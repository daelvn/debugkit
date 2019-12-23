# debugkit Basics

This manual covers the basics of logging and inspecting using
debugkit.

## Inspecting

There is not much to this, you simply import the function
and use it exactly the same way as you would with [inspect.lua](https://github.com/kikito/inspect.lua).

```lua tab="Lua"
inspect = require"debugkit.inspect".inspect
print(inspect(t))
```

```moon tab="MoonScript"
import inspect from require "debugkit.inspect"
print inspect t
```

## Logging

### Getting Started

Logging is a bit more complex. For a simple task such as the usual
print debugging, you might just want to use the minimal logger.

```lua tab="Lua"
logger         = require"debugkit.log".logger
myLogger       = logger.minimal()
myLogger.level = "all"
log            = myLogger "all"

log("tag", "msg")
```

```moon tab="MoonScript"
import logger from require "debugkit.log"
myLogger       = logger.minimal!
myLogger.level = "all"
log            = myLogger "all"

log "msg"
```

This works if you're print-debugging. However, if you need actual
logging with time, levels, tags. That will not suffice.

### Headers and footers

Before anything else, you will want to know how headers and footers
work for properly printing messages (or logging them into a file).

These are obtained by the logger by calling `self:header()`
and `self:footer()` (or `@header!` and `@footer!` if you
are using MoonScript) from within the Logger function. They must be
functions so things like setting the level, time and date work.
Let's look at the definition of a header.

```lua tab="Lua"
logger.example = function() return Logger {
    header = function(self, tag, level)
      return ("%s %s [%s]"):format self.time(), self.name, level
    end
  }
end
```

```moon tab="MoonScript"
logger.example = -> Logger header: (tag, level) => "#{@time!} #{@name} [#{level}]"
```

!!! note
    Footers work exactly the same way, getting passed self, tag and
    level.

As we can see, the header function takes the header itself and the
level for the message, and then returns a formatted string. It calls
time so that it returns a different time each time. `time` is defined
as:

```lua tab="Lua"
logger.example = function() return Logger {
    time = function(self) return os.date "%X" end
  }
end
```

```moon tab="MoonScript"
logger.example = -> Logger time: => os.date "%X"
```

Now, you might want to make your header depend on the level being
used, say, for coloring differently. Let's check the definition in
the [loggers](/module/loggers/) module.

```lua tab="Lua"
-- leveled logger
logger.leveled = function()
  return Logger({
    headers = {
      base = function(self)
        return self.color and (style("%{white bold}" .. tostring(self:time()) .. " %{green}" .. tostring(self.name) .. " ")) or tostring(self:time()) .. " " .. tostring(self.name)
      end,
      levels = {
        none = function(self)
          return self.color and ((style.white("[NONE]")) .. (style.reset("  "))) or "[NONE] "
        end,
        debug = function(self)
          return self.color and ((style.white.bluebg("[DEBUG]")) .. (style.reset(" "))) or "[DEBUG]"
        end,
        info = function(self)
          return self.color and ((style.cyan("[INFO]")) .. (style.reset("  "))) or "[INFO] "
        end,
        ok = function(self)
          return self.color and ((style.green("[OK]")) .. (style.reset("    "))) or "[OK]   "
        end,
        warn = function(self)
          return self.color and ((style.yellow("[WARN]")) .. (style.reset("  "))) or "[WARN] "
        end,
        error = function(self)
          return self.color and ((style.red("[ERROR]")) .. (style.reset(" "))) or "[ERROR]"
        end,
        fatal = function(self)
          return self.color and ((style.white.redbg("[FATAL]")) .. (style.reset(" "))) or "[FATAL]"
        end,
        all = function(self)
          return self.color and ((style.black.whitebg("[ALL]")) .. (style.reset("   "))) or "[ALL]  "
        end
      }
    },
    header = function(self, level)
      return (self.headers.base(self)) .. (self.headers.levels[level](self))
    end
  })
end
```

```moon tab="MoonScript"
-- Leveled logger
logger.leveled = -> Logger {
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
```

It is pretty much self-explanatory. The logger calls `header`, and
this uses a base in the table `headers` and a level from
`headers.levels`. That is a way of making changing headers, but you
can customize it as you wish.

### Tags

Tags are a really simple concept that allow you to exclude and filter
messages depending on their "topic". For example, I am logging two
things at debug level, one is about strings and the other about
numbers. If I am debugging numbers, I will only want to know about
the number messages.

Loggers let you prefix a tag to your message, like `log("tag", "msg")`
, and using a table in the logger, `exclude`, you can filter out the
messages that are in the table `exclude`. So I would do:

```lua
myLogger.exclude = {"string"}
log              = myLogger "debug"

log ("string", "will not print")
log ("number", "will print")
```

And now it will only print the second message.

### Levels

Levels are the way of filtering out whole categories of messages.
[`logger.leveled`](/module/log/loggers/#logger_leveled) has 7:

- none
- debug
- info
- ok
- warn
- error
- fatal
- all

These are in order, from least important to most important. Using the
function [`levels`](/module/log/init/#levels), you can pass it an
ordered list of levels and you will get a reversed table back (
keys become values, values become keys), making each level a certain
number. Now, when you log a message with a level, it checks its number
, and the sink (usually) will only print if the message level is equal
or superior to the minimum level (set in `Logger.level`).

### Sinks

You can use a different sink with a logger just by changing the
`Logger.sink` component. For example, I can make `logger.leveled`
print JSON strings doing:

```lua
myLogger      = logger.minimal()
myLogger.sink = sink.json()
log           = myLogger()
```

It's really simple and works on the fly, but if you change the sink
after it has been opened, you will need to close the previous one, then change it, then open it manually again, like this:

```lua tab="Lua"
myLogger:close()
myLogger.sink = sink.file "example.log"
myLogger:open()
```

```moon tab="MoonScript"
myLogger\close!
myLogger.sink = sink.file "example.log"
myLogger\open!
```

Not all sinks need to be opened, but you won't get an error from
trying to open one which doesn't have an `open` method, or from
trying to close one which doesn't have a `close` method.