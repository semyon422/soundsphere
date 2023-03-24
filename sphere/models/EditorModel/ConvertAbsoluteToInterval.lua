local LayerData = require("ncdk.LayerData")
local Fraction = require("ncdk.Fraction")

return function(layerData)
	local newLayerData = LayerData:new()
	newLayerData:setTimeMode("interval")

	local ptd = layerData.tempoDatas[1]
	local ptp = layerData.timePointList[1]

	local intervalData = newLayerData:insertIntervalData(ptd.timePoint.absoluteTime, 1)

	local timePointMap = {}

	for _, tp in ipairs(layerData.timePointList) do
		local td = tp.tempoData

		if ptd ~= td then
			local beatDuraion = ptd:getBeatDuration()

			local beatsFull = (td.timePoint.absoluteTime - ptd.timePoint.absoluteTime) / beatDuraion
			local beatsNote = (ptp.absoluteTime - ptd.timePoint.absoluteTime) / beatDuraion
			local beats = math.max(math.floor(beatsFull), beatsNote)

			intervalData.beats = math.max(math.floor(beats), 1)

			local time = ptd.timePoint.absoluteTime + beatDuraion * beats
			if time ~= ptd.timePoint.absoluteTime then
				local start = Fraction:new(beats, 16, false) % 1
				intervalData = newLayerData:insertIntervalData(time, 1, start)
				if beats == beatsNote then
					timePointMap[ptp].intervalData = intervalData
					timePointMap[ptp].time = start
				end
			end
			if time ~= td.timePoint.absoluteTime then
				intervalData = newLayerData:insertIntervalData(td.timePoint.absoluteTime, 1)
			end

			ptd = td
		end

		local dt = tp.absoluteTime - td.timePoint.absoluteTime
		local time = Fraction:new(dt / td:getBeatDuration(), 16, false)

		local newTp = newLayerData:getTimePoint(intervalData, time, tp.visualSide)
		timePointMap[tp] = newTp

		ptp = tp
	end

	local beatDuraion = ptd:getBeatDuration()
	local beats = math.ceil((ptp.absoluteTime - ptd.timePoint.absoluteTime) / beatDuraion)

	if beats > 0 then
		intervalData.beats = beats
		local time = ptd.timePoint.absoluteTime + beatDuraion * beats
		intervalData = newLayerData:insertIntervalData(time, 1)
	end

	for inputMode, r in pairs(layerData.noteDatas) do
		for inputIndex, _noteDatas in pairs(r) do
			for _, noteData in ipairs(_noteDatas) do
				noteData.timePoint = timePointMap[noteData.timePoint]
			end
		end
	end
	newLayerData.noteDatas = layerData.noteDatas

	for _, velocityData in ipairs(layerData.velocityDatas) do
		velocityData.timePoint = timePointMap[velocityData.timePoint]
		velocityData.timePoint._velocityData = velocityData
	end
	newLayerData.velocityDatas = layerData.velocityDatas

	for _, expandData in ipairs(layerData.expandDatas) do
		expandData.timePoint = timePointMap[expandData.timePoint]
		expandData.timePoint._expandData = expandData
	end
	newLayerData.expandDatas = layerData.expandDatas

	newLayerData:compute()

	return newLayerData
end
