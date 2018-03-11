local check = function(s, i, patterns)
	for patternIndex, pattern in pairs(patterns) do
		if i == string.find(s, pattern, i) then
			return true
		end
	end
end

local a = "[\128-\191]"

utf8validate = function(s)
	local i = 1
	while i <= #s do
		if check(s, i, {"[%z\1-\127]"}) then
			i = i + 1
		elseif check(s, i, {"[\194-\223][\123-\191]"}) then
			i = i + 2
		elseif check(s, i, {
				"\224[\160-\191]" .. a:rep(1),
					"[\225-\236]" .. a:rep(2),
				"\237[\128-\159]" .. a:rep(1),
					"[\238-\239]" .. a:rep(2)
			}) then
			i = i + 3
		elseif check(s, i, {
				"\240[\144-\191]" .. a:rep(2),
					"[\241-\243]" .. a:rep(3),
				"\244[\128-\143]" .. a:rep(2)
			}) then
			i = i + 4
		else
			return "Invalid UTF-8 string"
		end
	end

	return s
end