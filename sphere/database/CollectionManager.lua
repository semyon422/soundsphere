local Cache = require("sphere.database.Cache")

local CollectionManager = {}

CollectionManager.getPaths = function(self)
	local packPathsDict = {}
	for _, chartSetData in ipairs(Cache.chartSetList) do
		packPathsDict[chartSetData.path:match("^(.+)/.-$")] = true
	end
	
	local packPaths = {}
	for path in pairs(packPathsDict) do
		packPaths[#packPaths + 1] = path
	end
	table.sort(packPaths)
	
	return packPaths
end

return CollectionManager
