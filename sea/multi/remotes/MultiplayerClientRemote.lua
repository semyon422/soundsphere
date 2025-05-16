local class = require("class")

---@class sea.MultiplayerClientRemote
---@operator call: sea.MultiplayerClientRemote
local MultiplayerClientRemote = class()

---@param client sea.MultiplayerClient
function MultiplayerClientRemote:new(client)
	self.client = client
end

---@param ... any
function MultiplayerClientRemote:print(...)
	print(...)
end

---@param key any
---@param value any
function MultiplayerClientRemote:set(key, value)
	self.client:set(key, value)
end

function MultiplayerClientRemote:startMatch()
	self.client:startClientMatch()
end

function MultiplayerClientRemote:stopMatch()
	self.client:stopClientMatch()
end

---@param msg string
function MultiplayerClientRemote:addMessage(msg)
	self.client:addMessage(msg)
end

return MultiplayerClientRemote
