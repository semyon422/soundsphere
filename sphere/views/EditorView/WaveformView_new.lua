local math_util = require("math_util")
local gfx_util = require("gfx_util")

local function getPointList(self, points, sampleStart, sampleEnd, channel)
	local editorModel = self.game.editorModel
	local soundData = editorModel.soundData

	local sampleCount = soundData:getSampleCount()
	local channelCount = soundData:getChannelCount()

	local j = channel

	local list = {}
	local i = sampleStart

	for k = 0, points - 1 do
		local max, min

		local _point = math.floor(math_util.map(i, sampleStart, sampleEnd, 0, points))
		while k == _point do
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
			_point = math.floor(math_util.map(i, sampleStart, sampleEnd, 0, points))
		end

		local x1, x2 = min or 0, max or 0
		if min and max then
			list[#list + 1] = {x1, x2}
		elseif min then
			list[#list + 1] = {x1}
		elseif max then
			list[#list + 1] = {x2}
		end
		if (min or max) and not list.offset then
			list.offset = k
		end
	end

	return list
end

local waveformLines = {}
local waveformPoints = {}
local waveformKey
local prevSamples = 0
local renderedSamples

local roundCounters = {}

local function loadWaveform(self, w, h)
	local editorModel = self.game.editorModel
	local soundData = editorModel.soundData
	local noteSkin = self.game.noteSkinModel.noteSkin

	local sampleRate = soundData:getSampleRate()
	local sampleCount = soundData:getSampleCount()
	local channelCount = soundData:getChannelCount()

	local points = math.floor(h)
	local samples = math.floor(points * sampleRate / math.abs(noteSkin.unit * editorModel.speed))
	local sampleOffset = math.floor((editorModel.timePoint.absoluteTime - editorModel.soundDataOffset) * sampleRate)

	local _waveformKey = sampleOffset .. "/" .. samples
	if waveformKey == _waveformKey then
		return
	end
	waveformKey = _waveformKey

	if samples ~= prevSamples then
		renderedSamples = nil
		prevSamples = samples
	end

	local newSampleStart, newSampleEnd = sampleOffset - samples, sampleOffset + samples - 1

	if renderedSamples then
		local sampleStart, sampleEnd = unpack(renderedSamples)
		if math_util.intersect1(sampleStart, sampleEnd, newSampleStart, newSampleEnd) then
			if newSampleStart > sampleStart then
				for j = 0, channelCount - 1 do
					roundCounters[j] = roundCounters[j] or 0

					local _count = math_util.map(newSampleEnd - sampleEnd, 0, newSampleEnd - newSampleStart, 0, points * 2)

					local c = roundCounters[j]
					roundCounters[j] = roundCounters[j] + _count
					local count = math.floor(roundCounters[j]) - math.floor(c)  -- fixes wrong point adding speed caused by rounding

					local _newPoints = {}
					for i = count + 1, points * 2 do
						_newPoints[#_newPoints + 1] = waveformPoints[j][i - waveformPoints[j].offset]
					end

					local newPoints = getPointList(self, count, sampleEnd, newSampleEnd, j)
					for i = 1, count do
						_newPoints[#_newPoints + 1] = newPoints[i]
					end
					_newPoints.offset = math.max(waveformPoints[j].offset - count, 0)

					waveformPoints[j] = _newPoints
				end
			else
				for j = 0, channelCount - 1 do
					roundCounters[j] = roundCounters[j] or 0

					local _count = math_util.map(sampleStart - newSampleStart, 0, newSampleEnd - newSampleStart, 0, points * 2)

					local c = roundCounters[j]
					roundCounters[j] = roundCounters[j] + _count
					local count = math.floor(roundCounters[j]) - math.floor(c)  -- fixes wrong point adding speed caused by rounding

					local _newPoints = {}

					local newPoints = getPointList(self, count, newSampleStart, sampleStart, j)
					for i = 1, count do
						_newPoints[#_newPoints + 1] = newPoints[i]
					end
					_newPoints.offset = newPoints.offset or 0
					-- _newPoints.offset = math.max(waveformPoints[j].offset - count, 0)

					for i = 1, points * 2 - count do
						_newPoints[#_newPoints + 1] = waveformPoints[j][i]
						-- _newPoints[#_newPoints + 1] = waveformPoints[j][i - waveformPoints[j].offset]
					end

					waveformPoints[j] = _newPoints
				end
			end
		end
	else
		for j = 0, channelCount - 1 do
			waveformPoints[j] = getPointList(self, points * 2, newSampleStart, newSampleEnd, j)
		end
	end

	renderedSamples = {newSampleStart, newSampleEnd}

	waveformLines = {}

	for j = 0, channelCount - 1 do
		waveformLines[j] = waveformLines[j] or {}
		local waveformLine = waveformLines[j]

		local c = 0
		for i = 1, #waveformPoints[j] do
			local p = waveformPoints[j][i]
			for l = 1, #p do
				waveformLine[c + 1] = p[l] * w / 2
				waveformLine[c + 2] = -(i + waveformPoints[j].offset) + points
				c = c + 2
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

	for j = 0, channelCount - 1 do
		local waveformLine = waveformLines[j]
		if #waveformLine >= 4 then
			love.graphics.line(waveformLine)
		end
		love.graphics.translate(noteSkin.fullWidth, 0)
	end

	love.graphics.pop()
end
