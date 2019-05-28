local Class = require("aqua.util.Class")
local StaticObject = require("sphere.game.PlayField.StaticObject")
local InputObject = require("sphere.game.PlayField.InputObject")
local TextDisplay = require("sphere.game.PlayField.TextDisplay")
local ScoreDisplay = require("sphere.game.PlayField.ScoreDisplay")

local PlayField = Class:new()

PlayField.load = function(self)
	self.cs = self.noteSkin:getCS()
	
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
	local object = StaticObject:new(objectData)
	object.playField = self
	object.container = self.container
	object.cs = self.cs
	object:load()
	table.insert(self.objects, object)
end

PlayField.loadInputObject = function(self, objectData)
	local object = InputObject:new(objectData)
	object.playField = self
	object.container = self.container
	object.cs = self.cs
	object:load()
	table.insert(self.objects, object)
end

PlayField.loadScoreDisplay = function(self, objectData)
	local object = ScoreDisplay:new(objectData)
	object.playField = self
	object.container = self.container
	object.cs = self.cs
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
