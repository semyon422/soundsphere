local Modifier = require("sphere.models.ModifierModel.Modifier")
local map = require("math_util").map

local WindUp = Modifier + {}

WindUp.type = "TimeEngineModifier"
WindUp.interfaceType = "toggle"

WindUp.defaultValue = true
WindUp.name = "WindUp"
WindUp.shortName = "WU"

WindUp.description = "Change time rate from 0.75 to 1.5 during the play"

function WindUp:getString(config)
	if not config.value then
		return
	end
	return Modifier.getString(self)
end

function WindUp:applyMeta(config, state)
	if not config.value then
		return
	end
	state.windUp = {0.75, 1.5}
end

return WindUp
