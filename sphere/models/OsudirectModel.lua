local LibraryModel = require("sphere.models.LibraryModel")
local thread = require("aqua.thread")
local osudirect_urls = require("sphere.osudirect.urls")
local osudirect_parse = require("sphere.osudirect.parse")
local socket_url = require("socket.url")

local OsudirectModel = LibraryModel:new()

OsudirectModel.load = function(self)
	self.itemsCache.getObject = function(_, itemIndex)
		return setmetatable({}, {__index = function(t, k)
			local item = self.beatmapSets[itemIndex]
			if item then
				return item[k]
			end
		end})
	end
end

OsudirectModel.setBeatmap = function(self, beatmap)
	self.beatmap = beatmap
end

OsudirectModel.searchString = ""

OsudirectModel.setSearchString = function(self, s)
	self.searchString = s
end

local empty = {}
OsudirectModel.getDifficulties = function(self)
	local beatmap = self.beatmap
	return beatmap and beatmap.difficulties or empty
end

local asyncRequest = thread.async(function(url)
	local request = require("luajit-request")
	local response, code, err = request.send(url)
	if not response then
		return
	end
	return response.body, response.code
end)

OsudirectModel.search = thread.coro(function(self)
	local config = self.configModel.configs.online.osu
	local url = socket_url.absolute(config.web, osudirect_urls.search(self.searchString))
	local body = asyncRequest(url)
	if not body then
		return
	end
	local beatmaps, err = osudirect_parse(body)
	self.beatmapSets = beatmaps
	self.itemsCount = #beatmaps
end)

OsudirectModel.getBackgroundUrl = function(self)
	local config = self.configModel.configs.online.osu
	return socket_url.absolute(config.assets, osudirect_urls.cover(self.beatmap.setId, true))
end

OsudirectModel.getPreviewUrl = function(self)
	local config = self.configModel.configs.online.osu
	return socket_url.absolute(config.static, osudirect_urls.preview(self.beatmap.setId))
end

return OsudirectModel
