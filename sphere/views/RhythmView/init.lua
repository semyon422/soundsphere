local Class = require("aqua.util.Class")
local NoteViewFactory = require("sphere.views.RhythmView.NoteViewFactory")
local transform = require("aqua.graphics.transform")

local RhythmView = Class:new()

RhythmView.construct = function(self)
	self.noteViewFactory = NoteViewFactory:new()
end

RhythmView.load = function(self)
	self.noteViews = {}

	local noteViewFactory = self.noteViewFactory
	noteViewFactory.videoBgaEnabled = self.videoBgaEnabled
	noteViewFactory.imageBgaEnabled = self.imageBgaEnabled

	self.textures = {}
	self.images = {}
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
			noteView.graphicEngine = self.rhythmModel.graphicEngine
			noteView.noteSkin = self.noteSkin
			noteView.rhythmView = self
			noteViews[note] = noteView
		else
			local graphicalNote = noteViews[note]
			if not graphicalNote then
				return
			end
			noteViews[note] = nil
		end
	elseif event.name == "TimeState" then
		for _, note in pairs(self.noteViews) do
			note:receive(event)
		end
	end
end

RhythmView.update = function(self, dt)
	for _, noteView in pairs(self.noteViews) do
		noteView:update(dt)
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
	for _, noteView in ipairs(noteViews) do
		noteView:draw()
	end

	local tf = transform(self.noteSkin.transform)
	love.graphics.replaceTransform(tf)
	tf:release()

	for _, spriteBatch in ipairs(self.spriteBatches) do
		love.graphics.draw(spriteBatch)
		spriteBatch:clear()
	end
end

RhythmView.loadImages = function(self)
	for _, path in ipairs(self.noteSkin.textures) do
		local texture = love.graphics.newImage(self.noteSkin.directoryPath .. "/" .. path)
		local spriteBatch = love.graphics.newSpriteBatch(texture, 1000)

		self.textures[path] = texture
		self.spriteBatches[path] = spriteBatch
		table.insert(self.spriteBatches, spriteBatch)
	end

	for _, data in pairs(self.noteSkin.images) do
		local texture = self.textures[data[1]]
		local w, h = texture:getDimensions()
		data[3] = {w, h}

		local quad
		local q = data[2]
		if q then
			quad = love.graphics.newQuad(q[1], q[2], q[3], q[4], w, h)
		end

		self.images[data] = {texture, quad}
	end
end

RhythmView.setBgaEnabled = function(self, type, enabled)
	if type == "video" then
		self.videoBgaEnabled = enabled
	elseif type == "image" then
		self.imageBgaEnabled = enabled
	end
end

RhythmView.getDimensions = function(self, note, part)
	local image = self.noteSkin:get(note, part, "image")
	if image[2] then
		return image[2][3], image[2][4]
	elseif image[3] then
		return image[3][1], image[3][2]
	end
end

RhythmView.getSpriteBatch = function(self, note, part)
	local image = self.noteSkin:get(note, part, "image")
	return self.spriteBatches[image[1]]
end

RhythmView.getQuad = function(self, note, part)
	local image = self.noteSkin:get(note, part, "image")
	return self.images[image][2]
end

return RhythmView
