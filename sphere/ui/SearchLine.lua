local Theme = require("aqua.ui.Theme")
local Observable = require("aqua.util.Observable")
local aquafonts = require("aqua.assets.fonts")
local spherefonts = require("sphere.assets.fonts")
local CoordinateManager = require("aqua.graphics.CoordinateManager")

local SearchLine = {}

SearchLine.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")

SearchLine.observable = Observable:new()
SearchLine.searchString = ""
SearchLine.searchTable = {}


SearchLine.load = function(self)
	self.textInputFrame = self.textInputFrame or Theme.TextInputFrame:new({
		x = self.x,
		y = self.y,
		w = self.w,
		h = self.h,
		ry = self.h / 2,
		backgroundColor = {0, 0, 0, 63},
		borderColor = {255, 255, 255, 255},
		textColor = {255, 255, 255, 255},
		lineStyle = "smooth",
		lineWidth = 1.5,
		cs = self.cs,
		limit = 1,
		textAlign = {x = "left", y = "center"},
		xpadding = 0.01,
		text = "",
		font = aquafonts.getFont(spherefonts.NotoSansRegular, 26),
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
