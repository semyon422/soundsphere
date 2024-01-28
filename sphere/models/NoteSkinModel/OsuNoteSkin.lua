local NoteSkinVsrg = require("sphere.models.NoteSkinModel.NoteSkinVsrg")
local PlayfieldVsrg = require("sphere.models.NoteSkinModel.PlayfieldVsrg")
local BasePlayfield = require("sphere.models.NoteSkinModel.BasePlayfield")
local JustConfig = require("sphere.JustConfig")

local ImageView = require("sphere.views.ImageView")
local ImageValueView = require("sphere.views.ImageValueView")

local ImageProgressView = require("sphere.views.GameplayView.ImageProgressView")
local CircleProgressView = require("sphere.views.GameplayView.CircleProgressView")

---@class sphere.OsuNoteSkin: sphere.NoteSkinVsrg
---@operator call: sphere.OsuNoteSkin
local OsuNoteSkin = NoteSkinVsrg + {}

---@param s string
---@return table
local function toarray(s)
	if not s then
		return {}
	end
	local array = s:split(",")
	for i, v in ipairs(array) do
		array[i] = tonumber(v)
	end
	return array
end

---@param t table
---@param default table
---@return table
local function fromDefault(t, default)
	local out = {}
	for i, v in ipairs(default) do
		out[i] = t[i] or v
	end
	return out
end

---@param t table
---@return table
local function fixColor(t)
	for i, v in ipairs(t) do
		t[i] = t[i] / 255
	end
	return t
end

---@param src table
---@param dst table
local function fillTable(src, dst)
	for k, v in pairs(src) do
		if type(v) ~= "table" then
			dst[k] = v
		elseif type(dst[k]) == "table" then
			fillTable(v, dst[k])
		end
	end
end

---@param src table
---@param dst table
local function copyDefaults(src, dst)
	for k, default in pairs(src) do
		local v = dst[k]
		if not v then
			dst[k] = default
		elseif type(default) == "table" then
			local arr = toarray(v)
			if k:find("Colour") then
				fixColor(arr)
			end
			dst[k] = fromDefault(arr, default)
		elseif type(default) == "number" then
			dst[k] = tonumber(dst[k]) or default
		end
	end
end

local bodyStyles = {
	[0] = "stretch",
	"cascade_top",
	"cascade_bottom",
}

