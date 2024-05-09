---@param vps ncdk2.VisualPoint[]
---@param j number
---@param i number
---@param svdt number
---@return number|false?
local function intersect(vps, j, i, svdt)
	local vp = vps[j]
	local _vp = vps[i]
	local next_vp = vps[i + 1]

	local globalSpeed = _vp.globalSpeed
	local localSpeed = vp.localSpeed
	local targetVisualTime = vp.visualTime - svdt / globalSpeed / localSpeed
	local targetTime = (targetVisualTime - _vp.visualTime) / _vp.currentSpeed + _vp.point.absoluteTime
	if #vps == 1 then
		return targetTime
	end
	if i == #vps then
		return targetTime >= _vp.point.absoluteTime and targetTime
	end
	if i == 1 then
		return targetTime < next_vp.point.absoluteTime and targetTime
	end
	if targetTime >= _vp.point.absoluteTime and targetTime < next_vp.point.absoluteTime then
		return targetTime
	end
end

---@param vps ncdk2.VisualPoint[]
---@param range number[]
---@return table
local function TimeToEvent(vps, range)
	local events = {}

	for j = 1, #vps do
		local vp = vps[j]
		for i = 1, #vps do
			local _vp = vps[i]  -- current time is from i to i+1
			local rightTime = intersect(vps, j, i, range[2])
			local leftTime = intersect(vps, j, i, range[1])
			local speed = _vp.globalSpeed * vp.localSpeed * _vp.currentSpeed
			if rightTime then
				table.insert(events, {
					time = rightTime,
					action = speed >= 0 and "show" or "hide",
					timePoint = vp,
				})
			end
			if leftTime then
				table.insert(events, {
					time = leftTime,
					action = speed >= 0 and "hide" or "show",
					timePoint = vp,
				})
			end
		end
	end

	table.sort(events, function(a, b)
		return a.time < b.time
	end)

	return events
end

return TimeToEvent
