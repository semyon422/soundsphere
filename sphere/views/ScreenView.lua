local viewspackage = (...):match("^(.-%.views%.)")

local Class = require("aqua.util.Class")

local SequenceView = require(viewspackage .. "SequenceView")
local ScrollBarView = require(viewspackage .. "ScrollBarView")
local RectangleView = require(viewspackage .. "RectangleView")
local CircleView = require(viewspackage .. "CircleView")
local LineView = require(viewspackage .. "LineView")
local UserInfoView = require(viewspackage .. "UserInfoView")
local LogoView = require(viewspackage .. "LogoView")
local ScreenMenuView = require(viewspackage .. "ScreenMenuView")
local BackgroundView = require(viewspackage .. "BackgroundView")
local InspectView = require(viewspackage .. "InspectView")
local ValueView = require(viewspackage .. "ValueView")
local ImageView = require(viewspackage .. "ImageView")
local CameraView = require(viewspackage .. "CameraView")
local GaussianBlurView = require(viewspackage .. "GaussianBlurView")
local ImageAnimationView = require(viewspackage .. "ImageAnimationView")

local ScreenView = Class:new()

ScreenView.construct = function(self)
	self.sequenceView = SequenceView:new()
	self.screenMenuView = ScreenMenuView:new()
	self.userInfoView = UserInfoView:new()
	self.logoView = LogoView:new()
	self.scrollBarView = ScrollBarView:new()
	self.backgroundView = BackgroundView:new()
	self.rectangleView = RectangleView:new()
	self.circleView = CircleView:new()
	self.lineView = LineView:new()
	self.inspectView = InspectView:new()
	self.valueView = ValueView:new()
	self.imageView = ImageView:new()
	self.cameraView = CameraView:new()
	self.gaussianBlurView = GaussianBlurView:new()
	self.imageAnimationView = ImageAnimationView:new()
end

ScreenView.load = function(self)
	local screenMenuView = self.screenMenuView
	local navigator = self.navigator
	local sequenceView = self.sequenceView
	local backgroundView = self.backgroundView
	local cameraView = self.cameraView

	navigator.view = self
	navigator.viewConfig = self.viewConfig
	navigator.sequenceView = sequenceView
	screenMenuView.navigator = navigator
	backgroundView.backgroundModel = self.backgroundModel
	cameraView.navigator = navigator

	sequenceView:setSequenceConfig(self.viewConfig)
	sequenceView:setView("BackgroundView", backgroundView)
	sequenceView:setView("ScreenMenuView", screenMenuView)
	sequenceView:setView("UserInfoView", self.userInfoView)
	sequenceView:setView("LogoView", self.logoView)
	sequenceView:setView("ScrollBarView", self.scrollBarView)
	sequenceView:setView("RectangleView", self.rectangleView)
	sequenceView:setView("CircleView", self.circleView)
	sequenceView:setView("LineView", self.lineView)
	sequenceView:setView("InspectView", self.inspectView)
	sequenceView:setView("ValueView", self.valueView)
	sequenceView:setView("ImageView", self.imageView)
	sequenceView:setView("CameraView", cameraView)
	sequenceView:setView("GaussianBlurView", self.gaussianBlurView)
	sequenceView:setView("ImageAnimationView", self.imageAnimationView)
	sequenceView:load()

	navigator:load()
end

ScreenView.unload = function(self)
	self.sequenceView:unload()
	self.navigator:unload()
end

ScreenView.receive = function(self, event)
	self.sequenceView:receive(event)
	self.navigator:receive(event)
end

ScreenView.update = function(self, dt)
	self.sequenceView:update(dt)
	self.navigator:update()
end

ScreenView.draw = function(self)
	self.sequenceView:draw()
end

return ScreenView
