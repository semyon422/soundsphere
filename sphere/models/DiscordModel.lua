local discordrpc = require("discordRPC")
local class = require("class")

---@class sphere.DiscordModel
---@operator call: sphere.DiscordModel
local DiscordModel = class()

DiscordModel.appId = "594443609668059149"

function DiscordModel:load()
	discordrpc.ready = function(userId, username, discriminator, avatar)
		return self:ready(userId, username, discriminator, avatar)
	end
	discordrpc.disconnected = function(errorCode, message)
		return self:disconnected(errorCode, message)
	end
	discordrpc.errored = function(errorCode, message)
		return self:errored(errorCode, message)
	end
	discordrpc.joinGame = function(joinSecret)
		return self:joinGame(joinSecret)
	end
	discordrpc.spectateGame = function(spectateSecret)
		return self:spectateGame(spectateSecret)
	end
	discordrpc.joinRequest = function(userId, username, discriminator, avatar)
		return self:joinRequest(userId, username, discriminator, avatar)
	end
	discordrpc.initialize(self.appId, true)

	self.presence = {}
	self.nextUpdate = 0
end

---@param presence table
function DiscordModel:setPresence(presence)
	self.presence = self:validatePresence(presence)
end

---@param presence table
---@return table
function DiscordModel:validatePresence(presence)
	presence.state				= presence.state			and presence.state			:sub(1, 127)
	presence.details			= presence.details			and presence.details		:sub(1, 127)
	presence.startTimestamp		= presence.startTimestamp	--integer (52 bit, signed)
	presence.endTimestamp		= presence.endTimestamp		--integer (52 bit, signed)
	presence.largeImageKey		= presence.largeImageKey	and presence.largeImageKey	:sub(1, 21)
	presence.largeImageText		= presence.largeImageText	and presence.largeImageText	:sub(1, 127)
	presence.smallImageKey		= presence.smallImageKey	and presence.smallImageKey	:sub(1, 31)
	presence.smallImageText		= presence.smallImageText	and presence.smallImageText	:sub(1, 127)
	presence.partyId			= presence.partyId			and presence.partyId		:sub(1, 127)
	presence.partySize			= presence.partySize		--integer (32 bit, signed)
	presence.partyMax			= presence.partyMax			--integer (32 bit, signed)
	presence.matchSecret		= presence.matchSecret		and presence.matchSecret	:sub(1, 127)
	presence.joinSecret			= presence.joinSecret		and presence.joinSecret		:sub(1, 127)
	presence.spectateSecret		= presence.spectateSecret	and presence.spectateSecret	:sub(1, 127)
	presence.instance			= presence.instance			--integer (8 bit, signed)

	return presence
end

function DiscordModel:update()
	if self.nextUpdate < love.timer.getTime() then
		pcall(discordrpc.updatePresence, self.presence)
		self.nextUpdate = love.timer.getTime() + 2
	end
	discordrpc.runCallbacks()
end

function DiscordModel:unload()
	discordrpc.shutdown()
end

---@param userId any
---@param username any
---@param discriminator any
---@param avatar any
function DiscordModel:ready(userId, username, discriminator, avatar)
	print(string.format("Discord: ready (%s, %s, %s, %s)", userId, username, discriminator, avatar))
end

---@param errorCode any
---@param message any
function DiscordModel:disconnected(errorCode, message)
	print(string.format("Discord: disconnected (%d: %s)", errorCode, message))
end

---@param errorCode any
---@param message any
function DiscordModel:errored(errorCode, message)
	print(string.format("Discord: error (%d: %s)", errorCode, message))
end

---@param joinSecret any
function DiscordModel:joinGame(joinSecret)
	print(string.format("Discord: join (%s)", joinSecret))
end

---@param spectateSecret any
function DiscordModel:spectateGame(spectateSecret)
	print(string.format("Discord: spectate (%s)", spectateSecret))
end

---@param userId any
---@param username any
---@param discriminator any
---@param avatar any
function DiscordModel:joinRequest(userId, username, discriminator, avatar)
	print(string.format("Discord: join request (%s, %s, %s, %s)", userId, username, discriminator, avatar))
	self:respond(userId, "yes")
end

---@param userId any
---@param reply any
function DiscordModel:respond(userId, reply)
	discordrpc.respond(userId, "yes")
end

return DiscordModel
