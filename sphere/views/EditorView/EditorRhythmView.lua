local RhythmView = require("sphere.views.RhythmView")
local just = require("just")
local gfx_util = require("gfx_util")

local EditorRhythmView = RhythmView:new()

EditorRhythmView.processNote = function(self, note)
	local editorModel = self.game.editorModel
	local noteManager = editorModel.noteManager
	local graphicEngine = editorModel.graphicEngine

	local mouseTime = editorModel:getMouseTime()
	if note.noteType == "ShortNote" then
		local over = just.mouse_over(note, note.over, "mouse")
		if over then
			if just.mousepressed(1) then
				graphicEngine:selectNote(note)
				noteManager:grabNotes("body", mouseTime)
			elseif just.mousepressed(2) then
				noteManager:removeNote(note)
			end
		end
	elseif note.noteType == "LongNote" then
		local bodyOver = just.mouse_over(tostring(note) .. "body", note.bodyOver, "mouse")
		local headOver = just.mouse_over(tostring(note) .. "head", note.headOver, "mouse")
		local tailOver = just.mouse_over(tostring(note) .. "tail", note.tailOver, "mouse")
		if just.mousepressed(1) then
			if bodyOver then
				graphicEngine:selectNote(note)
				noteManager:grabNotes("body", mouseTime)
			elseif headOver then
				graphicEngine:selectNote(note)
				noteManager:grabNotes("head", mouseTime)
			elseif tailOver then
				graphicEngine:selectNote(note)
				noteManager:grabNotes("tail", mouseTime)
			end
		end
		if (bodyOver or headOver or tailOver) and just.mousepressed(2) then
			noteManager:removeNote(note)
		end
	end
end

EditorRhythmView.draw = function(self)
	local editorModel = self.game.editorModel
	local noteManager = editorModel.noteManager
	local ld = editorModel.layerData
	local noteSkin = self.game.noteSkinModel.noteSkin
	local editor = self.game.configModel.configs.settings.editor

	if not ld.ranges.timePoint.head then
		return
	end

	love.graphics.replaceTransform(gfx_util.transform(self.transform))

	local t = editorModel:getMouseTime()

	if editorModel.state == "notes" then
		if editor.tool == "ShortNote" or editor.tool == "LongNote" then
			for i = 1, noteSkin.inputsCount do
				local Head = noteSkin.notes.ShortNote.Head
				local over = just.is_over(Head.w[i], noteSkin.unit, Head.x[i], 0)
				over = just.mouse_over("add note" .. i, over, "mouse")
				if over and just.mousepressed(1) then
					noteManager:addNote(t, "key", i)
				end
			end
		elseif editor.tool == "Select" then
			local over = just.mouse_over("editor select", true, "mouse")
			if over and just.mousepressed(1) then
				editorModel:selectStart()
			end
		end
		if editorModel.selectRect then
			local x, y, x1, y1 = unpack(editorModel.selectRect)
			love.graphics.push("all")
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.rectangle("line", x, y, x1 - x, y1 - y)
			love.graphics.setColor(1, 1, 1, 0.2)
			love.graphics.rectangle("fill", x, y, x1 - x, y1 - y)
			love.graphics.pop()
		end
	end

	RhythmView.draw(self)

	if editorModel.state ~= "notes" then
		return
	end

	for _, note in ipairs(editorModel.graphicEngine.notes) do
		self:processNote(note)
	end
	if just.mousereleased(1) then
		if next(editorModel.noteManager.grabbedNotes) then
			noteManager:dropNotes(t)
		end
		if editorModel.selectRect then
			editorModel:selectEnd()
		end
	end
end

EditorRhythmView.processNotes = function(self, f)
	local editorModel = self.game.editorModel
	for _, graphicalNote in ipairs(editorModel.graphicEngine.notes) do
		f(self, graphicalNote)
	end
end

return EditorRhythmView
