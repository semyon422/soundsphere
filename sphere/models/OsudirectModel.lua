local Class = require("Class")
local extractAsync = require("sphere.filesystem.extract")
local downloadAsync = require("sphere.filesystem.download")
local thread = require("thread")
local delay = require("delay")
local http_util = require("http_util")
local json = require("json")

local OsudirectModel = Class:new()

OsudirectModel.rankedStatuses = {
	{-3, "any"},
	{-2, "graveyard"},
	{-1, "wip"},
	{0, "pending"},
	{1, "ranked"},
	{3, "qualified"},
	{4, "loved"},
}
OsudirectModel.rankedStatusesMap = {}
for i, d in ipairs(OsudirectModel.rankedStatuses) do
	OsudirectModel.rankedStatuses[i] = d[2]
	OsudirectModel.rankedStatusesMap[d[2]] = d[1]
end

OsudirectModel.load = function(self)
	self.statusBeatmap = {title = "LOADING", artist = ""}
	self.items = {self.statusBeatmap}
	self.processing = {}
	self.page = 1
	self.rankedStatus = "ranked"
end

OsudirectModel.setRankedStatus = function(self, status)
	self.rankedStatus = status
	self.page = 1
	self.items = {self.statusBeatmap}
	self:searchNoDebounce()
end

OsudirectModel.update = function(self)
	local dl = thread.shared.download
	for _, b in ipairs(self.processing) do
		local status = dl[b.url]
		if status then
			if b.isDownloading then
				local status = dl[b.url]
				b.status = ("%0.1fmbps - %3.2f%%"):format(
					status.speed * 1e-6,
					(status.total / status.size) * 100
				)
			else
				dl[b.url] = nil
			end
		end
	end
end

OsudirectModel.isChanged = function(self)
	local changed = self.changed
	self.changed = false
	return changed
end

OsudirectModel.setBeatmap = function(self, beatmap)
	self.beatmap = beatmap
	self.changed = true

	local statusBeatmap = self.statusBeatmap
	if beatmap ~= statusBeatmap or self.items[1] == beatmap or statusBeatmap.title == "LOADING" then
		return
	end
	statusBeatmap.title = "LOADING"
	coroutine.wrap(function()
		self:searchNext()
	end)()
end

OsudirectModel.searchString = ""

OsudirectModel.setSearchString = function(self, s)
	self.searchString = s
	self:searchDebounce()
end

local empty = {}
OsudirectModel.getDifficulties = function(self)
	local beatmap = self.beatmap
	return beatmap and beatmap.difficulties or empty
end

local requestAsync = thread.async(function(url)
	local https = require("ssl.https")
	return https.request(url)
end)

OsudirectModel.searchDebounce = function(self)
	delay.debounce(self, "loadDebounce", 0.1, self.search, self)
end

OsudirectModel.searchNoDebounce = function(self)
	coroutine.wrap(function()
		self:search()
	end)()
end

OsudirectModel.search = function(self)
	self.statusBeatmap.title = "LOADING"
	self.items = {self.statusBeatmap}
	self.page = 0

	local searchString = self.searchString
	self:searchNext()
	if searchString ~= self.searchString then
		return self:search()
	end
end

OsudirectModel.searchRequest = function(self, searchString, page)
	local config = self.game.configModel.configs.urls.osu
	local url = config.search .. "?" .. http_util.encode_query_string({
		query = searchString,
		mode = 3,
		offset = (page - 1) * 100,
		status = self.rankedStatusesMap[self.rankedStatus],
		amount = 100,
	})
	print("GET " .. url)
	local body = requestAsync(url)
	if not body then
		return
	end

	local status, err = pcall(json.decode, body)
	if not status then
		return {}
	end

	local beatmaps = {}
	for _, set in ipairs(err) do
		local beatmap = {}
		beatmap.artist = set.Artist
		beatmap.title = set.Title
		beatmap.creator = set.Creator
		beatmap.setId = set.SetID

		beatmap.difficulties = {}
		for i, diff in ipairs(set.ChildrenBeatmaps) do
			table.insert(beatmap.difficulties, {
				name = diff.DiffName,
				sr = diff.DifficultyRating,
				bpm = diff.BPM,
				cs = diff.CS,
				length = diff.TotalLength,
				beatmap = beatmap,
			})
		end
		table.sort(beatmap.difficulties, function(a, b)
			return a.sr < b.sr
		end)

		table.insert(beatmaps, beatmap)
	end

	return beatmaps
end

OsudirectModel.searchNext = function(self)
	self.page = self.page + 1

	local searchString = self.searchString
	local beatmaps = self:searchRequest(searchString, self.page)
	if not beatmaps then
		self.statusBeatmap.title = "UNAVAILABLE"
		return
	end
	if #beatmaps == 0 then
		self.statusBeatmap.title = "NO RESULTS"
		return
	end

	local newPos = #self.items
	table.remove(self.items, newPos)
	for _, beatmap in ipairs(beatmaps) do
		table.insert(self.items, beatmap)
	end

	self.statusBeatmap.title = "LOAD MORE"
	table.insert(self.items, self.statusBeatmap)

	self:setBeatmap(self.items[newPos])
end

OsudirectModel.getBackgroundUrl = function(self)
	local config = self.game.configModel.configs.urls.osu
	return config.background:format(self.beatmap.setId)
end

OsudirectModel.getPreviewUrl = function(self)
	local config = self.game.configModel.configs.urls.osu
	return config.preview:format(self.beatmap.setId)
end

OsudirectModel.downloadBeatmapSet = thread.coro(function(self, beatmap, callback)
	if not beatmap or beatmap == self.statusBeatmap then
		return
	end

	table.insert(self.processing, 1, beatmap)

	local config = self.game.configModel.configs.urls.osu

	local saveDir = "userdata/charts/downloads"

	local setId = beatmap.setId
	local url = config.download:format(setId)
	beatmap.url = url

	print(("Downloading: %s"):format(url))
	beatmap.status = "Downloading"

	beatmap.isDownloading = true
	local filename, err = downloadAsync(url, saveDir)
	beatmap.isDownloading = false

	if not filename then
		beatmap.status = err
		return
	end

	local savePath = saveDir .. "/" .. filename
	print(("Downloaded: %s"):format(savePath))
	if not filename:find("%.osz$") then
		beatmap.status = "Unsupported file type"
		print("Unsupported file type")
		return
	end

	local extractPath = saveDir .. "/" .. filename:match("^(.+)%.osz$")
	print("Extracting")
	beatmap.status = "Extracting"
	local extracted = extractAsync(savePath, extractPath, true)
	if not extracted then
		beatmap.status = "Extracting error"
		return
	end
	print(("Extracted to: %s"):format(extractPath))

	beatmap.status = "Caching"

	local c = coroutine.running()
	self.game.cacheModel:startUpdate(extractPath, true, function()
		coroutine.resume(c)
	end)
	coroutine.yield()

	for i, v in ipairs(self.processing) do
		if v == beatmap then
			table.remove(self.processing, i)
			break
		end
	end

	if callback then
		callback()
	end
end)

return OsudirectModel
