local class = require("class")
local table_util = require("table_util")
local VisualNoteFactory = require("rizu.engine.visual.VisualNoteFactory")
local Point = require("ncdk2.tp.Point")
local VisualPoint = require("ncdk2.visual.VisualPoint")

---@class rizu.VisualEngine
---@operator call: rizu.VisualEngine
local VisualEngine = class()

VisualEngine.range = 1

---@param action -1|1
---@return true?
local function true_from_action(action)
	if action == 1 then
		return true
	end
end

---@param visual_info rizu.VisualInfo
function VisualEngine:new(visual_info)
	self.visual_info = visual_info
	self.visual_note_factory = VisualNoteFactory(visual_info)
end

---@param vp any
---@param event table
function VisualEngine:insertNoteEvent(vp, event)
	self.point_notes[vp] = self.point_notes[vp] or {}
	table.insert(self.point_notes[vp], event)
end

---@param linked_note ncdk2.LinkedNote
---@param visual_note rizu.VisualNote
function VisualEngine:addNote(linked_note, visual_note)
	local event = {
		linked_note = linked_note,
		visual_note = visual_note,
	}

	self:insertNoteEvent(linked_note.startNote.visualPoint, event)
	if linked_note:isLong() then
		self:insertNoteEvent(linked_note.endNote.visualPoint, event)
	end
end

---@param chart ncdk2.Chart
---@param lazy_scrollers boolean?
function VisualEngine:load(chart, lazy_scrollers)
	---@type {[ncdk2.Visual]: ncdk2.VisualPoint}
	self.cvp = {}

	---@type {[rizu.VisualNote]: true}
	self.visible_notes_map = {}
	---@type rizu.VisualNote[]
	self.visible_notes = {}

	---@type {[ncdk2.VisualPoint]: -1|1}
	self.point_events = {}
	---@type {[ncdk2.VisualPoint]: {linked_note: ncdk2.LinkedNote, visual_note: rizu.VisualNote}[]}
	self.point_notes = {}

	---@type {[ncdk2.Column]: rizu.VisualNote[]}
	self.bga_notes = {}
	---@type {[ncdk2.Column]: integer}
	self.last_bga_index = {}

	for _, visual in ipairs(chart:getVisuals()) do
		self.cvp[visual] = VisualPoint(Point())
		visual:generateEvents(lazy_scrollers)
	end

	local point_events = self.point_events
	function self.handle_event(vp, action)
		point_events[vp] = action
	end

	for _, linked_note in ipairs(chart.notes:getLinkedNotes()) do
		local visual_note = self.visual_note_factory:getNote(linked_note)
		if visual_note then
			local visual = chart:getVisualByPoint(linked_note.startNote.visualPoint --[[@as ncdk2.VisualPoint]])
			---@cast visual -?

			visual_note.cvp = self.cvp[visual]
			visual_note.visual = visual

			self:addNote(linked_note, visual_note)

			if visual.bga then
				visual_note.is_bga = true
				local column = linked_note:getColumn()

				self.bga_notes[column] = self.bga_notes[column] or {}
				table.insert(self.bga_notes[column], visual_note)
			end
		end
	end

	for _, notes in pairs(self.bga_notes) do
		table.sort(notes)
	end
end

function VisualEngine:update()
	local range = self.range
	local visual_info = self.visual_info

	local visible_notes_map = self.visible_notes_map

	local point_events = self.point_events
	local handle_event = self.handle_event
	table_util.clear(point_events)

	for visual, cvp in pairs(self.cvp) do
		cvp.point.absoluteTime = visual_info:getTime()
		visual.interpolator:interpolate(visual.points, cvp, "absolute")

		if not visual.bga then
			-- TODO: implement const for scroller
			visual.scroller:scroll(cvp.point.absoluteTime, handle_event)
			visual.scroller:scale(range / (visual_info.rate * cvp.globalSpeed), handle_event)
		end
	end

	for column in pairs(self.bga_notes) do
		self:updateBga(column, visual_info:getTime())
	end

	-- TODO: fix a bug with LN disappearing
	-- when you increase play speed and LN tail get hide event
	for vp, action in pairs(point_events) do
		local notes = self.point_notes[vp]
		if notes then
			for _, t in ipairs(notes) do
				if
					t.linked_note:isShort() or
					vp == t.linked_note.startNote.visualPoint and action == 1 or
					vp == t.linked_note.endNote.visualPoint and action == -1
				then
					visible_notes_map[t.visual_note] = true_from_action(action)
				end
			end
		end
	end

	local visible_notes = self.visible_notes
	table_util.clear(visible_notes)

	for note in pairs(visible_notes_map) do
		note:update()
		table.insert(visible_notes, note)
	end

	table.sort(visible_notes)
end

---@param column ncdk2.Column
---@param time number
function VisualEngine:updateBga(column, time)
	-- if column ~= "bmsbga4" then return end
	local notes = self.bga_notes[column]
	local index = 1
	for i, note in ipairs(notes) do
		if note.linked_note:getStartTime() <= time then
			index = i
		else
			break
		end
	end

	local last_index = self.last_bga_index[column]
	if last_index ~= index then
		if last_index then
			local old_note = notes[last_index]
			pprint({"hide", self.visual_info.time, old_note.linked_note.startNote})
			self.handle_event(old_note.linked_note.startNote.visualPoint, -1)
		end
		local new_note = notes[index]
		pprint({"show", self.visual_info.time, new_note.linked_note.startNote})
		self.handle_event(new_note.linked_note.startNote.visualPoint, 1)
		self.last_bga_index[column] = index
	end
end

return VisualEngine
