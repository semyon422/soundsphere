local class = require("class")

---@class sea.Peer
---@operator call: sea.Peer
---@field user sea.User
---@field session sea.Session
---@field ip string
---@field remote sea.MultiplayerClientRemote
---@field remote_no_return sea.MultiplayerClientRemote
local Peer = class()

return Peer

