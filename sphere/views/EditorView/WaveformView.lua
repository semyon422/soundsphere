local math_util = require("math_util")
local gfx_util = require("gfx_util")

local waveformLines = {}
local waveformKey
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
