return {
	audio = {
		midi = {
			constantVolume = false
		},
		mode = {
			preview = "streamOpenAL",
			primary = "streamMemoryTempo",
			secondary = "sample"
		},
		volume = {
			effects = 1,
			master = 1,
			music = 1
		}
	},
	gameplay = {
		bga = {
			image = false,
			video = false
		},
		needTimeRound = true,
		offset = {
			input = 0,
			judgement = 0,
			note = 0
		},
		pauseOnFail = false,
		replayType = "NanoChart",
		speed = 1,
		time = {
			pausePlay = 0.5,
			pauseRetry = 0.5,
			playPause = 0,
			playRetry = 0.5,
			prepare = 2
		}
	},
	graphics = {
		blur = {
			gameplay = 0,
			result = 0,
			select = 0
		},
		cursor = "circle",
		dim = {
			gameplay = 0.8,
			result = 0.6,
			select = 0.5
		},
		fps = 240,
		mode = {
			flags = {
				borderless = false,
				centered = true,
				display = 1,
				fullscreen = false,
				fullscreentype = "exclusive",
				highdpi = false,
				msaa = 0,
				resizable = true,
				usedpiscale = true,
				vsync = 0
			},
			fullscreen = {
				height = 720,
				width = 1280
			},
			window = {
				height = 720,
				width = 1280
			}
		},
		perspective = {
			camera = false,
			pitch = 0,
			rx = false,
			ry = true,
			x = 0.5,
			y = 0.5,
			yaw = 0,
			z = -0.71407400337105997
		}
	},
	input = {
		pause = "escape",
		offset = {
			decrease = "-",
			increase = "="
		},
		playSpeed = {
			decrease = "f3",
			increase = "f4",
			invert = "f2"
		},
		quickRestart = "`",
		screenshot = {
			capture = "f12",
			open = "lshift"
		},
		selectRandom = "f2",
		skipIntro = "space",
		timeRate = {
			decrease = "f5",
			increase = "f6",
			invert = "f7"
		}
	},
	miscellaneous = {
		autoUpdate = true
	}
}
