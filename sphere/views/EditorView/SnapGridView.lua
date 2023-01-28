local Class = require("Class")
local gfx_util = require("gfx_util")
local math_util = require("math_util")
local spherefonts = require("sphere.assets.fonts")
local just = require("just")
local Fraction = require("ncdk.Fraction")
local imgui = require("imgui")

local Layout = require("sphere.views.EditorView.Layout")

local SnapGridView = Class:new()

SnapGridView.hitPosition = 0.75
SnapGridView.laneWidth = 80
SnapGridView.waveformEnabled = true
SnapGridView.notesEnabled = true
SnapGridView.timingEnabled = true

local function getTimingText(timePoint)
	local out = {}
	if timePoint._tempoData then
		table.insert(out, timePoint._tempoData.tempo .. " bpm")
	elseif timePoint._signatureData then
		table.insert(out, "signature " .. tostring(timePoint._signatureData.signature) .. " beats")
	elseif timePoint._stopData then
		table.insert(out, "stop " .. tostring(timePoint._stopData.duration) .. " beats")
	elseif timePoint._intervalData then
		table.insert(out, timePoint.absoluteTime)
	end
	return table.concat(out, ", ")
end

local function getVelocityText(timePoint)
	local out = {}
	if timePoint._velocityData then
		table.insert(out, timePoint._velocityData.currentSpeed .. "x")
	elseif timePoint._expandData then
		table.insert(out, "expand " .. tostring(timePoint._expandData.duration) .. " beats")
	end
	return table.concat(out, ", ")
end

SnapGridView.drawTimingObjects = function(self, field, currentTime, w, h, align, getText)
	local rangeTracker = self.game.editorModel.layerData.ranges.timePoint
	local timePoint = rangeTracker.head
	if not timePoint or not currentTime then
		return
	end

	local endTimePoint = rangeTracker.tail
	while timePoint and timePoint <= endTimePoint do
		local text = getText(timePoint)
		if text then
			local y = (timePoint[field] - currentTime) * self.pixelSpeed
			gfx_util.printFrame(text, 0, y - h / 2, w, h, align, "center")
		end

		timePoint = timePoint.next
	end
end

local colors = {
	white = {1, 1, 1},
	red = {1, 0, 0},
	blue = {0, 0, 1},
	green = {0, 1, 0},
	yellow = {1, 1, 0},
	violet = {1, 0, 1},
}

local snaps = {
	[1] = colors.white,
	[2] = colors.red,
	[3] = colors.violet,
	[4] = colors.blue,
	[5] = colors.yellow,
	[6] = colors.violet,
	[7] = colors.yellow,
	[8] = colors.green,
}

SnapGridView.drawComputedGrid = function(self, field, currentTime, w1, w2)
	local editorModel = self.game.editorModel
	local ld = editorModel.layerData
	local snap = editorModel.snap

	if not currentTime then
		return
	end

	if ld.mode == "measure" then
		for time = ld.startTime:ceil(), ld.endTime:floor() do
			local signature = ld:getSignature(time)
			local _signature = signature:ceil()
			for i = 0, _signature - 1 do
				for j = 0, snap - 1 do
					local f = Fraction(i * snap + j, signature * snap)
					if f:tonumber() < 1 then
						local timePoint = ld:getDynamicTimePoint(f + time, -1)
						if not timePoint then break end
						local y = (timePoint[field] - currentTime) * self.pixelSpeed

						local w = w1 or 30
						if i == 1 and j == 0 then
							w = w2 or w1 or 60
						end
						love.graphics.setColor(snaps[editorModel:getSnap(j)] or colors.white)
						love.graphics.line(0, y, w, y)
					end
				end
			end
		end
	elseif ld.mode == "interval" then
		local timePoint = ld:getDynamicTimePointAbsolute(192, ld.startTime)
		local intervalData = timePoint.intervalData
		local time = timePoint.time
		timePoint = ld:getDynamicTimePointAbsolute(192, ld.endTime)
		local endIntervalData = timePoint.intervalData
		local endTime = timePoint.time

		time = Fraction((time * snap):ceil(), snap)
		endTime = Fraction((endTime * snap):floor(), snap)

		while intervalData and intervalData < endIntervalData or intervalData == endIntervalData and time <= endTime do
			if intervalData.next and time >= intervalData:_end() then
				time = time - intervalData.beats
				intervalData = intervalData.next
			end

			timePoint = ld:getDynamicTimePoint(intervalData, time)
			if not timePoint or not timePoint[field] then break end
			local y = (timePoint[field] - currentTime) * self.pixelSpeed

			local j = snap * (time % 1)
			local w = w1 or 30
			if time == 0 and j == 0 then
				w = w2 or w1 or 60
			end
			love.graphics.setColor(snaps[editorModel:getSnap(j)] or colors.white)
			love.graphics.line(0, y, w, y)

			time = time + Fraction(1, snap)
		end
	end
	love.graphics.setColor(1, 1, 1, 1)
