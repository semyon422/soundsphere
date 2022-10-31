local NoteChartExporter = require("osu.NoteChartExporter")
local NoteChartFactory = require("notechart.NoteChartFactory")

local function loadNoteChart(path, index)
	local status, noteCharts = assert(NoteChartFactory:getNoteCharts(
		path,
		love.filesystem.read(path),
		index or 1
	))
	if not status then
		error(noteCharts)
	end

	return noteCharts[1]
end

local function export(noteChart)
	local nce = NoteChartExporter:new()
	nce.noteChart = noteChart
	nce.noteChartDataEntry = noteChart.metaData:getTable()

	return nce:export()
end

local path = "userdata/testcharts"
return function()
	local files = love.filesystem.getDirectoryItems(path)

	for _, name in ipairs(files) do
		if not name:find("%.out$") then
			local noteChart = loadNoteChart(path .. "/" .. name)

			local out = path .. "/" .. name .. ".out"
			local tested = love.filesystem.read(out)
			local exported = export(noteChart)
			if tested then
				if tested ~= exported then
					love.filesystem.write(path .. "/" .. name .. ".new.out", exported)
					error(name)
				end
			else
				love.filesystem.write(out, exported)
			end
		end
	end
end

