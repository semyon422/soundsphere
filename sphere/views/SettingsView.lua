local just = require("just")
local imgui = require("imgui")
local ModalImView = require("sphere.imviews.ModalImView")
local TimingsModalView = require("sphere.views.TimingsModalView")
local _transform = require("gfx_util").transform
local spherefonts = require("sphere.assets.fonts")
local version = require("version")
local audio = require("audio")
local utf8validate = require("utf8validate")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local sections = {
	"gameplay",
	"graphics",
	"audio",
	"input",
	"misc",
}
local section = sections[1]

local scrollY = {}

local w, h = 768, 1080 / 2
local _w, _h = w / 2, 55
local r = 8

local window_id = "settings window"

local drawSection = {}

---@param self table?
---@return boolean?
local function draw(self)
	if not self then
		return true
	end

	imgui.setSize(w, h, _w, _h)

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate((1920 - w) / 2, (1080 - h) / 2)

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)

	just.push()

	section = imgui.tabs("settings tabs", section, sections)

	scrollY[section] = scrollY[section] or 0
	imgui.Container(window_id, w, h - _h, _h / 3, _h * 2, scrollY[section])

	drawSection[section](self)
	just.emptyline(8)

	scrollY[section] = imgui.Container()
	just.pop()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
end

---@param id any
---@param v number
---@param label string
---@return number
local function intButtonsMs(id, v, label)
	return imgui.intButtons(id, v * 1000, 1, label) / 1000
end

