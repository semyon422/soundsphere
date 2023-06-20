local ConvertAbsoluteToInterval = require("sphere.models.EditorModel.ConvertAbsoluteToInterval")
local ConvertMeasureToInterval = require("sphere.models.EditorModel.ConvertMeasureToInterval")
local NoteChart = require("ncdk.NoteChart")
local Fraction = require("ncdk.Fraction")

local function F(n)
	return Fraction:new(n, 1000, false)
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("absolute")
	ld:setSignatureMode("long")
	ld:setPrimaryTempo(60)

	ld:insertTempoData(0, 60)

	local tp0 = ld:getTimePoint(0)
	local tp1 = ld:getTimePoint(4)

	nc:compute()

	assert(tp0.absoluteTime == 0)
	assert(tp1.absoluteTime == 4)

	local ild, tpm = ConvertAbsoluteToInterval(ld)

	assert(#ild.intervalDatas == 2)
	assert(ild.intervalDatas[1].beats == 4)
	assert(ild.intervalDatas[2].beats == 1)

	assert(tpm[tp1].time == F(0))
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("absolute")
	ld:setSignatureMode("long")
	ld:setPrimaryTempo(60)

	ld:insertTempoData(0, 60)

	local tp0 = ld:getTimePoint(0)
	local tp1 = ld:getTimePoint(3.5)

	nc:compute()

	assert(tp0.absoluteTime == 0)
	assert(tp1.absoluteTime == 3.5)

	local ild, tpm = ConvertAbsoluteToInterval(ld)

	assert(#ild.intervalDatas == 2)
	assert(ild.intervalDatas[1].beats == 4)
	assert(ild.intervalDatas[2].beats == 1)

	assert(tpm[tp1].time == F(3.5))
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("absolute")
	ld:setSignatureMode("long")
	ld:setPrimaryTempo(60)

	ld:insertTempoData(0, 60)
	ld:insertTempoData(4, 120)

	local tp0 = ld:getTimePoint(0)
	local tp1 = ld:getTimePoint(4)
	local tp2 = ld:getTimePoint(6)
	local tp3 = ld:getTimePoint(0.5)

	nc:compute()

	assert(tp0.absoluteTime == 0)
	assert(tp1.absoluteTime == 4)
	assert(tp2.absoluteTime == 6)
	assert(tp3.absoluteTime == 0.5)

	local ild, tpm = ConvertAbsoluteToInterval(ld)

	assert(#ild.intervalDatas == 3)
	assert(ild.intervalDatas[1].beats == 4)
	assert(ild.intervalDatas[2].beats == 4)
	assert(ild.intervalDatas[3].beats == 1)

	assert(tpm[tp3].time == F(0.5))
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("absolute")
	ld:setSignatureMode("long")
	ld:setPrimaryTempo(60)

	ld:insertTempoData(0, 60)
	ld:insertTempoData(3.5, 120)

	local tp0 = ld:getTimePoint(0)
	local tp1 = ld:getTimePoint(3.5)

	nc:compute()

	local ild, tpm = ConvertAbsoluteToInterval(ld)

	assert(#ild.intervalDatas == 2)  -- 0, 3.5 (no tps between)
	assert(ild.intervalDatas[1].beats == 1)
	assert(ild.intervalDatas[2].beats == 1)
	assert(ild.intervalDatas[1]:start() == F(0))
	assert(ild.intervalDatas[2]:start() == F(0))
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("absolute")
	ld:setSignatureMode("long")
	ld:setPrimaryTempo(60)

	ld:insertTempoData(0, 60)
	ld:insertTempoData(3.5, 120)

	local tp0 = ld:getTimePoint(0)
	local tp1 = ld:getTimePoint(3.5)
	local tp2 = ld:getTimePoint(3.25)

	nc:compute()

	local ild, tpm = ConvertAbsoluteToInterval(ld)

	assert(#ild.intervalDatas == 3)
	assert(ild.intervalDatas[1].beats == 3)
	assert(ild.intervalDatas[2].beats == 1)
	assert(ild.intervalDatas[3].beats == 1)
	assert(ild.intervalDatas[1]:start() == F(0))
	assert(ild.intervalDatas[2]:start() == F(0.5 - 1/16))
	assert(ild.intervalDatas[3]:start() == F(0))
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("absolute")
	ld:setSignatureMode("long")
	ld:setPrimaryTempo(60)

	ld:insertTempoData(0, 60)
	ld:insertTempoData(0.5, 120)

	local tp0 = ld:getTimePoint(0)
	local tp1 = ld:getTimePoint(0.5)
	local tp2 = ld:getTimePoint(0.25)

	nc:compute()

	local ild, tpm = ConvertAbsoluteToInterval(ld)

	assert(#ild.intervalDatas == 3)  -- 0, 0.25, 0.5
	assert(ild.intervalDatas[1].beats == 0)
	assert(ild.intervalDatas[2].beats == 1)
	assert(ild.intervalDatas[3].beats == 1)
	assert(ild.intervalDatas[1]:start() == F(0))
	assert(ild.intervalDatas[2]:start() == F(0.5 - 1/16))
	assert(ild.intervalDatas[3]:start() == F(0))
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("absolute")
	ld:setSignatureMode("long")
	ld:setPrimaryTempo(60)

	ld:insertTempoData(0, 60)
	ld:insertTempoData(0.5, 120)

	local tp0 = ld:getTimePoint(0)
	local tp1 = ld:getTimePoint(0.5)
	local tp2 = ld:getTimePoint(0.499999)

	nc:compute()

	local ild, tpm = ConvertAbsoluteToInterval(ld)

	assert(#ild.intervalDatas == 2)
	assert(ild.intervalDatas[1].beats == 1)
	assert(ild.intervalDatas[2].beats == 1)
	assert(ild.intervalDatas[1]:start() == F(0))
	assert(ild.intervalDatas[2]:start() == F(0))
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("absolute")
	ld:setSignatureMode("long")
	ld:setPrimaryTempo(60)

	ld:insertTempoData(0, 60)
	ld:insertTempoData(0.99999, 120)

	local tp0 = ld:getTimePoint(0)
	local tp1 = ld:getTimePoint(0.99999)
	local tp2 = ld:getTimePoint(0.99998)

	nc:compute()

	local ild, tpm = ConvertAbsoluteToInterval(ld)

	assert(#ild.intervalDatas == 2)
	assert(#ild.timePointList == 2)

	assert(ild.intervalDatas[1].beats == 1)
	assert(ild.intervalDatas[2].beats == 1)
	assert(ild.intervalDatas[1]:start() == F(0))
	assert(ild.intervalDatas[2]:start() == F(0))

	assert(tpm[tp2].intervalData == ild.intervalDatas[2])
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("absolute")
	ld:setSignatureMode("long")
	ld:setPrimaryTempo(60)

	ld:insertTempoData(0, 60)
	ld:insertTempoData(0.99999, 120)

	local tp0 = ld:getTimePoint(0)
	local tp1 = ld:getTimePoint(0.99999)
	local tp2 = ld:getTimePoint(0.00001)

	nc:compute()

	local ild, tpm = ConvertAbsoluteToInterval(ld)

	assert(#ild.intervalDatas == 2)
	assert(#ild.timePointList == 2)

	assert(ild.intervalDatas[1].beats == 1)
	assert(ild.intervalDatas[2].beats == 1)
	assert(ild.intervalDatas[1]:start() == F(0))
	assert(ild.intervalDatas[2]:start() == F(0))

	assert(tpm[tp2].intervalData == ild.intervalDatas[1])
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("absolute")
	ld:setSignatureMode("long")
	ld:setPrimaryTempo(60)

	ld:insertTempoData(0, 60)
	ld:insertTempoData(0.002, 120)

	local tp0 = ld:getTimePoint(0)
	local tp1 = ld:getTimePoint(0.002)
	local tp2 = ld:getTimePoint(0.001)

	nc:compute()

	local ild, tpm = ConvertAbsoluteToInterval(ld)

	assert(#ild.intervalDatas == 2)
	assert(#ild.timePointList == 2)

	assert(ild.intervalDatas[1].beats == 1)
	assert(ild.intervalDatas[2].beats == 1)
	assert(ild.intervalDatas[1]:start() == F(0))
	assert(ild.intervalDatas[2]:start() == F(0))

	assert(tpm[tp2].intervalData == ild.intervalDatas[1])
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("absolute")
	ld:setSignatureMode("long")
	ld:setPrimaryTempo(60)

	ld:insertTempoData(0, 60)
	ld:insertTempoData(0.5, 120)

	local tp0 = ld:getTimePoint(0)
	local tp1 = ld:getTimePoint(0.5)
	local tp2 = ld:getTimePoint(0, 1)

	nc:compute()

	local ild, tpm = ConvertAbsoluteToInterval(ld)

	assert(#ild.intervalDatas == 2)
	assert(#ild.timePointList == 3)

	assert(ild.intervalDatas[1].beats == 1)
	assert(ild.intervalDatas[2].beats == 1)
	assert(ild.intervalDatas[1]:start() == F(0))
	assert(ild.intervalDatas[2]:start() == F(0))
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("absolute")
	ld:setSignatureMode("long")
	ld:setPrimaryTempo(60)

	ld:insertTempoData(0.146, 60000 / 788.39252234492)
	ld:insertTempoData(22.221, 60000 / 689.48892265437)
	ld:insertTempoData(44.285, 60000 / 689.75422887858)

	local tp0 = ld:getTimePoint(42.906)
	local tp1 = ld:getTimePoint(0.935)

	nc:compute()

	local ild, tpm = ConvertAbsoluteToInterval(ld)

	assert(#ild.intervalDatas == 3)
	assert(ild.intervalDatas[1].beats == 28)
	assert(ild.intervalDatas[2].beats == 32)
	assert(ild.intervalDatas[3].beats == 1)
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("absolute")
	ld:setSignatureMode("long")
	ld:setPrimaryTempo(60)

	ld:insertTempoData(0, 60)
	ld:insertTempoData(0.01, 60)
	ld:insertTempoData(0.02, 60)
	ld:insertTempoData(0.03, 60)

	local tp0 = ld:getTimePoint(0.005)

	nc:compute()

	local ild, tpm = ConvertAbsoluteToInterval(ld)
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("absolute")
	ld:setSignatureMode("long")
	ld:setPrimaryTempo(60)

	ld:insertTempoData(91.633, 60 / 0.006)
	ld:insertTempoData(91.633 + 0.002, 60)

	local tp0 = ld:getTimePoint(91.633 + 0.001)

	nc:compute()

	local ild, tpm = ConvertAbsoluteToInterval(ld)
end

--------------------------------------------------------------------------------

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("measure")
	ld:setSignatureMode("long")
	ld:setPrimaryTempo(60)

	ld:insertTempoData(F(0), 60)
	ld:insertTempoData(F(1), 120)

	local tp0 = ld:getTimePoint(F(0))
	local tp1 = ld:getTimePoint(F(1))
	local tp2 = ld:getTimePoint(F(2))
	local tp3 = ld:getTimePoint(F(0.5))

	nc:compute()

	assert(tp0.absoluteTime == 0)
	assert(tp1.absoluteTime == 4)
	assert(tp2.absoluteTime == 6)
	assert(tp3.absoluteTime == 2)

	local ild, tpm = ConvertMeasureToInterval(ld)

	assert(#ild.intervalDatas == 3)
	assert(ild.intervalDatas[1].beats == 4)
	assert(ild.intervalDatas[2].beats == 4)
	assert(ild.intervalDatas[3].beats == 1)

	assert(tpm[tp3].time == F(2))
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("measure")
	ld:setSignatureMode("long")
	ld:setPrimaryTempo(60)

	ld:insertTempoData(F(0), 60)
	ld:insertTempoData(F(1), 120)

	ld:setSignature(0, F(9/8))
	ld:setSignature(1, F(1))

	local tp0 = ld:getTimePoint(F(0))
	local tp1 = ld:getTimePoint(F(1))
	local tp2 = ld:getTimePoint(F(2))
	local tp3 = ld:getTimePoint(F(0.5))

	nc:compute()

	assert(tp0.absoluteTime == 0)
	assert(tp1.absoluteTime == 9 / 8)
	assert(tp2.absoluteTime == 9 / 8 + 0.5)
	assert(tp3.absoluteTime == 9 / 16)

	local ild, tpm = ConvertMeasureToInterval(ld)

	assert(#ild.intervalDatas == 3)
	assert(ild.intervalDatas[1].beats == 1)
	assert(ild.intervalDatas[2].beats == 1)
	assert(ild.intervalDatas[3].beats == 1)

	assert(tpm[tp3].time == F(9/16))
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("measure")
	ld:setSignatureMode("long")
	ld:setPrimaryTempo(60)

	ld:insertTempoData(F(0), 60)
	ld:insertTempoData(F(1), 120)

	ld:insertStopData(F(0.5), F(1))

	local tp0 = ld:getTimePoint(F(0))
	local tp1 = ld:getTimePoint(F(1))
	local tp2 = ld:getTimePoint(F(2))
	local tp3 = ld:getTimePoint(F(0.5))
	local tp4 = ld:getTimePoint(F(0.5), 1)

	nc:compute()

	assert(tp0.absoluteTime == 0)
	assert(tp1.absoluteTime == 5)
	assert(tp2.absoluteTime == 7)
	assert(tp3.absoluteTime == 2)
	assert(tp4.absoluteTime == 3)

	local ild, tpm = ConvertMeasureToInterval(ld)

	assert(#ild.intervalDatas == 3)
	assert(ild.intervalDatas[1].beats == 5)
	assert(ild.intervalDatas[2].beats == 4)
	assert(ild.intervalDatas[3].beats == 1)

	assert(tpm[tp3].time == F(2))
	assert(tpm[tp4].time == F(3))
end
