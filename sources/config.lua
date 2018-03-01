KeyBind = {
	["S"] = "q",
	[1] = "w",
	[2] = "e",
	[3] = "r",
	[4] = "space",
	[5] = "o",
	[6] = "p",
	[7] = "[",
}


cache = Cache:new()
cache:init()
cache:import()
cache:export()

globalFileManager = FileManager:new()

audioManager = AudioManager:new()
audioManager:load()

stateManager = StateManager:new()

globalKeyBindManager = KeyBindManager:new()
globalKeyBindManager:activate()
globalKeyBindManager:setBinding("escape", function() stateManager:switchState("selectionScreen") _G.unloadEngine() end, nil, true)

local background = BackgroundManager:new({
	drawable = love.graphics.newImage("resources/background.jpg")
})

mainFont20 = love.graphics.newFont("resources/OpenSansRegular.ttf", 20)
mainFont30 = love.graphics.newFont("resources/OpenSansRegular.ttf", 30)

local button = soul.ui.RectangleTextButton:new({
	x = 0.4, y = 0.4, w = 0.2, h = 0.2,
	layer = 2,
	cs = soul.CS:new(nil, 0.5, 0.5, 0.5, 0.5, "h", 600),
	text = "play",
	rectangleColor = {255, 255, 255, 15},
	mode = "fill",
	limit = 0.2,
	textAlign = {
		x = "center", y = "center"
	},
	action = function() stateManager:switchState("selectionScreen") end,
	font = mainFont30
})

local list = List:new({
	x = 0, y = 0, w = 1, h = 1,
	layer = 2,
	cs = soul.CS:new(nil, 0.5, 0.5, 0.5, 0.5, "h", 768),
	rectangleColor = {255, 255, 255, 31},
	selectedRectangleColor = {255, 255, 255, 63},
	mode = "fill",
	limit = 1,
	textAlign = {
		x = "center", y = "center"
	},
	buttonCount = 17,
	font = mainFont20
})

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
	engine.timeManager:play()
end

unloadEngine = function()
	globalFileManager:removePath(currentCacheData.directoryPath)
	
	engine:deactivate()
end

for cacheData in cache:getCacheDataIterator() do
	list:addItem(
		cacheData.directoryPath .. "\t/\t" .. cacheData.fileName,
		function()
			currentCacheData = cacheData
			stateManager:switchState("playing")
		end
	)
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
			list
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
			list
		}
	),
	"playing"
)

stateManager:switchState("mainMenu")