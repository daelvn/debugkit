-- debugkit.loggers
-- Loggers collection
-- By daelvn
import Logger, sink, levels from require "debugkit.log"
import style                from require "ansikit.style"

-- Logger collection
logger = {}

-- Leveled logger
logger.leveled = -> Logger {
  name:           "leveled"
  sink:           sink.print
  level:          "info"
  levels:         levels {"none", "debug", "info", "ok", "warn", "error", "fatal", "all"}
  time:           os.date "%X"
  footer:         => ""
  headers:        {
    base: => @color and (style "%{white bold}#{@time!} %{green}#{@name} ") or "#{@time!} #{@name}"
    levels:
      none:  => @color and ((style.white         "[NONE]" ) .. (style.reset "  "  )) or "[NONE] "
      debug: => @color and ((style.white.bluebg  "[DEBUG]") .. (style.reset " "   )) or "[DEBUG]"
      info:  => @color and ((style.cyan          "[INFO]" ) .. (style.reset "  "  )) or "[INFO] "
      ok:    => @color and ((style.green         "[OK]"   ) .. (style.reset "    ")) or "[OK]   "
      warn:  => @color and ((style.yellow        "[WARN]" ) .. (style.reset "  "  )) or "[WARN] "
      error: => @color and ((style.red           "[ERROR]") .. (style.reset " "   )) or "[ERROR]"
      fatal: => @color and ((style.white.redbg   "[FATAL]") .. (style.reset " "   )) or "[FATAL]"
      all:   => @color and ((style.black.whitebg "[ALL]"  ) .. (style.reset "   " )) or "[ALL]  "   
  }
  header: (tag, level) => (@headers.base @) .. (@headers.levels[level] @)
}

return logger