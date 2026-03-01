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
	local state = cacheModel.shared.state

	local state_messages = {
		[1] = "Searching files...",
		[2] = "Computing difficulty...",
		[3] = "Processing scores...",
	}
	local msg = state_messages[state] or "Busy..."

	love.graphics.setColor(1, 1, 1, 1)
	imgui.text(msg)
	imgui.text(("%s / %s"):format(current, count))
	
	if count > 0 then
		local progress = math.min(current / count, 1)
		imgui.text(("%0.2f%%"):format(progress * 100))
		-- Simple progress bar using rectangles
		local bar_w, bar_h = 400, 20
		local bar_x = (w - bar_w) / 2
		local bar_y = h / 2 + 100
		
		love.graphics.setColor(0.2, 0.2, 0.2, 1)
		love.graphics.rectangle("fill", bar_x, bar_y, bar_w, bar_h)
		love.graphics.setColor(0.4, 0.8, 0.4, 1)
		love.graphics.rectangle("fill", bar_x, bar_y, bar_w * progress, bar_h)
	end

	if imgui.button("stopTask", "stop task") then
		cacheModel:stopTask()
	end

	just.container()
end

return ui_lock
