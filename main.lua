require("hooks")

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
aquapackage.add("lua-MessagePack/src")

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

local to_wchar_t
do
	local defined = false
	to_wchar_t = function(s)
		if not defined then
			ffi.cdef([[
				int MultiByteToWideChar(
					uint32_t CodePage,
					uint32_t dwFlags,
					const char *lpMultiByteStr,
					int32_t cbMultiByte,
					wchar_t *lpWideCharStr,
					int32_t cchWideChar
				);
			]])
			defined = true
		end

		local size = ffi.C.MultiByteToWideChar(65001, 8, s, #s, nil, 0)
		if size == 0 then
			return ffi.new("wchar_t[?]", size + 1)
		end
		assert(size > 0, "conversion error")

		local buf = ffi.new("wchar_t[?]", size + 1)
		assert(ffi.C.MultiByteToWideChar(65001, 8, s, #s, buf, size) ~= 0, "conversion error")

		return buf
	end
end

if jit.os == "Windows" then
	-- ffi.cdef("int _putenv_s(const char *varname, const char *value_string);")
	-- ffi.cdef("int _chdir(const char *dirname);")
	-- assert(ffi.C._putenv_s("PATH", os.getenv("PATH") .. ";" .. root .. "/bin/win64") == 0)
	-- assert(ffi.C._chdir(root) == 0)
	ffi.cdef("int _wputenv_s(const wchar_t *varname, const wchar_t *value_string);")
	ffi.cdef("int _wchdir(const wchar_t *dirname);")
	assert(ffi.C._wputenv_s(to_wchar_t("PATH"), to_wchar_t(os.getenv("PATH") .. ";" .. root .. "/bin/win64")) == 0)
	assert(ffi.C._wchdir(to_wchar_t(root)) == 0)
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

require("luamidi")

setmetatable(_G, {
	__newindex = function(a, b, c)
		print(a, b, c, debug.traceback())
		rawset(a, b, c)
	end
})

require("preloaders.preloadall")
require("luajit-request").init()

local aquaevent = require("aqua.event")
aquaevent:init()

local GameController = require("sphere.controllers.GameController")
local game = GameController:new()

aquaevent:add(game)
game:load()
