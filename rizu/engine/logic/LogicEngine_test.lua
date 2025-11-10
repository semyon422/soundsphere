local LogicEngine = require("rizu.engine.logic.LogicEngine")
local LogicInfo = require("rizu.engine.logic.LogicInfo")
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

local offsets = {-0.5, -0.25, 0, 0.25, 0.5}

local function iter_offsets(logic_info)
	---@type fun(): boolean, number, number
	return coroutine.wrap(function()
		for _, input_offset in ipairs(offsets) do
			logic_info.input_offset = input_offset
			coroutine.yield(input_offset)
		end
	end)
end

local test = {}

---@param t testing.T
function test.no_notes(t)
	local h = LogicEngine()

	t:has_not_error(h.update, h)
end

---@param t testing.T
function test.track_active_notes(t)
	local logic_info = LogicInfo()
	logic_info.timing_values:setSimple(1)

	local le = LogicEngine(logic_info)

	local chart = get_chart([[
1000 =0
0100 =1
0010 =2
]])

	for logic_offset in iter_offsets(logic_info) do
		le:load(chart)

		logic_info.time = -1.001 + logic_offset
		le:update()
		t:eq(le:getActiveNotesCount(), 0)

		logic_info.time = -1 + logic_offset
		le:update()
		t:eq(le:getActiveNotesCount(), 1)

		logic_info.time = 0.999 + logic_offset
		le:update()
		t:eq(le:getActiveNotesCount(), 2)

		logic_info.time = 1 + logic_offset
		le:update()
		t:eq(le:getActiveNotesCount(), 3)

		logic_info.time = 2.001 + logic_offset
		le:update()
		t:eq(le:getActiveNotesCount(), 1)

		logic_info.time = 3.001 + logic_offset
		le:update()
		t:eq(le:getActiveNotesCount(), 0)
	end
end

return test