local configPath = "sphere/models/NoteSkinModel/OsuNoteSkinConfig.lua"
function OsuNoteSkin:load()
	OsuNoteSkin.configContent = OsuNoteSkin.configContent or love.filesystem.read(configPath)

	local skinini = self.skinini

	local mania = self.mania
	local keysCount = tonumber(mania.Keys)

	local baseMania = {}
	fillTable(mania, baseMania)

	local defaultMania = self:getDefaultManiaSection(keysCount)
	copyDefaults(defaultMania, mania)

	local config, exists = JustConfig({defaultContent = self.configContent}):fromFile(
		self.path:sub(1, -9) .. keysCount .. "key.config.lua"
	)
	self.config = config
	config.skinIniPath = self.path
	config.mania = mania

	self:fixManiaValues()

	if not exists then
		config:init()
	elseif config.data.mania then
		fillTable(config.data.mania, mania)
	end

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

	local SplitStages = mania.SplitStages == 1 and keysCount > 1

	local space = mania.ColumnSpacing
	if #space == keysCount - 1 then
		if SplitStages then
			space[math.floor(keysCount / 2)] = mania.StageSeparation
		end
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

	local columns = self.columns
	local width = self.width
	local ninputs = self.columnsCount
	local ninputs2 = math.floor(ninputs / 2)

	local textures = {}
	local images = {}
	local blendModes = {}
	table.insert(textures, {pixel = ""})
	images.pixel = {"pixel"}

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
	local lstyle = {}
	for i = 1, keysCount do
		local _i = i - 1
		lhead[i] = "NoteImage" .. _i .. "H"
		lbody[i] = "NoteImage" .. _i .. "L"
		ltail[i] = "NoteImage" .. _i .. "T"
		if not images[lhead[i]] then
			lhead[i] = shead[i]
		end
		if not images[ltail[i]] then
			ltail[i] = lhead[i]
		end

		local bskey = "NoteBodyStyle" .. _i
		local styleIndex = baseMania[bskey] and mania[bskey] or mania.NoteBodyStyle
		local style = bodyStyles[styleIndex] or bodyStyles[defaultMania.NoteBodyStyle]
		lstyle[i] = style
	end
	self:setLongNote({
		head = lhead,
		body = lbody,
		tail = ltail,
		style = lstyle,
		scale = 1 / 1.6,
	})

	local smallestWidth = self.width[1]
	for i = 1, keysCount do
		if self.width[i] < smallestWidth then
			smallestWidth = self.width[i]
		end
	end
	local wfnhs = mania.WidthForNoteHeightScale
	smallestWidth = wfnhs and wfnhs ~= 0 and wfnhs or smallestWidth
	for i = 1, keysCount do
		self.notes.ShortNote.Head.h[i] = function()
			local w, h = self:getDimensions(shead[i])
			return h / w * smallestWidth
		end
		self.notes.LongNote.Head.h[i] = function()
			local w, h = self:getDimensions(lhead[i])
			return h / w * smallestWidth
		end
		self.notes.LongNote.Tail.h[i] = function()
			local w, h = self:getDimensions(ltail[i])
			return -h / w * smallestWidth
		end
		self.notes.LongNote.Tail.oy[i] = 0
		self.notes.LongNote.Body.y = function(timeState, noteView, column)
			local w, h = self:getDimensions(lhead[column])
			return self:getPosition(timeState, noteView, column) - h / w * smallestWidth / 2
		end
	end
	self:setShortNote({
		image = ltail,
	}, "SoundNote")

	local widthLeft, widthRight
	if SplitStages then
		widthLeft = columns[ninputs2] - columns[1] + width[ninputs2]
		widthRight = columns[ninputs] - columns[ninputs2 + 1] + width[ninputs]
	end
	if config:get("Barline") then
		if not SplitStages then
			self:addMeasureLine({
				h = mania.BarlineHeight,
				color = mania.ColourBarline,
				image = "pixel"
			})
		else
			self:addMeasureLine({
				x = columns[1],
				w = widthLeft,
				h = mania.BarlineHeight,
				color = mania.ColourBarline,
				image = "pixel"
			}, 1)
			self:addMeasureLine({
				x = columns[ninputs2] + width[ninputs2] + space[ninputs2 + 1],
				w = widthRight,
				h = mania.BarlineHeight,
				color = mania.ColourBarline,
				image = "pixel"
			}, 2)
		end
	end

	local playfield = PlayfieldVsrg(self)

	playfield:enableCamera()

	local colors = {}
	for i = 1, keysCount do
		colors[i] = mania["Colour" .. i]
	end
	playfield:addColumnsBackground({
		color = colors
	})

	local guidelines = mania.ColumnLineWidth
	local guidelinesW = {}
	local guidelinesHeight = {}
	local guidelinesY = {}
	for i = 1, keysCount + 1 do
		guidelinesW[i] = (guidelines[i] or 2) * 480 / 768
		guidelinesHeight[i] = self.hitposition
		guidelinesY[i] = 0
	end
	playfield:addGuidelines({
		y = guidelinesY,
		w = guidelinesW,
		h = guidelinesHeight,
		image = {},
		color = mania.ColourColumnLine,
		both = true,
		mode = config:get("ColumnLineMode"),
	})

	if not SplitStages then
		self:addStages(
			columns[1],
			columns[ninputs] + width[ninputs] + space[ninputs + 1],
			self.fullWidth
		)
	else
		self:addStages(
			columns[1],
			columns[ninputs2] + width[ninputs2],
			widthLeft
		)
		self:addStages(
			columns[ninputs2] + width[ninputs2] + space[ninputs2 + 1],
			columns[ninputs] + width[ninputs],
			widthRight
		)
	end

	self:addHpBar()

	local pressed, released = self:getDefaultKeyImages()
	local stageLight = {}
	local stageLightColor = {}
	local stageLightImage, stageLightRange = self:findAnimation(mania.StageLight)
	for i = 1, keysCount do
		local ki = "KeyImage" .. (i - 1)
		pressed[i] = self:findImage(mania[ki .. "D"]) or self:findImage(pressed[i])
		released[i] = self:findImage(mania[ki]) or self:findImage(released[i])
		stageLight[i] = {stageLightImage, stageLightRange}
		stageLightColor[i] = mania["ColourLight" .. i]
	end
	if stageLightImage then
		playfield:addKeyImageAnimations({
			sy = 480 / 768,
			padding = 480 - mania.LightPosition,
			rate = mania.LightFramePerSecond,
			hold = stageLight,
			color = stageLightColor,
		})
	end

	local function addNotes()
		playfield:addNotes()
		if not SplitStages then
			playfield:addLaneCovers(config.data.covers)
		else
			playfield:addLaneCovers(config.data.covers, columns[1], widthLeft)
			playfield:addLaneCovers(config.data.covers, columns[ninputs2] + width[ninputs2] + space[ninputs2 + 1], widthRight)
		end
	end

	local keysUnderNotes = mania.KeysUnderNotes == 1
	if not keysUnderNotes then
		addNotes()
	end

	playfield:addKeyImages({
		sy = 480 / 768,
		padding = 0,
		pressed = pressed,
		released = released,
	})

	if keysUnderNotes then
		addNotes()
	end

	playfield:addLightings()

	playfield:disableCamera()

	self:addCombo()
	self:addScore()
	local accObj = self:addAccuracy()

	playfield:addCircleProgressBar({
		x = 0,
		y = 0,
		r = 10 * 1.6,
		transform = self.playField:newTransform(1024, 768, "right"),
		backgroundColor = {1, 1, 1, 0.6},
		foregroundColor = {1, 1, 1, 1},
		draw = function(self)
			self.y = accObj.y + self.r
			self.x = accObj.x - accObj.width * accObj.scale - self.r
			CircleProgressView.draw(self)
		end,
	})

	self:addJudgements(config:get("OverallDifficulty"))

	local h = 14
	BasePlayfield.addHitError(playfield, {
		transform = playfield:newLaneCenterTransform(self.unit),
		x = 0,
		y = config:get("HitErrorPosition") or 480,
		w = 64 * 4,
		h = h,
		origin = {
			w = 2,
			h = h + 4,
			color = {1, 1, 1, 1}
		},
		background = {
			color = {0.25, 0.25, 0.25, 0.5}
		},
		radius = 1.5,
		count = 20,
	})

	BasePlayfield.addMatchPlayers(playfield)
