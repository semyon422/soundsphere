local Theme = require("aqua.ui.Theme")
local Observable = require("aqua.util.Observable")
local aquafonts = require("aqua.assets.fonts")
local spherefonts = require("sphere.assets.fonts")
local CoordinateManager = require("aqua.graphics.CoordinateManager")

local SearchLine = {}

SearchLine.observable = Observable:new()
SearchLine.searchString = ""
SearchLine.searchTable = {}
SearchLine.padding = 0.005

SearchLine.load = function(self)
	self.textInputFrame = self.textInputFrame or Theme.TextInputFrame:new({
		x1 = self.x1,
		y1 = self.y1,
		x2 = self.x2,
		y2 = self.y2,
		ry = self.ry,
		backgroundColor = {0, 0, 0, 255},
		borderColor = {255, 255, 255, 0},
		textColor = {255, 255, 255, 255},
		lineStyle = "smooth",
		lineWidth = 1.5,
		cs1 = self.cs1,
		cs2 = self.cs2,
		limit = 1,
		textAlign = {x = "left", y = "center"},
		xpadding = 0.02,
		text = "",
		font = self.font,
		enableStencil = true
	})
	
	self.textInputFrame:reload()
end

SearchLine.reload = function(self)
	self.textInputFrame:reload()
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
			self.searchTable = self.searchString:split(" ")
			self.observable:send({
				name = "search",
				text = newText
			})
		end
	end
end

SearchLine.draw = function(self)
	self.textInputFrame:draw()
end

SearchLine.getText = function(self)
	return self.textInputFrame.textInput.text
end

return SearchLine
