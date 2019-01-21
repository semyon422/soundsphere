local ThreadPool = require("aqua.thread.ThreadPool")
local sound = require("aqua.sound")

local JamLoader = {}

local ojms = {}
local callbacks = {}

JamLoader.load = function(self, path, callback)
	if ojms[path] then
		return callback(ojms[path])
	end
	
	if not callbacks[path] then
		callbacks[path] = {}
		
		ThreadPool:execute(
			[[
				local aquapackage = require("aqua.package")
				aquapackage.add("chartbase")
				require("byte")
				
				local file = require("aqua.file")
				local sound = require("aqua.sound")
				local OJM = require("o2jam.OJM")
				
				local fileData = file.new(...)
				local ojm = OJM:new(fileData.data)
				local soundDatas = {}
				
				for sampleIndex, sampleData in pairs(ojm.samples) do
					soundDatas[sampleIndex] = sound.new(nil, {
						data = sampleData.sampleData,
						length = #sampleData.sampleData
					})
				end
				
				return soundDatas
			]],
			{path},
			function(result)
				local soundDatas = result[2]
				ojms[path] = soundDatas
				
				for i, soundData in pairs(ojms[path]) do
					sound.add(path .. "/" .. i, soundData)
				end
				
				for i = 1, #callbacks[path] do
					callbacks[path][i](soundDatas)
				end
				callbacks[path] = nil
			end
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

return JamLoader
