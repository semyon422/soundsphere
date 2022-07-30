local bit = require("bit")
local ffi = require("ffi")
local imgui = require("cimgui")
local ImguiView = require("sphere.views.ImguiView")
local ImguiHotkey = require("aqua.imgui.Hotkey")
local align = require("aqua.imgui.config").align

local InputView = ImguiView:new()

local keyPtr = ffi.new("const char*[1]")
local devicePtr = ffi.new("const char*[1]")

InputView.toggle = function(self, state)
	ImguiView.toggle(self, state)
	if self.isOpen[0] then
		self.game.selectController:resetModifiedNoteChart()
	end
end

InputView.draw = function(self)
	local noteChart = self.game.noteChartModel.noteChart
	if not noteChart then
		return
	end

	local inputModeString = noteChart.inputMode:getString()
	local items = self.game.inputModel:getInputs(inputModeString)

	if not self.isOpen[0] then
		return
	end

	local closed = self:closeOnEscape()
	if closed then
		return
	end

	imgui.SetNextWindowPos({align(0.5, 279), 279}, 0)
	imgui.SetNextWindowSize({454, 522}, 0)
	local flags = imgui.love.WindowFlags("NoMove", "NoResize")
	if imgui.Begin("Input bindings", self.isOpen, flags) then
		for i = 1, #items do
			local virtualKey = items[i].virtualKey
			local key, device = self.game.inputModel:getKey(inputModeString, virtualKey)
			keyPtr[0] = tostring(key)
			devicePtr[0] = device
			if ImguiHotkey(virtualKey, keyPtr, devicePtr) then
				key = ffi.string(keyPtr[0])
				device = ffi.string(devicePtr[0])
				self.game.inputModel:setKey(inputModeString, virtualKey, key, device)
			end
		end
		imgui.CaptureKeyboardFromApp(true)
	end
	imgui.End()
end

return InputView
