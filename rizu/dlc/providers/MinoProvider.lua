local class = require("class")
local http_util = require("web.http.util")
local json = require("json")

---@class rizu.dlc.providers.MinoProvider: rizu.dlc.IDlcProvider
---@operator call: rizu.dlc.providers.MinoProvider
local MinoProvider = class()

function MinoProvider:new(config)
	self.config = config or {
		search = "https://catboy.best/api/v2/search",
		download = "https://catboy.best/d/%s",
	}
	if self.config.download and self.config.download:find("%%s") == nil then
		-- Ensure download URL has %s
		if self.config.download:sub(-1) ~= "/" then
			self.config.download = self.config.download .. "/"
		end
		self.config.download = self.config.download .. "%s"
	end
	self.rankedStatusesMap = {
		any = -3,
		graveyard = -2,
		wip = -1,
		pending = 0,
		ranked = 1,
		qualified = 3,
		loved = 4,
	}
end

---@param query string
---@param filters table?
---@return table[]? results, string? error
function MinoProvider:search(query, filters)
	filters = filters or {}
	local page = filters.page or 1
	local status = filters.status or "ranked"

	local url = self.config.search .. "?" .. http_util.encode_query_string({
		query = query,
		mode = 3,
		offset = (page - 1) * 100,
		status = self.rankedStatusesMap[status] or 1,
		amount = 100,
	})

	print("[MinoProvider] Requesting URL:", url)
	local res, err = http_util.request(url)

	if not res then
		return nil, err or "HTTP request failed"
	end

	local body = res.body
	local ok, data = pcall(json.decode, body)
	if not ok then
		return nil, "Failed to decode JSON response"
	end

	local results = {}
	for _, set in ipairs(data) do
		table.insert(results, {
			id = set.id,
			title = set.title,
			artist = set.artist,
			creator = set.creator,
			source = set.source,
			tags = set.tags,
			status = set.status,
			difficulties = set.beatmaps,
			has_video = set.video,
			has_storyboard = set.storyboard,
			thumbnail_url = self:getThumbnailUrl(set.id),
		})
	end

	return results
end

---@param id string|number
---@return string? url, string? error
function MinoProvider:getDownloadUrl(id)
	return self.config.download:format(id)
end

---@param id string|number
---@return string? url, string? error
function MinoProvider:getThumbnailUrl(id)
	return ("https://assets.ppy.sh/beatmaps/%s/covers/card.jpg"):format(id)
end

return MinoProvider
