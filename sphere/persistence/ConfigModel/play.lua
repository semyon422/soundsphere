---@class sphere.PlayConfig
local play = {
	const = false,
	rate = 1,
	modifiers = {},
	timings = {
		nearest = false,
		ShortNote = {
			hit = {-0.12, 0.12},
			miss = {-0.16, 0.16}
		},
		LongNoteStart = {
			hit = {-0.12, 0.12},
			miss = {-0.16, 0.16},
		},
		LongNoteEnd = {
			hit = {-0.12, 0.12},
			miss = {-0.16, 0.16}
		}
	}
}

return play
