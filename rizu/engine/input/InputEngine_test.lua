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

	t:has_not_error(ie.receive, ie, {})
end

---@param t testing.T
function test.match(t)
	local function new_note(match_event)
		local note = TestLogicNote()
		note.time = 0
		note.data = match_event
		function note:input(value)
			table.insert(match_event, self)
		end
		return note
	end

	local event_1 = {}
	local event_2 = {}

	local notes = {
		new_note(event_1),
		new_note(event_2),
	}

	local ie = InputEngine(notes)
	function ie:match(note, event)
		return note.data == event
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
			return value
		end
		return note
	end

	local events = {}

	local notes = {
		new_note(1, events),
		new_note(2, events),
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
		{1, true},
		{2, true},
		{1, true},
		{2, false},
		{1, false},
	})
end

---@param t testing.T
function test.nearest(t)
	local function new_note(time, event)
		local note = TestLogicNote()
		---@cast note +{catched: any}
		note.time = time
		function note:input()
			table.insert(event, time)
		end
		return note
	end

	local event = {}

	local notes = {
		new_note(0, event),
		new_note(2, event),
	}

	local ie = InputEngine(notes)
	ie.nearest = true
	function ie:match()
		return true
	end

	set_time(notes, 1)

	ie:receive(event)
	t:eq(event[1], 0)

	set_time(notes, 1.001)

	ie:receive(event)
	t:eq(event[2], 2)

	set_time(notes, 0.999)

	ie:receive(event)
	t:eq(event[3], 0)
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

	local event = {}

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
function test.variable_match(t)
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
	function ie:match(note, event)
		return event.matching
	end

	set_time(notes, 0)

	ie:receive({id = 1, matching = true, value = true})
	ie:receive({id = 1, matching = false, value = nil})
	ie:receive({id = 1, matching = true, value = nil})
	ie:receive({id = 1, matching = true, value = false})

	-- t:tdeq(events, {
	-- 	{true},
	-- 	{nil},
	-- 	{true},
	-- 	{false},
	-- })
end

-- TODO:
-- complete variable_match test
-- add test for cleaning catch table for inactive notes
-- add test for nil event pos and values (no changes)

return test
