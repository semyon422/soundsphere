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

OsudirectModel.searchString = ""

OsudirectModel.setSearchString = function(self, s)
	self.searchString = s
end

local asyncRequest = thread.async(function(url)
	local request = require("luajit-request")
	local response, code, err = request.send(url)
	assert(response, err)
	return response.body, response.code
end)

OsudirectModel.search = thread.coro(function(self)
	local config = self.configModel.configs.online.osu
	local url = socket_url.absolute(config.web, osudirect_urls.search(self.searchString))
	local body = asyncRequest(url)
	local beatmaps, err = osudirect_parse(body)
	self.beatmapSets = beatmaps
	self.itemsCount = #beatmaps
	print(#self.items)
end)

OsudirectModel.updateItems = function(self)
	self:search()
end

OsudirectModel.getItemIndex = function(self, noteChartDataId, noteChartId, noteChartSetId)
	return 1
end

return OsudirectModel
