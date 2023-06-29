local Modifier = require("sphere.models.ModifierModel.Modifier")

local ProMode = Modifier:new()

ProMode.type = "LogicEngineModifier"
ProMode.interfaceType = "toggle"

ProMode.defaultValue = true
ProMode.name = "ProMode"
ProMode.shortName = "PRO"

ProMode.description = "Press any keys to play like an AutoPlay"

ProMode.getString = function(self, config)
	if not config.value then
		return
	end
	return Modifier.getString(self)
end

ProMode.apply = function(self, config)
	if not config.value then
		return
	end
	self.rhythmModel.logicEngine.promode = true
end

return ProMode
