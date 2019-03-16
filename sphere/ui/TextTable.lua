local Button = require("aqua.ui.Button")

local TextTable = Button:new()

TextTable.setTable = function(self, textTable)
	return self:setText(self:getTableText(textTable))
end

TextTable.getTableText = function(self, textTable)
	local lines = {}
	
	local columnWidth = {}
	for row = 1, #textTable do
		for col = 1, #textTable[row] do
			local text = tostring(textTable[row][col])
			columnWidth[col] = columnWidth[col] or 0
			if #text > columnWidth[col] then
				columnWidth[col] = #text
			end
		end
	end
	
	local formatStringTables = {}
	for row = 1, #textTable do
		formatStringTables[row] = formatStringTables[row] or {}
		for col = 1, #textTable[row] do
			formatStringTables[row][col] = "%" .. columnWidth[col] + 1 .. "s"
		end
	end
	
	for row = 1, #textTable do
		lines[#lines + 1] = (table.concat(formatStringTables[row])):format(unpack(textTable[row]))
	end
	
	return table.concat(lines)
end

return TextTable
