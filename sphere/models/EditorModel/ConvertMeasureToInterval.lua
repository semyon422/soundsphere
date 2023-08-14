local LayerData = require("ncdk.LayerData")
local Fraction = require("ncdk.Fraction")

return function(layerData)
	local newLayerData = LayerData()
	newLayerData:setTimeMode("interval")

	local lastTimePoint = layerData.timePointList[#layerData.timePointList]
	local lastBeatTime = lastTimePoint.fullBeatTime

	local intervalsMap = {}
	local intervalData
	for i = 1, #layerData.tempoDatas do
		local td = layerData.tempoDatas[i]
		local td_next = layerData.tempoDatas[i + 1]
		local beatTime = td.timePoint.fullBeatTime
		local beats = 1
		if td_next then
			beats = td_next.timePoint.fullBeatTime:floor() - beatTime:floor()
		else
			beats = lastBeatTime:floor() - beatTime:floor()
		end
		intervalData = newLayerData:insertIntervalData(td.timePoint.absoluteTime, beats, beatTime % 1)
		intervalsMap[td] = intervalData
	end
	local lastIntervalData = intervalData
	if not lastTimePoint._tempoData then
		lastIntervalData = newLayerData:insertIntervalData(lastTimePoint.absoluteTime, 1, lastBeatTime % 1)
	end

	local timePointMap = {}
	for _, tp in ipairs(layerData.timePointList) do
		local td = tp.tempoData

		local beatTime = td.timePoint.fullBeatTime
		local intervalData = intervalsMap[td]
		local time = tp.fullBeatTime - beatTime:floor()

		if tp == lastTimePoint then
			intervalData = lastIntervalData
			time = lastBeatTime % 1
		end

		timePointMap[tp] = newLayerData:getTimePoint(intervalData, time, tp.visualSide)
	end

	if layerData.noteDatas.measure then
		for inputIndex, _noteDatas in pairs(layerData.noteDatas.measure) do
			for _, noteData in ipairs(_noteDatas) do
				if noteData.noteType == "LineNoteStart" then
					newLayerData:insertMeasureData(timePointMap[noteData.timePoint])
				end
			end
		end
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

	return newLayerData, timePointMap
end
