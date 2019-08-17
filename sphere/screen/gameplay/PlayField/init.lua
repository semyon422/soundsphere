local Class			= require("aqua.util.Class")
local InputObject	= require("sphere.screen.gameplay.PlayField.InputObject")
local ScoreDisplay	= require("sphere.screen.gameplay.PlayField.ScoreDisplay")
local StaticObject	= require("sphere.screen.gameplay.PlayField.StaticObject")
local TextDisplay	= require("sphere.screen.gameplay.PlayField.TextDisplay")

local PlayField = Class:new()

PlayField.load = function(self)
	self.objects = {}
	
	for _, objectData in ipairs(self.playFieldData) do
		if objectData.type == "static" then
			self:loadStaticObject(objectData)
		elseif objectData.type == "input" then
			self:loadInputObject(objectData)
		elseif objectData.type == "score" then
			self:loadScoreDisplay(objectData)
		end
	end
end

PlayField.loadStaticObject = function(self, objectData)
	objectData.csi = objectData.csi or objectData.cs
	local object = StaticObject:new(objectData)
	object.playField = self
	object.container = self.container
	object.cs = self.noteSkin.cses[objectData.csi]
	object:load()
	table.insert(self.objects, object)
end

PlayField.loadInputObject = function(self, objectData)
	objectData.csi = objectData.csi or objectData.cs
	local object = InputObject:new(objectData)
	object.playField = self
	object.container = self.container
	object.cs = self.noteSkin.cses[objectData.csi]
	object:load()
	table.insert(self.objects, object)
end

PlayField.loadScoreDisplay = function(self, objectData)
	objectData.csi = objectData.csi or objectData.cs
	local object = ScoreDisplay:new(objectData)
	object.playField = self
	object.container = self.container
	object.cs = self.noteSkin.cses[objectData.csi]
	object.score = self.score
	object:load()
	table.insert(self.objects, object)
end

PlayField.update = function(self)
	for _, object in ipairs(self.objects) do
		object:update()
	end
end

PlayField.unload = function(self)
	for _, object in ipairs(self.objects) do
		object:unload()
	end
end

PlayField.receive = function(self, event)
	for _, object in ipairs(self.objects) do
		object:receive(event)
	end
end

return PlayField
