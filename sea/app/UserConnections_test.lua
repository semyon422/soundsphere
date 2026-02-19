local UserConnections = require("sea.app.UserConnections")
local UserConnectionsRepo = require("sea.app.repos.UserConnectionsRepo")
local FakeSharedDict = require("web.nginx.FakeSharedDict")
local Message = require("icc.Message")
local User = require("sea.access.User")

local test = {}

---@param t testing.T
function test.full_call(t)
	local dict = FakeSharedDict()
	local repo = UserConnectionsRepo(dict)
	local users_repo = {
		getUser = function(self, id)
			local u = User()
			u.id = id
			u.name = "user" .. id
			return u
		end
	}
	local uc = UserConnections(repo, users_repo)

	-- Setup handlers
	local tbl = {
		getRandomNumber = function(self)
			return 42
		end
	}
	uc:setup(tbl, {getRandomNumber = true})

	local ip1, port1 = "1.1.1.1", 1
	local sid1 = ip1 .. ":" .. port1
	local ip2, port2 = "2.2.2.2", 2
	local sid2 = ip2 .. ":" .. port2

	uc:onConnect(ip1, port1, 1)
	uc:onConnect(ip2, port2, 2)

	-- Connection 1 wants to call Connection 2
	local peer2_from_1 = uc:getPeer(ip2, port2, ip1, port1)
	
	local result
	local done = false
	coroutine.wrap(function()
		result = peer2_from_1.remote:getRandomNumber()
		done = true
	end)()

	-- Verify and handle call in connection 2
	-- In reality, connection 2's background loop would call processQueue
	uc:processQueue(sid2, tbl)

	-- Verify and handle return in connection 1
	uc:processQueue(sid1, tbl)

	t:assert(done)
	t:eq(result, 42)
end

return test
