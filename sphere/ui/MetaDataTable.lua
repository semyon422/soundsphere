local Class = require("aqua.util.Class")
local TextFrame = require("aqua.graphics.TextFrame")

local aquafonts = require("aqua.assets.fonts")
local spherefonts = require("sphere.assets.fonts")

local MetaDataTable = Class:new()

MetaDataTable.x = 0.05
MetaDataTable.y = 0.05
MetaDataTable.w = 1
MetaDataTable.h = 1

MetaDataTable.load = function(self)
	self.artistText = TextFrame:new({
		text = self.data.artist,
		x = self.x,
		y = self.y,
		w = self.w - 2 * self.x,
		h = self.h / 6,
		cs = self.cs,
		limit = self.w - 2 * self.x,
		align = {x = "right", y = "top"},
		color = {255, 255, 255, 255},
		font = aquafonts.getFont(spherefonts.NotoSansRegular, 24)
	})
	self.artistText:reload()
	
	self.titleText = TextFrame:new({
		text = self.data.title,
		x = self.x,
		y = self.y + 0.05,
		w = self.w- 2 * self.x,
		h = self.h / 6,
		cs = self.cs,
		limit = self.w - 2 * self.x,
		align = {x = "right", y = "top"},
		color = {255, 255, 255, 255},
		font = aquafonts.getFont(spherefonts.NotoSansRegular, 28)
	})
	self.titleText:reload()
	
	-- self.nameText = TextFrame:new({
		-- text = self.data.name .. " by " .. self.data.creator,
		-- x = self.x,
		-- y = self.y + 3 / 20,
		-- w = self.w,
		-- h = self.h / 6,
		-- cs = self.cs,
		-- limit = self.w,
		-- align = {x = "left", y = "top"},
		-- color = {255, 255, 255, 255},
		-- font = aquafonts.getFont(spherefonts.NotoSansRegular, 22)
	-- })
	-- self.nameText:reload()
end

MetaDataTable.reload = function(self)
	self.artistText:reload()
	self.titleText:reload()
	-- self.nameText:reload()
end

MetaDataTable.draw = function(self)
	self.artistText:draw()
	self.titleText:draw()
	-- self.nameText:draw()
end


return MetaDataTable
