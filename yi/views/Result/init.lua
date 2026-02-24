local Screen = require("yi.views.Screen")
local Label = require("yi.views.Label")

---@class yi.Result : yi.Screen
---@operator call: yi.Result
local Result = Screen + {}

function Result:load()
	self:setWidth("100%")
	self:setHeight("100%")
	self.handles_keyboard_input = true

	local res = self:getResources()

	self:add(Label(res:getFont("black", 58), "Work In Progress."), {pivot = "center"})
end

function Result:onKeyDown(e)
	local k = e.key

	if k == "escape" then
		self.parent:set("select")
	end
end

return Result
