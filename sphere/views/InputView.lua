local just = require("just")
local imgui = require("imgui")
local ModalImView = require("sphere.imviews.ModalImView")
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

	imgui.setSize(w, h, _w, _h)

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

	currentDevice = imgui.tabs("input tabs", currentDevice, devices)

	imgui.Container(window_id, w, h - _h, _h / 3, _h * 2, scrollY)

	for i = 1, #inputs do
		local hotkey_id = "input hotkey" .. i
		local virtualKey = inputs[i]
		local key = self.game.inputModel:getKey(inputMode, virtualKey, currentDevice)
		local changed, key = imgui.Hotkey(hotkey_id, currentDevice, key, _w, _h)
		if changed then
			self.game.inputModel:setKey(inputMode, virtualKey, currentDevice, key)
			if i + 1 <= #inputs then
				just.focus("input hotkey" .. (i + 1))
			end
		end
		just.sameline()
		just.indent(8)
		imgui.Label(hotkey_id, virtualKey, _h)
	end
	just.emptyline(8)

	scrollY = imgui.Container()
	just.pop()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
end)
