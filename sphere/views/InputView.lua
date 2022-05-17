local bit = require("bit")
local ffi = require("ffi")
local imgui = require("cimgui")
local ImguiView = require("sphere.views.ImguiView")
local ImguiHotkey = require("aqua.imgui.Hotkey")
local align = require("aqua.imgui.config").align

local InputView = ImguiView:new()

local keyPtr = ffi.new("const char*[1]")
local devicePtr = ffi.new("const char*[1]")

InputView.draw = function(self)
	local noteChart = self.gameController.noteChartModel.noteChart
	if not noteChart then
		return
	end

	local inputModeString = noteChart.inputMode:getString()
	local items = self.gameController.inputModel:getInputs(inputModeString)

	if self.isOpen[0] then
		imgui.SetNextWindowPos({align(0.5, 279), 279}, 0)
		imgui.SetNextWindowSize({454, 522}, 0)
		local flags = imgui.love.WindowFlags("NoMove", "NoResize")
		if imgui.Begin("Input bindings", self.isOpen, flags) then
			for i = 1, #items do
				local virtualKey = items[i].virtualKey
				local key, device = self.gameController.inputModel:getKey(inputModeString, virtualKey)
				keyPtr[0] = tostring(key)
				devicePtr[0] = device
				if ImguiHotkey(virtualKey, keyPtr, devicePtr) then
					key = ffi.string(keyPtr[0])
					device = ffi.string(devicePtr[0])
					self.navigator:setInputBinding(inputModeString, virtualKey, key, device)
				end
			end
		end
		imgui.End()
	end
end

return InputView
