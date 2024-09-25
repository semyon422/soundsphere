local class = require("class")
local table_util = require("table_util")

---@class sphere.Version
---@operator call: sphere.Version
local Version = class()

---@param ver_str string
---@return sphere.Version
function Version:fromString(ver_str)
	local num_strs = ver_str:split(".")
	---@type integer[]
	local nums = {}
	for i, num_str in ipairs(num_strs) do
		nums[i] = tonumber(num_str)
	end
	return Version(nums)
end

function Version.__eq(a, b)
	return table_util.equal(a, b)
end

function Version.__lt(a, b)
	for i = 1, math.max(#a, #b) do
		if (a[i] or 0) < (b[i] or 0) then
			return true
		end
	end
end

return Version
