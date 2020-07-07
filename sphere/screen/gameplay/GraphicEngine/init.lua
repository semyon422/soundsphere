local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local NoteDrawer		= require("sphere.screen.gameplay.GraphicEngine.NoteDrawer")
local GameConfig		= require("sphere.config.GameConfig")
local tween				= require("tween")

local GraphicEngine = Class:new()

GraphicEngine.construct = function(self)
	self.observable = Observable:new()

	self.localAliases = {}
	self.globalAliases = {}
end

GraphicEngine.load = function(self)
	self.noteCount = 0
	self.currentTime = 0
	self.timeRate = 1
	
	self:loadNoteDrawers()
	
	self.noteSkin.visualTimeRate = GameConfig:get("speed")
	self.noteSkin.targetVisualTimeRate = GameConfig:get("speed")
end

GraphicEngine.update = function(self, dt)
	self:updateNoteDrawers()
	
	self.noteSkin:update(dt)
end

GraphicEngine.unload = function(self)
	self:unloadNoteDrawers()
end

GraphicEngine.draw = function(self)
	self.noteSkin:draw()
end

GraphicEngine.receive = function(self, event)
	for noteDrawer in pairs(self.noteDrawers) do
		noteDrawer:receive(event)
	end

	if event.name == "TimeState" then
		self.currentTime = event.currentTime
		self.timeRate = event.timeRate
		if event.timeRate ~= 0 then
			self.noteSkin.timeRate = event.timeRate
		end
		return
	end

	if event.name == "resize" then
		self:reloadNoteDrawers()
	elseif event.name == "keypressed" then
		local key = event.args[1]
		local delta = 0.05
		
		if key == GameConfig:get("gameplay.invertPlaySpeed") then
			self.noteSkin.targetVisualTimeRate = -self.noteSkin.targetVisualTimeRate
			self.noteSkin:setVisualTimeRate(self.noteSkin.targetVisualTimeRate)
			return self.observable:send({
				name = "notify",
				text = "visualTimeRate: " .. self.noteSkin.targetVisualTimeRate
			})
		elseif key == GameConfig:get("gameplay.decreasePlaySpeed") then
			if math.abs(self.noteSkin.targetVisualTimeRate - delta) > 0.001 then
				self.noteSkin.targetVisualTimeRate = self.noteSkin.targetVisualTimeRate - delta
				self.noteSkin:setVisualTimeRate(self.noteSkin.targetVisualTimeRate)
			else
				self.noteSkin.targetVisualTimeRate = 0
				self.noteSkin:setVisualTimeRate(self.noteSkin.targetVisualTimeRate)
			end
			return self.observable:send({
				name = "notify",
				text = "visualTimeRate: " .. self.noteSkin.targetVisualTimeRate
			})
		elseif key == GameConfig:get("gameplay.increasePlaySpeed") then
			if math.abs(self.noteSkin.targetVisualTimeRate + delta) > 0.001 then
				self.noteSkin.targetVisualTimeRate = self.noteSkin.targetVisualTimeRate + delta
				self.noteSkin:setVisualTimeRate(self.noteSkin.targetVisualTimeRate)
			else
				self.noteSkin.targetVisualTimeRate = 0
				self.noteSkin:setVisualTimeRate(self.noteSkin.targetVisualTimeRate)
			end
			return self.observable:send({
				name = "notify",
				text = "visualTimeRate: " .. self.noteSkin.targetVisualTimeRate
			})
		end
	end
end

GraphicEngine.getLogicalNote = function(self, noteData)
	return self.logicEngine.sharedLogicalNotes[noteData]
end

GraphicEngine.getNoteDrawer = function(self, layerIndex, inputType, inputIndex)
	return NoteDrawer:new({
		layerIndex = layerIndex,
		inputType = inputType,
		inputIndex = inputIndex,
		graphicEngine = self
	})
end

GraphicEngine.loadNoteDrawers = function(self)
	self.noteDrawers = {}
	for layerIndex in self.noteChart:getLayerDataIndexIterator() do
		local layerData = self.noteChart:requireLayerData(layerIndex)
		if not layerData.invisible then
			for inputType, inputIndex in self.noteChart:getInputIteraator() do
				local noteDrawer = self:getNoteDrawer(layerIndex, inputType, inputIndex)
				if noteDrawer then
					self.noteDrawers[noteDrawer] = noteDrawer
					noteDrawer:load()
				end
			end
		end
	end
end

GraphicEngine.updateNoteDrawers = function(self)
	for noteDrawer in pairs(self.noteDrawers) do
		noteDrawer:update()
	end
end

GraphicEngine.unloadNoteDrawers = function(self)
	for noteDrawer in pairs(self.noteDrawers) do
		noteDrawer:unload()
	end
	self.noteDrawers = nil
end

GraphicEngine.reloadNoteDrawers = function(self)
	for noteDrawer in pairs(self.noteDrawers) do
		noteDrawer:reload()
	end
end

return GraphicEngine
