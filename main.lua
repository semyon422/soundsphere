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
aquapackage.add("md5")

local MainLog = require("sphere.MainLog")
MainLog:write("trace", "starting game")

require("aqua")
require("aqua.event"):init()
require("sphere.SphereGame"):run()
