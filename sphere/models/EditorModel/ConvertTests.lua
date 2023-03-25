local ConvertAbsoluteToInterval = require("sphere.models.EditorModel.ConvertAbsoluteToInterval")
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

	assert(#ild.intervalDatas == 4)
	assert(ild.intervalDatas[1].beats == 4)
	assert(ild.intervalDatas[2].beats == 1)
	assert(ild.intervalDatas[3].beats == 4)
	assert(ild.intervalDatas[4].beats == 1)

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

	assert(#ild.intervalDatas == 3)  -- 0, 3.25, 3.5
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

	assert(#ild.intervalDatas == 3)
	assert(#ild.timePointList == 3)

	assert(ild.intervalDatas[1].beats == 0)
	assert(ild.intervalDatas[2].beats == 1)
	assert(ild.intervalDatas[3].beats == 1)
	assert(ild.intervalDatas[1]:start() == F(0))
	assert(ild.intervalDatas[2]:start() == F(1-1/16))
	assert(ild.intervalDatas[3]:start() == F(0))

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

-- do
-- 	local nc = NoteChart:new()
-- 	local ld = nc:getLayerData(1)
-- 	ld:setTimeMode("absolute")
-- 	ld:setSignatureMode("long")
-- 	ld:setPrimaryTempo(60)

-- 	ld:insertTempoData(0, 60)
-- 	ld:insertTempoData(1/16+0.002, 120)

-- 	local tp0 = ld:getTimePoint(0)
-- 	local tp1 = ld:getTimePoint(1/16+0.002)
-- 	local tp2 = ld:getTimePoint(1/16+0.001)

-- 	nc:compute()

-- 	local ild, tpm = ConvertAbsoluteToInterval(ld)

-- 	assert(#ild.intervalDatas == 2)
-- 	assert(#ild.timePointList == 2)

-- 	assert(ild.intervalDatas[1].beats == 1)
-- 	assert(ild.intervalDatas[2].beats == 1)
-- 	assert(ild.intervalDatas[1]:start() == F(0))
-- 	assert(ild.intervalDatas[2]:start() == F(0))
-- end


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

	-- assert(tpm[tp2].intervalData == ild.intervalDatas[1])
end

