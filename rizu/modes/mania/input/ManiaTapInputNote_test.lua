local ManiaTapInputNote = require("rizu.modes.mania.input.ManiaTapInputNote")
local TimeInfo = require("rizu.modes.common.TimeInfo")
local TimingValues = require("sea.chart.TimingValues")
local Note = require("ncdk2.notes.Note")
local LinkedNote = require("ncdk2.notes.LinkedNote")
local AbsolutePoint = require("ncdk2.tp.AbsolutePoint")
local VisualPoint = require("ncdk2.visual.VisualPoint")

local function new_test_ctx()
	local time_info = TimeInfo(0, 1)
	local timing_values = TimingValues():setSimple(1, 2)

	local point = AbsolutePoint(0)
	local visual_point = VisualPoint(point)
	local note = Note(visual_point, "key1", "tap", 0)
	local linked_note = LinkedNote(note)

	local input_note = ManiaTapInputNote(linked_note, timing_values, time_info)

	local events = {}
	input_note.observable:add({receive = function(self, event)
		table.insert(events, event)
	end})

	return {
		time_info = time_info,
		timing_values = timing_values,
		point = point,
		visual_point = visual_point,
		note = note,
		linked_note = linked_note,
		input_note = input_note,
		events = events,
	}
end

local test = {}

---@param t testing.T
function test.too_late(t)
	local ctx = new_test_ctx()

	ctx.time_info.time = 10
	t:eq(ctx.input_note:getResult(), "too late")
	ctx.input_note:update()

	t:tdeq(ctx.events, {{deltaTime = 2}})
end

return test
