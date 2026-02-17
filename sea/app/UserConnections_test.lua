local UserConnections = require("sea.app.UserConnections")
local UserConnectionsRepo = require("sea.app.repos.UserConnectionsRepo")
local FakeSharedDict = require("web.nginx.FakeSharedDict")
local Message = require("icc.Message")

local test = {}

---@param t testing.T
function test.full_call(t)
	local dict = FakeSharedDict()
	local repo = UserConnectionsRepo(dict)
	local uc = UserConnections(repo)

	-- Setup handlers
	local tbl = {
		print = function(self, msg)
			return "printed: " .. msg
		end
	}
	uc:setup(tbl)

	local ip = "127.0.0.1"
	local port = 1234
	uc:onConnect(ip, port, 1)

	local peers = uc:getPeers()
	t:eq(#peers, 1)
	local peer = peers[1]

	local done = false
	local result
	coroutine.wrap(function()
		result = peer.remote:print("hello") -- This will push to queue and yield
		done = true
	end)()

	-- Verify message is in queue
	local queue = repo:getQueue(ip, port)
	t:eq(queue:count(), 1)
	local call_msg = queue:pop()
	t:assert(call_msg)
	t:tdeq(call_msg[1], {"print"})
	t:eq(call_msg[2], true) -- is_method
	t:eq(call_msg[3], "hello")

	-- Simulate client receiving message and sending back a result.
	-- The result arrives at the server's TaskHandler.
	local return_msg = Message(call_msg.id, true, true, "printed: hello")

	-- Pass the return message to the server's TaskHandler
	uc.task_handler:handle(nil, {}, return_msg)

	t:assert(done)
	t:eq(result, "printed: hello")
end

return test
