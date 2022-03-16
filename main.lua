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

local jit_os = jit.os
local arch = jit.arch
if jit_os == "Windows" then
	local bin = arch == "x64" and "bin/win64" or "bin/win32"
	ffi.cdef("int _putenv_s(const char *varname, const char *value_string);")
	ffi.cdef("int _chdir(const char *dirname);")
	ffi.C._putenv_s("PATH", os.getenv("PATH") .. ";" .. root .. "/" .. bin)
	ffi.C._chdir(root)
	aquapackage.add(bin)
elseif jit_os == "Linux" then
	local ldlp = os.getenv("LD_LIBRARY_PATH")
	if not ldlp or not ldlp:find("bin/linux64") then
		ffi.cdef("int setenv(const char *name, const char *value, int overwrite);")
		ffi.C.setenv("LD_LIBRARY_PATH", (ldlp or "") .. ":" .. root .. "/bin/linux64", true)
		os.execute(arg[-2] .. " " .. arg[1] .. " &")
		return os.exit()
	end
	ffi.cdef("int chdir(const char *path);")
	ffi.C.chdir(root)
	aquapackage.add("bin/linux64")
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

require("luamidi")

setmetatable(_G, {
	__newindex = function(a, b, c)
		print(a, b, c, debug.traceback())
		rawset(a, b, c)
	end
})

require("preloaders.preloadall")
require("love.window")

local aquaevent = require("aqua.event")
aquaevent:init()

local GameController = require("sphere.controllers.GameController")
local gameController = GameController:new()

aquaevent:add(gameController)
gameController:load()
