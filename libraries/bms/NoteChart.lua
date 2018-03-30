bms.NoteChart = {}
local NoteChart = bms.NoteChart

bms.NoteChart_metatable = {}
local NoteChart_metatable = bms.NoteChart_metatable
NoteChart_metatable.__index = NoteChart

setmetatable(NoteChart, ncdk.NoteChart_metatable)

NoteChart.new = function(self)
	local noteChart = {}
	
	noteChart.layerDataSequence = ncdk.LayerDataSequence:new()
	noteChart.layerDataSequence.noteChart = noteChart
	
	noteChart.inputMode = ncdk.InputMode:new()
	
	setmetatable(noteChart, NoteChart_metatable)
	
	return noteChart
end

NoteChart.import = function(self, noteChartString)
	local noteChartImporter = bms.NoteChartImporter:new()
	noteChartImporter.noteChart = self
	noteChartImporter:import(noteChartString)
end

NoteChart.export = function(self)
	local noteChartExporter = bms.NoteChartExporter:new()
	noteChartExporter.noteChart = self
	return noteChartExporter:export()
end