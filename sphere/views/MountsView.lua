local imgui = require("cimgui")
local ImguiView = require("sphere.views.ImguiView")
local align = require("aqua.imgui.config").align

local MountsView = ImguiView:new({construct = false})

local selectedItem
MountsView.draw = function(self)
	local mountModel = self.gameController.mountModel
	local items = self.gameController.configModel.configs.mount
	selectedItem = selectedItem or items[1]

	if not self.isOpen[0] then
		return
	end
	self:closeOnEscape()

	imgui.SetNextWindowPos({align(0.5, 279 + 454 * 3 / 4), 279}, 0)
	imgui.SetNextWindowSize({454 * 1.5, 522}, 0)
	local flags = imgui.love.WindowFlags("NoMove", "NoResize")
	if imgui.Begin("Mounted directories", self.isOpen, flags) then
		local avail = imgui.GetContentRegionAvail()
		if imgui.BeginChild_Str("Mount points child window", {0, avail.y / 3}, false, 0) then
			if imgui.BeginListBox("##Mount points", {-imgui.FLT_MIN, -imgui.FLT_MIN}) then
				for i = 1, #items do
					local item = items[i]
					local isSelected = selectedItem == item
					if imgui.Selectable_Bool(item[2], isSelected) then
						selectedItem = item
					end

					if isSelected then
						imgui.SetItemDefaultFocus()
					end
				end
				imgui.EndListBox()
			end
		end
		imgui.EndChild()
		if selectedItem then
			if imgui.BeginChild_Str("Mount point child window", {0, 0}, false, 0) then
				imgui.Text("Status: " .. (mountModel.mountStatuses[selectedItem[1]] or "unknown"))
				imgui.Text("Real path: ")
				imgui.TextWrapped(selectedItem[1])
				if imgui.Button("Open") then
					love.system.openURL(selectedItem[1])
				end
				if imgui.Button("Remove") then
					for i = 1, #items do
						if items[i] == selectedItem then
							table.remove(items, i)
							selectedItem = nil
							break
						end
					end
				end
			end
			imgui.EndChild()
		end
	end
	imgui.End()
end

return MountsView
