Group = createClass()

Group.inited = false

Group.init = function(self)
	self.objects = {}
	self.inited = true
end

Group.initCheck = function(self)
	if not self.inited then
		self:init()
	end
end

Group.addObject = function(self, object)
	self:initCheck()
	self.objects[object] = true
end

Group.removeObject = function(self, object)
	self:initCheck()
	self.objects[object] = nil
end

Group.call = function(self, func)
	self:initCheck()
	for object in pairs(self.objects) do
		func(object)
	end
end