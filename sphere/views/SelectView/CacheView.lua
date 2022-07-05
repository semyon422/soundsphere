
local just = require("just")
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local baseline_print = require("aqua.graphics.baseline_print")
local spherefonts = require("sphere.assets.fonts")

local CacheView = Class:new()

CacheView.font = {
	filename = "Noto Sans",
	size = 24,
}

CacheView.draw = function(self)
	local tf = transform(self.transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	local font = spherefonts.get(self.font)
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

	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local over = 0 <= mx and mx <= self.w and 0 <= my and my <= self.h

	local changed, active, hovered = just.button_behavior(self, over)
	if hovered then
		local alpha = active and 0.2 or 0.1
		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.rectangle("fill", 0, 0, self.w, self.h)
	end
	love.graphics.setColor(1, 1, 1, 1)

	if changed then
		self.navigator:updateCacheCollection()
	end

	baseline_print(text, 44, 45, math.huge, 1, "left")
end

return CacheView
