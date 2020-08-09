local Class = require("aqua.util.Class")

local CollectionModel = Class:new()

CollectionModel.getPaths = function(self)
	local packPathsDict = {}
	for _, chartSetData in ipairs(self.cacheModel.cacheManager:getNoteChartSets()) do
		packPathsDict[chartSetData.path:match("^(.+)/.-$")] = true
	end

	local directoryItems = love.filesystem.getDirectoryItems("userdata/charts")
	for _, name in ipairs(directoryItems) do
		packPathsDict["userdata/charts/" .. name] = true
	end

	local packPaths = {}
	for path in pairs(packPathsDict) do
		packPaths[#packPaths + 1] = path
	end
	table.sort(packPaths)

	return packPaths
end

return CollectionModel
