local NoteSkinVsrg = require("sphere.models.NoteSkinModel.NoteSkinVsrg")
local BasePlayfield = require("sphere.models.NoteSkinModel.BasePlayfield")

local noteskin = NoteSkinVsrg({
	path = ...,
	name = "circle connected",
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

	{bwhite = "body/white.png"},
	{bwhite_left = "body/white-left.png"},
	{bwhite_right = "body/white-right.png"},
	{bwhite_middle = "body/white-middle.png"},

	{hwhite = "headtail/white.png"},
	{hwhite_left = "headtail/white-left.png"},
	{hwhite_right = "headtail/white-right.png"},
	{hwhite_middle = "headtail/white-middle.png"},

	{nwhite = "note/white.png"},
	{nwhite_left = "note/white-left.png"},
	{nwhite_right = "note/white-right.png"},
	{nwhite_middle = "note/white-middle.png"},
	{nred = "note/red.png"},
})

noteskin:setImagesAuto()

local columnsCount = noteskin.columnsCount
local function getSuffix(chord, column)
	local suffix = ""
	if column < columnsCount and not chord[column - 1] and chord[column + 1] then
		suffix = "_left"
	elseif column > 1 and chord[column - 1] and not chord[column + 1] then
		suffix = "_right"
	elseif column > 1 and column < columnsCount and chord[column - 1] and chord[column + 1] then
		suffix = "_middle"
	end
	return suffix
end

local noChord = {}
local function getStartChord(noteView)
	local chord = noteView.chords[noteView.graphicalNote.linked_note.startNote:getTime()]
	return chord or noChord
end
local function getEndChord(noteView)
	local note = noteView.graphicalNote.linked_note
	local endNote = note.endNote or note.startNote
	local chord = noteView.chords[endNote:getTime()]
	return chord or noChord
end
local middleChord = {}
local function getMiddleChord(noteView)
	local startChord = getStartChord(noteView)
	local endChord = getEndChord(noteView)
	for i = 1, columnsCount do
		middleChord[i] = nil
		if type(startChord[i]) == "table" and type(endChord[i]) == "table" then
			middleChord[i] = startChord[i]
		end
	end

	return middleChord
end

noteskin:setShortNote({
	image = function(timeState, noteView, column) return "nwhite" .. getSuffix(getStartChord(noteView), column) end,
	h = 48,
})

noteskin:setLongNote({
	head = function(timeState, noteView, column) return "hwhite" .. getSuffix(getStartChord(noteView), column) end,
	body = function(timeState, noteView, column) return "bwhite" .. getSuffix(getMiddleChord(noteView), column) end,
	tail = function(timeState, noteView, column) return "hwhite" .. getSuffix(getEndChord(noteView), column) end,
	h = 48,
})

noteskin:setShortNote({
	image = "nred",
	h = 48,
	color = {1, 1, 1, 1},
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
	h = 480,
	padding = 0,
	pressed = {
		"key/key-down-1.png",
		"key/key-up-1.png",
		"key/key-up-1.png",
		"key/key-down-1.png",
	},
	released = {
		"key/key-down-0.png",
		"key/key-up-0.png",
		"key/key-up-0.png",
		"key/key-down-0.png",
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
