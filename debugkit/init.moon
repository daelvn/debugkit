--- Print debugging module
-- @module init
-- @author daelvn
unpack or= table.unpack

--- A map function with varargs. **Curried function.**
-- @tparam function f Transforming function.
-- @param ... Variables to map.
-- @return ... Variables applied to f.
mapM = (f) -> (...) -> unpack [f v for v in *{...}]

--- Sets instant printing (no virtual buffer) for stdout.
doInstant = -> io.stdout\setvbuf "no"

--- Custom inspect functions with filters. **Curried function.**
-- @tparam function inspect [Inspect](https://github.com/kikito/inspect.lua) function.
-- @tparam function filter Filter function.
-- @tparam number depth Depth of the table.
-- @param ... Variables to inspect.
-- @return ... Inspected variables.
finspect = (inspect) -> (filter) -> (depth) -> (...) -> (mapM (x)->inspect x, :depth, process: filter) ...

--- Filtered print. Will not print if the string does not pass the filter.
-- @tparam function filter Filter function.
-- @param ... Variables to filter and print.
fprint = (filter) -> (...) ->
  doPrint = true
  for v in *{...} do unless filter v
    doPrint = false
  print ... if doPrint

--- Matches a keyword list in a value. **Curried function.**
-- @tparam table keywords Keyword list.
-- @param any Value to be checked.
filterKeywords = (keywords) -> (any) ->
  return if ("string" == type any)
    for keyword in *keywords
      false if any\match keyword
    true
  else true

--- Special case of `fprint`. Gets a list of keywords and won't print anything if at least one of the keywords appears in
-- a string. **Curried function.**
-- @tparam table keywords Keyword list.
-- @param ... Variables to filter and print.
fsprint = (keywords, f=filterKeywords, g=((...)->...)) -> (...) -> (fprint f keywords) g ...

--- Composable `fsprint`, to combine with other filtering functions.
-- @tparam function f Function to compose `filterKeywords` with.
-- @tparam table keywords Keyword list.
-- @param ... Variables to filter and print.
cfsprint = (f) -> (keywords) -> fsprint keywords, filterKeywords, f

c      = require "ansicolors"
_color = (t) -> (x) ->
  for k, v in pairs t do
    x = x\gsub k, "%%{#{v}}#{k}%%{reset}"
  c x
--- Custom color formatting function over ansicolors. **Curried function.**
-- @tparam table format A table where the keys are substrings to color, and values are the format.
-- @param ... Strings to color.
color = (format) -> (...) -> (mapM _color format) ...

--- Table with functions to format entire strings.
-- Shares fields with [ansicolors](https://github.com/kikito/ansicolors.lua)' formatting options. So colorall.red becomes `(x) -> color ("%{red}" .. x)`
-- @table colorall
colorall = setmetatable {}, __index: (i) => (x) -> c ("%{#{i}}" .. x)

MODULE = { :mapM, :doInstant, :finspect, :fprint, :filterKeywords, :fsprint, :cfsprint, :color, :colorall}

id = (...) -> ...
-- Will return `id` functions if `bool` is false.
return (bool) -> bool and MODULE or {
  mapM:           id
  doInstant:      id
  finspect:       id
  fprint:         id
  filterKeywords: id
  fsprint:        id
  cfsprint:       id
  color:          id
  colorall:       setmetatable {}, __call: id, __index: => id
}
