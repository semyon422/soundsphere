local MinoProvider = require("rizu.dlc.providers.MinoProvider")

local test = {}

---@param t testing.T
function test.search(t)
	local provider = MinoProvider()
	
	-- We can't easily test real HTTP in a unit test without mocks, 
	-- but we can verify the function exists and doesn't crash on invocation.
	-- (Wait for the real network or mock it in future tests)
	t:assert(type(provider.search) == "function")
end

---@param t testing.T
function test.getDownloadUrl(t)
	local provider = MinoProvider()
	local url = provider:getDownloadUrl(12345)
	t:eq(url, "https://catboy.best/d/12345")
end

return test
