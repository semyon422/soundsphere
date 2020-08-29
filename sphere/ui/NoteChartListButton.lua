local aquafonts			= require("aqua.assets.fonts")
local TextFrame			= require("aqua.graphics.TextFrame")
local spherefonts		= require("sphere.assets.fonts")
local ScoreManager		= require("sphere.database.ScoreManager")
local CustomList		= require("sphere.ui.CustomList")
local AliasManager		= require("sphere.database.AliasManager")

local NoteChartListButton = CustomList.Button:new()

NoteChartListButton.nameTextAlign = {x = "left", y = "center"}
NoteChartListButton.difficultyTextAlign = {x = "right", y = "bottom"}
NoteChartListButton.inputModeTextAlign = {x = "left", y = "top"}

NoteChartListButton.columnX = {0, 0.4}
NoteChartListButton.columnWidth = {0.38, 0.6}

NoteChartListButton.construct = function(self)
	self.nameFont = aquafonts.getFont(spherefonts.NotoSansRegular, 24)
	self.difficultyFont = aquafonts.getFont(spherefonts.SourceCodeProBold, 18)
	self.inputModeFont = aquafonts.getFont(spherefonts.SourceCodeProRegular, 18)
	
	self.nameTextFrame = TextFrame:new()
	self.difficultyTextFrame = TextFrame:new()
	self.inputModeTextFrame = TextFrame:new()
	
	CustomList.Button.construct(self)
end

NoteChartListButton.reloadTextFrame = function(self)
	local textFrame = self.inputModeTextFrame
	
	textFrame.x = self.x + self.w * self.columnX[1]
	textFrame.y = self.y
	textFrame.w = self.w * self.columnWidth[1]
	textFrame.h = self.h
	textFrame.limit = self.w * self.columnWidth[1]
	textFrame.align = self.inputModeTextAlign
	textFrame.text = AliasManager:getAlias("inputMode", self.item.noteChartDataEntry.inputMode)
	textFrame.font = self.inputModeFont
	textFrame.color = self.textColor
	textFrame.cs = self.cs
	
	textFrame:reload()
	
	local textFrame = self.difficultyTextFrame
	
	textFrame.x = self.x + self.w * self.columnX[1]
	textFrame.y = self.y
	textFrame.w = self.w * self.columnWidth[1]
	textFrame.h = self.h
	textFrame.limit = self.w * self.columnWidth[1]
	textFrame.align = self.difficultyTextAlign
	textFrame.text = ("%.2f"):format(self.item.noteChartDataEntry.noteCount / self.item.noteChartDataEntry.length / 3)
	textFrame.font = self.difficultyFont
	textFrame.color = self.textColor
	textFrame.cs = self.cs
	
	textFrame:reload()
	
	local textFrame = self.nameTextFrame
	
	textFrame.x = self.x + self.w * self.columnX[2]
	textFrame.y = self.y
	textFrame.w = self.w * self.columnWidth[2]
	textFrame.h = self.h
	textFrame.limit = math.huge
	textFrame.align = self.nameTextAlign
	textFrame.text = self.item.noteChartDataEntry.name or ""
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
	self.difficultyTextFrame:draw()
	self.nameTextFrame:draw()
	self.inputModeTextFrame:draw()
	if self.enableStencil then
		self.stencil:set()
	end
	self.border:draw()
end

return NoteChartListButton
