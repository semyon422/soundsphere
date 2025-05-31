local class = require("class")

---@class sphere.OffsetModel
---@operator call: sphere.OffsetModel
local OffsetModel = class()

---@param charts_repo sea.ChartsRepo
---@param configModel sphere.ConfigModel
function OffsetModel:new(configModel, charts_repo)
	self.configModel = configModel
	self.charts_repo = charts_repo
end

---@param hash string
---@param index integer
---@return number
---@return number
function OffsetModel:getInputVisual(hash, index)
	local charts_repo = self.charts_repo

	local chartmeta = assert(charts_repo:getChartmetaByHashIndex(hash, index))
	local chartmeta_user_data = charts_repo:getUserChartmetaUserData(hash, index, 1)

	local config = self.configModel.configs.settings
	local g = config.gameplay

	local audio_mode = config.audio.mode.primary

	local chart_offset = chartmeta_user_data and chartmeta_user_data.local_offset or 0
	local audio_mode_offset = g.offset_audio_mode[audio_mode] or 0
	local format_offset = g.offset_format[chartmeta.format] or 0

	local input_offset, visual_offset = 0, 0
	input_offset = g.offset.input + format_offset + audio_mode_offset + chart_offset
	visual_offset = g.offset.visual + format_offset + audio_mode_offset + chart_offset

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

return OffsetModel
