local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.ConstSpeed: sphere.Modifier
---@operator call: sphere.ConstSpeed
local ConstSpeed = Modifier + {}

ConstSpeed.name = "ConstSpeed"
ConstSpeed.description = "Notes are moving with constant speed"

---@param config table
---@return string
---@return string
function ConstSpeed:getString(config)
	return "CON", "ST"
end

---@param config table
---@param state table
function ConstSpeed:applyMeta(config, state)
	state.constant = true
end

return ConstSpeed
