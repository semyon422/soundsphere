local View = require("yi.views.View")
local Label = require("yi.views.Label")
local TimingValuesFactory = require("sea.chart.TimingValuesFactory")

---@class yi.HitGraph : yi.View
---@operator call: yi.HitGraph
local HitGraph = View + {}

HitGraph.TickScale = 0.6
HitGraph.ReverseY = false -- `true` is stepmania/etterna/upscroll behavior

function HitGraph:load()
	self.img = love.graphics.newImage("resources/yi/result_hit.png")
	self.sprite_batch = love.graphics.newSpriteBatch(self.img)

	self:setPaddings({5, 5, 5, 5})

	local res = self:getResources()
	self.early_label = self:add(Label(res:getFont("bold", 16), ""))
	self.late_label = self:add(Label(res:getFont("bold", 16), ""))
	self.late_label:setJustifySelf("end")

	self.err_label = self:add(Label(res:getFont("bold", 24), ""))
	self.err_label:setAlignSelf("center")
	self.err_label:setJustifySelf("center")
	self.err_label:setEnabled(false)
end

local JudgeColors = {
	sphere = {
		{1, 1, 1, 1},
		{1, 0.6, 0.4, 1},
	},
	osuod = {
		{0.6, 0.8, 1, 1},
		{0.95, 0.796, 0.188, 1},
		{0.07, 0.8, 0.56, 1},
		{0.1, 0.39, 1, 1},
		{0.42, 0.48, 0.51, 1},
	},
	etternaj = {
		{0.6, 0.8, 1, 1},
		{0.95, 0.796, 0.188, 1},
		{0.07, 0.8, 0.56, 1},
		{0.1, 0.7, 1, 1},
		{1, 0.1, 0.7, 1},
	},
	quaver = {
		{1, 1, 0.71, 1},
		{1, 0.91, 0.44, 1},
		{0.38, 0.96, 0.47, 1},
		{0.25, 0.7, 0.75, 1},
		{0.72, 0.46, 0.65, 1},
	},
	bmsrank = {
		{0.6, 0.8, 1, 1},
		{0.95, 0.796, 0.188, 1},
		{1, 0.69, 0.24, 1},
		{1, 0.5, 0.24, 1},
	},
}

---@param timings sea.Timings
---@param subtimings sea.Subtimings
---@param judges_source sphere.ScoreSystem + sphere.IJudgesSource
---@param sequence {misc: sphere.MiscScore, base: sphere.BaseScore}[]
function HitGraph:setHits(timings, subtimings, judges_source, sequence)
	local sb = self.sprite_batch
	sb:clear()

	local timing_values, err = TimingValuesFactory():get(timings, subtimings)

	if not timing_values then
		---@cast err -?
		self.err_label:setText(err)
		self.err_label:setEnabled(true)
		return
	end

	self.err_label:setEnabled(false)

	local delta_min = timing_values.ShortNote.hit[1]
	local delta_max = timing_values.ShortNote.hit[2]
	local range = math.abs(delta_min) + delta_max
	local max_time = sequence[#sequence].base.currentTime
	local cw, ch = self:getCalculatedWidth(), self:getCalculatedHeight()

	local w = (cw - self.img:getWidth())
	local h = (ch - self.img:getHeight())
	local s = HitGraph.TickScale
	local reverse = HitGraph.ReverseY

	self.early_label:setText(("Early: %ims"):format(delta_min * 1000))
	self.late_label:setText(("Late: %ims"):format(delta_max * 1000))

	for _, v in ipairs(sequence) do
		local delta = v.misc.deltaTime
		local time = v.base.currentTime
		local judge = judges_source.judge_windows:get(delta)
		local color = JudgeColors[timings.name][judge] or {1, 0, 0, 1}

		local x = (time / max_time) * w
		local y = ((math.abs(delta_min) + delta) / range) * h
		if reverse then
			y = h - y
		end

		if v.base.isEarlyHit or v.base.isMiss then
			sb:setColor(1, 0, 0, 1)
		else
			sb:setColor(color[1], color[2], color[3], color[4])
		end

		sb:add(x, y, 0, s, s)
	end
end

function HitGraph:draw()
	love.graphics.draw(self.sprite_batch)
end

return HitGraph
