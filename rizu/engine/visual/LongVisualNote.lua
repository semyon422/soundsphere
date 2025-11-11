local math_util = require("math_util")
local VisualNote = require("rizu.engine.visual.VisualNote")
local Point = require("ncdk2.tp.Point")
local VisualPoint = require("ncdk2.visual.VisualPoint")

---@class rizu.LongVisualNote: rizu.VisualNote
---@operator call: rizu.LongVisualNote
local LongVisualNote = VisualNote + {}

LongVisualNote.type = "long"

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

	local hold_visual_time = self:getHoldVisualTime()
	self.start_dt = visual_info:sub(hold_visual_time)

	hold_visual_time = math.max(hold_visual_time, end_visual_time + visual_info.shortening)
	self.end_dt = visual_info:sub(hold_visual_time)
end

---@param time number
function LongVisualNote:clampAbsoluteTime(time)
	local linked_note = self.linked_note
	local visual_info = self.visual_info
	return math_util.clamp(time, linked_note:getStartTime(), linked_note:getEndTime() + visual_info.shortening)
end

---@param cur_time number
function LongVisualNote:getLatePressTime(cur_time)
	self.hold_press_offset = self.hold_press_offset or cur_time

	local dur = math.max(self.hold_press_offset - self.linked_note:getStartTime(), 0)
	local press_time = cur_time - self.hold_press_offset

	return cur_time + math.min(press_time - dur, 0)
end

---@param cur_time number
function LongVisualNote:getLatePressTimeClamped(cur_time)
	return self:clampAbsoluteTime(self:getLatePressTime(cur_time))
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

	if visual_info.const then
		hold_vp.point.absoluteTime = self:getLatePressTimeClamped(cvp.point.absoluteTime - visual_info.offset)
		return hold_vp.point.absoluteTime
	end

	local interpolator = self.visual.interpolator
	local points = self.visual.points

	hold_vp.monotonicVisualTime = cvp.monotonicVisualTime - visual_info.offset
	self.hold_index = interpolator:interpolate(points, self.hold_index, hold_vp, "visual")

	hold_p.absoluteTime = self:getLatePressTimeClamped(hold_p.absoluteTime)
	self.hold_index = interpolator:interpolate(points, self.hold_index, hold_vp, "absolute")

	return hold_vp:getVisualTime(cvp)
end

LongVisualNote.__lt = VisualNote.__lt

return LongVisualNote
