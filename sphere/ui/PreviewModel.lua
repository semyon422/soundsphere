local class = require("class")
local delay = require("delay")
local thread = require("thread")
local AudioPreviewPlayer = require("rizu.gameplay.AudioPreviewPlayer")

---@class sphere.PreviewModel
---@operator call: sphere.PreviewModel
local PreviewModel = class()

PreviewModel.preview_time = 0
PreviewModel.position = 0
PreviewModel.mode = "absolute"
PreviewModel.manual_time = 0

---@param configModel sphere.ConfigModel
function PreviewModel:new(configModel)
	self.configModel = configModel
	self.audioPreviewPlayer = AudioPreviewPlayer(configModel)
	---@type {[string]: boolean?}
	self.generating_hashes = {}
	---@type {[string]: boolean?}
	self.attempted_hashes = {}
end

function PreviewModel:load()
	self.audio_path = ""
	self.volume = 0
	self.rate = 1
	self.target_rate = 1
end

---@param audio_path string?
---@param preview_time number?
---@param mode string?
---@param chartview table?
function PreviewModel:setAudioPathPreview(audio_path, preview_time, mode, chartview)
	local is_same_audio = self.audio_path == audio_path and (audio_path or "") ~= ""
	local is_same_chart_file = self.chartview and chartview and self.chartview.location_path == chartview.location_path

	if self.audio_path ~= audio_path or self.chartview ~= chartview then
		self.audio_path = audio_path
		self.preview_time = preview_time
		self.mode = mode
		self.chartview = chartview

		if not is_same_audio and not is_same_chart_file then
			self:loadPreviewDebounce()
			return
		end
	end

	if self._on_load then
		self._on_load()
		self._on_load = nil
	end
end

---@param f function?
function PreviewModel:onLoad(f)
	self._on_load = f
end

function PreviewModel:update()
	local settings = self.configModel.configs.settings
	local muteOnUnfocus = settings.miscellaneous.muteOnUnfocus
	local hasFocus = love.window.hasFocus()

	if hasFocus or not muteOnUnfocus then
		local start_time = self.chartview and self.chartview.start_time or 0
		local duration = self.chartview and self.chartview.duration or 0
		if duration > 0 then
			self.manual_time = self.audioPreviewPlayer:getPosition()
			if self.manual_time > start_time + duration then
				self.manual_time = 0
				self.audioPreviewPlayer:seek(self.manual_time)
			end
		end
		self.audioPreviewPlayer:resume()
	else
		self.audioPreviewPlayer:pause()
	end

	self.audioPreviewPlayer:update()

	local volumeConfig = settings.audio.volume
	local volume = volumeConfig.master * volumeConfig.music
	if self.volume ~= volume then
		self.audioPreviewPlayer:setVolume(volume)
		self.volume = volume
	end

	local target_rate = self.target_rate
	if self.rate ~= target_rate then
		self.audioPreviewPlayer:setRate(target_rate)
		self.rate = target_rate
	end
end

---@param rate number
function PreviewModel:setRate(rate)
	self.target_rate = rate
end

function PreviewModel:getTime()
	return self.manual_time
end

---@param size integer
function PreviewModel:setFFTSize(size)
	self.audioPreviewPlayer:setFFTSize(size)
end

---@return ffi.cdata*?
function PreviewModel:getFFT()
	return self.audioPreviewPlayer:getFFT()
end

function PreviewModel:loadPreviewDebounce()
	delay.debounce(self, "loadDebounce", 0.1, self.loadPreview, self)
end

local loadingPreview = false
function PreviewModel:loadPreview()
	if loadingPreview then
		return
	end
	loadingPreview = true

	local path = self.audio_path

	if not path then
		loadingPreview = false
		self:stop()
		return
	end

	self.audioPreviewPlayer:stop()

	loadingPreview = false
	if path ~= self.audio_path then
		self:loadPreview()
		return
	end

	local volumeConfig = self.configModel.configs.settings.audio.volume
	local volume = volumeConfig.master * volumeConfig.music

	local position = self.preview_time or 0
	if self.mode == "relative" then
		position = (self.chartview and self.chartview.duration or 0) * position
	end
	position = math.max(position, 0)
	self.position = position
	self.manual_time = position

	---@type string?
	local hash = self.chartview and self.chartview.hash
	if hash then
		local preview_path = "userdata/audio_previews/" .. hash .. ".audio_preview"
		if love.filesystem.getInfo(preview_path) then
			self.audioPreviewPlayer:load(preview_path, self.chartview.location_dir)
			self.audioPreviewPlayer:setVolume(volume)
			self.audioPreviewPlayer:setRate(self.rate)
			self.audioPreviewPlayer:seek(position)
		else
			if not self.attempted_hashes[hash] then
				self:generateAudioPreview(self.chartview)
			end
		end
	end

	self.volume = volume
	if self._on_load then
		self._on_load()
		self._on_load = nil
	end
end

local generateAudioPreviewAsync = thread.async(function(chartview_data)
	print("AudioPreview: generating " .. chartview_data.hash)
	local AudioPreviewGenerator = require("rizu.gameplay.AudioPreviewGenerator")
	local BassSoundDecoder = require("rizu.engine.audio.BassSoundDecoder")
	local ChartFactory = require("notechart.ChartFactory")
	local LoveFilesystem = require("fs.LoveFilesystem")

	require("love.filesystem")

	local fs = LoveFilesystem()
	local generator = AudioPreviewGenerator(fs, function(data)
		return BassSoundDecoder(data)
	end)

	local content = fs:read(chartview_data.location_path)
	if not content then
		print("AudioPreview: could not read " .. tostring(chartview_data.location_path))
		return false
	end

	local chart_chartmetas = ChartFactory:getCharts(chartview_data.chartfile_name, content)
	if not chart_chartmetas then
		print("AudioPreview: chart parsing failed for " .. tostring(chartview_data.chartfile_name))
		return false
	end

	local t = chart_chartmetas[chartview_data.index]
	if not t then
		print("AudioPreview: chart index " .. tostring(chartview_data.index) .. " not found")
		return false
	end

	t.chart.layers.main:toAbsolute()
	generator:generate(t.chart, chartview_data.location_dir, chartview_data.hash)
	return true
end)

---@param chartview table
function PreviewModel:generateAudioPreview(chartview)
	local hash = chartview.hash
	if self.generating_hashes[hash] then
		return
	end
	self.generating_hashes[hash] = true

	local chartview_data = {
		location_path = chartview.location_path,
		location_dir = chartview.location_dir,
		chartfile_name = chartview.chartfile_name,
		index = chartview.index,
		hash = hash,
	}

	thread.coro(function()
		local ok, result = pcall(generateAudioPreviewAsync, chartview_data)
		self.generating_hashes[hash] = nil
		self.attempted_hashes[hash] = true
		if ok and result then
			if self.chartview and self.chartview.hash == hash then
				self:loadPreview()
			end
		else
			print("AudioPreview: generation failed for " .. hash .. " error: " .. tostring(result))
		end
	end)()
end

function PreviewModel:stop()
	self.audioPreviewPlayer:stop()
	self.manual_time = 0
end

function PreviewModel:release()
	self:stop()
	self.audioPreviewPlayer:release()
end

return PreviewModel
