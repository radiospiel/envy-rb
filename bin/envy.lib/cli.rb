# This module is supposed to be included from another file.
require "shellwords"
require_relative "./log"

module CLI
  extend self

  def run!(*args)
    command_name = args.shift || help!

    command = string_to_command(command_name)
    help! unless commands.include?(command)
    self.send command, *args_with_options(args)
  rescue ArgumentError => e
    Log.error "#{e}\n\n"
    help!
  rescue => e
    msg = e.to_s
    msg += " (#{e.class.name})" unless $!.class.name == "RuntimeError"
    Log.error msg
    exit 2
  end

  private

  def args_with_options(args)
    r = []
    options = {}
    while arg = args.shift
      case arg
      when /^--(.*)=(.*)/ then options[$1.to_sym] = $2
      when /^--no-(.*)/   then options[$1.to_sym] = false
      when /^--(.*)/      then options[$1.to_sym] = true
      else r << arg
      end
    end

    r << options unless options.empty?
    r
  end

  def command_to_string(sym)
    sym.to_s.gsub("_", ":")
  end

  def string_to_command(s)
    s.gsub(":", "_").to_sym
  end

  def commands
    public_instance_methods(false)
  end

  def help_for_command(sym)
    command_name = command_to_string(sym)
    method = instance_method(sym)

    #
    # [TODO] Try to parse default arguments from source, at method.source_location
    # file, line = method.source_location

    options = []
    args = []

    method.parameters.each do |mode, name|
      case mode
      when :req     then args << "<#{name}>"
      when :key     then options << "[ --#{name}[=<#{name}>] ]"
      when :keyreq  then options << "--#{name}[=<#{name}>]"
      when :opt     then args << "[ <#{name}> ]"
      when :rest    then args << "[ <#{name}> .. ]"
      end
    end

    help = "envy #{command_name}"
    help << " #{options.join(" ")}" unless options.empty?
    help << " #{args.join(" ")}" unless args.empty?
    help
  end

  def help!
    STDERR.puts "Usage:\n\n"
    commands.each do |sym|
      STDERR.puts "    #{help_for_command(sym)}"
    end
    STDERR.puts "\n"
    exit 1
  end

  def sys(cmd, *args)
    System.run(cmd, *args)
  end

  def sys!(cmd, *args)
    System.run!(cmd, *args)
  end

  class System
    def self.run(cmd, *args)
      command_line = new(cmd, *args)
      command_line.run
      $?.success?
    end

    def self.run!(cmd, *args)
      command_line = new(cmd, *args)
      command_line.run
      raise "failed with #{$?.exitstatus}: #{command_line}" unless $?.success?
    end

    def initialize(*args)
      @args = args
    end

    def run
      STDERR.puts "> #{self}"
      if @args.length > 1
        system to_s
      else
        system *@args
      end
    end

    def to_s
      escaped_args = @args.map do |arg| 
        escaped = Shellwords.escape(arg) 
        next arg if escaped == arg 
        next escaped if arg.include?("'")
        "'#{arg}'"
      end
      escaped_args.join(" ")
    end
  end
end
