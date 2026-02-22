local class = require("class")
local path_util = require("path_util")
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
	local samples_map = {}
	local sample_durations = {}

	local finder = ResourceFinder(self.fs)
	finder:addPath(chart_dir)

	---@param path string
	---@return number
	local function get_duration(path)
		if sample_durations[path] then
			return sample_durations[path]
		end

		local full_path = finder:findFile(path, "audio")
		if not full_path then
			print("AudioPreviewGenerator: could not find file " .. tostring(path))
			sample_durations[path] = 0
			return 0
		end

		local content = self.fs:read(full_path)
		if not content then
			print("AudioPreviewGenerator: could not read " .. tostring(full_path))
			sample_durations[path] = 0
			return 0
		end

		local ok, fileData = pcall(love.filesystem.newFileData, content, full_path)
		if not ok then
			print("AudioPreviewGenerator: newFileData failed for " .. tostring(full_path) .. ": " .. tostring(fileData))
			sample_durations[path] = 0
			return 0
		end

		local ok, decoder = pcall(love.sound.newDecoder, fileData)
		if not ok or not decoder then
			print("AudioPreviewGenerator: newDecoder failed for " .. tostring(path) .. ": " .. tostring(decoder))
			sample_durations[path] = 0
			return 0
		end

		local duration = decoder:getDuration()
		if duration <= 0 then
			print("AudioPreviewGenerator: zero duration for " .. tostring(path))
		end
		sample_durations[path] = duration
		return duration
	end

	local notes = chart.notes.notes
	for _, note in ipairs(notes) do
		local sounds = note.data.sounds
		if sounds then
			for _, sound_data in ipairs(sounds) do
				local path = sound_data[1]
				local volume = sound_data[2] or 1
				
				if not samples_map[path] then
					table.insert(preview.samples, path)
					samples_map[path] = #preview.samples
				end

				local duration = get_duration(path)
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

return AudioPreviewGenerator
