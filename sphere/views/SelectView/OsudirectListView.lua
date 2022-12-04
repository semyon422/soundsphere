local ListView = require("sphere.views.ListView")
local TextCellImView = require("sphere.imviews.TextCellImView")
local just = require("just")

local OsudirectListView = ListView:new()

OsudirectListView.rows = 11

OsudirectListView.reloadItems = function(self)
	self.items = self.game.osudirectModel.items
	if self.itemIndex > #self.items then
		self.targetItemIndex = 1
		self.stateCounter = (self.stateCounter or 0) + 1
	end
end

OsudirectListView.scroll = function(self, count)
	ListView.scroll(self, count)
	self.game.osudirectModel:setBeatmap(self.items[self.targetItemIndex])
end

OsudirectListView.draw = function(self, ...)
	ListView.draw(self, ...)

	if not just.key_over() then
		return
	end

	local kp = just.keypressed
	if kp("up") or kp("left") then self:scroll(-1)
	elseif kp("down") or kp("right") then self:scroll(1)
	elseif kp("pageup") then self:scroll(-10)
	elseif kp("pagedown") then self:scroll(10)
	elseif kp("home") then self:scroll(-math.huge)
	elseif kp("end") then self:scroll(math.huge)
	end
end

OsudirectListView.drawItem = function(self, i, w, h)
	local item = self.items[i]

	just.indent(44)
	TextCellImView(math.huge, h, "left", item.artist, item.title)
end

return OsudirectListView
