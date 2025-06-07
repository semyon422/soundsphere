local Timezone = require("sea.activity.Timezone")

local timezones = {
	-1200,
	-0800,
	-0400,
	0000,
	0400,
	0800,
	1200,
}

---@type sea.Timezone[]
local ActivityTimezones = {}

for i, v in ipairs(timezones) do
	ActivityTimezones[i] = Timezone.decode(v)
end

return ActivityTimezones