end

local primaryTempo = "60"
local defaultSignature = {"4", "1"}
SnapGridView.drawUI = function(self, w, h)
	local editorModel = self.game.editorModel
	local ld = editorModel.layerData

	local dtp = editorModel:getDynamicTimePoint()

	just.push()

	imgui.setSize(w, h, 200, 55)
	editorModel.snap = imgui.slider1("snap select", editorModel.snap, "%d", 1, 16, 1, "snap")

	local logSpeed = imgui.slider1("editor speed", editorModel:getLogSpeed(), "%d", -30, 50, 1, "speed")
	if logSpeed ~= editorModel:getLogSpeed() then
		editorModel:setLogSpeed(logSpeed)
		editorModel:updateRange()
	end

	if ld.mode == "measure" then
		just.row(true)
		primaryTempo = imgui.input("primaryTempo input", primaryTempo, "primary tempo")
		if imgui.button("set primaryTempo button", "set") then
			ld:setPrimaryTempo(tonumber(primaryTempo))
		end
		if imgui.button("unset primaryTempo button", "unset") then
			ld:setPrimaryTempo(0)
		end
		just.row()

		just.row(true)
		imgui.label("set signature mode", "signature mode")
		if imgui.button("set short signature button", "short") then
			ld:setSignatureMode("short")
		end
		if imgui.button("set long signature button", "long") then
			ld:setSignatureMode("long")
		end
		just.row()

		imgui.setSize(w, h, 100, 55)
		just.row(true)
		defaultSignature[1] = imgui.input("defsig n input", defaultSignature[1])
		imgui.unindent()
		imgui.label("/ label", "/")
		defaultSignature[2] = imgui.input("defsig d input", defaultSignature[2], "default signature")
		if imgui.button("set defsig button", "set") then
			ld:setDefaultSignature(Fraction(tonumber(defaultSignature[1]), tonumber(defaultSignature[2])))
		end
		just.row(false)
		imgui.setSize(w, h, 200, 55)

		just.text("primary tempo: " .. ld.primaryTempo)
		just.text("signature mode: " .. ld.signatureMode)
		just.text("default signature: " .. ld.defaultSignature)

		local measureOffset = dtp.measureTime:floor()
		local signature = ld:getSignature(measureOffset)
		local snap = editorModel.snap

		local beatTime = (dtp.measureTime - measureOffset) * signature
		local snapTime = (beatTime - beatTime:floor()) * snap

		just.text("beat: " .. tostring(beatTime))
		just.text("snap: " .. tostring(snapTime))
	end

	self.laneWidth = imgui.slider1("laneWidth", self.laneWidth, "%d", 10, 200, 10, "lane width")
	self.waveformEnabled = imgui.checkbox("waveformEnabled", self.waveformEnabled, "waveform")
	self.notesEnabled = imgui.checkbox("notesEnabled", self.notesEnabled, "notes")
	self.timingEnabled = imgui.checkbox("timingEnabled", self.timingEnabled, "timing")

	if imgui.button("add object", "add") then
		self.game.gameView:setModal(require("sphere.views.EditorView.AddTimingObjectView"))
	end

	if imgui.button("save btn", "save") then
		self.game.editorController:save()
	end

	local playing = 0
	for _ in pairs(self.game.editorModel.audioManager.sources) do
		playing = playing + 1
	end
	imgui.text("playing sounds: " .. playing)

	just.pop()
end

