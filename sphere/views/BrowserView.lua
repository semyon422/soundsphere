local Class = require("aqua.util.Class")
local Container = require("aqua.graphics.Container")

local BackgroundManager	= require("sphere.ui.BackgroundManager")

local GUI = require("sphere.ui.GUI")

local BrowserList		= require("sphere.ui.BrowserList")

local BrowserView = Class:new()

BrowserView.construct = function(self)
    self.container = Container:new()
	self.gui = GUI:new()
end

BrowserView.load = function(self)
    local container = self.container
	local gui = self.gui

    gui.cacheModel = self.cacheModel
    gui.collectionModel = self.collectionModel
    gui.container = container

	gui:load("userdata/interface/browser.json")
    gui.observable:add(self)
	gui.observable:add(self.controller)

    BrowserList.collectionModel = self.collectionModel

	BrowserList:init()
	BrowserList.observable:add(self)
	BrowserList:load()

	BackgroundManager:setColor({127, 127, 127})
end

BrowserView.unload = function(self)
	BrowserList:unload()
    self.gui.observable:remove(self)
    self.gui.observable:remove(self.controller)
end

BrowserView.receive = function(self, event)
	BrowserList:receive(event)
	self.gui:receive(event)

	if event.name == "keypressed" and event.args[1] == self.configModel:get("screen.browser") then
		self.controller:receive({
			name = "setScreen",
			screenName = "SelectScreen"
		})
	end
end

BrowserView.update = function(self, dt)
    self.container:update()

	BrowserList:update()

	self.gui:update()
end

BrowserView.draw = function(self)
	self.container:draw()

	BrowserList:draw()
end

return BrowserView
