local just = require("just")
local Class = require("aqua.util.Class")
local LabelImView = require("sphere.imviews.LabelImView")
local TextButtonImView = require("sphere.imviews.TextButtonImView")
local TextButtonImView2 = require("sphere.imviews.TextButtonImView2")
local TextInputImView = require("sphere.imviews.TextInputImView")
local SpoilerImView = require("sphere.imviews.SpoilerImView")
local SliderImView = require("sphere.imviews.SliderImView")
local CheckboxImView = require("sphere.imviews.CheckboxImView")
local HotkeyImView = require("sphere.imviews.HotkeyImView")
local ModalImView = require("sphere.imviews.ModalImView")
local TimingsModalView = require("sphere.views.TimingsModalView")
local _transform = require("aqua.graphics.transform")
local round = require("aqua.math").round
local map = require("aqua.math").map
local spherefonts = require("sphere.assets.fonts")
local version = require("version")

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

local w, h = 454 * 1.5, 1080 / 2
local _w, _h = w / 2, 55
local r = 8

local window_id = "settings window"

local drawTabs
local drawSection = {}

local function draw(self)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate(279 + 454 * 3 / 4, 1080 / 4)

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)

	just.clip(love.graphics.rectangle, "fill", 0, 0, w, h, r)

	local over = just.is_over(w, h)
	just.container(window_id, over)
	just.button(window_id, over)

	local scroll = just.wheel_over(window_id, over)
	love.graphics.translate(0, -scrollY)
	local startHeight = just.height

	drawTabs()
	just.emptyline(8)
	drawSection[currentSection](self)
	just.emptyline(8)

	local overlap = math.max(just.height - startHeight - h, 0)
	if overlap > 0 and scroll then
		scrollY = math.min(math.max(scrollY - scroll * _h * 2, 0), overlap)
	end
	if overlap == 0 then
		scrollY = 0
	end

	just.container()
	just.clip()

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
		end
	end
	just.row(false)
	love.graphics.line(0, 0, w, 0)
end

local function separator()
	just.emptyline(8)
	love.graphics.line(0, 0, w, 0)
	just.emptyline(8)
end

local function slider(id, v, a, b, label)
	local _v = map(v, a, b, 0, 1)
	_v = SliderImView(id, _v, _w, _h) or _v
	just.sameline()
	just.indent(8)
	LabelImView(id .. "label", label, _h)
	return map(_v, 0, 1, a, b)
end

local function checkbox(id, v, label)
	if CheckboxImView(id, v, _h, 0.75) then
		v = not v
	end
	just.sameline()
	just.indent(8)
	LabelImView(id, label, _h)
	return v
end

local function combo(id, v, values, format, label)
	local fv = format and format(v) or v
	if SpoilerImView(id, _w, _h, fv) then
		for i, _v in ipairs(values) do
			local dv = format and format(_v) or _v
			if TextButtonImView(id .. i, dv, _w - _h * 0.125, _h * 0.75) then
				v = _v
				just.focus()
			end
		end
		SpoilerImView()
	end
	just.sameline()
	just.indent(8)
	LabelImView(id .. "label", label, _h)
	return v
end

local function intButtons(id, v, s, label)
	just.row(true)
	if TextButtonImView2(id .. "-1", "-1", _w / 4, _h) then v = v - 1 end
	if TextButtonImView2(id .. "+1", "+1", _w / 4, _h) then v = v + 1 end
	if s >= 10 then
		if TextButtonImView2(id .. "-10", "-10", _w / 4, _h) then v = v - 10 end
		if TextButtonImView2(id .. "+10", "+10", _w / 4, _h) then v = v + 10 end
	end
	if s >= 100 then
		if TextButtonImView2(id .. "-100", "-100", _w / 4, _h) then v = v - 100 end
		if TextButtonImView2(id .. "+100", "+100", _w / 4, _h) then v = v + 100 end
	end
	just.indent(8)
	LabelImView(id .. "label", label, _h)
	just.row(false)
	return math.floor(v)
end

local function intButtonsMs(id, v, labelFormat)
	return intButtons(id, v * 1000, 10, labelFormat:format(v * 1000)) / 1000
end

local function hotkey(id, key, label)
	local _
	_, key = HotkeyImView(id, "keyboard", key, _w, _h)
	just.sameline()
	just.indent(8)
	LabelImView(id .. "label", label, _h)
	return key
end

