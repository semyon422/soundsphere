require("hooks")

require("mime")
require("ltn12")
require("enet")
require("socket")

local pkg = require("aqua.package")
pkg.reset()
pkg.addc("3rd-deps/lib")
pkg.addc("bin/lib")
pkg.add("3rd-deps/lua")
pkg.add("aqua")
pkg.add("ncdk")
pkg.add("chartbase")
pkg.add("libchart")
pkg.add("tree/share/lua/5.1")

require("aqua.string")

if arg[2] == "test" then
	local runner = require("luacov.runner")
	runner.init()
end

local deco = require("deco")
deco.package_path = love.filesystem.getRequirePath()
deco.read_file = love.filesystem.read
deco.blacklist = {
	"3rd-deps",
	"tree",
	"aqua/byte.lua",
	-- "sphere/views",
}

local reqprof = require("reqprof")
if love.filesystem.getInfo("reqprof", "file") then
	deco.add(reqprof.ProfileDecorator())
	print("enabled reqprof.ProfileDecorator")
end

local typecheck = require("typecheck")
if love.filesystem.getInfo("typecheck", "file") then
	typecheck.strict = true
	deco.add(require("typecheck.TypeDecorator")())
	deco.add(require("typecheck.ClassDecorator")())
	print("enabled typecheck.TypeDecorator")
	print("enabled typecheck.ClassDecorator")
end

deco.replace_loader()

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
	pkg.addc("bin/win64")
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
	pkg.addc("bin/linux64")
end

love.errhand = require("errhand")

local physfs = require("physfs")
physfs.setWriteDir(root)

if root == sourceBase then
	assert(physfs.mount(root, "/", true))
end

local moddedgame = love.filesystem.getInfo("moddedgame")
if moddedgame and moddedgame.type == "directory" then
	assert(physfs.mount(root .. "/moddedgame", "/", false))
end

require("preload")

local love_run = require("love_run")
love.load = function() end  -- for compatibility with old conf.lua
local defaultLoop = love.loop or love_run()
function love.run()
	return function()
		return defaultLoop()
	end
end

if arg[2] == "test" then
	local testing = require("testing")

	testing.blacklist = {
		"3rd-deps",
		"tree",
		"libchart",
		"userdata",
	}

	testing.test()
	os.exit()
end

local delay = require("delay")
delay.set_timer(love.timer.getTime)

local thread = require("thread")
thread.coro(function()
	local UpdateController = require("sphere.update.UpdateController")
	local updateController = UpdateController()
	local needRestart = updateController:updateAsync()
	if needRestart then
		thread.unload()
		thread.waitAsync()
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
	local game = GameController()

	game:load()

	local loop = require("loop")
	loop:init()
	defaultLoop = loop:run()
	loop:add(game)
end)()
