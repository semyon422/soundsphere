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
		time = time - visual_info.input_offset
		cvp.visualTime = time
		cvp.monotonicVisualTime = time
		cvp.point.absoluteTime = time
	end

	local logic_note = HoldLogicNote(linked_note, {}, visual_info)
	visual_info.logic_notes[linked_note] = logic_note

	return {
		set_time = set_time,
		visual_info = visual_info,
		note = visual_note,
		logic_note = logic_note,
		offsets = {-0.5, -0.25, 0, 0.25, 0.5},
	}
end

local test = {}

--- Do not press
---@param t testing.T
function test.do_not_press(t)
	local ctx = new_ctx()

	for _, visual_offset in ipairs(ctx.offsets) do
		ctx.visual_info.visual_offset = visual_offset

		for _, input_offset in ipairs(ctx.offsets) do
			ctx.visual_info.input_offset = input_offset

			ctx.set_time(0 + visual_offset)
			ctx.note:update()
			t:eq(ctx.note.start_dt, -1)
			t:eq(ctx.note.end_dt, -2)

			ctx.set_time(0.75 + visual_offset)
			ctx.note:update()
			t:eq(ctx.note.start_dt, -0.25)
			t:eq(ctx.note.end_dt, -1.25)

			ctx.set_time(1.5 + visual_offset)
			ctx.note:update()
			t:eq(ctx.note.start_dt, 0.5)
			t:eq(ctx.note.end_dt, -0.5)

			ctx.set_time(2.25 + visual_offset)
			ctx.note:update()
			t:eq(ctx.note.start_dt, 1.25)
			t:eq(ctx.note.end_dt, 0.25)
		end
	end
end

--- Early press, late release, offsets
---@param t testing.T
function test.hold(t)
	local ctx = new_ctx()

	ctx.logic_note.state = "startPassedPressed"

	for _, visual_offset in ipairs(ctx.offsets) do
		ctx.visual_info.visual_offset = visual_offset

		for _, input_offset in ipairs(ctx.offsets) do
			ctx.visual_info.input_offset = input_offset

			ctx.set_time(0 + visual_offset)
			ctx.note:update()
			t:eq(ctx.note.start_dt, -1)
			t:eq(ctx.note.end_dt, -2)

			ctx.set_time(0.75 + visual_offset)
			ctx.note:update()
			t:eq(ctx.note.start_dt, -0.25)
			t:eq(ctx.note.end_dt, -1.25)

			ctx.set_time(1.5 + visual_offset)
			ctx.note:update()
			t:eq(ctx.note.start_dt, 0)
			t:eq(ctx.note.end_dt, -0.5)

			ctx.set_time(2.25 + visual_offset)
			ctx.note:update()
			t:eq(ctx.note.start_dt, 0.25)
			t:eq(ctx.note.end_dt, 0.25)
		end
	end
end

--- Early release, visual offset
---@param t testing.T
function test.hold_early_release(t)
	local ctx = new_ctx()

	for _, visual_offset in ipairs(ctx.offsets) do
		ctx.visual_info.visual_offset = visual_offset

		for _, input_offset in ipairs(ctx.offsets) do
			ctx.visual_info.input_offset = input_offset

			ctx.logic_note.state = "startPassedPressed"
			ctx.set_time(1.25 + visual_offset)
			ctx.note:update()
			t:eq(ctx.note.start_dt, 0)
			t:eq(ctx.note.end_dt, -0.75)

			ctx.logic_note.state = "endPassed"
			ctx.set_time(1.5 + visual_offset)
			ctx.note:update()
			t:eq(ctx.note.start_dt, 0)
			t:eq(ctx.note.end_dt, -0.5)

			ctx.set_time(1.75 + visual_offset)
			ctx.note:update()
			t:eq(ctx.note.start_dt, 0)
			t:eq(ctx.note.end_dt, -0.25)

			ctx.set_time(2.25 + visual_offset)
			ctx.note:update()
			t:eq(ctx.note.start_dt, 0.25)
			t:eq(ctx.note.end_dt, 0.25)
		end
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
