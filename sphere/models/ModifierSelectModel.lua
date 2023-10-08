local class = require("class")
local table_util = require("table_util")

---@class sphere.ModifierSelectModel
---@operator call: sphere.ModifierSelectModel
local ModifierSelectModel = class()

local Modifiers = {
	"AutoKeySound",
	"ConstSpeed",
	"TimeRateQ",
	"TimeRateX",
	"WindUp",
	"NoScratch",
	"NoLongNote",
	"Automap",
	"MultiplePlay",
	"MultiOverPlay",
	"Alternate",
	"Alternate2",
	"Shift",
	"Mirror",
	"Random",
	"BracketSwap",
	"MaxChord",
	"LessChord",
	"FullLongNote",
	"MinLnLength",
}
ModifierSelectModel.modifiers = Modifiers

local OneUseModifiers = {
	"AutoKeySound",
	"ConstSpeed",
	"TimeRateQ",
	"TimeRateX",
	"WindUp",
	"NoScratch",
	"NoLongNote",
}

---@param modifierModel sphere.ModifierModel
function ModifierSelectModel:new(modifierModel)
	self.modifierModel = modifierModel
	self.modifierIndex = 1
	self.availableModifierIndex = 1

	self.addedModifiers = {}
	for _, name in ipairs(Modifiers) do
		self.addedModifiers[name] = 0
	end
end

---@return boolean
function ModifierSelectModel:isChanged()
	local changed = self.changed
	self.changed = false
	return changed
end

function ModifierSelectModel:change()
	self.changed = true
end

function ModifierSelectModel:updateAdded()
	for _, name in ipairs(Modifiers) do
		self.addedModifiers[name] = 0
	end
	for _, c in ipairs(self.modifierModel.config) do
		self.addedModifiers[c.name] = self.addedModifiers[c.name] + 1
	end
end

---@return boolean
function ModifierSelectModel:isAdded(modifier)
	return self.addedModifiers[modifier] > 0
end

---@param direction number
function ModifierSelectModel:scrollAvailableModifier(direction)
	if not Modifiers[self.availableModifierIndex + direction] then
		return
	end
	self.availableModifierIndex = self.availableModifierIndex + direction
end

---@param direction number
function ModifierSelectModel:scrollModifier(direction)
	local index = self.modifierIndex + direction
	if index < 1 or index > #self.modifierModel.config + 1 then
		return
	end
	self.modifierIndex = index
end

---@param modifier string
---@return boolean
function ModifierSelectModel:isOneUse(modifier)
	return table_util.indexof(OneUseModifiers, modifier) ~= nil
end

---@param modifier string
---@return number
function ModifierSelectModel:getMinimalModifierIndex(modifier)
	local index = 1
	for _, ou_modifier in ipairs(OneUseModifiers) do
		if self:isAdded(ou_modifier) then
			index = index + 1
		end
		if modifier == ou_modifier then
			return index
		end
	end
	return index
end

---@param modifier string
function ModifierSelectModel:add(modifier)
	local minimalModifierIndex = self:getMinimalModifierIndex(modifier)
	local index = math.max(self.modifierIndex, minimalModifierIndex)
	if self:isOneUse(modifier) then
		if self.addedModifiers[modifier] > 0 then
			return
		end
		index = minimalModifierIndex
	end
	self.modifierModel:add(modifier, index)
	self.modifierIndex = index + 1
	self.addedModifiers[modifier] = self.addedModifiers[modifier] + 1
	self:change()
end

---@param index number
function ModifierSelectModel:remove(index)
	local modifierConfig = self.modifierModel:remove(index)
	if not self.modifierModel.config[self.modifierIndex] then
		self.modifierIndex = math.max(self.modifierIndex - 1, 0)
	end
	if modifierConfig then
		local modifier = modifierConfig.name
		self.addedModifiers[modifier] = self.addedModifiers[modifier] - 1
	end
	self:change()
end

return ModifierSelectModel
