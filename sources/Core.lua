Core = createClass(soul.SoulObject)

Core.load = function(self)
	self:loadConfig()
	self:loadResourceLoader()
	self:loadAudioManager()
	self:loadFontManager()
	self:loadNoteSkinManager()
	self:loadInputModeLoader()
	self:loadCache()
	self:loadKeyBindManager()
	self:loadBackgroundManager()
	self:loadMapList()
	self:loadNotificationLine()
	self:loadFileManager()
	self:loadStateManager()
	self:loadCLI()
end

Core.receiveEvent = function(self, event)
	if event.name == "resource" then
		if event.type == "font" then
			event.callback(self.fontManager:getFont(event.fontType, event.fontSize))
		end
	elseif event.name == "setBackground" then
		self.backgroundManager:setBackground(event.path)
	elseif event.name == "mapListSelectedItemClicked" then
		self.stateManager:switchState("playing")
	elseif event.name == "cacheDatabase" then
		event.callback(self.cache.db)
	elseif event.name == "updateCache" then
		self.cache:update(event.path, event.recursive, event.callback)
	elseif event.name == "notify" then
		self.notificationLine:setText(event.text)
	end
end

Core.loadCLI = function(self)
	self.cli = CLI:new()
	self.observer:subscribe(self.cli.observable)
	self.cli:activate()
	self:loadCLICommands()
end

Core.loadConfig = function(self)
	self.config = Config:new()
	self.config:read("userdata/config.json")
end

Core.loadResourceLoader = function(self)
	self.resourceLoader = ResourceLoader:getGlobal():activate()
end

Core.loadAudioManager = function(self)
	self.audioManager = AudioManager:new()
	self.audioManager:activate()
end

Core.loadFontManager = function(self)
	self.fontManager = FontManager:new()
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
end

Core.loadKeyBindManager = function(self)
	self.keyBindManager = KeyBindManager:new()
	self.keyBindManager:activate()
	self.keyBindManager:setBinding("`", function()
		self.cli:switch()
	end, nil, true)
end

Core.loadBackgroundManager = function(self)
	self.backgroundManager = BackgroundManager:new()
	self.backgroundManager.core = self
	self.backgroundManager:activate()
end

Core.loadMapList = function(self)
	self.mapList = MapList:new()
	self.observer:subscribe(self.mapList.observable)
end

Core.loadNotificationLine = function(self)
	self.notificationLine = NotificationLine:new()
	self.observer:subscribe(self.notificationLine.observable)
	self.notificationLine:activate()
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
				self.mapList
			}
		),
		"selectionScreen"
	)
	self.stateManager:setState(
		StateManager.State:new(
			function()
				self.editor = Editor:new()
				self.editor:activate()
			end,
			function()
				self.editor:deactivate()
			end
		),
		"editor"
	)
	self.stateManager:setState(
		StateManager.State:new(
			function()
				self:loadEngine()
			end,
			function()
				self:unloadEngine()
			end
		),
		"playing"
	)

	self.stateManager:switchState("selectionScreen")
end

Core.loadEngine = function(self)
	self.currentCacheData = self.mapList.currentCacheData
	
	local noteChart = self.cache:getNoteChart(self.currentCacheData.path)
	local data = self.noteSkinManager:getNoteSkin(noteChart.inputMode) or {}
	
	noteChart.directoryPath = self.currentCacheData.path:match("^(.+)/")
	self.fileManager:addPath(noteChart.directoryPath)
	
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
	self.observer:subscribe(self.engine.observable)
	self.engine:activate()
	
	self.score = Score:new()
	self.score.engine = self.engine
	self.score:activate()
	
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
		self.score:deactivate()
		self.engine = nil
	end
	if self.playField then
		self.playField:deactivate()
	end
end

Core.loadCLICommands = function(self)
	self.cli:addCommand(
		"fps",
		function()
			self.cli:print(function()
				return love.timer.getFPS()
			end)
		end
	)
	self.cli:addCommand(
		"state",
		function(state)
			self.stateManager:switchState(state)
		end
	)
	self.cli:addCommand(
		"fullscreen",
		function(...)
			love.window.setFullscreen(not love.window.getFullscreen())
		end
	)
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