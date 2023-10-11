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

---@param config table
function ModifierModel:setConfig(config)
	self.config = config
end

---@param nameOrId string|number?
---@return sphere.Modifier?
function ModifierModel:getModifier(nameOrId)
	return ModifiersByName[nameOrId] or ModifiersById[nameOrId]
end

---@param modifier string
---@param index number
function ModifierModel:add(modifier, index)
	local mod = assert(self:getModifier(modifier))
	table.insert(self.config, index, mod:getDefaultConfig())
end

---@param index number
---@return table?
function ModifierModel:remove(index)
	return table.remove(self.config, index)
end

---@param modifierConfig table
---@param value any
function ModifierModel:setModifierValue(modifierConfig, value)
	local mod = assert(self:getModifier(modifierConfig.name))
	mod:setValue(modifierConfig, value)
end

---@param modifierConfig table
---@param delta number
function ModifierModel:increaseModifierValue(modifierConfig, delta)
	local mod = assert(self:getModifier(modifierConfig.name))
	local indexValue = mod:toIndexValue(modifierConfig.value)
	mod:setValue(modifierConfig, mod:fromIndexValue(indexValue + delta))
end

---@param noteChart ncdk.NoteChart
function ModifierModel:apply(noteChart)
	local obj = {}
	obj.noteChart = noteChart
	for _, modifierConfig in ipairs(self.config) do
		local mod = self:getModifier(modifierConfig.name)
		if mod then
			table_util.clear(obj)
			setmetatable(obj, mod)
			obj:apply(modifierConfig)
		end
	end
end

---@param state table
function ModifierModel:applyMeta(state)
	local obj = {}
	for _, modifierConfig in ipairs(self.config) do
		local mod = self:getModifier(modifierConfig.name)
		if mod then
			table_util.clear(obj)
			setmetatable(obj, mod)
			obj:applyMeta(modifierConfig, state)
		end
	end
end

---@param config table
---@return string
function ModifierModel:getString(config)
	config = config or self.config
	local t = {}
	for _, modifierConfig in ipairs(config) do
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

---@param oldConfig table
function ModifierModel:fixOldFormat(oldConfig)
	for _, modifierConfig in ipairs(oldConfig) do
		local mod = self:getModifier(modifierConfig.name)
		if mod then
			if type(modifierConfig.value) == "number" and type(mod.defaultValue) == "string" then
				modifierConfig.value = mod:fromIndexValue(modifierConfig.value)
			end
		end
	end
end

return ModifierModel
