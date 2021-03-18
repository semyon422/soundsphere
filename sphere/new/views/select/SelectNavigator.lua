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

SelectNavigator.updateSearch = function(self)
	local newSearchString = self.searchLineModel:getSearchString()
	if self.searchString ~= newSearchString then
		self:pushSearch()
		self:pullSearch()
		self.searchString = newSearchString
	end
end

SelectNavigator.scrollNoteChartSet = function(self, direction, destination)
	local noteChartSetList = self.noteChartSetList
	local noteChartList = self.noteChartList
	local scoreList = self.scoreList

	local noteChartSetItems = self.view.noteChartSetLibraryModel:getItems()

	direction = direction or destination - noteChartSetList.selected
	if not noteChartSetItems[noteChartSetList.selected + direction] then
		return
	end

	noteChartSetList.selected = noteChartSetList.selected + direction
	noteChartList.selected = 1
	scoreList.selected = 1

	self:pushNoteChartSet()
	self:pullSearch()
end

SelectNavigator.scrollNoteChart = function(self, direction, destination)
	local noteChartList = self.noteChartList
	local noteChartItems = self.view.noteChartLibraryModel:getItems()

	direction = direction or destination - noteChartList.selected

	if not noteChartItems[noteChartList.selected + direction] then
		return
	end

	noteChartList.selected = noteChartList.selected + direction

	self:pushNoteChart()
	self:pullSearch()
end

SelectNavigator.scrollScore = function(self, direction)
	local scoreList = self.scoreList
	local scoreItems = self.view.scoreLibraryModel:getItems()
	if not scoreItems[scoreList.selected + direction] then
		return
	end
	scoreList.selected = scoreList.selected + direction

	self:pushScore()
	self:pullSearch()
end

SelectNavigator.scrollSelectMenu = function(self, direction)
	local selectMenu = self.selectMenu
	local selectMenuItems = self.view.selectMenuView.items
	if not selectMenuItems[selectMenu.selected + direction] then
		return
	end
	selectMenu.selected = selectMenu.selected + direction
end

SelectNavigator.pushSearch = function(self)
	local searchString = self.searchLineModel:getSearchString()

	self.view.noteChartLibraryModel:setSearchString(searchString)
	self.view.noteChartSetLibraryModel:setSearchString(searchString)

	self:send({
		name = "selectSearchString",
		searchString = searchString
	})
end

SelectNavigator.pullSearch = function(self)
	local searchString = self.config.searchString

	self.searchLineModel:setSearchString(searchString)

	self.view.noteChartLibraryModel:setSearchString(searchString)
	self.view.noteChartSetLibraryModel:setSearchString(searchString)

	self:pullNoteChartSet()
end

SelectNavigator.pushNoteChartSet = function(self)
	local noteChartSetItems = self.view.noteChartSetLibraryModel:getItems()
	local noteChartSetItem = noteChartSetItems[self.noteChartSetList.selected]
	if not noteChartSetItem then
		return
	end

	self:send({
		name = "selectNoteChartSetEntry",
		noteChartSetEntryId = noteChartSetItem.noteChartSetEntry.id
	})
end

SelectNavigator.pullNoteChartSet = function(self)
	local config = self.config
	local noteChartSetLibraryModel = self.view.noteChartSetLibraryModel
	local noteChartSetList = self.noteChartSetList

	local noteChartSetItems = noteChartSetLibraryModel:getItems()
	local noteChartSetItem = noteChartSetItems[noteChartSetList.selected]

	if noteChartSetItem and noteChartSetItem.noteChartSetEntry.id == config.noteChartSetEntryId then
		self:pullNoteChart()
		return
	end

	local noteChartSetItemIndex = noteChartSetLibraryModel:getItemIndex(config.noteChartSetEntryId)
	noteChartSetList.selected = noteChartSetItemIndex

	noteChartSetItem = noteChartSetItems[noteChartSetList.selected]
	if noteChartSetItem then
		config.noteChartSetEntryId = noteChartSetItem.noteChartSetEntry.id
		self:pullNoteChart()
	end
end

