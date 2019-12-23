---
title: debugkit.log.sinks
description: Sinks using log.init
path: tree/master/debugkit/log
source: sinks.moon
---

# debugkit.log.sinks

All below return the sink when called.

## json

Returns all data from the logger and sink as a JSON string. Encoded using any of the optional dependency JSON libraries. Exports logger name, level filter, time, date, excluding tags and flags in a table named `data`, and in the top level, the message, level of the message, and the tag.

## rollingFile

Taking a filename and a size in bytes (defaults to 1000000), creates a sink that will automatically start writing in another file (`(filename).(count)` except for the first one, which is just `filename`) after the file is deemed full.