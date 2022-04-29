local SubmissionStatus = {
	["1"] = "ranked",
	["2"] = "approved",
	["3"] = "qualified",
}

local function parseBeatmap(line)
	local l = line:split("|")

	local beatmap = {}
	beatmap.serverFilename = l[1]
	beatmap.artist = l[2]
	beatmap.title = l[3]
	beatmap.creator = l[4]

	local status = l[5]
	beatmap.submissionStatus = SubmissionStatus[status] or "pending"

	beatmap.rating = l[6]
	beatmap.lastupdate = l[7]

	beatmap.setId = tonumber(l[8])
	beatmap.threadid = tonumber(l[9])
	beatmap.hasVideo = l[10] == "1"
	beatmap.hasStoryboard = l[11] == "1"
	beatmap.filesize = tonumber(l[12])  -- 1337

	if beatmap.hasVideo and #l[13] > 0 then
		beatmap.filesize_novideo = tonumber(l[13])
	end
	if 13 < #l then
		local difficulties = l[14]:split(",")
		beatmap.difficulties = {}
		for i, subline in ipairs(difficulties) do
			local name, sr, bpm, cs, length = subline:match("^(.+) %((.+)★~(.+)♫~.+~.+~CS(.+)~.+~(.+)%)@3$")
			if name then
				table.insert(beatmap.difficulties, {
					name = name,
					sr = tonumber(sr),
					bpm = tonumber(bpm),
					cs = tonumber(cs),
					length = length,
					beatmap = beatmap,
				})
			end
		end
		table.sort(beatmap.difficulties, function(a, b)
			return a.sr < b.sr
		end)
	end

	return beatmap
end

return function(response)
	local lines = response:split("\n")

	local status = tonumber(lines[1])
	if status < 0 then
		return false, lines[2]
	end

	local beatmaps = {}
	for i = 2, #lines do
		if #lines[i] > 0 then
			table.insert(beatmaps, parseBeatmap(lines[i]))
		end
	end

	return beatmaps
end