drawSection.gameplay = function(self)
	local settings = self.game.configModel.configs.settings
	local g = settings.gameplay
	local i = settings.input

	g.speed = round(slider("speed", g.speed, 0, 3, ("play speed: %0.2f"):format(g.speed)), 0.05)

	if TextButtonImView2("open timings", "timings", _w / 2, _h) then
		self.game.gameView:setModal(TimingsModalView)
	end
	just.sameline()
	g.timings.nearest = checkbox("nearest", g.timings.nearest, "nearest input")

	g.actionOnFail = combo("actionOnFail", g.actionOnFail, {"none", "pause", "quit"}, nil, "action on fail")
	g.scaleSpeed = checkbox("scaleSpeed", g.scaleSpeed, "scale scroll speed with rate")
	g.longNoteShortening = round(slider(
		"shortening", g.longNoteShortening, -0.3, 0,
		("visual LN shortening: %dms"):format(g.longNoteShortening * 1000)), 0.01)
	g.offset.input = intButtonsMs("input offset", g.offset.input, "input offset: %d")
	g.offset.visual = intButtonsMs("visual offset", g.offset.visual, "visual offset: %d")
	g.offsetScale.input = checkbox("offsetScale.input", g.offsetScale.input, "input offset * time rate")
	g.offsetScale.visual = checkbox("offsetScale.visual", g.offsetScale.visual, "visual offset * time rate")
	g.lastMeanValues = intButtons("lastMeanValues", g.lastMeanValues, 10, ("last mean values: %d"):format(g.lastMeanValues))
	g.ratingHitTimingWindow = intButtonsMs("ratingHitTimingWindow", g.ratingHitTimingWindow, "rating hit timing window: %d")

	-- g.hp.start = intButtons("hp.start", g.hp.start, "hp start: %d")
	-- g.hp.min = intButtons("hp.min", g.hp.min, "hp min: %d")
	-- g.hp.max = intButtons("hp.max", g.hp.max, "hp max: %d")
	-- g.hp.increase = intButtons("hp.increase", g.hp.increase, "hp increase: %d")
	-- g.hp.decrease = intButtons("hp.decrease", g.hp.decrease, "hp decrease: %d")

	g.bga.video = checkbox("bga.video", g.bga.video, "video BGA")
	g.bga.image = checkbox("bga.image", g.bga.image, "image BGA")

	separator()
	i.pause = hotkey("pause", i.pause, "pause")
	i.skipIntro = hotkey("skipIntro", i.skipIntro, "skip intro")
	i.quickRestart = hotkey("quickRestart", i.quickRestart, "quick restart")

	separator()
	just.indent(10)
	just.text("time to")
	g.time.prepare = round(slider("time.prepare", g.time.prepare, 0.5, 3, ("prepare: %0.1f"):format(g.time.prepare)), 0.1)
	g.time.playPause = round(slider("time.playPause", g.time.playPause, 0, 2, ("play-pause: %0.1f"):format(g.time.playPause)), 0.1)
	g.time.pausePlay = round(slider("time.pausePlay", g.time.pausePlay, 0, 2, ("pause-play: %0.1f"):format(g.time.pausePlay)), 0.1)
	g.time.playRetry = round(slider("time.playRetry", g.time.playRetry, 0, 2, ("play-retry: %0.1f"):format(g.time.playRetry)), 0.1)
	g.time.pauseRetry = round(slider("time.pauseRetry", g.time.pauseRetry, 0, 2, ("pause-retry: %0.1f"):format(g.time.pauseRetry)), 0.1)

	separator()
	just.indent(10)
	just.text("offset")
	i.offset.decrease = hotkey("offset.decrease", i.offset.decrease, "decrease")
	i.offset.increase = hotkey("offset.increase", i.offset.increase, "increase")

	separator()
	just.indent(10)
	just.text("play speed")
	i.playSpeed.decrease = hotkey("playSpeed.decrease", i.playSpeed.decrease, "decrease")
	i.playSpeed.increase = hotkey("playSpeed.increase", i.playSpeed.increase, "increase")
	i.playSpeed.invert = hotkey("playSpeed.invert", i.playSpeed.invert, "invert ")

	separator()
	just.indent(10)
	just.text("time rate")
	i.timeRate.decrease = hotkey("timeRate.decrease", i.timeRate.decrease, "decrease")
	i.timeRate.increase = hotkey("timeRate.increase", i.timeRate.increase, "increase")
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

	g.fps = intButtons("fps", g.fps, 100, ("FPS limit: %s"):format(g.fps))

	local flags = g.mode.flags
	flags.fullscreen = checkbox("flags.fullscreen", flags.fullscreen, "fullscreen")
	flags.fullscreentype = combo("flags.fst", flags.fullscreentype, {"desktop", "exclusive"}, nil, "fullscreen type")
	flags.vsync = combo("flags.vsync", flags.vsync, {1, 0, -1}, formatVsync, "vsync")
	g.vsyncOnSelect = checkbox("vsyncOnSelect", g.vsyncOnSelect, "vsync on select")
	g.dwmflush = checkbox("dwmflush", g.dwmflush, "DWM flush")
	g.asynckey = checkbox("asynckey", g.asynckey, "threaded input")

	self.modes = self.modes or love.window.getFullscreenModes()
	g.mode.window = combo("mode.window", g.mode.window, self.modes, formatMode, "start window resolution")

	g.cursor = combo("g.cursor", g.cursor, {"circle", "arrow", "system"}, nil, "cursor")

	local dim = g.dim
	dim.select = round(slider("dim.select", dim.select, 0, 1, ("dim select: %0.2f"):format(dim.select)), 0.01)
	dim.gameplay = round(slider("dim.gameplay", dim.gameplay, 0, 1, ("dim gameplay: %0.2f"):format(dim.gameplay)), 0.01)
	dim.result = round(slider("dim.result", dim.result, 0, 1, ("dim result: %0.2f"):format(dim.result)), 0.01)

	local blur = g.blur
	blur.select = round(slider("blur.select", blur.select, 0, 1, ("blur select: %0.2f"):format(blur.select)), 0.01)
	blur.gameplay = round(slider("blur.gameplay", blur.gameplay, 0, 1, ("blur gameplay: %0.2f"):format(blur.gameplay)), 0.01)
	blur.result = round(slider("blur.result", blur.result, 0, 1, ("blur result: %0.2f"):format(blur.result)), 0.01)

	local p = g.perspective
	p.camera = checkbox("p.camera", p.camera, "enable camera")
	p.rx = checkbox("p.rx", p.rx, "allow rotate x")
	p.ry = checkbox("p.ry", p.ry, "allow rotate y")
