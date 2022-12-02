local just = require("just")
local LabelImView = require("sphere.imviews.LabelImView")
local HotkeyImView = require("sphere.imviews.HotkeyImView")
local TextButtonImView = require("sphere.imviews.TextButtonImView")
local ModalImView = require("sphere.imviews.ModalImView")
local ContainerImView = require("sphere.imviews.ContainerImView")
local _transform = require("gfx_util").transform
local spherefonts = require("sphere.assets.fonts")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local currentDevice = "keyboard"
local scrollY = 0

local w, h = 768, 1080 / 2
local _w, _h = w / 2, 55
local r = 8
local window_id = "InputView"

return ModalImView(function(self)
	if not self then
		return true
	end

	local inputMode = tostring(self.game.modifierModel.state.inputMode)
	local inputs = self.game.inputModel:getInputs(inputMode)
	local devices = self.game.inputModel.devices

	if #inputs == 0 then
		return true
	end

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate((1920 - w) / 2, (1080 - h) / 2)

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)

	just.push()

	just.row(true)
	for _, device in ipairs(devices) do
		if device == currentDevice then
			love.graphics.setColor(1, 1, 1, 0.1)
			love.graphics.rectangle("fill", 0, 0, w / #devices, _h)
		end
		love.graphics.setColor(1, 1, 1, 1)
		if TextButtonImView("InputView " .. device, device, w / #devices, _h) then
			currentDevice = device
		end
	end
	just.row()
	love.graphics.line(0, 0, w, 0)

	ContainerImView(window_id, w, h - _h, _h * 2, scrollY)

	just.emptyline(8)
	for i = 1, #inputs do
		local hotkey_id = "input hotkey" .. i
		local virtualKey = inputs[i]
		local key = self.game.inputModel:getKey(inputMode, virtualKey, currentDevice)
		local changed, key = HotkeyImView(hotkey_id, currentDevice, key, _w, _h)
		if changed then
			self.game.inputModel:setKey(inputMode, virtualKey, currentDevice, key)
			if i + 1 <= #inputs then
				just.focus("input hotkey" .. (i + 1))
			end
		end
		just.sameline()
		just.indent(8)
		LabelImView(hotkey_id, virtualKey, _h)
	end
	just.emptyline(8)

	scrollY = ContainerImView()
	just.pop()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
end)
