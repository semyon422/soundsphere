PlayField = createClass(soul.SoulObject)
require("PlayField.StaticObject")
require("PlayField.InputObject")

PlayField.load = function(self)
	self.filePath = self.directoryPath .. "/" .. self.fileName
	self.inputMode = self.engine.noteChart.inputMode:getString()
	self.cs = self.engine.noteSkin:getCS({
		inputModeString = self.inputMode
	})
	
	self.config = SpaceConfig:new()
	self.config:init()
	self.config.observable:addObserver(self.observer)
	self.config:load(self.filePath)
	
	
	self:loadObjects()
	
	self.observer:subscribe(self.engine.observable)
end

PlayField.loadObjects = function(self)
	self.objects = {}
	
	for key, data in self.config:getKeyDataIterator() do
		if table.equal(key, {self.inputMode, "static", "image"}) then
			self:loadStaticObjects(key, data)
		elseif key[1] == self.inputMode and key[2] == "input" and key[4] == "image" and key[5] == "released" then
			self:loadInputObjects(key, data)
		end
	end
end

PlayField.loadStaticObjects = function(self, key, data)
	for i = 1, #data do
		local object = PlayField.StaticObject:new()
		object.filePath = self.directoryPath .. "/" .. data[i]
		object.layer = tonumber(self.config:getKeyTable({self.inputMode, "static", "layer"})[i]) or 0
		object.cs = self.cs
		object.x = self.config:getKeyTable({self.inputMode, "static", "x"})[i] or 0
		object.y = self.config:getKeyTable({self.inputMode, "static", "y"})[i] or 0
		object.w = self.config:getKeyTable({self.inputMode, "static", "w"})[i] or 0
		object.h = self.config:getKeyTable({self.inputMode, "static", "h"})[i] or 0
		object:activate()
		object.observer:subscribe(self.engine.observable)
		table.insert(self.objects, object)
	end
end

PlayField.loadInputObjects = function(self, key, data)
	for i = 1, #data do
		local object = PlayField.InputObject:new()
		object.filePathReleased = self.directoryPath .. "/" .. data[i]
		object.filePathPressed = self.config:getKeyTable({self.inputMode, "input", key[3], "image", "pressed"})[i]
		object.filePathPressed = object.filePathPressed and self.directoryPath .. "/" .. object.filePathPressed or object.filePathReleased
		object.layer = tonumber(self.config:getKeyTable({self.inputMode, "input", key[3], "layer"})[i]) or 0
		object.cs = self.cs
		object.x = self.config:getKeyTable({self.inputMode, "input", key[3], "x"})[i] or 0
		object.y = self.config:getKeyTable({self.inputMode, "input", key[3], "y"})[i] or 0
		object.w = self.config:getKeyTable({self.inputMode, "input", key[3], "w"})[i] or 0
		object.h = self.config:getKeyTable({self.inputMode, "input", key[3], "h"})[i] or 0
		object.inputType = key[3]
		object.inputIndex = i
		object:activate()
		object.observer:subscribe(self.engine.observable)
		table.insert(self.objects, object)
	end
end

PlayField.unloadObjects = function(self)
	for _, object in ipairs(self.objects) do
		object:deactivate()
	end
end

PlayField.unload = function(self)
	self:unloadObjects()
end