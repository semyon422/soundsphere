local Circle			= require("aqua.graphics.Circle")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Image				= require("aqua.graphics.Image")
local Line				= require("aqua.graphics.Line")
local map				= require("aqua.math").map
local NoteChartManager	= require("sphere.database.NoteChartManager")
local Button			= require("sphere.ui.Button")

local CacheManagerDisplay = Button:new()

CacheManagerDisplay.loadGui = function(self)
	Button.loadGui(self)

	self.interact = function()
		self:processCache()
	end
end

CacheManagerDisplay.load = function(self)
	NoteChartManager.observable:add(self)
	self.state = 0

	Button.load(self)

	self:updateState()
end

CacheManagerDisplay.updateState = function(self)

end

CacheManagerDisplay.processCache = function(self)
	if self.state == 0 or self.state == 3 then
		NoteChartManager:updateCache()
	else
		NoteChartManager:stopCache()
	end
end

CacheManagerDisplay.update = function(self)

	Button.update(self)
end

CacheManagerDisplay.draw = function(self)

	Button.draw(self)
end

CacheManagerDisplay.unload = function(self)
	NoteChartManager.observable:remove(self)

	Button.unload(self)
end

CacheManagerDisplay.receive = function(self, event)
	if event.name == "resize" then
		self.circle:reload()
	elseif event.name == "NoteChartManagerState" then
		if event.state == 1 then
			self.button.text = ("searching for charts: %d"):format(event.noteChartCount)
			self.button:reload()
		elseif event.state == 2 then
			self.button.text = ("creating cache: %0.2f%%"):format(event.cachePercent)
			self.button:reload()
		elseif event.state == 3 then
			self.button.text = "complete"
			self.button:reload()
		elseif event.state == 0 then
			self.button.text = "refresh"
			self.button:reload()
		end
		self.state = event.state
	end

	Button.receive(self, event)
end

return CacheManagerDisplay
