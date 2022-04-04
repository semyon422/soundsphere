local Modifier = require("sphere.models.ModifierModel.Modifier")

local ProMode = Modifier:new()

ProMode.type = "LogicEngineModifier"
ProMode.interfaceType = "toggle"

ProMode.defaultValue = true
ProMode.name = "ProMode"
ProMode.shortName = "PRO"

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

ProMode.receive = function(self, config, event)
	if config.value == 0 then
		return
	end

	if event.name ~= "keypressed" then
		return
	end

	local logicEngine = self.rhythmModel.logicEngine

	local nearestNote
	for _, noteHandler in pairs(logicEngine.noteHandlers) do
		local currentNote = noteHandler.currentNote
		if
			currentNote and
			(
				not nearestNote or
				currentNote.startNoteData.timePoint.absoluteTime < nearestNote.startNoteData.timePoint.absoluteTime
			) and
			not currentNote.ended and
			currentNote:isReachable(currentNote) and
			not currentNote.autoplay and
			(
				currentNote.startNoteData.noteType == "ShortNote" or
				currentNote.startNoteData.noteType == "LongNoteStart"
			)
		then
			nearestNote = currentNote
		end
	end
	if nearestNote then
		nearestNote:switchAutoplay(true)
	end
end

return ProMode
