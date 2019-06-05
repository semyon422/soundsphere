local Class = require("aqua.util.Class")
local Line = require("aqua.graphics.Line")

local AccuracyGraph = Class:new()

AccuracyGraph.load = function(self)
	self.points = {}
	self.line = Line:new({
		points = self.points,
		cs = self.cs,
		lineStyle = "smooth",
		lineWidth = 2
	})
	
	local maxAmount = 0
	local hits = {}
	for deltaTime, amount in pairs(self.score.hits) do
		hits[#hits + 1] = {deltaTime, amount}
		maxAmount = math.max(maxAmount, amount)
	end
	table.sort(hits, function(a, b) return a[1] < b[1] end)
	
	for i = 1, #hits do
		self.points[#self.points + 1] = hits[i][1] * 4 / 250 + 0.5
		self.points[#self.points + 1] = 1 - hits[i][2] / maxAmount / 4
	end
	
	if #self.points > 0 then
		self.line:reload()
	end
end

AccuracyGraph.reload = function(self)
	if #self.points >= 4 then
		self.line:reload()
	end
end

AccuracyGraph.draw = function(self)
	if #self.points >= 4 then
		self.line:draw()
	end
end

return AccuracyGraph
