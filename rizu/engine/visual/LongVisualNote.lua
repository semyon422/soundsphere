local VisualNote = require("rizu.engine.visual.VisualNote")
local Point = require("ncdk2.tp.Point")
local VisualPoint = require("ncdk2.visual.VisualPoint")

---@class rizu.LongVisualNote: rizu.VisualNote
---@operator call: rizu.LongVisualNote
local LongVisualNote = VisualNote + {}

function LongVisualNote:initHold()
	if self.hold_index then
		return
	end

	local vp = self.linked_note.startNote.visualPoint
	local hold_p = Point(vp.point.absoluteTime)
	local hold_vp = VisualPoint(hold_p)
	hold_vp.visualTime = vp.visualTime

	self.hold_p = hold_p
	self.hold_vp = hold_vp
	self.hold_index = 1
end

function LongVisualNote:update()
	local visual_info = self.visual_info

	self:initHold()

	local end_visual_time = self:getVisualTime(self.linked_note.endNote.visualPoint)

	local time = visual_info.time
	local rate = visual_info.rate
	local visual_offset = visual_info.visual_offset

	local hold_visual_time = self:getHoldVisualTime()
	self.start_dt = (time - hold_visual_time - visual_offset) * rate

	hold_visual_time = math.max(hold_visual_time, end_visual_time + visual_info.shortening)
	self.end_dt = (time - hold_visual_time - visual_offset) * rate
end

---@param time number
function LongVisualNote:clampAbsoluteTime(time)
	local linked_note = self.linked_note
	local visual_info = self.visual_info
	return math.min(math.max(time, linked_note:getStartTime()), linked_note:getEndTime() + visual_info.shortening)
end

---@return number
function LongVisualNote:getHoldVisualTime()
	local visual_info = self.visual_info
	local cvp = self.cvp
	local hold_vp = self.hold_vp
	local hold_p = self.hold_p

	local state = self:getState()
	if state ~= "startPassedPressed" and state ~= "endPassed" then
		return self:getVisualTime(hold_vp)
	end

	-- Important: `cvp.point.absoluteTime` must be equal `time - input_offset`
	local offset = visual_info.visual_offset - visual_info.input_offset

	if visual_info.const then
		local time = cvp.point.absoluteTime - offset
		hold_vp.point.absoluteTime = self:clampAbsoluteTime(time)
		return hold_vp.point.absoluteTime
	end

	local interpolator = self.visual.interpolator
	local points = self.visual.points

	hold_vp.visualTime = cvp.visualTime - offset
	self.hold_index = interpolator:interpolate(points, self.hold_index, hold_vp, "visual")

	hold_p.absoluteTime = self:clampAbsoluteTime(hold_p.absoluteTime)
	self.hold_index = interpolator:interpolate(points, self.hold_index, hold_vp, "absolute")

	return hold_vp:getVisualTime(cvp)
end

LongVisualNote.__lt = VisualNote.__lt

return LongVisualNote
