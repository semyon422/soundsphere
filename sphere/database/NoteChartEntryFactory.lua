local NoteChartEntryFactory = {}

NoteChartEntryFactory.init = function(self)
end

NoteChartEntryFactory.splitList = function(self, paths)
	local dict = {}
	for _, path in ipairs(paths) do
		for i = 1, #self.formats do
			local pattern = self.formats[i][1]
			if path:find(pattern) then
				dict[pattern] = dict[pattern] or {}
				table.insert(dict[pattern], path)
			end
		end
	end
	
	local list = {}
	for _, data in pairs(dict) do
		list[#list + 1] = data
	end
	
	return list
end

NoteChartEntryFactory.getEntries = function(self, paths)
	local formats = self.formats
	
	local entries = {}
	for _, subPaths in ipairs(self:splitList(paths)) do
		local path = subPaths[1]
		for _, data in ipairs(formats) do
			local pattern = data[1]
			local getEntries = data[2]
			if path:lower():find(pattern) then
				for _, entry in ipairs(getEntries(self, subPaths)) do
					entries[#entries + 1] = entry
				end
			end
		end
	end
	
	return entries
end

NoteChartEntryFactory.getBMS = function(self, paths)
	local entries = {}
	
	for i = 1, #paths do
		entries[#entries + 1] = {
			path			= paths[i],
			hash			= nil,
			chartSetId		= nil,
			lastModified	= nil
		}
	end
	
	return entries
end

NoteChartEntryFactory.getO2Jam = function(self, paths)
	local entries = {}
	
	for i = 1, #paths do
		local path = paths[i]
		for j = 1, 3 do
			entries[#entries + 1] = {
				path			= path .. "/" .. j,
				hash			= nil,
				chartSetId		= nil,
				lastModified	= nil
			}
		end
	end
	
	return entries
end

NoteChartEntryFactory.formats = {
	{"%.osu$", NoteChartEntryFactory.getBMS},
	{"%.qua$", NoteChartEntryFactory.getBMS},
	{"%.bm[sel]$", NoteChartEntryFactory.getBMS},
	{"%.pms$", NoteChartEntryFactory.getBMS},
	{"%.ojn$", NoteChartEntryFactory.getO2Jam},
	{"%.ksh$", NoteChartEntryFactory.getBMS},
	{"%.sph$", NoteChartEntryFactory.getBMS}
}

return NoteChartEntryFactory
