local class = require("class")
local flux = require("flux")

---@class sphere.JudgementView
---@operator call: sphere.JudgementView
---@field game sphere.GameController
---@field animate boolean?
---@field scale number
---@field judgements sphere.ImageAnimationView
---@field counterIndex {[string]: number}
local JudgementView = class()

function JudgementView:load()
	local score_engine = self.game.rhythmModel.scoreEngine
	if not score_engine.loaded then
		return
	end

	self.judge = score_engine:getJudge()
	self.notes = 0

	self.counterIndex = {}

	local counters = self.judge.orderedCounters
	for i, v in ipairs(counters) do
		self.counterIndex[v] = i
	end

	self.counterIndex.miss = #self.judgements
	self.scale = self.scale or 1
	self.animationScale = 1
	self.rotation = 0
	self.alpha = 1
end

function JudgementView:startAnimation()
	local counter = self.judge.lastCounter

	if self.alphaTween then
		self.alphaTween:stop()
	end
	if self.scaleTween then
		self.scaleTween:stop()
	end
	if self.rotationTween then
		self.rotationTween:stop()
	end

	self.alpha = 1
	self.alphaTween = flux.to(self, 0.04, { alpha = 0 }):delay(0.18):ease("quadout")

	self.rotation = 0

	if counter == "miss" then
		self.animationScale = 1.2
		self.scaleTween = flux.to(self, 0.1, { animationScale = 1 }):ease("quadout")
		self.rotationTween = flux.to(self, 0.1, { rotation = (0.2 - math.random(1, 3) * 0.1) }):ease("quadout")
	else
		self.animationScale = 0.95
		self.scaleTween = flux.to(self, 0.04, { animationScale = 1 })
			:after(self, 0.04, { animationScale = 0.92 })
			:after(self, 0.1, {})
			:after(self, 0.04, { animationScale = 0.85 }):ease("quadin")
	end
end

---@param dt number
function JudgementView:update(dt)
	local judge = self.judge
	local counter_index = self.counterIndex[judge.lastCounter]

	local image = self.judgements[counter_index] or self.judgements[1]
	if not image then
		return
	end

	image.color[4] = self.alpha
	image.sx = self.scale * self.animationScale
	image.sy = self.scale * self.animationScale
	image.rotation = self.rotation

	local notes = judge.notes
	if notes == self.notes then
		return
	end
	self.notes = notes

	for _, view in ipairs(self.judgements) do
		view:setTime(math.huge)
	end
	image:setTime(0)

	if self.animate then
		self:startAnimation()
	end
end

return JudgementView
