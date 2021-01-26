local Modifier = require("sphere.models.ModifierModel.Modifier")

local ProMode = Modifier:new()

ProMode.type = "LogicEngineModifier"

ProMode.name = "ProMode"
ProMode.shortName = "ProMode"

ProMode.apply = function(self)
	local config = self.config
	if not config.value then
		return
	end
	self.rhythmModel.logicEngine.promode = true
end

ProMode.receive = function(self, event)
	local config = self.config
	if not config.value then
		return
	end

	if event.name ~= "keypressed" then
		return
	end

	local logicEngine = self.rhythmModel.logicEngine

	local nearestNote
	for noteHandler in pairs(logicEngine.noteHandlers) do
		local currentNote = noteHandler.currentNote
		if
			currentNote and
			(
				not nearestNote or
				currentNote.startNoteData.timePoint.absoluteTime < nearestNote.startNoteData.timePoint.absoluteTime
			) and
			not currentNote.ended and
			currentNote:isReachable() and
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
		print(nearestNote.keyBind)
	else
		print("no note")
	end
end

return ProMode
