local Class = require("aqua.util.Class")
local ncdk = require("ncdk")
local toml = require("lua-toml.toml")
local ajson = require("aqua.util.json")
local NoteSkin = require("sphere.screen.gameplay.CloudburstEngine.NoteSkin")

local TomlNoteSkinLoader = Class:new()

TomlNoteSkinLoader.data = {}
TomlNoteSkinLoader.path = "userdata/skins"

TomlNoteSkinLoader.load = function(self, metaData)
	local noteSkin = NoteSkin:new()
	noteSkin.metaData = metaData
	self.noteSkin = noteSkin

	local file = io.open(metaData.directoryPath .. "/" .. metaData.path, "r")
	noteSkin.tomlData = toml.parse(file:read("*all"))
	file:close()

	self.unit = noteSkin.tomlData.general.unit

	self:processPlayFieldData()
	self:processNoteSkinData()
	self:addMeasureLine()
	noteSkin:load()

	-- ajson.write("skin.json", noteSkin.playField)

	return noteSkin
end

TomlNoteSkinLoader.processNoteSkinData = function(self)
	local noteSkin = self.noteSkin
	noteSkin.noteSkinData = {}
	local noteSkinData = noteSkin.noteSkinData

	noteSkinData.cses = {
		{0.5, 0, 0, 0, "h"},
		{0, 0, 0, 0, "all"}
	}
	noteSkinData.images = {}
	self.imageNames = {}

	noteSkinData.notes = {}
	local input = noteSkin.tomlData.general.input
	for i = 1, #input do
		self:processInput(input[i], i)
	end
end

