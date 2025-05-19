local ListView = require("sphere.views.ListView")
local just = require("just")
local imgui = require("imgui")
local spherefonts = require("sphere.assets.fonts")
local ModifierEncoder = require("sphere.models.ModifierEncoder")
local ModifierModel = require("sphere.models.ModifierModel")

local RoomUsersListView = ListView()

RoomUsersListView.rows = 9

function RoomUsersListView:reloadItems()
	---@type sphere.GameController
	local game = self.game
	local room_users = game.multiplayerModel.client.room_users
	self.items = room_users
end

---@param i number
---@param w number
---@param h number
function RoomUsersListView:drawItem(i, w, h)
	---@type sphere.GameController
	local game = self.game

	---@type sea.RoomUser[]
	local items = self.items
	local room_user = items[i]

	local client = game.multiplayerModel.client
	local room = client:getMyRoom()
	if not room then
		return
	end

	love.graphics.setColor(0.8, 0.8, 0.8, 1)
	if room_user.is_ready then
		love.graphics.setColor(0.3, 1, 0.3, 1)
	end
	if not room_user.chart_found then
		love.graphics.setColor(1, 0.3, 0.1, 1)
	end
	love.graphics.rectangle("fill", 0, 0, 12, h)

	if room.host_user_id == room_user.user_id then
		love.graphics.setColor(1, 0.7, 0.1, 1)
		love.graphics.rectangle("fill", 12, 0, 12, h)
	end

	love.graphics.setColor(1, 1, 1, 1)

	local user = client:getUser(room_user.user_id)

	local name = user and user.name or "unknown"
	if room_user.is_playing then
		name = name .. " (playing)"
	end

	local modifiers = room_user.replay_base.modifiers
	local modifiers_string = ModifierModel:getString(modifiers)

	-- local title = user.notechart.title or ""
	-- local diffname = user.notechart.name or ""

	local description = ""
	-- if room.is_free_notechart then
	-- 	description = ("%s - %s"):format(title, diffname)
	-- 	if room.is_free_modifiers then
	-- 		description = description .. "\n"
	-- 	end
	-- end
	if room.is_free_modifiers then
		description = description .. modifiers_string
	end

	just.row(true)
	just.indent(30)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	imgui.Label(room_user, name, h)
	just.offset(w / 2)
	love.graphics.setFont(spherefonts.get("Noto Sans", 18))
	imgui.Label(room_user, description, h)
	just.row()

	if not client:isHost() or room.host_user_id == room_user.user_id then
		return
	end

	local s = tostring(self)
	if just.button(s .. i .. "button", just.is_over(w, -h)) then
		local width = 200
		self.gameView:setContextMenu(function()
			local close = false
			just.indent(10)
			just.text(name)
			love.graphics.line(0, 0, 200, 0)
			if imgui.TextOnlyButton("Kick", "Kick", width, 55) then
				client:kickUser(room_user.user_id)
				close = true
			end
			if imgui.TextOnlyButton("Give host", "Give host", width, 55) then
				client:setHost(room_user.user_id)
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
