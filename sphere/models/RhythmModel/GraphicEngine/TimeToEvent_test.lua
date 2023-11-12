local TimeToEvent = require("sphere.models.RhythmModel.GraphicEngine.TimeToEvent")
local NoteChart = require("ncdk.NoteChart")

local test = {}

function test.basic(t)
	local nc = NoteChart()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("absolute")

	local tp = ld:getTimePoint(0)
	ld:insertVelocityData(tp, 1)

	nc:compute()

	local events = TimeToEvent(ld)
	t:eq(#events, 2)
	t:eq(events[1].time, -1)
	t:eq(events[1].action, "show")
	t:eq(events[2].time, 1)
	t:eq(events[2].action, "hide")
end

function test.local_1(t)
	local nc = NoteChart()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("absolute")

	local tp_1 = ld:getTimePoint(0)
	ld:insertVelocityData(tp_1, 1)

	local tp_2 = ld:getTimePoint(1)
	ld:insertVelocityData(tp_2, 1, 0.5)

	nc:compute()

	local events = TimeToEvent(ld)
	t:eq(#events, 4)
end

return test
