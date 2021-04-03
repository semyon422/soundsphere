local viewspackage = (...):match("^(.-%.views%.)")

local Node = require("aqua.util.Node")
local ResultNavigator = require(viewspackage .. "ResultView.ResultNavigator")
local BackgroundView = require(viewspackage .. "BackgroundView")

local Class = require("aqua.util.Class")
local ValueView	= require("sphere.views.GameplayView.ValueView")
local PointGraphView	= require("sphere.views.GameplayView.PointGraphView")
local ImageView	= require("sphere.views.GameplayView.ImageView")
local SequenceView	= require("sphere.views.SequenceView")

local ResultView = Class:new()

ResultView.construct = function(self)
	self.node = Node:new()
	self.valueView = ValueView:new()
	self.pointGraphView = PointGraphView:new()
	self.imageView = ImageView:new()
	self.sequenceView = SequenceView:new()
end

ResultView.load = function(self)
	local valueView = self.valueView
	local pointGraphView = self.pointGraphView
	local imageView = self.imageView
	local sequenceView = self.sequenceView
	local configModel = self.configModel

	local node = self.node
	local config = configModel:getConfig("result")

	local navigator = ResultNavigator:new()
	self.navigator = navigator
	navigator.config = config
	navigator.view = self

	local backgroundView = BackgroundView:new()
	backgroundView.view = self

	valueView.scoreSystem = self.scoreSystem
	valueView.noteChartDataEntry = self.noteChartModel.noteChartDataEntry
	valueView.modifierString = self.modifierModel:getString()

	pointGraphView.scoreSystem = self.scoreSystem
	pointGraphView.noteChartModel = self.noteChartModel

	imageView.root = "."

	sequenceView:setView("ValueView", valueView)
	sequenceView:setView("PointGraphView", pointGraphView)
	sequenceView:setView("ImageView", imageView)
	sequenceView:setSequenceConfig(config)
	sequenceView:load()

	node:node(backgroundView)

	navigator:load()
end

ResultView.unload = function(self)
	self.navigator:unload()
	self.sequenceView:unload()
end

ResultView.receive = function(self, event)
	self.node:callnext(event.name, event)
	self.navigator:receive(event)
	self.sequenceView:receive(event)
end

ResultView.update = function(self, dt)
	self.node:callnext("update")
	self.navigator:update()
	self.sequenceView:update()
end

ResultView.draw = function(self)
	self.node:callnext("draw")
	self.sequenceView:draw()
end

return ResultView
