local Class = require("aqua.util.Class")
local NoteViewFactory = require("sphere.views.RhythmView.NoteViewFactory")
local transform = require("aqua.graphics.transform")

local RhythmView = Class:new()

RhythmView.load = function(self)
	local config = self.config
	local state = self.state

	state.noteViews = {}

	local noteViewFactory = NoteViewFactory:new()
	noteViewFactory.videoBgaEnabled = self.videoBgaEnabled
	noteViewFactory.imageBgaEnabled = self.imageBgaEnabled
	if config.mode then
		noteViewFactory.mode = config.mode
	end
	state.noteViewFactory = noteViewFactory

	state.textures = {}
	state.quads = {}
	state.spriteBatches = {}
	self:loadImages()
end

RhythmView.receive = function(self, event)
	local config = self.config
	local state = self.state

	if event.name == "GraphicalNoteState" then
		local noteViews = state.noteViews
		local note = event.note
		if note.activated then
			local noteView = state.noteViewFactory:getNoteView(note)
			if not noteView then
				return
			end
			noteView.graphicEngine = self.gameController.rhythmModel.graphicEngine
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
	elseif event.name == "TimeState" then
		for _, note in pairs(state.noteViews) do
			note:receive(event)
		end
	end
end

RhythmView.update = function(self, dt)
	local state = self.state
	for _, noteView in pairs(state.noteViews) do
		noteView:update(dt)
	end
end

RhythmView.draw = function(self)
	local config = self.config
	local state = self.state

	love.graphics.origin()
	love.graphics.setColor(1, 1, 1, 1)
	local noteViews = {}
	for _, noteView in pairs(state.noteViews) do
		table.insert(noteViews, noteView)
	end
	table.sort(noteViews, function(a, b)
		return a.startNoteData.timePoint > b.startNoteData.timePoint
	end)
	for _, noteView in ipairs(noteViews) do
		noteView:draw()
	end

	local tf = transform(config.transform)
	love.graphics.replaceTransform(tf)
	tf:release()

	for _, spriteBatch in ipairs(state.spriteBatches) do
		love.graphics.draw(spriteBatch)
		spriteBatch:clear()
	end
end

RhythmView.loadTexture = function(self, path)
	local state = self.state

	local texture = love.graphics.newImage(self.gameController.rhythmModel.graphicEngine.noteSkin.directoryPath .. "/" .. path)
	local spriteBatch = love.graphics.newSpriteBatch(texture, 1000)

	state.textures[path] = texture
	state.spriteBatches[path] = spriteBatch
	table.insert(state.spriteBatches, spriteBatch)
end

RhythmView.loadImages = function(self)
	local state = self.state

	for _, path in ipairs(self.gameController.rhythmModel.graphicEngine.noteSkin.textures) do
		if type(path) == "string" then
			self:loadTexture(path)
		elseif type(path) == "table" then
			local range = path[2]
			for i = range[1], range[2] do
				self:loadTexture(path[1]:format(i))
			end
		end
	end

	for imageName, image in pairs(self.gameController.rhythmModel.graphicEngine.noteSkin.images) do
		local path = image[1]
		if type(path) == "string" then
			local texture = state.textures[path]
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
			state.quads[imageName] = quad
		elseif type(path) == "table" then
			local texture = state.textures[path[1]:format(path[2][1])]
			local w, h = texture:getDimensions()
			image[3] = {w, h}
		end
	end
end

RhythmView.setBgaEnabled = function(self, type, enabled)
	if type == "video" then
		self.videoBgaEnabled = enabled
	elseif type == "image" then
		self.imageBgaEnabled = enabled
	end
end

RhythmView.getDimensions = function(self, note, part, key, timeState)
	local noteSkin = self.gameController.rhythmModel.graphicEngine.noteSkin
	return noteSkin:getDimensions(noteSkin:get(note, part, key, timeState))
end

RhythmView.getSpriteBatch = function(self, note, part, key, timeState)
	local state = self.state
	local noteSkin = self.gameController.rhythmModel.graphicEngine.noteSkin
	local imageName, frame = noteSkin:get(note, part, key, timeState)
	local image = noteSkin.images[imageName]
	if not image then
		return
	end
	local texture = image[1]
	if type(texture) == "string" then
		return state.spriteBatches[texture]
	elseif type(texture) == "table" then
		return state.spriteBatches[texture[1]:format(frame)]
	end
end

RhythmView.getQuad = function(self, note, part, key, timeState)
	local state = self.state
	local noteSkin = self.gameController.rhythmModel.graphicEngine.noteSkin
	local imageName, frame = noteSkin:get(note, part, key, timeState)
	local quad = state.quads[imageName]
	if type(quad) == "table" then
		return quad[frame]
	end
	return quad
end

return RhythmView
