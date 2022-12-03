local ListView = require("sphere.views.ListView")
local just = require("just")
local imgui = require("imgui")
local spherefonts = require("sphere.assets.fonts")

local RoomUsersListView = ListView:new()

RoomUsersListView.rows = 9

RoomUsersListView.reloadItems = function(self)
	self.items = self.game.multiplayerModel.roomUsers
end

RoomUsersListView.drawItem = function(self, i, w, h)
	local items = self.items
	local user = items[i]

	local multiplayerModel = self.game.multiplayerModel
	local room = multiplayerModel.room
	if not room then
		return
	end

	love.graphics.setColor(0.8, 0.8, 0.8, 1)
	if user.isReady then
		love.graphics.setColor(0.3, 1, 0.3, 1)
	end
	if not user.isNotechartFound then
		love.graphics.setColor(1, 0.3, 0.1, 1)
	end
	love.graphics.rectangle("fill", 0, 0, 12, h)
	love.graphics.setColor(1, 1, 1, 1)

	local name = user.name
	if room.hostPeerId == user.peerId then
		name = name .. " host"
	end
	if user.isPlaying then
		name = name .. " playing"
	end

	local modifierModel = self.game.modifierModel

	local configModifier = user.modifiers
	if type(configModifier) == "string" then
		configModifier = modifierModel:decode(configModifier)
	end
	configModifier = configModifier or {}
	local modifiers = modifierModel:getString(configModifier)

	local title = user.notechart.title or ""
	local diffname = user.notechart.name or ""

	local description = ""
	if room.isFreeNotechart then
		description = ("%s - %s"):format(title, diffname)
		if room.isFreeModifiers then
			description = description .. "\n"
		end
	end
	if room.isFreeModifiers then
		description = description .. modifiers
	end

	just.row(true)
	just.indent(18)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	imgui.Label(user, name, h)
	just.offset(w / 2)
	love.graphics.setFont(spherefonts.get("Noto Sans", 18))
	imgui.Label(user, description, h)
	just.row()

	if not multiplayerModel:isHost() or room.hostPeerId == user.peerId then
		return
	end

	local s = tostring(self)
	if just.button(s .. i .. "button", just.is_over(w, -h)) then
		local width = 200
		self.game.gameView:setContextMenu(function()
			local close = false
			just.indent(10)
			just.text(user.name)
			love.graphics.line(0, 0, 200, 0)
			if imgui.TextOnlyButton("Kick", "Kick", width, 55) then
				multiplayerModel:kickUser(user.peerId)
				close = true
			end
			if imgui.TextOnlyButton("Give host", "Give host", width, 55) then
				multiplayerModel:setHost(user.peerId)
				close = true
			end
			if imgui.TextOnlyButton("Close", "Close", width, 55) then
				close = true
			end
			return close
		end, width)
	end
end

return RoomUsersListView
