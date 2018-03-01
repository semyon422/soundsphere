soul.ui.UIObject = createClass(soul.SoulObject)
local UIObject = soul.ui.UIObject

UIObject.group = "*"
UIObject.action = function(self) end

UIObject.interact = function(self)
	if soul.ui.accessableGroups[self.group] then
		self:action()
	end
end