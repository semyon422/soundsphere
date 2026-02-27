local VisualEngine = require("rizu.engine.visual.VisualEngine")
local VisualInfo = require("rizu.engine.visual.VisualInfo")
local TestChartFactory = require("sea.chart.TestChartFactory")
local Chart = require("ncdk2.Chart")
local AbsoluteLayer = require("ncdk2.layers.AbsoluteLayer")
local Visual = require("ncdk2.visual.Visual")
local InputMode = require("ncdk.InputMode")
local Note = require("notechart.Note")

local tcf = TestChartFactory()

local test = {}

---@param t testing.T
function test.bga_basic(t)
	local visual_info = VisualInfo()
	local ve = VisualEngine(visual_info)

	local chart = Chart()
	chart.inputMode = InputMode("4key")
	local inputMap = chart.inputMode:getInputs()

	local layer = AbsoluteLayer()
	chart.layers.main = layer

	local visual_gameplay = Visual()
	visual_gameplay.primaryTempo = 120
	layer.visuals["gameplay"] = visual_gameplay

	local visual_bga = Visual()
	visual_bga.bga = true
	visual_bga.primaryTempo = 120
	layer.visuals["bga"] = visual_bga

	-- Gameplay notes
	local p1 = layer:getPoint(1)
	local vp1 = visual_gameplay:getPoint(p1)
	chart.notes:insert(Note(vp1, inputMap[1], "tap", 0))

	-- BGA notes
	local p0 = layer:getPoint(0)
	local p2 = layer:getPoint(2)
	local vb0 = visual_bga:getPoint(p0)
	local vb2 = visual_bga:getPoint(p2)

	chart.notes:insert(Note(vb0, 100, "sprite", 0))
	chart.notes:insert(Note(vb2, 100, "sprite", 0))

	chart:compute()
	ve:load(chart)

	-- Test
	visual_info.time = -1
	ve:update()
	-- Sprite 1 (at 0) should be visible even before its time
	t:eq(#ve.visible_notes, 1)
	t:eq(ve.visible_notes[1].linked_note:getStartTime(), 0)

	visual_info.time = 1
	ve:update()
	-- Sprite 1 still visible + Gameplay note 1 (at 1)
	t:eq(#ve.visible_notes, 2)

	visual_info.time = 2.5
	ve:update()
	-- Sprite 2 (at 2) is visible. Gameplay note at 1 is gone.
	t:eq(#ve.visible_notes, 1)
	t:eq(ve.visible_notes[1].linked_note:getStartTime(), 2)

	visual_info.time = 10
	ve:update()
	-- Sprite 2 still visible
	t:eq(#ve.visible_notes, 1)
	t:eq(ve.visible_notes[1].linked_note:getStartTime(), 2)
end

---@param t testing.T
function test.bga_multiple_columns(t)
	local visual_info = VisualInfo()
	local ve = VisualEngine(visual_info)

	local chart = Chart()
	local layer = AbsoluteLayer()
	chart.layers.main = layer

	local visual_bga1 = Visual()
	visual_bga1.bga = true
	layer.visuals["bga1"] = visual_bga1

	local visual_bga2 = Visual()
	visual_bga2.bga = true
	layer.visuals["bga2"] = visual_bga2

	-- BGA 1 notes
	local p0 = layer:getPoint(0)
	local vb0_1 = visual_bga1:getPoint(p0)
	chart.notes:insert(Note(vb0_1, 100, "sprite", 0))

	-- BGA 2 notes
	local vb0_2 = visual_bga2:getPoint(p0)
	chart.notes:insert(Note(vb0_2, 101, "sprite", 0))

	chart:compute()
	ve:load(chart)

	-- Both should be visible
	visual_info.time = 0
	ve:update()
	t:eq(#ve.visible_notes, 2)
end

---@param t testing.T
function test.bga_multiple_columns_single_visual(t)
	local visual_info = VisualInfo()
	local ve = VisualEngine(visual_info)

	local chart = Chart()
	local layer = AbsoluteLayer()
	chart.layers.main = layer

	local visual_bga = Visual()
	visual_bga.bga = true
	layer.visuals["bga"] = visual_bga

	-- BGA column 1 note at time 0
	local p0 = layer:getPoint(0)
	local vb0_1 = visual_bga:getPoint(p0)
	chart.notes:insert(Note(vb0_1, 100, "sprite", 0))

	-- BGA column 2 note at time 2
	local p2 = layer:getPoint(2)
	local vb2_2 = visual_bga:getPoint(p2)
	chart.notes:insert(Note(vb2_2, 101, "sprite", 0))

	chart:compute()
	ve:load(chart)

	-- At time 0, both should be visible (Sprite 1 in column 1 and Sprite 2 in column 2 because it's the first in its column)
	visual_info.time = 0
	ve:update()
	t:eq(#ve.visible_notes, 2)
	t:eq(ve.visible_notes[1].linked_note:getColumn(), 100)
	t:eq(ve.visible_notes[2].linked_note:getColumn(), 101)
end

---@param t testing.T
function test.basic_short(t)
	local visual_info = VisualInfo()
	local ve = VisualEngine(visual_info)

	local res = tcf:create("4key", {
		{time = 0, column = 1},
		{time = 1, column = 2},
		{time = 2, column = 3},
	})

	ve:load(res.chart)

	visual_info.time = -1.001
	ve:update()
	t:eq(#ve.visible_notes, 0)

	visual_info.time = -1
	ve:update()
	t:eq(#ve.visible_notes, 1)

	visual_info.time = 0.999
	ve:update()
	t:eq(#ve.visible_notes, 2)

	visual_info.time = 1
	ve:update()
	t:eq(#ve.visible_notes, 2)

	visual_info.time = 2.001
	ve:update()
	t:eq(#ve.visible_notes, 1)

	visual_info.time = 3
	ve:update()
	t:eq(#ve.visible_notes, 0)
end

---@param t testing.T
function test.basic_long(t)
	local visual_info = VisualInfo()
	local ve = VisualEngine(visual_info)

	local res = tcf:create("4key", {
		{time = 0, column = 1, end_time = 4},
	})

	ve:load(res.chart)

	visual_info.time = -1.001
	ve:update()
	t:eq(#ve.visible_notes, 0)

	visual_info.time = -1
	ve:update()
	t:eq(#ve.visible_notes, 1)

	visual_info.time = 2
	ve:update()
	t:eq(#ve.visible_notes, 1)

	visual_info.time = 4.999
	ve:update()
	t:eq(#ve.visible_notes, 1)

	visual_info.time = 5
	ve:update()
	t:eq(#ve.visible_notes, 0)
end

---@param t testing.T
function test.sv_should_move_with_notes(t)
	local visual_info = VisualInfo()
	local ve = VisualEngine(visual_info)

	local res = tcf:create("4key", {
		{time = 0, velocity = {}},
		{time = 0.25, column = 2, velocity = {0.5}},
		{time = 0.75, column = 3, velocity = {}},
	})

	ve:load(res.chart)

	local notes = ve.visible_notes
	---@cast notes rizu.ShortVisualNote[]

	visual_info.time = 0
	ve:update()
	t:eq(#notes, 2)

	t:eq(notes[1].start_dt, -0.25)
	t:eq(notes[2].start_dt, -0.5)

	visual_info.time = 0.25
	ve:update()

	t:eq(notes[1].start_dt, 0)
	t:eq(notes[2].start_dt, -0.25)

	visual_info.time = 0.5
	ve:update()

	t:eq(notes[1].start_dt, 0.125)
	t:eq(notes[2].start_dt, -0.125)
end

return test
