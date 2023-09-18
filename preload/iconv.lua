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

---@param mod string
---@return table
local function preload(mod)
	ffi.load = _load
	local iconv = require("aqua.iconv")
	ffi.load = ffi_load
	return iconv
end

return preload
