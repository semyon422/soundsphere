local class = require("class")
local AudioPreview = require("rizu.gameplay.AudioPreview")
local ResourceFinder = require("rizu.files.ResourceFinder")

---@class rizu.gameplay.AudioPreviewGenerator
---@operator call: rizu.gameplay.AudioPreviewGenerator
local AudioPreviewGenerator = class()

---@param fs fs.IFilesystem
function AudioPreviewGenerator:new(fs)
	self.fs = assert(fs, "missing fs")
end

---@param chart ncdk2.Chart
---@param chart_dir string
---@param hash string
function AudioPreviewGenerator:generate(chart, chart_dir, hash)
	local preview = AudioPreview()

	---@type {[string]: integer}
	local samples_map = {}

	---@type {[string]: number}
	local sample_durations = {}

	local finder = ResourceFinder(self.fs)
	finder:addPath(chart_dir)

	local notes = chart.notes.notes
	for _, note in ipairs(notes) do
		---@type [string, number?][]
		local sounds = note.data.sounds
		if sounds then
			for _, sound_data in ipairs(sounds) do
				local path = sound_data[1]
				local volume = sound_data[2] or 1

				if not samples_map[path] then
					table.insert(preview.samples, path)
					samples_map[path] = #preview.samples
				end

				local duration = self:getDuration(path, finder, sample_durations)
				if duration > 0 then
					table.insert(preview.events, {
						time = note:getTime(),
						sample_index = samples_map[path],
						duration = duration,
						volume = volume,
					})
				end
			end
		end
	end

	if #preview.events == 0 then
		print("AudioPreviewGenerator: no events generated for " .. hash)
		return
	end

	table.sort(preview.events, function(a, b)
		return a.time < b.time
	end)

	local output_dir = "userdata/audio_previews"
	if not self.fs:getInfo(output_dir) then
		self.fs:createDirectory(output_dir)
	end

	local output_path = output_dir .. "/" .. hash .. ".audio_preview"
	print("AudioPreviewGenerator: writing " .. #preview.events .. " events to " .. output_path)

	self.fs:write(output_path, preview:encode())
end

---@param path string
---@param finder rizu.ResourceFinder
---@param durs {[string]: number}
---@return number
function AudioPreviewGenerator:getDuration(path, finder, durs)
	if durs[path] then
		return durs[path]
	end

	local full_path = finder:findFile(path, "audio")
	if not full_path then
		print("AudioPreviewGenerator: could not find file " .. tostring(path))
		durs[path] = 0
		return 0
	end

	local content = self.fs:read(full_path)
	if not content then
		print("AudioPreviewGenerator: could not read " .. tostring(full_path))
		durs[path] = 0
		return 0
	end

	-- no fs access, just in-memory object
	local ok, fileData = pcall(love.filesystem.newFileData, content, full_path)
	if not ok then
		print("AudioPreviewGenerator: newFileData failed for " .. tostring(full_path) .. ": " .. tostring(fileData))
		durs[path] = 0
		return 0
	end

	local ok, decoder = pcall(love.sound.newDecoder, fileData)
	if not ok or not decoder then
		print("AudioPreviewGenerator: newDecoder failed for " .. tostring(path) .. ": " .. tostring(decoder))
		durs[path] = 0
		return 0
	end

	local duration = decoder:getDuration()
	if duration <= 0 then
		print("AudioPreviewGenerator: zero duration for " .. tostring(path))
	end

	durs[path] = duration

	return duration
end

return AudioPreviewGenerator
