local NoteSkinVsrg = require("sphere.models.NoteSkinModel.NoteSkinVsrg")
local PlayfieldVsrg = require("sphere.models.NoteSkinModel.PlayfieldVsrg")
local BasePlayfield = require("sphere.models.NoteSkinModel.BasePlayfield")

local OsuNoteSkin = NoteSkinVsrg:new()

local toarray = function(s)
	if not s then
		return {}
	end
	local array = s:split(",")
	for i, v in ipairs(array) do
		array[i] = tonumber(v)
	end
	return array
end

OsuNoteSkin.load = function(self)
	local skinini = self.skinini
	local mania = self.mania

	local keysCount = tonumber(mania.Keys)

	self.name = skinini.General.Name
	self.playField = {}
	self.range = {-1, 1}
	self.unit = 480
	self.hitposition = tonumber(mania.HitPosition)

	local keys = {}
	for i = 1, keysCount do
		keys[i] = "key" .. i
	end
	self:setInput(keys)

	local space = toarray(mania.ColumnSpacing)
	if #space == keysCount - 1 then
		table.insert(space, 1, 0)
		table.insert(space, 0)
	else
		for i = 1, keysCount + 1 do
			space[i] = 0
		end
	end
	self:setColumns({
		offset = 0,
		align = "center",
		width = toarray(mania.ColumnWidth),
		space = space,
	})

	local textures = {}
	local images = {}
	local blendModes = {}
	local defaultNoteImages = self:getDefaultNoteImages()
	for _, data in ipairs(defaultNoteImages) do
		local key, value = unpack(data)
		if mania[key] then
			value = mania[key]
		end
		local image = self:findImage(value)
		if image then
			table.insert(textures, {[key] = image})
			images[key] = {key}
		end
	end
	local lightingN, rangeN = self:findAnimation(mania.LightingN)
	if not lightingN then
		lightingN, rangeN = self:findAnimation("LightingN")
	end
	if lightingN then
		if rangeN then
			table.insert(textures, {lightingN = {lightingN, rangeN}})
		else
			table.insert(textures, {lightingN = lightingN})
		end
		images.lightingN = {"lightingN"}
		blendModes.lightingN = {"add", "alphamultiply"}
	end
	local lightingL, rangeL = self:findAnimation(mania.LightingL)
	if not lightingL then
		lightingL, rangeL = self:findAnimation("LightingL")
	end
	if lightingL then
		if rangeL then
			table.insert(textures, {lightingL = {lightingL, rangeL}})
		else
			table.insert(textures, {lightingL = lightingL})
		end
		images.lightingL = {"lightingL"}
		blendModes.lightingL = {"add", "alphamultiply"}
	end
	self:setTextures(textures)
	self:setImages(images)
	self:setBlendModes(blendModes)

	local rate = tonumber(mania.LightFramePerSecond) or 30
	if lightingN then
		self:setLighting({
			image = "lightingN",
			scale = 480 / 1080,
			rate = rate,
			range = rangeN,
			offset = 0,
		})
	end
	if lightingL then
		self:setLighting({
			image = "lightingL",
			scale = 480 / 1080,
			rate = rate,
			range = rangeL,
			offset = 0,
			long = true,
		})
	end

	local shead = {}
	for i = 1, keysCount do
		shead[i] = "NoteImage" .. (i - 1)
	end
	self:setShortNote({
		image = shead
	})

	local lhead = {}
	local lbody = {}
	local ltail = {}
	for i = 1, keysCount do
		lhead[i] = "NoteImage" .. (i - 1) .. "H"
		lbody[i] = "NoteImage" .. (i - 1) .. "L"
		ltail[i] = "NoteImage" .. (i - 1) .. "T"
		if not images[lhead[i]] then
			lhead[i] = shead[i]
		end
		if not images[ltail[i]] then
			ltail[i] = lhead[i]
		end
	end
	self:setLongNote({
		head = lhead,
		body = lbody,
		tail = ltail,
	})
	for i = 1, keysCount do
		local wfnhs = tonumber(mania.WidthForNoteHeightScale)
		local width = wfnhs and wfnhs ~= 0 and wfnhs or self.width[i]
		self.notes.ShortNote.Head.h[i] = function()
			local w, h = self:getDimensions(shead[i])
			return h / w * width
		end
		self.notes.LongNote.Head.h[i] = function()
			local w, h = self:getDimensions(lhead[i])
			return h / w * width
		end
		self.notes.LongNote.Tail.h[i] = function()
			local w, h = self:getDimensions(ltail[i])
			return -h / w * width
		end
		self.notes.LongNote.Tail.oy[i] = 0
		self.notes.LongNote.Body.y = function(...)
			local w, h = self:getDimensions(lhead[i])
			return self:getPosition(...) - h / w * width / 2
		end
	end

	local playfield = PlayfieldVsrg:new({
		noteskin = self
	})

	playfield:enableCamera()

	local colors = {}
	local defaultColor = {0, 0, 0, 1}
	for i = 1, keysCount do
		local key = "Colour" .. i
		local value = toarray(mania[key])
		for j = 1, 4 do
			value[j] = value[j] and value[j] / 255 or defaultColor[j]
		end
		colors[i] = value
	end
	playfield:addColumnsBackground({
		color = colors
	})

	self:addStages()

	playfield:addNotes()

	local pressed, released = self:getDefaultKeyImages()
	for i = 1, keysCount do
		local ki = "KeyImage" .. (i - 1)
		pressed[i] = self:findImage(mania[ki .. "D"]) or self:findImage(pressed[i])
		released[i] = self:findImage(mania[ki]) or self:findImage(released[i])
	end
	playfield:addKeyImages({
		sy = 480 / 768,
		padding = 0,
		pressed = pressed,
		released = released,
	})
	playfield:addLightings()
	playfield:disableCamera()

	self:addJudgements()
	BasePlayfield.addBaseHitError(playfield)
