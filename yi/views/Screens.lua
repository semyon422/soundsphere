local View = require("yi.views.View")
local Menu = require("yi.views.menu.Menu")
local Select = require("yi.views.select.Select")
local Gameplay = require("yi.views.gameplay.Gameplay")
local Result = require("yi.views.result.Result")
local Test = require("yi.views.Test")
local Dlc = require("yi.views.dlc.DlcScreen")

---@class yi.Screens : yi.View
---@overload fun(): yi.Screens
local Screens = View + {}

function Screens:new()
	View.new(self)
	self.id = "screens"
	self:setWidth("100%")
	self:setHeight("100%")

	self.menu = self:add(Menu())
	self.select = self:add(Select())
	self.gameplay = self:add(Gameplay())
	self.result = self:add(Result())
	self.test = self:add(Test())
	self.dlc = self:add(Dlc())

	self.menu:setEnabled(false)
	self.select:setEnabled(false)
	self.gameplay:setEnabled(false)
	self.result:setEnabled(false)
	self.test:setEnabled(false)
	self.dlc:setEnabled(false)
end

---@param screen_name "menu" | "select" | "gameplay" | "result" | "test" | "dlc"
function Screens:set(screen_name)
	if self.screen then
		self.screen:setEnabled(false)
		self.screen:exit()
	end

	if screen_name == "menu" then
		self.screen = self.menu
	elseif screen_name == "select" then
		self.screen = self.select
	elseif screen_name == "gameplay" then
		self.screen = self.gameplay
	elseif screen_name == "result" then
		self.screen = self.result
	elseif screen_name == "test" then
		self.screen = self.test
	elseif screen_name == "dlc" then
		self.screen = self.dlc
	else
		error("Unknown screen")
	end

	self.screen:setEnabled(true)
	self.screen:enter()
end

---@param event table
function Screens:receive(event)
	self.screen:receive(event)
end

return Screens
