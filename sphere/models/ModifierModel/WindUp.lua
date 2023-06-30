local Modifier = require("sphere.models.ModifierModel.Modifier")
local map = require("math_util").map

local WindUp = Modifier:new()

WindUp.type = "TimeEngineModifier"
WindUp.interfaceType = "toggle"

WindUp.defaultValue = true
WindUp.name = "WindUp"
WindUp.shortName = "WU"

WindUp.description = "Change time rate from 0.75 to 1.5 during the play"

WindUp.getString = function(self, config)
	if not config.value then
		return
	end
	return Modifier.getString(self)
end

WindUp.applyMeta = function(self, config, state)
	if not config.value then
		return
	end
	state.windUp = {0.75, 1.5}
end

return WindUp
