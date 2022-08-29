local ffi = require("ffi")
local imgui = require("cimgui")
local align = require("aqua.imgui.config").align
local ModalImView = require("sphere.imviews.ModalImView")

local isOpen = ffi.new("bool[1]", true)
local function draw(self)
	if not isOpen[0] then
		isOpen[0] = true
		return true
	end

	local noteChart = self.game.noteChartModel.noteChart
	local selectedNoteSkin = self.game.noteSkinModel:getNoteSkin(noteChart.inputMode)

	local items = self.game.noteSkinModel:getNoteSkins(noteChart.inputMode)

	imgui.SetNextWindowPos({align(0.5, 279), 279}, 0)
	imgui.SetNextWindowSize({454, 522}, 0)
	local flags = imgui.love.WindowFlags("NoMove", "NoResize")
	if imgui.Begin("Noteskins", isOpen, flags) then
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

local function close(self)
	local noteChart = self.game.noteChartModel.noteChart
	local selectedNoteSkin = self.game.noteSkinModel:getNoteSkin(noteChart.inputMode)

	if selectedNoteSkin.config then
		selectedNoteSkin.config:close()
	end
end

return ModalImView(draw, close)
