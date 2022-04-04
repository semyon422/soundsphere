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

local fromDefault = function(t, default)
	local out = {}
	for i, v in ipairs(default) do
		out[i] = t[i] or v
	end
	return out
end

local fixColor = function(t)
	for i, v in ipairs(t) do
		t[i] = t[i] / 255
	end
	return t
end

OsuNoteSkin.load = function(self)
	local skinini = self.skinini

	local mania = self.mania
	local keysCount = tonumber(mania.Keys)
	local defaultMania = self:getDefaultManiaSection(keysCount)

	for k, default in pairs(defaultMania) do
		local v = mania[k]
		if not v then
			mania[k] = default
		elseif type(default) == "table" then
			local arr = toarray(v)
			if k:find("Colour") then
				fixColor(arr)
			end
			mania[k] = fromDefault(arr, default)
		elseif type(default) == "number" then
			mania[k] = tonumber(mania[k]) or default
		end
	end
	self:fixManiaValues()

	self.name = skinini.General.Name
	self.playField = {}
	self.range = {-1, 1}
	self.unit = 480
	self.hitposition = mania.HitPosition

	local keys = {}
	for i = 1, keysCount do
		keys[i] = "key" .. i
	end
	self:setInput(keys)

	local space = mania.ColumnSpacing
	if #space == keysCount - 1 then
		table.insert(space, 1, 0)
		table.insert(space, 0)
	else
		for i = 1, keysCount + 1 do
			space[i] = 0
		end
	end
	self:setColumns({
		offset = mania.ColumnStart,
		align = "left",
		width = mania.ColumnWidth,
		space = space,
		upscroll = mania.UpsideDown == 1,
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

	local lightingNWidth = mania.LightingNWidth
	local lightingLWidth = mania.LightingLWidth
	local lightingNScale = {}
	local lightingLScale = {}
	for i = 1, keysCount do
		lightingNScale[i] = (lightingNWidth[i] > 0 and lightingNWidth[i] or self.width[i]) / 30 * 480 / 768
		lightingLScale[i] = (lightingLWidth[i] > 0 and lightingLWidth[i] or self.width[i]) / 30 * 480 / 768
	end

	if lightingN then
		local rate = 1000 / 170
		if rangeN then
			rate = 1000 / math.max(170 / (rangeN[2] - rangeN[1] + 1), 1000 / 60)
		end
		self:setLighting({
			image = "lightingN",
			scale = lightingNScale,
			rate = rate,
			range = rangeN,
			offset = 0,
		})
	end
	if lightingL then
		local rate = 1000 / 170
		if rangeL then
			rate = 1000 / math.max(170 / (rangeL[2] - rangeL[1] + 1), 1000 / 60)
		end
		self:setLighting({
			image = "lightingL",
			scale = lightingLScale,
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
		local wfnhs = mania.WidthForNoteHeightScale
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
	for i = 1, keysCount do
		colors[i] = mania["Colour" .. i]
	end
	playfield:addColumnsBackground({
		color = colors
	})

	local guidelines = mania.ColumnLineWidth
	local guidelinesHeight = {}
	local guidelinesY = {}
	for i = 1, keysCount + 1 do
		guidelines[i] = (guidelines[i] or 2) * 480 / 768
		guidelinesHeight[i] = self.hitposition
		guidelinesY[i] = 0
	end
	playfield:addGuidelines({
		y = guidelinesY,
		w = guidelines,
		h = guidelinesHeight,
		image = {},
		color = mania.ColourColumnLine,
	})

	local keysUnderNotes = mania.KeysUnderNotes == 1

	if not keysUnderNotes then
		playfield:addNotes()
	end

	local pressed, released = self:getDefaultKeyImages()
	local stageLight = {}
	local stageLightImage, stageLightRange = self:findAnimation("mania-stage-light")
	for i = 1, keysCount do
		local ki = "KeyImage" .. (i - 1)
		pressed[i] = self:findImage(mania[ki .. "D"]) or self:findImage(pressed[i])
		released[i] = self:findImage(mania[ki]) or self:findImage(released[i])
		stageLight[i] = {stageLightImage, stageLightRange}
	end
	playfield:addKeyImages({
		sy = 480 / 768,
		padding = 0,
		pressed = pressed,
		released = released,
	})
	if stageLightImage then
		playfield:addKeyImageAnimations({
			sy = 480 / 768,
			padding = 480 - mania.LightPosition,
			hold = stageLight,
			rate = mania.LightFramePerSecond,
		})
	end

	self:addStages()
	self:addHpBar()

	if keysUnderNotes then
		playfield:addNotes()
	end

	playfield:addLightings()

	self:addCombo()
	self:addScore()
	self:addAccuracy()

	playfield:disableCamera()

	self:addJudgements()
	BasePlayfield.addBaseHitError(playfield)
	BasePlayfield.addBaseProgressBar(playfield)
end

local getNoteType = function(key, keymode)
	if keymode % 2 == 1 then
		local half = (keymode - 1) / 2
		if (keymode + 1) / 2 == key then
			return "S"
		else
			if (half - key + 1) % 2 == 1 then
				return 1
			else
				return 2
			end
		end
	else
		local half = keymode / 2
		if key <= keymode / 2 then
			if (half - key + 1) % 2 == 1 then
				return 1
			else
				return 2
			end
		else
			if (half - key + 1) % 2 == 1 then
				return 2
			else
				return 1
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
	local rate = tonumber(self.skinini.AnimationFramerate) or -1
	local od = tonumber(mania.OverallDifficulty) or 5
	local position = mania.ScorePosition
	if self.upscroll then
		position = 480 - position
	end

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
		x = 0, y = position, ox = 0.5, oy = 0.5,
		scale = 480 / 768,
		transform = self.playField:newLaneCenterTransform(480),
		key = "osuOD" .. od,
		judgements = judgements,
	})
end

local supportedImageFormats = {
	"png", "bmp", "tga", "jpg", "jpeg"
}
for _, format in ipairs(supportedImageFormats) do
	supportedImageFormats[format] = true
end

local chars = {
	comma = ",",
	dot = ".",
	percent = "%",
}
OsuNoteSkin.findCharFiles = function(self, prefix)
	local images = {}
	prefix = prefix:gsub("\\", "/"):lower()
	for _, file in pairs(self.files) do
		if file:lower():find(prefix, 1, true) == 1 then
			local rest = file:sub(#prefix + 1)
			local format = rest:match("^.*%.([^%.]+)$")
			if supportedImageFormats[format] then
				rest = rest:sub(1, -#format - 2)
				if rest:find("^-.+@%dx$") then
					local char, dpi = rest:match("^-(.+)@(%d)x$")
					dpi = tonumber(dpi)
					char = chars[char] or char
					images[dpi] = images[dpi] or {}
					images[dpi][char] = file
				elseif rest:find("^-.+$") then
					local char = rest:match("^-(.+)$")
					char = chars[char] or char
					images[1] = images[1] or {}
					images[1][char] = file
				end
			end
		end
	end
	local files = self:getMaxResolution(images)
	return files
end

OsuNoteSkin.addCombo = function(self)
	local fonts = self.skinini.Fonts
	local files = self:findCharFiles(fonts.ComboPrefix or "score")
	local position = self.mania.ComboPosition
	if self.upscroll then
		position = 480 - position
	end
	self.playField:addCombo({
		class = "ImageValueView",
		transform = self.playField:newLaneCenterTransform(480),
		x = 0,
		y = position,
		oy = 0.5,
		align = "center",
		scale = 480 / 768,
		overlap = tonumber(fonts.ComboOverlap) or 0,
		files = files,
	})
end

OsuNoteSkin.addScore = function(self)
	local fonts = self.skinini.Fonts
	local files = self:findCharFiles(fonts.ScorePrefix or "score")
	self.scoreConfig = {
		class = "ImageValueView",
		transform = self.playField:newTransform(1024, 768, "right"),
		x = 1024,
		y = 0,
		align = "right",
		overlap = tonumber(fonts.ScoreOverlap) or 0,
		files = files,
	}
	self.playField:addScore(self.scoreConfig)
end

OsuNoteSkin.addAccuracy = function(self)
	local fonts = self.skinini.Fonts
	local files = self:findCharFiles(fonts.ScorePrefix or "score")
	local scoreConfig = self.scoreConfig
	self.playField:addAccuracy({
		class = "ImageValueView",
		transform = self.playField:newTransform(1024, 768, "right"),
		x = 1024,
		y = 0,
		scale = 0.6,
		align = "right",
		format = "%0.2f%%",
		overlap = tonumber(fonts.ScoreOverlap) or 0,
		files = files,
		beforeDraw = function(self)
			self.config.y = scoreConfig.height
		end
	})
end

OsuNoteSkin.getDefaultNoteImages = function(self)
	local mania = self.mania
	local keysCount = mania.Keys

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
	local keysCount = mania.Keys

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

OsuNoteSkin.getMaxResolution = function(self, images)
	local dpi = 0
	local file
	for k, v in pairs(images) do
		if k > dpi then
			dpi = k
			file = v
		end
	end
	return file, dpi
end

OsuNoteSkin.findImage = function(self, value, preferFrame)
	if not value then
		return
	end
	value = value:gsub("\\", "/"):lower()
	local single = {}
	local frame = {}
	for _, file in pairs(self.files) do
		if file:lower():find(value, 1, true) == 1 then
			local trueValue = file:sub(1, #value)
			local rest = file:sub(#trueValue + 1)
			local format = rest:match("^.*%.([^%.]+)$")
			if supportedImageFormats[format] then
				rest = rest:sub(1, -#format - 2)
				if rest == "" then
					single[1] = file
				elseif rest:find("^@%d+x$") then
					local dpi = tonumber(rest:find("^@(%d+)x$"))
					single[dpi] = file
				elseif rest:find("^-0$") then
					frame[1] = file
				elseif rest:find("^-0@%d+x$") then
					local dpi = tonumber(rest:find("^-0@(%d+)x$"))
					frame[dpi] = file
				end
			end
		end
	end
	local file
	if preferFrame and next(frame) then
		file = self:getMaxResolution(frame)
	elseif next(single) then
		file = self:getMaxResolution(single)
	elseif next(frame) then
		file = self:getMaxResolution(frame)
	end
	return file
end

OsuNoteSkin.findAnimation = function(self, value)
	if not value then
		return
	end
	value = value:gsub("\\", "/"):lower()

	local singles = {}
	local frames = {}
	local framesPath = {}
	for _, file in pairs(self.files) do
		if file:lower():find(value, 1, true) == 1 then
			local trueValue = file:sub(1, #value)
			local rest = file:sub(#trueValue + 1)
			local format = rest:match("^.*%.([^%.]+)$")
			if supportedImageFormats[format] then
				rest = rest:sub(1, -#format - 2)
				if rest == "" then
					singles[1] = file
				elseif rest:find("^@%d+x$") then
					local dpi = tonumber(rest:find("^@(%d+)x$"))
					singles[dpi] = file
				elseif rest:find("^-%d+$") then
					local frame = tonumber(rest:match("^-(%d+)$"))
					frames[1] = frames[1] or {}
					table.insert(frames[1], frame)
					framesPath[1] = trueValue .. "-%d." .. format
				elseif rest:find("^-%d+@%d+x$") then
					local frame, dpi = rest:match("^-(%d+)@(%d+)x$")
					frame, dpi = tonumber(frame), tonumber(dpi)
					frames[dpi] = frames[dpi] or {}
					table.insert(frames[dpi], frame)
					framesPath[dpi] = trueValue .. "-%d@" .. dpi .. "x." .. format
				end
			end
		end
	end
	if not next(frames) then
		local file = self:getMaxResolution(singles)
		return file
	end
	local frames, dpi = self:getMaxResolution(frames)

	table.sort(frames)
	local startFrame = frames[1]
	local endFrame = frames[#frames]
	for i = 2, #frames do
		local frame, nextFrame = frames[i - 1], frames[i]
		if nextFrame - frame > 1 then
			endFrame = frame
			break
		end
	end

	return framesPath[dpi], {startFrame, endFrame}
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
			sy = 1,
			oy = 0.5,
			transform = playfield:newNoteskinTransform(),
			image = stageHint,
		})
	end

	local stageBottom = self:findImage(mania.StageBottom) or self:findImage("mania-stage-bottom")
	if stageBottom then
		playfield:add({
			class = "ImageView",
			x = 0,
			y = 480,
			sx = 1,
			sy = 1,
			oy = 1,
			ox = 0.5,
			transform = self.playField:newLaneCenterTransform(480),
			image = stageBottom,
		})
	end
end

OsuNoteSkin.addHpBar = function(self)
	local mania = self.mania
	local playfield = self.playField

	local right = self.columns[self.inputsCount] + self.width[self.inputsCount] + self.space[self.inputsCount + 1]

	local scoreBarBg = self:findImage("scorebar-bg")
	if scoreBarBg then
		playfield:add({
			class = "ImageView",
			x = right + 1,
			y = 480,
			sx = 480 / 768 * 0.7,
			sy = 480 / 768 * 0.7,
			r = -math.pi / 2,
			transform = playfield:newNoteskinTransform(),
			image = scoreBarBg,
		})
	end

	local scoreBar = self:findImage("scorebar-colour")
	local scoreBarMarker = self:findImage("scorebar-marker")
	if scoreBar then
		local x, y
		if scoreBarMarker then
			x = right + 6.6
			y = 474.8
		else
			x = right + 8
			y = 478
		end
		playfield:addHpBar({
			class = "ImageProgressView",
			x = x,
			y = y,
			sx = 480 / 768 * 0.7,
			sy = 480 / 768 * 0.7,
			r = -math.pi / 2,
			transform = playfield:newNoteskinTransform(),
			direction = "left-right",
			mode = "+",
			image = scoreBar,
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
	skinini.General = skinini.General or {}
	skinini.Colours = skinini.Colours or {}
	skinini.Fonts = skinini.Fonts or {}
	skinini.CatchTheBeat = skinini.CatchTheBeat or {}
	skinini.Mania = skinini.Mania or {}
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
			if key and block then
				block[key] = value
			end
		end
	end
	local skinnedKeys = {}
	for i, mania in ipairs(skinini.Mania) do
		local keys = tonumber(mania.Keys)
		if keys then
			skinnedKeys[keys] = true
		end
	end
	for i = 1, 18 do
		if not skinnedKeys[i] then
			table.insert(skinini.Mania, {Keys = i})
		end
	end
	return skinini
end

local tovalues = function(value, count)
	local t = {}
	for i = 1, count do
		t[i] = value
	end
	return t
end

OsuNoteSkin.getDefaultManiaSection = function(self, keys)
	local mania = {}
	mania.Keys = keys
	mania.ColumnStart = 136
	mania.ColumnRight = 19
	mania.ColumnSpacing = tovalues(0, keys - 1)
	mania.ColumnWidth = tovalues(30, keys)
	mania.ColumnLineWidth = tovalues(2, keys + 1)
	mania.BarlineHeight = 1.2
	mania.LightingNWidth = tovalues(0, keys)
	mania.LightingLWidth = tovalues(0, keys)
	mania.WidthForNoteHeightScale = 0  -- If not defined, the height scale of the smallest column width is used
	mania.HitPosition = 402
	mania.LightPosition = 413
	mania.ScorePosition = 325
	mania.ComboPosition = 111
	mania.JudgementLine = 0
	mania.LightFramePerSecond = 60
	mania.SpecialStyle = 0
	mania.ComboBurstStyle = 1
	mania.SplitStages = 0
	mania.StageSeparation = 40
	mania.SeparateScore = 1
	mania.KeysUnderNotes = 0
	mania.UpsideDown = 0
	mania.KeyFlipWhenUpsideDown = 1
	mania.NoteFlipWhenUpsideDown = 1
	mania.NoteBodyStyle = 1
	mania.ColourColumnLine = {1, 1, 1, 1}
	mania.ColourBarline = {1, 1, 1, 1}
	mania.ColourJudgementLine = {1, 1, 1}
	mania.ColourKeyWarning = {0, 0, 0}
	mania.ColourHold = {1, 199 / 255, 51 / 255, 1}
	mania.ColourBreak = {1, 0, 0}
	mania.StageLeft = "mania-stage-left"
	mania.StageRight = "mania-stage-right"
	mania.StageBottom = "mania-stage-bottom"
	mania.StageHint = "mania-stage-hint"
	mania.StageLight = "mania-stage-light"
	mania.LightingN = "LightingN"
	mania.LightingL = "LightingL"
	mania.WarningArrow = "WarningArrow"
	mania.Hit0 = "mania-hit0"
	mania.Hit50 = "mania-hit50"
	mania.Hit100 = "mania-hit100"
	mania.Hit200 = "mania-hit200"
	mania.Hit300 = "mania-hit300"
	mania.Hit300g = "mania-hit300g"

	for i = 0, keys - 1 do
		mania["KeyFlipWhenUpsideDown" .. i] = 1
		mania["KeyFlipWhenUpsideDown" .. i .. "D"] = 1
		mania["NoteFlipWhenUpsideDown" .. i] = 1
		mania["NoteFlipWhenUpsideDown" .. i .. "H"] = 1
		mania["NoteFlipWhenUpsideDown" .. i .. "L"] = 1
		mania["NoteFlipWhenUpsideDown" .. i .. "T"] = 1
		mania["NoteBodyStyle" .. i] = 1
		mania["Colour" .. i + 1] = {0, 0, 0, 1}
		mania["ColourLight" .. i + 1] = {55 / 255, 1, 1}
		mania["KeyImage" .. i] = "mania-key" .. getNoteType(i + 1, keys)
		mania["KeyImage" .. i .. "D"] = "mania-key" .. getNoteType(i + 1, keys) .. "D"
		mania["NoteImage" .. i] = "mania-note" .. getNoteType(i + 1, keys)
		mania["NoteImage" .. i .. "H"] = "mania-note" .. getNoteType(i + 1, keys) .. "H"
		mania["NoteImage" .. i .. "L"] = "mania-note" .. getNoteType(i + 1, keys) .. "L"
		mania["NoteImage" .. i .. "T"] = "mania-note" .. getNoteType(i + 1, keys) .. "T"
	end

	return mania
end

OsuNoteSkin.fixManiaValues = function(self)
	local mania = self.mania

	do
		local w = mania.ColumnLineWidth
		for i = 1, #w do
			local wi = w[i]
			w[i] = wi > 0 and wi < 2 and 2 or wi
		end
	end
	do
		local w = mania.ColumnWidth
		for i = 1, #w do
			w[i] = math.min(math.max(w[i], 5), 100)
		end
	end
	for i = 1, mania.Keys - 1 do
		mania.ColumnSpacing[i] = math.max(mania.ColumnSpacing[i], -mania.ColumnWidth[i + 1])
	end
	mania.StageSeparation = math.max(mania.StageSeparation, 5)
	mania.HitPosition = math.min(math.max(mania.HitPosition, 240), 480)
	if mania.LightFramePerSecond <= 0 then
		mania.LightFramePerSecond = 24
	end
end

return OsuNoteSkin
