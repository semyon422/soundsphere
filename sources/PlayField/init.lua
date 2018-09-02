PlayField = createClass(soul.SoulObject)
require("PlayField.StaticObject")
require("PlayField.InputObject")

PlayField.load = function(self)
	self.cs = self.engine.noteSkin:getCS()

	self:loadObjects()
	
	self.observer:subscribe(self.engine.observable)
end

PlayField.loadObjects = function(self)
	self.objects = {}
	
	for _, objectData in ipairs(self.playFieldData) do
		if objectData.type == "static" then
			self:loadStaticObject(objectData)
		elseif objectData.type == "input" then
			self:loadInputObject(objectData)
		end
	end
end

PlayField.loadStaticObject = function(self, objectData)
	local object = PlayField.StaticObject:new(objectData)
	object.playField = self
	object.cs = self.cs
	object:activate()
	object.observer:subscribe(self.engine.observable)
	table.insert(self.objects, object)
end

PlayField.loadInputObject = function(self, objectData)
	local object = PlayField.InputObject:new(objectData)
	object.playField = self
	object.cs = self.cs
	object:activate()
	object.observer:subscribe(self.engine.observable)
	table.insert(self.objects, object)
end

PlayField.unloadObjects = function(self)
	for _, object in ipairs(self.objects) do
		object:deactivate()
	end
end

PlayField.unload = function(self)
	self:unloadObjects()
end