local table_util = require("table_util")
local InputEngine = require("rizu.engine.input.InputEngine")
local TestLogicNote = require("rizu.engine.logic.TestLogicNote")

---@param notes rizu.LogicNote[]
---@param time number
local function set_time(notes, time)
	for _, note in ipairs(notes) do
		---@cast note rizu.TestLogicNote
		note.current_time = time
	end
end

local test = {}

---@param t testing.T
function test.no_notes(t)
	local ie = InputEngine({})

	t:has_not_error(ie.receive, ie, {id = 1, pos = 1})
end

---@param t testing.T
function test.match(t)
	local function new_note(match_event)
		local note = TestLogicNote()
		note.time = 0
		note.data = match_event.pos
		function note:input(value)
			table.insert(match_event, self)
		end
		return note
	end

	local event_1 = {value = true, id = 1, pos = 1}
	local event_2 = {value = true, id = 2, pos = 2}

	local notes = {
		new_note(event_1),
		new_note(event_2),
	}

	local ie = InputEngine(notes)
	function ie:match(note, pos)
		return note.data == pos
	end

	set_time(notes, 0)

	ie:receive(event_1)
	t:eq(event_1[1], notes[1])
	t:eq(#event_1, 1)

	ie:receive(event_2)
	t:eq(event_2[1], notes[2])
	t:eq(#event_2, 1)

	ie:receive(event_1)
	t:eq(event_1[2], notes[1])
	t:eq(#event_1, 2)
end

---@param t testing.T
function test.catch(t)
	local function new_note(id, events)
		local note = TestLogicNote()
		note.time = 0
		function note:input(value)
			table.insert(events, {id, value})
		end
		return note
	end

	local events = {}

	local notes = {
		new_note("a", events),
		new_note("b", events),
	}

	local ie = InputEngine(notes)
	function ie:match()
		return true
	end

	set_time(notes, 0)

	ie:receive({id = 1, value = true})
	ie:receive({id = 2, value = true})
	ie:receive({id = 1, value = true})
	ie:receive({id = 2, value = false})
	ie:receive({id = 1, value = false})

	t:tdeq(events, {
		{"a", true},
		{"b", true},
		{"a", true},
		{"b", false},
		{"a", false},
	})
end

---@param t testing.T
function test.nearest(t)
	local function new_note(time, events)
		local note = TestLogicNote()
		---@cast note +{catched: any}
		note.time = time
		function note:input()
			table.insert(events, time)
		end
		return note
	end

	local events = {}

	local notes = {
		new_note(0, events),
		new_note(2, events),
	}

	local ie = InputEngine(notes)
	ie.nearest = true
	function ie:match()
		return true
	end

	set_time(notes, 1)

	ie:receive({value = true, id = 1})
	ie:receive({value = false, id = 1})
	t:eq(events[1], 0)

	set_time(notes, 1.001)

	ie:receive({value = true, id = 1})
	ie:receive({value = false, id = 1})
	t:eq(events[3], 2)

	set_time(notes, 0.999)

	ie:receive({value = true, id = 1})
	ie:receive({value = false, id = 1})
	t:eq(events[5], 0)
end

---@param t testing.T
function test.priority(t)
	local function new_note(time, priority, event)
		local note = TestLogicNote()
		---@cast note +{catched: any}
		note.time = time
		note.priority = priority
		function note:input()
			table.insert(event, time)
		end
		return note
	end

	local event = {value = true, id = 1}

	local notes = {
		new_note(0, 0, event),
		new_note(2, 1, event),
	}

	local ie = InputEngine(notes)
	function ie:match()
		return true
	end

	set_time(notes, 0)

	ie:receive(event)
	t:eq(event[1], 2)
end

---@param t testing.T
function test.nil_value(t)
	local function new_note(events)
		local note = TestLogicNote()
		note.time = 0
		function note:input(value)
			table.insert(events, {value})
			return value
		end
		return note
	end

	local events = {}

	local notes = {
		new_note(events),
	}

	local ie = InputEngine(notes)
	function ie:match()
		return true
	end

	set_time(notes, 0)

	ie:receive({id = 1, value = nil})
	ie:receive({id = 1, value = true})
	ie:receive({id = 1, value = true})
	ie:receive({id = 1, value = nil})
	ie:receive({id = 1, value = false})

	t:tdeq(events, {
		{true},
		{true},
		{false},
	})

	ie:receive({id = 1, value = false})
	ie:receive({id = 1, value = nil})

	t:tdeq(events, {
		{true},
		{true},
		{false},
	})
end

---@param t testing.T
function test.variable_match(t)
	local function new_note(events)
		local note = TestLogicNote()
		note.time = 0
		function note:input(value)
			table.insert(events, {value})
		end
		return note
	end

	local events = {}

	local notes = {
		new_note(events),
	}

	local ie = InputEngine(notes)
	function ie:match(note, pos)
		return pos
	end

	set_time(notes, 0)

	ie:receive({id = 1, pos = true, value = true})
	ie:receive({id = 1, pos = true, value = nil})
	ie:receive({id = 1, pos = false, value = nil})

	t:tdeq(events, {
		{true},
		{false},
	})

	ie:receive({id = 1, pos = true, value = nil})
	ie:receive({id = 1, pos = true, value = nil})
	ie:receive({id = 1, pos = true, value = nil})
	ie:receive({id = 1, pos = false, value = nil})
	ie:receive({id = 1, pos = false, value = nil})
	ie:receive({id = 1, pos = true, value = nil})
	ie:receive({id = 1, pos = true, value = nil})
	ie:receive({id = 1, pos = true, value = false})

	t:tdeq(events, {
		{true},
		{false},
	})
end

---@param t testing.T
function test.bottom_notes(t)
	---@param id string
	---@param state {[string]: any}
	---@return rizu.TestLogicNote
	local function new_note(id, state)
		local note = TestLogicNote()
		note.is_bottom = true
		note.time = 0
		function note:input(value)
			state.count = state.count + 1
			state[id] = value
		end
		return note
	end

	local state = {count = 0}

	local notes = {
		new_note("a", state),
		new_note("b", state),
	}

	local ie = InputEngine(notes)
	function ie:match(note, pos)
		return pos
	end

	set_time(notes, 0)

	ie:update()
	t:tdeq(state, {a = false, b = false, count = 2})

	ie:receive({id = 1, pos = false, value = true})
	ie:update()
	t:tdeq(state, {a = false, b = false, count = 4})

	ie:receive({id = 1, pos = true, value = true})
	ie:update()
	t:tdeq(state, {a = true, b = true, count = 6})

	ie:receive({id = 1, pos = false, value = true})
	ie:update()
	t:tdeq(state, {a = false, b = false, count = 8})

	ie:receive({id = 1, pos = false, value = false})
	ie:update()
	t:tdeq(state, {a = false, b = false, count = 10})

	ie:receive({id = 1, pos = true, value = true})
	ie:update()
	t:tdeq(state, {a = true, b = true, count = 12})
end

---@param t testing.T
function test.pause_keep_pressed_id_changed(t)
	local function new_note(id, events)
		local note = TestLogicNote()
		note.time = 0
		function note:input(value)
			table.insert(events, {id, value})
		end
		return note
	end

	local events = {}
	local function clear_events()
		table_util.clear(events)
	end

	local notes = {
		new_note("a", events),
		new_note("b", events),
	}

	local ie = InputEngine(notes)
	function ie:match(note, pos)
		return true
	end

	set_time(notes, 0)

	ie:receive({id = 1, value = true})
	t:tdeq(events, {
		{"a", true},
	})
	clear_events()

	ie:pause()
	ie:receive({id = 1, value = false})
	t:tdeq(events, {})

	ie:receive({id = 2, value = true})
	t:tdeq(events, {})

	ie:resume()
	t:tdeq(events, {})

	ie:receive({id = 2, value = false})
	t:tdeq(events, {
		{"a", false},
	})
end

---@param t testing.T
function test.pause_press_on_resume(t)
	local function new_note(id, events)
		local note = TestLogicNote()
		note.time = 0
		function note:input(value)
			table.insert(events, {id, value})
		end
		return note
	end

	local events = {}
	local function clear_events()
		table_util.clear(events)
	end

	local notes = {
		new_note("a", events),
		new_note("b", events),
	}

	local ie = InputEngine(notes)
	function ie:match(note, pos)
		return true
	end

	set_time(notes, 0)

	ie:pause()
	ie:receive({id = 1, value = true})
	t:tdeq(events, {})

	ie:resume()
	t:tdeq(events, {
		{"a", true},
	})
	clear_events()

	ie:receive({id = 1, value = false})
	t:tdeq(events, {
		{"a", false},
	})
end

---@param t testing.T
function test.pause_release_on_resume(t)
	local function new_note(id, events)
		local note = TestLogicNote()
		note.time = 0
		function note:input(value)
			table.insert(events, {id, value})
		end
		return note
	end

	local events = {}
	local function clear_events()
		table_util.clear(events)
	end

	local notes = {
		new_note("a", events),
		new_note("b", events),
	}

	local ie = InputEngine(notes)
	function ie:match(note, pos)
		return true
	end

	set_time(notes, 0)

	ie:receive({id = 1, value = true})
	t:tdeq(events, {
		{"a", true},
	})
	clear_events()

	ie:pause()
	ie:receive({id = 1, value = false})
	t:tdeq(events, {})

	ie:resume()
	t:tdeq(events, {
		{"a", false},
	})
end

---@param t testing.T
function test.pause_bottom_notes_keep_pressed_id_changed(t)
	---@param id string
	---@param state {[string]: any}
	---@return rizu.TestLogicNote
	local function new_note(id, state)
		local note = TestLogicNote()
		note.is_bottom = true
		note.time = 0
		function note:input(value)
			state.count = state.count + 1
			state[id] = value
		end
		return note
	end

	local state = {count = 0}

	local notes = {
		new_note("a", state),
		new_note("b", state),
	}

	local ie = InputEngine(notes)
	function ie:match(note, pos)
		return pos
	end

	ie:receive({id = 1, pos = true, value = true})
	ie:update()
	t:tdeq(state, {a = true, b = true, count = 2})

	ie:pause()
	ie:receive({id = 1, pos = true, value = false})
	ie:update()
	t:tdeq(state, {a = true, b = true, count = 2})

	ie:receive({id = 1, pos = true, value = true})
	ie:resume()
	ie:update()
	t:tdeq(state, {a = true, b = true, count = 4})
end

--[[
	TODO:
	pause (unmatch / rematch) x (top / bottom)
]]

return test
