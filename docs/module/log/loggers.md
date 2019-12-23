---
title: debugkit.log.loggers
description: Loggers using log.init
path: tree/master/debugkit/log
source: loggers.moon
---

# debugkit.log.loggers

All below return the logger when called.

## leveled

- `name`: `leveled`
- `sink`: `sink.print`
- `level`: `info`
- `levels`: `none`, `debug`, `info`, `ok`, `warn`, `error`, `fatal`, `all`
- `time`: `os.date "%X"`
- `date`: `""`
- `color`: `true`
- `footer`: ``

### Header

The header is formed from a non-standard component named `headers`. `headers` is a table that contains a function `base` which acts as the non-changing part of the header (time, name...) and a table of functions `levels` with one function per level that adds a header in the style of `[LEVEL]`. Feel free to mess around with it to know the colors for each one.

From the logger, `header` is called with self and the level of the message, and it assembles both parts together.