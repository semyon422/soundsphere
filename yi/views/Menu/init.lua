local Screen = require("yi.views.Screen")
local Label = require("yi.views.Label")

---@class yi.Menu : yi.Screen
---@operator call: yi.Result
local Menu = Screen + {}

local misans = [[Rizu uses MiSans fonts, provided by Xiaomi Inc. under the MiSans Font Intellectual Property License Agreement.]]

function Menu:load()
	Screen.load(self)

	self:setup({
		id = "menu",
		w = "100%",
		h = "100%",
		arrange = "flex_col",
		justify_content = "center",
		align_items = "center",
		keyboard = true,
	})

	local res = self:getResources()
	self:add(Label(res:getFont("black", 58), "Press ENTER to continue"))
	self:add(Label(res:getFont("regular", 24), misans))
end

function Menu:onKeyDown(e)
	local k = e.key

	if k == "return" then
		self.parent:set("select")
	end
end

return Menu
