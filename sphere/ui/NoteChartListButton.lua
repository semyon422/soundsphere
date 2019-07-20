local TextFrame = require("aqua.graphics.TextFrame")
local CustomList = require("sphere.ui.CustomList")
local CustomListButton = CustomList.Button
local aquafonts = require("aqua.assets.fonts")
local spherefonts = require("sphere.assets.fonts")
local ScoreManager = require("sphere.game.ScoreManager")

local NoteChartListButton = CustomListButton:new()
	
NoteChartListButton.nameFont = aquafonts.getFont(spherefonts.NotoSansRegular, 24)
NoteChartListButton.difficultyFont = aquafonts.getFont(spherefonts.SourceCodeProBold, 30)
NoteChartListButton.scoreFont = aquafonts.getFont(spherefonts.SourceCodeProRegular, 28)
NoteChartListButton.inputModeFont = aquafonts.getFont(spherefonts.SourceCodeProRegular, 24)

NoteChartListButton.nameTextAlign = {x = "left", y = "center"}
NoteChartListButton.difficultyTextAlign = {x = "right", y = "center"}
NoteChartListButton.scoreTextAlign = {x = "right", y = "center"}
NoteChartListButton.inputModeTextAlign = {x = "left", y = "center"}

NoteChartListButton.columnX = {0.05, 0.3, 0.45, 0.6}
NoteChartListButton.columnWidth = {0.25, 0.15, 0.14, 0.4}

NoteChartListButton.construct = function(self)
	self.nameTextFrame = TextFrame:new()
	self.difficultyTextFrame = TextFrame:new()
	self.scoreTextFrame = TextFrame:new()
	self.inputModeTextFrame = TextFrame:new()
	
	CustomListButton.construct(self)
end

NoteChartListButton.reloadTextFrame = function(self)
	local textFrame = self.inputModeTextFrame
	
	textFrame.x = self.x + self.w * self.columnX[1]
	textFrame.y = self.y
	textFrame.w = self.w * self.columnWidth[1]
	textFrame.h = self.h
	textFrame.limit = self.w * self.columnWidth[1]
	textFrame.align = self.inputModeTextAlign
	textFrame.xpadding = 0
	textFrame.text = self.item.cacheData.inputMode
	textFrame.font = self.inputModeFont
	textFrame.color = self.textColor
	textFrame.cs = self.cs
	
	textFrame:reload()
	
	local textFrame = self.scoreTextFrame
	
	local scores = ScoreManager.scoresByHash[self.item.cacheData.hash]
	local score = scores and scores[1] and scores[1].score or 0
	
	textFrame.x = self.x + self.w * self.columnX[2]
	textFrame.y = self.y
	textFrame.w = self.w * self.columnWidth[2]
	textFrame.h = self.h
	textFrame.limit = self.w * self.columnWidth[2]
	textFrame.align = self.scoreTextAlign
	textFrame.xpadding = 0
	textFrame.text = ("%7d"):format(score)
	textFrame.font = self.scoreFont
	textFrame.color = self.textColor
	textFrame.cs = self.cs
	
	textFrame:reload()
	
	local textFrame = self.difficultyTextFrame
	
	textFrame.x = self.x + self.w * self.columnX[3]
	textFrame.y = self.y
	textFrame.w = self.w * self.columnWidth[3]
	textFrame.h = self.h
	textFrame.limit = self.w * self.columnWidth[3]
	textFrame.align = self.difficultyTextAlign
	textFrame.xpadding = 0
	textFrame.text = ("%.2f"):format(self.item.cacheData.noteCount / self.item.cacheData.length / 3)
	textFrame.font = self.difficultyFont
	textFrame.color = self.textColor
	textFrame.cs = self.cs
	
	textFrame:reload()
	
	local textFrame = self.nameTextFrame
	
	textFrame.x = self.x + self.w * self.columnX[4]
	textFrame.y = self.y
	textFrame.w = self.w * self.columnWidth[4]
	textFrame.h = self.h
	textFrame.limit = self.w * self.columnWidth[4]
	textFrame.align = self.nameTextAlign
	textFrame.xpadding = 0
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
	self.inputModeTextFrame:draw()
	if self.enableStencil then
		self.stencil:set()
	end
	self.border:draw()
end

return NoteChartListButton
