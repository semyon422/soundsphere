local ffi = require("ffi")
local jit = require("jit")

local load = ffi.load

local _load = function(name)
	if jit.os == "Windows" then
		return load("libiconv-2")
	elseif jit.os == "Linux" then
		return load("iconv")
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
