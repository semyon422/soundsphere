local just = require("just")
local gfx_util = require("gfx_util")
local imgui = require("imgui")

local AvailableModifierListView = require("sphere.views.ModifierView.AvailableModifierListView")
local ModifierListView = require("sphere.views.ModifierView.ModifierListView")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local function Frames(self)
	love.graphics.replaceTransform(gfx_util.transform(transform))

	love.graphics.setColor(0, 0, 0, 0.8)
	local x, y, w, h = 279, 144, 1362, 792
	love.graphics.translate(x, y)
	love.graphics.rectangle("fill", 0, 0, w, h, 36)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, 36)

	local window_id = "modifiers window"
	local over = just.is_over(w, h)
	just.button(window_id, over)
	just.wheel_over(window_id, over)
end

local function AvailableModifierList(self)
	love.graphics.replaceTransform(gfx_util.transform(transform))
	love.graphics.translate(279, 144)
	AvailableModifierListView.game = self.game
	AvailableModifierListView:draw(454, 792)
end

local function ModifierList(self)
	love.graphics.replaceTransform(gfx_util.transform(transform))
	love.graphics.translate(733, 144)
	ModifierListView.game = self.game
	ModifierListView:draw(454, 792)
end

local function AvailableModifierScrollBar(self)
	love.graphics.replaceTransform(gfx_util.transform(transform))
	love.graphics.translate(279, 144)

	local list = AvailableModifierListView
	local count = #list.items - 1
	local pos = (list.visualItemIndex - 1) / count
	local newScroll = imgui.ScrollBar("amsb", pos, 16, 792, count / list.rows)
	if newScroll then
		list:scroll(math.floor(count * newScroll + 1) - list.itemIndex)
	end
end

local function Buttons(self)
	love.graphics.replaceTransform(gfx_util.transform(transform))
	love.graphics.translate(279 + 454 * 2, 144 + 72 * 10)

	if imgui.TextButton("export to osu", "export to osu", 200, 72) then
		self.game.selectController:exportToOsu()
	end
end

local function Rectangle(self)
	love.graphics.replaceTransform(gfx_util.transform(transform))
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("fill", 733, 504, 4, 72)
	love.graphics.rectangle("fill", 279, 504, 4, 72)
	love.graphics.circle("fill", 755, 504, 4)
	love.graphics.circle("line", 755, 504, 4)
end

return function(self)
	Frames(self)
	AvailableModifierList(self)
	ModifierList(self)
	AvailableModifierScrollBar(self)
	Rectangle(self)
	Buttons(self)
end
