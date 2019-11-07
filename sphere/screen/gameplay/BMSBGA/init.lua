local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Class				= require("aqua.util.Class")
local NoteHandler		= require("sphere.screen.gameplay.BMSBGA.NoteHandler")

local BMSBGA = Class:new()

BMSBGA.timeRate = 1

BMSBGA.construct = function(self)
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
end

BMSBGA.setColor = function(self, color)
	self.color = color
end

BMSBGA.load = function(self)
	self:loadNoteHandlers()
end

BMSBGA.getNoteHandler = function(self, inputType, inputIndex)
	if inputType == "bmsbga" then
		return NoteHandler:new({
			bga = self,
			engine = self.engine,
			inputIndex = inputIndex
		})
	end
end

BMSBGA.loadNoteHandlers = function(self)
	self.noteHandlers = {}
	for inputType, inputIndex in self.noteChart:getInputIteraator() do
		local noteHandler = self:getNoteHandler(inputType, inputIndex)
		if noteHandler then
			self.noteHandlers[inputIndex] = noteHandler
			noteHandler:load()
		end
	end
end

BMSBGA.updateNoteHandlers = function(self, dt)
	if not self.noteHandlers then return end
	for _, noteHandler in pairs(self.noteHandlers) do
		noteHandler:update(dt)
	end
end

local drawOrder = {0x04, 0x07, 0x0A}
BMSBGA.drawNoteHandlers = function(self)
	if not self.noteHandlers then return end
	for _, inputIndex in ipairs(drawOrder) do
		local noteHandler = self.noteHandlers[inputIndex]
		if noteHandler then
			noteHandler:draw()
		end
	end
end

BMSBGA.unloadNoteHandlers = function(self)
	if not self.noteHandlers then return end
	for _, noteHandler in pairs(self.noteHandlers) do
		noteHandler:unload()
	end
	self.noteHandlers = nil
end

BMSBGA.unload = function(self)
	self:unloadNoteHandlers()
end

BMSBGA.update = function(self, dt)
	self:updateNoteHandlers(dt)
end

BMSBGA.draw = function(self)
	self:drawNoteHandlers()
end

BMSBGA.setTimeRate = function(self, timeRate)
	self.timeRate = timeRate
	if not self.noteHandlers then return end
	for _, noteHandler in pairs(self.noteHandlers) do
		noteHandler:setTimeRate(timeRate)
	end
end

BMSBGA.pause = function(self)
	if not self.noteHandlers then return end
	for _, noteHandler in pairs(self.noteHandlers) do
		noteHandler:pause()
	end
end

BMSBGA.play = function(self)
	if not self.noteHandlers then return end
	for _, noteHandler in pairs(self.noteHandlers) do
		noteHandler:play()
	end
end

BMSBGA.receive = function(self, event)
	if not self.noteHandlers then return end
	for _, noteHandler in pairs(self.noteHandlers) do
		noteHandler:receive(event)
	end
end

return BMSBGA
