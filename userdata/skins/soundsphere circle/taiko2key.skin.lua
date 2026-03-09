local NoteSkinVsrg = require("sphere.models.NoteSkinModel.NoteSkinVsrg")
local BasePlayfield = require("sphere.models.NoteSkinModel.BasePlayfield")

local noteskin = NoteSkinVsrg({
	path = ...,
	name = "taiko",
	inputMode = "2key",
	range = {-1, 2},
	unit = 480,
	hitposition = 280,
})

noteskin:setInput({
	"key1",
	"key2",
})

local note_size = 56 * 1.5

noteskin:setColumns({
	offset = 0,
	align = "center",
	count = 1,
	width = {note_size},
	space = {0, 0},
	inputs = {
		{"key1", 1},
		{"key2", 1},
	},
})

noteskin:setTextures({
	{pixel = "pixel.png"},
	{body = "body/white.png"},
	{body_small = "body/white_small.png"},
	{head = "headtail/white.png"},
	{head_small = "headtail/white_small.png"},
	{note = "note/white.png"},
	{note_small = "note/white_small.png"},
})

local color_red = {1, 0.3, 0.22}
local color_blue = {0.3, 0.65, 0.8}
local color_purple = {0.53, 0.36, 0.80}
local color_yellow = {0.94, 0.69, 0.04}
noteskin:setImagesAuto({
	note_1 = {"note_small", color = color_red},
	note_1_double = {"note", color = color_red},
	note_2 = {"note_small", color = color_blue},
	note_2_double = {"note", color = color_blue},
	note_3 = {"note_small", color = color_purple},
	note_3_double = {"note", color = color_purple},
	note_4_double = {"note", color = {0.8, 0.8, 0.8}},
	head_0 = {"head_small", color = color_yellow},
	head_0_double = {"head", color = color_yellow},
	body_0 = {"body_small", color = color_yellow},
	body_0_double = {"body", color = color_yellow},
})

local function get_note_image(_, noteView)
	local note = noteView.graphicalNote.linked_note
	local startNote = note.startNote

	local postfix = ""
	if startNote.isDouble then
		postfix = "_double"
	end

	local column = noteView.column or noteView.graphicalNote:getColumn()
	local i = tostring(column):match("(%d+)$")
	local chord = noteView.chords[startNote:getTime()]
	if not chord then
		return "note_" .. i .. postfix
	end

	local notes = chord[1]

	if #notes == 1 then
		return "note_" .. i .. postfix
	end

	local both_small, both_large
	both_small = not (notes[1].isDouble or notes[2].isDouble)
	both_large = notes[1].isDouble and notes[2].isDouble
	if both_small or both_large then
		if i == 2 then
			return "empty"
		end
		if both_large then
			return "note_4_double"
		end
		return "note_3_double"
	end

	return "note_" .. i .. postfix
end

noteskin:setShortNote({
	image = get_note_image,
	h = note_size,
})

noteskin:setLongNote({
	head = function(_, noteView)
		local note = noteView.graphicalNote.linked_note
		local postfix = ""
		if note.startNote.isDouble then
			postfix = "_double"
		end
		return "head_0" .. postfix
	end,
	body = function(_, noteView)
		local note = noteView.graphicalNote.linked_note
		local postfix = ""
		if note.startNote.isDouble then
			postfix = "_double"
		end
		return "body_0" .. postfix
	end,
	tail = function(_, noteView)
		local note = noteView.graphicalNote.linked_note
		local postfix = ""
		if note.startNote.isDouble then
			postfix = "_double"
		end
		return "head_0" .. postfix
	end,
	h = note_size,
})

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

local transform = {0, 0, math.pi / 2, {0, 1 / noteskin.unit}, {0, 1 / noteskin.unit}, -noteskin.unit / 2, noteskin.unit, 0, 0}
playfield:enableCamera()
playfield:addNotes({
	transform = transform,
})
playfield:addKeyImages({
	h = note_size,
	padding = 480 - 280,
	pressed = {
		"key/key-taiko.png",
	},
	released = {
		"key/key-taiko.png",
	},
	transform = transform,
})

playfield:disableCamera()

playfield:addBaseElements()

return noteskin
