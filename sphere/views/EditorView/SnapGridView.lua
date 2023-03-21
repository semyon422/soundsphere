local Class = require("Class")
local gfx_util = require("gfx_util")
local math_util = require("math_util")
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
	local editorModel = self.game.editorModel
	local rangeTracker = editorModel.layerData.ranges.timePoint
	local noteSkin = self.game.noteSkinModel.noteSkin
	local timePoint = rangeTracker.head
	if not timePoint or not currentTime then
		return
	end

	local endTimePoint = rangeTracker.tail
	while timePoint and timePoint <= endTimePoint do
		local text = getText(timePoint)
		if text then
			local y = noteSkin:getTimePosition((currentTime - timePoint[field]) * editorModel.speed)
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

SnapGridView.drawComputedGrid = function(self, field, currentTime, width)
	local editorModel = self.game.editorModel
	local ld = editorModel.layerData
	local snap = editorModel.snap
	local noteSkin = self.game.noteSkinModel.noteSkin

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
						local y = noteSkin:getTimePosition((currentTime - timePoint[field]) * editorModel.speed)
						love.graphics.setColor(snaps[editorModel:getSnap(j)] or colors.white)
						love.graphics.line(0, y, width, y)
					end
				end
			end
		end
	elseif ld.mode == "interval" then
		local timePoint = ld:getDynamicTimePointAbsolute(192, ld.startTime)
		local intervalData = timePoint.intervalData
		local measureData = timePoint.measureData
		local time = timePoint.time
		timePoint = ld:getDynamicTimePointAbsolute(192, ld.endTime)
		local endIntervalData = timePoint.intervalData
		local endTime = timePoint.time

		time = Fraction((time * snap):ceil(), snap)
		endTime = Fraction((endTime * snap):floor(), snap)

		while intervalData and intervalData < endIntervalData or intervalData == endIntervalData and time <= endTime do
			timePoint = ld:getDynamicTimePoint(intervalData, time)
			if not timePoint or not timePoint[field] then break end

			local drawNothing
			if measureData ~= timePoint.measureData then
				measureData = timePoint.measureData
				intervalData, time = measureData.timePoint:add(-measureData.start + Fraction(1, snap))
				timePoint = ld:getDynamicTimePoint(intervalData, time)
				if not timePoint or not timePoint[field] then break end
				drawNothing = timePoint.measureData ~= measureData
			end

			if not drawNothing then
				local y = noteSkin:getTimePosition((currentTime - timePoint[field]) * editorModel.speed)

				local j = snap * timePoint:getBeatModulo()
				love.graphics.setColor(snaps[editorModel:getSnap(j)] or colors.white)
				love.graphics.line(0, y, width, y)
			end

			intervalData, time = timePoint:add(Fraction(1, snap))
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

	editorModel.lockSnap = imgui.checkbox("lock snap", editorModel.lockSnap, "locks snap")

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

	local dtp = editorModel:getDynamicTimePoint()
	if imgui.button("next tp", "next") and dtp.next then
		editorModel:scrollTimePoint(dtp.next)
	end
	if imgui.button("prev tp", "prev") and dtp.prev then
		editorModel:scrollTimePoint(dtp.prev)
	end

	editorModel.tool = imgui.combo("tool select", editorModel.tool, editorModel.tools, nil, "tool")

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
end

SnapGridView.drawTimings = function(self, _w, _h)
	local editorModel = self.game.editorModel
	local ld = editorModel.layerData
	local editorTimePoint = editorModel.timePoint
	local noteSkin = self.game.noteSkinModel.noteSkin

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
	love.graphics.setLineWidth(4)
	local endTimePoint = rangeTracker.tail
	while timePoint and timePoint <= endTimePoint do
		local intervalData = timePoint._intervalData
		local measureData = timePoint._measureData

		if intervalData then
			love.graphics.setColor(1, 0.8, 0.2)
		elseif measureData then
			love.graphics.setColor(snaps[editorModel:getSnap(timePoint:getBeatModulo())] or colors.white)
		end

		if intervalData or measureData then
			local y = noteSkin:getTimePosition((editorTimePoint.absoluteTime - timePoint.absoluteTime) * editorModel.speed)
			love.graphics.line(0, y, _w, y)
		end

		timePoint = timePoint.next
	end
	love.graphics.pop()
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
	local noteSkin = self.game.noteSkinModel.noteSkin

	local w, h = Layout:move("base")
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	love.graphics.setLineStyle("smooth")

	local lineHeight = 55
	imgui.setSize(w, h, 200, lineHeight)

	self:drawUI(w, h)

	local editorTimePoint = editorModel.timePoint

	love.graphics.replaceTransform(gfx_util.transform(self.transform))
	love.graphics.translate(noteSkin.baseOffset, 0)
	local width = noteSkin.fullWidth
	local _mx, _my = love.graphics.inverseTransformPoint(love.mouse.getPosition())

	love.graphics.push()
	self:drawComputedGrid("absoluteTime", editorTimePoint.absoluteTime, width)
	self:drawTimings(width, h)

	love.graphics.translate(width + 40, 0)
	self:drawTimingObjects("absoluteTime", editorTimePoint.absoluteTime, 500, 50, "left", getVelocityText)
	love.graphics.pop()

	if love.keyboard.isDown("lalt") and drag("drag1", width, h) then
		local a = noteSkin:getInverseTimePosition(_my)
		local b = noteSkin:getInverseTimePosition(prevMouseY)
		editorModel:scrollSecondsDelta((a - b) / editorModel.speed)
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
