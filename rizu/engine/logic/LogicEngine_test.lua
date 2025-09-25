local LogicEngine = require("rizu.engine.logic.LogicEngine")
local TestLogicNote = require("rizu.engine.logic.TestLogicNote")

---@param t testing.T
---@param h rizu.LogicEngine
---@param _t number
---@param n integer
local function update_and_eq_active(t, h, _t, n)
	for _, note in ipairs(h.notes) do
		---@cast note rizu.TestLogicNote
		note.current_time = _t
	end
	h:update()
	t:eq(h:getActiveNotesCount(), n)
end

local test = {}

---@param t testing.T
function test.no_notes(t)
	local h = LogicEngine()

	t:has_not_error(h.update, h)
end

---@param t testing.T
function test.track_active_notes(t)
	local function new_note()
		local note = TestLogicNote()
		note.time = 0
		note.early_window = -1
		note.late_window = 1
		return note
	end

	local h = LogicEngine()
	h:setNotes({
		new_note(),
		new_note(),
	})

	update_and_eq_active(t, h, -10, 0)
	update_and_eq_active(t, h, -1, 2)
	update_and_eq_active(t, h, 0, 2)
	update_and_eq_active(t, h, 1, 2)
	update_and_eq_active(t, h, 10, 2)

	for _, note in ipairs(h.active_notes) do
		---@cast note rizu.TestLogicNote
		note.active = false
	end

	update_and_eq_active(t, h, 10, 0)
end

return test
