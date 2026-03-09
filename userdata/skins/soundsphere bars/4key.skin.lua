local NoteSkinVsrg = require("sphere.models.NoteSkinModel.NoteSkinVsrg")
local BasePlayfield = require("sphere.models.NoteSkinModel.BasePlayfield")

local noteskin = NoteSkinVsrg({
	path = ...,
	name = "bar",
	inputMode = "4key",
	range = {-1, 1},
	unit = 480,
	hitposition = 450,
})

noteskin:setInput({
	"key1",
	"key2",
	"key3",
	"key4",
})

noteskin:setColumns({
	offset = 0,
	align = "center",
	width = {48, 48, 48, 48},
	space = {24, 0, 0, 0, 24},
})

noteskin:setTextures({
	{pixel = "pixel.png"},
	{body = "body.png"},
	{note = "note.png"},
})

noteskin:setImagesAuto()

noteskin:setShortNote({
	image = {
		"note",
		"note",
		"note",
		"note",
	},
	h = 24,
})

noteskin:setLongNote({
	head = {
		"note",
		"note",
		"note",
		"note",
	},
	body = {
		"body",
		"body",
		"body",
		"body",
	},
	tail = {
		"note",
		"note",
		"note",
		"note",
	},
	h = 24,
})

noteskin:setShortNote({
	image = "note",
	h = 24,
	color = {1, 0.25, 0.25, 1},
}, "SoundNote")

noteskin:addMeasureLine({
	h = 2,
	color = {1, 1, 1, 0.5},
	image = "pixel"
})

noteskin:addBga({
	x = 0,
	y = 0,
	w = 1,
	h = 1,
	color = {0.25, 0.25, 0.25, 1}
})

local playfield = BasePlayfield(noteskin)


playfield:addBga({
	transform = {{1 / 2, -16 / 9 / 2}, {0, -7 / 9 / 2}, 0, {0, 16 / 9}, {0, 16 / 9}, 0, 0, 0, 0}
})
playfield:enableCamera()
playfield:addNotes()
playfield:addKeyImages({
	h = 12,
	padding = 30,
	pressed = {
		"key.png",
		"key.png",
		"key.png",
		"key.png",
	},
	released = {
		"key.png",
		"key.png",
		"key.png",
		"key.png",
	},
})

playfield:disableCamera()

playfield:addBaseElements()

playfield:addDeltaTimeJudgement({
	x = 0, y = 540, ox = 0.5, oy = 0.5,
	rate = 2,
	transform = playfield:newLaneCenterTransform(1080),
	judgements = {
		-0.12,
		"judgements/-3.png",
		-0.080,
		"judgements/-2.png",
		-0.048,
		"judgements/-1.png",
		-0.016,
		"judgements/0.png",
		0.016,
		"judgements/1.png",
		0.048,
		"judgements/2.png",
		0.080,
		"judgements/3.png",
		0.12,
	}
})

return noteskin
