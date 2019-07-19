local CS = require("aqua.graphics.CS")
local TextFrame = require("aqua.graphics.TextFrame")
local aquafonts = require("aqua.assets.fonts")
local spherefonts = require("sphere.assets.fonts")

local MetaDataTable = {}

MetaDataTable.cs = CS:new({
	bx = 0,
	by = 0,
	rx = 0,
	ry = 0,
	binding = "all",
	baseOne = 768
})

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
		self.nameText.text = "Chartset by " .. self.data.creator
	end
end

MetaDataTable.load = function(self)
	self.artistText = self.artistText or TextFrame:new({
		text = "",
		x = self.x,
		y = self.y,
		w = self.w - 2 * self.x,
		h = self.h,
		h = self.h,
		cs = self.cs,
		limit = self.w - 2 * self.x,
		align = {x = "left", y = "top"},
		xpadding = 0,
		color = {255, 255, 255, 255},
		font = aquafonts.getFont(spherefonts.NotoSansRegular, 22)
	})
	
	self.titleText = self.titleText or TextFrame:new({
		text = "",
		x = self.x,
		y = self.y + 0.045,
		w = self.w- 2 * self.x,
		h = self.h,
		cs = self.cs,
		limit = self.w - 2 * self.x,
		align = {x = "left", y = "top"},
		xpadding = 0,
		color = {255, 255, 255, 255},
		font = aquafonts.getFont(spherefonts.NotoSansRegular, 28)
	})
	
	self.nameText = self.nameText or TextFrame:new({
		text = "",
		x = self.x,
		y = self.y + 0.1,
		w = self.w - 2 * self.x,
		h = self.h,
		cs = self.cs,
		limit = self.w - 2 * self.x,
		align = {x = "left", y = "top"},
		xpadding = 0,
		color = {255, 255, 255, 255},
		font = aquafonts.getFont(spherefonts.NotoSansRegular, 22)
	})
	
	self:reload()
end

MetaDataTable.reload = function(self)
	self.cs:reload()
	self.artistText:reload()
	self.titleText:reload()
	self.nameText:reload()
end

MetaDataTable.draw = function(self)
	self.artistText:draw()
	self.titleText:draw()
	self.nameText:draw()
end

return MetaDataTable