SelectNavigator.pushNoteChart = function(self)
	local noteChartSetItems = self.view.noteChartSetLibraryModel:getItems()
	local noteChartSetItem = noteChartSetItems[self.noteChartSetList.selected]
	self.view.noteChartLibraryModel:setNoteChartSetId(noteChartSetItem.noteChartSetEntry.id)

	local noteChartItems = self.view.noteChartLibraryModel:getItems()
	local noteChartItem = noteChartItems[self.noteChartList.selected]
	if not noteChartItem then
		return
	end

	self:send({
		name = "selectNoteChartEntry",
		noteChartEntryId = noteChartItem.noteChartEntry.id
	})
	self:send({
		name = "selectNoteChartDataEntry",
		noteChartDataEntryId = noteChartItem.noteChartDataEntry.id
	})
end

SelectNavigator.pullNoteChart = function(self)
	local config = self.config
	local noteChartList = self.noteChartList
	local noteChartSetLibraryModel = self.view.noteChartSetLibraryModel
	local noteChartLibraryModel = self.view.noteChartLibraryModel

	local noteChartSetItems = noteChartSetLibraryModel:getItems()
	local noteChartSetItem = noteChartSetItems[self.noteChartSetList.selected]
	noteChartLibraryModel:setNoteChartSetId(noteChartSetItem.noteChartSetEntry.id)

	local noteChartItems = self.view.noteChartLibraryModel:getItems()
	local noteChartItem = noteChartItems[noteChartList.selected]

	if
		noteChartItem and
		noteChartItem.noteChartEntry.id == config.noteChartEntryId and
		noteChartItem.noteChartDataEntry.id == config.noteChartDataEntryId
	then
		self:pullScore()
		return
	end

	local noteChartItemIndex = noteChartLibraryModel:getItemIndex(config.noteChartEntryId, config.noteChartDataEntryId)
	noteChartList.selected = noteChartItemIndex

	noteChartItem = noteChartItems[noteChartList.selected]
	if noteChartItem then
		config.noteChartEntryId = noteChartItem.noteChartEntry.id
		config.noteChartDataEntryId = noteChartItem.noteChartDataEntry.id
		self:pullScore()
	end
end

SelectNavigator.pushScore = function(self)
	local noteChartItems = self.view.noteChartLibraryModel:getItems()
	local noteChartItem = noteChartItems[self.noteChartList.selected]
	self.view.scoreLibraryModel:setHash(noteChartItem.noteChartDataEntry.hash)
	self.view.scoreLibraryModel:setIndex(noteChartItem.noteChartDataEntry.index)

	local scoreItems = self.view.scoreLibraryModel:getItems()
	local scoreItem = scoreItems[self.scoreList.selected]
	if not scoreItem then
		return
	end

	self:send({
		name = "selectScoreEntry",
		scoreEntryId = scoreItem.scoreEntry.id
	})
end

SelectNavigator.pullScore = function(self)
	local config = self.config
	local scoreList = self.scoreList
	local scoreLibraryModel = self.view.scoreLibraryModel

	local noteChartItems = self.view.noteChartLibraryModel:getItems()
	local noteChartItem = noteChartItems[self.noteChartList.selected]
	scoreLibraryModel:setHash(noteChartItem.noteChartDataEntry.hash)
	scoreLibraryModel:setIndex(noteChartItem.noteChartDataEntry.index)

	local scoreItems = self.view.scoreLibraryModel:getItems()
	local scoreItem = scoreItems[scoreList.selected]
	if scoreItem and scoreItem.scoreEntry.id == config.scoreEntryId then
		return
	end

	local scoreItemIndex = scoreLibraryModel:getItemIndex(config.scoreEntryId)
	scoreList.selected = scoreItemIndex

	scoreItem = scoreItems[scoreList.selected]
	if scoreItem then
		config.scoreEntryId = scoreItem.scoreEntry.id
	end
end

SelectNavigator.load = function(self)
	Navigator.load(self)

	local noteChartSetList = self.noteChartSetList
	local noteChartList = self.noteChartList
	local scoreList = self.scoreList
	local selectMenu = self.selectMenu

	self.node = noteChartSetList
	noteChartSetList:on("up", function()
		self:scrollNoteChartSet(-1)
	end)
	noteChartSetList:on("down", function()
		self:scrollNoteChartSet(1)
	end)
	noteChartSetList:on("left", function()
		self.node = noteChartList
	end)

	noteChartList:on("up", function()
		self:scrollNoteChart(-1)
	end)
	noteChartList:on("down", function()
		self:scrollNoteChart(1)
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
		self:scrollScore(-1)
	end)
	scoreList:on("down", function()
		self:scrollScore(1)
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

	self.searchString = self.config.searchString
	self:pullSearch()
end

SelectNavigator.update = function(self)
	self:updateSearch()
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
