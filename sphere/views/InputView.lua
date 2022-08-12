local just = require("just")
local LabelImView = require("sphere.views.LabelImView")
local HotkeyImView = require("sphere.views.HotkeyImView")
local TextButtonImView = require("sphere.views.TextButtonImView")
local Class = require("aqua.util.Class")
local _transform = require("aqua.graphics.transform")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local InputView = Class:new()

InputView.isOpen = false
InputView.device = "keyboard"

InputView.toggle = function(self, state)
	if state == nil then
		self.isOpen = not self.isOpen
	else
		self.isOpen = state
	end
	if self.isOpen then
		self.game.selectController:resetModifiedNoteChart()
	end
end

InputView.draw = function(self)
	local noteChart = self.game.noteChartModel.noteChart
	if not noteChart then
		return
	end

	if not self.isOpen then
		return
	end

	local inputMode = noteChart.inputMode:getString()
	local inputs = self.game.inputModel:getInputs(inputMode)
	local devices = self.game.inputModel.devices

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate(279 + 454 * 3 / 4, 1080 / 4)
	local w, h = 454 * 1.5, 1080 / 2
	local r = 8

	love.graphics.push()

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)

	just.catch(just.focused_id)

	just.clip(love.graphics.rectangle, "fill", 0, 0, w, h, r)
	just.container("ContextMenuImView", just.is_over(w, h))

	local inputHeight = 55

	local scroll = just.wheel_over(self, just.is_over(w, h))

	self.scroll = self.scroll or 0
	love.graphics.translate(0, -self.scroll)

	local startHeight = just.height

	just.row(true)
	for _, device in ipairs(devices) do
		if device == self.device then
			love.graphics.setColor(1, 1, 1, 0.1)
			love.graphics.rectangle("fill", 0, 0, w / #devices, inputHeight)
		end
		love.graphics.setColor(1, 1, 1, 1)
		if TextButtonImView("InputView " .. device, device, w / #devices, inputHeight) then
			self.device = device
		end
	end
	just.row(false)
	love.graphics.line(0, 0, w, 0)

	love.graphics.translate(r, 0)
	just.emptyline(r)

	for i = 1, #inputs do
		local virtualKey = inputs[i]
		local key = self.game.inputModel:getKey(inputMode, virtualKey, self.device)
		local changed, key = HotkeyImView(i, self.device, key, w / 2, inputHeight)
		if changed then
			self.game.inputModel:setKey(inputMode, virtualKey, self.device, key)
			if i + 1 <= #inputs then
				just.focus(i + 1)
			end
		end
		just.sameline()
		just.indent(r)
		LabelImView(i, virtualKey, inputHeight)
		just.emptyline(r)
	end

	just.container()
	just.clip()

	if just.keypressed("escape") and not just.catch() then
		self:toggle(false)
	end

	local overlap = math.max(just.height - startHeight - h, 0)
	if overlap > 0 and scroll then
		self.scroll = math.min(math.max(self.scroll - scroll * 50, 0), overlap)
	end

	love.graphics.pop()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
end

return InputView
