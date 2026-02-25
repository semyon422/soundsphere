local View = require("yi.views.View")
local Menu = require("yi.views.Menu")
local Select = require("yi.views.Select")
local Gameplay = require("yi.views.Gameplay")
local Result = require("yi.views.Result")

---@class yi.Screens : yi.View
---@overload fun(): yi.Screens
local Screens = View + {}

function Screens:new()
	View.new(self)
	self:setWidth("100%")
	self:setHeight("100%")
end

---@param screen_name "menu" | "select" | "gameplay" | "result"
function Screens:set(screen_name)
	for _, v in ipairs(self.children) do
		v:kill()
	end

	if self.screen then
		self.screen:exit()
	end

	if screen_name == "menu" then
		self.screen = self:add(Menu())
	elseif screen_name == "select" then
		self.screen = self:add(Select())
	elseif screen_name == "gameplay" then
		self.screen = self:add(Gameplay())
	elseif screen_name == "result" then
		self.screen = self:add(Result())
	else
		error("Unknown screen")
	end

	self.screen:enter()
end

---@param event table
function Screens:receive(event)
	self.screen:receive(event)
end

return Screens
