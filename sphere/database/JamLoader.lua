local aquathread	= require("aqua.thread")
local audio	= require("aqua.audio")

local JamLoader = {}

local loadOjm = aquathread.async(function(path)
	local audio = require("aqua.audio")
	local OJM = require("o2jam.OJM")

	local fileData, err = love.filesystem.newFileData(path)
	if not fileData then
		return false, err
	end

	local ojm = OJM:new(fileData:getFFIPointer(), fileData:getSize())
	local soundDatas = {}

	for sampleIndex, sampleData in pairs(ojm.samples) do
		soundDatas[sampleIndex] = audio.newSoundData(love.filesystem.newFileData(sampleData, sampleIndex))
	end

	return soundDatas
end)

JamLoader.loadAsync = function(self, path)
	local soundDatas = loadOjm(path)
	if not soundDatas then
		return
	end
	for _, soundData in pairs(soundDatas) do
		setmetatable(soundData, {__index = audio.SoundData})
	end
	return soundDatas
end

return JamLoader
