local PlayfieldVsrg = require("sphere.models.NoteSkinModel.PlayfieldVsrg")

local BasePlayfield = PlayfieldVsrg:new({construct = false})

BasePlayfield.addBaseElements = function(self)
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

	self:addScore({
		x = 0,
		baseline = 52,
		limit = 1906,
		align = "right",
		font = {
			filename = "Noto Sans Mono",
			size = 48
		},
		transform = self:newTransform(1920, 1080, "right")
	})

	self:addAccuracy({
		x = 0,
		baseline = 94,
		limit = 1905,
		align = "right",
		font = {
			filename = "Noto Sans Mono",
			size = 32
		},
		transform = self:newTransform(1920, 1080, "right")
	})

	self:addCombo({
		x = -540,
		baseline = 476,
		limit = 1080,
		align = "center",
		font = {
			filename = "Noto Sans Mono",
			size = 240
		},
		transform = self:newLaneCenterTransform(1080),
		color = {1, 1, 1, 0.4},
	})
end

return BasePlayfield
