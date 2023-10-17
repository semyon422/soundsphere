return {
	audio = {
		adjustRate = 0.1,
		device = {  -- use default
			period = 0,
			buffer = 0,
		},
		midi = {
			constantVolume = false
		},
		mode = {
			primary = "bass_fx_tempo",
			secondary = "bass_sample"
		},
		sampleGain = 0,
		volumeType = "linear",
		volume = {
			effects = 1,
			master = 1,
			music = 1,
			metronome = 1,
		}
	},
	editor = {
		audioOffset = 0,
		waveformOffset = 0,
		speed = 1,
		snap = 1,
		lockSnap = true,
		showTimings = true,
		time = 0,
		tool = "Select",
		waveform = {
			opacity = 0.5,
			scale = 0.5
		},
	},
	gameplay = {
		bga = {
			image = false,
			video = false
		},
		hp = {
			shift = false,
			notes = 20,
		},
		lastMeanValues = 10,
		longNoteShortening = 0,
		offset = {
			input = 0,
			visual = 0
		},
		offsetScale = {
			input = false,
			visual = false
		},
		actionOnFail = "none",
		ratingHitTimingWindow = 0.032,
		scaleSpeed = false,
		rateType = "default",
		speedType = "default",
		speed = 1,
		tempoFactor = "average",  -- "average", "primary", "minimum", "maximum"
		primaryTempo = 120,
		time = {
			pausePlay = 0.5,
			pauseRetry = 0.5,
			playPause = 0,
			playRetry = 0.5,
			prepare = 2
		},
	},
	graphics = {
		asynckey = false,
		autoKeySound = false,
		blur = {
			gameplay = 0,
			result = 0,
			select = 0
		},
		cursor = "circle",
		dim = {
			gameplay = 0.8,
			result = 0,
			select = 0
		},
		dwmflush = false,
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
		},
		vsyncOnSelect = true
	},
	input = {
		pause = "escape",
		offset = {
			decrease = "-",
			increase = "="
		},
		playSpeed = {
			decrease = "f3",
			increase = "f4"
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
			increase = "f6"
		}
	},
	miscellaneous = {
		autoUpdate = true,
		muteOnUnfocus = false,
		showNonManiaCharts = false,
		showFPS = false,
		showTasks = false,
		showDebugMenu = false,
	}
}
