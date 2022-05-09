local bit = require("bit")
local ffi = require("ffi")
local imgui = require("cimgui")
local transform = require("aqua.graphics.transform")
local ImguiView = require("sphere.views.ImguiView")
local ImguiHotkey = require("aqua.imgui.Hotkey")

local ImguiElements = {
	Checkbox = require("sphere.imgui.Checkbox"),
	SliderFloat = require("sphere.imgui.SliderFloat"),
	SliderInt = require("sphere.imgui.SliderInt"),
	InputFloat = require("sphere.imgui.InputFloat"),
	InputInt = require("sphere.imgui.InputInt"),
	Hotkey = require("sphere.imgui.Hotkey"),
	Combo = require("sphere.imgui.Combo"),
}

local SettingsView = ImguiView:new({construct = false})

SettingsView.draw = function(self)
	local config = self.gameController.configModel.configs.settings
	local settings_model = self.gameController.configModel.configs.settings_model

	if self.isOpen[0] then
		imgui.SetNextWindowPos({279 + 454 * 3 / 4, 279}, 0)
		imgui.SetNextWindowSize({454 * 1.5, 522}, 0)
		local flags = bit.bor(imgui.ImGuiWindowFlags_NoMove, imgui.ImGuiWindowFlags_NoResize)
		if imgui.Begin("Game settings", self.isOpen, flags) then
			if imgui.BeginTabBar("Section tab bar", 0) then
				local sections = {}
				local section
				for _, item in ipairs(settings_model) do
					if item.section ~= section then
						section = item.section
						table.insert(sections, section)
					end
				end
				for _, section in ipairs(sections) do
					if imgui.BeginTabItem(section) then
						for _, item in ipairs(settings_model) do
							if item.section == section and ImguiElements[item.type] then
								ImguiElements[item.type](item, config)
							end
						end
						imgui.EndTabItem()
					end
				end
                imgui.EndTabBar()
            end
		end
		imgui.End()
	end
end

return SettingsView
