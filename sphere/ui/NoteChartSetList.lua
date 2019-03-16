local CS = require("aqua.graphics.CS")
local Observable = require("aqua.util.Observable")
local CacheList = require("sphere.ui.CacheList")

local NoteChartSetList = CacheList:new()

NoteChartSetList.sender = "NoteChartSetList"

NoteChartSetList.x = 0.6
NoteChartSetList.y = 0
NoteChartSetList.w = 1 - NoteChartSetList.x
NoteChartSetList.h = 1
NoteChartSetList.buttonCount = 17
NoteChartSetList.middleOffset = 9
NoteChartSetList.startOffset = 9
NoteChartSetList.endOffset = 9

NoteChartSetList.observable = Observable:new()

NoteChartSetList.basePath = "userdata/charts"

NoteChartSetList.cs = CS:new({
	bx = 0,
	by = 0,
	rx = 0,
	ry = 0,
	binding = "all",
	baseOne = 768
})

NoteChartSetList.send = function(self, event)
	if event.action == "scrollStop" then
		self.NoteChartList:updateBackground()
	end
	
	CacheList.send(self, event)
end

NoteChartSetList.receive = function(self, event)
	CacheList.receive(self, event)
end

NoteChartSetList.selectRequest = [[
	SELECT * FROM `cache`
	WHERE `container` == 1 AND INSTR(`path`, ?) == 1
	ORDER BY `path`;
]]

return NoteChartSetList
