local TextFrame = require("aqua.graphics.TextFrame")
local CustomList = require("sphere.ui.CustomList")
local CustomListButton = CustomList.Button
local aquafonts = require("aqua.assets.fonts")
local spherefonts = require("sphere.assets.fonts")

local NoteChartListButton = CustomListButton:new()
	
NoteChartListButton.nameFont = aquafonts.getFont(spherefonts.NotoSansRegular, 24)
NoteChartListButton.difficultyFont = aquafonts.getFont(spherefonts.SourceCodeProBold, 30)
NoteChartListButton.scoreFont = aquafonts.getFont(spherefonts.SourceCodeProRegular, 28)

NoteChartListButton.nameTextAlign = {x = "left", y = "center"}
NoteChartListButton.difficultyTextAlign = {x = "right", y = "center"}
NoteChartListButton.scoreTextAlign = {x = "right", y = "center"}

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
	textFrame.w = self.w * 0.25
	textFrame.h = self.h
	textFrame.limit = self.w * 0.25
	textFrame.align = self.scoreTextAlign
	textFrame.xpadding = 0
	textFrame.text = "1000000"
	textFrame.font = self.scoreFont
	textFrame.color = self.textColor
	textFrame.cs = self.cs
	
	textFrame:reload()
	
	local textFrame = self.difficultyTextFrame
	
	textFrame.x = self.x + self.w * 0.25
	textFrame.y = self.y
	textFrame.w = self.w * 0.15
	textFrame.h = self.h
	textFrame.limit = self.w * 0.15
	textFrame.align = self.difficultyTextAlign
	textFrame.xpadding = self.xpadding
	textFrame.text = ("%.2f"):format(self.item.cacheData.noteCount / self.item.cacheData.length / 3)
	textFrame.font = self.difficultyFont
	textFrame.color = self.textColor
	textFrame.cs = self.cs
	
	textFrame:reload()
	
	local textFrame = self.nameTextFrame
	
	textFrame.x = self.x + self.w * 0.45
	textFrame.y = self.y
	textFrame.w = self.w * 0.55
	textFrame.h = self.h
	textFrame.limit = self.w * 0.55
	textFrame.align = self.nameTextAlign
	textFrame.xpadding = self.xpadding
	textFrame.text = self.item.cacheData.name or ""
	textFrame.font = self.nameFont
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
