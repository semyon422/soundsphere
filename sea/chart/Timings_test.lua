local Timings = require("sea.chart.Timings")

local test = {}

---@param t testing.T
function test.all(t)
	for i = -1, 2000 do
		t:eq(Timings:decode(i):encode(), i)
	end
end

return test
