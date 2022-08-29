local Class = require("aqua.util.Class")
local SequenceView = require("sphere.views.SequenceView")
local just = require("just")

local ModifierViewConfig = require("sphere.views.ModifierView.ModifierViewConfig")

local ModifierView = Class:new()

ModifierView.construct = function(self)
	self.sequenceView = SequenceView:new()
	self.viewConfig = ModifierViewConfig

	self.isOpen = false
	self.activeList = "modifierList"
end

ModifierView.toggle = function(self, state)
	if state == nil then
		self.isOpen = not self.isOpen
	else
		self.isOpen = state
	end
end

ModifierView.draw = function(self)
	if not self.isOpen then
		return
	end

	self.sequenceView:draw()

	just.container("modifier keyboard", true)
	if not just.keyboard_over() then
		just.container()
		return
	end

	local kp = just.keypressed

	local modifierModel = self.game.modifierModel
	if self.activeList == "modifierList" then
		if kp("up") then modifierModel:scrollModifier(-1)
		elseif kp("down") then modifierModel:scrollModifier(1)
		elseif kp("tab") then self.activeList = "availableModifierList"
		elseif kp("return") then
		elseif kp("backspace") then modifierModel:remove()
		elseif kp("right") then modifierModel:increaseModifierValue(nil, 1)
		elseif kp("left") then modifierModel:increaseModifierValue(nil, -1)
		end
	elseif self.activeList == "availableModifierList" then
		if kp("up") then modifierModel:scrollAvailableModifier(-1)
		elseif kp("down") then modifierModel:scrollAvailableModifier(1)
		elseif kp("tab") then self.activeList = "modifierList"
		elseif kp("return") then modifierModel:add()
		end
	end
	if kp("f1") or kp("escape") then self:toggle(false) end

	just.container()
end

ModifierView.load = function(self)
	local sequenceView = self.sequenceView

	sequenceView.game = self.game
	sequenceView:setSequenceConfig(self.viewConfig)
	sequenceView:load()
end

ModifierView.unload = function(self)
	self.sequenceView:unload()
end

ModifierView.receive = function(self, event)
	self.sequenceView:receive(event)
end

ModifierView.update = function(self, dt)
	self.sequenceView:update(dt)
end

return ModifierView
