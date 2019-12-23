-- debugkit.log
-- Lua and MoonScript logger
-- https://xkcd.com/927/
-- By daelvn
import style    from require "ansikit.style"
import safeOpen from require "filekit"

-- Returns a list of levels
-- Also inverses table keys and values
-- {1: v} -> {v: 1}
levels  = (t) -> {v, i for i, v in ipairs t}
inverse = levels

-- check if a table contains an element
-- memoized
_cache_contains = {}
contains        = (e, t) ->
  _cache_contains[t] = inverse t unless _cache_contains[t]
  _cache_contains[t][e] and true or false


-- Creates a Sink for the logger
Sink ==> setmetatable {
  flag:      @flag  or {}
  open:      @open  or ->
  write:     @write or ->
  close:     @close or ->
}, __type: "Sink"

-- Sinks
sink        = {}
sink.null   =        -> Sink!
sink.all    =        -> Sink write: (L, tag, level, msg) => print msg
sink.print  =        -> Sink write: (L, tag, level, msg) => print msg    if (L.levels[level] >= L.levels[L.level]) and (not contains tag, L.exclude)
sink.write  =        -> Sink write: (L, tag, level, msg) => io.write msg if (L.levels[level] >= L.levels[L.level]) and (not contains tag, L.exclude)
sink.file   = (file) -> Sink {
  open: =>
    unless @flag.opened
      fh  = safeOpen file, "a"
      if fh.error then error "sink.file $ could not open file #{file}!"
      @fh, @flag.opened = fh, true
  write: (L, tag, level, msg) =>
    if @flag.opened
      @fh\write msg if (L.levels[level] >= L.levels[L.level]) and (not contains tag, L.exclude)
    else
      error "sink.file $ sink is not open!"
  close: =>
    if @flag.opened
      @fh\close!
      @flag.opened = false
}

-- Creates a new Logger
Logger ==>
  -- defaults
  @color   or= true                                     -- use color
  @name    or= ""                                       -- name of the app
  @sink    or= sink.write!                              -- writing target
  @level   or= "all"                                    -- current logging level
  @levels  or= levels {"none", "all"}                   -- available levels
  @time    or=       => os.date "%X"                    -- time
  @date    or=       => ""                              -- date
  @header  or= (t,l) => "#{@time!} #{@name} #{@level} " -- header for the message
  @footer  or= (t,l) => "\n"                            -- footer for message
  @exclude or= {"hide"}                                 -- tags to exclude
  -- create shortcuts for sink
  @open  ==> @sink\open!
  @close ==> @sink\close!
  -- return object
  setmetatable @, {
    __call: (t, level="all") ->
      @open!        -- open sink
      (tag, msg) -> -- return logger function
        if not msg
          @sink\write @, "show", level, "#{@header "show", level}#{tag}#{@footer tag, level}"
        else
          @sink\write @, tag, level, "#{@header tag, level}#{msg}#{@footer tag, level}"
    __type: "Logger"
  }

-- Loggers
logger         = {}
-- minimal logger
logger.minimal = -> Logger {
  _count: 0
  name:   "log"
  header: =>
    @_count += 1
    @color and (style "%{white bold}#{@_count} %{yellow}$ ") or "#{@_count} $ "
}
-- default logger
logger.default = -> Logger {
  name:   "default"                                          -- name of the app
  sink:   sink.write!                                        -- sink to write to
  level:  "all"                                              -- minimum log level
  levels: levels {"none", "all"}                             -- list of levels
  time:   => os.date "%X"                                    -- time
  date:   => ""                                              -- date
  color:  true                                               -- use color
  footer: => "\n"                                            -- footer
  header: =>                                                 -- header
    @color and (style "%{white bold}#{@time!} %{green}#{@name} ") or "#{@time!} #{@name}"
}

{
  :Sink,   :sink
  :Logger, :logger
  :levels
}