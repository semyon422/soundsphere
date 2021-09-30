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

	self.name = skinini.General.Name
	self.playField = {}
	self.range = {-1, 1}
	self.unit = 480
	self.hitposition = tonumber(mania.HitPosition)

	local keys = {}
	for i = 1, tonumber(mania.Keys) do
		keys[i] = "key" .. i
	end
	self:setInput(keys)

	local space = toarray(mania.ColumnSpacing)
	table.insert(space, 1, 0)
	table.insert(space, 0)
	self:setColumns({
		offset = 0,
		align = "center",
		width = toarray(mania.ColumnWidth),
		space = space,
	})

	local textures = {}
	local images = {}
	for key, value in pairs(mania) do
		if key:find("^NoteImage") then
			table.insert(textures, {[key] = value .. ".png"})
			images[key] = {key}
		end
	end
	self:setTextures(textures)
	self:setImages(images)

	local shead = {}
	for i = 1, tonumber(mania.Keys) do
		shead[i] = "NoteImage" .. (i - 1)
	end
	self:setShortNote({
		image = shead
	})

	local lhead = {}
	local lbody = {}
	local ltail = {}
	for i = 1, tonumber(mania.Keys) do
		lhead[i] = "NoteImage" .. (i - 1) .. "H"
		lbody[i] = "NoteImage" .. (i - 1) .. "L"
		ltail[i] = "NoteImage" .. (i - 1) .. "T"
	end
	self:setLongNote({
		head = lhead,
		body = lbody,
		tail = ltail,
	})
	for i = 1, tonumber(mania.Keys) do
		local width = tonumber(mania.WidthForNoteHeightScale) or self.width[i]
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
			return h / w * width
		end
		self.notes.LongNote.Body.y = function(...)
			local w, h = self:getDimensions(lhead[i])
			return self:getPosition(...) - h / w * width / 2
		end
	end

	local playfield = PlayfieldVsrg:new({
		noteskin = self
	})

	playfield:enableCamera()
	playfield:addNotes()

	local pressed = {}
	local released = {}
	for i = 1, tonumber(mania.Keys) do
		pressed[i] = mania["KeyImage" .. (i - 1) .. "D"] .. ".png"
		released[i] = mania["KeyImage" .. (i - 1)] .. ".png"
	end
	playfield:addKeyImages({
		h = 480,
		padding = 0,
		pressed = pressed,
		released = released,
	})
	playfield:disableCamera()
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
