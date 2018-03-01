soul.SoulObject = createClass()
local SoulObject = soul.SoulObject

SoulObject.loaded = false

SoulObject.update = function(self) end

SoulObject.load = function(self)
	self.loaded = true
end

SoulObject.unload = function(self)
	self.loaded = false
end

SoulObject.reload = function(self)
	if self.loaded then
		self:unload()
	end
	self:load()
end

SoulObject.deactivate = function(self)
	if self.loaded then
		self:unload()
	end
	soul.objects[self] = nil
end

SoulObject.activate = function(self)
	if not self.loaded then
		self:load()
	end
	soul.objects[self] = self
end