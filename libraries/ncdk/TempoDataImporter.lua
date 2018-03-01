ncdk.TempoDataImporter = {}
local TempoDataImporter = ncdk.TempoDataImporter

ncdk.TempoDataImporter_metatable = {}
local TempoDataImporter_metatable = ncdk.TempoDataImporter_metatable
TempoDataImporter_metatable.__index = TempoDataImporter

TempoDataImporter.new = function(self, lineTable)
	local tempoDataImporter = {}
	
	tempoDataImporter.lineTable = lineTable
	
	setmetatable(tempoDataImporter, TempoDataImporter_metatable)
	
	return tempoDataImporter
end

TempoDataImporter.DataEnum = {
	measureTime = 3,
	tempo = 4
}

TempoDataImporter.getTempoData = function(self)
	local measureTime = ncdk.Fraction:new():fromString(self.lineTable[self.DataEnum.measureTime])
	local tempo = ncdk.Fraction:new():fromString(self.lineTable[self.DataEnum.tempo]):tonumber()
	
	return ncdk.TempoData:new(measureTime, tempo)
end