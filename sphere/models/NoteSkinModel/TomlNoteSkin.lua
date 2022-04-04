local NoteSkinVsrg = require("sphere.models.NoteSkinModel.NoteSkinVsrg")
local PlayfieldVsrg = require("sphere.models.NoteSkinModel.PlayfieldVsrg")

local toml = require("lua-toml.toml")
toml.strict = false

local TomlNoteSkin = NoteSkinVsrg:new()

TomlNoteSkin.bgaTransform = {{1 / 2, -16 / 9 / 2}, {0, -7 / 9 / 2}, 0, {0, 16 / 9}, {0, 16 / 9}, 0, 0, 0, 0}

TomlNoteSkin.load = function(self, content)
	local tomlData = toml.parse(content)

	self.name = tomlData.general.name
	self.inputMode = tomlData.general.inputMode
	self.playField = tomlData.general.playField
	self.range = tomlData.general.range
	self.unit = tomlData.general.unit
	self.hitposition = tomlData.general.hitposition

	self:setInput(tomlData.general.input)
	self:setColumns(tomlData.columns)
	self:setTextures(tomlData.general.textures)
	self:setImages(tomlData.general.images)
	self:setShortNote(tomlData.notes.short)
	self:setLongNote(tomlData.notes.long)
	self:addMeasureLine(tomlData.measure)

	local bga = tomlData.bga
	if bga then
		bga.x = 0
		bga.y = 0
		bga.w = 1
		bga.h = 1
		self:addBga(bga)
	end

	if tomlData.notes.short.lighting then
		self:setLighting(tomlData.notes.short.lighting)
	end
	if tomlData.notes.long.lighting then
		tomlData.notes.long.lighting.long = true
		self:setLighting(tomlData.notes.long.lighting)
	end

	local playfield = PlayfieldVsrg:new({
		noteskin = self
	})

	for _, name in ipairs(tomlData.general.playfield) do
		if tomlData[name] then
			local tf = tomlData[name].transform
			if tf and type(tf[1]) == "string" then
				tomlData[name].transform = playfield[tf[1]](playfield, tf[2], tf[3], tf[4])
			end
		end
		if name == "bga" then playfield:addBga({transform = self.bgaTransform})
		elseif name == "camera.on" then playfield:enableCamera()
		elseif name == "keys.images" then playfield:addKeyImages(tomlData.keys.images)
		elseif name == "keys.animations" then playfield:addKeyImageAnimations(tomlData.keys.animations)
		elseif name == "notes" then playfield:addNotes()
		elseif name == "lightings" then playfield:addLightings()
		elseif name == "guidelines" then playfield:addGuidelines(tomlData.guidelines)
		elseif name == "camera.off" then playfield:disableCamera()
		elseif name == "progress" then playfield:addProgressBar(tomlData.progress)
		elseif name == "hp" then playfield:addHpBar(tomlData.hp)
		elseif name == "score" then playfield:addScore(tomlData.score)
		elseif name == "accuracy" then playfield:addAccuracy(tomlData.accuracy)
		elseif name == "combo" then playfield:addCombo(tomlData.combo)
		elseif name == "judgement.counters" then playfield:addJudgement(tomlData.judgement.counters)
		elseif name == "judgement.delta" then playfield:addDeltaTimeJudgement(tomlData.judgement.delta)
		end
	end
end

return TomlNoteSkin
