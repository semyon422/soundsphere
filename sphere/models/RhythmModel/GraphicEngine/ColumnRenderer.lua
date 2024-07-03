local class = require("class")
local table_util = require("table_util")
local GraphicalNoteFactory = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNoteFactory")

---@class sphere.ColumnRenderer
---@operator call: sphere.ColumnRenderer
local ColumnRenderer = class()

---@param layer ncdk2.Layer
---@param notes notechart.Note[]
---@param column ncdk2.Column
---@param layerRenderer sphere.LayerRenderer
function ColumnRenderer:new(layer, notes, column, layerRenderer)
	self.layer = layer
	self._notes = notes
	self.column = column
	self.layerRenderer = layerRenderer
end

local function sort_const(a, b)
	return a.startNote.visualPoint.point:compare(b.startNote.visualPoint.point)
end

local function sort_visual(a, b)
	return a.startNote.visualPoint:compare(b.startNote.visualPoint)
end

function ColumnRenderer:load()
	local layerRenderer = self.layerRenderer
	local graphicEngine = layerRenderer.graphicEngine
	local layer = self.layer

	self.notes = {}
	local notes = self.notes

	self.noteByTimePoint = {}

	for _, _note in ipairs(self._notes) do
		local note = GraphicalNoteFactory:getNote(_note)
		if note then
			note.currentVisualPoint = layerRenderer.currentVisualPoint
			note.graphicEngine = graphicEngine
			note.layer = layer
			note.column = self.column
			table.insert(notes, note)

			if graphicEngine.eventBasedRender then
				local endNote = note.startNote.endNote
				if not endNote then
					self.noteByTimePoint[note.startNote.visualPoint] = {
						note = note,
						show = true,
						hide = true,
					}
				else
					self.noteByTimePoint[note.startNote.visualPoint] = {
						note = note,
						show = true,
					}
					self.noteByTimePoint[endNote.visualPoint] = {
						note = note,
						hide = true,
					}
				end
			end
		end
	end

	if graphicEngine.constant then
		table.sort(notes, sort_const)
	else
		table.sort(notes, sort_visual)
	end

	for i, note in ipairs(notes) do
		note.nextNote = notes[i + 1]
	end

	self.startNoteIndex = 1
	self.endNoteIndex = 0

	self.visibleNotes = {}
	self.visibleNotesList = {}
end

function ColumnRenderer:update()
	if self.layerRenderer.graphicEngine.eventBasedRender then
		return self:updateEventBased()
	end
	return self:updateSorted()
end

function ColumnRenderer:updateEventBased()
	for _, event in ipairs(self.pointEvents) do
		local vp, action = unpack(event)
		local noteInfo = self.noteByTimePoint[vp]
		if noteInfo then
			if action == 1 and noteInfo.show then
				self.visibleNotes[noteInfo.note] = true
			elseif action == -1 and noteInfo.hide then
				self.visibleNotes[noteInfo.note] = nil
			end
		end
	end

	local visibleNotesList = self.visibleNotesList
	table_util.clear(visibleNotesList)

	for note in pairs(self.visibleNotes) do
		note:update()
		table.insert(visibleNotesList, note)
	end

	table.sort(visibleNotesList, sort_const)
end

function ColumnRenderer:updateSorted()
	local notes = self.notes
	local note

	for i = self.startNoteIndex, self.endNoteIndex do
		notes[i]:update()
	end

	for i = self.startNoteIndex, 2, -1 do
		note = notes[i - 1]
		note:update()
		if note:willDrawBeforeStart() or i ~= self.startNoteIndex then
			break
		end
		self.startNoteIndex = self.startNoteIndex - 1
	end

	for i = self.endNoteIndex, #notes - 1, 1 do
		note = notes[i + 1]
		note:update()
		if note:willDrawAfterEnd() or i ~= self.endNoteIndex then
			break
		end
		self.endNoteIndex = self.endNoteIndex + 1
	end

	for i = self.startNoteIndex, self.endNoteIndex do
		note = notes[i]
		if not note:willDrawBeforeStart() then
			break
		end
		self.startNoteIndex = self.startNoteIndex + 1
	end

	for i = self.endNoteIndex, self.startNoteIndex, -1 do
		note = notes[i]
		if not note:willDrawAfterEnd() then
			break
		end
		self.endNoteIndex = self.endNoteIndex - 1
	end
end

return ColumnRenderer