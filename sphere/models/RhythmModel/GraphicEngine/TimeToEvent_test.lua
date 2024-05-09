local TimeToEvent = require("sphere.models.RhythmModel.GraphicEngine.TimeToEvent")
local Chart = require("ncdk2.Chart")
local AbsoluteLayer = require("ncdk2.layers.AbsoluteLayer")
local Velocity = require("ncdk2.visual.Velocity")

local test = {}

function test.basic(t)
	local layer = AbsoluteLayer()
	local vp = layer.visual:newPoint(layer:getPoint(0))
	vp._velocity = Velocity(1)

	layer:compute()

	local events = TimeToEvent(layer.visual.points, {-1, 1})
	t:eq(#events, 2)
	t:eq(events[1].time, -1)
	t:eq(events[1].action, "show")
	t:eq(events[2].time, 1)
	t:eq(events[2].action, "hide")
end

function test.local_1(t)
	local layer = AbsoluteLayer()

	local vp_1 = layer.visual:newPoint(layer:getPoint(0))
	vp_1._velocity = Velocity(1)

	local vp_2 = layer.visual:newPoint(layer:getPoint(1))
	vp_2._velocity = Velocity(1, 0.5)

	layer:compute()

	local events = TimeToEvent(layer.visual.points, {-1, 1})
	t:eq(#events, 4)
end

return test
