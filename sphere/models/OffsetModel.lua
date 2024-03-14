local class = require("class")

---@class sphere.OffsetModel
---@operator call: sphere.OffsetModel
local OffsetModel = class()

---@param configModel sphere.ConfigModel
---@param selectModel sphere.SelectModel
function OffsetModel:new(configModel, selectModel)
	self.configModel = configModel
	self.selectModel = selectModel
end

---@return number
---@return number
function OffsetModel:getInputVisual()
	local chartview = self.selectModel.chartview
	local config = self.configModel.configs.settings
	local g = config.gameplay

	local audio_mode = config.audio.mode.primary

	local chart_offset = chartview.offset
	local audio_mode_offset = g.offset_audio_mode[audio_mode] or 0
	local format_offset = g.offset_format[chartview.format] or 0

	local input_offset, visual_offset
	if chart_offset then
		input_offset = chart_offset + audio_mode_offset
		visual_offset = g.offset.visual - g.offset.input + input_offset
	else
		input_offset = g.offset.input + format_offset + audio_mode_offset
		visual_offset = g.offset.visual + format_offset + audio_mode_offset
	end

	print("resulting offsets: " .. input_offset .. ", " .. visual_offset)

	-- local baseTimeRate = rhythmModel.timeEngine.baseTimeRate
	-- if config.gameplay.offsetScale.input then
	-- 	input_offset = input_offset * baseTimeRate
	-- end
	-- if config.gameplay.offsetScale.visual then
	-- 	visual_offset = visual_offset * baseTimeRate
	-- end

	return input_offset, visual_offset
end

function OffsetModel:getDefaultLocal()
	local chartview = self.selectModel.chartview
	local config = self.configModel.configs.settings
	local g = config.gameplay
	local format_offset = g.offset_format[chartview.format] or 0
	return g.offset.input + format_offset
end

return OffsetModel
