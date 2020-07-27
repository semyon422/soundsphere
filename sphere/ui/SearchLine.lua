local Class					= require("aqua.util.Class")
local aquafonts				= require("aqua.assets.fonts")
local CoordinateManager		= require("aqua.graphics.CoordinateManager")
local Theme					= require("aqua.ui.Theme")
local Observable			= require("aqua.util.Observable")

local SearchLine = Class:new()

SearchLine.searchString = ""

local transparent = {0, 0, 0, 0}
local white = {255, 255, 255, 255}
SearchLine.loadGui = function(self)
	self.cs = CoordinateManager:getCS(unpack(self.data.cs))
	self.x = self.data.x
	self.y = self.data.y
	self.w = self.data.w
	self.h = self.data.h
	self.ry = self.data.ry
	self.layer = self.data.layer
	self.textAlign = self.data.textAlign
	self.text = self.data.text or ""
	self.textolor = self.data.textolor or white
	self.borderColor = self.data.borderColor or transparent
	self.backgroundColor = self.data.backgroundColor or transparent

	if self.data.font then
		self.font = aquafonts.getFont(self.data.font, self.data.fontSize)
	end

	self.interact = function()
		local sequence = self.data.interact
		if not sequence then return end
		for i = 1, #sequence do
			local f = self.gui.functions[sequence[i]]
			if f then f() end
		end
	end

	self.container = self.gui.container

	self:load()
end

SearchLine.load = function(self)
	self.observable = Observable:new()
	self.observable:add(require("sphere.screen.SelectScreen"))

	local NoteChartStateManager	= require("sphere.ui.NoteChartStateManager")
	self.searchString = NoteChartStateManager.searchString

	self.sender = self
	
	self.textInputFrame = Theme.TextInputFrame:new({
		x = self.x,
		y = self.y,
		w = self.w,
		h = self.h,
		ry = self.ry,
		backgroundColor = self.backgroundColor,
		borderColor = self.borderColor,
		textColor = self.textColor,
		lineStyle = "smooth",
		lineWidth = 1.5,
		cs = self.cs,
		limit = 1,
		textAlign = {x = "left", y = "center"},
		xpadding = 0.01,
		font = self.font,
		enableStencil = true,
		layer = self.layer
	})
	self.textInputFrame.textInput:setText(self.searchString)
	self.textInputFrame:reload()

	self.container:add(self.textInputFrame)
end

SearchLine.update = function(self) end

SearchLine.unload = function(self)
	self.observable:remove(require("sphere.screen.SelectScreen"))
	self.container:remove(self.textInputFrame)
end

SearchLine.reload = function(self)
	self:unload()
	self:load()
end

SearchLine.receive = function(self, event)
	local forceReload = false
	if event.name == "keypressed" and event.args[1] == "escape" then
		self.textInputFrame.textInput:reset()
		forceReload = true
	end
	
	if self.textInputFrame then
		local oldText = self:getText()
		self.textInputFrame:receive(event)
		local newText = self:getText()
		
		if oldText ~= newText or forceReload then
			self.searchString = newText:lower()
			self.observable:send({
				name = "search",
				text = newText,
				sender = self
			})
		end
	end
end

SearchLine.getText = function(self)
	return self.textInputFrame.textInput.text
end

return SearchLine
