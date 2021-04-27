local viewspackage = (...):match("^(.-%.views%.)")

local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")

local ModifierListItemView = require(viewspackage .. "ModifierView.ModifierListItemView")
local StepperView = require(viewspackage .. "StepperView")

local ModifierListItemStepperView = ModifierListItemView:new()

ModifierListItemStepperView.init = function(self)
	self:on("draw", self.draw)

	self.fontName = aquafonts.getFont(spherefonts.NotoSansRegular, 24)

	self.stepperView = StepperView:new()
end

ModifierListItemStepperView.draw = function(self)
	local listView = self.listView

	local itemIndex = self.itemIndex
	local item = self.item

	local cs = listView.cs

	local x, y, w, h = self:getPosition()

    local modifierConfig = item
    local modifier = listView.view.modifierModel:getModifier(modifierConfig)

	local deltaItemIndex = math.abs(itemIndex - listView.selectedItem)
	if listView.isSelected then
		love.graphics.setColor(1, 1, 1,
			deltaItemIndex == 0 and 1 or 0.66
		)
	else
		love.graphics.setColor(1, 1, 1, 0.33)
	end

	love.graphics.setFont(self.fontName)
	love.graphics.printf(
		modifierConfig.name,
		x,
		y,
		w / cs.one * 1080,
		"left",
		0,
		cs.one / 1080,
		cs.one / 1080,
		-cs:X(0 / cs.one),
		-cs:Y(18 / cs.one)
	)
	love.graphics.printf(
		modifierConfig.value,
		x + w / 2,
		y,
		w / 2 / cs.one * 1080,
		"center",
		0,
		cs.one / 1080,
		cs.one / 1080,
		-cs:X(0 / cs.one),
		-cs:Y(18 / cs.one)
	)

	local stepperView = self.stepperView
	stepperView:setPosition(x + w / 2, y, w / 2, h)
	stepperView:setValue(modifier:toIndexValue(modifierConfig.value))
	stepperView:setCount(modifier:getCount())
	stepperView:draw()
end

ModifierListItemStepperView.receive = function(self, event)
	ModifierListItemView.receive(self, event)

	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end

	local listView = self.listView
	local x, y, w, h = self:getPosition()

	if listView.activeItem ~= self.itemIndex then
		return
	end

	local stepper = listView.stepper

	local modifierConfig = self.item
	local modifier = listView.view.modifierModel:getModifier(modifierConfig)
	stepper:setPosition(x + w / 2, y, w / 2, h)
	stepper:setValue(modifier:toIndexValue(modifierConfig.value))
	stepper:setCount(modifier:getCount())
	stepper:receive(event)

	if stepper.valueUpdated then
		self.listView.navigator:send({
			name = "setModifierValue",
			modifierConfig = modifierConfig,
			value = modifier:fromIndexValue(stepper.value)
		})
		stepper.valueUpdated = false
	end
end

ModifierListItemStepperView.wheelmoved = function(self, event)
	local x, y, w, h = self:getPosition()
	local mx, my = love.mouse.getPosition()

	if event.name == "wheelmoved" and not (mx >= x and mx <= x + w and my >= y and my <= y + h) then
		return
	end

	if mx >= x + w * 0.5 and mx <= x + w then
		local wy = event.args[2]
		if wy == 1 then
			self.listView.navigator:call("right", self.itemIndex)
		elseif wy == -1 then
			self.listView.navigator:call("left", self.itemIndex)
		end
	end
end

return ModifierListItemStepperView
