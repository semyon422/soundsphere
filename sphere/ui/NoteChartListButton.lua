local TextFrame = require("aqua.graphics.TextFrame")
local CustomList = require("sphere.ui.CustomList")
local CustomListButton = CustomList.Button

local NoteChartListButton = CustomListButton:new()

NoteChartListButton.construct = function(self)
	self.nameTextFrame = TextFrame:new()
	self.difficultyTextFrame = TextFrame:new()
	self.scoreTextFrame = TextFrame:new()
	CustomListButton.construct(self)
end

NoteChartListButton.reloadTextFrame = function(self)
	local textFrame = self.scoreTextFrame
	
	textFrame.x = self.x
	textFrame.y = self.y
	textFrame.w = self.w / 4
	textFrame.h = self.h
	textFrame.limit = self.limit / 4
	textFrame.align = self.textAlign
	textFrame.xpadding = self.xpadding
	textFrame.text = ""
	textFrame.font = self.font
	textFrame.color = self.textColor
	textFrame.cs = self.cs
	
	textFrame:reload()
	
	local textFrame = self.difficultyTextFrame
	
	textFrame.x = self.x + self.w / 4
	textFrame.y = self.y
	textFrame.w = self.w / 8
	textFrame.h = self.h
	textFrame.limit = self.limit / 8
	textFrame.align = self.textAlign
	textFrame.xpadding = self.xpadding
	textFrame.text = ("%.2f"):format(self.item.cacheData.noteCount / self.item.cacheData.length / 3)
	textFrame.font = self.font
	textFrame.color = self.textColor
	textFrame.cs = self.cs
	
	textFrame:reload()
	
	local textFrame = self.nameTextFrame
	
	textFrame.x = self.x + self.w * 3 / 8
	textFrame.y = self.y
	textFrame.w = self.w * 5 / 8
	textFrame.h = self.h
	textFrame.limit = self.limit * 5 / 8
	textFrame.align = self.textAlign
	textFrame.xpadding = self.xpadding
	textFrame.text = self.item.cacheData.name
	textFrame.font = self.font
	textFrame.color = self.textColor
	textFrame.cs = self.cs
	
	textFrame:reload()
end

NoteChartListButton.draw = function(self)
	if self.enableStencil then
		self.stencil:draw()
		self.stencil:set("greater", 0)
	end
	self.background:draw()
	self.scoreTextFrame:draw()
	self.difficultyTextFrame:draw()
	self.nameTextFrame:draw()
	if self.enableStencil then
		self.stencil:set()
	end
	self.border:draw()
end

return NoteChartListButton
