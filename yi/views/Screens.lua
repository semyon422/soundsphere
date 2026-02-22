local View = require("yi.views.View")
local Select = require("yi.views.Select")
local Gameplay = require("yi.views.Gameplay")

---@class yi.Screens : yi.View
---@overload fun(): yi.Screens
local Screens = View + {}

function Screens:new()
	View.new(self)
	self:setWidth("100%")
	self:setHeight("100%")
end

---@param screen_name "select" | "gameplay" | "result"
function Screens:set(screen_name)
	for _, v in ipairs(self.children) do
		v:destroy()
	end

	if self.screen then
		self.screen:exit()
	end

	if screen_name == "select" then
		self.screen = self:add(Select())
	elseif screen_name == "gameplay" then
		self.screen = self:add(Gameplay())
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
