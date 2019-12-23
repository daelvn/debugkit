import logger      from require "debugkit.log"

myLogger       = logger.minimal!
myLogger.level = "all"

all  = myLogger "all"
--none = myLogger "none"

all "bepis", "bappo"
all "hide",  "bappae"