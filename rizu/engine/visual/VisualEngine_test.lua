local VisualEngine = require("rizu.engine.visual.VisualEngine")
local VisualInfo = require("rizu.engine.visual.VisualInfo")
local ChartFactory = require("notechart.ChartFactory")

local cf = ChartFactory()
local test_chart_header = [[
# metadata
title Title
artist Artist
name Name
creator Creator
input 4key

# notes
]]

---@param notes string
---@return ncdk2.Chart
local function get_chart(notes)
	return assert(cf:getCharts("chart.sph", test_chart_header .. notes))[1].chart
end

local test = {}

---@param t testing.T
function test.basic_short(t)
	local visual_info = VisualInfo()
	local ve = VisualEngine(visual_info)

	local chart = get_chart([[
1000 =0
0100 =1
0010 =2
]])

	ve:load(chart)

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

	local chart = get_chart([[
2000 =0
0000 =1
0000 =2
0000 =3
3000 =4
]])

	ve:load(chart)

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

	local chart = get_chart([[
- =0 x1
0100 =0.25 x0.5
0010 =0.75 x1
]])

	ve:load(chart)

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
