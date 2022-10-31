local Class = require("Class")
local gfx_util = require("gfx_util")

local SnapGridView = Class:new()

SnapGridView.draw = function(self)
	local graphicEngine = self.game.rhythmModel.graphicEngine
	local noteSkin = graphicEngine.noteSkin

	love.graphics.replaceTransform(gfx_util.transform(self.transform))
	love.graphics.setColor(1, 1, 1, 1)

	for _, noteDrawer in ipairs(graphicEngine.noteDrawers) do
		for i = noteDrawer.startNoteIndex, noteDrawer.endNoteIndex do
			local note = noteDrawer.notes[i]
			local y = noteSkin:getTimePosition(note.startTimeState.scaledVisualDeltaTime)
			local x = noteSkin.baseOffset
			local w = noteSkin.fullWidth
			love.graphics.line(x, y, x + w, y)
		end
	end
end

return SnapGridView
