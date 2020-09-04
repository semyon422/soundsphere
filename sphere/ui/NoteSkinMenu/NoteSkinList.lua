local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local CustomList		= require("sphere.ui.CustomList")
-- local NoteSkinManager	= require("sphere.noteskin.NoteSkinManager")
local NoteChartList  	= require("sphere.ui.NoteChartList")

local NoteSkinList = CustomList:new()

NoteSkinList.x = 0
NoteSkinList.y = 0
NoteSkinList.w = 1
NoteSkinList.h = 1

NoteSkinList.textAlign = {x = "center", y = "center"}

NoteSkinList.sender = "NoteSkinList"
NoteSkinList.needFocusToInteract = false

NoteSkinList.buttonCount = 17
NoteSkinList.middleOffset = 9
NoteSkinList.startOffset = 9
NoteSkinList.endOffset = 9

NoteSkinList.init = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0.5, 0.5, 0.5, "min")
end

NoteSkinList.load = function(self)
	-- NoteSkinManager:load()
	self:addItems()
	self:reload()
end

NoteSkinList.send = function(self, event)
	if event.action == "buttonInteract" and event.button == 1 then
		local metaData = self.items[event.itemIndex].metaData
		self.menu.observable:send({
			name = "setNoteSkin",
			inputMode = self:getSelectedInputMode(),
			metaData = metaData
		})
		self:addItems()
	end

	CustomList.send(self, event)
end

NoteSkinList.getSelectedInputMode = function(self)
	local noteChart = self.menu.noteChart

	if not noteChart then
		return ""
	end

	return noteChart.inputMode:getString()
end

NoteSkinList.addItems = function(self)
	local items = {}

	if not self.menu.noteChart then
		return self:setItems(items)
	end

	local noteSkinModel = self.menu.noteSkinModel

	local list = noteSkinModel:getNoteSkins(self.menu.noteChart.inputMode)
	local selectedNoteSkin = noteSkinModel:getNoteSkin(self.menu.noteChart.inputMode)

	for _, noteSkin in ipairs(list) do
		local name = noteSkin.name
		if name == selectedNoteSkin.name then
			name = "★ " .. name
		end
		items[#items + 1] = {
			metaData = noteSkin,
			name = name
		}
	end

	return self:setItems(items)
end

return NoteSkinList
