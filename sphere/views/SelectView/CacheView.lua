
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local baseline_print = require("aqua.graphics.baseline_print")
local spherefonts = require("sphere.assets.fonts")

local CacheView = Class:new()

CacheView.draw = function(self)
	local config = self.config

	local tf = transform(config.transform):translate(config.x, config.y)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(1, 1, 1, 1)

	local font = spherefonts.get(config.text.font)
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
		config.text.x,
		config.text.baseline,
		config.text.limit,
		1,
		config.text.align
	)
end

CacheView.receive = function(self, event)
	local config = self.config
	if event.name == "mousepressed" then
		local tf = transform(config.transform)
		local mx, my = tf:inverseTransformPoint(event[1], event[2])

		local button = event[3]

		local x = config.x
		local y = config.y
		local w = config.w
		local h = config.h

		if mx >= x and mx < x + w and my >= y and my < y + h and button == 1 then
			self.navigator:updateCacheCollection()
		end
	end
end

return CacheView
