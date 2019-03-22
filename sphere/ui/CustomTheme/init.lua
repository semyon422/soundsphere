local Class = require("aqua.util.Class")
local aquajson = require("aqua.util.json")
local Handler = require("sphere.ui.CustomTheme.Handler")
local ObjectFactory = require("sphere.ui.CustomTheme.ObjectFactory")

local CustomTheme = Class:new()

CustomTheme.load = function(self, path)
	self.objects = {}
	self.themeData = aquajson.read(path)
	
	for _, objectData in ipairs(self.themeData) do
		self:loadObject(objectData)
	end
end

CustomTheme.loadObject = function(self, objectData)
	local object = ObjectFactory:getObject(objectData)
	object.container = self.container
	object.observable:add(Handler)
	object:load()
	table.insert(self.objects, object)
end

CustomTheme.update = function(self)
	for _, object in ipairs(self.objects) do
		object:update()
	end
end

CustomTheme.unload = function(self)
	for _, object in ipairs(self.objects) do
		object:unload()
	end
end

CustomTheme.receive = function(self, event)
	for _, object in ipairs(self.objects) do
		object:receive(event)
	end
end

return CustomTheme
