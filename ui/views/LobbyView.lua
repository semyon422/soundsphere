local just = require("just")
local ModalImView = require("ui.imviews.ModalImView")
local _transform = require("gfx_util").transform
local spherefonts = require("sphere.assets.fonts")
local imgui = require("imgui")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local name = ""
local password = ""

local w, h = 1024, 1080 / 2
local scrollY = 0
local _h = 55

local sections = {"rooms", "players"}
local section = sections[1]

local section_draw = {}

local modal = ModalImView(function(self, quit)
	if quit then
		return true
	end

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate((1920 - w) / 2, (1080 - h) / 2)
	local r = 8

	imgui.setSize(w, h, w / 2, 55)

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)

	local window_id = "ContextMenuImView"

	just.push()
	imgui.Container(window_id, w, h, _h / 3, _h * 2, scrollY)

	just.push()
	local tabsw
	section, tabsw = imgui.vtabs("lobby tabs", section, sections)
	just.pop()

	local inner_w = w - tabsw
	imgui.setSize(inner_w, h, inner_w / 2, _h)
	love.graphics.translate(tabsw, 0)


	love.graphics.setColor(1, 1, 1, 1)
	local close = section_draw[section](self, inner_w)
	just.emptyline(8)

	scrollY = imgui.Container()
	just.pop()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)

	return close
end)

function section_draw.rooms(self, inner_w)
	local multiplayerModel = self.game.multiplayerModel

	local close
	local status = multiplayerModel.status
	if status ~= "connected" then
		imgui.text(status)
	elseif not multiplayerModel.user then
		imgui.text("Not logged in")
	elseif not multiplayerModel.selectedRoom and not multiplayerModel.room then
		imgui.text("Create room")

		name = imgui.input("LobbyView name", name, "Name")
		password = imgui.input("LobbyView password", password, "Password")

		just.sameline()
		just.offset(inner_w - 144)
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
				just.offset(inner_w - 144)
				if imgui.button(i, "Join") then
					multiplayerModel.selectedRoom = room
					multiplayerModel:joinRoom("")
					just.focus()
				end
			end
			just.row()
			love.graphics.setColor(1, 1, 1, 0.2)
			love.graphics.line(0, 0, inner_w, 0)
			love.graphics.setColor(1, 1, 1, 1)
		end
	elseif not multiplayerModel.room then
		imgui.text(multiplayerModel.selectedRoom.name)
		password = imgui.input("LobbyView password", password, "Password")
		just.sameline()
		just.offset(inner_w - 144)
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
	return close
end

function section_draw.players(self, inner_w)
	local users = self.game.multiplayerModel.users
	if not users then
		return
	end
	for _, user in ipairs(users) do
		imgui.text(user.name)
	end
end

return modal
