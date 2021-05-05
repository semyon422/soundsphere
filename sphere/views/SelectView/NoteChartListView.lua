local viewspackage = (...):match("^(.-%.views%.)")

local tween = require("tween")
local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local NoteChartListItemView = require(viewspackage .. "SelectView.NoteChartListItemView")

local NoteChartListView = Class:new()

NoteChartListView.construct = function(self)
	self.itemView = NoteChartListItemView:new()
	self.itemView.listView = self
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
	self.stencilfunction = function()
		self:drawStencil()
	end
end

NoteChartListView.load = function(self)
	self:forceScroll()
	self:reloadItems()
end

NoteChartListView.forceScroll = function(self)
	self.state.selectedItem = self.selectModel.noteChartItemIndex
	self.state.selectedVisualItem = self.selectModel.noteChartItemIndex
end

NoteChartListView.reloadItems = function(self)
	self.state.items = self.noteChartLibraryModel.items
end

NoteChartListView.receive = function(self, event)
	local config = self.config
	if event.name == "wheelmoved" then
		local mx, my = love.mouse.getPosition()
		local cs = self.cs
		local x = cs:X(config.x / config.screen.h, true)
		local y = cs:Y(config.y / config.screen.h, true)
		local w = cs:X(config.w / config.screen.h)
		local h = cs:Y(config.h / config.screen.h)
		if mx >= x and mx < x + w and my >= y and my < y + h then
			local wy = event.args[2]
			if wy == 1 then
				self.navigator:scrollNoteChart("up")
			elseif wy == -1 then
				self.navigator:scrollNoteChart("down")
			end
		end
	end
end

NoteChartListView.update = function(self, dt)
	if self.state.selectedItem ~= self.selectModel.noteChartItemIndex then
		self.state.scrollTween = tween.new(
			0.1,
			self.state,
			{selectedVisualItem = self.selectModel.noteChartItemIndex},
			"linear"
		)
		self.state.selectedItem = self.selectModel.noteChartItemIndex
	end
	if self.state.selectedVisualItem == self.state.selectedItem then
		self.state.scrollTween = nil
	end
	if self.state.scrollTween then
		self.state.scrollTween:update(dt)
	end
	local items = self.state.items
	self:reloadItems()
	if items ~= self.state.items then
		self:forceScroll()
	end
end

NoteChartListView.drawStencil = function(self)
	local config = self.config
	local cs = self.cs
	local screen = config.screen

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle(
		"fill",
		cs:X(config.x / screen.h, true),
		cs:Y(config.y / screen.h, true),
		cs:X(config.w / screen.h),
		cs:Y(config.h / screen.h)
	)
end

NoteChartListView.draw = function(self)
	love.graphics.stencil(
		self.stencilfunction,
		"replace",
		1,
		false
	)
	love.graphics.setStencilTest("greater", 0)

	local state = self.state
	local config = self.config

	local deltaItemIndex = state.selectedItem - state.selectedVisualItem
	for i = 0 - math.floor(deltaItemIndex), config.rows - math.floor(deltaItemIndex) do
		local itemIndex = i + state.selectedItem - math.ceil(config.rows / 2)
		local visualIndex = i + deltaItemIndex
		local item = state.items[itemIndex]
		if item then
			local itemView = self.itemView
			itemView.visualIndex = visualIndex
			itemView.item = item
			itemView.listView = self
			itemView.prevItem = state.items[itemIndex - 1]
			itemView.nextItem = state.items[itemIndex + 1]
			itemView:draw()
		end
	end

	love.graphics.setStencilTest()
end

return NoteChartListView