function drawSection:gameplay()
	local configs = self.game.configModel.configs
	local settings = configs.settings
	local g = settings.gameplay
	local i = settings.input
	local s = configs.select
	local p = configs.play

	local speedModel = self.game.speedModel

	local speedRange = speedModel.range[g.speedType]
	local speedFormat = speedModel.format[g.speedType]
	local newSpeed = imgui.slider1("speed", speedModel:get(), speedFormat, speedRange[1], speedRange[2], speedRange[3], "play speed")
	speedModel:set(newSpeed)

	g.speedType = imgui.combo("speedType", g.speedType, speedModel.types, nil, "speed type")

	if imgui.TextButton("open timings", "timings", _w / 2, _h) then
		self.game.gameView:setModal(TimingsModalView)
	end
	just.sameline()
	p.timings.nearest = imgui.checkbox("nearest", p.timings.nearest, "nearest input")

	g.actionOnFail = imgui.combo("actionOnFail", g.actionOnFail, {"none", "pause", "quit"}, nil, "action on fail")
	g.scaleSpeed = imgui.checkbox("scaleSpeed", g.scaleSpeed, "scale scroll speed with rate")
	g.longNoteShortening = imgui.slider1(
		"shortening", g.longNoteShortening * 1000, "%dms", -300, 0, 10,
		"visual LN shortening") / 1000
	g.offset.input = intButtonsMs("input offset", g.offset.input, "input offset")
	g.offset.visual = intButtonsMs("visual offset", g.offset.visual, "visual offset")
	g.offsetScale.input = imgui.checkbox("offsetScale.input", g.offsetScale.input, "input offset * time rate")
	g.offsetScale.visual = imgui.checkbox("offsetScale.visual", g.offsetScale.visual, "visual offset * time rate")

	g.tempoFactor = imgui.combo("tempoFactor", g.tempoFactor, {"average", "primary", "minimum", "maximum"}, nil, "tempo factor")
	if g.tempoFactor == "primary" then
		g.primaryTempo = imgui.slider1("primaryTempo", g.primaryTempo, "%d bpm", 60, 240, 1, "primary tempo")
	end

	g.lastMeanValues = imgui.intButtons("lastMeanValues", g.lastMeanValues, 1, "last mean values")
	g.ratingHitTimingWindow = intButtonsMs("ratingHitTimingWindow", g.ratingHitTimingWindow, "rating hit timing window")

	g.autoKeySound = imgui.checkbox("autoKeySound", g.autoKeySound, "auto key sound")
	g.eventBasedRender = imgui.checkbox("eventBasedRender", g.eventBasedRender, "event based render (experimental)")
	g.swapVelocityType = imgui.checkbox("swapVelocityType", g.swapVelocityType, "swap 'current' and 'local' velocity (experimental)")

	imgui.separator()
	s.collapse = imgui.checkbox("s.collapse", s.collapse, "group charts if applicable")

	imgui.separator()
	just.indent(10)
	just.text("gauge/hp")
	g.hp.shift = imgui.checkbox("hp.shift", g.hp.shift, "auto shift")
	g.hp.notes = math.min(math.max(imgui.intButtons("hp.notes", g.hp.notes, 1, "misses to fail with full hp"), 0), 100)

	imgui.separator()
	just.indent(10)
	just.text("background animation")
	g.bga.video = imgui.checkbox("bga.video", g.bga.video, "video")
	g.bga.image = imgui.checkbox("bga.image", g.bga.image, "image")

	imgui.separator()
	i.pause = imgui.hotkey("pause", i.pause, "pause")
	i.skipIntro = imgui.hotkey("skipIntro", i.skipIntro, "skip intro")
	i.quickRestart = imgui.hotkey("quickRestart", i.quickRestart, "quick restart")

	imgui.separator()
	just.indent(10)
	just.text("time to")
	g.time.prepare = imgui.slider1("time.prepare", g.time.prepare, "%0.1f", 0.5, 3, 0.1, "prepare")
	g.time.playPause = imgui.slider1("time.playPause", g.time.playPause, "%0.1f", 0, 2, 0.1, "play-pause")
	g.time.pausePlay = imgui.slider1("time.pausePlay", g.time.pausePlay, "%0.1f", 0, 2, 0.1, "pause-play")
	g.time.playRetry = imgui.slider1("time.playRetry", g.time.playRetry, "%0.1f", 0, 2, 0.1, "play-retry")
	g.time.pauseRetry = imgui.slider1("time.pauseRetry", g.time.pauseRetry, "%0.1f", 0, 2, 0.1, "pause-retry")

	imgui.separator()
	just.indent(10)
	just.text("offset")
	i.offset.decrease = imgui.hotkey("offset.decrease", i.offset.decrease, "decrease")
	i.offset.increase = imgui.hotkey("offset.increase", i.offset.increase, "increase")

	imgui.separator()
	just.indent(10)
	just.text("play speed")
	i.playSpeed.decrease = imgui.hotkey("playSpeed.decrease", i.playSpeed.decrease, "decrease")
	i.playSpeed.increase = imgui.hotkey("playSpeed.increase", i.playSpeed.increase, "increase")

	imgui.separator()
	just.indent(10)
	just.text("time rate")
	i.timeRate.decrease = imgui.hotkey("timeRate.decrease", i.timeRate.decrease, "decrease")
	i.timeRate.increase = imgui.hotkey("timeRate.increase", i.timeRate.increase, "increase")
end

---@param mode table
---@return string
local function formatMode(mode)
	return mode.width .. "x" .. mode.height
end
local vsyncNames = {
	[1] = "enabled",
	[0] = "disabled",
	[-1] = "adaptive",
}

---@param v number?
---@return string
local function formatVsync(v)
	return vsyncNames[v] or ""
