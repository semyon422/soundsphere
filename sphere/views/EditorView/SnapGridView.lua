local Class = require("Class")
local gfx_util = require("gfx_util")
local spherefonts = require("sphere.assets.fonts")
local just = require("just")
local Fraction = require("ncdk.Fraction")
local imgui = require("imgui")

local Layout = require("sphere.views.EditorView.Layout")

local SnapGridView = Class:new()

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
			local y = (timePoint[field] - currentTime) * self.speed
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
			for i = 1, _signature do
				for j = 1, snap do
					local f = Fraction((i - 1) * snap + j - 1, signature * snap)
					if f:tonumber() < 1 then
						local timePoint = ld:getDynamicTimePoint(f + time, -1)
						if not timePoint then break end
						local y = (timePoint[field] - currentTime) * self.speed

						local w = w1 or 30
						if i == 1 and j == 1 then
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
			if intervalData.next and time - intervalData.start >= intervalData.beats then
				intervalData = intervalData.next
				time = Fraction((intervalData.start * snap):ceil(), snap)
			end

			timePoint = ld:getDynamicTimePoint(intervalData, time)
			if not timePoint or not timePoint[field] then break end
			local y = (timePoint[field] - currentTime) * self.speed

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
	local speed = imgui.slider1("second pixels", 100 * editorModel.speed, "%d", 10, 1000, 10, "scale") / 100
	if speed ~= editorModel.speed then
		editorModel.speed = speed
		editorModel:updateRange()
	end

	if imgui.button("add object", "add") then
		self.game.gameView:setModal(require("sphere.views.EditorView.AddTimingObjectView"))
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

	just.text("time point: " .. tostring(dtp))

	just.row(true)
	if imgui.button("prev tp", "prev") and dtp.prev then
		editorModel:scrollTimePoint(dtp.prev)
	end
	if imgui.button("next tp", "next") and dtp.next then
		editorModel:scrollTimePoint(dtp.next)
	end
	just.row()

	if imgui.button("save btn", "save") then
		self.game.editorController:save()
	end

	just.pop()
end

SnapGridView.drawNotes = function(self, pixels, width)
	local editorModel = self.game.editorModel
	local ld = editorModel.layerData

	local rangeTracker = self.game.editorModel.layerData.ranges.timePoint
	local timePoint = rangeTracker.head
	if not timePoint then
		return
	end

	local currentTime = editorModel.timePoint.absoluteTime

	local endTimePoint = rangeTracker.tail
	while timePoint and timePoint <= endTimePoint do
		local noteDatas = timePoint.noteDatas
		if noteDatas then
			for _, noteData in ipairs(noteDatas) do
				local y = (timePoint.absoluteTime - currentTime) * pixels
				local x = (noteData.inputIndex - 1) * width / 4
				local h = (pixels > 0 and 1 or -1) * width / 16
				just.push()
				love.graphics.translate(x, y)
				love.graphics.rectangle("fill", 0, 0, width / 4, h)
				if just.button("remove note" .. tostring(noteData), just.is_over(width / 4, h), 2) then
					ld:removeNoteData(noteData)
				end
				just.pop()
			end
		end

		timePoint = timePoint.next
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

	just.next(w, h)

	return just.active_id == id
end

local prevMouseY = 0
SnapGridView.draw = function(self)
	local editorModel = self.game.editorModel
	local ld = editorModel.layerData

	local w, h = Layout:move("base")
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	self:drawUI(w, h)

	local speed = -h * editorModel.speed
	self.speed = speed

	local editorTimePoint = editorModel.timePoint

	love.graphics.translate(w / 3, 0)

	-- love.graphics.push()
	-- love.graphics.translate(0, h / 2)
	-- love.graphics.line(0, 0, 240, 0)
	-- love.graphics.translate(-40, 0)
	-- if ld.mode == "measure" then
	-- 	self:drawTimingObjects("beatTime", editorTimePoint.beatTime, -500, 50, "right", getTimingText)
	-- elseif ld.mode == "interval" then
	-- 	self:drawTimingObjects("absoluteTime", editorTimePoint.absoluteTime, -500, 50, "right", getTimingText)
	-- end
	-- love.graphics.translate(40, 0)
	-- self:drawComputedGrid("beatTime", editorTimePoint.beatTime)

	-- love.graphics.translate(80, 0)
	-- self:drawComputedGrid("absoluteTime", editorTimePoint.absoluteTime)

	-- love.graphics.translate(80, 0)
	-- self:drawComputedGrid("visualTime", editorTimePoint.visualTime)

	-- love.graphics.pop()

	love.graphics.push()
	local _mx, _my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local my = h - _my

	local over = just.is_over(320, h)
	local t = editorTimePoint.absoluteTime - (my - h / 2) / speed
	if over then
		love.graphics.rectangle("fill", _mx, _my, 80, -20)
	end

	love.graphics.push()
	for i = 1, 4 do
		love.graphics.line(0, 0, 0, h)
		if just.button("add note" .. i, just.is_over(80, h), 1) then
			editorModel:addNote(t, "key", i)
		end
		love.graphics.translate(80, 0)
	end
	love.graphics.line(0, 0, 0, h)
	love.graphics.pop()

	just.push()
	love.graphics.translate(-40, 0)
	if drag("drag1", 40, h) then
		editorModel:scrollSeconds((my - prevMouseY) / speed)
	end
	just.pop()

	love.graphics.translate(0, h / 2)
	love.graphics.line(-40, 0, 360, 0)
	self:drawComputedGrid("absoluteTime", editorTimePoint.absoluteTime, 320, 320)
	self:drawNotes(speed, 320)
	love.graphics.translate(340, 0)
	self:drawTimingObjects("absoluteTime", editorTimePoint.absoluteTime, 500, 50, "left", getVelocityText)
	love.graphics.pop()

	prevMouseY = my

	local scroll = just.wheel_over("scale scroll", just.is_over(240, h))
	if just.keypressed("right") then
		scroll = 1
	elseif just.keypressed("left") then
		scroll = -1
	end

	if scroll then
		if love.keyboard.isDown("lshift") then
			editorModel.snap = math.min(math.max(editorModel.snap + scroll, 1), 16)
		elseif love.keyboard.isDown("lctrl") then
			editorModel.speed = math.min(math.max(editorModel.speed * 100 + scroll * 10, 10), 1000) / 100
		else
			editorModel:scrollSnaps(scroll)
		end
	end
end

return SnapGridView
