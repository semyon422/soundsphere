require("hooks")

require("mime")
require("ltn12")
require("enet")
require("socket")

if arg[2] == "debug" then
    require("lldebugger").start()
end

local pkg = require("aqua.pkg")

pkg.addc()
pkg.addc("3rd-deps/lib")
pkg.addc("bin/lib")
pkg.add()
pkg.add("3rd-deps/lua")
pkg.add("aqua")
pkg.add("ncdk")
pkg.add("chartbase")
pkg.add("libchart")
pkg.add("tree/share/lua/5.1")

pkg.export_lua()
pkg.export_love()

require("aqua.string")

local luacov_runner
if arg[2] == "test" then
	local ok, err = pcall(require, "luacov.runner")
	if ok then
		luacov_runner = err
		luacov_runner.init()
	end
end

local deco = require("deco")
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
elseif jit.os == "OSX" then
	local ldlp = os.getenv("DYLD_FALLBACK_LIBRARY_PATH")
	if not ldlp or not ldlp:find("bin/mac64") then
		ffi.cdef("int setenv(const char *name, const char *value, int overwrite);")
		ffi.C.setenv("DYLD_FALLBACK_LIBRARY_PATH", root .. "/bin/mac64", true)
		--os.execute(("%q %q &"):format(arg[-2], arg[1]))
		--return os.exit()
	end
	ffi.cdef("int chdir(const char *path);")
	ffi.C.chdir(root)
	pkg.addc("bin/mac64")
end

pkg.export_lua()
pkg.export_love()

love.errhand = require("errhand")

local physfs = require("physfs")
physfs.setWriteDir(root)

if root == sourceBase then
	assert(physfs.mount(root, "/", true))
end

require("preload")

local modloader = require("modloader")(root)
modloader:loadMods()

local love_run = require("love_run")
love.load = function() end  -- for compatibility with old conf.lua
local defaultLoop = love.loop or love_run()
function love.run()
	return function()
		return defaultLoop()
	end
end

if arg[2] == "test" then
	local Testing = require("testing.Testing")
	local BaseTestingIO = require("testing.BaseTestingIO")

	local tio = BaseTestingIO()
	tio.blacklist = {
		".git",
		"3rd-deps",
		"tree",
		"userdata",
	}

	local testing = Testing(tio)

	local file_pattern, method_pattern = arg[3], arg[4]
	testing:test(file_pattern, method_pattern)

	if luacov_runner then
		debug.sethook(nil)
		luacov_runner.save_stats()
		require("luacov.reporter.lcov").report()
	end

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

	local GameController = require("sphere.controllers.GameController")
	local game = GameController()

	game:load()

	local loop = require("loop")
	loop:init()
	defaultLoop = loop:run()
	loop:add(game)
end)()
