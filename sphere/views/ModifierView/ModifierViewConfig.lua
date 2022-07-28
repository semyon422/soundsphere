local _transform = require("aqua.graphics.transform")
local just = require("just")
local spherefonts = require("sphere.assets.fonts")
local just_layout = require("just.layout")

local TextCellImView = require("sphere.views.SelectView.TextCellImView")
local TextTooltipImView = require("sphere.views.TextTooltipImView")

local ScrollBarView = require("sphere.views.ScrollBarView")
local RectangleView = require("sphere.views.RectangleView")
local CircleView = require("sphere.views.CircleView")
local SwitchView = require("sphere.views.SwitchView")
local StepperView = require("sphere.views.StepperView")
local SliderView = require("sphere.views.SliderView")

local AvailableModifierListView = require("sphere.views.ModifierView.AvailableModifierListView")
local ModifierListView = require("sphere.views.ModifierView.ModifierListView")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local Tooltip = {draw = function(self)
	if self.text then
		love.graphics.setFont(spherefonts.get("Noto Sans", 28))
		TextTooltipImView(self.id, self.text)
	end
	self.id = nil
	self.text = nil
end}

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
end}

local ContainerBegin = {draw = function(self)
	love.graphics.replaceTransform(_transform(transform))

	local x, y, w, h = 279, 144, 1362, 792
	love.graphics.translate(x, y)

	local over = just.is_over(w, h)
	just.container("modifiers window", over)
	just.wheel_over("modifiers window", over)
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
	drawItem = function(self, i, w, h)
		local item = self.items[i]
		local prevItem = self.items[i - 1]

		if just.button(i, just.is_over(w, h)) then
			self.navigator:addModifier(i)
		end

		love.graphics.setColor(1, 1, 1, 1)
		if item.oneUse and item.added then
			love.graphics.setColor(1, 1, 1, 0.5)
		end

		just.row(true)
		just.indent(44)
		TextCellImView(410, 72, "left", "", item.name)
		if just.is_over(-410, 72) then
			Tooltip.text = item.description
			Tooltip.id = i
		end
		just.indent(-410 - 44)

		love.graphics.setColor(1, 1, 1, 1)
		if not prevItem or prevItem.oneUse ~= item.oneUse then
			local text = "One use modifiers"
			if not item.oneUse then
				text = "Sequential modifiers"
			end
			TextCellImView(410, 72, "right", text, "")
		end
		just.row(false)
	end,
})

local ModifierList = ModifierListView:new({
	transform = transform,
	x = 733,
	y = 144,
	w = 454,
	h = 792,
	rows = 11,
	drawItem = function(self, i, w, h)
		local item = self.items[i]
		local w2 = w / 2

		if just.button(tostring(item) .. "1", just.is_over(w2, h), 2) then
			self.navigator:removeModifier(i)
		end

		just.row(true)
		just.indent(44)
		TextCellImView(w2 - 44, 72, "left", "", item.name)

		local modifier = self.game.modifierModel:getModifier(item)
		if modifier.interfaceType == "toggle" then
			just.indent((w2 - h) / 2)
			w2 = 72
			local over = SwitchView:isOver(w2, h)
			local delta = just.wheel_over(item, over)
			local changed, active, hovered = just.button(item, over)

			local value = item.value
			if changed then
				value = not value
			elseif delta then
				value = delta == 1
			end
			if changed or delta then
				self.navigator:setModifierValue(item, value)
			end
			SwitchView:draw(w2, h, value)
		elseif modifier.interfaceType == "slider" then
			just.indent(-w2)
			TextCellImView(w2, 72, "right", "", item.value)

			local value = modifier:toNormValue(item.value)

			local over = SliderView:isOver(w2, h)
			local pos = SliderView:getPosition(w2, h)

			local delta = just.wheel_over(item, over)
			local new_value, active, hovered = just.slider(item, over, pos, value)
			if new_value then
				self.navigator:setModifierValue(item, modifier:fromNormValue(new_value))
			elseif delta then
				self.navigator:increaseModifierValue(i, delta)
			end
			SliderView:draw(w2, h, value)
		elseif modifier.interfaceType == "stepper" then
			TextCellImView(w2, 72, "center", "", item.value)
			just.indent(-w2)

			local value = modifier:toIndexValue(item.value)
			local count = modifier:getCount()

			local overAll, overLeft, overRight = StepperView:isOver(w2, h)

			local id = tostring(item)
			local delta = just.wheel_over(id .. "A", overAll)
			local changedLeft = just.button(id .. "L", overLeft)
			local changedRight = just.button(id .. "R", overRight)

			if changedLeft or delta == -1 then
				self.navigator:increaseModifierValue(i, -1)
			elseif changedRight or delta == 1 then
				self.navigator:increaseModifierValue(i, 1)
			end
			StepperView:draw(w2, h, value, count)
		end
		just.row(false)
	end,
})

local AvailableModifierScrollBar = ScrollBarView:new({
	transform = transform,
	list = AvailableModifierList,
	x = 263,
	y = 144,
	w = 16,
	h = 792,
	rows = 11,
	backgroundColor = {1, 1, 1, 0.33},
	color = {1, 1, 1, 0.66}
})

local Rectangle = RectangleView:new({
	transform = transform,
	rectangles = {
		{
			color = {1, 1, 1, 1},
			mode = "fill",
			lineStyle = "smooth",
			lineWidth = 1,
			x = 733,
			y = 504,
			w = 4,
			h = 72,
			rx = 0,
			ry = 0
		},
		{
			color = {1, 1, 1, 1},
			mode = "fill",
			lineStyle = "smooth",
			lineWidth = 1,
			x = 279,
			y = 504,
			w = 4,
			h = 72,
			rx = 0,
			ry = 0
		}
	}
})

local Circle = CircleView:new({
	transform = transform,
	circles = {
		{
			color = {1, 1, 1, 1},
			mode = "fill",
			lineStyle = "smooth",
			lineWidth = 1,
			x = 755,
			y = 504,
			r = 4
		},
		{
			color = {1, 1, 1, 1},
			mode = "line",
			lineStyle = "smooth",
			lineWidth = 1,
			x = 755,
			y = 504,
			r = 4
		},
	}
})

local ModifierViewConfig = {
	Frames,
	ContainerBegin,
	AvailableModifierList,
	ModifierList,
	AvailableModifierScrollBar,
	Rectangle,
	Circle,
	ContainerEnd,
	require("sphere.views.DebugInfoViewConfig"),
	Tooltip,
}

return ModifierViewConfig
