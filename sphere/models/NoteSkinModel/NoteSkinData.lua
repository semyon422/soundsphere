local class = require("class")
local gfx_util = require("gfx_util")

---@class sphere.NoteSkinData
---@operator call: sphere.NoteSkinData
local NoteSkinData = class()

function NoteSkinData:load()
	self.textures = {}
	self.quads = {}
	self.spriteBatches = {}
	self:loadImages()
end

---@param key string
---@param path string
function NoteSkinData:loadTexture(key, path)
	local textures = self.textures
	local spriteBatches = self.spriteBatches

	local status, texture = pcall(love.image.newImageData, self.noteSkin.directoryPath .. "/" .. path)
	if status then
		texture = love.graphics.newImage(gfx_util.limitImageData(texture))
	else
		texture = gfx_util.newPixel(1, 1, 1, 1)
	end
	texture:setWrap("repeat", "repeat")

	local spriteBatch = love.graphics.newSpriteBatch(texture, 1000)

	textures[key] = textures[key] or {}
	textures[key][path] = texture
	spriteBatches[key] = spriteBatches[key] or {}
	spriteBatches[key][path] = spriteBatch
	table.insert(spriteBatches, spriteBatch)
	spriteBatches[spriteBatch] = key
end

function NoteSkinData:loadImages()
	for i, texture in ipairs(self.noteSkin.textures) do
		local key, path = next(texture)
		if type(path) == "string" then
			self:loadTexture(key, path)
		elseif type(path) == "table" then
			local range = path[2]
			for i = range[1], range[2] do
				self:loadTexture(key, path[1]:format(i))
			end
		end
	end

	for imageName, image in pairs(self.noteSkin.images) do
		local key, path = next(image[1])
		if type(path) == "string" then
			local texture = self.textures[key][path]
			local w, h = texture:getDimensions()
			image[3] = {w, h}

			local quad
			local q = image[2]
			if q then
				local range = q[5]
				if not range then
					quad = love.graphics.newQuad(q[1], q[2], q[3], q[4], w, h)
				else
					quad = {}
					local offset = 0
					for i = range[1], range[2] do
						quad[i] = love.graphics.newQuad(q[1] + offset * q[3], q[2], q[3], q[4], w, h)
						offset = offset + 1
					end
				end
			end
			self.quads[imageName] = quad
		elseif type(path) == "table" then
			local texture = self.textures[key][path[1]:format(path[2][1])]
			local w, h = texture:getDimensions()
			image[3] = {w, h}
		end
	end
end

---@param note sphere.NoteView
---@param part string
---@param key string
---@param timeState table
---@return number
---@return number
function NoteSkinData:getDimensions(note, part, key, timeState)
	local noteSkin = self.noteSkin
	return noteSkin:getDimensions(noteSkin:get(note, part, key, timeState))
end

---@param note sphere.NoteView
---@param part string
---@param key string
---@param timeState table
---@return love.SpriteBatch?
function NoteSkinData:getSpriteBatch(note, part, key, timeState)
	local noteSkin = self.noteSkin
	local imageName, frame = noteSkin:get(note, part, key, timeState)
	local image = noteSkin.images[imageName]
	if not image then
		return
	end
	local texture = image[1]
	local key, path = next(texture)
	if type(path) == "string" then
		return self.spriteBatches[key][path]
	elseif type(path) == "table" then
		return self.spriteBatches[key][path[1]:format(frame)]
	end
end

---@param note sphere.NoteView
---@param part string
---@param key string
---@param timeState table
---@return love.Quad?
function NoteSkinData:getQuad(note, part, key, timeState)
	local noteSkin = self.noteSkin
	local imageName, frame = noteSkin:get(note, part, key, timeState)
	local quad = self.quads[imageName]
	if type(quad) == "table" then
		return quad[frame]
	end
	return quad
end

return NoteSkinData
