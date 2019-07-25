local SearchManager = {}

SearchManager.search = function(self, list, searchTable)
	local foundList = {}
	for i = 1, #list do
		if self:check(list[i], searchTable) then
			foundList[#foundList + 1] = list[i]
		end
	end
	return foundList
end

SearchManager.check = function(self, chart, searchTable)
	local found = true
	for _, searchString in ipairs(searchTable) do
		local key, operator, value = searchString:match("^(.-)([=><~!]+)(.+)$")
		if key and self:checkFilter(chart, key, operator, value) or self:find(chart, searchString) then
			-- skip
		else
			found = false
		end
	end
	return found
end

SearchManager.find = function(self, chart, searchString)
	if
		chart.path and chart.path:lower():find(searchString, 1, true) or
		chart.hash and chart.hash:lower():find(searchString, 1, true) or
		chart.artist and chart.artist:lower():find(searchString, 1, true) or
		chart.title and chart.title:lower():find(searchString, 1, true) or
		chart.name and chart.name:lower():find(searchString, 1, true) or
		chart.source and chart.source:lower():find(searchString, 1, true) or
		chart.tags and chart.tags:lower():find(searchString, 1, true) or
		chart.creator and chart.creator:lower():find(searchString, 1, true) or
		chart.inputMode and chart.inputMode:lower():find(searchString, 1, true)
	then
		return true
	end
end

SearchManager.checkFilter = function(self, chart, key, operator, value)
	local value1 = tonumber(chart[key])
	local value2 = tonumber(value)
	
	if not value1 or not value2 then
		return
	end
	
	if operator == "=" then
		return value1 == value2
	elseif operator == ">" then
		return value1 > value2
	elseif operator == "<" then
		return value1 < value2
	elseif operator == ">=" then
		return value1 >= value2
	elseif operator == "<=" then
		return value1 <= value2
	elseif operator == "!=" or operator == "~=" then
		return value1 ~= value2
	end
end

return SearchManager
