Core = createClass(soul.SoulObject)

Core.load = function(self)
	self.profiler = Profiler:new():activate()
	self.config = Config:new():read("userdata/config.json")
	self.resourceLoader = ResourceLoader:global():activate()
	self.audioManager = AudioManager:new():activate()
	self.fontManager = FontManager:new()
	self.noteSkinManager = NoteSkinManager:new()
	self.inputManager = InputManager:new():activate()
	self.cache = Cache:new()
	
	self.backgroundManager = BackgroundManager:new():activate()
	
	self.mapList = MapList:new()
	self.observer:subscribe(self.mapList.observable)
	
	self.notificationLine = NotificationLine:new()
	self.observer:subscribe(self.notificationLine.observable)
	self.notificationLine:activate()
	
	self.fileManager = FileManager:new()
	
	self:loadStateManager()
	
	self.cli = CLI:new()
	self.observer:subscribe(self.cli.observable)
	self.cli:activate()
	self:loadCLICommands()
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
		noteSkin = CloudburstEngine.NoteSkin:new({
			directoryPath = data.directoryPath,
			noteSkinData = data.noteSkin
		})
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