
local just = require("just")
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local baseline_print = require("aqua.graphics.baseline_print")
local spherefonts = require("sphere.assets.fonts")
local IconButtonImView = require("sphere.views.IconButtonImView")
local TextButtonImView = require("sphere.views.TextButtonImView")
local CheckboxImView = require("sphere.views.CheckboxImView")
local LabelImView = require("sphere.views.LabelImView")

local CacheView = Class:new()

CacheView.draw = function(self)
	local tf = transform(self.transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	local cacheModel = self.game.cacheModel
	local state = cacheModel.state

	local text = ""
	if state == 1 then
		text = ("searching for charts: %d"):format(cacheModel.noteChartCount)
	elseif state == 2 then
		text = ("creating cache: %0.2f%%"):format(cacheModel.cachePercent)
	elseif state == 3 then
		text = "complete"
	elseif state == 0 then
		text = "update"
	end

	local changed, active, hovered = just.button(self, just.is_over(self.w, self.h))
	if hovered then
		local alpha = active and 0.2 or 0.1
		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.rectangle("fill", 0, 0, self.w, self.h)
	end
	love.graphics.setColor(1, 1, 1, 1)

	if changed then
		self.game.selectController:updateCacheCollection(
			self.game.selectModel.collectionItem.path,
			love.keyboard.isDown("lshift")
		)
	end

	baseline_print(text, 44, 45, math.huge, 1, "left")
end

return CacheView
