-- debugkit.log.sinks
-- Sinks collection
-- By daelvn
import Sink              from require "debugkit.log"
import safeOpen, getSize from require "filekit"

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

-- Sinks collections
sink = {}

-- JSON Sink
local encode
do
  -- cjson - https://www.kyne.com.au/~mark/software/lua-cjson-manual.html
  ok, json = pcall -> require "cjson"
  if ok then encode = json.encode
  -- dkjson - http://dkolf.de/src/dkjson-lua.fsl/home
  ok, json = pcall -> require "dkjson"
  if ok then encode = json.encode
  -- json.lua (rxi-json-lua) - https://github.com/rxi/json.lua
  ok, json = pcall -> require "json"
  if ok then encode = json.encode else -> 404
--
sink.json = -> Sink {
  write: (L, tag, level, msg) =>
    data = {
      name:    L.name
      level:   L.level
      time:    L.time!
      date:    L.date!
      exclude: L.exclude
      flag:    @flag
    }
    -- message
    msg = encode {
      message: msg
      :level
      :data
      :tag
    }
    return if (msg == 404) or (msg == nil)
    -- write
    io.write msg if (L.levels[level] >= L.levels[L.level]) and (not contains tag, L.exclude)
}

-- Rolling file Sink
sink.rollingFile = (file, size=1000000) -> Sink {
  open: (f=file) =>
    @flag.current = f
    unless @flag.opened
      fh  = safeOpen f, "a"
      if fh.error then error "sink.rollingFile $ could not open file #{f}!"
      @fh, @flag.opened = fh, true
    unless @flag.initialized
      @flag.size      or= size
      @flag.filename  or= file
      @flag.count     or= 0
      @flag.initialized = true
  write: (L, tag, level, msg) =>
    if @flag.opened
      if ((getSize @flag.current) + #msg) < @flag.size
        @fh\write msg if (L.levels[level] >= L.levels[L.level]) and (not contains tag, L.exclude)
      else
        @close!
        @flag.count += 1
        @open "#{@flag.filename}.#{@flag.count}"
        @write L, level, msg
    else
      error "sink.file $ sink is not open!"
  close: =>
    if @flag.opened
      @fh\close!
      @flag.opened = false
}

return sink