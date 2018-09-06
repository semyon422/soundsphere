require("tweaks")
require("utf8validate")
json = require("json")
require("Observer")
require("Config")

require("soul")
require("ncdk")
require("bms")
require("osu")
require("ucs")

soul.init()

ffi = require("ffi")
utf8 = require("utf8")

require("bass_ffi")
bassInit()

require("iconv_ffi")

require("ResourceLoader")
require("AudioManager")