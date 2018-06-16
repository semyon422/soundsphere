Core = createClass(soul.SoulObject)

Core.load = function(self)
	self:loadFonts()
	self:loadAudioManager()
	self:loadInputModeLoader()
	self:loadCache()
	self:loadKeyBindManager()
	self:loadBackgroundManager()
	self:loadMapList()
	self:loadFileManager()
	self:loadStateManager()
end

Core.loadFonts = function(self)
	self.fonts = {}
	self.fonts.main16 = love.graphics.newFont("resources/NotoSansCJK-Regular.ttc", 16)
	self.fonts.main20 = love.graphics.newFont("resources/NotoSansCJK-Regular.ttc", 20)
	self.fonts.main30 = love.graphics.newFont("resources/NotoSansCJK-Regular.ttc", 30)
end

Core.loadAudioManager = function(self)
	self.audioManager = AudioManager:new()
	self.audioManager:activate()
end

Core.loadInputModeLoader = function(self)
	self.inputModeLoader = InputModeLoader:new()
	self.inputModeLoader:load("userdata/input.txt")
end

Core.loadCache = function(self)
	self.cache = Cache:new()
	self.cache:init()
	self.cache:import()
	self.cache:export()
end

Core.loadKeyBindManager = function(self)
	self.keyBindManager = KeyBindManager:new()
	self.keyBindManager:activate()
	self.keyBindManager:setBinding("escape", function()
		if self.engine and self.engine.loaded then
			self.stateManager:switchState("selectionScreen") self:unloadEngine()
		end
	end, nil, true)
end

Core.loadBackgroundManager = function(self)
	self.backgroundManager = BackgroundManager:new({
		drawable = love.graphics.newImage("resources/background.jpg")
	})
	self.backgroundManager:activate()
end

Core.loadMapList = function(self)
	self.chartList = MapList:new({
		dataMode = "ChartMode"
	})
	self.packList = MapList:new({
		dataMode = "PackMode"
	})
	self.chartList.packList = self.packList
	self.packList.chartList = self.chartList
	self.chartList.core = self
	self.packList.core = self
end

Core.loadFileManager = function(self)
	self.fileManager = FileManager:new()
end

Core.loadStateManager = function(self)
	self.stateManager = StateManager:new()
	
	self.stateManager:setState(
		StateManager.State:new(
			{
				self.packList
			},
			{
				self.button
			}
		),
		"selectionScreen"
	)
	self.stateManager:setState(
		StateManager.State:new(
			function()
				self:loadEngine(self.currentCacheData.directoryPath, self.currentCacheData.fileName)
			end,
			{
				self.packList, self.chartList
			}
		),
		"playing"
	)

	self.stateManager:switchState("selectionScreen")
end


Core.getNoteChart = function(self, directoryPath, fileName)
	local filePath = directoryPath .. "/" .. fileName
	
	local noteChart
	if filePath:find(".osu$") then
		noteChart = osu.NoteChart:new()
	elseif filePath:find(".bm") then
		noteChart = bms.NoteChart:new()
	elseif filePath:find(".ucs") then
		noteChart = ucs.NoteChart:new()
		noteChart.audioFileName = fileName:match("^(.+)%.ucs$") .. ".mp3"
	end
	
	local file = love.filesystem.newFile(filePath)
	file:open("r")
	noteChart:import(file:read())
	
	return noteChart
end

Core.loadEngine = function(self, directoryPath, fileName)
	self.fileManager:addPath(directoryPath)
	
	local noteChart = self:getNoteChart(directoryPath, fileName)

	local noteSkin = CloudburstEngine.NoteSkin:new()

	self.engine = CloudburstEngine:new()
	self.engine.noteChart = noteChart
	self.engine.noteSkin = noteSkin
	self.engine.fileManager = self.fileManager
	self.engine.core = self
	self.engine:activate()
	
	self.playField = PlayField:new({
		engine = self.engine
	})
	self.playField:activate()
end

Core.unloadEngine = function(self)
	self.fileManager:removePath(self.currentCacheData.directoryPath)
	
	self.engine:deactivate()
	self.playField:deactivate()
end