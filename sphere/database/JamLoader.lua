local sound			= require("aqua.sound")
local aquathread	= require("aqua.thread")

local JamLoader = {}

local ojms = {}

local loadOJM = aquathread.async(function(path)
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
	if ojms[path] then
		return callback(ojms[path])
	end

	local soundDatas = loadOJM(path)
	ojms[path] = soundDatas
	for i, soundData in pairs(soundDatas) do
		sound.add(path .. "/" .. i, soundData)
	end

	callback(soundDatas)
end)

JamLoader.unload = function(self, path)
	if not ojms[path] then
		return
	end
	for i, soundData in pairs(ojms[path]) do
		sound.free(soundData)
		sound.remove(path .. "/" .. i)
	end
end

return JamLoader
