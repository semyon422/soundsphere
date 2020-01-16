local NoteChartEntryFactory = {}

NoteChartEntryFactory.init = function(self)
end

NoteChartEntryFactory.splitList = function(self, fileDatas)
	local dict = {}

	for _, fileData in ipairs(fileDatas) do
		for i = 1, #self.formats do
			local pattern = self.formats[i][1]
			if fileData.path:find(pattern) then
				dict[pattern] = dict[pattern] or {}
				table.insert(dict[pattern], fileData)
			end
		end
	end
	
	local list = {}
	for _, fileData in pairs(dict) do
		list[#list + 1] = fileData
	end
	
	return list
end

NoteChartEntryFactory.getEntries = function(self, fileDatas)
	local formats = self.formats
	
	local entries = {}
	for _, subFileDatas in ipairs(self:splitList(fileDatas)) do
		local path = subFileDatas[1].path
		for _, data in ipairs(formats) do
			local pattern = data[1]
			local getEntries = data[2]
			if path:lower():find(pattern) then
				for _, entry in ipairs(getEntries(self, subFileDatas)) do
					entries[#entries + 1] = entry
				end
			end
		end
	end
	
	return entries
end

--[[
	fileDatas = {
		{
			path = "path/to/chart.bms"
		}
	}
]]
NoteChartEntryFactory.getBMS = function(self, fileDatas)
	local entries = {}
	
	for i = 1, #fileDatas do
		local fileData = fileDatas[i]
		entries[#entries + 1] = {
			path			= fileData.path,
			hash			= fileData.hash,
			setId			= fileData.setId,
			lastModified	= fileData.lastModified
		}
	end
	
	return entries
end

--[[
	fileDatas = {
		{
			path = "path/to/chart.ojn"
		}
	}
]]
NoteChartEntryFactory.getO2Jam = function(self, fileDatas)
	local entries = {}
	
	for i = 1, #fileDatas do
		local fileData = fileDatas[i]
		local path = fileData.path
		for j = 1, 3 do
			entries[#entries + 1] = {
				path			= path .. "/" .. j,
				hash			= fileData.hash,
				setId			= fileData.setId,
				lastModified	= fileData.lastModified
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
