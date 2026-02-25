local Screen = require("yi.views.Screen")
local Label = require("yi.views.Label")

---@class yi.Result : yi.Screen
---@operator call: yi.Result
local Result = Screen + {}

function Result:load()
	self:setup({
		id = "result",
		w = "100%",
		h = "100%",
		keyboard = true
	})

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
