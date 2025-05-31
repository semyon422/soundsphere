local valid = require("valid")
local types = require("sea.shared.types")
local ChartmetaKey = require("sea.chart.ChartmetaKey")

---@class sea.ChartmetaUserData: sea.ChartmetaKey
---@operator call: sea.ChartmetaUserData
---@field user_id integer
---@field local_offset number?
---@field rating number? [0, 1]
---@field comment string?
local ChartmetaUserData = ChartmetaKey + {}

ChartmetaUserData.struct = {
	local_offset = types.number,
	rating = types.number,
	comment = types.description,
}

local validate_chartmeta_user_data = valid.struct(ChartmetaUserData.struct)

---@return boolean?
---@return string[]?
function ChartmetaUserData:validate()
	return valid.flatten(validate_chartmeta_user_data(self))
end

return ChartmetaUserData
