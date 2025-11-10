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

local offsets = {-0.5, -0.25, 0, 0.25, 0.5}

local function iter_offsets(visual_info)
	---@type fun(): boolean, number, number
	return coroutine.wrap(function()
		for _, visual_offset in ipairs(offsets) do
			visual_info.visual_offset = visual_offset
			coroutine.yield(visual_offset)
		end
	end)
end

---@param t testing.T
function test.basic_short(t)
	local visual_info = VisualInfo()
	local ve = VisualEngine(visual_info)

	local chart = get_chart([[
1000 =0
0100 =1
0010 =2
]])

	for visual_offset in iter_offsets(visual_info) do
		ve:load(chart)

		visual_info.time = -1.001 + visual_offset
		ve:update()
		t:eq(#ve.visible_notes, 0)

		visual_info.time = -1 + visual_offset
		ve:update()
		t:eq(#ve.visible_notes, 1)

		visual_info.time = 0.999 + visual_offset
		ve:update()
		t:eq(#ve.visible_notes, 2)

		visual_info.time = 1 + visual_offset
		ve:update()
		t:eq(#ve.visible_notes, 2)

		visual_info.time = 2.001 + visual_offset
		ve:update()
		t:eq(#ve.visible_notes, 1)

		visual_info.time = 3 + visual_offset
		ve:update()
		t:eq(#ve.visible_notes, 0)
	end
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

	for visual_offset in iter_offsets(visual_info) do
		ve:load(chart)

		visual_info.time = -1.001 + visual_offset
		ve:update()
		t:eq(#ve.visible_notes, 0)

		visual_info.time = -1 + visual_offset
		ve:update()
		t:eq(#ve.visible_notes, 1)

		visual_info.time = 2 + visual_offset
		ve:update()
		t:eq(#ve.visible_notes, 1)

		visual_info.time = 4.999 + visual_offset
		ve:update()
		t:eq(#ve.visible_notes, 1)

		visual_info.time = 5 + visual_offset
		ve:update()
		t:eq(#ve.visible_notes, 0)
	end
end

return test
