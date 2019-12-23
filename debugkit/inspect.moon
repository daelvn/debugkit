-- debugkit.inspect
-- Colorized inspect.lua
-- By daelvn
import style from require "ansikit.style"
pcre            = require "rex_pcre2"
inspect         = require "inspect"

colorize = (str) ->
  with str
    str = pcre.gsub str, [[((?<![\\])['"])((?:.(?!(?<![\\])\1))*.?)\1]], style.green        [[%0]]
    str = \gsub [[<(.-)>]],                                              style.cyan         [[<%1>]]
    str = \gsub "%s+([+-]?%d*%.?%d+)[,\n]",                              style.magenta      " %1#{style.white ","}"
    str = \gsub "inf,",                                                  style.magenta      "inf#{style.white ","}"
    str = \gsub "=",                                                     style.bold.blue    "="
    str = \gsub "([{}])",                                                style.bold.white   "%1"
    str = \gsub "true",                                                  style.italic.green "true"
    str = \gsub "false",                                                 style.italic.red   "false"
    str = \gsub "__[a-zA-Z0-9]+",                                        style.italic       "%1"
    str = \gsub "  ",                                                    style.faint.white  "| "
  str

i = (v, s) -> colorize inspect v, s

{ inspect: i }