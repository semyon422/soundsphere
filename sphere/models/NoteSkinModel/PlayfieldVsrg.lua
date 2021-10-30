local Class = require("aqua.util.Class")

local PlayfieldVsrg = Class:new()

PlayfieldVsrg.construct = function(self)
	self.noteskin.playField = self
end

PlayfieldVsrg.newTransform = function(self, width, height, align)
	local transform = {0, 0, 0, {0, 1 / height}, {0, 1 / height}, 0, 0, 0, 0}
	if align == "center" then
		transform[1] = {1 / 2, -width / height / 2}
	elseif align == "right" then
		transform[1] = {1, -width / height}
	end
	return transform
end

PlayfieldVsrg.newNoteskinTransform = function(self)
	local height = self.noteskin.unit
	local align = self.noteskin.align
	local transform = {0, 0, 0, {0, 1 / height}, {0, 1 / height}, 0, 0, 0, 0}
	if align == "center" then
		transform[1] = {1 / 2, 0}
	elseif align == "right" then
		transform[1] = {1, 0}
	end
	if self.noteskin.upscroll then
		transform[5][2] = -transform[5][2]
		transform[7] = height
	end
	return transform
end

PlayfieldVsrg.newLaneCenterTransform = function(self, height)
	local noteskin = self.noteskin
	local align = noteskin.align
	local offset = noteskin.columnsOffset or 0
	local unit = noteskin.unit or 1
	local transform = {0, 0, 0, {0, 1 / height}, {0, 1 / height}, 0, 0, 0, 0}
	if align == "center" then
		transform[1] = {1 / 2, offset / unit}
	elseif align == "right" then
		transform[1] = {1, -noteskin.fullWidth / unit / 2 + offset / unit}
	elseif align == "left" then
		transform[1] = {0, noteskin.fullWidth / unit / 2 + offset / unit}
	end
	return transform
end

PlayfieldVsrg.newFullTransform = function(self, width, height)
	return {0, 0, 0, {1 / width, 0}, {0, 1 / height}, 0, 0, 0, 0}
end

PlayfieldVsrg.add = function(self, ...)
	table.insert(self, ...)
end

PlayfieldVsrg.enableCamera = function(self)
	self:add({
		class = "CameraView",
		draw_start = true,
	})
end

PlayfieldVsrg.disableCamera = function(self)
	self:add({
		class = "CameraView",
		draw_end = true,
	})
end

PlayfieldVsrg.addRhythmView = function(self, object)
	object.class = "RhythmView"
	if not object.transform then
		object.transform = self:newNoteskinTransform()
	end
	self:add(object)
end

PlayfieldVsrg.addNotes = function(self, object)
	self:addRhythmView(object or {})
end

PlayfieldVsrg.addLightings = function(self, object)
	object = object or {}
	object.mode = "lighting"
	self:addRhythmView(object)
end

PlayfieldVsrg.addBga = function(self, object)
	object = object or {}
	object.mode = "bga"
	self:addRhythmView(object)
end

PlayfieldVsrg.addProgressBar = function(self, object)
	object = object or {}
	object.class = "ProgressView"
	object.min = {key = "gameController.rhythmModel.timeEngine.minTime"}
	object.max = {key = "gameController.rhythmModel.timeEngine.maxTime"}
	object.start = {key = "gameController.rhythmModel.timeEngine.startTime"}
	object.current = {key = "gameController.rhythmModel.timeEngine.currentTime"}
	self:add(object)
end

PlayfieldVsrg.addHpBar = function(self, object)
	object = object or {}
	object.class = "ProgressView"
	object.min = {value = 0}
	object.max = {value = 1}
	object.start = {value = 0}
	object.current = {key = "gameController.rhythmModel.scoreEngine.scoreSystem.hp.hp"}
	self:add(object)
end

PlayfieldVsrg.addValueView = function(self, object)
	object = object or {}
	object.class = "ValueView"
	self:add(object)
end

PlayfieldVsrg.addScore = function(self, object)
	object = object or {}
	object.class = object.class or "ValueView"
	object.key = "gameController.rhythmModel.scoreEngine.scoreSystem.normalscore.score"
	object.format = "%0.2f"
	object.multiplier = 1000
	object.color = object.color or {1, 1, 1, 1}
	self:add(object)
