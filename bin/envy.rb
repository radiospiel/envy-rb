#!/usr/bin/env ruby

# rubocop:disable Metrics/ModuleLength

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "simple-cli", "~> 0.2.23"
  gem "expectation"
end

LIB = File.join(File.dirname(__FILE__), "envy.lib")

require "shellwords"
require "open3"
require "openssl"
require "securerandom"
require "fileutils"
require "base64"

class File
  def self.write(path, content)
    # [TODO] open me in 0600 mode.
    File.open(path, "w") { |io| io.write(content) }
  end
end

module Envy
  include Simple::CLI

  # -- envy run ---------------------------------------------------------------

  # run a command, with environment loaded from envy file.
  # If no command is defined
  def run(file, cmd, *args)
    env = Environment.load(source: file)
    exec env, cmd, *args
  end

  # fill in environment values into a template.
  def template(file, template)
    config = Environment.load(source: file)
    template = File.read(template)
    result = template.gsub(/{{([^}:]+)(:([^}]+))?}}/) do |_|
      key = $1
      default_value = ENV[key] || $3
      if default_value
        config.fetch(key, default_value)
      else
        config.fetch(key)
      end
    end
    puts result
  end

  # Load a file
  def load(file, export: false, json: false)
    config = Environment.load(source: file)

    if json
      require "json"
      puts JSON.pretty_generate(config)
    else
      export_prefix = export ? "export " : ""

      config.each do |k, v|
        puts "#{export_prefix}#{k}=#{Shellwords.escape(v)}"
      end
    end
  end

  # Edit a file
  def edit(file)
    unless File.exist?(file)
      generate file
      return
    end

    with_tmp_file do |tmp_file|
      Environment.unlock source: file, dest: tmp_file
      edit_file tmp_file
      Environment.lock source: tmp_file, dest: file
    end
  end

  # Generate a file
  def generate(file)
    FileUtils.mkdir_p File.dirname(file)

    with_tmp_file do |tmp_file|
      template = File.read(__FILE__).split("\n__END__\n", 2).last
      raise Exception, "Cannot read template" unless template

      File.write tmp_file, template
      edit_file tmp_file
      Environment.lock source: tmp_file, dest: file
    end
  end

  private

  def edit_file(file)
    editor = ENV["EDITOR"] || "vi"
    sys! "#{editor} #{Shellwords.escape(file)}"
  end

  def with_tmp_file(&block)
    _ = block

    require "tempfile"

    file = Tempfile.new("foo")
    file.close
    yield file.path
  ensure
    file.unlink
  end

  public

  # generate a new secret
  def secret_generate
    Secret.generate
  end

  # generate a gpg file using a symmetric password.
  #
  # Usage:
  #
  #   envy secret:backup eny.secret.backup
  #   envy secret:restore eny.secret.backup
  #
  def secret_backup(path, force: false)
    confirm! "We'll run gpg to create an encrypted version of the secret file. You will be asked for a passphrase!" unless force

    system "gpg -o #{Shellwords.escape(path)} --symmetric --armor #{Shellwords.escape(Secret.path)}"

    File.open path, "a" do |io|
      io.puts <<~MSG
                This is an encrypted envy(3) secret. To restore the secret please run
        envy secret:restore <path_to_this_file>.
      MSG
    end

    logger.success "Created #{path}"
  end

  # restore a secret
  def secret_restore(path, force: false)
    confirm! "We'll run gpg to decrypt the supplied file. You will be asked for a passphrase!" unless force

    secret = IO.popen "gpg --decrypt #{Shellwords.escape(path)}", &:read

    raise "Could not read secret, gpg failed." unless $?.exitstatus == 0

    Secret.set secret
  end

  # print a secret
  def secret_show
    puts Secret.get
  end

  # The Secret module handles secrets.
  module Secret
    extend self

    # set the secret to a new value
    def set(secret)
      if File.exist?(path)
        backup_path = "#{path}.bak"
        Simple::CLI.logger.info "Backing up secret in #{backup_path}"
        FileUtils.mv path, backup_path
      end

      File.write(path, secret)
      File.chmod(0400, path)
      Simple::CLI.logger.info "Generated #{path}"
    end

    # generate a secret with a given name.
    #
    # The secret is stored in the file system in $HOME/.<name>.envy
    def generate
      raise "The secret file #{path} already exists." if File.exist?(path)

      set SecureRandom.hex(16)
    end

    ENVY_BASE_NAME = ".secret.envy"

    def path
      if path = ENV["ENVY_SECRET_PATH"]
        Simple::CLI.logger.debug "read secret storage from ENVY_SECRET_PATH: #{path}"
      else
        path = File.join(ENV["HOME"], ENVY_BASE_NAME)
        Simple::CLI.logger.debug "secret storage in #{path}"
      end

      path
    end

    # returns the secret as a printable (hex) string
    def get
      File.read(path)
    end

    # encrypt or decrypt data
    def cipher(cipher_mode, data)
      expect! cipher_mode => [ :decrypt, :encrypt ]

      case cipher_mode
      when :decrypt
        expect! data => /^envy:/
        cipher_op(:decrypt, data: Base64.decode64(data[5..-1]))
      when :encrypt
        "envy:" + Base64.strict_encode64(cipher_op(:encrypt, data: data))
      end
    end

    private

    CIPHER = "AES-128-CBC"

    def cipher_op(mode, data:)
      expect! mode => [ :decrypt, :encrypt ]

      binary_secret = get.scan(/../).map(&:hex).pack("c*")

      cipher = OpenSSL::Cipher.new(CIPHER)
      cipher.send(mode)
      cipher.key = binary_secret
      cipher.update(data) + cipher.final
    end
  end

  module Environment
    extend self

    def load(source:)
      env, _commands = load_file(source: source)
      env
    end

    def commands(source:)
      _env, commands = load_file(source: source)
      commands
    end

    def load_file(source:)
      env = {}

      in_run_block = false
      commands = []

      process(:decrypt, source: source) do |mode, line|
        case mode
        when :header
          in_run_block = line.start_with?("[run]")
        when String
          env.update mode => line if mode.is_a?(String)
        end
      end

      commands = nil if commands.empty?
      [env, commands]
    end

    def unlock(source:, dest:)
      process_and_write(:decrypt, source: source, dest: dest)
    end

    def lock(source:, dest:)
      process_and_write(:encrypt, source: source, dest: dest)
    end

    private

    def process_and_write(cipher_mode, source:, dest:)
      r = []

      process(cipher_mode, source: source) do |mode, line|
        # process lines that contain a value. In that case mode is the name of
        # the environment value. In all other cases mode is a symbol, and line
        # contains the entire line.
        line = "#{mode}=#{line}\n" if mode.is_a?(String)
        r << line
      end

      File.write(dest, r.join(""))
    end

    def process(cipher_mode, source:)
      public_block = true

      File.readlines(source).each do |line|
        case line
        when /^\s*#/, /^\s*$/
          yield :comment, line
        when /^\s*\[((.+)\.)?secure\]$/
          public_block = false
          yield :header, line
        when /^\s*\[(.+)\]$/
          public_block = true
          yield :header, line
        when /^\s*([a-zA-Z0-9_]+)\s*=\s*(.*)\s*$/
          value = public_block ? $2 : Secret.cipher(cipher_mode, $2)
          yield $1, value
        else
          yield :blank, line
        end
      end
    end
  end
end

Envy.run!(*ARGV)

__END__
#
# This is an envy(3) file.
#
# Use "envy edit path-to-file" to edit this file.
#

#
# A non-secured part. Note that part names are only here for documentation purposes.
#
[http]
HTTP_PORT=80

#
# A secure block: every entry in a block named [secure] or [something.secure]
# will be encrypted.
[secure]
MY_PASSWORD=This is my password

#
# Another non-secured block
[database]
DATABASE_POOL_SIZE=10

#
# Another secured block
[database.secure]
DATABASE_URL=postgres://pg_user:pg_password/server:5432/database/schema
