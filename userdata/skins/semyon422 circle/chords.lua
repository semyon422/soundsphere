local chords = {}

local start_type_to_suffix = {
	[0] = 1,
	[1] = 2,
	[-1] = 0,
}

local end_type_to_suffix = {
	[0] = 0,
	[1] = 0,
	[-1] = 3,
}

function chords.get_suffix(c, column)
	local l, m, r = c[column - 1], c[column], c[column + 1]
	if not m then
		return "_00"
	end

	local tts = start_type_to_suffix
	if m.weight == -1 then
		tts = end_type_to_suffix
	end

	local a, b = 0, 0
	if l then
		a = tts[l.weight] or 0
	end
	if r then
		b = tts[r.weight] or 0
	end

	return "_" .. a .. b
end

local function getStartNote(noteView)
	local note = noteView.graphicalNote or noteView
	return note.linked_note.startNote
end

local function getEndNote(noteView)
	local note = noteView.graphicalNote or noteView
	return note.linked_note.endNote or note.linked_note.startNote
end

local noChord = {}
function chords.get_start_chord(noteView)
	local startTime = getStartNote(noteView):getTime()
	local chord = noteView.chords[startTime]
	if not chord then
		return noChord
	end

	local sc = {}

	for i, nds in pairs(chord) do
		local visual_note = nds[1]
		local note = visual_note.linked_note
		local startNote = note.startNote
		local endNote = note.endNote
		if startNote:getTime() == startTime then
			sc[i] = startNote
		elseif endNote and endNote:getTime() == startTime then
			sc[i] = endNote
		end
	end

	return sc
end

function chords.get_middle_chord(noteView)
	local note = noteView.graphicalNote.linked_note
	local startTime = note.startNote:getTime()
	local endNote = note.endNote
	if not endNote then
		return noChord
	end
	local endTime = endNote:getTime()

	local sc = noteView.chords[startTime] or noChord
	local ec = noteView.chords[endTime] or noChord

	local mc = {}

	for i, nds in pairs(sc) do
		local head = nds[1]
		local tail = ec[i] and ec[i][1]
		if head == tail then
			mc[i] = head.linked_note.endNote
		end
	end

	return mc
end

return chords
