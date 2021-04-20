local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")
local Node = require("aqua.util.Node")

local SelectNavigator = Navigator:new()

SelectNavigator.construct = function(self)
	Navigator.construct(self)

	local noteChartSetList = Node:new()
	self.noteChartSetList = noteChartSetList
	noteChartSetList.selected = 1

	local noteChartList = Node:new()
	self.noteChartList = noteChartList
	noteChartList.selected = 1

	local scoreList = Node:new()
	self.scoreList = scoreList
	scoreList.selected = 1

	local selectMenu = Node:new()
	self.selectMenu = selectMenu
	selectMenu.selected = 1
end

SelectNavigator.updateSelected = function(self)
	self.noteChartSetList.selected = self.selectModel.noteChartSetItemIndex
	self.noteChartList.selected = self.selectModel.noteChartItemIndex
	self.scoreList.selected = self.selectModel.scoreItemIndex
end

SelectNavigator.scrollSelectMenu = function(self, direction)
	local selectMenu = self.selectMenu
	local selectMenuItems = self.view.selectMenuView.items
	if not selectMenuItems[selectMenu.selected + direction] then
		return
	end
	selectMenu.selected = selectMenu.selected + direction
end

SelectNavigator.load = function(self)
	Navigator.load(self)

	local noteChartSetList = self.noteChartSetList
	local noteChartList = self.noteChartList
	local scoreList = self.scoreList
	local selectMenu = self.selectMenu

	self.node = noteChartSetList
	noteChartSetList:on("up", function()
		self:send({
			name = "scrollNoteChartSet",
			direction = -1
		})
	end)
	noteChartSetList:on("down", function()
		self:send({
			name = "scrollNoteChartSet",
			direction = 1
		})
	end)
	noteChartSetList:on("left", function()
		self.node = noteChartList
	end)

	noteChartList:on("up", function()
		self:send({
			name = "scrollNoteChart",
			direction = -1
		})
	end)
	noteChartList:on("down", function()
		self:send({
			name = "scrollNoteChart",
			direction = 1
		})
	end)
	noteChartList:on("right", function()
		self.node = noteChartSetList
	end)
	noteChartList:on("left", function()
		self.node = scoreList
	end)
	noteChartList:on("tab", function()
		self.node = selectMenu
	end)
	noteChartList:on("return", function()
		self:send({
			action = "playNoteChart"
		})
	end)

	scoreList:on("up", function()
		self:send({
			name = "scrollScore",
			direction = -1
		})
	end)
	scoreList:on("down", function()
		self:send({
			name = "scrollScore",
			direction = 1
		})
	end)
	scoreList:on("right", function()
		self.node = noteChartList
	end)

	selectMenu:on("left", function()
		self:scrollSelectMenu(-1)
	end)
	selectMenu:on("right", function()
		self:scrollSelectMenu(1)
	end)
	selectMenu:on("tab", function()
		self.node = noteChartList
	end)
	selectMenu:on("return", function()
		self:send({
			action = "clickSelectMenu",
			item = self.view.selectMenuView.items[selectMenu.selected]
		})
	end)

	self:send({
		name = "updateSearch"
	})
end

SelectNavigator.update = function(self)
	self:send({
		name = "updateSearch"
	})
	self:updateSelected()
end

SelectNavigator.receive = function(self, event)
	if event.name == "wheelmoved" then
		local y = event.args[2]
		if y == 1 then
			self:call("up")
		elseif y == -1 then
			self:call("down")
		end
	elseif event.name == "mousepressed" then
		self:call("return")
	elseif event.name == "keypressed" then
		self:call(event.args[1])
	end
end

return SelectNavigator