local waveformLines = {}
local waveformKey
SnapGridView.loadWaveform = function(self, w, h)
	local editorModel = self.game.editorModel
	local soundData = editorModel.soundData

	local sampleRate = soundData:getSampleRate()
	local sampleCount = soundData:getSampleCount()
	local channelCount = soundData:getChannelCount()

	local points = math.floor(h)
	local samples = math.floor(points * sampleRate / math.abs(self.pixelSpeed))

	local sampleOffset = math.floor((editorModel.timePoint.absoluteTime - editorModel.soundDataOffset) * sampleRate)

	local _waveformKey = sampleOffset .. "/" .. samples
	if waveformKey == _waveformKey then
		return
	end
	waveformKey = _waveformKey

	for j = 0, channelCount - 1 do
		waveformLines[j] = waveformLines[j] or {}
		local waveformLine = waveformLines[j]
		local i = -samples
		local c = 0
		for k = 0, 2 * points - 1 do
			local max, min

			local _point = math.floor(math_util.map(i, -samples, samples - 1, 0, 2 * points - 1))
			while k == _point do
				local sampleTime = (sampleOffset + i) * channelCount + j
				if sampleTime >= 0 and sampleTime < sampleCount * channelCount then
					local sample = soundData:getSample(sampleTime)
					if sample >= 0 then
						max = math.max(max or 0, sample)
					else
						min = math.min(min or 0, sample)
					end
				end
				i = i + 1
				_point = math.floor(math_util.map(i, -samples, samples - 1, 0, 2 * points - 1))
			end

			local y = math.floor(-(k - points))

			local x1, x2 = (min or 0) * w / 2, (max or 0) * w / 2
			if min and max then
				waveformLine[c + 1] = x1
				waveformLine[c + 2] = y
				waveformLine[c + 3] = x2
				waveformLine[c + 4] = y
				c = c + 4
			elseif min then
				waveformLine[c + 1] = x1
				waveformLine[c + 2] = y
				c = c + 2
			elseif max then
				waveformLine[c + 1] = x2
				waveformLine[c + 2] = y
				c = c + 2
			end
		end
		for k = c + 1, 8 * points do
			waveformLine[k] = nil
		end
	end
end

SnapGridView.drawWaveform = function(self, _w, h)
	local editorModel = self.game.editorModel
	local soundData = editorModel.soundData
	if not soundData then
		return
	end

	local channelCount = soundData:getChannelCount()

	self:loadWaveform(_w, h)

	love.graphics.push("all")
	love.graphics.setLineJoin("none")

	for j = 0, channelCount - 1 do
		local waveformLine = waveformLines[j]
		if #waveformLine >= 4 then
			love.graphics.line(waveformLine)
		end
		love.graphics.translate(_w, 0)
	end

	love.graphics.pop()
end

SnapGridView.drawTimings = function(self, _w, _h)
	local editorModel = self.game.editorModel
	local ld = editorModel.layerData
	local editorTimePoint = editorModel.timePoint

	if ld.mode ~= "interval" then
		return
	end

	local rangeTracker = self.game.editorModel.layerData.ranges.timePoint
	local timePoint = rangeTracker.head
	if not timePoint then
		return
	end

	love.graphics.push("all")
	love.graphics.setColor(1, 0.8, 0.2)
	love.graphics.setLineWidth(8)
	local endTimePoint = rangeTracker.tail
	while timePoint and timePoint <= endTimePoint do
		local intervalData = timePoint._intervalData
		if intervalData then
			local y = (timePoint.absoluteTime - editorTimePoint.absoluteTime) * self.pixelSpeed
			love.graphics.line(0, y, _w, y)
		end

		timePoint = timePoint.next
	end
	love.graphics.pop()
end

SnapGridView.drawNotes = function(self, _w, _h)
	local editorModel = self.game.editorModel
	local ld = editorModel.layerData
	local pixelSpeed = self.pixelSpeed
	local columns = editorModel.columns

	if not ld.ranges.timePoint.head then
		return
	end

	local nw = _w / columns
	local nh = nw / 4 * (pixelSpeed > 0 and 1 or -1)

	just.push()
	love.graphics.translate(0, -_h * self.hitPosition)

	local _mx, _my = love.graphics.inverseTransformPoint(love.mouse.getPosition())

	local over = just.is_over(_w, _h)
	if over then
		love.graphics.rectangle("fill", _mx - nw / 2, _my, nw, nh)
	end

	local t = editorModel.timePoint.absoluteTime - (_h * self.hitPosition - _my) / pixelSpeed
	for i = 1, columns do
		love.graphics.line(0, 0, 0, _h)
		if just.button("add note" .. i, just.is_over(nw, _h), 1) then
			editorModel:addNote(t, "key", i)
		end
		love.graphics.translate(nw, 0)
	end
	love.graphics.line(0, 0, 0, _h)
	just.pop()

	local currentTime = editorModel.timePoint.absoluteTime

	for _, r in pairs(ld.ranges.note) do
		for inputIndex, range in pairs(r) do
			local noteData = range.head
			while noteData and noteData <= range.tail do
				local y = (noteData.timePoint.absoluteTime - currentTime) * pixelSpeed
				local x = (inputIndex - 1) * nw
				just.push()
				love.graphics.translate(x, y)
				love.graphics.rectangle("fill", 0, 0, nw, nh)
				if just.button("remove note" .. tostring(noteData), just.is_over(nw, nh), 2) then
					ld:removeNoteData(noteData)
				end
				just.pop()

				noteData = noteData.next
			end
		end
	end
