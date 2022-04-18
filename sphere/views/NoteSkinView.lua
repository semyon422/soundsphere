local bit = require("bit")
local imgui = require("cimgui")
local transform = require("aqua.graphics.transform")
local ImguiView = require("sphere.views.ImguiView")

local NoteSkinView = ImguiView:new()

local tfTable = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}
local tfOriginTable = {0, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}
NoteSkinView.draw = function(self)
	local noteChart = self.gameController.noteChartModel.noteChart
	if not noteChart then
		return
	end

	local items = self.gameController.noteSkinModel:getNoteSkins(noteChart.inputMode)
	local selectedNoteSkin = self.gameController.noteSkinModel:getNoteSkin(noteChart.inputMode)

	if self.isOpen[0] then
		local tf = transform(tfTable)
		imgui.SetNextWindowPos({tf:transformPoint(279, 279)}, 0)
		tf:release()
		tf = transform(tfOriginTable)
		imgui.SetNextWindowSize({tf:transformPoint(454, 522)}, 0)
		tf:release()
		local flags = bit.bor(imgui.ImGuiWindowFlags_NoMove, imgui.ImGuiWindowFlags_NoResize)
		if imgui.Begin("Noteskins", self.isOpen, flags) then
			if imgui.BeginListBox("Noteskins", {-imgui.FLT_MIN, -imgui.FLT_MIN}) then
				for i = 1, #items do
					local noteSkin = items[i]
					local isSelected = selectedNoteSkin == noteSkin
					if imgui.Selectable_Bool(noteSkin.name, isSelected) then
						self.navigator:setNoteSkin(i)
					end

					if isSelected then
						imgui.SetItemDefaultFocus()
					end
				end
				imgui.EndListBox()
			end
		end
		imgui.End()
	end
end

return NoteSkinView
