local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local NoteDrawer		= require("sphere.screen.gameplay.GraphicEngine.NoteDrawer")
local NoteSkin			= require("sphere.screen.gameplay.GraphicEngine.NoteSkin")
local Config			= require("sphere.config.Config")
local tween				= require("tween")

local GraphicEngine = Class:new()

GraphicEngine.load = function(self)
	self.observable = Observable:new()
	
	self.noteCount = 0
	
	self:loadNoteDrawers()
	
	NoteSkin.visualTimeRate = Config.data.speed
	NoteSkin.targetVisualTimeRate = Config.data.speed
end

GraphicEngine.update = function(self, dt)
	self.currentTime = self.logicEngine.currentTime
	self.timeRate = self.logicEngine.timeRate
	NoteSkin.timeRate = self.timeRate

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
	if event.name == "resize" then
		self:reloadNoteDrawers()
	elseif event.name == "keypressed" then
		local key = event.args[1]
		local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
		local control = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
		local delta
		if shift and control then
			delta = 5
		elseif shift then
			delta = 0.05
		elseif control then
			delta = 1
		else
			delta = 0.1
		end
		if key == "f2" then
			NoteSkin.targetVisualTimeRate = -NoteSkin.targetVisualTimeRate
			NoteSkin:setVisualTimeRate(NoteSkin.targetVisualTimeRate)
			return self.observable:send({
				name = "notify",
				text = "visualTimeRate: " .. NoteSkin.targetVisualTimeRate
			})
		elseif key == "f3" then
			if math.abs(NoteSkin.targetVisualTimeRate - delta) > 0.001 then
				NoteSkin.targetVisualTimeRate = NoteSkin.targetVisualTimeRate - delta
				NoteSkin:setVisualTimeRate(NoteSkin.targetVisualTimeRate)
			else
				NoteSkin.targetVisualTimeRate = 0
				NoteSkin:setVisualTimeRate(NoteSkin.targetVisualTimeRate)
			end
			return self.observable:send({
				name = "notify",
				text = "visualTimeRate: " .. NoteSkin.targetVisualTimeRate
			})
		elseif key == "f4" then
			if math.abs(NoteSkin.targetVisualTimeRate + delta) > 0.001 then
				NoteSkin.targetVisualTimeRate = NoteSkin.targetVisualTimeRate + delta
				NoteSkin:setVisualTimeRate(NoteSkin.targetVisualTimeRate)
			else
				NoteSkin.targetVisualTimeRate = 0
				NoteSkin:setVisualTimeRate(NoteSkin.targetVisualTimeRate)
			end
			return self.observable:send({
				name = "notify",
				text = "visualTimeRate: " .. NoteSkin.targetVisualTimeRate
			})
		end
	end
end

GraphicEngine.getLogicalNote = function(self, noteData)
	return self.logicEngine.sharedLogicalNoteData[noteData]
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
