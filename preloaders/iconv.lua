local ffi = require("ffi")
local jit = require("jit")

local ffi_load = ffi.load

---@param name string
---@return ffi.namespace*
local function _load(name)
	if jit.os == "Windows" then
		return ffi_load("libiconv-2")
	end
	return ffi_load("iconv")
end

local iconv_preloader = {}

iconv_preloader.name = "iconv"

---@param mod string
---@return table
function iconv_preloader.preload(mod)
	ffi.load = _load
	local iconv = require("aqua.iconv")
	ffi.load = ffi_load
	return iconv
end

return iconv_preloader
