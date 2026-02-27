local AudioEngine = require("rizu.engine.audio.AudioEngine")
local FakeSoundDecoder = require("rizu.engine.audio.FakeSoundDecoder")
local FakeChartAudioSource = require("rizu.engine.audio.FakeChartAudioSource")
local FakeMixerSource = require("rizu.engine.audio.FakeMixerSource")

local test = {}

---@param t testing.T
function test.load_and_play(t)
	local engine = AudioEngine()
	engine:setEnabled(false) -- Ensures FakeAudioProvider is used

	local chart = {
		notes = {
			iter = function()
				return ipairs({
					{
						type = "tap",
						visualPoint = {point = {absoluteTime = 1}},
						data = {sounds = {{"bg", 1}}},
					},
				})
			end,
		},
	}

	local resources = {
		bg = 100, -- 100 samples
	}

	engine:load(chart, resources, true)

	t:assert(engine.source ~= nil)
	t:assert(engine.foregroundSource ~= nil)
	t:eq(engine:getStartTime(), 1)

	engine:play()
	t:assert(engine.source.playing)

	engine:update()
	t:assert(engine.source.position > 0)

	engine:playSample("bg", 0.5)
	t:eq(#engine.foregroundSource.active_sounds, 1)
	t:eq(engine.foregroundSource.active_sounds[1].volume, 0.5)

	engine:unload()
	t:eq(engine.chart_audio, nil)
end

return test