end

PlayfieldVsrg.addAccuracy = function(self, object)
	object = object or {}
	object.class = object.class or "ValueView"
	object.key = "gameController.rhythmModel.scoreEngine.scoreSystem.normalscore.accuracy"
	object.format = "%0.2f"
	object.multiplier = 1000
	object.color = object.color or {1, 1, 1, 1}
	self:add(object)
end

PlayfieldVsrg.addCombo = function(self, object)
	object = object or {}
	object.class = object.class or "ValueView"
	object.key = "gameController.rhythmModel.scoreEngine.scoreSystem.base.combo"
	object.format = "%d"
	object.color = object.color or {1, 1, 1, 1}
	self:add(object)
end

PlayfieldVsrg.addJudgement = function(self, object)
	local judgements = {}
	if not object.transform then
		object.transform = self:newLaneCenterTransform(1080)
	end
	for _, judgement in ipairs(object.judgements) do
		local config = {
			class = "ImageAnimationView",
			x = object.x, y = object.y,
			w = object.w, h = object.h,
			sx = object.sx or object.scale, sy = object.sy or object.scale,
			ox = object.ox, oy = object.oy,
			transform = object.transform,
			image = judgement[2],
			range = judgement[3],
			quad = judgement[4],
			rate = judgement.rate or object.rate,
		}
		judgements[judgement[1]] = config
		self:add(config)
	end
	local key = "gameController.rhythmModel.scoreEngine.scoreSystem.judgement.counters"
	if object.key then
		key = key .. "." .. object.key
	end
	self:add({
		class = "JudgementView",
		key = key,
		judgements = judgements
	})
end

PlayfieldVsrg.addDeltaTimeJudgement = function(self, object)
	local judgements = {}
	if not object.transform then
		object.transform = self:newLaneCenterTransform(1080)
	end
	for i, judgement in ipairs(object.judgements) do
		if type(judgement) == "string" then
			judgement = {judgement}
		end
		if type(judgement) == "table" then
			local config = {
				class = "ImageAnimationView",
				x = object.x, y = object.y,
				w = object.w, h = object.h,
				sx = object.sx or object.scale, sy = object.sy or object.scale,
				ox = object.ox, oy = object.oy,
				transform = object.transform,
				image = judgement[1],
				range = judgement[2],
				quad = judgement[3],
				rate = judgement.rate or object.rate,
			}
			judgements[i] = config
			self:add(config)
		else
			judgements[i] = judgement
		end
	end
	self:add({
		class = "DeltaTimeJudgementView",
		key = "gameController.rhythmModel.scoreEngine.scoreSystem.misc",
		judgements = judgements
	})
end

PlayfieldVsrg.addKeyImages = function(self, object)
	local noteskin = self.noteskin
	if not object.transform then
		object.transform = self:newNoteskinTransform()
	end
	for i = 1, #object.pressed do
		local pressed
		local released
		if object.pressed[i] then
			pressed = {
				class = "ImageView",
				x = noteskin.columns[i],
				y = noteskin.unit - object.padding,
				w = noteskin.width[i],
				h = object.h,
				sy = object.sy,
				oy = 1,
				transform = object.transform,
				image = object.pressed[i],
			}
		end
		if object.released[i] then
			released = {
				class = "ImageView",
				x = noteskin.columns[i],
				y = noteskin.unit - object.padding,
				w = noteskin.width[i],
				h = object.h,
				sy = object.sy,
				oy = 1,
				transform = object.transform,
				image = object.released[i],
			}
		end
		local inputType, inputIndex = noteskin.inputs[i]:match("^(.-)(%d+)$")
		local key = {
			class = "InputView",
			inputType = inputType, inputIndex = tonumber(inputIndex),
			pressed = pressed,
			released = released,
		}
		self:add(pressed)
		self:add(released)
		self:add(key)
	end
end

