local InputNotesHandler = require("rizu.modes.common.input.InputNotesHandler")
local InputNote = require("rizu.modes.common.input.InputNote")

---@param t testing.T
---@param h rizu.InputNotesHandler
---@param n integer
local function update_and_eq_active(t, h, _t, n)
	h:update(_t)
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
		local note = InputNote()
		note.time = 0
		note.early_window = -1
		note.late_window = 1
		note.active = active
		function note:update(time)
			if time > self:getEndTime() then
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

return test
