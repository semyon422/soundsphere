local format = {}

---@param n number
function format.float4(n)
	if n < 10 then
		return ("%0.3f"):format(n)
	elseif n < 100 then
		return ("%0.2f"):format(n)
	elseif n < 1000 then
		return ("%0.1f"):format(n)
	end
	return ("%d"):format(n)
end

return format
