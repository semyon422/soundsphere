local LongVisualNote = require("rizu.engine.visual.LongVisualNote")
local VisualInfo = require("rizu.engine.visual.VisualInfo")
local HoldLogicNote = require("rizu.engine.logic.notes.HoldLogicNote")
local LinkedNote = require("ncdk2.notes.LinkedNote")
local Note = require("ncdk2.notes.Note")
local Visual = require("ncdk2.visual.Visual")
local VisualPoint = require("ncdk2.visual.VisualPoint")
local Point = require("ncdk2.tp.Point")

local function new_ctx()
	local visual = Visual()

	local cvp = VisualPoint(Point(0))

	local linked_note = LinkedNote(
		Note(visual:getPoint(Point(1)), "key1", "hold", 1),
		Note(visual:getPoint(Point(2)), "key1", "hold", -1)
	)
	local visual_info = VisualInfo()
	local visual_note = LongVisualNote(linked_note, visual_info)
	visual_note.visual = visual
	visual_note.cvp = cvp

	visual:compute()

	---@param time number
	local function set_time(time)
		visual_info.time = time
		cvp.visualTime = time
		cvp.monotonicVisualTime = time
		cvp.point.absoluteTime = time
	end

	local logic_note = HoldLogicNote(linked_note, {}, visual_info)
	visual_info.logic_notes[linked_note] = logic_note

	local offsets = {-0.5, -0.25, 0, 0.25, 0.5}

	return {
		set_time = set_time,
		visual_info = visual_info,
		note = visual_note,
		logic_note = logic_note,
		offsets = offsets,
		iter = function()
			---@type fun(): boolean, number, number
			return coroutine.wrap(function()
				for _, const in ipairs({false, true}) do
					visual_info.const = const
					for _, offset in ipairs(offsets) do
						visual_info.offset = offset
						coroutine.yield(const, offset)
					end
				end
			end)
		end
	}
end

local test = {}

--- Do not press
---@param t testing.T
function test.do_not_press(t)
	local ctx = new_ctx()

	for const, offset in ctx.iter() do
		ctx.set_time(0 + offset)
		ctx.note:update()
		t:eq(ctx.note.start_dt, -1)
		t:eq(ctx.note.end_dt, -2)

		ctx.set_time(0.75 + offset)
		ctx.note:update()
		t:eq(ctx.note.start_dt, -0.25)
		t:eq(ctx.note.end_dt, -1.25)

		ctx.set_time(1.5 + offset)
		ctx.note:update()
		t:eq(ctx.note.start_dt, 0.5)
		t:eq(ctx.note.end_dt, -0.5)

		ctx.set_time(2.25 + offset)
		ctx.note:update()
		t:eq(ctx.note.start_dt, 1.25)
		t:eq(ctx.note.end_dt, 0.25)
	end
end

--- Early press, late release
---@param t testing.T
function test.hold(t)
	local ctx = new_ctx()

	for const, offset in ctx.iter() do
		ctx.logic_note.state = "startPassedPressed"

		ctx.set_time(0 + offset)
		ctx.note:update()
		t:eq(ctx.note.start_dt, -1)
		t:eq(ctx.note.end_dt, -2)

		ctx.set_time(0.75 + offset)
		ctx.note:update()
		t:eq(ctx.note.start_dt, -0.25)
		t:eq(ctx.note.end_dt, -1.25)

		ctx.set_time(1.5 + offset)
		ctx.note:update()
		t:eq(ctx.note.start_dt, 0)
		t:eq(ctx.note.end_dt, -0.5)

		ctx.set_time(2.25 + offset)
		ctx.note:update()
		t:eq(ctx.note.start_dt, 0.25)
		t:eq(ctx.note.end_dt, 0.25)
	end
end

--- Late press
---@param t testing.T
function test.hold_late_press(t)
	local ctx = new_ctx()

	for const, offset in ctx.iter() do
		ctx.logic_note.state = "startPassedPressed"

		ctx.set_time(1.25 + offset)
		ctx.note:update()
		t:eq(ctx.note.start_dt, 0.25)
		t:eq(ctx.note.end_dt, -0.75)

		ctx.set_time(1.3 + offset)
		ctx.note:update()
		t:aeq(ctx.note.start_dt, 0.2, 1e-6)
		t:aeq(ctx.note.end_dt, -0.7, 1e-6)

		ctx.set_time(1.4 + offset)
		ctx.note:update()
		t:aeq(ctx.note.start_dt, 0.1, 1e-6)
		t:aeq(ctx.note.end_dt, -0.6, 1e-6)

		ctx.set_time(1.5 + offset)
		ctx.note:update()
		t:aeq(ctx.note.start_dt, 0, 1e-6)
		t:aeq(ctx.note.end_dt, -0.5, 1e-6)

		ctx.set_time(1.75 + offset)
		ctx.note:update()
		t:aeq(ctx.note.start_dt, 0, 1e-6)
		t:aeq(ctx.note.end_dt, -0.25, 1e-6)
	end
end

--- Early release
---@param t testing.T
function test.hold_early_release(t)
	local ctx = new_ctx()

	for const, offset in ctx.iter() do
		ctx.logic_note.state = "startPassedPressed"
		ctx.set_time(1 + offset)
		ctx.note:update()
		t:eq(ctx.note.start_dt, 0)
		t:eq(ctx.note.end_dt, -1)

		ctx.logic_note.state = "endPassed"
		ctx.set_time(1.5 + offset)
		ctx.note:update()
		t:eq(ctx.note.start_dt, 0)
		t:eq(ctx.note.end_dt, -0.5)

		ctx.set_time(1.75 + offset)
		ctx.note:update()
		t:eq(ctx.note.start_dt, 0)
		t:eq(ctx.note.end_dt, -0.25)

		ctx.set_time(2.25 + offset)
		ctx.note:update()
		t:eq(ctx.note.start_dt, 0.25)
		t:eq(ctx.note.end_dt, 0.25)
	end
end

---@param t testing.T
function test.shortening(t)
	local ctx = new_ctx()

	ctx.logic_note.state = "startPassedPressed"
	ctx.visual_info.shortening = -0.25

	ctx.set_time(0)
	ctx.note:update()
	t:eq(ctx.note.start_dt, -1)
	t:eq(ctx.note.end_dt, -1.75)

	ctx.set_time(2.25)
	ctx.note:update()
	t:eq(ctx.note.start_dt, 0.5)
	t:eq(ctx.note.end_dt, 0.5)
end

return test
