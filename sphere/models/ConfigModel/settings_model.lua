local modes = love.window.getFullscreenModes()
table.sort(modes, function(a, b)
	if a.width ~= b.width then
		return a.width > b.width
	end
	return a.height > b.height
end)

local settings = {
	{
		name = "play speed",
		section = "gameplay",
		key = "gameplay.speed",
		type = "slider",
		range = {0, 3},
		step = 0.05,
		format = "%0.2f"
	},
	{
		name = "pause on fail",
		section = "gameplay",
		key = "gameplay.pauseOnFail",
		type = "switch",
		displayRange = {"no", "yes"}
	},
	{
		name = "replay type",
		section = "gameplay",
		key = "gameplay.replayType",
		type = "stepper",
		values = {"NanoChart", "Json"},
		displayValues = {"NanoChart", "Json"}
	},
	{
		name = "round off time",
		section = "gameplay",
		key = "gameplay.needTimeRound",
		type = "switch",
		displayRange = {"no", "yes"}
	},
	{
		name = "visual long note shortening",
		section = "gameplay",
		key = "gameplay.longNoteShortening",
		type = "slider",
		range = {-0.3, 0},
		displayRange = {-300, 0},
		step = 0.001,
		format = "%d"
	},
	{
		name = "note offset",
		section = "gameplay",
		key = "gameplay.offset.note",
		type = "slider",
		range = {-0.3, 0.3},
		displayRange = {-300, 300},
		step = 0.001,
		format = "%d"
	},
	{
		name = "input offset",
		section = "gameplay",
		key = "gameplay.offset.input",
		type = "slider",
		range = {-0.3, 0.3},
		displayRange = {-300, 300},
		step = 0.001,
		format = "%d"
	},
	{
		name = "last mean values",
		section = "gameplay",
		key = "gameplay.lastMeanValues",
		type = "slider",
		range = {10, 100},
		step = 10,
		format = "%d"
	},
	{
		name = "new rating",
		section = "gameplay",
		key = "gameplay.newRating",
		type = "switch",
		displayRange = {"disabled", "enabled"}
	},
	{
		name = "rating hit timing window",
		section = "gameplay",
		key = "gameplay.ratingHitTimingWindow",
		type = "slider",
		range = {0.016, 0.064},
		step = 0.016,
		displayRange = {16, 64},
		format = "%d"
	},
	{
		name = "video BGA",
		section = "gameplay",
		key = "gameplay.bga.video",
		type = "switch",
		displayRange = {"disabled", "enabled"}
	},
	{
		name = "image BGA",
		section = "gameplay",
		key = "gameplay.bga.image",
		type = "switch",
		displayRange = {"disabled", "enabled"}
	},
	{
		name = "time to prepare",
		section = "gameplay",
		key = "gameplay.time.prepare",
		type = "slider",
		range = {0.5, 3},
		step = 0.5,
		format = "%0.1f"
	},
	{
		name = "time to play-pause",
		section = "gameplay",
		key = "gameplay.time.playPause",
		type = "slider",
		range = {0, 2},
		step = 0.1,
		format = "%0.1f"
	},
	{
		name = "time to pause-play",
		section = "gameplay",
		key = "gameplay.time.pausePlay",
		type = "slider",
		range = {0, 2},
		step = 0.1,
		format = "%0.1f"
	},
	{
		name = "time to play-retry",
		section = "gameplay",
		key = "gameplay.time.playRetry",
		type = "slider",
		range = {0, 2},
		step = 0.1,
		format = "%0.1f"
	},
	{
		name = "time to pause-retry",
		section = "gameplay",
		key = "gameplay.time.pauseRetry",
		type = "slider",
		range = {0, 2},
		step = 0.1,
		format = "%0.1f"
	},
	{
		name = "pause",
		type = "binding",
		section = "gameplay",
		key = "input.pause"
	},
	{
		name = "skip intro",
		type = "binding",
		section = "gameplay",
		key = "input.skipIntro"
	},
	{
		name = "quick restart",
		type = "binding",
		section = "gameplay",
		key = "input.quickRestart"
	},
	{
		name = "decrease offset",
		type = "binding",
		section = "gameplay",
		key = "input.offset.decrease"
	},
	{
		name = "increase offset",
		type = "binding",
		section = "gameplay",
		key = "input.offset.increase"
	},
	{
		name = "decrease play speed",
		type = "binding",
		section = "gameplay",
		key = "input.playSpeed.decrease"
	},
	{
		name = "increase play speed",
		type = "binding",
		section = "gameplay",
		key = "input.playSpeed.increase"
	},
	{
		name = "invert play speed",
		type = "binding",
		section = "gameplay",
		key = "input.playSpeed.invert"
	},
	{
		name = "decrease time rate",
		type = "binding",
		section = "gameplay",
		key = "input.timeRate.decrease"
	},
	{
		name = "increase time rate",
		type = "binding",
		section = "gameplay",
		key = "input.timeRate.increase"
	},
	{
		name = "invert time rate",
		type = "binding",
		section = "gameplay",
		key = "input.timeRate.invert"
	},
	{
		name = "FPS limit",
		section = "graphics",
		key = "graphics.fps",
		type = "slider",
		range = {10, 1000},
		step = 10,
		format = "%d"
	},
	{
		name = "fullscreen",
		section = "graphics",
		key = "graphics.mode.flags.fullscreen",
		type = "switch",
		displayRange = {"disabled", "enabled"}
	},
	{
		name = "fullscreen type",
		section = "graphics",
		key = "graphics.mode.flags.fullscreentype",
		type = "stepper",
		values = {"desktop", "exclusive"},
	},
	{
		name = "vsync",
		section = "graphics",
		key = "graphics.mode.flags.vsync",
		type = "stepper",
		values = {1, 0, -1},
		displayValues = {"enabled", "disabled", "adaptive"}
	},
	{
		name = "DWM flush",
		section = "graphics",
		key = "graphics.dwmflush",
		type = "switch",
		displayRange = {"disabled", "enabled"}
	},
	{
		name = "predict draw time",
		section = "graphics",
		key = "graphics.predictDrawTime",
		type = "switch",
		displayRange = {"disabled", "enabled"}
	},
	{
		name = "threaded input",
		section = "graphics",
		key = "graphics.asynckey",
		type = "switch",
		displayRange = {"disabled", "enabled"}
	},
	{
		name = "start window resolution",
		section = "graphics",
		key = "graphics.mode.window",
		type = "stepper",
		values = modes,
		format = function(mode)
			return ("%dx%d"):format(mode.width, mode.height)
		end
	},
	{
		name = "cursor",
		section = "graphics",
		key = "graphics.cursor",
		type = "stepper",
		values = {"circle", "arrow", "system"}
	},
	{
		name = "dim select",
		section = "graphics",
		key = "graphics.dim.select",
		type = "slider",
		range = {0, 1},
		displayRange = {0, 100},
		step = 0.01,
		format = "%d"
	},
	{
		name = "dim gameplay",
		section = "graphics",
		key = "graphics.dim.gameplay",
		type = "slider",
		range = {0, 1},
		displayRange = {0, 100},
		step = 0.01,
		format = "%d"
	},
	{
		name = "dim result",
		section = "graphics",
		key = "graphics.dim.result",
		type = "slider",
		range = {0, 1},
		displayRange = {0, 100},
		step = 0.01,
		format = "%d"
	},
	{
		name = "blur select",
		section = "graphics",
		key = "graphics.blur.select",
		type = "slider",
		range = {0, 50},
		displayRange = {0, 50},
		step = 1,
		format = "%d"
	},
	{
		name = "blur gameplay",
		section = "graphics",
		key = "graphics.blur.gameplay",
		type = "slider",
		range = {0, 50},
		displayRange = {0, 50},
		step = 1,
		format = "%d"
	},
	{
		name = "blur result",
		section = "graphics",
		key = "graphics.blur.result",
		type = "slider",
		range = {0, 50},
		displayRange = {0, 50},
		step = 1,
		format = "%d"
	},
	{
		name = "enable camera",
		section = "graphics",
		key = "graphics.perspective.camera",
		type = "switch",
		displayRange = {"disabled", "enabled"}
	},
	{
		name = "allow rotate x",
		section = "graphics",
		key = "graphics.perspective.rx",
		type = "switch",
		displayRange = {"disabled", "enabled"}
	},
	{
		name = "allow rotate y",
		section = "graphics",
		key = "graphics.perspective.ry",
		type = "switch",
		displayRange = {"disabled", "enabled"}
	},
	{
		name = "master volume",
		section = "audio",
		key = "audio.volume.master",
		type = "slider",
		range = {0, 1},
		displayRange = {0, 100},
		step = 0.01,
		format = "%d"
	},
	{
		name = "music volume",
		section = "audio",
		key = "audio.volume.music",
		type = "slider",
		range = {0, 1},
		displayRange = {0, 100},
		step = 0.01,
		format = "%d"
	},
	{
		name = "effects volume",
		section = "audio",
		key = "audio.volume.effects",
		type = "slider",
		range = {0, 1},
		displayRange = {0, 100},
		step = 0.01,
		format = "%d"
	},
	{
		name = "primary audio mode",
		section = "audio",
		key = "audio.mode.primary",
		type = "stepper",
		values = {
			"sample",
			"streamMemoryTempo",
			-- "streamOpenAL", "sampleOpenAL"
		},
		displayValues = {
			"sample",
			"memory",
			-- "streamOAL", "sampleOAL"
		}
	},
	{
		name = "secondary audio mode",
		section = "audio",
		key = "audio.mode.secondary",
		type = "stepper",
		values = {
			"sample",
			"streamMemoryTempo",
			-- "streamOpenAL", "sampleOpenAL"
		},
		displayValues = {
			"sample",
			"memory",
			-- "streamOAL", "sampleOAL"
		}
	},
	{
		name = "preview audio mode",
		section = "audio",
		key = "audio.mode.preview",
		type = "stepper",
		values = {"stream", "streamTempo", "streamOpenAL"},
		displayValues = {"stream", "tempo", "streamOAL"}
	},
	{
		name = "midi constant volume",
		section = "audio",
		key = "audio.midi.constantVolume",
		type = "switch",
		displayRange = {"no", "yes"}
	},
	{
		name = "select random chart",
		type = "binding",
		section = "input",
		key = "input.selectRandom"
	},
	{
		name = "capture screenshot",
		type = "binding",
		section = "input",
		key = "input.screenshot.capture"
	},
	{
		name = "open screenshot",
		type = "binding",
		section = "input",
		key = "input.screenshot.open"
	},
	{
		name = "auto update on game start",
		section = "miscellaneous",
		key = "miscellaneous.autoUpdate",
		type = "switch",
		displayRange = {"disabled", "enabled"}
	},
}

return settings
