local just = require("just")
local imgui = require("imgui")
local gfx_util = require("gfx_util")
local ModalImView = require("ui.imviews.ModalImView")
local spherefonts = require("sphere.assets.fonts")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local scrollY = 0

local w, h = 768, 1080 / 2
local _w, _h = w / 2, 55
local r = 8
local window_id = "InputView"

return ModalImView(function(self, quit)
	if quit then
		return true
	end

	imgui.setSize(w, h, _w, _h)

	local inputMode = tostring(self.game.selectController.state.inputMode)
	local inputs = self.game.inputModel:getInputs(inputMode)

	if #inputs == 0 then
		return true
	end

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	love.graphics.replaceTransform(gfx_util.transform(transform))
	love.graphics.translate((1920 - w) / 2, (1080 - h) / 2)

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)

	just.push()

	imgui.Container(window_id, w, h, _h / 3, _h * 2, scrollY)

	local inputModel = self.game.inputModel

	local font = love.graphics.getFont()
	local max_vk_width = 0
	for i = 1, #inputs do
		max_vk_width = math.max(max_vk_width, font:getWidth(inputs[i]))
	end

	local binds_count = inputModel:getBindsCount(inputMode)

	local inputIdPattern = "input hotkey %s %s"
	for i = 1, #inputs do
		local virtualKey = inputs[i]
		just.indent(8)
		imgui.Label("input label" .. i, virtualKey, _h)
		just.sameline()
		just.offset(max_vk_width + 16)
		for j = 1, binds_count + 1 do
			local hotkey_id = inputIdPattern:format(i, j)
			local _key, _device, _device_id = inputModel:getKey(inputMode, virtualKey, j)
			local text = _key or ""
			local width = font:getWidth(text)

			local changed, key, device, device_id = imgui.Hotkey(hotkey_id, text, width + _h, _h)
			if changed then
				inputModel:setKey(inputMode, virtualKey, j, device, device_id, key)
				if i + 1 <= #inputs then
					just.focus(inputIdPattern:format(i + 1, j))
				end
			end
			just.sameline()
			if _device and just.mouse_over(hotkey_id, false, "mouse") then
				self.game.gameView.tooltip = ("%s (%s)"):format(_device, _device_id)
			end
		end
		just.next()
	end

	if imgui.button("reset bindings", "reset") then
		inputModel:resetInputs(inputMode)
	end

	just.emptyline(8)

	scrollY = imgui.Container()
	just.pop()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
end)
