local Class = require("aqua.util.Class")
local Line = require("aqua.graphics.Line")

local AccuracyGraph = Class:new()

AccuracyGraph.load = function(self)
	self.points = {}
	self.line = Line:new({
		points = self.points,
		cs = self.cs
	})
end

AccuracyGraph.compute = function(self)
	local maxAmount = 0
	local hits = {}
	for deltaTime, amount in pairs(self.score.hits) do
		hits[#hits + 1] = {deltaTime, amount}
		maxAmount = math.max(maxAmount, amount)
	end
	table.sort(hits, function(a, b) return a[1] < b[1] end)
	
	local points = {}
	for i = 1, #hits do
		points[2 * i - 1] = hits[i][1] + 0.5
		points[2 * i] = 1 - hits[i][2] / maxAmount / 2
	end
	self.points = points
	
	if #self.points > 0 then
		self.line.points = points
		self.line:reload()
	end
end

AccuracyGraph.reload = function(self)
	if #self.points > 0 then
		self.line:reload()
	end
end

AccuracyGraph.draw = function(self)
	if #self.points > 0 then
		self.line:draw()
	end
end

return AccuracyGraph
