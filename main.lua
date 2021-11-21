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
aquapackage.add("s3dc")
aquapackage.add("inspect")
aquapackage.add("lua-crc32")
aquapackage.add("serpent/src")

local ffi = require("ffi")

local jit_os = jit.os
local arch = jit.arch
if jit_os == "Windows" then
	local bin = arch == "x64" and "bin/win64" or "bin/win32"
	ffi.cdef("int _putenv_s(const char *varname, const char *value_string);")
	ffi.C._putenv_s("PATH", os.getenv("PATH") .. ";" .. bin)
	aquapackage.add(bin)
elseif jit_os == "Linux" then
	local ldlp = os.getenv("LD_LIBRARY_PATH")
	if not ldlp or not ldlp:find("bin/linux64") then
		ffi.cdef("int setenv(const char *name, const char *value, int overwrite);")
		ffi.C.setenv("LD_LIBRARY_PATH", (ldlp or "") .. ":bin/linux64", true)
		os.execute(arg[-2] .. " " .. arg[1] .. " &")
		return os.exit()
	end
	aquapackage.add("bin/linux64")
end
love.window.setMode(1, 1)

local aquafs = require("aqua.filesystem")

local source = love.filesystem.getSource()
local sourceBase = love.filesystem.getSourceBaseDirectory()
local moddedgame = love.filesystem.getInfo("moddedgame")
local moddedgamePrefix = ""
if source:find("^.+%.love$") then
	print("starting from .love file directly")
	aquafs.mount(sourceBase, "/", true)
	aquafs.setWriteDir(sourceBase)
	moddedgamePrefix = sourceBase .. "/"
else
	print("starting from current directory")
	aquafs.setWriteDir(source)
end
if moddedgame and moddedgame.type == "directory" then
	aquafs.mount(moddedgamePrefix .. "moddedgame", "/", false)
end

require("luamidi")

setmetatable(_G, {
	__newindex = function(a, b, c)
		print(a, b, c, debug.traceback())
		rawset(a, b, c)
	end
})

require("preloaders.preloadall")

local aquaevent = require("aqua.event")
aquaevent:init()

local GameController = require("sphere.controllers.GameController")
local gameController = GameController:new()

aquaevent:add(gameController)
gameController:load()
