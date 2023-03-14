local math_util = require("math_util")
local gfx_util = require("gfx_util")

local function getPointList(self, points, pointOffset, samplesPerPoint, channel)
	local editorModel = self.game.editorModel
	local soundData = editorModel.soundData

	local sampleCount = soundData:getSampleCount()
	local channelCount = soundData:getChannelCount()

	local j = channel

	local list = {}

	for k = 0, points - 1 do
		local sampleStart = math.floor((pointOffset + k) * samplesPerPoint)
		local sampleEnd = math.floor((pointOffset + k + 1) * samplesPerPoint)

		local max, min
		for i = sampleStart, sampleEnd do
			local sampleTime = i * channelCount + j
			if sampleTime >= 0 and sampleTime < sampleCount * channelCount then
				local sample = soundData:getSample(sampleTime)
				if sample >= 0 then
					max = math.max(max or 0, sample)
				else
					min = math.min(min or 0, sample)
				end
			end
			i = i + 1
		end

		local x1, x2 = min or 0, max or 0
		if min and max then
			list[k] = {x1, x2}
		elseif min then
			list[k] = {x1}
		elseif max then
			list[k] = {x2}
		end
	end

	return list
end

local waveformLines = {}
local waveformPoints = {}
local waveformKey
local prevSamplesPerPoint = 0
local renderedPointOffset
local pointDrawDelta

local function adjustPoints(self, pointStart, newPointStart, points, samplesPerPoint, channelCount)
	for j = 0, channelCount - 1 do
		local count = math.abs(pointStart - newPointStart)
		local _newPoints = {}
		if newPointStart > pointStart then
			for i = count, points - 1 do
				_newPoints[i - count] = waveformPoints[j][i]
			end

			local newPoints = getPointList(self, count, pointStart + points + 1, samplesPerPoint, j)
			for i = 0, count - 1 do
				_newPoints[points - count + i] = newPoints[i]
			end
		else
			for i = 0, points - 1 - count do
				_newPoints[i + count] = waveformPoints[j][i]
			end

			local newPoints = getPointList(self, count, newPointStart, samplesPerPoint, j)
			for i = 0, count - 1 do
				_newPoints[i] = newPoints[i]
			end
		end
		waveformPoints[j] = _newPoints
	end
end

local function loadWaveform(self, w, h)
	local editorModel = self.game.editorModel
	local soundData = editorModel.soundData
	local noteSkin = self.game.noteSkinModel.noteSkin

	local sampleRate = soundData:getSampleRate()
	local channelCount = soundData:getChannelCount()

	local points = math.floor(h)

	local samplesPerPoint = sampleRate / math.abs(noteSkin.unit * editorModel.speed)

	local sampleOffset = math.floor((editorModel.timePoint.absoluteTime - editorModel.soundDataOffset) * sampleRate)
	local pointOffset = math.floor(sampleOffset / samplesPerPoint)
	pointDrawDelta = sampleOffset / samplesPerPoint - pointOffset

	local _waveformKey = pointOffset .. "/" .. samplesPerPoint
	if waveformKey == _waveformKey then
		return
	end
	waveformKey = _waveformKey

	if samplesPerPoint ~= prevSamplesPerPoint then
		renderedPointOffset = nil
		prevSamplesPerPoint = samplesPerPoint
	end

	if renderedPointOffset then
		local pointStart, pointEnd = renderedPointOffset - points, renderedPointOffset + points - 1
		local newPointStart, newPointEnd = pointOffset - points, pointOffset + points - 1
		if math_util.intersect1(pointStart, pointEnd, newPointStart, newPointEnd) then
			adjustPoints(self, pointStart, newPointStart, points * 2, samplesPerPoint, channelCount)
		end
	else
		for j = 0, channelCount - 1 do
			waveformPoints[j] = getPointList(self, points * 2, pointOffset - points, samplesPerPoint, j)
		end
	end

	renderedPointOffset = pointOffset

	waveformLines = {}

	for j = 0, channelCount - 1 do
		waveformLines[j] = waveformLines[j] or {}
		local waveformLine = waveformLines[j]

		local c = 0
		for i = 0, points * 2 - 1 do
			local p = waveformPoints[j][i]
			if p then
				for l = 1, #p do
					waveformLine[c + 1] = p[l] * w / 2
					waveformLine[c + 2] = -i + points
					c = c + 2
				end
			end
		end
		for k = c + 1, 8 * points do
			waveformLine[k] = nil
		end
	end
end

return function(self)
	local editorModel = self.game.editorModel
	local soundData = editorModel.soundData
	if not soundData then
		return
	end

	local channelCount = soundData:getChannelCount()

	local noteSkin = self.game.noteSkinModel.noteSkin
	loadWaveform(self, noteSkin.fullWidth, noteSkin.unit)

	love.graphics.push("all")
	love.graphics.setLineJoin("none")

	love.graphics.replaceTransform(gfx_util.transform(self.transform))
	love.graphics.translate(noteSkin.baseOffset, noteSkin.hitposition)
	love.graphics.translate(0, pointDrawDelta)

	for j = 0, channelCount - 1 do
		local waveformLine = waveformLines[j]
		if #waveformLine >= 4 then
			love.graphics.line(waveformLine)
		end
		love.graphics.translate(noteSkin.fullWidth, 0)
	end

	love.graphics.pop()
end
