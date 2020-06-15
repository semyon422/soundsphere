local Class = require("aqua.util.Class")
local ncdk = require("ncdk")
local ajson = require("aqua.util.json")
local NoteSkin = require("sphere.screen.gameplay.GraphicEngine.NoteSkin")

local toml = require("lua-toml.toml")
toml.strict = false

local TomlNoteSkinLoader = Class:new()

TomlNoteSkinLoader.data = {}
TomlNoteSkinLoader.path = "userdata/skins"

TomlNoteSkinLoader.load = function(self, metaData, version)
	local noteSkin = NoteSkin:new()
	noteSkin.metaData = metaData
	self.noteSkin = noteSkin

	local file = io.open(metaData.directoryPath .. "/" .. metaData.path, "r")
	noteSkin.tomlData = toml.parse(file:read("*all"))
	file:close()

	self.unit = noteSkin.tomlData.general.unit

	self.noteSkin.playField = {}
	self.noteSkin.noteSkinData = {}

	self:addCS()
	self:addEnv()

	self:processNoteSkinData()
	self:addMeasureLine()
	self:processPlayFieldData()

	self:addBmsBga()

	noteSkin:load()

	-- ajson.write("skin.json", noteSkin.playField)

	return noteSkin
end

local colors = {
	transparent = {255, 255, 255, 0},
	clear = {255, 255, 255, 255},
	missed = {127, 127, 127, 255},
	passed = {255, 255, 255, 0},
	startMissed = {127, 127, 127, 255},
	startMissedPressed = {191, 191, 191, 255},
	startPassedPressed = {255, 255, 255, 255},
	endPassed = {255, 255, 255, 0},
	endMissed = {127, 127, 127, 255},
	endMissedPassed = {127, 127, 127, 255}
}

local envcolor = function(timeState, logicalState, data)
    if logicalState == "clear" or logicalState == "skipped" then
		return colors.clear
	elseif logicalState == "missed" then
		return colors.missed
	elseif logicalState == "passed" then
		return colors.passed
    end
	
	local startTimeState = timeState.startTimeState or timeState
	local endTimeState = timeState.endTimeState or timeState
	local sdt = timeState.scaledFakeVisualDeltaTime or timeState.scaledVisualDeltaTime

	if startTimeState.fakeCurrentVisualTime >= endTimeState.absoluteTime then
		return colors.transparent
	elseif logicalState == "clear" then
		return colors.clear
	elseif logicalState == "startMissed" then
		return colors.startMissed
	elseif logicalState == "startMissedPressed" then
		return colors.startMissedPressed
	elseif logicalState == "startPassedPressed" then
		return colors.startPassedPressed
	elseif logicalState == "endPassed" then
		return colors.endPassed
	elseif logicalState == "endMissed" then
		return colors.endMissed
	elseif logicalState == "endMissedPassed" then
		return colors.endMissedPassed
	end

    return colors.clear
end

TomlNoteSkinLoader.addEnv = function(self)
	local noteSkin = self.noteSkin
	noteSkin.env = {}
	local env = noteSkin.env

	env.number = function(timeState, logicalState, n) return n end
	env.linear = function(timeState, logicalState, data)
		return data[1] + data[2] * (timeState.scaledFakeVisualDeltaTime or timeState.scaledVisualDeltaTime)
	end
	env.color = envcolor
	env.colorWhite = function() return colors.clear end
	env.bgacolor = function()
		local bga = noteSkin.tomlData.bga
		if not bga then
			return colors.clear
		end
		return bga.color
	end
end

TomlNoteSkinLoader.processNoteSkinData = function(self)
	local noteSkin = self.noteSkin
	local noteSkinData = noteSkin.noteSkinData

	noteSkinData.images = {}
	self.imageNames = {}

	noteSkinData.notes = {}
	local input = noteSkin.tomlData.general.input
	for i = 1, #input do
		self:processInput(input[i], i)
	end

	self:addPlayFieldGuidelines()
end

