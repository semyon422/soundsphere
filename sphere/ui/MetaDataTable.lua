local CoordinateManager = require("aqua.graphics.CoordinateManager")
local TextFrame = require("aqua.graphics.TextFrame")
local Rectangle = require("aqua.graphics.Rectangle")
local aquafonts = require("aqua.assets.fonts")
local spherefonts = require("sphere.assets.fonts")

local MetaDataTable = {}

MetaDataTable.setData = function(self, data)
	self.data = data or {}
	self:updateValues()
	self:reload()
end

MetaDataTable.updateValues = function(self)
	self.artistText.text = self.data.artist or ""
	self.titleText.text = self.data.title or ""
	self.nameText.text = self.data.name or ""
	
	if self.data.creator then
		self.nameText.text = self.data.creator
	end
end

MetaDataTable.load = function(self)
	self.background = Rectangle:new({
		x1 = self.x1 - 1/10,
		y1 = self.y1,
		x2 = self.x2,
		y2 = self.y2,
		cs1 = self.cs1,
		cs2 = self.cs2,
		ry = 27/1080,
		color = {0, 0, 0, 191},
		mode = "fill"
	})
	self.background:reload()
	
	self.frame = Rectangle:new({
		x1 = self.x1 - 1/10,
		y1 = self.y1,
		x2 = self.x2,
		y2 = self.y2,
		cs1 = self.cs1,
		cs2 = self.cs2,
		ry = 27/1080,
		color = {101, 202, 252, 255},
		lineWidth = 2,
		mode = "line"
	})
	self.frame:reload()
	
	self.artistText = self.artistText or TextFrame:new({
		text = "",
		x1 = self.x1 + 30/1080,
		y1 = self.y1 + 70/1080,
		x2 = self.x2 - 30/1080,
		y2 = self.y2,
		cs1 = self.cs1,
		cs2 = self.cs2,
		align = {x = "left", y = "top"},
		color = {255, 255, 255, 255},
		font = aquafonts.getFont(spherefonts.NotoSansRegular, 18)
	})
	
	self.titleText = self.titleText or TextFrame:new({
		text = "",
		x1 = self.x1 + 30/1080,
		y1 = self.y1 + 18/1080,
		x2 = self.x2 - 30/1080,
		y2 = self.y2,
		cs1 = self.cs1,
		cs2 = self.cs2,
		align = {x = "left", y = "top"},
		color = {255, 255, 255, 255},
		font = aquafonts.getFont(spherefonts.NotoSansRegular, 24)
	})
	
	self.nameText = self.nameText or TextFrame:new({
		text = "",
		x1 = self.x1 + 30/1080,
		y1 = self.y1 + 70/1080,
		x2 = self.x2 - 30/1080,
		y2 = self.y2 - (self.y2 - self.y1) / 2,
		cs1 = self.cs1,
		cs2 = self.cs2,
		align = {x = "right", y = "top"},
		color = {255, 255, 255, 255},
		font = aquafonts.getFont(spherefonts.NotoSansRegular, 18)
	})
	
	self:reload()
end

MetaDataTable.reload = function(self)
	self.background:reload()
	self.artistText:reload()
	self.titleText:reload()
	self.nameText:reload()
	self.frame:reload()
end

MetaDataTable.draw = function(self)
	self.background:draw()
	self.artistText:draw()
	self.titleText:draw()
	self.nameText:draw()
	self.frame:draw()
end

return MetaDataTable
