local sound			= require("aqua.sound")
local ThreadPool	= require("aqua.thread.ThreadPool")

local JamLoader = {}

local ojms = {}
local callbacks = {}

JamLoader.load = function(self, path, callback)
	if ojms[path] then
		return callback(ojms[path])
	end

	if not callbacks[path] then
		callbacks[path] = {}

		ThreadPool:execute({
			f = function(params)
				local byte = require("byte")

				local file = require("aqua.file")
				local sound = require("aqua.sound")
				local OJM = require("o2jam.OJM")

				local path = params.path
				local fileData = file.new(path)
				local ojm = OJM:new(fileData:getString())
				local soundDatas = {}

				for sampleIndex, sampleData in pairs(ojm.samples) do
					soundDatas[sampleIndex] = sound.new(nil, file.new(sampleData.sampleData, sampleIndex))
				end

				return soundDatas
			end,
			params = {
				path = path
			},
			result = function(soundDatas)
				ojms[path] = soundDatas

				for i, soundData in pairs(soundDatas) do
					sound.add(path .. "/" .. i, soundData)
				end

				for i = 1, #callbacks[path] do
					callbacks[path][i](soundDatas)
				end
				callbacks[path] = nil
			end
		})
	end

	callbacks[path][#callbacks[path] + 1] = callback
end

JamLoader.unload = function(self, path, callback)
	if ojms[path] then
		return ThreadPool:execute({
			f = function(params)
				local sound = require("aqua.sound")
				for _, soundData in pairs(params.path) do
					sound.free(soundData)
				end
			end,
			params = {
				path = ojms[path]
			},
			result = function(result)
				for i, soundData in pairs(ojms[path]) do
					sound.remove(path .. "/" .. i)
				end
				ojms[path] = nil
				return callback()
			end
		})
	else
		return callback()
	end
end

return JamLoader