end

local _formatModes = {
	sample = "bass sample",
	streamMemoryTempo = "bass fx tempo",
}
local function formatModes(mode)
	return _formatModes[mode] or mode
end
drawSection.audio = function(self)
	local settings = self.game.configModel.configs.settings
	local a = settings.audio

	local v = a.volume
	v.master = round(slider("v.master", v.master, 0, 1, ("master volume: %0.2f"):format(v.master)), 0.01)
	v.music = round(slider("v.music", v.music, 0, 1, ("music volume: %0.2f"):format(v.music)), 0.01)
	v.effects = round(slider("v.effects", v.effects, 0, 1, ("effects volume: %0.2f"):format(v.effects)), 0.01)

	a.sampleGain = round(slider("sampleGain", a.sampleGain, 0, 100, ("gain with clipping: +%0.0fdB"):format(a.sampleGain)), 1)

	local mode = a.mode
	mode.primary = combo(
		"mode.primary", mode.primary, {"sample", "streamMemoryTempo"}, formatModes, "primary audio mode")
	mode.secondary = combo(
		"mode.secondary", mode.secondary, {"sample", "streamMemoryTempo"}, formatModes, "secondary audio mode")

	a.midi.constantVolume = checkbox("midi.constantVolume", a.midi.constantVolume, "midi constant volume")
end

drawSection.input = function(self)
	local settings = self.game.configModel.configs.settings
	local i = settings.input

	i.selectRandom = hotkey("selectRandom", i.selectRandom, "select random")
	i.screenshot.capture = hotkey("screenshot.capture", i.screenshot.capture, "capture screenshot")
	i.screenshot.open = hotkey("screenshot.open", i.screenshot.open, "open screenshot")
end

drawSection.misc = function(self)
	local settings = self.game.configModel.configs.settings
	local m = settings.miscellaneous

	m.autoUpdate = checkbox("autoUpdate", m.autoUpdate, "auto update")
	m.imguiShowDemoWindow = checkbox("imguiShowDemoWindow", m.imguiShowDemoWindow, "show imgui demo window")
	m.showNonManiaCharts = checkbox("showNonManiaCharts", m.showNonManiaCharts, "show non-mania charts")
	m.showFPS = checkbox("showFPS", m.showFPS, "show FPS")

	just.indent(8)
	just.text(version.commit)
	just.indent(8)
	just.text(version.date)
end

return ModalImView(draw)