TomlNoteSkinLoader.getImageName = function(self, path, layer)
	local noteSkin = self.noteSkin
	local noteSkinData = noteSkin.noteSkinData

	local images = noteSkinData.images
	local imageNames = self.imageNames

	local name = path .. ":" .. layer
	if not imageNames[name] then
		images[#images + 1] = {name = name, path = path, layer = layer}
		imageNames[name] = true
	end

	return name
end

TomlNoteSkinLoader.processInput = function(self, input, i)
	self:addShortNote(input, i)
	self:addLongNote(input, i)
	self:addPlayFieldKey(input, i)
end

TomlNoteSkinLoader.getNoteX = function(self, i)
	local columns = self.noteSkin.tomlData.columns
	local sum = 0

	for j = 1, #columns.width do
		sum = sum + columns.width[j]
	end
	for j = 1, #columns.space do
		sum = sum + columns.space[j]
	end

	local x = columns.x - sum / 2

	for j = 1, i - 1 do
		x = x + columns.width[j]
	end
	for j = 1, i do
		x = x + columns.space[j]
	end

	return x
end

TomlNoteSkinLoader.getNoteY = function(self, i)
	local scroll = self.noteSkin.tomlData.general.scroll
	local columns = self.noteSkin.tomlData.columns
	if scroll >= 0 then
		return columns.y
	else
		return self.unit - columns.y + columns.height[i]
	end
end

TomlNoteSkinLoader.addShortNote = function(self, input, i)
	local noteSkin = self.noteSkin
	local noteSkinData = noteSkin.noteSkinData

	noteSkinData.notes[input .. ":ShortNote"] = {}
	local shortNote = noteSkinData.notes[input .. ":ShortNote"]
	
	local tomlNote = noteSkin.tomlData.notes.ShortNote
	local unit = self.unit
	local scroll = noteSkin.tomlData.general.scroll

	local columns = noteSkin.tomlData.columns

	shortNote.Head = {}
	local head = shortNote.Head
	head.cs = 1
	head.layer = 10
	head.image = self:getImageName(tomlNote.Head.images[i], tomlNote.Head.layer)
	head.sb = {}
	head.gc = {
		x = {self:getNoteX(i) / unit},
		y = {self:getNoteY(i) / unit, scroll},
		w = {columns.width[i] / unit},
		h = {columns.height[i] / unit},
		ox = {0},
		oy = {-1}
	}
end

TomlNoteSkinLoader.addLongNote = function(self, input, i)
	local noteSkin = self.noteSkin
	local noteSkinData = noteSkin.noteSkinData

	noteSkinData.notes[input .. ":LongNote"] = {}
	local longNote = noteSkinData.notes[input .. ":LongNote"]

	local tomlNote = noteSkin.tomlData.notes.LongNote
	local unit = self.unit
	local scroll = noteSkin.tomlData.general.scroll

	local columns = noteSkin.tomlData.columns

	longNote.Head = {}
	local head = longNote.Head
	head.cs = 1
	head.layer = 10
	head.image = self:getImageName(tomlNote.Head.images[i], tomlNote.Head.layer)
	head.sb = {}
	head.gc = {
		x = {self:getNoteX(i) / unit},
		y = {self:getNoteY(i) / unit, scroll},
		w = {columns.width[i] / unit},
		h = {columns.height[i] / unit},
		ox = {0},
		oy = {-1}
	}

	longNote.Body = {}
	local body = longNote.Body
	body.cs = 1
	body.layer = 10
	body.image = self:getImageName(tomlNote.Body.images[i], tomlNote.Body.layer)
	body.sb = {}
	body.gc = {
		x = {self:getNoteX(i) / unit},
		y = {self:getNoteY(i) / unit, scroll},
		w = {columns.width[i] / unit},
		h = {0},
		ox = {0},
		oy = {-0.5}
	}

	longNote.Tail = {}
	local tail = longNote.Tail
	tail.cs = 1
	tail.layer = 10
	tail.image = self:getImageName(tomlNote.Tail.images[i], tomlNote.Tail.layer)
	tail.sb = {}
	tail.gc = {
		x = {self:getNoteX(i) / unit},
		y = {self:getNoteY(i) / unit, scroll},
		w = {columns.width[i] / unit},
		h = {columns.height[i] / unit},
		ox = {0},
		oy = {-1}
	}
end

TomlNoteSkinLoader.addPlayFieldKey = function(self, input, i)
	local playField = self.noteSkin.playField
	local inputType, inputIndex = input:match("^(.-)(%d+)$")
	inputIndex = tonumber(inputIndex)

	local keys = self.noteSkin.tomlData.keys
	local unit = self.unit
	local scroll = self.noteSkin.tomlData.general.scroll

	local y
	if scroll >= 0 then
		y = unit - keys.padding - keys.height[i]
	else
		y = keys.padding
	end
	playField[#playField + 1] = {
		class = "InputImage",
		inputType = inputType,
		inputIndex = inputIndex,
		x = self:getNoteX(i) / unit,
		y = y / unit,
		w = keys.width[i] / unit,
		h = keys.height[i] / unit,
		layer = keys.layer,
		released = keys.released[i],
		pressed = keys.pressed[i],
		cs = {0.5, 0, 0, 0, "h"}
	}
end

TomlNoteSkinLoader.addMeasureLine = function(self)
	local noteSkin = self.noteSkin
	local noteSkinData = noteSkin.noteSkinData

	noteSkinData.notes["measure1:LongNote"] = {}
	local longNote = noteSkinData.notes["measure1:LongNote"]

	local tomlMeasureLine = noteSkin.tomlData.measureline
	local unit = self.unit
	local scroll = noteSkin.tomlData.general.scroll

	local columns = noteSkin.tomlData.columns

	longNote.Head = {}
	local head = longNote.Head
	head.cs = 1
	head.layer = 10
	head.image = self:getImageName(tomlMeasureLine.image, tomlMeasureLine.layer)
	head.sb = {}
	head.gc = {
		x = {self:getNoteX(0) / unit},
		y = {columns.y / unit, scroll},
		w = {0},
		h = {0},
		ox = {0},
		oy = {0}
	}

	longNote.Body = {}
	local body = longNote.Body
	body.cs = 1
	body.layer = 10
	body.image = self:getImageName(tomlMeasureLine.image, tomlMeasureLine.layer)
	body.sb = {}
	body.gc = {
		x = {self:getNoteX(0) / unit},
		y = {columns.y / unit, scroll},
		w = {(self:getNoteX(#columns.width + 1) - self:getNoteX(0)) / unit},
		h = {tomlMeasureLine.height / unit},
		ox = {0},
		oy = {0}
	}

	longNote.Tail = {}
	local tail = longNote.Tail
	tail.cs = 1
	tail.layer = 10
	tail.image = self:getImageName(tomlMeasureLine.image, tomlMeasureLine.layer)
	tail.sb = {}
	tail.gc = {
		x = {self:getNoteX(0) / unit},
		y = {columns.y / unit, scroll},
		w = {0},
		h = {0},
		ox = {0},
		oy = {0}
	}
end

TomlNoteSkinLoader.processPlayFieldData = function(self)
	self.noteSkin.playField = {}
	local playField = self.noteSkin.playField
	local tomlScore = self.noteSkin.tomlData.score
	local columns = self.noteSkin.tomlData.columns

	playField[#playField + 1] = {
		class = "ScoreDisplay",
		field = "score",
		format = tomlScore.score.format,
		x = 0,
		y = 0,
		w = 1,
		h = 1,
		layer = 20,
		cs = {0, 0, 0, 0, "all"},
		align = {x = tomlScore.score.align[1], y = tomlScore.score.align[2]},
		color = tomlScore.score.color,
		font = tomlScore.score.font,
		size = tomlScore.score.size
	}
	playField[#playField + 1] = {
		class = "ScoreDisplay",
		field = "accuracy",
		format = tomlScore.accuracy.format,
		x = 0,
		y = 0,
		w = 1,
		h = 1,
		layer = 20,
		cs = {0, 0, 0, 0, "all"},
		align = {x = tomlScore.accuracy.align[1], y = tomlScore.accuracy.align[2]},
		color = tomlScore.accuracy.color,
		font = tomlScore.accuracy.font,
		size = tomlScore.accuracy.size
	}
	playField[#playField + 1] = {
		class = "ScoreDisplay",
		field = "combo",
		format = tomlScore.combo.format,
		x = -0.5 + columns.x / self.unit,
		y = 0,
		w = 1,
		h = 1,
		layer = 20,
		cs = {0.5, 0, 0, 0, "h"},
		align = {x = tomlScore.combo.align[1], y = tomlScore.combo.align[2]},
		color = tomlScore.combo.color,
		font = tomlScore.combo.font,
		size = tomlScore.combo.size
	}
	playField[#playField + 1] = {
		class = "ScoreDisplay",
		field = "timegate",
		format = tomlScore.timegate.format,
		x = -0.5 + columns.x / self.unit,
		y = 0,
		w = 1,
		h = 1,
		layer = 20,
		cs = {0.5, 0, 0, 0, "h"},
		align = {x = tomlScore.timegate.align[1], y = tomlScore.timegate.align[2]},
		color = tomlScore.timegate.color,
		font = tomlScore.timegate.font,
		size = tomlScore.timegate.size
	}
	playField[#playField + 1] = {
		class = "AccuracyGraph",
		x = 0.25,
		y = 0.25,
		w = 0.5,
		h = 0.5,
		r = 0.002,
		layer = 0,
		cs = {0, 0, 0, 0, "all"},
		color = {127, 127, 127, 255},
		lineColor = {127, 127, 127, 127}
	}
	playField[#playField + 1] = {
		class = "ProgressBar",
		x = 0,
		y = 0.995,
		w = 1,
		h = 0.005,
		layer = 20,
		cs = {0, 0, 0, 0, "all"},
		color = {255, 255, 255, 255},
		direction = "left-right",
		mode = "+"
	}
end

return TomlNoteSkinLoader
