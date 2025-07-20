local InputNotesHandler = require("rizu.modes.common.input.InputNotesHandler")
local TestInputNote = require("rizu.modes.common.input.TestInputNote")

---@param t testing.T
---@param h rizu.InputNotesHandler
---@param _t number
---@param n integer
local function update_and_eq_active(t, h, _t, n)
	for _, note in ipairs(h.notes) do
		---@cast note rizu.TestInputNote
		note.current_time = _t
	end
	h:update()
	t:eq(h:getActiveNotesCount(), n)
end

local test = {}

---@param t testing.T
function test.no_notes(t)
	local h = InputNotesHandler({})

	t:has_not_error(h.update, h, 0)
	t:has_not_error(h.receive, h, {})
end

---@param t testing.T
function test.track_active_notes(t)
	local function new_note(active)
		local note = TestInputNote()
		note.time = 0
		note.early_window = -1
		note.late_window = 1
		note.active = active
		function note:update()
			if self.current_time > self:getEndTime() then
				self.active = false
			end
		end
		return note
	end

	local h = InputNotesHandler({
		new_note(true),
		new_note(false),
		new_note(true),
		new_note(false),
	})

	update_and_eq_active(t, h, -10, 0)
	update_and_eq_active(t, h, -1, 2)
	update_and_eq_active(t, h, 0, 2)
	update_and_eq_active(t, h, 1, 2)
	update_and_eq_active(t, h, 10, 0)
end

---@param t testing.T
function test.match(t)
	local function new_note(match_event)
		local note = TestInputNote()
		note.time = 0
		note.early_window = -1
		note.late_window = 1
		note.active = true
		function note:match(event)
			return event == match_event
		end
		function note:receive(event)
			table.insert(event, self)
		end
		return note
	end

	local event_1 = {}
	local event_2 = {}

	local notes = {
		new_note(event_1),
		new_note(event_2),
	}

	local h = InputNotesHandler(notes)

	update_and_eq_active(t, h, 0, 2)

	h:receive(event_1)
	t:eq(event_1[1], notes[1])
	t:eq(#event_1, 1)

	h:receive(event_2)
	t:eq(event_2[1], notes[2])
	t:eq(#event_2, 1)

	h:receive(event_1)
	t:eq(event_1[2], notes[1])
	t:eq(#event_1, 2)
end

---@param t testing.T
function test.catch(t)
	local function new_note(id)
		local note = TestInputNote()
		---@cast note +{catched: any}
		note.time = 0
		note.early_window = -1
		note.late_window = 1
		note.active = true
		function note:match(event)
			return not self.catched
		end
		function note:catch(event)
			return event[1] == id
		end
		function note:receive(event)
			self.catched = event
			table.insert(event, id)
		end
		return note
	end

	local event_1 = {}
	local event_2 = {}

	local notes = {
		new_note(1),
		new_note(2),
	}

	local h = InputNotesHandler(notes)

	update_and_eq_active(t, h, 0, 2)

	h:receive(event_1)
	t:eq(event_1[1], 1)
	t:eq(#event_1, 1)

	h:receive(event_2)
	t:eq(event_2[1], 2)
	t:eq(#event_2, 1)

	h:receive(event_1)
	t:eq(event_1[2], 1)
	t:eq(#event_1, 2)
end

---@param t testing.T
function test.nearest(t)
	local function new_note(time)
		local note = TestInputNote()
		---@cast note +{catched: any}
		note.time = time
		note.early_window = -10
		note.late_window = 10
		note.active = true
		function note:match(event)
			return true
		end
		function note:receive(event)
			table.insert(event, time)
		end
		return note
	end

	local event = {}

	local notes = {
		new_note(0),
		new_note(2),
	}

	local h = InputNotesHandler(notes)
	h.nearest = true

	update_and_eq_active(t, h, 1, 2)

	h:receive(event)
	t:eq(event[1], 0)

	update_and_eq_active(t, h, 1.001, 2)

	h:receive(event)
	t:eq(event[2], 2)

	update_and_eq_active(t, h, 0.999, 2)

	h:receive(event)
	t:eq(event[3], 0)
end

---@param t testing.T
function test.priority(t)
	local function new_note(time, priority)
		local note = TestInputNote()
		---@cast note +{catched: any}
		note.time = time
		note.early_window = -10
		note.late_window = 10
		note.active = true
		note.priority = priority
		function note:match(event)
			return true
		end
		function note:receive(event)
			table.insert(event, time)
		end
		return note
	end

	local event = {}

	local notes = {
		new_note(0, 0),
		new_note(2, 1),
	}

	local h = InputNotesHandler(notes)

	update_and_eq_active(t, h, 0, 2)

	h:receive(event)
	t:eq(event[1], 2)
end

return test
