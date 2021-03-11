local viewspackage = (...):match("^(.-%.views%.)")

local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")

local SettingsListItemView = require(viewspackage .. "settings.SettingsListItemView")
local SliderView = require(viewspackage .. "SliderView")

local SettingsListItemSliderView = SettingsListItemView:new()

SettingsListItemSliderView.init = function(self)
	self:on("draw", self.draw)

	self.fontName = aquafonts.getFont(spherefonts.NotoSansRegular, 24)

	self.sliderView = SliderView:new()
end

SettingsListItemSliderView.draw = function(self)
	local listView = self.listView

	local itemIndex = self.itemIndex
	local item = self.item

	local cs = listView.cs

	local x, y, w, h = self:getPosition()

    local settingConfig = item
    -- local modifier = listView.view.modifierModel:getSettings(modifierConfig)
    -- local realValue = modifier:getRealValue(modifierConfig)

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
		settingConfig.name .. " " .. 1,
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

	local sliderView = self.sliderView
	sliderView:setPosition(x + w / 2, y, w / 2, h)
	-- sliderView:setValue(modifier:getNormalizedValue(modifierConfig))
	sliderView:setValue(1)
	sliderView:draw()
end

SettingsListItemSliderView.receive = function(self, event)
	SettingsListItemView.receive(self, event)

	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end

	local listView = self.listView
	local x, y, w, h = self:getPosition()

	if listView.activeItem ~= self.itemIndex then
		return
	end

	local slider = listView.slider

	-- local modifierConfig = self.item
	-- local modifier = listView.view.modifierModel:getSettings(modifierConfig)
	slider:setPosition(x + w / 2, y, w / 2, h)
	-- slider:setValue(modifier:getNormalizedValue(modifierConfig))
	slider:setValue(1)
	slider:receive(event)

	if slider.valueUpdated then
		-- self.listView.navigator:send({
		-- 	name = "setSettingsValue",
		-- 	modifierConfig = modifierConfig,
		-- 	value = modifier:fromNormalizedValue(slider.value)
		-- })
		slider.valueUpdated = false
	end
end

SettingsListItemSliderView.wheelmoved = function(self, event)
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

return SettingsListItemSliderView
