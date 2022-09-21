require("hooks")

require("mime")
require("ltn12")
require("enet")
require("socket")

local aquapackage = require("aqua.aqua.package")
aquapackage.add("3rd-deps/lib")
aquapackage.add("3rd-deps/lua")
aquapackage.add("aqua")
aquapackage.add("ncdk")
aquapackage.add("chartbase")
aquapackage.add("libchart")
aquapackage.add("s3dc")
aquapackage.add("lua-crc32")
aquapackage.add("love-just-ui")

local ffi = require("ffi")

local source = love.filesystem.getSource()
local sourceBase = love.filesystem.getSourceBaseDirectory()

local root
if source:find("^.+%.love$") then
	print("starting from .love file directly")
	root = sourceBase
else
	print("starting from current directory")
	root = source
end

if jit.os == "Windows" then
	local winapi = require("winapi")
	winapi.putenv("PATH", ("%s;%s"):format(winapi.getenv("PATH"), root .. "/bin/win64"))
	winapi.chdir(root)
	aquapackage.add("bin/win64")
elseif jit.os == "Linux" then
	local ldlp = os.getenv("LD_LIBRARY_PATH")
	if not ldlp or not ldlp:find("bin/linux64") then
		ffi.cdef("int setenv(const char *name, const char *value, int overwrite);")
		ffi.C.setenv("LD_LIBRARY_PATH", (ldlp or "") .. ":" .. root .. "/bin/linux64", true)
		os.execute(("%q %q &"):format(arg[-2], arg[1]))
		return os.exit()
	end
	ffi.cdef("int chdir(const char *path);")
	ffi.C.chdir(root)
	aquapackage.add("bin/linux64")
end

local aquautf8 = require("aqua.utf8")
local errhand = love.errhand
function love.errhand(msg)
	return errhand(aquautf8.validate(msg))
end

local aquafs = require("aqua.filesystem")
aquafs.setWriteDir(root)

if root == sourceBase then
	aquafs.mount(root, "/", true)
end

local moddedgame = love.filesystem.getInfo("moddedgame")
if moddedgame and moddedgame.type == "directory" then
	aquafs.mount(root .. "/moddedgame", "/", false)
end

require("preloaders.preloadall")

local love_run = require("love_run")
love.load = function() end  -- for compatibility with old conf.lua
local defaultLoop = love.loop or love_run()
function love.run()
	return function()
		return defaultLoop()
	end
end

local aquathread = require("aqua.thread")
aquathread.coro(function()
	local UpdateController = require("sphere.controllers.UpdateController")
	local updateController = UpdateController:new()
	local needRestart = updateController:updateAsync()
	if needRestart then
		aquathread.unload()
		aquathread.waitAsync()
		return love.event.quit("restart")
	end

	require("luamidi")

	setmetatable(_G, {
		__newindex = function(a, b, c)
			print(a, b, c, debug.traceback())
			rawset(a, b, c)
		end
	})

	local GameController = require("sphere.controllers.GameController")
	local game = GameController:new()

	game:load()

	local aquaevent = require("aqua.event")
	aquaevent:init()
	defaultLoop = aquaevent.run()
	aquaevent:add(game)
end)()
