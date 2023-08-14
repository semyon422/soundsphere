
local just = require("just")
local class = require("class")
local gfx_util = require("gfx_util")
local spherefonts = require("sphere.assets.fonts")

local CacheView = class()

function CacheView:draw(w, h)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	local cacheModel = self.game.cacheModel
	local shared = cacheModel.shared
	local state = shared.state

	local text = ""
	if state == 1 then
		text = ("searching for charts: %d"):format(shared.noteChartCount)
	elseif state == 2 then
		text = ("creating cache: %0.2f%%"):format(shared.cachePercent)
	elseif state == 3 then
		text = "complete"
	elseif state == 0 then
		text = "update"
	end

	local changed, active, hovered = just.button(self, just.is_over(w, h))
	if hovered then
		local alpha = active and 0.2 or 0.1
		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.rectangle("fill", 0, 0, w, h)
	end
	love.graphics.setColor(1, 1, 1, 1)

	if changed then
		self.game.selectController:updateCacheCollection(
			self.game.selectModel.collectionItem.path,
			love.keyboard.isDown("lshift")
		)
	end

	gfx_util.printBaseline(text, 44, 45, math.huge, 1, "left")
end

return CacheView
