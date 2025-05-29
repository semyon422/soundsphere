local class = require("class")

---@class sea.ChartplaysAccess
---@operator call: sea.ChartplaysAccess
local ChartplaysAccess = class()

ChartplaysAccess.submit_interval = 30

---@param user sea.User
---@param time integer
---@param last_chartplay sea.Chartplay?
---@return boolean?
---@return string?
function ChartplaysAccess:canSubmit(user, time, last_chartplay)
	if user.is_banned then
		return false
	end
	if not last_chartplay then
		return true
	end
	if time - last_chartplay.submitted_at < self.submit_interval then
		return nil, "rate limit"
	end
	return true
end

return ChartplaysAccess
