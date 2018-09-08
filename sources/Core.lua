Core = createClass(soul.SoulObject)

Core.load = function(self)
	self:loadConfig()
	self:loadResourceLoader()
	self:loadAudioManager()
	self:loadFonts()
	self:loadNoteSkinManager()
	self:loadInputModeLoader()
	self:loadCache()
	self:loadKeyBindManager()
	self:loadBackgroundManager()
	self:loadMapList()
	self:loadFileManager()
	self:loadStateManager()
	self:loadCLI()
end

Core.loadCLI = function(self)
	self.cli = CLI:new()
	self.cli.core = self
	self.cli:activate()
	self:loadCLICommands()
end

Core.loadCLICommands = function(self)
	self.cli:addCommand(
		"config",
		function(...)
			local args = {...}
			if args[1] == "set" then
				local func, err = loadstring("(...)." .. args[2] .. "=" .. args[3])
				if not func then
					self.cli:print(err)
					return
				end
				local out = {pcall(func, self.config.data)}
				for _, value in pairs(out) do
					self.cli:print(value)
				end
			elseif args[1] == "get" then
				local func, err = loadstring("return (...)." .. args[2])
				if not func then
					self.cli:print(err)
					return
				end
				local out = {pcall(func, self.config.data)}
				for _, value in pairs(out) do
					self.cli:print(value)
				end
			elseif args[1] == "save" then
				self.config:write("userdata/config.json")
			elseif args[1] == "load" then
				self.config:read("userdata/config.json")
			end
		end
	)
end

Core.loadConfig = function(self)
	self.config = Config:new()
	self.config:read("userdata/config.json")
end

Core.loadResourceLoader = function(self)
	self.resourceLoader = ResourceLoader:getGlobal()
	self.resourceLoader:activate()
end

Core.loadAudioManager = function(self)
	self.audioManager = AudioManager:new()
	self.audioManager:activate()
end

Core.loadFonts = function(self)
	self.fonts = {}
	self.fonts.main16 = love.graphics.newFont("resources/NotoSansCJK-Regular.ttc", 16)
	self.fonts.main20 = love.graphics.newFont("resources/NotoSansCJK-Regular.ttc", 20)
	self.fonts.main30 = love.graphics.newFont("resources/NotoSansCJK-Regular.ttc", 30)
end

Core.loadInputModeLoader = function(self)
	self.inputModeLoader = InputModeLoader:new()
	self.inputModeLoader:load("userdata/input.json")
end

Core.loadNoteSkinManager = function(self)
	self.noteSkinManager = NoteSkinManager:new()
	self.noteSkinManager:load()
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
	self.keyBindManager:setBinding("`", function()
		self.cli:switch()
	end, nil, true)
end

Core.loadBackgroundManager = function(self)
	self.backgroundManager = BackgroundManager:new({
		drawable = love.graphics.newImage("resources/background.jpg")
	})
	self.backgroundManager:activate()
end

Core.loadMapList = function(self)
	self.mapList = MapList:new()
	self.mapList.core = self
end

Core.loadFileManager = function(self)
	self.fileManager = FileManager:new()
end

Core.loadStateManager = function(self)
	self.stateManager = StateManager:new()
	
	self.stateManager:setState(
		StateManager.State:new(
			{
				self.mapList
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
				self.mapList
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
	elseif filePath:find(".jnc$") then
		noteChart = jnc.NoteChart:new()
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
	local noteChart = self:getNoteChart(directoryPath, fileName)
	local data = self.noteSkinManager:getNoteSkin(noteChart.inputMode) or {}
	
	self.fileManager:addPath(directoryPath)
	noteChart.directoryPath = directoryPath
	
	local noteSkin
	if data.noteSkin then
		noteSkin = CloudburstEngine.NoteSkin:new()
		noteSkin.directoryPath = data.directoryPath
		noteSkin.noteSkinData = data.noteSkin
		noteSkin:activate()
	end
	
	self.engine = CloudburstEngine:new()
	self.engine.noteChart = noteChart
	self.engine.noteSkin = noteSkin
	self.engine.fileManager = self.fileManager
	self.engine.core = self
	self.engine:activate()
	
	if data.playField then
		self.playField = PlayField:new()
		self.playField.directoryPath = data.directoryPath
		self.playField.noteSkinData = data.noteSkin
		self.playField.playFieldData = data.playField
		self.playField.engine = self.engine
		self.playField:activate()
	end
end

Core.unloadEngine = function(self)
	if self.engine then
		self.fileManager:removePath(self.engine.noteChart.directoryPath)
		self.engine:deactivate()
		self.engine = nil
	end
	if self.playField then
		self.playField:deactivate()
	end
end