local unpack = unpack or table.unpack
local mapM
mapM = function(f)
  return function(...)
    return unpack((function(...)
      local _accum_0 = { }
      local _len_0 = 1
      local _list_0 = {
        ...
      }
      for _index_0 = 1, #_list_0 do
        local v = _list_0[_index_0]
        _accum_0[_len_0] = f(v)
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)(...))
  end
end
local doInstant
doInstant = function()
  return io.stdout:setvbuf("no")
end
local finspect
finspect = function(inspect)
  return function(filter)
    return function(depth)
      return function(...)
        return (mapM(function(x)
          return inspect(x, {
            depth = depth,
            process = filter
          })
        end))(...)
      end
    end
  end
end
local fprint
fprint = function(filter)
  return function(...)
    local doPrint = true
    local _list_0 = {
      ...
    }
    for _index_0 = 1, #_list_0 do
      local v = _list_0[_index_0]
      if not (filter(v)) then
        doPrint = false
      end
    end
    if doPrint then
      return print(...)
    end
  end
end
local filterKeywords
filterKeywords = function(keywords)
  return function(any)
    if ("string" == type(any)) then
      for _index_0 = 1, #keywords do
        local keyword = keywords[_index_0]
        if any:match(keyword) then
          local _ = false
        end
      end
      return true
    else
      return true
    end
  end
end
local fsprint
fsprint = function(keywords, f, g)
  if f == nil then
    f = filterKeywords
  end
  if g == nil then
    g = (function(...)
      return ...
    end)
  end
  return function(...)
    return (fprint(f(keywords)))(g(...))
  end
end
local cfsprint
cfsprint = function(f)
  return function(keywords)
    return fsprint(keywords, filterKeywords, f)
  end
end
local c = require("ansicolors")
local _color
_color = function(t)
  return function(x)
    for k, v in pairs(t) do
      if "string" == type(x) then
        x = x:gsub(k, "%%{" .. tostring(v) .. "}" .. tostring(k) .. "%%{reset}")
      end
    end
    return c(x)
  end
end
local color
color = function(format)
  return function(...)
    return (mapM(_color(format)))(...)
  end
end
local colorall = setmetatable({ }, {
  __index = function(self, i)
    return function(x)
      return c(("%{" .. tostring(i) .. "}" .. x))
    end
  end
})
local MODULE = {
  mapM = mapM,
  doInstant = doInstant,
  finspect = finspect,
  fprint = fprint,
  filterKeywords = filterKeywords,
  fsprint = fsprint,
  cfsprint = cfsprint,
  color = color,
  colorall = colorall
}
local id
id = function(...)
  return ...
end
return function(bool)
  return bool and MODULE or {
    mapM = id,
    doInstant = id,
    finspect = id,
    fprint = id,
    filterKeywords = id,
    fsprint = id,
    cfsprint = id,
    color = id,
    colorall = setmetatable({ }, {
      __call = id,
      __index = function(self)
        return id
      end
    })
  }
end
