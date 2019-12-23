---
title: debugkit.log.init
description: Logging functions
path: tree/master/debugkit/log
source: init.moon
---

# debugkit.log.init

A logger module, introducing the concept of sinks and loggers.

## Sinks

Sinks are interfaces that get logger messages and turn them into
another representation. Sinks can output to stdout, files, databases,
networks... and anything you want, as long as you code it of course.

### Components

- `flag`: (table) flags for the sink.
- `open`: (function) function that opens the sink.
- `write`: (function) function that writes a message to the sink.
- `close`: (function) function that closes the sink.

## Loggers

Loggers produce the messages to be passed to the sinks. They feature
levels and tags which the sinks can filter out. They are pretty
much self-explanatory.

The sink is opened when the function returned by `Logger` is called.

### Components

- `color`: (boolean) whether to use color or not.
- `name`: (string) name of the app.
- `sink`: (Sink) sink to use with the logger.
- `level`: (string) current logging filter. rejects all below.
- `levels`: (table) using [`levels`](#levels), the list of levels availiable, from least important to most important.
- `time`: (function) called with self, must return time.
- `date`: (function) called with self, must return date.
- `header`: (function) called with self, must return a header for the message.
- `footer`: (function) called with self, must return a footer for the message.
- `exclude`: (table) unordered list of tags to filter out.
- `open`: (function) calls `Logger.sink.open(Logger.sink)`.
- `close`: (function) calls `Logger.sink.close(Logger.sink)`.

## Sink

**Signature ->** `table -> Sink`<br>

Takes a table with any components (all are optional but you will probably want to pass `write`, at least).

## Logger

**Signature ->** `table -> Logger`

Takes a table with any components (all are optional, and if none are passed, it will automatically create a working minimal logger practically equivalent to logger.default in no color mode).

The returned Logger can be called again and has the following signature `level:string -> [tag:string], msg:string -> nil`. It first takes a level, and generates a function that only posts to that level so it can be filtered. This is where the sink is opened, and using flags you can make sure it doesnt get opened more than once. Then, it takes an optional tag for filtering and a message.

## List of sinks

All bellow return the sink only when called.

### sink.null

Doesn't do absolutely anything.

### sink.all

Prints all messages with `print`, regardless of level or tag.

### sink.print

Prints all messages with `print`, looking at level and tags.

### sink.write

Prints all messages with `io.write`, looking at level and tags.

### sink.file

Takes a filename and returns a sink that writes to that file,
looking at level and tags.

## List of loggers

All below return the logger only when called.

### logger.minimal

Produces messages with a count of times logged, nothing else. Color is availiable. It has the rest of components, levels and tags from
`default`, etc. This logger is not meant to use them, but you may.

```
1 $ test string
2 $ this is how it looks like
```

### logger.default

Default logger.

- `name`: `default`
- `sink`: `sink.write`
- `level`: `all`
- `levels`: `none`, `all`
- `time`: `os.date "%X"`
- `date`: `""`
- `color`: `true`
- `footer`: `\n`
- `header`: `%{white bold}#{@time!} %{green}#{@name} ` with possibility to omit colors.