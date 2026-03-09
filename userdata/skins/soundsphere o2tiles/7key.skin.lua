local NoteSkinVsrg = require("sphere.models.NoteSkinModel.NoteSkinVsrg")
local BasePlayfield = require("sphere.models.NoteSkinModel.BasePlayfield")

local noteskin = NoteSkinVsrg({
	path = ...,
	name = "o2tiles",
	inputMode = "7key",
	range = {-1, 1},
	unit = 600,
	hitposition = 480,
})

noteskin:setInput({
	"key1",
	"key2",
	"key3",
	"key4",
	"key5",
	"key6",
	"key7",
})

noteskin:setColumns({
	offset = 5,
	align = "left",
	width = {28, 22, 28, 32, 28, 22, 28},
	space = {0, 0, 0, 0, 0, 0, 0, 0},
})

noteskin:setTextures({
	{pixel = "pixel.png"},
	{black = "black.png"},
	{blue = "blue.png"},
	{red = "red.png"},
	{white = "white.png"},
	{yellow = "yellow.png"},
})

noteskin:setImages({
	pixel = {"pixel"},
	black = {"black"},
	blue = {"blue"},
	red = {"red"},
	white = {"white"},
	yellow = {"yellow"},
})

noteskin:setShortNote({
	image = {
		"white",
		"blue",
		"white",
		"yellow",
		"white",
		"blue",
		"white"
	},
	h = 7,
})

noteskin:setLongNote({
	head = {
		"white",
		"blue",
		"white",
		"yellow",
		"white",
		"blue",
		"white"
	},
	body = {
		"white",
		"blue",
		"white",
		"yellow",
		"white",
		"blue",
		"white"
	},
	tail = {
		"white",
		"blue",
		"white",
		"yellow",
		"white",
		"blue",
		"white"
	},
	h = 7,
})

noteskin:addMeasureLine({
	h = 1,
	color = {1, 1, 1, 1},
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
playfield:add({
	class = "ImageView",
	x = 5, y = 0, w = 188, h = 480,
	transform = playfield:newNoteskinTransform(),
	image = "black.png",
})
playfield:addNotes()
playfield:addKeyImages({
	h = 600,
	padding = 0,
	pressed = {
		"key1-1.png",
		"key2-1.png",
		"key1-1.png",
		"key4-1.png",
		"key1-1.png",
		"key2-1.png",
		"key1-1.png"
	},
	released = {
		"key1-0.png",
		"key2-0.png",
		"key1-0.png",
		"key4-0.png",
		"key1-0.png",
		"key2-0.png",
		"key1-0.png"
	},
})
playfield:disableCamera()

playfield:addBaseElements()

return noteskin
