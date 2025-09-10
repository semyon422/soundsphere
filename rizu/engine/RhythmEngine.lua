local class = require("class")
local ChartAudio = require("rizu.engine.audio.ChartAudio")
local BassSoundDecoder = require("rizu.engine.audio.BassSoundDecoder")
local BassChartAudioSource = require("rizu.engine.audio.BassChartAudioSource")
local ChartAudioMixer = require("rizu.engine.audio.ChartAudioMixer")
local ResourceLoader = require("rizu.files.ResourceLoader")
local ResourceFinder = require("rizu.files.ResourceFinder")

local InputInfo = require("rizu.engine.input.InputInfo")
local InputEngine = require("rizu.engine.input.InputEngine")
local InputPauser = require("rizu.engine.input.InputPauser")

local TimeEngine = require("rizu.engine.time.TimeEngine")

local VisualInfo = require("rizu.engine.visual.VisualInfo")
local VisualEngine = require("rizu.engine.visual.VisualEngine")

---@class rizu.RhythmEngine
---@operator call: rizu.RhythmEngine
local RhythmEngine = class()

---@param fs fs.IFilesystem
function RhythmEngine:new(fs)
	self.chart_audio = ChartAudio()

	self.resource_finder = ResourceFinder(fs)
	self.resource_loader = ResourceLoader(fs, self.resource_finder)

	self.input_info = InputInfo()
	self.input_engine = InputEngine(self.input_info)
	self.input_pauser = InputPauser()

	self.visual_info = VisualInfo()
	self.visual_engine = VisualEngine(self.visual_info)

	self.time_engine = TimeEngine(false, 0.5, function()
		return self.chart_audio_source:getPosition()
	end)
end

---@param chart ncdk2.Chart
---@param dir string
function RhythmEngine:load(chart, dir)
	self.input_engine:load(chart)
	self.visual_engine:load(chart)

	self.resource_finder:reset()
	self.resource_finder:addPath(dir)
	self.resource_loader:load(chart.resources)

	local ca = ChartAudio()

	ca:load(chart, true)

	---@type rizu.BassSoundDecoder[]
	local decoders = {}
	for i, sound in ipairs(ca.sounds) do
		local data = self.resource_loader:getResource(sound.name)
		if data then
			decoders[i] = BassSoundDecoder(data)
		end
	end

	self.chart_audio_mixer = ChartAudioMixer(ca.sounds, decoders)
	self.chart_audio_mixer:setPosition(0)

	local source = BassChartAudioSource(self.chart_audio_mixer)
	self.chart_audio_source = source
	source:play()
end

function RhythmEngine:unload()
	self.chart_audio_source:release()
end

function RhythmEngine:update()
	-- self.time_engine:setGlobalTime(0)

	self.time_engine:updateTime()
	self.input_engine:update()
	self.chart_audio_source:update()
end

function RhythmEngine:play()
	self.time_engine:play()
	self.chart_audio_source:play()
	self.input_pauser:play()
end

function RhythmEngine:pause()
	self.time_engine:pause()
	self.chart_audio_source:pause()
	self.input_pauser:pause()
end

return RhythmEngine