PlayfieldVsrg.addKeyImageAnimations = function(self, object)
	local noteskin = self.noteskin
	if not object.transform then
		object.transform = self:newNoteskinTransform()
	end
	for i = 1, #object.pressed do
		local pressed = {
			class = "ImageAnimationView",
			x = noteskin.columns[i],
			y = noteskin.unit - object.h - object.padding,
			w = noteskin.width[i],
			h = object.h,
			transform = object.transform,
			image = object.pressed[i][1],
			range = object.pressed[i][2],
			quad = object.pressed[i][3],
			rate = object.rate,
		}
		local hold = {
			class = "ImageAnimationView",
			x = noteskin.columns[i],
			y = noteskin.unit - object.h - object.padding,
			w = noteskin.width[i],
			h = object.h,
			transform = object.transform,
			image = object.hold[i][1],
			range = object.hold[i][2],
			quad = object.hold[i][3],
			rate = object.rate,
		}
		local released = {
			class = "ImageAnimationView",
			x = noteskin.columns[i],
			y = noteskin.unit - object.h - object.padding,
			w = noteskin.width[i],
			h = object.h,
			transform = object.transform,
			image = object.released[i][1],
			range = object.released[i][2],
			quad = object.released[i][3],
			rate = object.rate,
		}
		local inputType, inputIndex = noteskin.inputs[i]:match("^(.-)(%d+)$")
		local key = {
			class = "InputAnimationView",
			inputType = inputType, inputIndex = tonumber(inputIndex),
			pressed = pressed,
			hold = hold,
			released = released,
		}
		self:add(pressed)
		self:add(hold)
		self:add(released)
		self:add(key)
	end
end

PlayfieldVsrg.addColumnsBackground = function(self, object)
	if not object then
		return
	end
	if not object.transform then
		object.transform = self:newNoteskinTransform()
	end
	local noteskin = self.noteskin
	local inputs = noteskin.inputsCount
	local rectangles = {}
	for i = 1, inputs do
		local color = object.color[i]
		if type(object.color[1]) == "number" then
			color = object.color
		end
		table.insert(rectangles, {
			color = color,
			mode = "fill",
			lineStyle = "rough",
			lineWidth = 1,
			x = noteskin.columns[i],
			y = 0,
			w = noteskin.width[i],
			h = 480,
			rx = 0,
			ry = 0
		})
	end
	self:add({
		class = "RectangleView",
		transform = object.transform,
		rectangles = rectangles
	})
end

PlayfieldVsrg.addGuidelines = function(self, object)
	if not object then
		return
	end
	if not object.transform then
		object.transform = self:newNoteskinTransform()
	end
	local noteskin = self.noteskin
	local inputs = noteskin.inputsCount
	for i = 1, inputs + 1 do
		local bw = object.w[i]
		local bh = object.h[i]
		local by = object.y[i]
		local bi = object.image[i]

		if bw and bh and by and bi and bw ~= 0 and bh ~= 0 then
			local x
			if bw > 0 then
				if i <= inputs then
					x = noteskin.columns[i] - noteskin.space[i]
				else
					x = noteskin.columns[inputs] + noteskin.width[inputs]
				end
			elseif bw < 0 then
				if i <= inputs then
					x = noteskin.columns[i]
				else
					x = noteskin.columns[inputs] + noteskin.width[inputs] + noteskin.space[i]
				end
			end

			local view = {
				class = "ImageView",
				x = x,
				y = by,
				w = bw,
				h = bh,
				transform = object.transform,
				image = bi,
			}
			self:add(view)
		end
	end
end

local perfectColor = {1, 1, 1, 1}
local notPerfectColor = {1, 0.6, 0.4, 1}
local missColor = {1, 0.2, 0.2, 1}
PlayfieldVsrg.addHitError = function(self, object)
	if not object then
		return
	end
	object.class = "HitErrorView"
	object.transform = object.transform or playfield:newLaneCenterTransform(1080)
	object.count = object.count or 1
	object.key = "gameController.rhythmModel.scoreEngine.scoreSystem.sequence"
	object.value = "misc.deltaTime"
	object.unit = 0.16
	object.color = object.color or function(value, unit)
		if math.abs(value) <= 0.016 then
			return perfectColor
		elseif math.abs(value) > 0.12 then
			return missColor
		end
		return notPerfectColor
	end

	self:add(object)
end

return PlayfieldVsrg