end
function drawSection:graphics()
	local settings = self.game.configModel.configs.settings
	local g = settings.graphics

	g.fps = imgui.intButtons("fps", g.fps, 2, "FPS limit")

	local flags = g.mode.flags
	flags.fullscreen = imgui.checkbox("flags.fullscreen", flags.fullscreen, "fullscreen")
	flags.fullscreentype = imgui.combo("flags.fst", flags.fullscreentype, {"desktop", "exclusive"}, nil, "fullscreen type")
	flags.vsync = imgui.combo("flags.vsync", flags.vsync, {1, 0, -1}, formatVsync, "vsync")
	g.vsyncOnSelect = imgui.checkbox("vsyncOnSelect", g.vsyncOnSelect, "vsync on select")
	flags.msaa = imgui.combo("flags.msaa", flags.msaa, {0, 1, 2, 4, 8, 16}, nil, "MSAA")
	g.dwmflush = imgui.checkbox("dwmflush", g.dwmflush, "DWM flush")
	g.asynckey = imgui.checkbox("asynckey", g.asynckey, "threaded input")

	self.modes = self.modes or love.window.getFullscreenModes()
	g.mode.window = imgui.combo("mode.window", g.mode.window, self.modes, formatMode, "start window resolution")

	g.cursor = imgui.combo("g.cursor", g.cursor, {"circle", "arrow", "system"}, nil, "cursor")

	imgui.separator()
	just.indent(10)
	just.text("dim")
	local dim = g.dim
	dim.select = imgui.slider1("dim.select", dim.select, "%0.2f", 0, 1, 0.01, "select")
	dim.gameplay = imgui.slider1("dim.gameplay", dim.gameplay, "%0.2f", 0, 1, 0.01, "gameplay")
	dim.result = imgui.slider1("dim.result", dim.result, "%0.2f", 0, 1, 0.01, "result")

	imgui.separator()
	just.indent(10)
	just.text("blur")
	local blur = g.blur
	blur.select = imgui.slider1("blur.select", blur.select, "%d", 0, 20, 1, "select")
	blur.gameplay = imgui.slider1("blur.gameplay", blur.gameplay, "%d", 0, 20, 1, "gameplay")
	blur.result = imgui.slider1("blur.result", blur.result, "%d", 0, 20, 1, "result")

	imgui.separator()
	just.indent(10)
	just.text("camera")
	local p = g.perspective
	p.camera = imgui.checkbox("p.camera", p.camera, "enable camera")
	p.rx = imgui.checkbox("p.rx", p.rx, "allow rotate x")
	p.ry = imgui.checkbox("p.ry", p.ry, "allow rotate y")

	imgui.separator()
	imgui.text("Renderer")

	local name, version, vendor, device = love.graphics.getRendererInfo()
	imgui.text("name:")
	just.sameline()
	just.offset(120)
	just.text(name)
	imgui.text("version:")
	just.sameline()
	just.offset(120)
	just.text(version)
	imgui.text("vendor:")
	just.sameline()
	just.offset(120)
	just.text(vendor)
	imgui.text("device:")
	just.sameline()
	just.offset(120)
	just.text(device)
end

local _formatModes = {
	bass_sample = "bass sample",
	bass_fx_tempo = "bass fx tempo",
}

---@param mode string
---@return string
local function formatModes(mode)
	return _formatModes[mode] or mode
end

local function deviceToString(d)
	return d.driver or d.name
	-- return ("%s - %s - %s - %s"):format(d.id, d.name, d.driver, d.flags)
