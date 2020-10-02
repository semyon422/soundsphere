local BrowserList		= require("sphere.ui.BrowserList")
local Button			= require("sphere.ui.Button")

local CacheManagerDisplay = Button:new()

CacheManagerDisplay.loadGui = function(self)
	self.cacheModel = self.gui.cacheModel

	Button.loadGui(self)
end

CacheManagerDisplay.load = function(self)
	self.cacheModel.observable:add(self)
	self.state = 0

	self.interact = function()
		self:processCache()
	end

	Button.load(self)

	self:updateState()
end

CacheManagerDisplay.updateState = function(self)

end

CacheManagerDisplay.processCache = function(self)
	local noteChartSetsPath = self.gui.cacheModel.cacheManager.noteChartSetsPath
	for path in pairs(noteChartSetsPath) do
		if path:find("%.mid$") then
			self:createMidiKeybinds()
			break
		end
	end

	if self.state == 0 or self.state == 3 then
		self.cacheModel:startUpdate(BrowserList.basePath, self.data.force)
	else
		self.cacheModel:stopUpdate()
	end
end

CacheManagerDisplay.createMidiKeybinds = function(self)
	local inputBindings = self.gui.view.controller.selectController.inputModel.inputBindings

	if inputBindings["88key"] and inputBindings["88key"].press and inputBindings["88key"].press.midi then return end

	inputBindings["88key"] = {}
	inputBindings["88key"]["press"] = {}
	inputBindings["88key"]["press"]["midi"] = {}
	inputBindings["88key"]["release"] = {}
	inputBindings["88key"]["release"]["midi"] = {}
	for i = 1, 88 do
		inputBindings["88key"]["press"]["midi"][tostring(i + 20)] = {}
		inputBindings["88key"]["press"]["midi"][tostring(i + 20)]["press"] = {"key" .. tostring(i)}
		inputBindings["88key"]["press"]["midi"][tostring(i + 20)]["release"] = {}
		inputBindings["88key"]["release"]["midi"][tostring(i + 20)] = {}
		inputBindings["88key"]["release"]["midi"][tostring(i + 20)]["press"] = {}
		inputBindings["88key"]["release"]["midi"][tostring(i + 20)]["release"] = {"key" .. tostring(i)}
	end
end

CacheManagerDisplay.unload = function(self)
	self.cacheModel.observable:remove(self)

	Button.unload(self)
end

CacheManagerDisplay.receive = function(self, event)
	if event.name == "CacheProgress" then
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
			self.button.text = self.data.text
			self.button:reload()
		end
		self.state = event.state
	end

	Button.receive(self, event)
end

return CacheManagerDisplay
