
local Class = require("aqua.util.Class")
local Node = require("aqua.util.Node")
local Observable = require("aqua.util.Observable")

local SelectNavigator = Class:new()

SelectNavigator.construct = function(self)
	local observable = Observable:new()
	self.observable = observable
	observable:add(self.view.controller)

	local noteChartSetList = Node:new()
	self.noteChartSetList = noteChartSetList
	noteChartSetList.selected = 1

	local noteChartList = Node:new()
	self.noteChartList = noteChartList
	noteChartList.selected = 1
end

SelectNavigator.selectNoteChartSet = function(self)
	local noteChartSetList = self.noteChartSetList
	local noteChartSetItems = self.view.noteChartSetLibraryModel:getItems("")
	self:send({
		name = "selectNoteChart",
		type = "noteChartSetEntry",
		id = noteChartSetItems[noteChartSetList.selected].noteChartSetEntry.id
	})
	self:send({
		name = "unloadModifiedNoteChart"
	})
end

SelectNavigator.selectNoteChart = function(self)
	local noteChartSetList = self.noteChartSetList
	local noteChartList = self.noteChartList
	local noteChartSetItems = self.view.noteChartSetLibraryModel:getItems("")
	local setId = noteChartSetItems[noteChartSetList.selected].noteChartSetEntry.id
	local noteChartItems = self.view.noteChartLibraryModel:getItems(setId, "")
	self:send({
		name = "selectNoteChart",
		type = "noteChartEntry",
		noteChartEntryId = noteChartItems[noteChartList.selected].noteChartEntry.id,
		noteChartDataEntryId = noteChartItems[noteChartList.selected].noteChartDataEntry.id
	})
	self:send({
		name = "unloadModifiedNoteChart"
	})
end

SelectNavigator.load = function(self)
	local observable = self.observable
	local noteChartSetList = self.noteChartSetList
	local noteChartList = self.noteChartList

	observable:add(self.view.controller)

	self.node = noteChartSetList
	noteChartSetList:on("up", function()
		noteChartSetList.selected = noteChartSetList.selected - 1
		noteChartList.selected = 1
		self:selectNoteChartSet()
	end)
	noteChartSetList:on("down", function()
		noteChartSetList.selected = noteChartSetList.selected + 1
		noteChartList.selected = 1
		self:selectNoteChartSet()
	end)
	noteChartSetList:on("left", function()
		self.node = noteChartList
	end)

	noteChartList:on("up", function()
		noteChartList.selected = noteChartList.selected - 1
		self:selectNoteChart()
	end)
	noteChartList:on("down", function()
		noteChartList.selected = noteChartList.selected + 1
		self:selectNoteChart()
	end)
	noteChartList:on("right", function()
		self.node = noteChartSetList
	end)
	noteChartList:on("return", function()
		self:send({
			action = "playNoteChart",
		})
	end)
end

SelectNavigator.unload = function(self)
	self.observable:remove(self.view.controller)
end

SelectNavigator.setNode = function(self, nodeName)
	self.node = assert(self[nodeName])
end

SelectNavigator.call = function(self, ...)
	self.node:call(...)
end

SelectNavigator.send = function(self, event)
	return self.observable:send(event)
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
