local Class = require("aqua.util.Class")
local CS = require("aqua.graphics.CS")
local TextFrame = require("aqua.graphics.TextFrame")

local aquafonts = require("aqua.assets.fonts")
local spherefonts = require("sphere.assets.fonts")

local MetaDataTable = {}

MetaDataTable.x = 0.05
MetaDataTable.y = 0.05
MetaDataTable.w = 1
MetaDataTable.h = 1

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
		self.nameText.text = self.nameText.text .. " by " .. self.data.creator
	end
end

MetaDataTable.init = function(self)
	self.artistText = TextFrame:new({
		text = "",
		x = self.x,
		y = self.y,
		w = self.w - 2 * self.x,
		h = self.h,
		h = self.h,
		cs = self.cs,
		limit = self.w - 2 * self.x,
		align = {x = "left", y = "top"},
		color = {255, 255, 255, 255},
		font = aquafonts.getFont(spherefonts.NotoSansRegular, 24)
	})
	
	self.titleText = TextFrame:new({
		text = "",
		x = self.x,
		y = self.y + 0.05,
		w = self.w- 2 * self.x,
		h = self.h,
		cs = self.cs,
		limit = self.w - 2 * self.x,
		align = {x = "left", y = "top"},
		color = {255, 255, 255, 255},
		font = aquafonts.getFont(spherefonts.NotoSansRegular, 28)
	})
	
	self.nameText = TextFrame:new({
		text = "",
		x = self.x,
		y = self.y + 0.1,
		w = self.w - 2 * self.x,
		h = self.h,
		cs = self.cs,
		limit = self.w - 2 * self.x,
		align = {x = "left", y = "top"},
		color = {255, 255, 255, 255},
		font = aquafonts.getFont(spherefonts.NotoSansRegular, 22)
	})
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

MetaDataTable:init()
MetaDataTable:reload()

return MetaDataTable