end
function drawSection:audio()
	local settings = self.game.configModel.configs.settings
	local a = settings.audio

	a.volumeType = imgui.combo("a.volumeType", a.volumeType, {"linear", "logarithmic"}, nil, "volume type")

	local v = a.volume
	if a.volumeType == "linear" then
		v.master = imgui.slider1("v.master", v.master, "%0.2f", 0, 1, 0.01, "master")
		v.music = imgui.slider1("v.music", v.music, "%0.2f", 0, 1, 0.01, "music")
		v.effects = imgui.slider1("v.effects", v.effects, "%0.2f", 0, 1, 0.01, "effects")
		v.metronome = imgui.slider1("v.metronome", v.metronome, "%0.2f", 0, 1, 0.01, "metronome")
	elseif a.volumeType == "logarithmic" then
		v.master = imgui.lfslider("v.master", v.master, "%ddB", -60, 0, 1, "master")
		v.music = imgui.lfslider("v.music", v.music, "%ddB", -60, 0, 1, "music")
		v.effects = imgui.lfslider("v.effects", v.effects, "%ddB", -60, 0, 1, "effects")
		v.metronome = imgui.lfslider("v.metronome", v.metronome, "%ddB", -60, 0, 1, "metronome")
	end

	a.sampleGain = imgui.slider1("sampleGain", a.sampleGain, "+%0.0fdB", 0, 100, 1, "gain with clipping")

	imgui.separator()

	a.adjustRate = imgui.slider1("a.adjustRate", a.adjustRate, "%0.2f", 0, 1, 0.01, "timer adjust rate")

	local mode = a.mode
	mode.primary = imgui.combo(
		"mode.primary", mode.primary, {"bass_sample", "bass_fx_tempo"}, formatModes, "primary audio mode")
	mode.secondary = imgui.combo(
		"mode.secondary", mode.secondary, {"bass_sample", "bass_fx_tempo"}, formatModes, "secondary audio mode")

	a.midi.constantVolume = imgui.checkbox("midi.constantVolume", a.midi.constantVolume, "midi constant volume")

	imgui.separator()

	local audioInfo = audio.getInfo()
	imgui.text("Latency: " .. audioInfo.latency .. "ms")
	a.device.period = imgui.slider1("d.period", a.device.period, "%dms", 1, 50, 1, "update period")
	a.device.buffer = imgui.slider1("d.buffer", a.device.buffer, "%dms", 1, 50, 1, "buffer length")
	just.sameline()
	imgui.indent()
	imgui.url("dev buffer link", "link", "https://www.un4seen.com/doc/#bass/BASS_CONFIG_DEV_BUFFER.html", true)

	if imgui.button("apply device", "apply") then
		audio.setDevicePeriod(a.device.period)
		audio.setDeviceBuffer(a.device.buffer)
		audio.reinit()
	end
	just.sameline()
	if imgui.button("reset device", "reset") then
		a.device.period = audio.default_dev_period
		a.device.buffer = audio.default_dev_buffer
		audio.setDevicePeriod(a.device.period)
		audio.setDeviceBuffer(a.device.buffer)
		audio.reinit()
	end

	imgui.separator()
	imgui.text("Audio devices:")

	local bass = require("bass")
	local devices = bass.getDevices()
	for _, d in ipairs(devices) do
		local offset = imgui.text(("%s -"):format(d.id), 40, true)
		just.sameline()
		just.indent(10)
		just.text(utf8validate(("%s - %s"):format(d.driver, d.name)))
		just.indent(offset + 10)
		local s = ""
		if d.enabled then s = s .. "enabled " end
		if d.default then s = s .. "default " end
		if d.init then s = s .. "init " end
		imgui.text(s)
	end
end

function drawSection:input()
	local settings = self.game.configModel.configs.settings
	local i = settings.input

	i.selectRandom = imgui.hotkey("selectRandom", i.selectRandom, "select random")
	i.screenshot.capture = imgui.hotkey("screenshot.capture", i.screenshot.capture, "capture screenshot")
	i.screenshot.open = imgui.hotkey("screenshot.open", i.screenshot.open, "open screenshot")
end

function drawSection:misc()
	local settings = self.game.configModel.configs.settings
	local m = settings.miscellaneous

	m.autoUpdate = imgui.checkbox("autoUpdate", m.autoUpdate, "auto update")
	m.muteOnUnfocus = imgui.checkbox("muteOnUnfocus", m.muteOnUnfocus, "mute on unfocus")
	m.showNonManiaCharts = imgui.checkbox("showNonManiaCharts", m.showNonManiaCharts, "show non-mania charts")
	m.showFPS = imgui.checkbox("showFPS", m.showFPS, "show FPS")
	m.showTasks = imgui.checkbox("showTasks", m.showTasks, "show tasks")
	m.showDebugMenu = imgui.checkbox("showDebugMenu", m.showDebugMenu, "show debug menu")
	if imgui.button("error button", "error") then
		error("error")
	end
	if imgui.button("calc top scores", "calc top scores") then
		self.game.scoreModel:asyncCalculateTopScores()
	end

	just.indent(8)
	just.text("Commit: " .. version.commit)
	just.indent(8)
	just.text("Date: " .. version.date)
end

return ModalImView(draw)
