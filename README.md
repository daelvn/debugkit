# debugkit

Print debugging made easier.

## Why?
Turns out I had implemented this exact thing in several forms across some of my projects, I decided to make it the same for all and put them in a separate module.

## How?
Calling `require "debugkit"` returns a function that takes your `DEBUG` flag. `true` is debug mode, `false` is not debugging. Calling it with the flag returns a table with the functions you need, so you can import from them. If debug mode is not activated, then all functions are replaced with `id`. That means that your code will still work but will not print any debug data.

```moon
debugkit = require "debugkit"
import fsprint from debugkit true -- your debug flag goes here
```

## Documentation

[Right here](https://git.daelvn.ga/debugkit/).

## Maintainer

Dael \<daelvn@gmail.com\>

## License

Released to the public domain.
