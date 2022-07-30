local bit = require("bit")
local imgui = require("cimgui")
local ImguiView = require("sphere.views.ImguiView")
local align = require("aqua.imgui.config").align

local NoteSkinView = ImguiView:new()

NoteSkinView.toggle = function(self, state)
	ImguiView.toggle(self, state)
	if self.isOpen[0] then
		self.game.selectController:resetModifiedNoteChart()
	end
end

NoteSkinView.draw = function(self)
	local noteChart = self.game.noteChartModel.noteChart
	if not noteChart then
		return
	end

	if not self.isOpen[0] then
		return
	end
	local closed = self:closeOnEscape()

	local selectedNoteSkin = self.game.noteSkinModel:getNoteSkin(noteChart.inputMode)

	if closed then
		if selectedNoteSkin.config then
			selectedNoteSkin.config:close()
		end
		return
	end

	local items = self.game.noteSkinModel:getNoteSkins(noteChart.inputMode)

	imgui.SetNextWindowPos({align(0.5, 279), 279}, 0)
	imgui.SetNextWindowSize({454, 522}, 0)
	local flags = imgui.love.WindowFlags("NoMove", "NoResize")
	if imgui.Begin("Noteskins", self.isOpen, flags) then
		if imgui.BeginListBox("Noteskins", {-imgui.FLT_MIN, -imgui.FLT_MIN}) then
			for i = 1, #items do
				local noteSkin = items[i]
				local isSelected = selectedNoteSkin == noteSkin
				if imgui.Selectable_Bool(noteSkin.name, isSelected) then
					self.game.noteSkinModel:setDefaultNoteSkin(items[i])
				end

				if isSelected then
					imgui.SetItemDefaultFocus()
				end
			end
			imgui.EndListBox()
		end
	end
	imgui.End()
	if not selectedNoteSkin.config then
		return
	end

	imgui.SetNextWindowPos({align(0.5, 733), 279}, 0)
	imgui.SetNextWindowSize({454, 522}, 0)
	if imgui.Begin("Noteskin config", nil, flags) then
		selectedNoteSkin.config:render()
	end
	imgui.End()
end

return NoteSkinView
