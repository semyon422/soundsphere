inputModeLoader = InputModeLoader:new()
inputModeLoader:load("userdata/input.txt")

cache = Cache:new()
cache:init()
cache:import()
cache:export()

globalFileManager = FileManager:new()

audioManager = AudioManager:new()
audioManager:activate()

stateManager = StateManager:new()

globalKeyBindManager = KeyBindManager:new()
globalKeyBindManager:activate()
globalKeyBindManager:setBinding("escape", function()
	if engine and engine.loaded then
		stateManager:switchState("selectionScreen") _G.unloadEngine()
	end
end, nil, true)

local background = BackgroundManager:new({
	drawable = love.graphics.newImage("resources/background.jpg")
})

mainFont20 = love.graphics.newFont("resources/NotoSansCJK-Regular.ttc", 20)
mainFont30 = love.graphics.newFont("resources/NotoSansCJK-Regular.ttc", 30)

local button = soul.ui.RectangleTextButton:new({
	x = 0.4, y = 0.4, w = 0.2, h = 0.2,
	layer = 2,
	cs = soul.CS:new(nil, 0.5, 0.5, 0.5, 0.5, "h", 600),
	text = "play",
	rectangleColor = {255, 255, 255, 15},
	textColor = {255, 255, 255, 255},
	mode = "fill",
	limit = 0.2,
	textAlign = {
		x = "center", y = "center"
	},
	action = function() stateManager:switchState("selectionScreen") end,
	font = mainFont30
})

chartList = MapList:new({
	dataMode = "ChartMode"
})
packList = MapList:new({
	dataMode = "PackMode"
})
chartList.packList = packList
packList.chartList = chartList

currentCacheData = nil

loadEngine = function(directoryPath, fileName)
	globalFileManager:addPath(directoryPath)
	
	noteChart = bms.NoteChart:new()
	local file = love.filesystem.newFile(directoryPath .. "/" .. fileName)
	file:open("r")
	noteChart:import(file:read())

	noteSkin = CloudburstEngine.NoteSkin:new()

	engine = CloudburstEngine:new()
	engine.noteChart = noteChart
	engine.noteSkin = noteSkin
	engine.fileManager = globalFileManager
	engine:activate()
	-- engine.timeManager:play()
	
	playField = PlayField:new({
		engine = engine
	})
	playField:activate()
end

unloadEngine = function()
	globalFileManager:removePath(currentCacheData.directoryPath)
	
	engine:deactivate()
	playField:deactivate()
end

stateManager:setState(
	StateManager.State:new(
		{
			background,
			button
		},
		{
		
		}
	),
	"mainMenu"
)
stateManager:setState(
	StateManager.State:new(
		{
			packList
		},
		{
			button
		}
	),
	"selectionScreen"
)
stateManager:setState(
	StateManager.State:new(
		function()
			loadEngine(currentCacheData.directoryPath, currentCacheData.fileName)
		end,
		{
			packList, chartList
		}
	),
	"playing"
)

stateManager:switchState("mainMenu")