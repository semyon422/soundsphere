local stbl = require("stbl")
local valid = require("valid")
local types = require("sea.shared.types")

local IntegerArray = {}

local int_arr = valid.array(types.integer, math.huge)

---@param t integer[]
---@return string
function IntegerArray.encode(t)
	assert(valid.format(int_arr(t)))
	return stbl.encode(t)
end

---@param s string
---@return integer[]
function IntegerArray.decode(s)
	return stbl.decode(s)
end

return IntegerArray