TomlNoteSkinLoader.addCS = function(self)
	local columns = self.noteSkin.tomlData.columns
	local align = columns.align

	local noteSkinData = self.noteSkin.noteSkinData
	noteSkinData.cses = {}
	local cses = noteSkinData.cses
	self.cses = cses

	if align == "left" then
		cses[1] = {0, 0, 0, 0, "h"}
	elseif align == "right" then
		cses[1] = {1, 0, 1, 0, "h"}
	else
		cses[1] = {0.5, 0, 0.5, 0, "h"}
	end
	cses[2] = {0, 0, 0, 0, "all"}
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
	self:addSoundNote(input, i)
	self:addPlayFieldKey(input, i)
end

TomlNoteSkinLoader.getFullWidth = function(self)
	local columns = self.noteSkin.tomlData.columns
	local align = columns.align
	local sum = 0

	for j = 1, #columns.width do
		sum = sum + columns.width[j]
	end
	for j = 1, #columns.space do
		sum = sum + columns.space[j]
	end

	return sum
end

TomlNoteSkinLoader.getNoteX = function(self, i, leftSpace)
	local columns = self.noteSkin.tomlData.columns
	local align = columns.align
	local sum = self:getFullWidth()

	local x
	if align == "left" then
		x = columns.x
	elseif align == "right" then
		x = columns.x + self.unit - sum
	else
		x = columns.x + self.unit / 2 - sum / 2
	end

	for j = 1, i - 1 do
		x = x + columns.width[j]
	end
	for j = 1, leftSpace and (i - 1) or i do
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

	local tomlNote = noteSkin.tomlData.notes.ShortNote
	if not tomlNote then
		return
	end

	local noteSkinData = noteSkin.noteSkinData

	noteSkinData.notes[input .. ":ShortNote"] = {}
	local shortNote = noteSkinData.notes[input .. ":ShortNote"]
	
	local unit = self.unit
	local scroll = noteSkin.tomlData.general.scroll

	local columns = noteSkin.tomlData.columns

	shortNote.Head = {}
	local head = shortNote.Head
	head.cs = 1
	head.layer = 10
	head.image = self:getImageName(tomlNote.Head.images[i], tomlNote.Head.layer)
	head.gc = {
		x = {"number", self:getNoteX(i) / unit},
		y = {"linear", {self:getNoteY(i) / unit, scroll}},
		w = {"number", columns.width[i] / unit},
		h = {"number", columns.height[i] / unit},
		ox = {"number", 0},
		oy = {"number", -1},
		color = {"color", "white"}
	}
	head.drawInterval = {-1, 1}
end

TomlNoteSkinLoader.addLongNote = function(self, input, i)
	local noteSkin = self.noteSkin

	local tomlNote = noteSkin.tomlData.notes.LongNote
	if not tomlNote then
		return
	end

	local noteSkinData = noteSkin.noteSkinData

	noteSkinData.notes[input .. ":LongNote"] = {}
	local longNote = noteSkinData.notes[input .. ":LongNote"]

	local unit = self.unit
	local scroll = noteSkin.tomlData.general.scroll

	local columns = noteSkin.tomlData.columns

	longNote.Head = {}
	local head = longNote.Head
	head.cs = 1
	head.layer = 10
	head.image = self:getImageName(tomlNote.Head.images[i], tomlNote.Head.layer)
	head.gc = {
		x = {"number", self:getNoteX(i) / unit},
		y = {"linear", {self:getNoteY(i) / unit, scroll}},
		w = {"number", columns.width[i] / unit},
		h = {"number", columns.height[i] / unit},
		ox = {"number", 0},
		oy = {"number", -1},
		color = {"color", "white"}
	}
	head.drawInterval = {-1, 1}

	longNote.Body = {}
	local body = longNote.Body
	body.cs = 1
	body.layer = 10
	body.image = self:getImageName(tomlNote.Body.images[i], tomlNote.Body.layer)
	body.gc = {
		x = {"number", self:getNoteX(i) / unit},
		y = {"linear", {self:getNoteY(i) / unit, scroll}},
		w = {"number", columns.width[i] / unit},
		h = {"number", 0},
		ox = {"number", 0},
		oy = {"number", -0.5},
		color = {"color", "white"}
	}

	longNote.Tail = {}
	local tail = longNote.Tail
	tail.cs = 1
	tail.layer = 10
	tail.image = self:getImageName(tomlNote.Tail.images[i], tomlNote.Tail.layer)
	tail.gc = {
		x = {"number", self:getNoteX(i) / unit},
		y = {"linear", {self:getNoteY(i) / unit, scroll}},
		w = {"number", columns.width[i] / unit},
		h = {"number", columns.height[i] / unit},
		ox = {"number", 0},
		oy = {"number", -1},
		color = {"color", "white"}
	}
	tail.drawInterval = {-1, 1}
