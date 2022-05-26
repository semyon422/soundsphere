local ffi = require("ffi")
local imgui = require("cimgui")
local ImguiView = require("sphere.views.ImguiView")
local align = require("aqua.imgui.config").align
local inside = require("aqua.util.inside")

local OnlineView = ImguiView:new()

local emailPtr = ffi.new("char[128]")
local passwordPtr = ffi.new("char[128]")
local roomNamePtr = ffi.new("char[128]")
local roomPasswordPtr = ffi.new("char[128]")
local newRoomPasswordPtr = ffi.new("char[128]")
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
				imgui.Text("Coming soon")
				if not multiplayerModel.peer and imgui.Button("Connect") then
					multiplayerModel:connect()
				elseif multiplayerModel.peer and imgui.Button("Disconnect") then
					multiplayerModel:disconnect()
				end

				if multiplayerModel.peer then
					imgui.SameLine()
					if imgui.Button("Login") then
						multiplayerModel:login()
					end
					if multiplayerModel.user then
						imgui.Text("You are logged in as " .. multiplayerModel.user.name)
					end
					if imgui.BeginListBox("Players", {0, 150}) then
						for i = 1, #multiplayerModel.users do
							local user = multiplayerModel.users[i]
							local isSelected = multiplayerModel.user == user
							if imgui.Selectable_Bool(user.name, isSelected) then
								multiplayerModel.room = user
							end

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
					if imgui.Button("Leave") then
						multiplayerModel:leaveRoom()
					end
					if imgui.BeginListBox("Players", {0, 150}) then
						for i = 1, #multiplayerModel.room.users do
							local user = multiplayerModel.room.users[i]
							local isSelected = false
							if imgui.Selectable_Bool(user.name, isSelected) then
							end

							if isSelected then
								imgui.SetItemDefaultFocus()
							end
						end
						imgui.EndListBox()
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
