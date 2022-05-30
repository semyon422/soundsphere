local ffi = require("ffi")
local imgui = require("cimgui")
local ImguiView = require("sphere.views.ImguiView")
local align = require("aqua.imgui.config").align
local inside = require("aqua.util.inside")
local aquathread = require("aqua.thread")
local HelpMarker = require("sphere.imgui.HelpMarker")
local inspect = require("inspect")

local OnlineView = ImguiView:new()

local messagesCount = 0
local emailPtr = ffi.new("char[128]")
local passwordPtr = ffi.new("char[128]")
local roomNamePtr = ffi.new("char[128]")
local roomPasswordPtr = ffi.new("char[128]")
local newRoomPasswordPtr = ffi.new("char[128]")
local messagePtr = ffi.new("char[256]")
local freeModifiersPtr = ffi.new("bool[1]")
local readyPtr = ffi.new("bool[1]")
OnlineView.draw = function(self)
	if not self.isOpen[0] then
		return
	end

	local closed = self:closeOnEscape()
	if closed then
		return
	end

	local multiplayerModel = self.gameController.multiplayerModel

	imgui.SetNextWindowPos({align(0.5, 279 + 454 * 3 / 4), 279 / 2}, 0)
	imgui.SetNextWindowSize({454 * 1.5, 522 * 1.5}, 0)
	local flags = imgui.love.WindowFlags("NoMove", "NoResize")
	if imgui.Begin("Online", self.isOpen, flags) then
		if imgui.BeginTabBar("Online tab bar") then
			local active = inside(self, "gameController.configModel.configs.online.session.active")
			if imgui.BeginTabItem("Login") then
				if active then
					imgui.Text("You are logged in")
				end
				imgui.InputText("Email", emailPtr, ffi.sizeof(emailPtr))
				imgui.InputText("Password", passwordPtr, ffi.sizeof(passwordPtr), imgui.love.InputTextFlags("Password"))
				if imgui.Button("Login") then
					self.navigator:login(ffi.string(emailPtr), ffi.string(passwordPtr))
				end
				if imgui.Button("Quick login using browser") then
					self.navigator:quickLogin()
				end
				imgui.EndTabItem()
			end
			if active and imgui.BeginTabItem("Multiplayer") then
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

				imgui.EndTabItem()
			end
			if multiplayerModel.peer and multiplayerModel.user and imgui.BeginTabItem("Lobby") then
				if imgui.BeginListBox("Rooms", {0, 150}) then
					for i = 1, #multiplayerModel.rooms do
						local room = multiplayerModel.rooms[i]
						local isSelected = multiplayerModel.selectedRoom == room
						local name = room.name
						if room.isPlaying then
							name = name .. " (playing)"
						end
						if imgui.Selectable_Bool(name, isSelected) then
							multiplayerModel.selectedRoom = room
							if not multiplayerModel.room then
								multiplayerModel:joinRoom("")
							end
						end

						if isSelected then
							imgui.SetItemDefaultFocus()
						end
					end
					imgui.EndListBox()
				end

				imgui.Separator()

				imgui.Text("Create new room")
				imgui.InputText("Name", roomNamePtr, ffi.sizeof(roomNamePtr))
				imgui.InputText("Password (optional)", newRoomPasswordPtr, ffi.sizeof(newRoomPasswordPtr), imgui.love.InputTextFlags("Password"))
				if imgui.Button("Create room") then
					local name = ffi.string(roomNamePtr)
					local password = ffi.string(newRoomPasswordPtr)
					if name ~= "" then
						multiplayerModel:createRoom(name, password)
					end
				end
				imgui.EndTabItem()
			end
			local room = multiplayerModel.room
			if (multiplayerModel.selectedRoom or room) and imgui.BeginTabItem("Room") then
				if not room then
					imgui.InputText("Password", roomPasswordPtr, ffi.sizeof(roomPasswordPtr), imgui.love.InputTextFlags("Password"))
					if imgui.Button("Join") then
						multiplayerModel:joinRoom(ffi.string(roomPasswordPtr))
					end
				else
					local notechart = multiplayerModel.notechart
					local song = ("%s - %s"):format(notechart.artist or "?", notechart.title or "?")
					local name = notechart.name or "?"
					imgui.Text("Room name: " .. room.name)
					if room.isPlaying then
						imgui.SameLine()
						imgui.Text("(playing)")
					end
					imgui.Text("Song: " .. song)
					imgui.Text("Difficulty:")
					imgui.SameLine()
					HelpMarker(inspect(notechart))
					imgui.SameLine()
					imgui.Text(name)
					if imgui.BeginListBox("Players", {0, 150}) then
						for i = 1, #multiplayerModel.roomUsers do
							local user = multiplayerModel.roomUsers[i]
							local isSelected = false
							local name = user.name
							name = name .. " ("
							if room.hostPeerId == user.peerId then
								name = name .. "host"
							elseif not user.isNotechartFound then
								name = name .. "no chart"
							end
							if name:sub(-1) ~= "(" then
								name = name .. ", "
							end
							if user.isPlaying then
								name = name .. "playing"
							else
								name = name .. (user.isReady and "ready" or "not ready")
							end
							name = name .. ")"
							imgui.Selectable_Bool(name, isSelected)

							if isSelected then
								imgui.SetItemDefaultFocus()
							end
						end
						imgui.EndListBox()
					end
					if imgui.Button("Leave") then
						multiplayerModel:leaveRoom()
					end
					imgui.SameLine()

					local user = multiplayerModel.user

					readyPtr[0] = user.isReady
					if imgui.Checkbox("Ready", readyPtr) then
						user.isReady = readyPtr[0]
						multiplayerModel:switchReady()
					end
					if multiplayerModel:isHost() then
						freeModifiersPtr[0] = room.isFreeModifiers
						if imgui.Button("Set notechart") then
							multiplayerModel:pushNotechart()
						end
						imgui.SameLine()
						if imgui.Checkbox("Free modifiers", freeModifiersPtr) then
							multiplayerModel:setFreeModifiers(freeModifiersPtr[0])
						end
						imgui.SameLine()
						if not room.isPlaying and imgui.Button("Start match") then
							multiplayerModel:startMatch()
						elseif room.isPlaying and imgui.Button("Stop match") then
							multiplayerModel:stopMatch()
						end
					else
						imgui.Text("Free modifiers: " .. (room.isFreeModifiers and "yes" or "no"))
					end
					imgui.Separator()
					imgui.Text("Chat")

					imgui.BeginListBox("Messages", {0, 150})
					for i = 1, #multiplayerModel.roomMessages do
						local message = multiplayerModel.roomMessages[i]
						imgui.Selectable_Bool(message, false)
					end
					if messagesCount ~= #multiplayerModel.roomMessages then
						messagesCount = #multiplayerModel.roomMessages
						imgui.SetScrollHereY(1)
					end
					imgui.EndListBox()

					imgui.InputText("Message", messagePtr, ffi.sizeof(messagePtr))
					if imgui.Button("Send") then
						multiplayerModel:sendMessage(ffi.string(messagePtr))
						ffi.fill(messagePtr, ffi.sizeof(messagePtr), 0)
					end
				end
				imgui.EndTabItem()
			end
			imgui.EndTabBar()
		end
	end
	imgui.End()
end

return OnlineView