end

local getNoteType = function(key, keymode)
	if keymode % 2 == 1 then
		local half = (keymode - 1) / 2
		if (keymode + 1) / 2 == key then
			return "S"
		else
			if (half - key + 1) % 2 == 1 then
				return 2
			else
				return 1
			end
		end
	else
		local half = keymode / 2
		if key <= keymode / 2 then
			if (half - key + 1) % 2 == 1 then
				return 2
			else
				return 1
			end
		else
			if (half - key + 1) % 2 == 1 then
				return 1
			else
				return 2
			end
		end
	end
end

local defaultJudgements = {
	{"0", "Hit0", "mania-hit0"},
	{"50", "Hit50", "mania-hit50"},
	{"100", "Hit100", "mania-hit100"},
	{"200", "Hit200", "mania-hit200"},
	{"300", "Hit300", "mania-hit300"},
	{"300g", "Hit300g", "mania-hit300g"},
}

OsuNoteSkin.addJudgements = function(self)
	local mania = self.mania
	local rate = tonumber(mania.AnimationFramerate) or -1
	local od = tonumber(mania.OverallDifficulty) or 5

	local judgements = {}
	for i, jd in ipairs(defaultJudgements) do
		local name, key, default = unpack(jd)
		local path, range = self:findAnimation(mania[key])
		if not path then
			path, range = self:findAnimation(default)
		end
		if path then
			local judgement = {name, path, range}
			if rate ~= -1 then
				judgement.rate = rate
			elseif range then
				judgement.rate = 1 / (range[2] - range[1] + 1)
			else
				judgement.rate = 1
			end
			table.insert(judgements, judgement)
		end
	end
	self.playField:addJudgement({
		x = 0, y = self.hitposition, ox = 0.5, oy = 0.5,
		transform = self.playField:newLaneCenterTransform(1080),
		key = "osuOD" .. od,
		judgements = judgements,
	})
end

OsuNoteSkin.getDefaultNoteImages = function(self)
	local mania = self.mania
	local keysCount = tonumber(mania.Keys)

	local images = {}
	for i = 1, keysCount do
		local ni = "NoteImage" .. (i - 1)
		local mn = "mania-note" .. getNoteType(i, keysCount)
		table.insert(images, {ni .. "L", mn .. "L"})
		table.insert(images, {ni .. "T", mn .. "T"})
		table.insert(images, {ni .. "H", mn .. "H"})
		table.insert(images, {ni, mn})
	end
	return images
