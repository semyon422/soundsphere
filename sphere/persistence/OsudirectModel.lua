local class = require("class")
local fs_util = require("fs_util")
local thread = require("thread")
local delay = require("delay")
local http_util = require("http_util")
local path_util = require("path_util")
local json = require("json")

---@class sphere.OsudirectModel
---@operator call: sphere.OsudirectModel
local OsudirectModel = class()

OsudirectModel.changed = false

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

---@param configModel sphere.ConfigModel
---@param cacheModel sphere.CacheModel
function OsudirectModel:new(configModel, cacheModel)
	self.configModel = configModel
	self.cacheModel = cacheModel
	self.statusBeatmap = {title = "LOADING", artist = ""}
	self.items = {self.statusBeatmap}
	self.processing = {}
	self.page = 1
	self.rankedStatus = "ranked"
end

function OsudirectModel:load()
	self.statusBeatmap = {title = "LOADING", artist = ""}
	self.items = {self.statusBeatmap}
	self.processing = {}
	self.page = 1
	self.rankedStatus = "ranked"
end

---@param status string
function OsudirectModel:setRankedStatus(status)
	self.rankedStatus = status
	self.page = 1
	self.items = {self.statusBeatmap}
	self:searchNoDebounce()
end

function OsudirectModel:update()
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

---@return boolean
function OsudirectModel:isChanged()
	local changed = self.changed
	self.changed = false
	return changed
end

---@param beatmap table
function OsudirectModel:setBeatmap(beatmap)
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

---@param s string
function OsudirectModel:setSearchString(s)
	self.searchString = s
	self:searchDebounce()
end

local empty = {}

---@return table
function OsudirectModel:getDifficulties()
	local beatmap = self.beatmap
	return beatmap and beatmap.beatmaps or empty
end

local requestAsync = thread.async(function(url)
	local http = require("http")
	return http.request(url)
end)

function OsudirectModel:searchDebounce()
	delay.debounce(self, "loadDebounce", 0.1, self.search, self)
end

function OsudirectModel:searchNoDebounce()
	coroutine.wrap(function()
		self:search()
	end)()
end

---@return nil?
function OsudirectModel:search()
	self.statusBeatmap.title = "LOADING"
	self.items = {self.statusBeatmap}
	self.page = 0

	local searchString = self.searchString
	self:searchNext()
	if searchString ~= self.searchString then
		return self:search()
	end
end

---@param searchString string
---@param page number
---@return table?
function OsudirectModel:searchRequest(searchString, page)
	local config = self.configModel.configs.urls.osu
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

	for _, set in ipairs(err) do
		for i, diff in ipairs(set.beatmaps) do
			diff.beatmapset = set
		end
	end

	return err
end

---@param beatmaps table
---@return table
function OsudirectModel:getExistingHashes(beatmaps)
	local hashes = {}
	for _, beatmap in ipairs(beatmaps) do
		table.insert(hashes, beatmap.beatmaps[1].checksum)
	end
	local foundCharts = self.cacheModel.chartfilesRepo:getChartfilesByHashes(hashes)
	local foundHashes = {}
	for _, chart in ipairs(foundCharts) do
		foundHashes[chart.hash] = true
	end
	return foundHashes
end

function OsudirectModel:searchNext()
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

	local hashes = self:getExistingHashes(beatmaps)

	for _, beatmap in ipairs(beatmaps) do
		for _, b in ipairs(beatmap.beatmaps) do
			if hashes[b.checksum] then
				beatmap.downloaded = true
			end
		end
		table.insert(self.items, beatmap)
	end

	self.statusBeatmap.title = "LOAD MORE"
	table.insert(self.items, self.statusBeatmap)

	self:setBeatmap(self.items[newPos])
end

---@return string
function OsudirectModel:getBackgroundUrl()
	local config = self.configModel.configs.urls.osu
	return config.background:format(self.beatmap.id)
end

---@return string
function OsudirectModel:getPreviewUrl()
	local config = self.configModel.configs.urls.osu
	return config.preview:format(self.beatmap.id)
end

OsudirectModel.downloadBeatmapSet = thread.coro(function(self, beatmap, callback)
	if not beatmap or beatmap == self.statusBeatmap then
		return
	end

	local location = self.cacheModel.locationsRepo:selectLocationById(1)

	table.insert(self.processing, 1, beatmap)

	local config = self.configModel.configs.urls.osu
	local url = config.download:format(beatmap.id)
	beatmap.url = url

	print(("Downloading: %s"):format(url))
	beatmap.status = "Downloading"

	beatmap.isDownloading = true
	local data, code, headers, status_line = fs_util.downloadAsync(url)
	beatmap.isDownloading = false

	if not data then
		beatmap.status = status_line
		return
	end

	local filename = url:match("^.+/(.-)$")
	for header, value in pairs(headers) do
		header = header:lower()
		if header == "content-disposition" then
			local cd = http_util.parse_content_disposition(value)
			filename = cd.filename or filename
		end
	end

	filename = path_util.fix_illegal(filename)

	print(("Downloaded: %s"):format(filename))
	if not filename:find("%.osz$") then
		beatmap.status = "Unsupported file type"
		print("Unsupported file type")
		return
	end

	local filedata = love.filesystem.newFileData(data, filename)

	local location_path = path_util.join("downloads", filename:match("^(.+)%.osz$"))
	local extractPath = path_util.join(location.path, location_path)
	print("Extracting")
	beatmap.status = "Extracting"
	local extracted, err = fs_util.extractAsync(filedata, extractPath)
	if not extracted then
		beatmap.status = err or "Extracting error"
		return
	end
	print(("Extracted to: %s"):format(extractPath))

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
