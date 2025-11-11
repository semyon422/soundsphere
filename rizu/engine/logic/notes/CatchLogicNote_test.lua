local CatchLogicNote = require("rizu.engine.logic.notes.CatchLogicNote")
local table_util = require("table_util")
local LogicInfo = require("rizu.engine.logic.LogicInfo")
local Note = require("ncdk2.notes.Note")
local LinkedNote = require("ncdk2.notes.LinkedNote")
local AbsolutePoint = require("ncdk2.tp.AbsolutePoint")
local VisualPoint = require("ncdk2.visual.VisualPoint")

local function new_test_ctx()
	local logic_info = LogicInfo()
	logic_info.timing_values:setSimple(1, 2)

	local point = AbsolutePoint(0)
	local visual_point = VisualPoint(point)
	local note = Note(visual_point, "key1", "catch", 0)
	local linked_note = LinkedNote(note)

	local logic_note = CatchLogicNote(linked_note, logic_info)

	local events = {}
	logic_note.observable:add({receive = function(self, event)
		table.insert(events, event)
	end})

	return {
		logic_info = logic_info,
		point = point,
		visual_point = visual_point,
		note = note,
		linked_note = linked_note,
		logic_note = logic_note,
		events = events,
		clear_events = function() table_util.clear(events) end,
	}
end

local test = {}

---@param t testing.T
function test.passed_exact(t)
	local ctx = new_test_ctx()

	ctx.logic_note:input(true)

	ctx.logic_info.time = -1
	ctx.logic_note:update()

	t:tdeq(ctx.events, {})
	ctx.clear_events()

	ctx.logic_info.time = 1
	ctx.logic_note:update()

	t:tdeq(ctx.events, {{
		delta_time = 0,
		old_state = "clear",
		new_state = "passed",
	}})
end

return test
