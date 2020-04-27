local InconsequentialModifier = require("sphere.screen.gameplay.ModifierManager.InconsequentialModifier")

local AutoPlay = InconsequentialModifier:new()

AutoPlay.name = "AutoPlay"
AutoPlay.shortName = "AP"

AutoPlay.type = "boolean"

AutoPlay.apply = function(self) end

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
