local Class = require("Class")
local gfx_util = require("gfx_util")
local spherefonts = require("sphere.assets.fonts")
local just = require("just")
local Fraction = require("ncdk.Fraction")
local imgui = require("sphere.imgui")

local Layout = require("sphere.views.EditorView.Layout")

local SnapGridView = Class:new()

SnapGridView.construct = function(self)
	self.pixelsPerBeat = 40
	self.pixelsPerSecond = 40
end

local function getTimePointText(timePoint)
	if timePoint._tempoData then
		return timePoint._tempoData.tempo .. " bpm"
	elseif timePoint._stopData then
		return "stop " .. tostring(timePoint._stopData.duration) .. " beats"
	elseif timePoint._velocityData then
		return timePoint._velocityData.currentSpeed .. "x"
	elseif timePoint._expandData then
		return "expand into " .. tostring(timePoint._expandData.duration) .. " beats"
	end
end

SnapGridView.drawTimingObjects = function(self, field, currentTime, pixels)
	local rangeTracker = self.game.editorModel.layerData.timePointsRange
	local object = rangeTracker.startObject
	if not object then
		return
	end

	local endObject = rangeTracker.endObject
	while object and object <= endObject do
		local text = getTimePointText(object)
		if text then
			local y = (object[field] - currentTime) * pixels
			love.graphics.line(0, y, 10, y)
			gfx_util.printFrame(text, -500, y - 25, 490, 50, "right", "center")
		end

		object = object.next
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

SnapGridView.drawComputedGrid = function(self, field, currentTime, pixels)
	local editorModel = self.game.editorModel
	local ld = editorModel.layerData
	local snap = editorModel.snap

	for time = ld.startTime:ceil(), ld.endTime:floor() do
		local signature = ld:getSignature(time)
		local _signature = signature:ceil()
		for i = 1, _signature do
			for j = 1, snap do
				local f = Fraction((i - 1) * snap + j - 1, signature * snap)
				if f:tonumber() < 1 then
					local timePoint = ld:getDynamicTimePoint(f + time, -1)
					if not timePoint then break end
					local y = (timePoint[field] - currentTime) * pixels

					local w = 30
					if i == 1 and j == 1 then
						w = 60
					end
					love.graphics.setColor(snaps[editorModel:getSnap(j)] or colors.white)
					love.graphics.line(0, y, w, y)
				end
			end
		end
	end
	love.graphics.setColor(1, 1, 1, 1)
end

SnapGridView.drawUI = function(self, w, h)
	local editorModel = self.game.editorModel

	just.push()

	imgui.setSize(w, h, 200, 55)
	editorModel.snap = imgui.slider1("snap select", editorModel.snap, "%d", 1, 16, 1, "snap")
	self.pixelsPerBeat = imgui.slider1("beat pixels", self.pixelsPerBeat, "%d", 10, 1000, 10, "pixels per beat")
	self.pixelsPerSecond = imgui.slider1("second pixels", self.pixelsPerSecond, "%d", 10, 1000, 10, "pixels per second")

	if imgui.button("add object", "add") then
		self.game.gameView:setModal(require("sphere.views.EditorView.AddTimingObjectView"))
	end

	local dtp = editorModel:getDynamicTimePoint()

	local ld = editorModel.layerData
	local measureOffset = dtp.measureTime:floor()
	local signature = ld:getSignature(measureOffset)
	local snap = editorModel.snap

	local beatTime = (dtp.measureTime - measureOffset) * signature
	local snapTime = (beatTime - beatTime:floor()) * snap

	just.text("time point: " .. tostring(dtp))
	just.text("beat: " .. tostring(beatTime))
	just.text("snap: " .. tostring(snapTime))

	just.row(true)
	if imgui.button("prev tp", "prev") and dtp.prev then
		editorModel:scrollTimePoint(dtp.prev)
	end
	if imgui.button("next tp", "next") and dtp.next then
		editorModel:scrollTimePoint(dtp.next)
	end
	just.row()

	just.pop()
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

	local w, h = Layout:move("base")
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	self:drawUI(w, h)

	love.graphics.translate(w / 5, 0)

	love.graphics.push()
	love.graphics.translate(0, h / 2)
	love.graphics.line(0, 0, 240, 0)

	love.graphics.translate(-40, 0)
	self:drawTimingObjects("beatTime", editorModel.beatTime, self.pixelsPerBeat)
	love.graphics.translate(40, 0)
	self:drawComputedGrid("beatTime", editorModel.beatTime, self.pixelsPerBeat)

	love.graphics.translate(80, 0)
	self:drawComputedGrid("absoluteTime", editorModel.absoluteTime, self.pixelsPerSecond)

	love.graphics.translate(80, 0)
	self:drawComputedGrid("visualTime", editorModel.visualTime, self.pixelsPerSecond)

	love.graphics.pop()

	local _, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	my = h - my

	just.push()
	just.row(true)
	local pixels = drag("drag1", 80, h) and self.pixelsPerBeat or drag("drag2", 160, h) and self.pixelsPerSecond
	if pixels then
		editorModel:scrollSeconds((my - prevMouseY) / pixels)
	end
	just.row()
	just.pop()

	prevMouseY = my

	local scroll = just.wheel_over("scale scroll", just.is_over(240, h))
	scroll = scroll and -scroll
	if just.keypressed("right") then
		scroll = 1
	elseif just.keypressed("left") then
		scroll = -1
	end

	if scroll then
		editorModel:scrollSnaps(scroll)
	end
end

return SnapGridView
