local just = require("just")
local imgui = require("imgui")
local spherefonts = require("sphere.assets.fonts")

local function ui_lock(self)
	if not self.game.cacheModel.isProcessing then
		return
	end

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	just.container("cache task container", true)
	love.graphics.origin()
	local w, h = love.graphics.getDimensions()
	love.graphics.setColor(0, 0, 0, 0.75)
	love.graphics.rectangle("fill", 0, 0, w, h)
	just.wheel_over("cache task container", true)
	just.mouse_over("cache task container", true, "mouse")

	local cacheModel = self.game.cacheModel
	local count = cacheModel.shared.chartfiles_count
	local current = cacheModel.shared.chartfiles_current
	love.graphics.setColor(1, 1, 1, 1)
	imgui.text(("%s/%s"):format(current, count))
	imgui.text(("%0.2f%%"):format(current / count * 100))
	if imgui.button("stopTask", "stop task") then
		cacheModel:stopTask()
	end

	just.container()
end

return ui_lock
