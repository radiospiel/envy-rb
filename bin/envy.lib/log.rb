module Log
  NOTHING      = '0;0'
  BLACK        = '0;30'
  RED          = '0;31'
  GREEN        = '0;32'
  BROWN        = '0;33'
  BLUE         = '0;34'
  PURPLE       = '0;35'
  CYAN         = '0;36'
  LIGHT_GRAY   = '0;37'
  DARK_GRAY    = '1;30'
  LIGHT_RED    = '1;31'
  LIGHT_GREEN  = '1;32'
  YELLOW       = '1;33'
  LIGHT_BLUE   = '1;34'
  LIGHT_PURPLE = '1;35'
  LIGHT_CYAN   = '1;36'
  WHITE        = '1;37'

  extend self

  def debug(msg, *args);   log "DBG", LIGHT_GRAY, msg, *args; end
  def info(msg, *args);    log "INF", LIGHT_CYAN, msg, *args; end
  def warn(msg, *args);    log "WRN", YELLOW, msg, *args; end
  def error(msg, *args);   log "ERR", RED, msg, *args; end
  def success(msg, *args); log "OK", GREEN, msg, *args; end

  private

  def log(prefix, color, msg, *args)
    msg = "[#{prefix}] #{msg} #{args.map(&:inspect).join(" ")}"
    msg = colored(msg, color: color)
    STDERR.puts msg
  end

  def colored(msg, color:)
    "\e[#{ color }m#{msg}\e[0;0m" 
  end
end
