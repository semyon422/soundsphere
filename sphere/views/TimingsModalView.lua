local just = require("just")
local Class = require("aqua.util.Class")
local LabelImView = require("sphere.imviews.LabelImView")
local TextButtonImView = require("sphere.imviews.TextButtonImView")
local TextButtonImView2 = require("sphere.imviews.TextButtonImView2")
local TextInputImView = require("sphere.imviews.TextInputImView")
local SpoilerImView = require("sphere.imviews.SpoilerImView")
local SliderImView = require("sphere.imviews.SliderImView")
local CheckboxImView = require("sphere.imviews.CheckboxImView")
local JudgementBarImView = require("sphere.imviews.JudgementBarImView")
local ModalImView = require("sphere.imviews.ModalImView")
local _transform = require("aqua.graphics.transform")
local round = require("aqua.math").round
local map = require("aqua.math").map
local spherefonts = require("sphere.assets.fonts")
local deepclone = require("aqua.util.deepclone")

local _timings = require("sphere.models.RhythmModel.ScoreEngine.timings")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local function intButtons(id, v, w, h)
	local mod = love.keyboard.isScancodeDown("lshift", "rshift")
	if not mod then
		if TextButtonImView2(id .. "-1", "-1", w / 4, h) then v = v - 1 end
		if TextButtonImView2(id .. "+1", "+1", w / 4, h) then v = v + 1 end
	end
	if TextButtonImView2(id .. "-10", "-10", w / 4, h) then v = v - 10 end
	if TextButtonImView2(id .. "+10", "+10", w / 4, h) then v = v + 10 end
	if mod then
		if TextButtonImView2(id .. "-100", "-100", w / 4, h) then v = v - 100 end
		if TextButtonImView2(id .. "+100", "+100", w / 4, h) then v = v + 100 end
	end
	return math.floor(v)
end

local function intButtonsMs(id, v, w, h)
	return intButtons(id, v * 1000, w, h) / 1000
end

local function drawTimings(t, name, id, norm, mins, w, h)
	local min1, min2 = 0, 0
	if mins then
		min1, min2 = mins[1], mins[2]
	end
	just.row(true)
	t[1] = math.min(math.max(intButtonsMs(id .. 1, t[1], w / 4, h), -1), min1)
	JudgementBarImView(w / 4, h, -t[1] / norm, name, t[1] * 1000, true)
	JudgementBarImView(w / 4, h, t[2] / norm, name, t[2] * 1000)
	t[2] = math.min(math.max(intButtonsMs(id .. 2, t[2], w / 4, h), min2), 1)
	just.row(false)
end

local osuOD = 0

return ModalImView(function(self)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	love.graphics.replaceTransform(_transform(transform))
	local w, h = 1080, 680
	love.graphics.translate((1920 - w) / 2, (1080 - h) / 2)
	local r = 8

	love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)

	just.clip(love.graphics.rectangle, "fill", 0, 0, w, h, r)

	local window_id = "TimingsModalView"
	local over = just.is_over(w, h)
	just.container(window_id, over)
	just.button(window_id, over)
	just.wheel_over(window_id, over)

	local _w, _h = w / 3, 44
	local _h2 = 55
	local quit = false

	local gameplay = self.game.configModel.configs.settings.gameplay

	just.row(true)
	just.indent(10)
	LabelImView("presets label", "Timings presets:", _h2)
	if TextButtonImView2("default timings", "soundsphere", 200, _h2) then
		gameplay.timings = deepclone(_timings.soundsphere)
		self.game:resetGameplayConfigs()
	end
	if TextButtonImView2("lr2 timings", "LR2", 100, _h2) then
		gameplay.timings = deepclone(_timings.lr2)
		self.game:resetGameplayConfigs()
	end
	if TextButtonImView2("osu timings", "osu OD" .. osuOD, 150, _h2) then
		gameplay.timings = deepclone(_timings.osu(osuOD))
		self.game:resetGameplayConfigs()
		osuOD = (osuOD + 1) % 11
	end
	just.row(false)

	local timings = gameplay.timings

	just.indent(10)
	just.text("Current preset: " .. _timings.getName(timings))

	local maxt = 0
	for _, t in pairs(timings) do
		if type(t) == "table" and t.hit then
			maxt = math.max(maxt, -t.hit[1], t.hit[2], -t.miss[1], t.miss[2])
		end
	end

	local norm = 1
	while norm > maxt and norm / 2 > maxt do
		norm = norm / 2
	end
	while norm < maxt and norm * 2 < maxt do
		norm = norm * 2
	end

	just.indent(10)
	just.text("short note")

	drawTimings(timings.ShortNote.hit, "hit", "sn hit", norm, nil, w, _h)
	drawTimings(timings.ShortNote.miss, "miss", "sn miss", norm, timings.ShortNote.hit, w, _h)

	just.emptyline(20)
	just.indent(10)
	just.text("long note start")
	drawTimings(timings.LongNoteStart.hit, "hit", "lns hit", norm, nil, w, _h)
	drawTimings(timings.LongNoteStart.miss, "miss", "lns miss", norm, timings.LongNoteStart.hit, w, _h)

	just.emptyline(20)
	just.indent(10)
	just.text("long note end")
	drawTimings(timings.LongNoteEnd.hit, "hit", "lne hit", norm, nil, w, _h)
	drawTimings(timings.LongNoteEnd.miss, "miss", "lne miss", norm, timings.LongNoteEnd.hit, w, _h)

	just.emptyline(20)
	just.indent(10)
	just.text("hold shift to show +/-100 buttons")

	just.container()
	just.clip()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)

	return quit
end)
