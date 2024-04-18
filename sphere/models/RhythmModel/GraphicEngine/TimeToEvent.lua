---@param tps ncdk.TimePoint[]
---@param j number
---@param i number
---@param svdt number
---@return number|false?
local function intersect(tps, j, i, svdt)
	local tp = tps[j]
	local _tp = tps[i]
	local next_tp = tps[i + 1]

	local globalSpeed = _tp.globalSpeed
	local localSpeed = tp.localSpeed
	local targetVisualTime = tp.visualTime - svdt / globalSpeed / localSpeed
	local targetTime = (targetVisualTime - _tp.visualTime) / _tp.currentSpeed + _tp.absoluteTime
	if #tps == 1 then
		return targetTime
	end
	if i == #tps then
		return targetTime >= _tp.absoluteTime and targetTime
	end
	if i == 1 then
		return targetTime < next_tp.absoluteTime and targetTime
	end
	if targetTime >= _tp.absoluteTime and targetTime < next_tp.absoluteTime then
		return targetTime
	end
end

---@param tps ncdk.TimePoint[]
---@param range number[]
---@return table
local function TimeToEvent(tps, range)
	local events = {}

	for j = 1, #tps do
		local tp = tps[j]
		for i = 1, #tps do
			local _tp = tps[i]  -- current time is from i to i+1
			local rightTime = intersect(tps, j, i, range[2])
			local leftTime = intersect(tps, j, i, range[1])
			local speed = _tp.globalSpeed * tp.localSpeed * _tp.currentSpeed
			if rightTime then
				table.insert(events, {
					time = rightTime,
					action = speed >= 0 and "show" or "hide",
					timePoint = tp,
				})
			end
			if leftTime then
				table.insert(events, {
					time = leftTime,
					action = speed >= 0 and "hide" or "show",
					timePoint = tp,
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
