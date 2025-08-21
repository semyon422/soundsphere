local ResourceFinder = require("rizu.files.ResourceFinder")
local FakeFilesystem = require("fs.FakeFilesystem")

local test = {}

---@param t testing.T
function test.find_file(t)
	local fs = FakeFilesystem()
	local rf = ResourceFinder(fs)

	fs:createDirectory("dir")
	fs:write("dir/audio.mp3", "")

	rf:addPath("dir")

	t:eq(rf:findFile("audio.mp3"), "dir/audio.mp3")
	t:eq(rf:findFile("/audio.mp3"), "dir/audio.mp3")
	t:eq(rf:findFile("\\audio.mp3"), "dir/audio.mp3")
end

---@param t testing.T
function test.equal_name_found(t)
	local fs = FakeFilesystem()
	local rf = ResourceFinder(fs)

	fs:createDirectory("dir")
	fs:write("dir/Audio.MP3", "")
	fs:write("dir/audio.mp3", "")

	rf:addPath("dir")

	t:eq(rf:findFile("audio.mp3"), "dir/audio.mp3")
end

---@param t testing.T
function test.case_insensetive(t)
	local fs = FakeFilesystem()
	local rf = ResourceFinder(fs)

	fs:createDirectory("dir")
	fs:write("dir/audio.mp3", "")

	rf:addPath("dir")

	t:eq(rf:findFile("AUDIO.MP3"), "dir/audio.mp3")
end

---@param t testing.T
function test.alternate_ext_ordered(t)
	local fs = FakeFilesystem()
	local rf = ResourceFinder(fs)

	fs:createDirectory("dir")
	fs:write("dir/audio.wav", "")
	fs:write("dir/audio.mp3", "")

	rf:addPath("dir")

	t:eq(rf:findFile("audio.ogg"), "dir/audio.wav")
end

---@param t testing.T
function test.many_paths(t)
	local fs = FakeFilesystem()
	local rf = ResourceFinder(fs)

	fs:createDirectory("dir1")
	fs:createDirectory("dir2")
	fs:write("dir1/audio.mp3", "")
	fs:write("dir2/audio.wav", "")

	rf:addPath("dir1")
	rf:addPath("dir2")

	t:eq(rf:findFile("audio.ogg"), "dir1/audio.mp3")
end

return test
