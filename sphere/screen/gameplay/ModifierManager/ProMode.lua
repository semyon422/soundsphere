local Modifier = require("sphere.screen.gameplay.ModifierManager.Modifier")

local ProMode = Modifier:new()

ProMode.inconsequential = true
ProMode.type = "LogicEngineModifier"

ProMode.name = "ProMode"
ProMode.shortName = "ProMode"

ProMode.variableType = "boolean"

ProMode.apply = function(self)
	self.sequence.manager.logicEngine.promode = true
end

ProMode.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local logicEngine = self.sequence.manager.logicEngine

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
