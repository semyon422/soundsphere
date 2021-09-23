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

ScreenView.views = {
	{"screenMenuView", ScreenMenuView, "ScreenMenuView"},
	{"userInfoView", UserInfoView, "UserInfoView"},
	{"logoView", LogoView, "LogoView"},
	{"scrollBarView", ScrollBarView, "ScrollBarView"},
	{"backgroundView", BackgroundView, "BackgroundView"},
	{"rectangleView", RectangleView, "RectangleView"},
	{"circleView", CircleView, "CircleView"},
	{"lineView", LineView, "LineView"},
	{"inspectView", InspectView, "InspectView"},
	{"valueView", ValueView, "ValueView"},
	{"imageView", ImageView, "ImageView"},
	{"cameraView", CameraView, "CameraView"},
	{"gaussianBlurView", GaussianBlurView, "GaussianBlurView"},
	{"imageAnimationView", ImageAnimationView, "ImageAnimationView"},
}

ScreenView.construct = function(self)
	self.sequenceView = SequenceView:new()
end

ScreenView.createViews = function(self, views)
	for _, a in ipairs(views) do
		self[a[1]] = a[2]:new()
	end
end

ScreenView.loadViews = function(self, views)
	local navigator = assert(self.navigator)
	local gameController = assert(self.gameController)
	local sequenceView = assert(self.sequenceView)
	for _, a in ipairs(views) do
		local view = self[a[1]]
		view.gameController = gameController
		view.navigator = navigator
		sequenceView:setView(a[3], view)
	end
end

ScreenView.load = function(self)
	local navigator = self.navigator
	local sequenceView = self.sequenceView

	navigator.view = self
	navigator.gameController = self.gameController
	navigator.viewConfig = assert(self.viewConfig)
	navigator.sequenceView = sequenceView

	sequenceView:setSequenceConfig(self.viewConfig)
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
