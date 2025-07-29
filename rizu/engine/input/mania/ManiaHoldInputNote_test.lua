local ManiaHoldInputNote = require("rizu.engine.input.mania.ManiaHoldInputNote")
local table_util = require("table_util")
local DiscreteKeyVirtualInputEvent = require("rizu.input.DiscreteKeyVirtualInputEvent")
local InputInfo = require("rizu.engine.input.InputInfo")
local Note = require("ncdk2.notes.Note")
local LinkedNote = require("ncdk2.notes.LinkedNote")
local AbsolutePoint = require("ncdk2.tp.AbsolutePoint")
local VisualPoint = require("ncdk2.visual.VisualPoint")

local function new_test_ctx()
	local input_info = InputInfo(0, 1)
	input_info.timing_values:setSimple(1, 2)

	local start_point = AbsolutePoint(0)
	local end_point = AbsolutePoint(10)

	local start_visual_point = VisualPoint(start_point)
	local end_visual_point = VisualPoint(end_point)

	local start_note = Note(start_visual_point, "key1", "hold", 1)
	local end_note = Note(end_visual_point, "key1", "hold", -1)

	local linked_note = LinkedNote(start_note, end_note)

	local input_note = ManiaHoldInputNote(linked_note, input_info)

	local events = {}
	input_note.observable:add({receive = function(self, event)
		table.insert(events, event)
	end})

	return {
		input_info = input_info,
		start_point = start_point,
		end_point = end_point,
		start_visual_point = start_visual_point,
		end_visual_point = end_visual_point,
		start_note = start_note,
		end_note = end_note,
		linked_note = linked_note,
		input_note = input_note,
		events = events,
		clear_events = function() table_util.clear(events) end,
	}
end

local test = {}

---@param t testing.T
function test.too_early(t)
	local ctx = new_test_ctx()

	ctx.input_info:setTime(-3)
	ctx.input_note:update()
	ctx.input_note:receive(DiscreteKeyVirtualInputEvent("key1", true))

	t:tdeq(ctx.events, {{
		delta_time = -3,
		old_state = "clear",
		new_state = "clear",
	}})
	ctx.clear_events()
end

---@param t testing.T
function test.too_late(t)
	local ctx = new_test_ctx()

	ctx.input_info:setTime(3)
	ctx.input_note:update()

	t:tdeq(ctx.events, {{
		delta_time = 2,
		old_state = "clear",
		new_state = "startMissed",
	}})
	ctx.clear_events()

	ctx.input_info:setTime(13)
	ctx.input_note:update()

	t:tdeq(ctx.events, {{
		delta_time = 2,
		old_state = "startMissed",
		new_state = "endMissed",
	}})
end

---@param t testing.T
function test.perfect_hold(t)
	local ctx = new_test_ctx()

	ctx.input_info:setTime(0)
	ctx.input_note:update()
	ctx.input_note:receive(DiscreteKeyVirtualInputEvent("key1", true))

	t:tdeq(ctx.events, {{
		delta_time = 0,
		old_state = "clear",
		new_state = "startPassedPressed",
	}})
	ctx.clear_events()

	ctx.input_info:setTime(10)
	ctx.input_note:update()
	ctx.input_note:receive(DiscreteKeyVirtualInputEvent("key1", false))

	t:tdeq(ctx.events, {{
		delta_time = 0,
		old_state = "startPassedPressed",
		new_state = "endPassed",
	}})
end

---@param t testing.T
function test.early_release(t)
	local ctx = new_test_ctx()

	ctx.input_info:setTime(0.5)
	ctx.input_note:update()
	ctx.input_note:receive(DiscreteKeyVirtualInputEvent("key1", true))

	t:tdeq(ctx.events, {{
		delta_time = 0.5,
		old_state = "clear",
		new_state = "startPassedPressed",
	}})
	ctx.clear_events()

	ctx.input_info:setTime(5)
	ctx.input_note:update()
	ctx.input_note:receive(DiscreteKeyVirtualInputEvent("key1", false))

	t:tdeq(ctx.events, {{
		delta_time = -5,
		old_state = "startPassedPressed",
		new_state = "startMissed",
	}})
	ctx.clear_events()

	ctx.input_note:receive(DiscreteKeyVirtualInputEvent("key1", true))

	t:tdeq(ctx.events, {{
		delta_time = -5,
		old_state = "startMissed",
		new_state = "startMissedPressed",
	}})
	ctx.clear_events()

	ctx.input_note:receive(DiscreteKeyVirtualInputEvent("key1", false))

	t:tdeq(ctx.events, {{
		delta_time = -5,
		old_state = "startMissedPressed",
		new_state = "startMissed",
	}})
	ctx.clear_events()
end

---@param t testing.T
function test.late_press(t)
	local ctx = new_test_ctx()

	ctx.input_info:setTime(1.5)
	ctx.input_note:update()
	ctx.input_note:receive(DiscreteKeyVirtualInputEvent("key1", true))

	t:tdeq(ctx.events, {{
		delta_time = 1.5,
		old_state = "clear",
		new_state = "startMissedPressed",
	}})
	ctx.clear_events()

	ctx.input_info:setTime(10)
	ctx.input_note:update()
	ctx.input_note:receive(DiscreteKeyVirtualInputEvent("key1", false))

	t:tdeq(ctx.events, {{
		delta_time = 0,
		old_state = "startMissedPressed",
		new_state = "endMissedPassed",
	}})
end

---@param t testing.T
function test.too_late_press(t)
	local ctx = new_test_ctx()

	ctx.input_info:setTime(5)
	ctx.input_note:update()

	t:tdeq(ctx.events, {{
		delta_time = 2,
		old_state = "clear",
		new_state = "startMissed",
	}})
	ctx.clear_events()

	ctx.input_note:receive(DiscreteKeyVirtualInputEvent("key1", true))

	t:tdeq(ctx.events, {{
		delta_time = -5,
		old_state = "startMissed",
		new_state = "startMissedPressed",
	}})
	ctx.clear_events()

	ctx.input_info:setTime(10)
	ctx.input_note:update()
	ctx.input_note:receive(DiscreteKeyVirtualInputEvent("key1", false))

	t:tdeq(ctx.events, {{
		delta_time = 0,
		old_state = "startMissedPressed",
		new_state = "endMissedPassed",
	}})
end

return test
