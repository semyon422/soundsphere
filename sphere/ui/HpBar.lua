local aquafonts			= require("aqua.assets.fonts")
local Class				= require("aqua.util.Class")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Rectangle			= require("aqua.graphics.Rectangle")
local map				= require("aqua.math").map
local Theme				= require("aqua.ui.Theme")
local spherefonts		= require("sphere.assets.fonts")

local HpBar = Class:new()

HpBar.loadGui = function(self)
	self.cs = CoordinateManager:getCS(unpack(self.data.cs))
	self.x = self.data.x
	self.y = self.data.y
	self.w = self.data.w
	self.h = self.data.h
	self.layer = self.data.layer
	self.color = self.data.color
	self.mode = self.data.mode
	self.direction = self.data.direction
	self.blendMode = self.data.blendMode
	self.blendAlphaMode = self.data.blendAlphaMode

	self.noteChartModel = self.gui.noteChartModel
	self.scoreSystem = self.gui.scoreSystem
	self.container = self.gui.container
	
	self:load()
end

HpBar.load = function(self)
	self.progressRectangle = Rectangle:new({
		x = self.x,
		y = self.y,
		w = self.w,
		h = self.h,
		cs = self.cs,
		color = self.color,
		mode = "fill",
		blendMode = self.blendMode,
		blendAlphaMode = self.blendAlphaMode,
		layer = self.layer
	})
	self.progressRectangle:reload()

	self.minHp = 0
	self.maxHp = 1

	self.container:add(self.progressRectangle)
end

HpBar.unload = function(self)
	self.container:remove(self.progressRectangle)
end

HpBar.update = function(self, dt)
	local hp = self.scoreSystem:get("hp")
	
	local x0, w0 = self.x, self.w
	local y0, h0 = self.y, self.h
	local x, y, w, h
	if self.mode == "+" then
		if self.direction == "left-right" then
			w = map(hp, self.minHp, self.maxHp, 0, w0)
		elseif self.direction == "right-left" then
			w = map(hp, self.minHp, self.maxHp, 0, w0)
			x = x0 + w0 - w
		elseif self.direction == "up-down" then
			h = map(hp, self.minHp, self.maxHp, 0, h0)
		elseif self.direction == "down-up" then
			h = map(hp, self.minHp, self.maxHp, 0, h0)
			y = y0 + h0 - h
		end
	elseif self.mode == "-" then
		if self.direction == "left-right" then
			w = w0 - map(hp, self.minHp, self.maxHp, 0, w0)
			x = x0 + w0 - w
		elseif self.direction == "right-left" then
			w = w0 - map(hp, self.minHp, self.maxHp, 0, w0)
		elseif self.direction == "up-down" then
			h = h0 - map(hp, self.minHp, self.maxHp, 0, h0)
			y = y0 + h0 - h
		elseif self.direction == "down-up" then
			h = h0 - map(hp, self.minHp, self.maxHp, 0, h0)
		end
	end
	self.progressRectangle.x = x or x0
	self.progressRectangle.w = w or w0
	self.progressRectangle.y = y or y0
	self.progressRectangle.h = h or h0
	self.progressRectangle:reload()
end

HpBar.draw = function(self)
	self.progressRectangle:draw()
end

HpBar.receive = function(self, event)
end

HpBar.reload = function(self)
	self.progressRectangle:reload()
end

return HpBar
