local View = require("yi.views.View")
local Label = require("yi.views.Label")
local TimingValuesFactory = require("sea.chart.TimingValuesFactory")

---@class yi.HitGraph : yi.View
---@operator call: yi.HitGraph
local HitGraph = View + {}

HitGraph.TickScale = 0.6
HitGraph.ReverseY = false -- `true` is stepmania/etterna/upscroll behavior

function HitGraph:load()
	local res = self:getResources()
	self.hit = res.quads["result_hit"]
	self.pixel = res.quads["pixel"]
	self.sprite_batch = love.graphics.newSpriteBatch(res.atlas)

	self:setPaddings({5, 5, 5, 5})

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

local HpColor = {0.3, 0.95, 0.45, 0.36}
local HpSamplesTarget = 400

function HitGraph:reset()
	self.sprite_batch:clear()
end

---@param timings sea.Timings
---@param subtimings sea.Subtimings
---@param judges_source sphere.IJudgesSource
---@param sequence {misc: sphere.MiscScore, base: sphere.BaseScore, hp: sphere.HpScore}[]
function HitGraph:addHits(timings, subtimings, judges_source, sequence)
	---@cast judges_source +sphere.ScoreSystem
	local sb = self.sprite_batch
	local hit = self.hit
	local _, _, hit_w, hit_h = hit:getViewport()

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

	local w = (cw - hit_w)
	local h = (ch - hit_h)
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

		sb:add(hit, x, y, 0, s, s)
	end
end

---@param sequence {base: sphere.BaseScore, hp: {healths: number}}[]
---@param max_time number
---@param max_hp number
---@return number[]
local function reduceHpSequence(sequence, max_time, max_hp)
	local count = #sequence
	if count == 0 or max_time <= 0 or max_hp <= 0 then
		return {}
	end

	local points = {} ---@type number[]
	local step = max_time / HpSamplesTarget
	local seq_i = 1
	local current_hp = sequence[1].hp.healths

	for i = 1, HpSamplesTarget do
		local time_to = i * step
		local bucket_hp = current_hp

		while seq_i <= count and sequence[seq_i].base.currentTime <= time_to do
			local hp = sequence[seq_i].hp.healths
			if hp < bucket_hp then
				bucket_hp = hp
			end
			current_hp = hp
			seq_i = seq_i + 1
		end

		if seq_i > 1 and bucket_hp == current_hp then
			bucket_hp = current_hp
		end

		points[i] = math.min(math.max(bucket_hp / max_hp, 0), 1)
	end

	return points
end

---@param sequence {hp: {healths: number}, base: {currentTime: number}}[]
function HitGraph:addHp(sequence, max_hp)
	local sb = self.sprite_batch
	local pixel = self.pixel
	local _, _, pixel_w, pixel_h = pixel:getViewport()
	local cw, ch = self:getCalculatedWidth(), self:getCalculatedHeight()
	local max_time = sequence[#sequence] and sequence[#sequence].base.currentTime or 0

	if max_hp <= 0 or max_time <= 0 then
		return
	end

	local points = reduceHpSequence(sequence, max_time, max_hp)
	local line_w = cw / HpSamplesTarget

	sb:setColor(HpColor[1], HpColor[2], HpColor[3], HpColor[4])

	for i, hp in ipairs(points) do
		local line_h = hp * ch

		if line_h > 0 then
			local x = (i - 1) * line_w
			local y = ch - line_h
			sb:add(pixel, x, y, 0, line_w / pixel_w, line_h / pixel_h)
		end
	end
end

function HitGraph:draw()
	love.graphics.draw(self.sprite_batch)
end

return HitGraph
