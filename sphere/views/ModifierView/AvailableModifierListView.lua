local ListView = require("sphere.views.ListView")
local just = require("just")
local gfx_util = require("gfx_util")
local spherefonts = require("sphere.assets.fonts")
local ModifierModel = require("sphere.models.ModifierModel")
local ModifierRegistry = require("sphere.models.ModifierModel.ModifierRegistry")

local AvailableModifierListView = ListView()

AvailableModifierListView.rows = 11

function AvailableModifierListView:reloadItems()
	self.items = ModifierRegistry.list
end

---@return number
function AvailableModifierListView:getItemIndex()
	return self.game.modifierSelectModel.availableModifierIndex
end

---@param count number
function AvailableModifierListView:scroll(count)
	self.game.modifierSelectModel:scrollAvailableModifier(count)
end

---@param i number
---@param w number
---@param h number
function AvailableModifierListView:drawItem(i, w, h)
	local modifierSelectModel = self.game.modifierSelectModel

	local item = self.items[i]
	local prevItem = self.items[i - 1]

	local id = "available modifier" .. i
	local changed, active, hovered = just.button(id, just.is_over(w, h))
	if changed then
		local modifier = self.items[i]
		modifierSelectModel:add(modifier)
	end

	if hovered then
		local alpha = active and 0.2 or 0.1
		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.rectangle("fill", 0, 0, w, h)
	end
	love.graphics.setColor(1, 1, 1, 1)

	if modifierSelectModel:isOneUse(item) and modifierSelectModel:isAdded(item) then
		love.graphics.setColor(1, 1, 1, 0.5)
	end

	local mod = ModifierModel:getModifier(item)

	just.row(true)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	gfx_util.printFrame(mod.name, 44, 0, w - 44, h, "left", "center")
	if just.mouse_over(id, just.is_over(w, h), "mouse") then
		self.game.gameView.tooltip = mod.description
	end

	love.graphics.setColor(1, 1, 1, 1)
	if not prevItem or modifierSelectModel:isOneUse(prevItem) ~= modifierSelectModel:isOneUse(item) then
		local text = "One use modifiers"
		if not modifierSelectModel:isOneUse(item) then
			text = "Sequential modifiers"
		end
		love.graphics.setFont(spherefonts.get("Noto Sans", 16))
		gfx_util.printFrame(text, 0, 0, w - 22, h / 4, "right", "center")
	end
	just.row()
end

return AvailableModifierListView
