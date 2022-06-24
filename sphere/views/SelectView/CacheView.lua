
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local baseline_print = require("aqua.graphics.baseline_print")
local spherefonts = require("sphere.assets.fonts")

local CacheView = Class:new()

CacheView.draw = function(self)
	local tf = transform(self.transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(1, 1, 1, 1)

	local font = spherefonts.get(self.text.font)
	love.graphics.setFont(font)

	local cacheUpdater = self.game.cacheModel.cacheUpdater
	local state = cacheUpdater.state

	local text = ""
	if state == 1 then
		text = ("searching for charts: %d"):format(cacheUpdater.noteChartCount)
	elseif state == 2 then
		text = ("creating cache: %0.2f%%"):format(cacheUpdater.cachePercent)
	elseif state == 3 then
		text = "complete"
	elseif state == 0 then
		text = "update"
	end

	baseline_print(
		text,
		self.text.x,
		self.text.baseline,
		self.text.limit,
		1,
		self.text.align
	)
end

CacheView.receive = function(self, event)
	if event.name == "mousepressed" then
		local tf = transform(self.transform)
		local mx, my = tf:inverseTransformPoint(event[1], event[2])

		local button = event[3]

		local x = self.x
		local y = self.y
		local w = self.w
		local h = self.h

		if mx >= x and mx < x + w and my >= y and my < y + h and button == 1 then
			self.navigator:updateCacheCollection()
		end
	end
end

return CacheView
