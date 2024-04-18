local class = require("class")
local NoteChartFactory = require("notechart.NoteChartFactory")

---@class sphere.ChartPreviewModel
---@operator call: sphere.ChartPreviewModel
local ChartPreviewModel = class()

---@param configModel sphere.ConfigModel
function ChartPreviewModel:new(configModel)
	self.configModel = configModel
end

function ChartPreviewModel:setChartview(chartview)
	print(chartview.real_path)

	local content = love.filesystem.read(chartview.location_path)
	if not content then
		return
	end

	local noteChart = assert(NoteChartFactory:getNoteChart(
		chartview.chartfile_name,
		content,
		chartview.index
	))


	-- local noteSkin = noteSkinModel:loadNoteSkin(tostring(noteChart.inputMode))
	-- noteSkin:loadData()
	-- noteSkin.editor = true
end

return ChartPreviewModel
