PlayField = createClass(soul.SoulObject)

PlayField.layer = 0.5

PlayField.drawable = love.graphics.newImage("resources/playfield.png")

PlayField.load = function(self)
	self.cs = self.engine.noteSkin.cs
	
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