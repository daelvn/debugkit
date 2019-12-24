local logger
logger = require("debugkit.log").logger
local myLogger = logger.minimal()
myLogger.level = "all"
local all = myLogger("all")
all("bepis", "bappo")
return all("hide", "bappae")
