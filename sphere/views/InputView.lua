local just = require("just")
local LabelImView = require("sphere.imviews.LabelImView")
local HotkeyImView = require("sphere.imviews.HotkeyImView")
local TextButtonImView = require("sphere.imviews.TextButtonImView")
local ModalImView = require("sphere.imviews.ModalImView")
local _transform = require("aqua.graphics.transform")
local spherefonts = require("sphere.assets.fonts")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local currentDevice = "keyboard"
local scrollY = 0

return ModalImView(function(self)
	local noteChart = self.game.noteChartModel.noteChart
	local inputMode = noteChart.inputMode:getString()
	local inputs = self.game.inputModel:getInputs(inputMode)
	local devices = self.game.inputModel.devices

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate(279 + 454 * 3 / 4, 1080 / 4)
	local w, h = 454 * 1.5, 1080 / 2
	local r = 8

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)

	just.clip(love.graphics.rectangle, "fill", 0, 0, w, h, r)

	local window_id = "InputView"
	local over = just.is_over(w, h)
	just.container(window_id, over)
	just.button(window_id, over)

	local inputHeight = 55

	local scroll = just.wheel_over(window_id, just.is_over(w, h))

	love.graphics.translate(0, -scrollY)

	local startHeight = just.height

	just.row(true)
	for _, device in ipairs(devices) do
		if device == currentDevice then
			love.graphics.setColor(1, 1, 1, 0.1)
			love.graphics.rectangle("fill", 0, 0, w / #devices, inputHeight)
		end
		love.graphics.setColor(1, 1, 1, 1)
		if TextButtonImView("InputView " .. device, device, w / #devices, inputHeight) then
			currentDevice = device
		end
	end
	just.row(false)
	love.graphics.line(0, 0, w, 0)

	for i = 1, #inputs do
		local virtualKey = inputs[i]
		local key = self.game.inputModel:getKey(inputMode, virtualKey, currentDevice)
		local changed, key = HotkeyImView(i, currentDevice, key, w / 2, inputHeight)
		if changed then
			self.game.inputModel:setKey(inputMode, virtualKey, currentDevice, key)
			if i + 1 <= #inputs then
				just.focus(i + 1)
			end
		end
		just.sameline()
		just.indent(8)
		LabelImView(i, virtualKey, inputHeight)
	end

	just.container()
	just.clip()

	local overlap = math.max(just.height - startHeight - h, 0)
	if overlap > 0 and scroll then
		scrollY = math.min(math.max(scrollY - scroll * 50, 0), overlap)
	end

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
end)
