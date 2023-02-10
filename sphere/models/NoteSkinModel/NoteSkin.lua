local Class = require("Class")
local NoteSkinData = require("sphere.models.NoteSkinModel.NoteSkinData")

local NoteSkin = Class:new()

NoteSkin.construct = function(self)
	self.notes = {}
	self.inputs = {}
	self.textures = {}
	self.images = {}
	self.blendModes = {}

	self.data = NoteSkinData:new()
	self.data.noteSkin = self
end

NoteSkin.loadData = function(self)
	self.data:load()
end

NoteSkin.check = function(self, note)
	return self.notes[note.noteType] and self.inputs[note.inputType .. note.inputIndex]
end

NoteSkin.getColumn = function(self, input, index)
	local inputs = self.inputs
	index = index or 1

	local c = 0
	for i = 1, #inputs do
		if inputs[i] == input then
			c = c + 1
			if c == index then
				return i
			end
		end
	end
end

NoteSkin.get = function(self, noteView, part, key, timeState)
	local note = noteView.graphicalNote
	local noteType = noteView.noteType
	local column = self:getColumn(note.inputType .. note.inputIndex, noteView.index)

	local value =
		self.notes[noteType] and
		self.notes[noteType][part] and
		self.notes[noteType][part][key]

	if type(value) == "table" then
		value = value[column]
	end
	if type(value) == "function" then
		return value(timeState, noteView, column)  -- multiple values
	end

	return value
end

NoteSkin.setTextures = function(self, textures)
	self.textures = textures
	return textures
end

NoteSkin.setImagesAuto = function(self, images)
	images = images or {}
	for i, texture in ipairs(self.textures) do
		local k, v = next(texture)
		images[k] = {k}
	end
	return self:setImages(images)
end

NoteSkin.setImages = function(self, images)
	local map = {}
	for i, texture in ipairs(self.textures) do
		local k, v = next(texture)
		map[k] = texture
	end
	for _, image in pairs(images) do
		image[1] = map[image[1]]
	end
	self.images = images
	return images
end

NoteSkin.setBlendModes = function(self, blendModes)
	self.blendModes = blendModes
	return blendModes
end

NoteSkin.getDimensions = function(self, imageName)
	local image = self.images[imageName]
	if not image then
		return 1, 1
	elseif image[2] then
		return image[2][3], image[2][4]
	elseif image[3] then
		return image[3][1], image[3][2]
	end
end

return NoteSkin
