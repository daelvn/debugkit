---
title: debugkit.inspect
description: Colorize your inspect.lua output
path: tree/master/debugkit
source: inspect.moon
---
# debugkit.inspect

Simple colorizing for [inspect.lua](https://github.com/kikito/inspect.lua) using [lrexlib-pcre2](https://github.com/rrthomas/lrexlib) as a regex library (although only needed for matching strings correctly) and [ansikit](https://github.com/daelvn/ansikit).

## inspect

Clone of the `inspect` function in `inspect.lua`, except it colorizes
the output. It colors strings in green, tags in `<>` in cyan, numbers
in magenta, `=` in bold blue, `{` and `}` in bold white. `true` in
italics green and `false` in italics red. Metamethods in italics and
indentation adds guides in faint white.