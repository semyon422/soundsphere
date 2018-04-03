ffi.cdef(io.open("libraries/bass.h", "r"):read("*a"))

bass = ffi.load("libraries/bass")

bassInit = function()
	bass.BASS_Init(-1, 44100, 0, nil, nil)
end