end

---@param key number
---@param keymode number
---@return string|number
local function getNoteType(key, keymode)
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

---@param od number
function OsuNoteSkin:addJudgements(od)  -- TriggerScoreIncrease
	local mania = self.mania

	local rate = 20
	local duration = 0.22

	local judgements = {}
	for i, jd in ipairs(defaultJudgements) do
		local name, key, default = unpack(jd)
		local path, range = self:findAnimation(mania[key])
		if not path then
			path, range = self:findAnimation(default)
		end
		if path then
			local judgement = {name, path, range}
			local frames = 1
			if range then
				frames = range[2] - range[1] + 1
			end
			judgement.cycles = rate * duration / frames
			table.insert(judgements, judgement)
		end
	end

	local position = mania.ScorePosition
	if self.upscroll then
		position = 480 - position
	end

	self.playField:addJudgement({
		x = 0, y = position, ox = 0.5, oy = 0.5,
		scale = 480 / 768,
		transform = self.playField:newLaneCenterTransform(480),
		key = "osuOD" .. od,
		rate = rate,
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

---@param prefix string
---@return string|table?
---@return number?
function OsuNoteSkin:findCharFiles(prefix)
	prefix = prefix:gsub("\\", "/"):lower()
	local files = self.files[prefix:gsub("\\", "/"):lower()]
	if not files then
		return
	end

	local images = {}
	for _, file in ipairs(files) do
		if file.char then
			local dpi = file.dpi or 1
			local char = chars[file.char] or file.char
			images[dpi] = images[dpi] or {}
			images[dpi][char] = file.path
		end
	end

	return (self:getMaxResolution(images))
end

function OsuNoteSkin:addCombo()
	local fonts = self.skinini.Fonts
	local files = self:findCharFiles(fonts.ComboPrefix)
	local position = self.mania.ComboPosition
	if self.upscroll then
		position = 480 - position
	end
	self.playField:addCombo(ImageValueView({
		transform = self.playField:newLaneCenterTransform(480),
		x = 0,
		y = position,
		oy = 0.5,
		align = "center",
		scale = 480 / 768,
		overlap = fonts.ComboOverlap,
		files = files,
	}))
end

function OsuNoteSkin:addScore()
	local fonts = self.skinini.Fonts
	local files = self:findCharFiles(fonts.ScorePrefix)
	self.scoreConfig = ImageValueView({
		transform = self.playField:newTransform(1024, 768, "right"),
		x = 1024,
		y = 0,
		align = "right",
		overlap = fonts.ScoreOverlap,
		files = files,
	})
	self.playField:addScore(self.scoreConfig)
end

---@return sphere.ImageValueView
function OsuNoteSkin:addAccuracy()
	local fonts = self.skinini.Fonts
	local files = self:findCharFiles(fonts.ScorePrefix)
	local scoreConfig = self.scoreConfig
	return self.playField:addAccuracy(ImageValueView({
		transform = self.playField:newTransform(1024, 768, "right"),
		x = 1024,
		y = 0,
		scale = 0.6,
		align = "right",
		format = "%0.2f%%",
		overlap = fonts.ScoreOverlap,
		files = files,
		draw = function(self)
			self.y = scoreConfig.height
			ImageValueView.draw(self)
		end,
	}))
end

---@return table
function OsuNoteSkin:getDefaultNoteImages()
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

---@return table
---@return table
function OsuNoteSkin:getDefaultKeyImages()
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

---@param images table
---@return string|table
---@return number
function OsuNoteSkin:getMaxResolution(images)
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

---@param value string?
---@param preferFrame boolean?
---@return string|table?
function OsuNoteSkin:findImage(value, preferFrame)
	if not value then
		return
	end

	value = self:removeExtLower(value:gsub("\\", "/"))
	local files = self.files[value]
	if not files then
		return
	end

	local single = {}
	local frame = {}
	for _, file in ipairs(files) do
		local dpi = file.dpi or 1
		if not file.frame then
			single[dpi] = file.path
		elseif file.frame == 0 then
			frame[dpi] = file.path
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

---@param value string?
---@return string|table?
---@return table?
function OsuNoteSkin:findAnimation(value)
	if not value then
		return
	end

	value = self:removeExtLower(value:gsub("\\", "/"))
	local files = self.files[value]
	if not files then
		return
	end

	local singles = {}
	local frames = {}
	local framesPath = {}
	for _, file in ipairs(files) do
		local trueValue = file.path:sub(1, #value)
		local dpi = file.dpi or 1
		if not file.frame then
			singles[dpi] = file.path
		elseif file.frame then
			frames[dpi] = frames[dpi] or {}
			table.insert(frames[dpi], file.frame)
			framesPath[dpi] = trueValue .. "-%d" .. (dpi > 1 and "@" .. dpi .. "x" or "") .. "." .. file.ext
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

---@param xl number
---@param xr number
---@param w number
function OsuNoteSkin:addStages(xl, xr, w)
	local mania = self.mania
	local playfield = self.playField

	local stageLeft = self:findImage(mania.StageLeft) or self:findImage("mania-stage-left")
	if stageLeft then
		playfield:add(ImageView({
			x = xl,
			y = 480,
			sx = 480 / 768,
			h = 480,
			oy = 1,
			ox = 1,
			transform = playfield:newNoteskinTransform(),
			image = stageLeft,
		}))
	end

	local stageRight = self:findImage(mania.StageRight) or self:findImage("mania-stage-right")
	if stageRight then
		playfield:add(ImageView({
			x = xr,
			y = 480,
			sx = 480 / 768,
			h = 480,
			oy = 1,
			transform = playfield:newNoteskinTransform(),
			image = stageRight,
		}))
	end

	local stageHint = self:findImage(mania.StageHint) or self:findImage("mania-stage-hint")
	if stageHint then
		playfield:add(ImageView({
			x = xl,
			y = self.hitposition,
			w = w,
			sy = 1,
			oy = 0.5,
			transform = playfield:newNoteskinTransform(),
			image = stageHint,
		}))
	end

	local stageBottom = self:findImage(mania.StageBottom) or self:findImage("mania-stage-bottom")
	if stageBottom then
		playfield:add(ImageView({
			x = 0,
			y = 480,
			sx = 1,
			sy = 1,
			oy = 1,
			ox = 0.5,
			transform = self.playField:newLaneCenterTransform(480),
			image = stageBottom,
		}))
	end
end

function OsuNoteSkin:addHpBar()
	local playfield = self.playField

	local cc = self.columnsCount
	local right = self.columns[cc] + self.width[cc] + self.space[cc + 1]

	local scoreBarBg = self:findImage("scorebar-bg")
	if scoreBarBg then
		playfield:add(ImageView({
			x = right + 1,
			y = 480,
			sx = 480 / 768 * 0.7,
			sy = 480 / 768 * 0.7,
			r = -math.pi / 2,
			transform = playfield:newNoteskinTransform(),
			image = scoreBarBg,
		}))
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
		playfield:addHpBar(ImageProgressView({
			x = x,
			y = y,
			sx = 480 / 768 * 0.7,
			sy = 480 / 768 * 0.7,
			r = -math.pi / 2,
			transform = playfield:newNoteskinTransform(),
			direction = "left-right",
			mode = "+",
			image = scoreBar,
		}))
	end
end

---@param keys number
function OsuNoteSkin:setKeys(keys)
	for _, mania in ipairs(self.skinini.Mania) do
		if tonumber(mania.Keys) == keys then
			self.mania = mania
			return
		end
	end
	self.mania = {Keys = keys}
end

---@param file_name string
---@return string
---@return string?
function OsuNoteSkin:removeExtLower(file_name)
	local name, ext = file_name:lower():match("^(.+)%.(.-)$")
	if not name or not supportedImageFormats[ext] then
		return file_name:lower()
	end
	return name, ext
end

---@param files table
---@return table
function OsuNoteSkin:processFiles(files)
	local _files = {}

	for _, file in ipairs(files) do
		local key1, ext = self:removeExtLower(file)
		if supportedImageFormats[ext] then
			local key2, dpi = key1:match("^(.+)@(%d+)x$")
			key2 = key2 or key1

			local key3, frame = key2:match("^(.+)-(.-)$")
			if not (tonumber(frame) or chars[frame]) then
				key3, frame = key2, nil
			end
			key3 = key3 or key2

			_files[key3] = _files[key3] or {}
			table.insert(_files[key3], {
				path = file,
				char = frame,
				frame = tonumber(frame),
				dpi = tonumber(dpi),
				ext = ext,
			})
		end
	end

	return _files
end

---@param content string
---@return table
function OsuNoteSkin:parseSkinIni(content)
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

	copyDefaults(self:getDefaultGeneralSection(), skinini.General)
	copyDefaults(self:getDefaultFontsSection(), skinini.Fonts)

	local skinnedKeys = {}
	for i, mania in ipairs(skinini.Mania) do
		local keys = tonumber(mania.Keys)
		if keys then
			skinnedKeys[keys] = true
		end
	end
	return skinini
end

---@param value number
---@param count number
---@return table
local function tovalues(value, count)
	local t = {}
	for i = 1, count do
		t[i] = value
	end
	return t
end

---@return table
function OsuNoteSkin:getDefaultGeneralSection()
	local general = {}

	general.Name = "Unknown"
	general.Author = ""
	general.SliderBallFlip = 0
	general.CursorRotate = 1
	general.CursorExpand = 1
	general.CursorCentre = 1
	general.SliderBallFrames = 10
	general.HitCircleOverlayAboveNumber = 1
	general.SpinnerFrequencyModulate = 1
	general.LayeredHitSounds = 1
	general.SpinnerFadePlayfield = 0
	general.SpinnerNoBlink = 0
	general.AllowSliderBallTint = 0
	general.AnimationFramerate = -1
	general.CursorTrailRotate = 0
	general.CustomComboBurstSounds = {}
	general.ComboBurstRandom = 0
	general.SliderStyle = 2

	return general
end

---@return table
function OsuNoteSkin:getDefaultFontsSection()
	local fonts = {}

	fonts.HitCirclePrefix = "default"
	fonts.ScorePrefix = "score"
	fonts.ComboPrefix = "score"
	fonts.HitCircleOverlap = -2
	fonts.ScoreOverlap = 0
	fonts.ComboOverlap = 0

	return fonts
end

---@param keys number
---@return table
function OsuNoteSkin:getDefaultManiaSection(keys)
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
	mania.SplitStages = keys >= 10 and 1 or 0
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

function OsuNoteSkin:fixManiaValues()
	if self.config.data.DisableLimits then
		return
	end

	local mania = self.mania

	local clw = mania.ColumnLineWidth
	for i = 1, #clw do
		local wi = clw[i]
		clw[i] = wi > 0 and wi < 2 and 2 or wi
	end

	local cw = mania.ColumnWidth
	for i = 1, #cw do
		cw[i] = math.min(math.max(cw[i], 5), 100)
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
