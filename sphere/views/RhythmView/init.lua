local Class = require("Class")
local NoteViewFactory = require("sphere.views.RhythmView.NoteViewFactory")
local gfx_util = require("gfx_util")

local RhythmView = Class:new()

RhythmView.load = function(self)
	local bga = self.game.configModel.configs.settings.gameplay.bga

	self.noteViews = {}

	local noteViewFactory = NoteViewFactory:new()
	noteViewFactory.videoBgaEnabled = bga.video
	noteViewFactory.imageBgaEnabled = bga.image
	if self.mode then
		noteViewFactory.mode = self.mode
	end
	self.noteViewFactory = noteViewFactory

	self.textures = {}
	self.quads = {}
	self.spriteBatches = {}
	self:loadImages()
end

RhythmView.receive = function(self, event)
	if event.name == "GraphicalNoteState" then
		local noteViews = self.noteViews
		local note = event.note
		if note.activated then
			local noteView = self.noteViewFactory:getNoteView(note)
			if not noteView then
				return
			end
			noteView.graphicEngine = self.game.rhythmModel.graphicEngine
			noteView.noteSkin = noteView.graphicEngine.noteSkin
			noteView.rhythmView = self
			noteViews[note] = noteView
		else
			local graphicalNote = noteViews[note]
			if not graphicalNote then
				return
			end
			noteViews[note] = nil
		end
	end
end

RhythmView.draw = function(self)
	love.graphics.origin()
	love.graphics.setColor(1, 1, 1, 1)
	local noteViews = {}
	for _, noteView in pairs(self.noteViews) do
		table.insert(noteViews, noteView)
	end
	table.sort(noteViews, function(a, b)
		return a.startNoteData.timePoint > b.startNoteData.timePoint
	end)

	local noteSkin = self.game.rhythmModel.graphicEngine.noteSkin
	local inputsCount = noteSkin.inputsCount
	local inputs = noteSkin.inputs

	local chords = {}
	for _, noteView in ipairs(noteViews) do
		local startNoteData = noteView.startNoteData

		local column = inputs[startNoteData.inputType .. startNoteData.inputIndex]
		if column and column <= inputsCount and noteView:isVisible() then
			if noteView.fillChords then
				noteView:fillChords(chords, column)
			end
		end
	end

	for _, noteView in ipairs(noteViews) do
		noteView:updateMiddleChord()
		noteView:draw()
	end

	local tf = gfx_util.transform(self.transform)
	love.graphics.replaceTransform(tf)

	local noteSkin = self.game.rhythmModel.graphicEngine.noteSkin
	local blendModes = noteSkin.blendModes
	for _, spriteBatch in ipairs(self.spriteBatches) do
		local key = self.spriteBatches[spriteBatch]
		local blendMode = blendModes[key]
		if blendMode then
			love.graphics.setBlendMode(blendMode[1], blendMode[2])
		end
		love.graphics.draw(spriteBatch)
		spriteBatch:clear()
		if blendMode then
			love.graphics.setBlendMode("alpha")
		end
	end
end

RhythmView.loadTexture = function(self, key, path)
	local textures = self.textures
	local spriteBatches = self.spriteBatches

	local status, err = pcall(love.graphics.newImage, self.game.rhythmModel.graphicEngine.noteSkin.directoryPath .. "/" .. path)
	-- async load, use FileManager

	local texture = status and err or gfx_util.newPixel(1, 1, 1, 1)
	local spriteBatch = love.graphics.newSpriteBatch(texture, 1000)

	textures[key] = textures[key] or {}
	textures[key][path] = texture
	spriteBatches[key] = spriteBatches[key] or {}
	spriteBatches[key][path] = spriteBatch
	table.insert(spriteBatches, spriteBatch)
	spriteBatches[spriteBatch] = key
end

RhythmView.loadImages = function(self)
	for i, texture in ipairs(self.game.rhythmModel.graphicEngine.noteSkin.textures) do
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

	for imageName, image in pairs(self.game.rhythmModel.graphicEngine.noteSkin.images) do
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

RhythmView.getDimensions = function(self, note, part, key, timeState)
	local noteSkin = self.game.rhythmModel.graphicEngine.noteSkin
	return noteSkin:getDimensions(noteSkin:get(note, part, key, timeState))
end

RhythmView.getSpriteBatch = function(self, note, part, key, timeState)
	local noteSkin = self.game.rhythmModel.graphicEngine.noteSkin
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

RhythmView.getQuad = function(self, note, part, key, timeState)
	local noteSkin = self.game.rhythmModel.graphicEngine.noteSkin
	local imageName, frame = noteSkin:get(note, part, key, timeState)
	local quad = self.quads[imageName]
	if type(quad) == "table" then
		return quad[frame]
	end
	return quad
end

return RhythmView
