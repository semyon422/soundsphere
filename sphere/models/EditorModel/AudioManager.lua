local class = require("class")
local audio = require("audio")
local rbtree = require("rbtree")

local Keyframe_mt = {}

function Keyframe_mt.__eq(a, b)
	return a.time == b.time
end

function Keyframe_mt.__lt(a, b)
	return a.time < b.time
end

local function newKeyFrame(time)
	return setmetatable({
		time = time,
		sources = {},
	}, Keyframe_mt)
end

local AudioManager = class()

AudioManager.time = 0

local function exTime(key)
	return key.time
end

function AudioManager:load()
	self.tree = rbtree.new()

	self.sources = {}
	self.firstTime = 0
	self.lastTime = 0
end

function AudioManager:unload()
	local sources = {}
	for _, key in self.tree:iter() do
		for placedSource in pairs(key.sources) do
			sources[placedSource] = sources
		end
	end

	for placedSource in pairs(sources) do
		placedSource.source:stop()
		placedSource.source:release()
	end

	self:load()
end

function AudioManager:update(force)
	local time = self.editorModel.timer:getTime()
	if time == self.time and not force then
		return
	end
	self.time = time

	local isPlaying = self.editorModel.timer.isPlaying
	local forcePosition = not isPlaying or force

	local sources = self:getCurrentSources()

	for placedSource in pairs(self.sources) do
		if not sources[placedSource] then
			placedSource.source:stop()
			self.sources[placedSource] = nil
		end
	end

	for placedSource in pairs(sources) do
		if not self.sources[placedSource] then
			self.sources[placedSource] = true
		end
		placedSource.source:setRate(self.editorModel.timer.rate)
		local volume = placedSource.isStream and self.volume.music or self.volume.effects
		placedSource.source:setVolume(self.volume.master * volume * placedSource.volume)
	end

	if forcePosition then
		for placedSource in pairs(self.sources) do
			placedSource.source:setPosition(time - placedSource.offset)
		end
	end

	if isPlaying then
		for placedSource in pairs(sources) do
			placedSource.source:play()
		end
	end
end

function AudioManager:play()
	local time = self.editorModel.timer:getTime()
	for placedSource in pairs(self.sources) do
		placedSource.source:setPosition(time - placedSource.offset)
	end
end

function AudioManager:pause()
	for placedSource in pairs(self.sources) do
		placedSource.source:pause()
	end
end

function AudioManager:getCurrentSources()
	local time = self.time

	local a, b = self.tree:findex(time, exTime)
	if a then
		return a.key.sources
	end
	if not b then
		return {}
	end

	if b.key.time > time then
		local prev = b:prev()
		return prev and prev.key.sources or {}
	end

	return b.key.sources
end

function AudioManager:getNode(time)
	local tree = self.tree
	local n = tree:findex(time, exTime)
	if n then
		return n
	end

	n = tree:insert(newKeyFrame(time))

	local l = n:prev()
	if not l then
		return n
	end

	for source in pairs(l.key.sources) do
		n.key.sources[source] = true
	end

	return n
end

function AudioManager:insert(placedSource)
	local startTime, endTime = placedSource.offset, placedSource.offset + placedSource.duration

	local a = self:getNode(startTime)
	local b = self:getNode(endTime)

	a.key.sources[placedSource] = true

	local n = a:next()
	while n and n.key < b.key do
		n.key.sources[placedSource] = true
		n = n:next()
	end
end

function AudioManager:remove(placedSource)
	local n = self:getNode(placedSource.offset)

	while n and n.key.sources[placedSource] do
		n.key.sources[placedSource] = nil
		local _n = n
		n = n:next()
		if not next(_n.key.sources) then
			self.tree:remove_node(_n)
		end
	end
end

function AudioManager:loadResources(noteChart)
	local audioSettings = self.editorModel:getAudioSettings()
	for noteDatas in noteChart:getInputIterator() do
		for _, noteData in ipairs(noteDatas) do
			local offset = noteData.timePoint.absoluteTime
			if noteData.sounds and not noteData.stream then
				for _, s in ipairs(noteData.sounds) do
					local soundData = self.editorModel.resourceModel:getResource(s[1])
					if soundData then
						local mode = audioSettings.mode.secondary
						local duration = soundData:getDuration()
						self:insert({
							offset = offset,
							duration = duration,
							soundData = soundData,
							source = audio.newSource(soundData, mode),
							name = s[1],
							volume = s[2],
							isStream = noteData.stream,
						})
						self.firstTime = math.min(self.firstTime, offset)
						self.lastTime = math.max(self.lastTime, offset + duration)
					end
				end
			end
		end
	end
	-- self.firstTime = self.tree:min().key.time
	-- self.lastTime = self.tree:max().key.time
end

return AudioManager
