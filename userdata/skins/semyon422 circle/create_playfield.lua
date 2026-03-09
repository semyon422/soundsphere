local BasePlayfield = require("sphere.models.NoteSkinModel.BasePlayfield")

local no_options = {}
return function(noteskin, options)
	options = options or no_options
	local config = noteskin.config
	local cs = config:get("columnSize")

	local playfield = BasePlayfield(noteskin)

	playfield:addBga({
		transform = {{1 / 2, -16 / 9 / 2}, {0, -7 / 9 / 2}, 0, {0, 16 / 9}, {0, 16 / 9}, 0, 0, 0, 0}
	})
	playfield:enableCamera()

	local static_keys = {}
	local keys = {}
	local lanes = {}
	for i = 1, noteskin.columnsCount do
		static_keys[i] = "key/key-middle-0.png"
		keys[i] = "key/key-any-1.png"
		if not options.lanes_no_scratch or i > 1 and i < noteskin.columnsCount then
			lanes[i] = "key/light.png"
		end
	end
	static_keys[1] = "key/key-left-0.png"
	static_keys[#static_keys] = "key/key-right-0.png"

	if options.lanes then
		playfield:addStaticKeyImages({
			h = noteskin.unit,
			padding = 0,
			image = lanes,
		})
	end

	playfield:addStaticKeyImages({
		h = cs,
		padding = noteskin.unit - config:get("hitposition"),
		image = static_keys,
	})

	playfield:addNotes()
	playfield:addKeyImages({
		h = cs,
		padding = noteskin.unit - config:get("hitposition"),
		pressed = keys,
	})

	playfield:disableCamera()

	playfield:addBaseElements({"hp", "match players"})

	local combo_bl = config:get("upscroll") and 759 or 476
	playfield:addCircleProgressBar({
		x = cs * noteskin.columnsCount / 2 * 1080 / 480 + 240 + 30,
		y = combo_bl - 20,
		r = 20,
		transform = playfield:newLaneCenterTransform(1080),
		backgroundColor = {1, 1, 1, 0.6},
		foregroundColor = {1, 1, 1, 1},
	})

	playfield:addCombo({
		x = -540,
		baseline = combo_bl,
		limit = 1080,
		align = "center",
		font = {
			filename = "Noto Sans Mono",
			size = 240
		},
		transform = playfield:newLaneCenterTransform(1080),
		color = {1, 1, 1, 0.4},
	})

	playfield:addAccuracy({
		x = 0,
		baseline = combo_bl,
		limit = cs * noteskin.columnsCount / 2 * 1080 / 480 + 240,
		align = "right",
		font = {"Noto Sans Mono", 48},
		transform = playfield:newLaneCenterTransform(1080),
	})

	local hitH = 24
	playfield:addHitError({
		transform = playfield:newLaneCenterTransform(480),
		x = 0,
		y = 240 - hitH / 2,
		w = 64 * 8,
		h = hitH,
		origin = {
			w = 1,
			h = hitH * 1.5,
			color = {1, 1, 1, 1}
		},
		background = {
			color = {0.25, 0.25, 0.25, 0}
		},
		radius = 3,
		count = 20,
	})

	return playfield
end
