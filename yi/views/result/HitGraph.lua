local View = require("yi.views.View")
local Label = require("yi.views.Label")
local HitGraphTooltip = require("yi.views.result.HitGraphTooltip")
local TimingValuesFactory = require("sea.chart.TimingValuesFactory")

local math_util = require("math_util")

---@class yi.HitGraph : yi.View
---@operator call: yi.HitGraph
local HitGraph = View + {}

---@class yi.HitGraph.BaseSlice
---@field currentTime number
---@field isMiss boolean 
---@field isEarlyHit boolean

---@class yi.HitGraph.MiscSlice
---@field deltaTime number

---@class yi.HitGraph.HpSlice
---@field healths number

---@class yi.HitGraph.Normalscore
---@field mean number
---@field accuracyAdjusted number

---@class yi.HitGraph.Slice 
---@field base yi.HitGraph.BaseSlice
---@field misc yi.HitGraph.MiscSlice
---@field hp yi.HitGraph.HpSlice
---@field normalscore yi.HitGraph.Normalscore

HitGraph.TickScale = 0.6
HitGraph.ReverseY = false -- `true` is stepmania/etterna/upscroll behavior

function HitGraph:load()
	local res = self:getResources()
	self.hit = res.quads["result_hit"]
	self.pixel = res.quads["pixel"]
	self.sprite_batch = love.graphics.newSpriteBatch(res.atlas)

	self.early_label = self:add(Label(res:getFont("bold", 16), ""))
	self.late_label = self:add(Label(res:getFont("bold", 16), ""))
	self.early_label:setMargins({5, 5, 5, 5})
	self.late_label:setJustifySelf("end")
	self.late_label:setMargins({5, 5, 5, 5})

	self.err_label = self:add(Label(res:getFont("bold", 24), ""))
	self.err_label:setAlignSelf("center")
	self.err_label:setJustifySelf("center")
	self.err_label:setEnabled(false)

	self.tooltip = self:add(HitGraphTooltip())
	self.hover_line = self:add(View())
	self.hover_line:setBackgroundColor({1, 1, 1, 1})
	self.hover_line:setWidth(2)
	self.hover_line:setHeight("100%")
	self.hover_line:setEnabled(false)

	self.handles_mouse_input = true
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

---@param sequence yi.HitGraph.Slice[]
function HitGraph:setSequence(sequence)
	assert(#sequence > 0)
	self.sequence = sequence
	self.max_time = sequence[#sequence].base.currentTime
end

---@param timings sea.Timings
---@param subtimings sea.Subtimings
---@param judges_source sphere.IJudgesSource
function HitGraph:addHits(timings, subtimings, judges_source)
	---@cast judges_source +sphere.ScoreSystem
	local sb = self.sprite_batch
	local sequence = self.sequence
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
		if v.base.isEarlyHit or v.base.isMiss then
			goto continue
		end

		local delta = v.misc.deltaTime
		local time = v.base.currentTime
		local judge = judges_source.judge_windows:get(delta)
		local color = JudgeColors[timings.name][judge] or {1, 0, 0, 1}

		local x = (time / max_time) * w
		local y = ((math.abs(delta_min) + delta) / range) * h
		if reverse then
			y = h - y
		end

		sb:setColor(color[1], color[2], color[3], color[4])
		sb:add(hit, x, y, 0, s, s)

		::continue::
	end
end

function HitGraph:addMisses()
	local sb = self.sprite_batch
	local sequence = self.sequence
	local pixel = self.pixel
	local _, _, pixel_w, pixel_h = pixel:getViewport()
	local cw, ch = self:getCalculatedWidth(), self:getCalculatedHeight()
	local max_time = sequence[#sequence].base.currentTime or 0

	if max_time <= 0 then
		return
	end

	for _, v in ipairs(sequence) do
		if not v.base.isEarlyHit and not v.base.isMiss then
			goto continue
		end

		local x = (v.base.currentTime / max_time) * cw

		if v.base.isEarlyHit then
			sb:setColor(1, 0.5, 0, 1)
		else
			sb:setColor(1, 0, 0, 1)
		end

		sb:add(pixel, x, 0, 0, 1 / pixel_w, ch / pixel_h)

		::continue::
	end
end

---@param sequence yi.HitGraph.Slice[]
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

function HitGraph:addHp(max_hp)
	local sb = self.sprite_batch
	local sequence = self.sequence
	local pixel = self.pixel
	local _, _, pixel_w, pixel_h = pixel:getViewport()
	local cw, ch = self:getCalculatedWidth(), self:getCalculatedHeight()
	local max_time = sequence[#sequence].base.currentTime or 0

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

function HitGraph:onHover(_)
	self.tooltip:setEnabled(true)
	self.hover_line:setEnabled(true)
end

function HitGraph:onHoverLost(_)
	self.tooltip:setEnabled(false)
	self.hover_line:setEnabled(false)
end

---@param sequence yi.HitGraph.Slice[]
---@param time number
---@return integer
local function findSequenceIndexByTime(sequence, time)
	local low = 1
	local high = #sequence

	while low < high do
		local mid = math.floor((low + high) / 2)
		if sequence[mid].base.currentTime < time then
			low = mid + 1
		else
			high = mid
		end
	end

	if low > 1 then
		local prev = sequence[low - 1]
		local curr = sequence[low]
		if math.abs(prev.base.currentTime - time) <= math.abs(curr.base.currentTime - time) then
			return low - 1
		end
	end

	return low
end

function HitGraph:update(_)
	if self.mouse_over then
		local imx = self.transform:inverseTransformPoint(love.mouse.getPosition())
		local cw = self:getCalculatedWidth()
		if cw <= 0 then
			return
		end

		local xn = math_util.clamp(imx / cw, 0, 1)
		local time = xn * self.max_time
		local index = findSequenceIndexByTime(self.sequence, time)
		local slice = self.sequence[index]
		local text = ("NS: %0.02f\nMean: %0.02f"):format(
			slice.normalscore.accuracyAdjusted * 1000,
			slice.normalscore.mean * 1000
		)
		self.tooltip:setText(text)
		self.hover_line:setX(imx)
	end
end

function HitGraph:draw()
	love.graphics.draw(self.sprite_batch)
end

return HitGraph
