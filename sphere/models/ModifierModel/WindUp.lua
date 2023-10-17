local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.WindUp: sphere.Modifier
---@operator call: sphere.WindUp
local WindUp = Modifier + {}

WindUp.name = "WindUp"
WindUp.shortName = "WU"

WindUp.description = "Change time rate from 0.75 to 1.5 during the play"

---@param config table
---@param state table
function WindUp:applyMeta(config, state)
	state.windUp = {0.75, 1.5}
end

return WindUp
