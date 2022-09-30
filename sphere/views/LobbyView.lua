local just = require("just")
local ModalImView = require("sphere.imviews.ModalImView")
local _transform = require("aqua.graphics.transform")
local spherefonts = require("sphere.assets.fonts")
local imgui = require("sphere.imgui")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local name = ""
local password = ""

--[[
	local status = multiplayerModel.status
	if status == "disconnected" and imgui.Button("Connect") then
		multiplayerModel:connect()
	elseif status == "connected" and imgui.Button("Disconnect") then
		multiplayerModel:disconnect()
	elseif status == "connecting" then
		imgui.Text("Connecting...")
	elseif status == "disconnecting" then
		imgui.Text("Disconnecting...")
	end

	if multiplayerModel.peer then
		if multiplayerModel.user then
			imgui.SameLine()
			imgui.Text("logged in as " .. multiplayerModel.user.name)
		end
		if imgui.BeginListBox("Players", {0, 150}) then
			for i = 1, #multiplayerModel.users do
				local user = multiplayerModel.users[i]
				local isSelected = multiplayerModel.user == user
				imgui.Selectable_Bool(user.name, isSelected)

				if isSelected then
					imgui.SetItemDefaultFocus()
				end
			end
			imgui.EndListBox()
		end
	end
]]

return ModalImView(function(self)
	if not self then
		return true
	end

	local multiplayerModel = self.game.multiplayerModel

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate(279 + 454 * 3 / 4, 1080 / 4)
	local w, h = 454 * 1.5, 1080 / 2
	local r = 8

	imgui.setSize(w, h, w / 2, 55)

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)

	just.clip(love.graphics.rectangle, "fill", 0, 0, w, h, r)

	local window_id = "ContextMenuImView"
	local over = just.is_over(w, h)
	just.container(window_id, over)
	just.button(window_id, over)
	just.wheel_over(window_id, over)

	local close = false

	local status = multiplayerModel.status
	if status ~= "connected" then
		imgui.label("Connection status", status)
	elseif not multiplayerModel.user then
		imgui.label("Login status", "Not logged in")
	elseif not multiplayerModel.selectedRoom and not multiplayerModel.room then
		imgui.label("Create room", "Create room")

		name = imgui.input("LobbyView name", name, "Name")
		password = imgui.input("LobbyView password", password, "Password")

		just.sameline()
		just.offset(w - 144)
		if imgui.button("Create", "Create") and name ~= "" then
			multiplayerModel:createRoom(name, password)
		end

		imgui.separator()

		for i = 1, #multiplayerModel.rooms do
			local room = multiplayerModel.rooms[i]
			local name = room.name
			if room.isPlaying then
				name = name .. " (playing)"
			end
			just.row(true)
			imgui.label(i, name)
			if not multiplayerModel.room then
				just.offset(w - 144)
				if imgui.button(i, "Join") then
					multiplayerModel.selectedRoom = room
					multiplayerModel:joinRoom("")
					just.focus()
				end
			end
			just.row(false)
			love.graphics.setColor(1, 1, 1, 0.2)
			love.graphics.line(0, 0, w, 0)
			love.graphics.setColor(1, 1, 1, 1)
		end
	elseif not multiplayerModel.room then
		imgui.label("selected room name", multiplayerModel.selectedRoom.name)
		password = imgui.input("LobbyView password", password, "Password")
		just.sameline()
		just.offset(w - 144)
		if imgui.button("LobbyView join", "Join") then
			multiplayerModel:joinRoom(password)
			just.focus()
		end
		if imgui.button("LobbyView back", "Back") then
			multiplayerModel.selectedRoom = nil
			just.focus()
		end
	else
		close = true
		self.game.gameView.view:changeScreen("multiplayerView")
	end

	just.container()
	just.clip()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)

	return close
end)
