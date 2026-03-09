local class = require("class")
local Fraction = require("ncdk.Fraction")
local Line = require("sph.lines.Line")

---@class sph.ProtoLine
---@field globalTime ncdk.Fraction
---@field comment string?
---@field same true?
---@field visual string?
---@field measure ncdk.Fraction?
---@field sounds integer[]?
---@field volume integer[]?
---@field velocity number[]?
---@field expand number?
---@field notes sph.LineNote[]?
---@field offset number?

---@class sph.SphLines
---@operator call: sph.SphLines
local SphLines = class()

function SphLines:new()
	---@type sph.ProtoLine[]
	self.protoLines = {}
	self.beatOffset = -1
	self.lineTime = {0, 1}
end

---@param lines sph.Line[]
function SphLines:decode(lines)
	for _, line in ipairs(lines) do
		self:decodeLine(line)
	end
	self:recalcGlobalTime()
end

---@param line sph.Line
function SphLines:decodeLine(line)
	local pline = {}
	---@cast pline sph.ProtoLine

	pline.comment = line.comment
	local offset = line.offset

	---@type ncdk.Fraction?
	local lineTime
	if line.time then
		lineTime = line.time
		self.lineTime = lineTime
	end

	local same = line.same

	pline.same = line.same
	pline.visual = line.visual
	pline.measure = line.measure
	pline.sounds = line.sounds
	pline.volume = line.volume
	pline.velocity = line.velocity
	pline.expand = line.expand

	if not lineTime and not same then
		self.beatOffset = self.beatOffset + 1
		self.lineTime = nil
	end

	pline.notes = line.notes

	if not offset and not next(pline) then
		return
	end

	pline.offset = offset
	pline.globalTime = Fraction(self.beatOffset) + self.lineTime

	table.insert(self.protoLines, pline)
end

function SphLines:recalcGlobalTime()
	---@type integer?
	local offset
	for _, pline in ipairs(self.protoLines) do
		if pline.offset then
			offset = pline.globalTime:floor()
			break
		end
	end
	if not offset then
		return
	end
	for _, pline in ipairs(self.protoLines) do
		pline.globalTime = pline.globalTime - offset
	end
end

---@return sph.Line[]
function SphLines:encode()
	local protoLines = self.protoLines

	---@type sph.Line[]
	local lines = {}

	local plineIndex = 1
	local pline = protoLines[plineIndex]

	local currentTime = pline.globalTime
	local prevTime = nil
	while pline do
		local targetTime = Fraction(currentTime:floor() + 1)
		if pline.globalTime < targetTime then
			targetTime = pline.globalTime
		end
		local isAtTimePoint = pline.globalTime == targetTime

		if isAtTimePoint then
			local hasPayload =
				pline.notes or
				pline.expand or
				pline.offset or
				pline.velocity or
				pline.measure

			local isNextTime = pline.globalTime ~= prevTime
			if isNextTime then
				prevTime = pline.globalTime
			end

			local same = not isNextTime

			local line_time = pline.globalTime % 1

			local line = Line()

			if not pline.same then
				if pline.offset then
					line.offset = pline.offset
				end
				if line_time[1] ~= 0 then
					line.time = pline.globalTime % 1
				end
			else
				line.same = true
			end
			line.visual = pline.visual
			line.expand = pline.expand
			line.velocity = pline.velocity
			line.measure = pline.measure
			line.comment = pline.comment
			if pline.sounds and next(pline.sounds) then
				line.sounds = pline.sounds
			end
			if pline.volume and next(pline.volume) then
				line.volume = pline.volume
			end
			if pline.notes and next(pline.notes) then
				line.notes = pline.notes
			end

			if hasPayload or line_time[1] == 0 and not same then
				table.insert(lines, line)
			end

			plineIndex = plineIndex + 1
			pline = protoLines[plineIndex]
		else
			table.insert(lines, {})
		end
		currentTime = targetTime
	end

	return lines
end

return SphLines
