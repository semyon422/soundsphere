local aquafonts			= require("aqua.assets.fonts")
local TextFrame			= require("aqua.graphics.TextFrame")
local spherefonts		= require("sphere.assets.fonts")
local CustomList		= require("sphere.ui.CustomList")

local ScoreListButton = CustomList.Button:new()

ScoreListButton.scoreTextAlign = {x = "right", y = "top"}
ScoreListButton.dateTextAlign = {x = "right", y = "center"}
ScoreListButton.modifiersTextAlign = {x = "right", y = "bottom"}

ScoreListButton.columnX = {0, 0.5}
ScoreListButton.columnWidth = {0.5, 0.45}

ScoreListButton.construct = function(self)
	self.scoreFont = aquafonts.getFont(spherefonts.SourceCodeProRegular, 18)
	self.dateFont = aquafonts.getFont(spherefonts.SourceCodeProRegular, 14)
	self.modifiersFont = aquafonts.getFont(spherefonts.SourceCodeProRegular, 12)
	
	self.scoreTextFrame = TextFrame:new()
	self.dateTextFrame = TextFrame:new()
	self.modifiersTextFrame = TextFrame:new()
	
	CustomList.Button.construct(self)
end

ScoreListButton.reloadTextFrame = function(self)
	local textFrame = self.dateTextFrame
	
	textFrame.x = self.x + self.w * self.columnX[1]
	textFrame.y = self.y
	textFrame.w = self.w * self.columnWidth[1]
	textFrame.h = self.h
	textFrame.limit = self.w * self.columnWidth[1]
	textFrame.align = self.dateTextAlign
	textFrame.text = os.date("%H:%M:%S %d.%m.%y", self.item.scoreEntry.time)
	textFrame.font = self.dateFont
	textFrame.color = self.textColor
	textFrame.cs = self.cs
	
	textFrame:reload()
	
	local textFrame = self.scoreTextFrame
	
	textFrame.x = self.x + self.w * self.columnX[2]
	textFrame.y = self.y
	textFrame.w = self.w * self.columnWidth[2]
	textFrame.h = self.h
	textFrame.limit = self.w * self.columnWidth[2]
	textFrame.align = self.scoreTextAlign
	textFrame.text = math.ceil(self.item.scoreEntry.score)
	textFrame.font = self.scoreFont
	textFrame.color = self.textColor
	textFrame.cs = self.cs
	
	textFrame:reload()
	
	local textFrame = self.modifiersTextFrame
	
	textFrame.x = self.x + self.w * self.columnX[2]
	textFrame.y = self.y
	textFrame.w = self.w * self.columnWidth[2]
	textFrame.h = self.h
	textFrame.limit = self.w * self.columnWidth[2]
	textFrame.align = self.modifiersTextAlign
	textFrame.text = self.item.scoreEntry.modifiers
	textFrame.font = self.modifiersFont
	textFrame.color = self.textColor
	textFrame.cs = self.cs
	
	textFrame:reload()
end

ScoreListButton.draw = function(self)
	if self.enableStencil then
		self.stencil:draw()
		self.stencil:set("greater", 0)
	end
	self.background:draw()
	self.dateTextFrame:draw()
	self.scoreTextFrame:draw()
	self.modifiersTextFrame:draw()
	if self.enableStencil then
		self.stencil:set()
	end
	self.border:draw()
end

return ScoreListButton
