local Modifier = require("sphere.screen.gameplay.ModifierManager.Modifier")

local AutoPlay = Modifier:new()

AutoPlay.inconsequential = true
AutoPlay.type = "LogicEngineModifier"

AutoPlay.name = "AutoPlay"
AutoPlay.shortName = "AP"

AutoPlay.variableType = "boolean"

AutoPlay.apply = function(self)
	self.sequence.manager.logicEngine.autoplay = true
end

AutoPlay.receive = function(self, event)
	if event.name ~= "LogicalNoteState" then
		return
	end

	if event.key == "load" then
		event.note.autoplay = true
	elseif event.key == "unload" then
		event.note.autoplay = false
	end
end

return AutoPlay
