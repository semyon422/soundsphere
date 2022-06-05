local Modifier = require("sphere.models.ModifierModel.Modifier")

local AutoPlay = Modifier:new()

AutoPlay.type = "LogicEngineModifier"
AutoPlay.interfaceType = "toggle"

AutoPlay.defaultValue = true
AutoPlay.name = "AutoPlay"
AutoPlay.shortName = "AP"

AutoPlay.getString = function(self, config)
	if not config.value then
		return
	end
	return Modifier.getString(self)
end

AutoPlay.apply = function(self, config)
	if not config.value then
		return
	end
	self.rhythmModel.logicEngine.autoplay = true
end

return AutoPlay
