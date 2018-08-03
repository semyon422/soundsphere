PlayField = createClass(soul.SoulObject)

PlayField.layer = 0.5

PlayField.load = function(self)
	self.filePath = self.directoryPath .. "/" .. self.fileName
	self.cs = self.engine.noteSkin.cs
	
	self.config = SpaceConfig:new()
	self.config:init()
	self.config.observable:addObserver(self.observer)
	self.config:load(self.filePath)
	
	local fileName
	if
		self.config.data[self.engine.noteChart.inputMode:getString()] and
		self.config.data[self.engine.noteChart.inputMode:getString()][1]
	then
		fileName = self.config.data[self.engine.noteChart.inputMode:getString()][1]
	else
		return
	end
	
	self.drawable = love.graphics.newImage(self.directoryPath .. "/" .. fileName)
	self.drawableObject = soul.graphics.Drawable:new({
		drawable = self.drawable,
		layer = self.layer,
		cs = self.cs,
		x = 0,
		y = 0,
		sx = 1,
		sy = 1
	})
	self.drawableObject:activate()
	
	self.observer:subscribe(self.engine.observable)
end

PlayField.receiveEvent = function(self, event)
	if event.name == "love.update" then
		self:update()
	elseif event.name == "logicalNoteUpdated" then
		print(event.logicalNote.state)
	elseif event.name == "noteHandlerUpdated" then
		print(event.noteHandler.keyState, event.noteHandler.keyBind, event.noteHandler.inputType, event.noteHandler.inputIndex)
	end
end

PlayField.update = function(self)
	local scale = self.cs.screenHeight / self.drawable:getHeight()
	self.drawableObject.sx = scale
	self.drawableObject.sy = scale
end

PlayField.unload = function(self)
    self.drawableObject:deactivate()
end