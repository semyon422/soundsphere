local _transform = require("aqua.graphics.transform")
local just = require("just")
local just_layout = require("just.layout")

local AvailableModifierListView = require("sphere.views.ModifierView.AvailableModifierListView")
local ModifierListView = require("sphere.views.ModifierView.ModifierListView")
local ScrollBarImView = require("sphere.imviews.ScrollBarImView")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local Frames = {draw = function()
	local width, height = love.graphics.getDimensions()
	love.graphics.origin()

	love.graphics.replaceTransform(_transform(transform))

	local _x, _y = love.graphics.inverseTransformPoint(0, 0)
	local _xw, _yh = love.graphics.inverseTransformPoint(width, height)
	local _w, _h = _xw - _x, _yh - _y

	local x_int = 24
	local y_int = 55

	-- local x1, w1 = just_layout(0, 1920, {24, -1/3, -1/3, -1/3, 24})

	local y0, h0 = just_layout(0, 1080, {89, y_int, -1, y_int, 89})

	love.graphics.setColor(0, 0, 0, 0.8)
	local x, y, w, h = 279, 144, 1362, 792
	love.graphics.rectangle("fill", x, y, w, h, 36)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", x, y, w, h, 36)
end}

local ContainerBegin = {draw = function(self)
	love.graphics.replaceTransform(_transform(transform))

	local x, y, w, h = 279, 144, 1362, 792
	love.graphics.translate(x, y)

	local window_id = "modifiers window"
	local over = just.is_over(w, h)
	just.container(window_id, over)
	just.button(window_id, over)
	just.wheel_over(window_id, over)

	if just.keypressed("escape") then
		self.game.gameView.modifierView:toggle(false)
	end
end}

local ContainerEnd = {draw = function(self)
	just.container()
end}

local AvailableModifierList = AvailableModifierListView:new({
	transform = transform,
	x = 279,
	y = 144,
	w = 454,
	h = 792,
	rows = 11,
})

local ModifierList = ModifierListView:new({
	transform = transform,
	x = 733,
	y = 144,
	w = 454,
	h = 792,
	rows = 11,
})

local AvailableModifierScrollBar = {draw = function(self)
	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate(279, 144)

	local list = AvailableModifierList
	local count = #list.items - 1
	local pos = (list.visualItemIndex - 1) / count
	local newScroll = ScrollBarImView("amsb", pos, 16, 792, count / list.rows)
	if newScroll then
		list:scroll(math.floor(count * newScroll + 1) - list.itemIndex)
	end
end}

local Rectangle = {draw = function()
	love.graphics.replaceTransform(_transform(transform))
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("fill", 733, 504, 4, 72)
	love.graphics.rectangle("fill", 279, 504, 4, 72)
	love.graphics.circle("fill", 755, 504, 4)
	love.graphics.circle("line", 755, 504, 4)
end}

local ModifierViewConfig = {
	Frames,
	ContainerBegin,
	AvailableModifierList,
	ModifierList,
	AvailableModifierScrollBar,
	Rectangle,
	ContainerEnd,
}

return ModifierViewConfig
