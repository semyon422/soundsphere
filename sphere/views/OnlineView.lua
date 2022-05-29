local ffi = require("ffi")
local imgui = require("cimgui")
local ImguiView = require("sphere.views.ImguiView")
local align = require("aqua.imgui.config").align
local inside = require("aqua.util.inside")
local aquathread = require("aqua.thread")
local HelpMarker = require("sphere.imgui.HelpMarker")
local inspect = require("inspect")

local OnlineView = ImguiView:new()

local emailPtr = ffi.new("char[128]")
local passwordPtr = ffi.new("char[128]")
local roomNamePtr = ffi.new("char[128]")
local roomPasswordPtr = ffi.new("char[128]")
local newRoomPasswordPtr = ffi.new("char[128]")
local freeModifiersPtr = ffi.new("bool[1]")
OnlineView.draw = function(self)
	if not self.isOpen[0] then
		return
	end

	local closed = self:closeOnEscape()
	if closed then
		return
	end

	local multiplayerModel = self.gameController.multiplayerModel

	imgui.SetNextWindowPos({align(0.5, 279 + 454 * 3 / 4), 279}, 0)
	imgui.SetNextWindowSize({454 * 1.5, 522}, 0)
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
				if not multiplayerModel.peer and imgui.Button("Connect") then
					multiplayerModel:connect()
				elseif multiplayerModel.peer and imgui.Button("Disconnect") then
					multiplayerModel:disconnect()
				end

				if multiplayerModel.peer then
					if multiplayerModel.user then
						imgui.SameLine()
						imgui.Text("You are logged in as " .. multiplayerModel.user.name)
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
						if imgui.Selectable_Bool(room.name, isSelected) then
							multiplayerModel.selectedRoom = room
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
				imgui.InputText("Password", newRoomPasswordPtr, ffi.sizeof(newRoomPasswordPtr), imgui.love.InputTextFlags("Password"))
				if imgui.Button("Create room") then
					multiplayerModel:createRoom(ffi.string(roomNamePtr), ffi.string(newRoomPasswordPtr))
				end
				imgui.EndTabItem()
			end
			if (multiplayerModel.selectedRoom or multiplayerModel.room) and imgui.BeginTabItem("Room") then
				if not multiplayerModel.room then
					imgui.InputText("Password", roomPasswordPtr, ffi.sizeof(roomPasswordPtr), imgui.love.InputTextFlags("Password"))
					if imgui.Button("Join") then
						multiplayerModel:joinRoom(ffi.string(roomPasswordPtr))
					end
				else
					local notechart = multiplayerModel.notechart
					local song = ("%s - %s"):format(notechart.artist or "?", notechart.title or "?")
					local name = notechart.name or "?"
					imgui.Text("Room name: " .. multiplayerModel.room.name)
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
							name = name .. " (" .. (user.isReady and "ready" or "not ready")
							if multiplayerModel.room.hostPeerId == user.peerId then
								name = name .. ", host"
							elseif not user.isNotechartFound then
								name = name .. ", no chart"
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
					local isHost = user.peerId == multiplayerModel.room.hostPeerId

					local isReady = user.isReady
					if imgui.Button(isReady and "Ready" or "Not ready") then
						multiplayerModel:switchReady()
					end
					if isHost then
						imgui.SameLine()
						if imgui.Button("Start match") then
							multiplayerModel:startMatch()
						end
						freeModifiersPtr[0] = multiplayerModel.room.isFreeModifiers
						if imgui.Checkbox("Free modifiers", freeModifiersPtr) then
							multiplayerModel:setFreeModifiers(freeModifiersPtr[0])
						end
						if imgui.Button("Set notechart") then
							multiplayerModel:pushNotechart()
						end
					else
						imgui.Text("Free modifiers: " .. (multiplayerModel.room.isFreeModifiers and "yes" or "no"))
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