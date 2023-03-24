local just = require("just")
local imgui = require("imgui")
local ModalImView = require("sphere.imviews.ModalImView")
local TimingsModalView = require("sphere.views.TimingsModalView")
local _transform = require("gfx_util").transform
local spherefonts = require("sphere.assets.fonts")
local version = require("version")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local sections = {
	"gameplay",
	"graphics",
	"audio",
	"input",
	"editor",
	"misc",
}
local currentSection = sections[1]

local scrollY = 0

local w, h = 768, 1080 / 2
local _w, _h = w / 2, 55
local r = 8

local window_id = "settings window"

local drawSection = {}

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

	currentSection = imgui.tabs("settings tabs", currentSection, sections)
	imgui.Container(window_id, w, h - _h, _h / 3, _h * 2, scrollY)

	drawSection[currentSection](self)
	just.emptyline(8)

	scrollY = imgui.Container()
	just.pop()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
end

local function intButtonsMs(id, v, label)
	return imgui.intButtons(id, v * 1000, 1, label) / 1000
end

drawSection.gameplay = function(self)
	local settings = self.game.configModel.configs.settings
	local g = settings.gameplay
	local i = settings.input

	g.speed = imgui.slider1("speed", g.speed, "%0.2f", 0, 3, 0.01, "play speed")

	if imgui.TextButton("open timings", "timings", _w / 2, _h) then
		self.game.gameView:setModal(TimingsModalView)
	end
	just.sameline()
	g.timings.nearest = imgui.checkbox("nearest", g.timings.nearest, "nearest input")

	g.actionOnFail = imgui.combo("actionOnFail", g.actionOnFail, {"none", "pause", "quit"}, nil, "action on fail")
	g.scaleSpeed = imgui.checkbox("scaleSpeed", g.scaleSpeed, "scale scroll speed with rate")
	g.longNoteShortening = imgui.slider1(
		"shortening", g.longNoteShortening * 1000, "%dms", -300, 0, 10,
		"visual LN shortening") / 1000
	g.offset.input = intButtonsMs("input offset", g.offset.input, "input offset")
	g.offset.visual = intButtonsMs("visual offset", g.offset.visual, "visual offset")
	g.offsetScale.input = imgui.checkbox("offsetScale.input", g.offsetScale.input, "input offset * time rate")
	g.offsetScale.visual = imgui.checkbox("offsetScale.visual", g.offsetScale.visual, "visual offset * time rate")
	g.lastMeanValues = imgui.intButtons("lastMeanValues", g.lastMeanValues, 1, "last mean values")
	g.ratingHitTimingWindow = intButtonsMs("ratingHitTimingWindow", g.ratingHitTimingWindow, "rating hit timing window")

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
	i.playSpeed.invert = imgui.hotkey("playSpeed.invert", i.playSpeed.invert, "invert ")

	imgui.separator()
	just.indent(10)
	just.text("time rate")
	i.timeRate.decrease = imgui.hotkey("timeRate.decrease", i.timeRate.decrease, "decrease")
	i.timeRate.increase = imgui.hotkey("timeRate.increase", i.timeRate.increase, "increase")
end

local function formatMode(mode)
	return mode.width .. "x" .. mode.height
end
local vsyncNames = {
	[1] = "enabled",
	[0] = "disabled",
	[-1] = "adaptive",
}
local function formatVsync(v)
	return vsyncNames[v] or ""
end
drawSection.graphics = function(self)
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
end

local _formatModes = {
	bass_sample = "bass sample",
	bass_fx_tempo = "bass fx tempo",
}
local function formatModes(mode)
	return _formatModes[mode] or mode
end
drawSection.audio = function(self)
	local settings = self.game.configModel.configs.settings
	local a = settings.audio

	local v = a.volume
	v.master = imgui.slider1("v.master", v.master, "%0.2f", 0, 1, 0.01, "master volume")
	v.music = imgui.slider1("v.music", v.music, "%0.2f", 0, 1, 0.01, "music volume")
	v.effects = imgui.slider1("v.effects", v.effects, "%0.2f", 0, 1, 0.01, "effects volume")

	a.sampleGain = imgui.slider1("sampleGain", a.sampleGain, "+%0.0fdB", 0, 100, 1, "gain with clipping")

	local mode = a.mode
	mode.primary = imgui.combo(
		"mode.primary", mode.primary, {"bass_sample", "bass_fx_tempo"}, formatModes, "primary audio mode")
	mode.secondary = imgui.combo(
		"mode.secondary", mode.secondary, {"bass_sample", "bass_fx_tempo"}, formatModes, "secondary audio mode")

	a.midi.constantVolume = imgui.checkbox("midi.constantVolume", a.midi.constantVolume, "midi constant volume")
end

drawSection.input = function(self)
	local settings = self.game.configModel.configs.settings
	local i = settings.input

	i.selectRandom = imgui.hotkey("selectRandom", i.selectRandom, "select random")
	i.screenshot.capture = imgui.hotkey("screenshot.capture", i.screenshot.capture, "capture screenshot")
	i.screenshot.open = imgui.hotkey("screenshot.open", i.screenshot.open, "open screenshot")
end

drawSection.editor = function(self)
	local settings = self.game.configModel.configs.settings
	local e = settings.editor

	just.indent(10)
	just.text("waveform")
	local wf = e.waveform
	wf.opacity = imgui.slider1("wf.opacity", wf.opacity, "%0.2f", 0, 1, 0.01, "opacity")
	wf.scale = imgui.slider1("wf.scale", wf.scale, "%0.2f", 0, 1, 0.01, "scale")
end

drawSection.misc = function(self)
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

	just.indent(8)
	just.text("Commit: " .. version.commit)
	just.indent(8)
	just.text("Date: " .. version.date)
end

return ModalImView(draw)
