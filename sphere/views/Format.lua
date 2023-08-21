local Format = {}

---@param score any
---@return string
function Format.accuracy(score)
	score = tonumber(score) or math.huge
	if score >= 0.1 then
		return "100+"
	end
	return ("%2.2f"):format(score * 1000)
end

---@param difficulty number
---@return string
function Format.difficulty(difficulty)
	local format = "%.2f"
	if not difficulty then
		return ""
	elseif difficulty ~= difficulty then
		return "nan"
	elseif difficulty >= 10000 then
		format = "%s"
		difficulty = "????"
	elseif difficulty >= 100 then
		format = "%d"
	elseif difficulty > 9.995 then
		format = "%.1f"
	end
	return format:format(difficulty)
end

---@param timeRate number
---@return string
function Format.timeRate(timeRate)
	local exp = 10 * math.log(timeRate) / math.log(2)
	local roundedExp = math.floor(exp + 0.5)
	if math.abs(exp - roundedExp) % 1 < 1e-2 and math.abs(exp) > 1e-2 then
		return ("%dQ"):format(roundedExp)
	end
	return ("%.2f"):format(timeRate)
end

---@param inputMode any?
---@return string
function Format.inputMode(inputMode)
	if type(inputMode) ~= "string" then
		return ""
	end
	inputMode = inputMode
		:gsub("key", "K")
		:gsub("scratch", "S")
	return inputMode
end

return Format
