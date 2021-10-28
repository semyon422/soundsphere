local NoteSkin = require("sphere.models.NoteSkinModel.NoteSkin")

local NoteSkinVsrg = NoteSkin:new()

NoteSkinVsrg.setColumns = function(self, columns)
	local inputsCount = self.inputsCount

	assert(#columns.width == inputsCount, "Table columns.width should contain " .. inputsCount .. " values")
	assert(#columns.space == inputsCount + 1, "Table columns.space should contain " .. inputsCount + 1 .. " values")

	self.offset = columns.offset
	self.align = columns.align
	self.width = columns.width
	self.space = columns.space
	self.upscroll = columns.upscroll

	local fullWidth = 0
	for j = 1, #columns.width do
		fullWidth = fullWidth + columns.width[j]
	end
	for j = 1, #columns.space do
		fullWidth = fullWidth + columns.space[j]
	end
	self.fullWidth = fullWidth

	local offset
	if columns.align == "left" then
		offset = columns.offset
	elseif columns.align == "right" then
		offset = columns.offset - fullWidth
	else
		offset = columns.offset - fullWidth / 2
	end
	self.baseOffset = offset

	local x = {}
	for i = 1, #columns.width do
		offset = offset + columns.space[i]
		x[i] = offset
		offset = offset + columns.width[i]
	end
	self.columns = x
end

NoteSkinVsrg.setInput = function(self, columns)
	for i, input in ipairs(columns) do
		columns[input] = i
	end
	self.inputs = columns
	self.inputsCount = #columns
end

local colors = {
	transparent = {1, 1, 1, 0},
	clear = {1, 1, 1, 1},
	missed = {0.5, 0.5, 0.5, 1},
	passed = {1, 1, 1, 0},
	startMissed = {0.5, 0.5, 0.5, 1},
	startMissedPressed = {0.75, 0.75, 0.75, 1},
	startPassedPressed = {1, 1, 1, 1},
	endPassed = {1, 1, 1, 0},
	endMissed = {0.5, 0.5, 0.5, 1},
	endMissedPassed = {0.5, 0.5, 0.5, 1}
}
NoteSkinVsrg.colors = colors

NoteSkinVsrg.color = function(timeState, noteView)
	local logicalState = noteView.logicalState
	if logicalState == "clear" or logicalState == "skipped" then
		return colors.clear
	elseif logicalState == "missed" then
		return colors.missed
	elseif logicalState == "passed" then
		return colors.passed
	end

	local startTimeState = timeState.startTimeState or timeState
	local endTimeState = timeState.endTimeState or timeState
	local sdt = timeState.scaledFakeVisualDeltaTime or timeState.scaledVisualDeltaTime

	if startTimeState.fakeCurrentVisualTime >= endTimeState.absoluteTime then
		return colors.transparent
	elseif logicalState == "clear" then
		return colors.clear
	elseif colors[logicalState] then
		return colors[logicalState]
	end

	return colors.clear
end

local function getFrame(a, deltaTime)
	if not a.range then
		return
	end
	return math.floor(deltaTime * a.rate) % a.frames * (a.range[2] - a.range[1]) / (a.frames - 1) + a.range[1]
end

NoteSkinVsrg.getPosition = function(self, timeState)
	return self.hitposition + self.unit * (timeState.scaledFakeVisualDeltaTime or timeState.scaledVisualDeltaTime)
end

NoteSkinVsrg.setShortNote = function(self, params)
	local h = params.h or 0
	local height = {}
	for i = 1, self.inputsCount do
		height[i] = h
	end

	local image = params.image
	if type(params.image) == "string" then
		image = {}
		for i = 1, self.inputsCount do
			image[i] = params.image
		end
	end

	local color = {}
	for i = 1, self.inputsCount do
		color[i] = self.color
	end

	local oy = {}
	for i = 1, self.inputsCount do
		oy[i] = 1
	end

	self.notes.ShortNote = {Head = {
		x = self.columns,
		y = function(...) return self:getPosition(...) end,
		w = self.width,
		h = height,
		sx = {},
		sy = {},
		ox = {},
		oy = oy,
		r = {},
		color = color,
		image = image
	}}
end

NoteSkinVsrg.setLongNote = function(self, params)
	local h = params.h or 0
	local headHeight = {}
	local tailHeight = {}
	for i = 1, self.inputsCount do
		headHeight[i] = h
		tailHeight[i] = h
	end

	local tail = params.tail
	if type(params.tail) == "string" then
		tail = {}
		for i = 1, self.inputsCount do
			tail[i] = params.tail
		end
	end
	local body = params.body
	if type(params.body) == "string" then
		body = {}
		for i = 1, self.inputsCount do
			body[i] = params.body
		end
	end
	local head = params.head
	if type(params.head) == "string" then
		head = {}
		for i = 1, self.inputsCount do
			head[i] = params.head
		end
	end

	local color = {}
	for i = 1, self.inputsCount do
		color[i] = self.color
	end

	local headOy = {}
	local tailOy = {}
	for i = 1, self.inputsCount do
		headOy[i] = 1
		tailOy[i] = 1
	end
	local bh = {}
	for i = 1, self.inputsCount do
		bh[i] = 0
	end

	local Head = {
		x = self.columns,
		y = function(...) return self:getPosition(...) end,
		w = self.width,
		h = headHeight,
		sx = {},
		sy = {},
		ox = {},
		oy = headOy,
		r = {},
		color = color,
		image = head
	}

	local Tail = {
		x = self.columns,
		y = function(...) return self:getPosition(...) end,
		w = self.width,
		h = tailHeight,
		sx = {},
		sy = {},
		ox = {},
		oy = tailOy,
		r = {},
		color = color,
		image = tail
	}

	local Body = {
		x = self.columns,
		y = function(...) return self:getPosition(...) - h / 2 end,
		w = self.width,
		h = bh,
		sx = {},
		sy = {},
		ox = {},
		oy = {},
		color = color,
		image = body
	}

	self.notes.LongNote = {
		Head = Head,
		Tail = Tail,
		Body = Body,
	}
end

local bmsLayers = {
	0x04,
	-- 0x06,
	0x07,
	0x0A,
	-- 0x0B,
	-- 0x0C,
	-- 0x0D,
	-- 0x0E,
}
NoteSkinVsrg.addBga = function(self, params)
	local imageHead = {
		x = {},
		y = {},
		w = {},
		h = {},
		color = {}
	}
	local videoHead = {
		x = {},
		y = {},
		w = {},
		h = {},
		color = {}
	}
	self.notes.ImageNote = {Head = imageHead}
	self.notes.VideoNote = {Head = videoHead}

	for _, head in ipairs({imageHead, videoHead}) do
		for _, inputIndex in ipairs(bmsLayers) do
			self:addImageNote(head, "bmsbga" .. inputIndex, params)
		end
	end
end

NoteSkinVsrg.addImageNote = function(self, head, input, params)
	local i = self.inputs[input]
	if not i then
		i = #self.inputs + 1
		self.inputs[i] = input
		self.inputs[input] = i
	end

	head.x[i] = params.x or 0
	head.y[i] = params.y or 0
	head.w[i] = params.w or 1
	head.h[i] = params.h or 1
	head.color[i] = params.color or colors.clear
end

NoteSkinVsrg.addMeasureLine = function(self, params)
	local Head = self.notes.LongNote.Head

	local input = "measure1"
	local i = self.inputs[input]
	if not i then
		i = #self.inputs + 1
		self.inputs[i] = input
		self.inputs[input] = i
	end

	Head.x[i] = self.baseOffset
	Head.w[i] = self.fullWidth
	Head.h[i] = params.h
	Head.ox[i] = 0
	Head.oy[i] = 1
	Head.r[i] = 0
	Head.color[i] = params.color
	Head.image[i] = params.image
end

NoteSkinVsrg.setLighting = function(self, params)
	if params.range then
		params.frames = math.abs(params.range[2] - params.range[1]) + 1
	else
		params.frames = 1
	end
	local note = {Head = {
		x = function(_, _, column) return self.columns[column] + self.width[column] / 2 end,
		y = self.hitposition + params.offset,
		sx = params.scale,
		sy = params.scale,
		ox = 0.5,
		oy = 0.5,
		r = 0,
		color = function() return colors.clear end,
		image = function(timeState, noteView)
			if not noteView.startTime then
				return
			end
			local deltaTime = timeState.currentTime - noteView.startTime
			if not params.long and deltaTime >= params.frames / params.rate then
				return
			end
			return params.image, getFrame(params, deltaTime)
		end,
	}}
	if not params.long then
		self.notes.ShortNoteLighting = note
	else
		self.notes.LongNoteLighting = note
	end
end

local getAnimation = function(animations, timeState)
	local beforeStart = animations.beforeStart
	local afterStart = animations.afterStart
	local between = animations.between
	local beforeEnd = animations.beforeEnd
	local afterEnd = animations.afterEnd

	local currentTime = timeState.currentTime
	local startTime = timeState.absoluteTime

	local endTime
	if timeState.endTimeState then
		endTime = timeState.endTimeState.absoluteTime
	else
		endTime = math.huge
		between = nil
		beforeEnd = nil
		afterEnd = nil
	end

	local bs = currentTime - startTime < 0
	local as = currentTime - startTime > 0
	local be = currentTime - endTime < 0
	local ae = currentTime - endTime > 0
	if beforeStart then
		bs = (currentTime - startTime) * beforeStart.rate < -beforeStart.frames
	end
	if afterStart then
		as = (currentTime - startTime) * afterStart.rate > afterStart.frames
	end
	if beforeEnd then
		be = (currentTime - endTime) * beforeEnd.rate < -beforeEnd.frames
	end
	if afterEnd then
		ae = (currentTime - endTime) * afterEnd.rate > afterEnd.frames
	end

	-- check < <= > >=
	local animation
	if bs or ae then
		animation = nil
	elseif beforeStart and (currentTime - startTime) * beforeStart.rate < 0 then
		animation = beforeStart
	elseif afterStart and (currentTime - startTime) * afterStart.rate < math.min(afterStart.frames, (endTime - startTime) / 2) then
		animation = afterStart
	elseif between and as and be then
		animation = between
	elseif beforeEnd and (currentTime - endTime) * beforeStart.rate < 0 then
		animation = beforeEnd
	elseif afterEnd and (currentTime - endTime) * beforeStart.rate < afterEnd.frames then
		animation = afterEnd
	end

	local time
	if animation == beforeStart or animation == afterStart then
		time = startTime
	elseif animation == between then
		time = startTime - afterStart.frames / afterStart.rate
	elseif animation == beforeEnd or animation == afterEnd then
		time = endTime
	end

	if not animation then
		return
	end

	return animation, currentTime - time
end

local function getAnimationImage(animations, timeState)
	local animation, deltaTime = getAnimation(animations, timeState)
	if not animation then
		return
	end
	return animation.image, getFrame(animation, deltaTime)
end

NoteSkinVsrg.setAnimation = function(self, params)
	params.frames = math.abs(params.range[2] - params.range[1]) + 1
	local note = {Head = {
		x = function(timeState, _, column) return self.columns[column] + getAnimation(params.animations, timeState).x end,
		y = function(timeState) return self.hitposition + getAnimation(timeState).y end,
		w = function(timeState) return getAnimation(timeState).w end,
		h = function(timeState) return getAnimation(timeState).h end,
		ox = 0,
		oy = 0,
		r = 0,
		color = function() return colors.clear end,
		image = function(timeState)
			return getAnimationImage(params.animations, timeState)
		end,
	}}
	if not params.long then
		self.notes.ShortNoteAnimation = note
	else
		self.notes.LongNoteAnimation = note
	end
end

return NoteSkinVsrg
