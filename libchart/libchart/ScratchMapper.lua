local class = require("class")

---@class libchart.ScratchMapper
---@operator call: libchart.ScratchMapper
local ScratchMapper = class()

---@param ansc libchart.AnalogScratch
---@param callback function
function ScratchMapper:new(ansc, callback)
	self.ansc = ansc
	self.active = ansc.active
	self.scratch_right = ansc.scratch_right
	self.callback = callback
end

function ScratchMapper:update()
	local ansc = self.ansc
	if self.active ~= ansc.active then
		self.callback(ansc.active, ansc.scratch_right)
		self.active = ansc.active
		self.scratch_right = ansc.scratch_right
	elseif self.scratch_right ~= ansc.scratch_right then
		self.callback(false, self.scratch_right)
		self.callback(true, ansc.scratch_right)
		self.scratch_right = ansc.scratch_right
	end
end

return ScratchMapper
