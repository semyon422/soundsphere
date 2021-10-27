local NoteSkinVsrg = require("sphere.models.NoteSkinModel.NoteSkinVsrg")
local PlayfieldVsrg = require("sphere.models.NoteSkinModel.PlayfieldVsrg")

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
	self:setTextures(textures)
	self:setImages(images)

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

	playfield:addNotes()

	local pressed = {}
	local released = {}
	for i = 1, keysCount do
		pressed[i] = mania["KeyImage" .. (i - 1) .. "D"] .. ".png"
		released[i] = mania["KeyImage" .. (i - 1)] .. ".png"
	end
	playfield:addKeyImages({
		sy = 480 / 768,
		padding = 0,
		pressed = pressed,
		released = released,
	})
	playfield:disableCamera()
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

OsuNoteSkin.getDefaultNoteImages = function(self)
	local mania = self.mania
	local keysCount = tonumber(mania.Keys)

	local images = {}
	for i = 1, keysCount do
		local ni = "NoteImage" .. (i - 1)
		local mn = "mania-note" .. getNoteType(i - 1, keysCount)
		table.insert(images, {ni .. "L", mn .. "L"})
		table.insert(images, {ni .. "T", mn .. "T"})
		table.insert(images, {ni .. "H", mn .. "H"})
		table.insert(images, {ni, mn})
	end
	return images
end

OsuNoteSkin.findImage = function(self, value)
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