end

local function drag(id, w, h)
	local over = just.is_over(w, h)
	local _, active, hovered = just.button(id, over)

	if hovered then
		local alpha = active and 0.2 or 0.1
		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.rectangle("fill", 0, 0, w, h)
	end
	love.graphics.setColor(1, 1, 1, 1)

	return just.active_id == id
end

local prevMouseY = 0
SnapGridView.draw = function(self)
	local editorModel = self.game.editorModel
	local ld = editorModel.layerData

	local w, h = Layout:move("base")
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	local lineHeight = 55
	imgui.setSize(w, h, 200, lineHeight)

	self:drawUI(w, h)

	local pixelSpeed = -h * editorModel.speed
	self.pixelSpeed = pixelSpeed

	local editorTimePoint = editorModel.timePoint

	love.graphics.translate(w / 3, 0)
	local width = self.laneWidth * editorModel.columns

	love.graphics.push()
	local _mx, _my = love.graphics.inverseTransformPoint(love.mouse.getPosition())

	love.graphics.translate(0, h * self.hitPosition)

	love.graphics.setLineWidth(8)
	love.graphics.line(-40, 0, width + 40, 0)
	love.graphics.setLineWidth(1)

	just.push()
	love.graphics.translate(-200, -lineHeight)
	local dtp = editorModel:getDynamicTimePoint()
	if imgui.button("next tp", "next") and dtp.next then
		editorModel:scrollTimePoint(dtp.next)
	end
	if imgui.button("prev tp", "prev") and dtp.prev then
		editorModel:scrollTimePoint(dtp.prev)
	end

	local intervalData = dtp._intervalData
	local grabbedIntervalData = editorModel.grabbedIntervalData
	if not grabbedIntervalData then
		if not intervalData and imgui.button("split interval button", "split interval") then
			ld:splitInterval(dtp)
		end
		if intervalData then
			if imgui.button("merge interval button", "merge") then
				ld:mergeInterval(dtp)
			end
			local inc = imgui.intButtons("update interval", nil, 1)
			if inc ~= 0 then
				ld:updateInterval(intervalData, intervalData.beats + inc)
			end
		end
		if intervalData and imgui.button("grab interval button", "grab") then
			editorModel:grabIntervalData(intervalData)
		end
	else
		if imgui.button("drop interval button", "drop") then
			editorModel:dropIntervalData()
		end
	end
	just.pop()

	self:drawComputedGrid("absoluteTime", editorTimePoint.absoluteTime, width, width)
	if self.notesEnabled then
		self:drawNotes(width, h)
	end
	if self.waveformEnabled then
		self:drawWaveform(width, h)
	end
	if self.timingEnabled then
		self:drawTimings(width, h)
	end

	love.graphics.translate(width + 40, 0)
	self:drawTimingObjects("absoluteTime", editorTimePoint.absoluteTime, 500, 50, "left", getVelocityText)
	love.graphics.pop()

	if love.keyboard.isDown("lalt") and drag("drag1", width, h) then
		editorModel:scrollSecondsDelta(-(_my - prevMouseY) / pixelSpeed)
		if editorModel.timer.isPlaying then
			editorModel:pause()
			self.dragging = true
		end
	elseif self.dragging then
		editorModel:play()
		self.dragging = false
	end
	prevMouseY = _my

	local scroll = just.wheel_over("scale scroll", just.is_over(width, h))
	if just.keypressed("right") then
		scroll = 1
	elseif just.keypressed("left") then
		scroll = -1
	end

	if scroll then
		if love.keyboard.isDown("lshift") then
			editorModel.snap = math.min(math.max(editorModel.snap + scroll, 1), 16)
		elseif love.keyboard.isDown("lctrl") then
			editorModel:setLogSpeed(editorModel:getLogSpeed() + scroll)
			editorModel:updateRange()
		else
			editorModel:scrollSnaps(scroll)
		end
	end
end

return SnapGridView
