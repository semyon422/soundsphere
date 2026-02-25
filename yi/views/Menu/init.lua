local Screen = require("yi.views.Screen")
local View = require("yi.views.View")
local Label = require("yi.views.Label")
local h = require("yi.h")

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

	self:addArray({
		h(Label(res:getFont("black", 58), "Press ENTER to continue")),
		h(Label(res:getFont("bold", 16), misans)),
	})
end

function Menu:onKeyDown(e)
	local k = e.key

	if k == "return" then
		self.parent:set("select")
	end
end

return Menu
