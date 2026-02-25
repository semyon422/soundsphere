local ISoundDecoder = require("rizu.engine.audio.ISoundDecoder")
local ChartAudioMixer = require("rizu.engine.audio.ChartAudioMixer")
local ResourceFinder = require("rizu.files.ResourceFinder")
local LazySoundDecoder = require("rizu.engine.audio.LazySoundDecoder")
local LazyDataSoundDecoder = require("rizu.engine.audio.LazyDataSoundDecoder")
local OJM = require("o2jam.OJM")

---@class rizu.PreviewSoundDecoder: rizu.ISoundDecoder
---@operator call: rizu.PreviewSoundDecoder
---@field private mixer rizu.ChartAudioMixer
local PreviewSoundDecoder = ISoundDecoder + {}

---@param fs fs.IFilesystem
---@param dir string
---@param preview rizu.gameplay.AudioPreview
---@param decoder_factory fun(data: string): rizu.ISoundDecoder
function PreviewSoundDecoder:new(fs, dir, preview, decoder_factory)
	local rf = ResourceFinder(fs)
	rf:addPath(dir)

	local is_ojm = preview.samples[1] and preview.samples[1]:lower():match("%.ojm$")
	if is_ojm then
		return self:newOjm(fs, rf, preview, decoder_factory)
	end

	return self:newFiles(fs, rf, preview, decoder_factory)
end

---@param fs fs.IFilesystem
---@param rf rizu.ResourceFinder
---@param preview rizu.gameplay.AudioPreview
---@param decoder_factory fun(data: string): rizu.ISoundDecoder
function PreviewSoundDecoder:newOjm(fs, rf, preview, decoder_factory)
	local ojm_filename = preview.samples[1]

	---@type o2jam.OJM?
	local ojm
	local path = rf:findFile(ojm_filename, "ojm")
	if path then
		local data = fs:read(path)
		if data then
			ojm = OJM(data)
		end
	end

	if not ojm then
		print("PreviewSoundDecoder: could not load OJM " .. tostring(ojm_filename))
		self.mixer = ChartAudioMixer({}, {})
		return
	end

	-- Probe first sound to determine output format
	local sample_rate, channels, bytes_per_sample = 44100, 2, 2
	for i, event in ipairs(preview.events) do
		local sample_data = ojm.samples[event.sample_index - 1]
		if sample_data then
			local dec = decoder_factory(sample_data)
			sample_rate = dec:getSampleRate()
			channels = dec:getChannelCount()
			bytes_per_sample = dec:getBytesPerSample()
			dec:release()
			break
		end
	end

	local sounds = {}
	local decoders = {}
	for i, event in ipairs(preview.events) do
		local sample_data = ojm.samples[event.sample_index - 1]
		if sample_data then
			table.insert(sounds, {time = event.time})
			table.insert(decoders, LazyDataSoundDecoder(
				sample_data, decoder_factory,
				event.duration, sample_rate, channels, bytes_per_sample,
				event.volume
			))
		end
	end

	self.mixer = ChartAudioMixer(sounds, decoders)
end

---@param fs fs.IFilesystem
---@param rf rizu.ResourceFinder
---@param preview rizu.gameplay.AudioPreview
---@param decoder_factory fun(data: string): rizu.ISoundDecoder
function PreviewSoundDecoder:newFiles(fs, rf, preview, decoder_factory)
	-- Default format, will be updated if at least one sound is found
	local sample_rate, channels, bytes_per_sample = 44100, 2, 2

	-- Pre-find actual paths to avoid repeated searches
	---@type {[integer]: string}
	local sample_to_actual = {}
	for i, sample_path in ipairs(preview.samples) do
		sample_to_actual[i] = rf:findFile(sample_path, "audio")
	end

	-- Probe first sound to determine output format
	for i, event in ipairs(preview.events) do
		local actual_path = sample_to_actual[event.sample_index]
		if actual_path then
			local data = fs:read(actual_path)
			if data then
				local dec = decoder_factory(data)
				sample_rate = dec:getSampleRate()
				channels = dec:getChannelCount()
				bytes_per_sample = dec:getBytesPerSample()
				dec:release()
				break
			end
		end
	end

	local sounds = {}
	local decoders = {}
	for i, event in ipairs(preview.events) do
		local actual_path = sample_to_actual[event.sample_index]
		if actual_path then
			table.insert(sounds, {time = event.time})
			table.insert(decoders, LazySoundDecoder(
				fs, actual_path, decoder_factory,
				event.duration, sample_rate, channels, bytes_per_sample,
				event.volume
			))
		end
	end

	self.mixer = ChartAudioMixer(sounds, decoders)
end

function PreviewSoundDecoder:getData(buf, len) return self.mixer:getData(buf, len) end
function PreviewSoundDecoder:getSampleRate() return self.mixer:getSampleRate() end
function PreviewSoundDecoder:getChannelCount() return self.mixer:getChannelCount() end
function PreviewSoundDecoder:getBytesPerSample() return self.mixer:getBytesPerSample() end
function PreviewSoundDecoder:getDuration() return self.mixer:getDuration() end
function PreviewSoundDecoder:getBytesDuration() return self.mixer:getBytesDuration() end
function PreviewSoundDecoder:getBytesPosition() return self.mixer:getBytesPosition() end
function PreviewSoundDecoder:getPosition() return self.mixer:getPosition() end

function PreviewSoundDecoder:setBytesPosition(pos)
	self.mixer:setBytesPosition(pos)
end

function PreviewSoundDecoder:setPosition(pos)
	self.mixer:setPosition(pos)
end

function PreviewSoundDecoder:secondsToBytes(s) return self.mixer:secondsToBytes(s) end
function PreviewSoundDecoder:bytesToSeconds(b) return self.mixer:bytesToSeconds(b) end

function PreviewSoundDecoder:release()
	self.mixer:release()
end

return PreviewSoundDecoder
