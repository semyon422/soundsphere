require("mime")
require("ltn12")
require("enet")
require("socket")

local aquapackage = require("aqua.aqua.package")
aquapackage.add("aqua")
aquapackage.add("ncdk")
aquapackage.add("chartbase")
aquapackage.add("libchart")
aquapackage.add("md5")
aquapackage.add("luajit-request")
aquapackage.add("json")
aquapackage.add("tinyyaml")
aquapackage.add("tween")

local os = jit.os
local arch = jit.arch
if os == "Windows" then
	if arch == "x64" then
		aquapackage.add("bin/win64")
	elseif arch == "x86" then
		aquapackage.add("bin/win32")
	end
elseif os == "Linux" then
	aquapackage.add("bin/linux64")
end

require("luamidi")

setmetatable(_G, {
	__newindex = function(a, b, c)
		print(a, b, c, debug.traceback())
		rawset(a, b, c)
	end
})

require("preloaders.preloadall")

local MainLog = require("sphere.MainLog")
MainLog:write("trace", "starting game")

local aqua = require("aqua")

aqua.filesystem.setWriteDir(love.filesystem.getSource())

local aquaevent = require("aqua.event")
aquaevent:init()

local GameController = require("sphere.controllers.GameController")
local gameController = GameController:new()

aquaevent:add(gameController)
gameController:load()
