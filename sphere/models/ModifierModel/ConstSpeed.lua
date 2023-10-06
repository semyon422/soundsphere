local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.ConstSpeed: sphere.Modifier
---@operator call: sphere.ConstSpeed
local ConstSpeed = Modifier + {}

ConstSpeed.name = "ConstSpeed"
ConstSpeed.defaultValue = true
ConstSpeed.values = {false, true}

ConstSpeed.description = "Notes are moving with constant speed"

---@param config table
---@return string?
---@return string?
function ConstSpeed:getString(config)
	if not config.value then
		return
	end
	return "CON", "ST"
end

---@param config table
---@param state table
function ConstSpeed:applyMeta(config, state)
	local mode = config.value
	if not mode then
		return
	end
	state.constant = true
end

return ConstSpeed