end

TomlNoteSkinLoader.addSoundNote = function(self, input, i)
	local noteSkin = self.noteSkin

	local tomlNote = noteSkin.tomlData.notes.SoundNote
	if not tomlNote then
		return
	end

	local noteSkinData = noteSkin.noteSkinData

	noteSkinData.notes[input .. ":SoundNote"] = {}
	local shortNote = noteSkinData.notes[input .. ":SoundNote"]
	
	local unit = self.unit
	local scroll = noteSkin.tomlData.general.scroll

	local columns = noteSkin.tomlData.columns

	shortNote.Head = {}
	local head = shortNote.Head
	head.cs = 1
	head.layer = 10
	head.image = self:getImageName(tomlNote.Head.images[i], tomlNote.Head.layer)
	head.gc = {
		x = {"number", self:getNoteX(i) / unit},
		y = {"linear", {self:getNoteY(i) / unit, scroll}},
		w = {"number", columns.width[i] / unit},
		h = {"number", columns.height[i] / unit},
		ox = {"number", 0},
		oy = {"number", -1},
		color = {"colorWhite"}
	}
	head.drawInterval = {-1, 1}
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
		cs = self.cses[1]
	}
end

TomlNoteSkinLoader.addPlayFieldGuidelines = function(self)
	local playField = self.noteSkin.playField
	
	local guidelines = self.noteSkin.tomlData.guidelines
	local unit = self.unit

	for i = 1, #guidelines.width do
		local bw = guidelines.width[i]
		local bh = guidelines.height[i]

		if bw ~= 0 and bh ~= 0 then
			local x
			if bw >= 0 then
				x = self:getNoteX(i, true)
			elseif bw < 0 then
				x = self:getNoteX(i) + bw
			end

			playField[#playField + 1] = {
				class = "StaticObject",
				x = x / unit,
				y = guidelines.y / unit,
				w = math.abs(bw) / unit,
				h = bh / unit,
				layer = guidelines.layer,
				image = guidelines.images[i],
				cs = self.cses[1]
			}
		end
	end
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
	head.gc = {
		x = {"number", self:getNoteX(0) / unit},
		y = {"linear", {columns.y / unit, scroll}},
		w = {"number", 0},
		h = {"number", 0},
		ox = {"number", 0},
		oy = {"number", 0},
		color = {"colorWhite"}
	}
	head.drawInterval = {-1, 1}

	longNote.Body = {}
	local body = longNote.Body
	body.cs = 1
	body.layer = 10
	body.image = self:getImageName(tomlMeasureLine.image, tomlMeasureLine.layer)
	body.gc = {
		x = {"number", self:getNoteX(0) / unit},
		y = {"linear", {columns.y / unit, scroll}},
		w = {"number", (self:getNoteX(#columns.width + 1) - self:getNoteX(0)) / unit},
		h = {"number", tomlMeasureLine.height / unit},
		ox = {"number", 0},
		oy = {"number", 0},
		color = {"colorWhite"}
	}

	longNote.Tail = {}
	local tail = longNote.Tail
	tail.cs = 1
	tail.layer = 10
	tail.image = self:getImageName(tomlMeasureLine.image, tomlMeasureLine.layer)
	tail.gc = {
		x = {"number", self:getNoteX(0) / unit},
		y = {"linear", {columns.y / unit, scroll}},
		w = {"number", 0},
		h = {"number", 0},
		ox = {"number", 0},
		oy = {"number", 0},
		color = {"colorWhite"}
	}
	tail.drawInterval = {-1, 1}
end

TomlNoteSkinLoader.processPlayFieldData = function(self)
	local tomlPlayField = self.noteSkin.tomlData.playfield
	for _, object in pairs(tomlPlayField) do
		if object.class == "ScoreDisplay" and object.field == "score" then
			self:addScoreDisplayScore(object)
		elseif object.class == "ScoreDisplay" and object.field == "accuracy" then
			self:addScoreDisplayAccuracy(object)
		elseif object.class == "ScoreDisplay" and object.field == "combo" then
			self:addScoreDisplayCombo(object)
		elseif object.class == "ScoreDisplay" and object.field == "timegate" then
			self:addScoreDisplayTimegate(object)
		elseif object.class == "PointGraph" then
			self:addPointGraph(object)
		elseif object.class == "ProgressBar" then
			self:addProgressBar(object)
		elseif object.class == "StaticObject" then
			self:addStaticObject(object)
		end
	end
end

TomlNoteSkinLoader.getPlayFielObjectXYWH = function(self, object)
	local ox, oy, ow, oh = unpack(object.xywh)
	if object.origin == "lane" then
		local x0 = self:getNoteX(0)
		local width = self:getFullWidth()
		local xcenter = x0 + width / 2
		local unit = self.unit

		local x = (xcenter - unit / 2 + ox) / unit
		local y = oy / unit
		local w = ow / unit
		local h = oh / unit
		
		return x, y, w, h, self.cses[1]
	elseif object.origin == "all" then
		return ox, oy, ow, oh, self.cses[2]
	end
end

TomlNoteSkinLoader.addScoreDisplayScore = function(self, object)
	local playField = self.noteSkin.playField
	local x, y, w, h, cs = self:getPlayFielObjectXYWH(object)

	playField[#playField + 1] = {
		class = "ScoreDisplay",
		field = "score",
		format = object.format,
		x = x,
		y = y,
		w = w,
		h = h,
		layer = object.layer,
		cs = cs,
		align = {x = object.align[1], y = object.align[2]},
		color = object.color,
		font = object.font,
		size = object.size
	}
end

TomlNoteSkinLoader.addScoreDisplayAccuracy = function(self, object)
	local playField = self.noteSkin.playField
	local x, y, w, h, cs = self:getPlayFielObjectXYWH(object)

	playField[#playField + 1] = {
		class = "ScoreDisplay",
		field = "accuracy",
		format = object.format,
		x = x,
		y = y,
		w = w,
		h = h,
		layer = object.layer,
		cs = cs,
		align = {x = object.align[1], y = object.align[2]},
		color = object.color,
		font = object.font,
		size = object.size
	}
end

TomlNoteSkinLoader.addScoreDisplayCombo = function(self, object)
	local playField = self.noteSkin.playField
	local x, y, w, h, cs = self:getPlayFielObjectXYWH(object)

	playField[#playField + 1] = {
		class = "ScoreDisplay",
		field = "combo",
		format = object.format,
		x = x,
		y = y,
		w = w,
		h = h,
		layer = object.layer,
		cs = cs,
		align = {x = object.align[1], y = object.align[2]},
		color = object.color,
		font = object.font,
		size = object.size
	}
end

TomlNoteSkinLoader.addScoreDisplayTimegate = function(self, object)
	local playField = self.noteSkin.playField
	local x, y, w, h, cs = self:getPlayFielObjectXYWH(object)

	playField[#playField + 1] = {
		class = "ScoreDisplay",
		field = "timegate",
		format = object.format,
		x = x,
		y = y,
		w = w,
		h = h,
		layer = object.layer,
		cs = cs,
		align = {x = object.align[1], y = object.align[2]},
		color = object.color,
		font = object.font,
		size = object.size
	}
end

TomlNoteSkinLoader.addPointGraph = function(self, object)
	local playField = self.noteSkin.playField
	local x, y, w, h, cs = self:getPlayFielObjectXYWH(object)

	playField[#playField + 1] = {
		class = "PointGraph",
		x = x,
		y = y,
		w = w,
		h = h,
		r = object.r / self.unit,
		layer = object.layer,
		cs = cs,
		color = object.color,
		lineColor = object.lineColor,
		counterPath = object.counterPath
	}
end

TomlNoteSkinLoader.addProgressBar = function(self, object)
	local playField = self.noteSkin.playField
	local x, y, w, h, cs = self:getPlayFielObjectXYWH(object)

	playField[#playField + 1] = {
		class = "ProgressBar",
		x = x,
		y = y,
		w = w,
		h = h,
		layer = object.layer,
		cs = cs,
		color = object.color,
		direction = object.direction,
		mode = object.mode
	}
end

TomlNoteSkinLoader.addStaticObject = function(self, object)
	local playField = self.noteSkin.playField
	local x, y, w, h, cs = self:getPlayFielObjectXYWH(object)

	playField[#playField + 1] = {
		class = "StaticObject",
		x = x,
		y = y,
		w = w,
		h = h,
		layer = object.layer,
		cs = cs,
		image = object.image
	}
end

TomlNoteSkinLoader.addImageNote = function(self, input, layer)
	local noteSkin = self.noteSkin
	local noteSkinData = noteSkin.noteSkinData

	noteSkinData.notes[input .. ":ImageNote"] = {}
	local imageNote = noteSkinData.notes[input .. ":ImageNote"]

	imageNote.Head = {}
	local head = imageNote.Head
	head.cs = 2
	head.layer = layer
	head.gc = {
		x = {"number", 0},
		y = {"number", 0},
		w = {"number", 1},
		h = {"number", 1},
		ox = {"number", 0},
		oy = {"number", 0},
		color = {"bgacolor"}
	}
end

TomlNoteSkinLoader.addVideoNote = function(self, input, layer)
	local noteSkin = self.noteSkin
	local noteSkinData = noteSkin.noteSkinData

	noteSkinData.notes[input .. ":VideoNote"] = {}
	local videoNote = noteSkinData.notes[input .. ":VideoNote"]

	videoNote.Head = {}
	local head = videoNote.Head
	head.cs = 2
	head.layer = layer
	head.gc = {
		x = {"number", 0},
		y = {"number", 0},
		w = {"number", 1},
		h = {"number", 1},
		ox = {"number", 0},
		oy = {"number", 0},
		color = {"bgacolor"}
	}
end

-- local drawOrder = {0x04, 0x07, 0x0A}
TomlNoteSkinLoader.addBmsBga = function(self)
	local layer = self.noteSkin.tomlData.bga.layer

	self:addImageNote("bmsbga" .. 0x04, 0.1 + layer)
	-- self:addImageNote("bmsbga" .. 0x06)
	self:addImageNote("bmsbga" .. 0x07, 0.2 + layer)
	self:addImageNote("bmsbga" .. 0x0A, 0.3 + layer)
	-- self:addImageNote("bmsbga" .. 0x0B)
	-- self:addImageNote("bmsbga" .. 0x0C)
	-- self:addImageNote("bmsbga" .. 0x0D)
	-- self:addImageNote("bmsbga" .. 0x0E)

	self:addVideoNote("bmsbga" .. 0x04, 0.1 + layer)
	-- self:addVideoNote("bmsbga" .. 0x06)
	self:addVideoNote("bmsbga" .. 0x07, 0.2 + layer)
	self:addVideoNote("bmsbga" .. 0x0A, 0.3 + layer)
	-- self:addVideoNote("bmsbga" .. 0x0B)
	-- self:addVideoNote("bmsbga" .. 0x0C)
	-- self:addVideoNote("bmsbga" .. 0x0D)
	-- self:addVideoNote("bmsbga" .. 0x0E)
end

return TomlNoteSkinLoader
