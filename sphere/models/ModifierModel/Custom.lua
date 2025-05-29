local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.Custom: sphere.Modifier
---@operator call: sphere.Custom
local Custom = Modifier + {}

Custom.name = "Custom"
Custom.shortName = "Custom"

Custom.description = "Just adds custom flag"

---@param config table
---@return string
---@return string?
function Custom:getString(config)
	return "CUS", "TOM"
end

---@param config table
---@param state sea.ModifiersMetaState
function Custom:applyMeta(config, state)
	state.custom = true
end

return Custom
