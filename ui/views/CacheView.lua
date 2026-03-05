local just = require("just")
local imgui = require("imgui")
local spherefonts = require("sphere.assets.fonts")
local time_util = require("time_util")

local function ui_lock(self)
	---@type sphere.GameController
	local game = self.game

	if not game.library.isProcessing then
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

	local library = game.library
	local status = library.status

	local stage_messages = {
		scanning = "Searching files...",
		hashing = "Hashing charts...",
		difficulty = "Computing difficulty...",
		scores = "Processing scores...",
	}
	local msg = stage_messages[status.stage] or "Busy..."

	love.graphics.setColor(1, 1, 1, 1)
	imgui.text(msg)
	if status.label then
		imgui.text(status.label)
	end
	imgui.text(("%s / %s"):format(status.current, status.total))

	if status.itemsPerSecond then
		imgui.text(("%0.1f items/sec"):format(status.itemsPerSecond))
	end
	if status.eta then
		imgui.text(("ETA: %s"):format(time_util.format(status.eta)))
	end
	if status.errorCount > 0 then
		love.graphics.setColor(1, 0.4, 0.4, 1)
		imgui.text(("Errors: %d"):format(status.errorCount))
		love.graphics.setColor(1, 1, 1, 1)
	end
	
	if status.total > 0 then
		local progress = math.min(status.current / status.total, 1)
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
		library:stopTask()
	end

	just.container()
end

return ui_lock
