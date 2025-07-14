local table_util = require("table_util")
local ManiaTapInputNote = require("rizu.modes.mania.input.ManiaTapInputNote")
local DiscreteKeyVirtualInputEvent = require("rizu.input.DiscreteKeyVirtualInputEvent")
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
		clear_events = function() table_util.clear(events) end,
	}
end

local test = {}

---@param t testing.T
function test.too_late(t)
	local ctx = new_test_ctx()

	ctx.time_info.time = 2.5
	t:eq(ctx.input_note:getResult(), "too late")
	ctx.input_note:update()

	t:tdeq(ctx.events, {{
		delta_time = 2,
		old_state = "clear",
		new_state = "missed",
	}})
	ctx.clear_events()

	ctx.input_note:reset()
	ctx.time_info.rate = 1.5
	ctx.input_note:update()

	t:tdeq(ctx.events, {})

	ctx.time_info.time = 3.5
	ctx.input_note:update()

	t:tdeq(ctx.events, {{
		delta_time = 2,
		old_state = "clear",
		new_state = "missed",
	}})
end

---@param t testing.T
function test.hit_late_and_exactly_with_rate(t)
	local ctx = new_test_ctx()

	ctx.time_info.time = 1.1
	t:eq(ctx.input_note:getResult(), "late")
	ctx.input_note:update()

	t:tdeq(ctx.events, {})

	ctx.input_note:receive(DiscreteKeyVirtualInputEvent("key1", true))

	t:tdeq(ctx.events, {{
		delta_time = 1.1,
		old_state = "clear",
		new_state = "missed",
	}})
	ctx.clear_events()

	ctx.input_note:reset()
	ctx.time_info.rate = 1.5
	t:eq(ctx.input_note:getResult(), "exactly")

	ctx.input_note:receive(DiscreteKeyVirtualInputEvent("key1", true))

	t:tdeq(ctx.events, {{
		delta_time = 1.1 / 1.5, -- 0.733
		old_state = "clear",
		new_state = "passed",
	}})
end

---@param t testing.T
function test.hit_bounds(t)
	local ctx = new_test_ctx()

	ctx.time_info.time = -2
	t:eq(ctx.input_note:getResult(), "early")

	ctx.time_info.time = -1
	t:eq(ctx.input_note:getResult(), "exactly")

	ctx.time_info.time = 1
	t:eq(ctx.input_note:getResult(), "exactly")

	ctx.time_info.time = 2
	t:eq(ctx.input_note:getResult(), "late")
end

---@param t testing.T
function test.hit_too_early(t)
	local ctx = new_test_ctx()

	ctx.time_info.time = -3
	t:eq(ctx.input_note:getResult(), "too early")
	ctx.input_note:update()

	t:tdeq(ctx.events, {})

	ctx.input_note:receive(DiscreteKeyVirtualInputEvent("key1", true))

	t:tdeq(ctx.events, {{
		delta_time = -3,
		old_state = "clear",
		new_state = "clear",
	}})
end

return test
