local sound			= require("aqua.sound")
local ThreadPool	= require("aqua.thread.ThreadPool")

local JamLoader = {}

local ojms = {}
local callbacks = {}

JamLoader.init = function(self)
	ThreadPool.observable:add(self)
end

JamLoader.load = function(self, path, callback)
	if ojms[path] then
		return callback(ojms[path])
	end

	if not callbacks[path] then
		callbacks[path] = {}

		ThreadPool:execute(
			function(...)
				local byte = require("byte")

				local file = require("aqua.file")
				local sound = require("aqua.sound")
				local OJM = require("o2jam.OJM")

				local path = ...
				local fileData = file.new(path)
				local ojm = OJM:new(fileData:getString())
				local soundDatas = {}

				for sampleIndex, sampleData in pairs(ojm.samples) do
					soundDatas[sampleIndex] = sound.new(nil, file.new(sampleData.sampleData, sampleIndex))
				end

				thread:push({
					name = "OJM_SoundDatas",
					soundDatas = soundDatas,
					path = path
				})
			end,
			{path}
		)
	end

	callbacks[path][#callbacks[path] + 1] = callback
end

JamLoader.unload = function(self, path, callback)
	if ojms[path] then
		return ThreadPool:execute(
			[[
				local sound = require("aqua.sound")
				for _, soundData in pairs(...) do
					sound.free(soundData)
				end
			]],
			{ojms[path]},
			function(result)
				for i, soundData in pairs(ojms[path]) do
					sound.remove(path .. "/" .. i)
				end
				ojms[path] = nil
				return callback()
			end
		)
	else
		return callback()
	end
end

JamLoader.receive = function(self, event)
	if event.name == "OJM_SoundDatas" then
		local soundDatas = event.soundDatas
		local path = event.path
		ojms[path] = soundDatas

		for i, soundData in pairs(soundDatas) do
			sound.add(path .. "/" .. i, soundData)
		end

		for i = 1, #callbacks[path] do
			callbacks[path][i](soundDatas)
		end
		callbacks[path] = nil
	end
end

return JamLoader
