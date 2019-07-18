setmetatable(_G, {
	__newindex = function(a, b, c)
		print(a, b, c, debug.traceback())
		rawset(a, b, c)
	end
})

local aquapackage = require("aqua.aqua.package")
aquapackage.add("aqua")
aquapackage.add("ncdk")
aquapackage.add("chartbase")
aquapackage.add("log")

local log = require("log")
log.usecolor = false
log.outfile = "userdata/log.txt"
log.level = "trace"

log.trace("starting game")

require("aqua")

require("aqua.io"):init()

require("sphere.SphereGame"):run()
