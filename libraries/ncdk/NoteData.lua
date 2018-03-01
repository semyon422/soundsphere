ncdk.NoteData = {}
local NoteData = ncdk.NoteData

ncdk.NoteData_metatable = {}
local NoteData_metatable = ncdk.NoteData_metatable
NoteData_metatable.__index = NoteData

NoteData.new = function(self, startTimePoint, endTimePoint)
	local noteData = {}
	
	noteData.startTimePoint = startTimePoint
	noteData.endTimePoint = endTimePoint
	
	setmetatable(noteData, NoteData_metatable)
	
	return noteData
end