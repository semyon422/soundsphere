local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")
local Node = require("aqua.util.Node")

local ModifierNavigator = Navigator:new()

ModifierNavigator.construct = function(self)
	Navigator.construct(self)

	local availableModifierList = Node:new()
	self.availableModifierList = availableModifierList
	availableModifierList.selected = 1

	local modifierList = Node:new()
	self.modifierList = modifierList
	modifierList.selected = 1
end

ModifierNavigator.load = function(self)
    Navigator.load(self)

	local availableModifierList = self.availableModifierList
	local modifierList = self.modifierList

	self.node = modifierList
	modifierList:on("up", function()
		self:scrollModifier(-1)
	end)
	modifierList:on("down", function()
		self:scrollModifier(1)
	end)
	modifierList:on("left", function()
		self.node = availableModifierList
	end)
	modifierList:on("return", function()
		self:send({
			action = "playNoteChart",
		})
	end)

	availableModifierList:on("up", function()
		self:scrollAvailableModifier(-1)
	end)
	availableModifierList:on("down", function()
		self:scrollAvailableModifier(1)
	end)
	availableModifierList:on("right", function()
		self.node = modifierList
	end)
end

ModifierNavigator.receive = function(self, event)
	if event.name == "wheelmoved" then
		local y = event.args[2]
		if y == 1 then
			self:call("up")
		elseif y == -1 then
			self:call("down")
		end
	elseif event.name == "mousepressed" then
		self:call("return")
	elseif event.name == "keypressed" then
		self:call(event.args[1])
	end
end

return ModifierNavigator
