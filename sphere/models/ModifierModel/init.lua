local class = require("class")
local table_util = require("table_util")

---@class sphere.ModifierModel
---@operator call: sphere.ModifierModel
local ModifierModel = class()

local Modifiers = {
	-- AutoPlay = 0,
	-- ProMode = 1,
	AutoKeySound = 2,
	ConstSpeed = 3,
	TimeRateQ = 4,
	TimeRateX = 5,
	WindUp = 6,
	-- AudioClip = 7,
	NoScratch = 8,
	NoLongNote = 9,
	-- NoMeasureLine = 10,
	Automap = 11,
	MultiplePlay = 12,
	MultiOverPlay = 13,
	Alternate = 14,
	Shift = 15,
	Mirror = 16,
	Random = 17,
	BracketSwap = 18,
	FullLongNote = 19,
	MinLnLength = 20,
	-- ToOsu = 21,
	Alternate2 = 22,
	LessChord = 23,
	MaxChord = 24,
}
ModifierModel.Modifiers = Modifiers

local ModifiersByName = {}
local ModifiersById = {}
ModifierModel.ModifiersByName = ModifiersByName
ModifierModel.ModifiersById = ModifiersById

for name, id in pairs(Modifiers) do
	local M = require("sphere.models.ModifierModel." .. name)
	ModifiersByName[name] = M
	ModifiersById[id] = M
end

---@param nameOrId string|number?
---@return sphere.Modifier?
function ModifierModel:getModifier(nameOrId)
	return ModifiersByName[nameOrId] or ModifiersById[nameOrId]
end

---@param modifiers table
---@param modifier string
---@param index number
function ModifierModel:add(modifiers, modifier, index)
	local mod = assert(self:getModifier(modifier))
	table.insert(modifiers, index, mod:getDefaultConfig())
end

---@param modifiers table
---@param index number
---@return table?
function ModifierModel:remove(modifiers, index)
	return table.remove(modifiers, index)
end

---@param modifier table
---@param value any
function ModifierModel:setModifierValue(modifier, value)
	local mod = assert(self:getModifier(modifier.name))
	mod:setValue(modifier, value)
end

---@param modifier table
---@param delta number
function ModifierModel:increaseModifierValue(modifier, delta)
	local mod = assert(self:getModifier(modifier.name))
	local indexValue = mod:toIndexValue(modifier.value)
	mod:setValue(modifier, mod:fromIndexValue(indexValue + delta))
end

---@param modifiers table
---@param noteChart ncdk.NoteChart
function ModifierModel:apply(modifiers, noteChart)
	local obj = {}
	for _, modifierConfig in ipairs(modifiers) do
		local mod = self:getModifier(modifierConfig.name)
		if mod then
			table_util.clear(obj)
			obj.noteChart = noteChart
			setmetatable(obj, mod)
			obj:apply(modifierConfig)
		end
	end
end

---@param modifiers table
---@param state table
function ModifierModel:applyMeta(modifiers, state)
	local obj = {}
	for _, modifierConfig in ipairs(modifiers) do
		local mod = self:getModifier(modifierConfig.name)
		if mod then
			table_util.clear(obj)
			setmetatable(obj, mod)
			obj:applyMeta(modifierConfig, state)
		end
	end
end

---@param modifiers table
---@return string
function ModifierModel:getString(modifiers)
	local t = {}
	for _, modifierConfig in ipairs(modifiers) do
		local mod = self:getModifier(modifierConfig.name)
		if mod then
			local s, subs = mod:getString(modifierConfig)
			local str = (s or "") .. (subs or "")
			if #str > 0 then
				table.insert(t, str)
			end
		end
	end
	return table.concat(t, " ")
end

---@param modifiers table
function ModifierModel:fixOldFormat(modifiers)
	for _, modifierConfig in ipairs(modifiers) do
		local mod = self:getModifier(modifierConfig.name)
		if mod then
			if type(modifierConfig.value) == "number" and type(mod.defaultValue) == "string" then
				modifierConfig.value = mod:fromIndexValue(modifierConfig.value)
			end
		end
	end
end

return ModifierModel
