local function intersect(self, _tp, svdt, isFirst, isLast, next_tp)
	local globalSpeed = _tp.globalSpeed
	local localSpeed = self.localSpeed
	local targetVisualTime = self.visualTime - svdt / globalSpeed / localSpeed
	local targetTime = (targetVisualTime - _tp.visualTime) / _tp.currentSpeed + _tp.absoluteTime
	if isFirst and isLast then
		return targetTime
	end
	if isLast then
		return targetTime >= _tp.absoluteTime and targetTime
	end
	if isFirst then
		return targetTime < next_tp.absoluteTime and targetTime
	end
	if targetTime >= _tp.absoluteTime and
	targetTime < next_tp.absoluteTime then
		return targetTime
	end
end

---@param ld ncdk.LayerData
---@param range table
---@return table
local function TimeToEvent(ld, range)
	local events = {}

	local tps = ld.timePointList
	for j = 1, #tps do
		local tp = tps[j]
		for i = 1, #tps do
			local _tp = tps[i]  -- current time is from here
			local next_tp = tps[i + 1]  -- to here
			local showTime = intersect(tp, _tp, range[2], i == 1, i == #tps, next_tp)
			local hideTime = intersect(tp, _tp, range[1], i == 1, i == #tps, next_tp)
			if showTime then
				table.insert(events, {
					time = showTime,
					action = "show",
					timePoint = tp,
				})
			end
			if hideTime then
				table.insert(events, {
					time = hideTime,
					action = "hide",
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
