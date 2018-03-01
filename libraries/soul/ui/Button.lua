soul.ui.Button = createClass(soul.ui.UIObject)
local Button = soul.ui.Button

Button.loadCallbacks = function(self)
	soul.setCallback("mousepressed", self, function(mx, my)
		local x = self.cs:X(self.x, true)
		local y = self.cs:Y(self.y, true)
		local w = self.cs:X(self.w)
		local h = self.cs:Y(self.h)
		if belong(mx, x, x + w, my, y, y + h) then
			self:interact()
		end
	end)
end

Button.unloadCallbacks = function(self)
	soul.unsetCallback("mousepressed", self)
end

Button.load = function(self)
	if self.loadBackground then self:loadBackground() end
	if self.loadForeground then self:loadForeground() end
	self:loadCallbacks()
	
	self.loaded = true
end

Button.unload = function(self)
	if self.unloadBackground then self:unloadBackground() end
	if self.unloadForeground then self:unloadForeground() end
	self:unloadCallbacks()
	
	self.loaded = false
end