end

OsuNoteSkin.getDefaultKeyImages = function(self)
	local mania = self.mania
	local keysCount = tonumber(mania.Keys)

	local pressed = {}
	local released = {}
	for i = 1, keysCount do
		local ni = "KeyImage" .. (i - 1)
		local mn = "mania-key" .. getNoteType(i, keysCount)
		pressed[i] = mn .. "D"
		released[i] = mn
	end
	return pressed, released
end

OsuNoteSkin.findImage = function(self, value)
	if not value then
		return
	end
	value = value:gsub("\\", "/"):lower()
	for _, file in pairs(self.files) do
		if file:lower():find(value, 1, true) == 1 then
			local rest = file:sub(#value + 1)
			if rest:find("^%.[^%.]+$") or rest:find("^-0%.[^%.]+$") then
				return file
			end
		end
	end
end

OsuNoteSkin.findAnimation = function(self, value)
	if not value then
		return
	end
	value = value:gsub("\\", "/"):lower()
	local frames = {}
	local path
	for _, file in pairs(self.files) do
		if file:lower():find(value, 1, true) == 1 then
			local rest = file:sub(#value + 1)
			if rest:find("^%.[^%.]+$") then
				return file
			end
			if rest:find("^-%d+%.[^%.]+$") then
				local frame, format = rest:match("^-(%d+)%.([^%.]+)$")
				table.insert(frames, tonumber(frame))
				if not path then
					path = value .. "-%d." .. format
				end
			end
		end
	end
	if #frames == 0 then
		return
	end
	table.sort(frames)
	local startFrame = frames[1]
	local endFrame = frames[#frames]
	for i = 2, #frames do
		local frame, nextFrame = frames[i - 1], frames[i]
		if nextFrame - frame ~= 1 then
			endFrame = frame
			break
		end
	end
	return path, {startFrame, endFrame}
end

OsuNoteSkin.addStages = function(self)
	local mania = self.mania
	local playfield = self.playField
	local stageLeft = self:findImage(mania.StageLeft) or self:findImage("mania-stage-left")
	if stageLeft then
		playfield:add({
			class = "ImageView",
			x = self.columns[1] - self.space[1],
			y = 480,
			sx = 480 / 768,
			sy = 480 / 768,
			oy = 1,
			ox = 1,
			transform = playfield:newNoteskinTransform(),
			image = stageLeft,
		})
	end

	local stageRight = self:findImage(mania.StageRight) or self:findImage("mania-stage-right")
	if stageRight then
		playfield:add({
			class = "ImageView",
			x = self.columns[self.inputsCount] + self.width[self.inputsCount] + self.space[self.inputsCount + 1],
			y = 480,
			sx = 480 / 768,
			sy = 480 / 768,
			oy = 1,
			transform = playfield:newNoteskinTransform(),
			image = stageRight,
		})
	end

	local stageHint = self:findImage(mania.StageHint) or self:findImage("mania-stage-hint")
	if stageHint then
		playfield:add({
			class = "ImageView",
			x = self.columns[1] - self.space[1],
			y = self.hitposition,
			w = self.fullWidth,
			sy = 480 / 768,
			oy = 0.5,
			transform = playfield:newNoteskinTransform(),
			image = stageHint,
		})
	end
end

OsuNoteSkin.setKeys = function(self, keys)
	for _, mania in ipairs(self.skinini.Mania) do
		if tonumber(mania.Keys) == keys then
			self.mania = mania
			return
		end
	end
end

OsuNoteSkin.parseSkinIni = function(self, content)
	local skinini = {}
	local block
	for line in (content .. "\n"):gmatch("(.-)\n") do
		line = line:match("^%s*(.-)%s*$")
		if line:find("^%[") then
			local section = line:match("^%[(.*)%]")
			skinini[section] = skinini[section] or {}
			if section == "Mania" then
				block = {}
				table.insert(skinini[section], block)
			else
				block = skinini[section]
			end
		else
			local key, value = line:match("^(.-):%s*(.+)$")
			if key then
				block[key] = value
			end
		end
	end
	return skinini
end

return OsuNoteSkin
