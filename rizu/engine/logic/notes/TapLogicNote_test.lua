local table_util = require("table_util")
local TapLogicNote = require("rizu.engine.logic.notes.TapLogicNote")
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
	local note = Note(visual_point, "key1", "tap", 0)
	local linked_note = LinkedNote(note)

	local logic_note = TapLogicNote(linked_note, logic_info)

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
function test.too_late(t)
	local ctx = new_test_ctx()

	ctx.logic_info.time = 2.5
	t:eq(ctx.logic_note:getResult(), "too late")
	ctx.logic_note:update()

	t:tdeq(ctx.events, {{
		delta_time = 2,
		old_state = "clear",
		new_state = "missed",
	}})
	ctx.clear_events()

	ctx.logic_note:reset()
	ctx.logic_info.rate = 1.5
	ctx.logic_note:update()

	t:tdeq(ctx.events, {})

	ctx.logic_info.time = 3.5
	ctx.logic_note:update()

	t:tdeq(ctx.events, {{
		delta_time = 2,
		old_state = "clear",
		new_state = "missed",
	}})
end

---@param t testing.T
function test.hit_late_and_exactly_with_rate(t)
	local ctx = new_test_ctx()

	ctx.logic_info.time = 1.1
	t:eq(ctx.logic_note:getResult(), "late")
	ctx.logic_note:update()

	t:tdeq(ctx.events, {})

	ctx.logic_note:input(true)

	t:tdeq(ctx.events, {{
		delta_time = 1.1,
		old_state = "clear",
		new_state = "missed",
	}})
	ctx.clear_events()

	ctx.logic_note:reset()
	ctx.logic_info.rate = 1.5
	t:eq(ctx.logic_note:getResult(), "exactly")

	ctx.logic_note:input(true)

	t:tdeq(ctx.events, {{
		delta_time = 1.1 / 1.5, -- 0.733
		old_state = "clear",
		new_state = "passed",
	}})
end

---@param t testing.T
function test.hit_bounds(t)
	local ctx = new_test_ctx()

	ctx.logic_info.time = -2
	t:eq(ctx.logic_note:getResult(), "early")

	ctx.logic_info.time = -1
	t:eq(ctx.logic_note:getResult(), "exactly")

	ctx.logic_info.time = 1
	t:eq(ctx.logic_note:getResult(), "exactly")

	ctx.logic_info.time = 2
	t:eq(ctx.logic_note:getResult(), "late")
end

---@param t testing.T
function test.hit_too_early(t)
	local ctx = new_test_ctx()

	ctx.logic_info.time = -3
	t:eq(ctx.logic_note:getResult(), "too early")
	ctx.logic_note:update()

	t:tdeq(ctx.events, {})

	ctx.logic_note:input(true)

	t:tdeq(ctx.events, {{
		delta_time = -3,
		old_state = "clear",
		new_state = "clear",
	}})
end

return test
