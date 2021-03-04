local ffi = require("ffi")
local jit = require("jit")

local load = ffi.load

local get_libiconv_name = function()
	local os = jit.os
	local arch = jit.arch

	if os == "Windows" then
		if arch == "x64" then
			return "bin/win64/libiconv-2.dll"
		elseif arch == "x86" then
			return "bin/win32/libiconv-2.dll"
		end
	elseif os == "Linux" then
		return "libiconv"
	end
end

local _load = function(name)
	if name == "libiconv" then
		return load(get_libiconv_name())
	end
end

local iconv_preloader = {}

iconv_preloader.name = "iconv"

iconv_preloader.preload = function()
	ffi.load = _load
	local iconv = require("luajit-iconv.init")
	ffi.load = load
	return iconv
end

return iconv_preloader
