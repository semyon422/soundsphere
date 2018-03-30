ncdk.NoteChart = {}
local NoteChart = ncdk.NoteChart

ncdk.NoteChart_metatable = {}
local NoteChart_metatable = ncdk.NoteChart_metatable
NoteChart_metatable.__index = NoteChart

NoteChart.new = function(self)
	local noteChart = {}
	
	noteChart.layerDataSequence = ncdk.LayerDataSequence:new()
	noteChart.layerDataSequence.noteChart = noteChart
	
	noteChart.inputMode = ncdk.InputMode:new()
	
	setmetatable(noteChart, NoteChart_metatable)
	
	return noteChart
end

NoteChart.import = function(self, noteChartString)
	local noteChartImporter = ncdk.NoteChartImporter:new()
	noteChartImporter.noteChart = self
	noteChartImporter:import(noteChartString)
end

NoteChart.export = function(self)
	local noteChartExporter = ncdk.NoteChartExporter:new()
	noteChartExporter.noteChart = self
	return noteChartExporter:export()
end

NoteChart.getLayerDataIndexIterator = function(self)
	return self.layerDataSequence:getLayerDataIndexIterator()
end

NoteChart.getInputIteraator = function(self)
	return self.layerDataSequence:getInputIteraator()
end

