local PlayfieldVsrg = require("sphere.models.NoteSkinModel.PlayfieldVsrg")

---@class sphere.BasePlayfield: sphere.PlayfieldVsrg
---@operator call: sphere.BasePlayfield
local BasePlayfield = PlayfieldVsrg + {}

function BasePlayfield:addBaseProgressBar()
	self:addProgressBar({
		x = 0,
		y = 1070,
		w = 1920,
		h = 10,
		color = {1, 1, 1, 1},
		transform = self:newFullTransform(1920, 1080),
		direction = "left-right",
		mode = "+"
	})
end

function BasePlayfield:addBaseHpBar()
	self:addHpBar({
		x = 0,
		y = 0,
		w = 10,
		h = 1080,
		transform = self:newFullTransform(1920, 1080),
		color = {1, 1, 1, 1},
		direction = "down-up",
		mode = "+"
	})
end

function BasePlayfield:addBaseScore()
	self:addScore({
		x = 0,
		baseline = 52,
		limit = 1906,
		align = "right",
		font = {"Noto Sans Mono", 48},
		transform = self:newTransform(1920, 1080, "right")
	})
end

function BasePlayfield:addBaseAccuracy()
	self:addAccuracy({
		x = 0,
		baseline = 94,
		limit = 1905,
		align = "right",
		font = {"Noto Sans Mono", 32},
		transform = self:newTransform(1920, 1080, "right")
	})
end

function BasePlayfield:addBaseCombo()
	self:addCombo({
		x = -540,
		baseline = 476,
		limit = 1080,
		align = "center",
		font = {"Noto Sans Mono", 240},
		transform = self:newLaneCenterTransform(1080),
		color = {1, 1, 1, 0.4},
	})
end

function BasePlayfield:addBaseHitError()
	self:addHitError({
		transform = self:newLaneCenterTransform(1080),
		x = 0,
		y = 1041,
		w = 432,
		h = 24,
		origin = {
			w = 2,
			h = 34,
			color = {1, 1, 1, 1}
		},
		background = {
			color = {0.25, 0.25, 0.25, 0.5}
		},
		radius = 3,
		count = 20,
	})
end

function BasePlayfield:addBaseMatchPlayers()
	self:addMatchPlayers()
end

---@param elements table?
function BasePlayfield:addBaseElements(elements)
	if not elements then
		self:addBaseProgressBar()
		self:addBaseHpBar()
		self:addBaseScore()
		self:addBaseAccuracy()
		self:addBaseCombo()
		self:addBaseHitError()
		self:addBaseMatchPlayers()
		return
	end
	for i, element in ipairs(elements) do
		if element == "progress" then
			self:addBaseProgressBar()
		elseif element == "hp" then
			self:addBaseHpBar()
		elseif element == "score" then
			self:addBaseScore()
		elseif element == "accuracy" then
			self:addBaseAccuracy()
		elseif element == "combo" then
			self:addBaseCombo()
		elseif element == "hit error" then
			self:addBaseHitError()
		elseif element == "match players" then
			self:addBaseMatchPlayers()
		end
	end
end

return BasePlayfield
