local just = require("just")
local TextButtonImView = require("sphere.imviews.TextButtonImView")
local TextButtonImView2 = require("sphere.imviews.TextButtonImView2")
local ContainerImView = require("sphere.imviews.ContainerImView")
local ModalImView = require("sphere.imviews.ModalImView")
local TimingsModalView = require("sphere.views.TimingsModalView")
local _transform = require("aqua.graphics.transform")
local round = require("aqua.math").round
local spherefonts = require("sphere.assets.fonts")
local version = require("version")
local imgui = require("sphere.imgui")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local sections = {
	"gameplay",
	"graphics",
	"audio",
	"input",
	"misc",
}
local currentSection = sections[1]

local scrollY = 0

local w, h = 768, 1080 / 2
local _w, _h = w / 2, 55
local r = 8

local window_id = "settings window"

local drawTabs
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

	drawTabs()
	ContainerImView(window_id, w, h - _h, _h * 2, scrollY)

	just.emptyline(8)
	drawSection[currentSection](self)
	just.emptyline(8)

	scrollY = ContainerImView()
	just.pop()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
end

function drawTabs()
	just.row(true)
	for _, section in ipairs(sections) do
		if section == currentSection then
			love.graphics.setColor(1, 1, 1, 0.1)
			love.graphics.rectangle("fill", 0, 0, w / #sections, _h)
		end
		love.graphics.setColor(1, 1, 1, 1)
		if TextButtonImView("section " .. section, section, w / #sections, _h) then
			currentSection = section
			scrollY = 0
		end
	end
	just.row(false)
	love.graphics.line(0, 0, w, 0)
end

drawSection.gameplay = function(self)
	local settings = self.game.configModel.configs.settings
	local g = settings.gameplay
	local i = settings.input

	g.speed = round(imgui.slider("speed", g.speed, 0, 3, ("%0.2f"):format(g.speed), "play speed"), 0.05)

	if TextButtonImView2("open timings", "timings", _w / 2, _h) then
		self.game.gameView:setModal(TimingsModalView)
	end
	just.sameline()
	g.timings.nearest = imgui.checkbox("nearest", g.timings.nearest, "nearest input")

	g.actionOnFail = imgui.combo("actionOnFail", g.actionOnFail, {"none", "pause", "quit"}, nil, "action on fail")
	g.scaleSpeed = imgui.checkbox("scaleSpeed", g.scaleSpeed, "scale scroll speed with rate")
	g.longNoteShortening = round(imgui.slider(
		"shortening", g.longNoteShortening, -0.3, 0,
		("%dms"):format(g.longNoteShortening * 1000),
		"visual LN shortening"), 0.01)
	g.offset.input = imgui.intButtonsMs("input offset", g.offset.input, "input offset")
	g.offset.visual = imgui.intButtonsMs("visual offset", g.offset.visual, "visual offset")
	g.offsetScale.input = imgui.checkbox("offsetScale.input", g.offsetScale.input, "input offset * time rate")
	g.offsetScale.visual = imgui.checkbox("offsetScale.visual", g.offsetScale.visual, "visual offset * time rate")
	g.lastMeanValues = imgui.intButtons("lastMeanValues", g.lastMeanValues, 1, "last mean values")
	g.ratingHitTimingWindow = imgui.intButtonsMs("ratingHitTimingWindow", g.ratingHitTimingWindow, "rating hit timing window")

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
	g.time.prepare = round(imgui.slider("time.prepare", g.time.prepare, 0.5, 3, ("%0.1f"):format(g.time.prepare), "prepare"), 0.1)
	g.time.playPause = round(imgui.slider("time.playPause", g.time.playPause, 0, 2, ("%0.1f"):format(g.time.playPause), "play-pause"), 0.1)
	g.time.pausePlay = round(imgui.slider("time.pausePlay", g.time.pausePlay, 0, 2, ("%0.1f"):format(g.time.pausePlay), "pause-play"), 0.1)
	g.time.playRetry = round(imgui.slider("time.playRetry", g.time.playRetry, 0, 2, ("%0.1f"):format(g.time.playRetry), "play-retry"), 0.1)
	g.time.pauseRetry = round(imgui.slider("time.pauseRetry", g.time.pauseRetry, 0, 2, ("%0.1f"):format(g.time.pauseRetry), "pause-retry"), 0.1)

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
	dim.select = round(imgui.slider("dim.select", dim.select, 0, 1, ("%0.2f"):format(dim.select), "select"), 0.01)
	dim.gameplay = round(imgui.slider("dim.gameplay", dim.gameplay, 0, 1, ("%0.2f"):format(dim.gameplay), "gameplay"), 0.01)
	dim.result = round(imgui.slider("dim.result", dim.result, 0, 1, ("%0.2f"):format(dim.result), "result"), 0.01)

	imgui.separator()
	just.indent(10)
	just.text("blur")
	local blur = g.blur
	blur.select = round(imgui.slider("blur.select", blur.select, 0, 20, ("%d"):format(blur.select), "select"))
	blur.gameplay = round(imgui.slider("blur.gameplay", blur.gameplay, 0, 20, ("%d"):format(blur.gameplay), "gameplay"), 0.01)
	blur.result = round(imgui.slider("blur.result", blur.result, 0, 20, ("%d"):format(blur.result), "result"))

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
	v.master = round(imgui.slider("v.master", v.master, 0, 1, ("%0.2f"):format(v.master), "master volume"), 0.01)
	v.music = round(imgui.slider("v.music", v.music, 0, 1, ("%0.2f"):format(v.music), "music volume"), 0.01)
	v.effects = round(imgui.slider("v.effects", v.effects, 0, 1, ("%0.2f"):format(v.effects), "effects volume"), 0.01)

	a.sampleGain = round(imgui.slider("sampleGain", a.sampleGain, 0, 100, ("+%0.0fdB"):format(a.sampleGain), "gain with clipping"), 1)

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

drawSection.misc = function(self)
	local settings = self.game.configModel.configs.settings
	local m = settings.miscellaneous

	m.autoUpdate = imgui.checkbox("autoUpdate", m.autoUpdate, "auto update")
	m.imguiShowDemoWindow = imgui.checkbox("imguiShowDemoWindow", m.imguiShowDemoWindow, "show imgui demo window")
	m.showNonManiaCharts = imgui.checkbox("showNonManiaCharts", m.showNonManiaCharts, "show non-mania charts")
	m.showFPS = imgui.checkbox("showFPS", m.showFPS, "show FPS")

	just.indent(8)
	just.text("Commit: " .. version.commit)
	just.indent(8)
	just.text("Date: " .. version.date)
end

return ModalImView(draw)
