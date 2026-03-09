local class = require("class")
local valid = require("valid")
local path_util = require("path_util")
local digest = require("digest")

---@class notechart.ChartFactory
---@operator call: notechart.ChartFactory
local ChartFactory = class()

ChartFactory.extensions = {
	"osu",
	"sph",
	"ojn",
	"bms",
	"bme",
	"bml",
	"pms",
	"sm",
	"ssc",
	"qua",
	"mid",
	"midi",
	"ksh"
}

local ChartDecoders = {
	osu = require("osu.ChartDecoder"),
	sph = require("sph.ChartDecoder"),
	ojn = require("o2jam.ChartDecoder"),
	bms = require("bms.ChartDecoder"),
	bme = require("bms.ChartDecoder"),
	bml = require("bms.ChartDecoder"),
	pms = require("bms.PmsChartDecoder"),
	sm = require("stepmania.ChartDecoder"),
	ssc = require("stepmania.SscChartDecoder"),
	qua = require("quaver.ChartDecoder"),
	mid = require("midi.ChartDecoder"),
	midi = require("midi.ChartDecoder"),
	ksh = require("ksm.ChartDecoder"),
}

---@param filename string
---@return chartbase.IChartDecoder
function ChartFactory:getChartDecoder(filename)
	---@type chartbase.IChartDecoder
	local Decoder = assert(ChartDecoders[path_util.ext(filename, true)])
	return Decoder()
end

---@param filename string
---@param content string
---@param hash string?
---@return {chart: ncdk2.Chart, chartmeta: sea.Chartmeta}[]?
---@return string?
function ChartFactory:getCharts(filename, content, hash)
	hash = hash or digest.hash("md5", content, true)

	---@type chartbase.IChartDecoder
	local decoder = assert(ChartDecoders[path_util.ext(filename, true)], filename)()

	local status, chart_chartmetas = xpcall(decoder.decode, debug.traceback, decoder, content, hash)
	if not status then
		---@cast chart_chartmetas -table, +string
		return valid.format(nil, chart_chartmetas)
	end

	for _, t in ipairs(chart_chartmetas) do
		if t.chartmeta.hash ~= hash then
			return nil, "invalid hash"
		end
	end

	return chart_chartmetas
end

return ChartFactory
