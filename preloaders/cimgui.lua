local ffi = require("ffi")

local load = ffi.load

local _load = function(name)
	return load("cimgui")
end

local cimgui_preloader = {}

cimgui_preloader.name = "cimgui"

cimgui_preloader.preload = function()
	ffi.load = _load
	local cimgui = require("cimgui.init")
	ffi.load = load
	return cimgui
end

return cimgui_preloader
