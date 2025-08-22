local BassChartAudioSource = require("rizu.engine.audio.BassChartAudioSource")
local ChartAudio = require("rizu.engine.audio.ChartAudio")
local ChartFactory = require("notechart.ChartFactory")
local LoveFilesystem = require("fs.LoveFilesystem")
local ResourceLoader = require("rizu.files.ResourceLoader")
local ResourceFinder = require("rizu.files.ResourceFinder")

local bass = require("bass")
bass.init()

local cf = ChartFactory()

local test = {}

do return test end

function test.bms()
	local fs = LoveFilesystem()
	local rf = ResourceFinder(fs)
	local rl = ResourceLoader(fs, rf)

	local dir = "userdata/charts/Touhou bms pack/Nativefaith"
	local path = dir .. "/native_h.bme"
	local chart = assert(cf:getCharts(path, assert(fs:read(path))))[1].chart

	local ca = ChartAudio()
	ca:load(chart, true)

	rf:addPath(dir)
	rl:load(chart.resources)

	local source = BassChartAudioSource(ca.sounds, rl.resources)
	source:play()

	io.read()

	source:release()
end

return test
