local ffi = require("ffi")
local jit = require("jit")

local load = ffi.load

local _load = function(name)
	if jit.os == "Windows" then
		return load("bin/win64/cimgui.dll")
	elseif jit.os == "Linux" then
		return load("cimgui")
	end
end

local cimgui_preloader = {}

cimgui_preloader.name = "cimgui"

cimgui_preloader.preload = function()
	ffi.load = _load
	local cimgui = require("cimgui-love.src.init")
	ffi.load = load
	return cimgui
end

return cimgui_preloader
