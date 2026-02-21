local class = require("class")
local delay = require("delay")
local thread = require("thread")
local audio = require("audio")
local AudioPreviewPlayer = require("rizu.gameplay.AudioPreviewPlayer")

---@class sphere.PreviewModel
---@operator call: sphere.PreviewModel
local PreviewModel = class()

PreviewModel.preview_time = 0
PreviewModel.position = 0
PreviewModel.mode = "absolute"

---@param configModel sphere.ConfigModel
function PreviewModel:new(configModel)
	self.configModel = configModel
	self.audioPreviewPlayer = AudioPreviewPlayer(configModel)
	self.generating_hashes = {}
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
	if self.audio_path ~= audio_path or not self.audio or self.chartview ~= chartview then
		self.audio_path = audio_path
		self.preview_time = preview_time
		self.mode = mode
		self.chartview = chartview
		self:loadPreviewDebounce()
		return
	end
	if self._on_load then
		self._on_load()
		self._on_load = nil
	end
end

---@param f function
function PreviewModel:onLoad(f)
	self._on_load = f
end

function PreviewModel:update()
	local settings = self.configModel.configs.settings
	local muteOnUnfocus = settings.miscellaneous.muteOnUnfocus
	local hasFocus = love.window.hasFocus()

	local dt = love.timer.getDelta() * self.rate
	local audio = self.audio
	if audio then
		if not audio:isPlaying() and hasFocus then
			audio:seek(self.position)
			if not audio:play() then
				self.audio = nil -- invalid audio
				return
			end
			self.audioPreviewPlayer:seek(self.position)
		elseif audio:isPlaying() and not hasFocus and muteOnUnfocus then
			audio:pause()
			self.audioPreviewPlayer:pause()
		elseif audio:isPlaying() and hasFocus then
			self.audioPreviewPlayer:resume()
		end
	else
		if hasFocus or not muteOnUnfocus then
			local duration = self.chartview and self.chartview.duration or 0
			if duration > 0 then
				self.manual_time = (self.manual_time or self.position) + dt
				if self.manual_time > duration then
					self.manual_time = self.position
					self.audioPreviewPlayer:seek(self.position)
				end
			end
			self.audioPreviewPlayer:resume()
		elseif not hasFocus and muteOnUnfocus then
			self.audioPreviewPlayer:pause()
		end
	end

	local time = self:getTime()
	self.audioPreviewPlayer:update(time)

	local volumeConfig = settings.audio.volume
	local volume = volumeConfig.master * volumeConfig.music
	if self.volume ~= volume then
		if audio then audio:setVolume(volume) end
		self.audioPreviewPlayer:setVolume(volume)
		self.volume = volume
	end

	local target_rate = self.target_rate
	if self.rate ~= target_rate then
		if audio then
			audio:setRate(target_rate)
		end
		self.audioPreviewPlayer:setRate(target_rate)
		self.rate = target_rate
	end
end

---@param rate number
function PreviewModel:setRate(rate)
	self.target_rate = rate
end

function PreviewModel:getTime()
	if not self.audio then
		return self.manual_time or 0
	end
	return self.audio:getPosition()
end

function PreviewModel:loadPreviewDebounce()
	delay.debounce(self, "loadDebounce", 0.1, self.loadPreview, self)
end

local loadingPreview
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

	if self.audio then
		if self.path ~= path then
			self:stop()
		else
			loadingPreview = false
			return
		end
	end

	self.audioPreviewPlayer:stop()

	local audio
	if path:find("^http") then
		audio = self:loadAudio(path, "http")
	else
		audio = self:loadAudio(path)
	end

	loadingPreview = false
	if path ~= self.audio_path then
		self:loadPreview()
		return
	end

	local volumeConfig = self.configModel.configs.settings.audio.volume
	local volume = volumeConfig.master * volumeConfig.music

	local position = self.preview_time
	if self.mode == "relative" then
		-- audio is needed for relative position
		if audio then
			position = audio:getDuration() * position
		else
			position = 0
		end
	end
	position = math.max(position, 0)
	self.position = position

	local hash = self.chartview and self.chartview.hash
	local has_audio_preview = false
	if hash then
		local preview_path = "userdata/audio_previews/" .. hash .. ".audio_preview"
		local data = love.filesystem.read(preview_path)
		if data then
			self.audioPreviewPlayer:load(data, self.chartview.location_dir)
			has_audio_preview = true
		end
	end

	if not audio then
		if has_audio_preview then
			self.manual_time = position
			self.audioPreviewPlayer:setVolume(volume)
			self.audioPreviewPlayer:setRate(self.rate)
			self.audioPreviewPlayer:seek(position)
		else
			if self.chartview and self.chartview.hash then
				if not self.attempted_hashes[hash] then
					self:generateAudioPreview(self.chartview)
				end
			end
			return
		end
	else
		self.audio = audio
		self.path = path

		audio:seek(position)
		audio:setVolume(volume)
		if audio.setRate then
			audio:setRate(self.rate)
		else
			audio:setPitch(self.rate)
		end
		if not audio:play() then
			self.audio = nil -- invalid audio
		end

		if has_audio_preview then
			self.audioPreviewPlayer:setVolume(volume)
			self.audioPreviewPlayer:setRate(self.rate)
			self.audioPreviewPlayer:seek(position)
		elseif self.chartview and self.chartview.hash then
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
	local ChartFactory = require("notechart.ChartFactory")
	local LoveFilesystem = require("fs.LoveFilesystem")

	require("love.sound")
	require("love.filesystem")

	local fs = LoveFilesystem()
	local generator = AudioPreviewGenerator(fs)

	local content = love.filesystem.read(chartview_data.location_path)
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
	if not self.audio then
		return
	end
	self.audio:stop()
	self.audio:release()
	self.audio = nil
end

local loadHttp = thread.async(function(url)
	local http = require("http")
	local body = http.request(url)
	if not body then
		return
	end

	require("love.filesystem")
	require("love.audio")
	require("love.sound")
	local fileData = love.filesystem.newFileData(body, url:match("^.+/(.-)$"))
	local status, source = pcall(love.audio.newSource, fileData, "static")
	if status then
		return source
	end
end)

local function loadAudio(path)
	local status, source = pcall(audio.newFileSource, path)
	if status then
		return source
	end
end

---@param path string
---@param type string?
---@return love.Source?
function PreviewModel:loadAudio(path, type)
	local source
	if type == "http" then
		source = loadHttp(path)
	else
		source = loadAudio(path)
	end
	return source
end

return PreviewModel
