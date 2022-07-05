local Format = {}

Format.accuracy = function(score)
	score = tonumber(score) or math.huge
	if score >= 0.1 then
		return "100+"
	end
	return ("%2.2f"):format(score * 1000)
end

Format.difficulty = function(difficulty)
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

Format.timeRate = function(timeRate)
	local exp = 10 * math.log(timeRate) / math.log(2)
	local roundedExp = math.floor(exp + 0.5)
	if math.abs(exp - roundedExp) % 1 < 1e-2 and math.abs(exp) > 1e-2 then
		return ("%dQ"):format(roundedExp)
	end
	return ("%.2f"):format(timeRate)
end

return Format
