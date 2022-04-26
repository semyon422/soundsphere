local sound			= require("aqua.sound")
local aquathread	= require("aqua.thread")

local JamLoader = {}

local loadedPath
local loadedSoundDatas = {}

local loadOjm = aquathread.async(function(path)
	local sound = require("aqua.sound")
	local OJM = require("o2jam.OJM")

	local fileData = love.filesystem.newFileData(path)
	local ojm = OJM:new(fileData:getFFIPointer(), fileData:getSize())
	local soundDatas = {}

	for sampleIndex, sampleData in pairs(ojm.samples) do
		soundDatas[sampleIndex] = sound.new(nil, love.filesystem.newFileData(sampleData, sampleIndex))
	end

	return soundDatas
end)

JamLoader.load = aquathread.coro(function(self, path, callback)
	if loadedPath == path then
		return callback(loadedSoundDatas)
	else
		for i, soundData in pairs(loadedSoundDatas) do
			sound.free(soundData)
			sound.remove(path .. "/" .. i)
		end
	end

	local soundDatas = loadOjm(path)
	loadedPath = path
	loadedSoundDatas = soundDatas

	for i, soundData in pairs(soundDatas) do
		sound.add(path .. "/" .. i, soundData)
	end

	callback(soundDatas)
end)

return JamLoader
