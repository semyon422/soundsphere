local aquathread	= require("aqua.thread")
local sound	= require("aqua.sound")

local JamLoader = {}

local loadOjm = aquathread.async(function(path)
	local sound = require("aqua.sound")
	local OJM = require("o2jam.OJM")

	local fileData, err = love.filesystem.newFileData(path)
	if not fileData then
		return false, err
	end

	local ojm = OJM:new(fileData:getFFIPointer(), fileData:getSize())
	local soundDatas = {}

	for sampleIndex, sampleData in pairs(ojm.samples) do
		soundDatas[sampleIndex] = sound.newSoundData(love.filesystem.newFileData(sampleData, sampleIndex))
	end

	return soundDatas
end)

JamLoader.loadAsync = function(self, path)
	local soundDatas = loadOjm(path)
	if not soundDatas then
		return
	end
	for _, soundData in pairs(soundDatas) do
		setmetatable(soundData, {__index = sound.SoundData})
	end
	return soundDatas
end

return JamLoader
