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

---@type sea.Room?
local selectedRoom

function section_draw.rooms(self, inner_w)
	---@type sphere.GameController
	local game = self.game

	local multiplayerModel = game.multiplayerModel
	local mp_client = game.multiplayerModel.client

	local close
	local status = multiplayerModel.status
	if status ~= "connected" then
		imgui.text(status)
	elseif not mp_client:isLoggedIn() then
		imgui.text("Not logged in")
	elseif not selectedRoom and not mp_client:isInRoom() then
		imgui.text("Create room")

		name = imgui.input("LobbyView name", name, "Name")
		password = imgui.input("LobbyView password", password, "Password")

		just.sameline()
		just.offset(inner_w - 144)
		if imgui.button("Create", "Create") and name ~= "" then
			mp_client:createRoom(name, password)
		end

		imgui.separator()

		for i = 1, #mp_client.rooms do
			local room = mp_client.rooms[i]
			local name = room.name
			if room.isPlaying then
				name = name .. " (playing)"
			end
			just.row(true)
			imgui.label(i, name)
			just.offset(inner_w - 144)
			if imgui.button(i, "Join") then
				selectedRoom = room
				mp_client:joinRoom(room.id, "")
				just.focus()
			end
			just.row()
			love.graphics.setColor(1, 1, 1, 0.2)
			love.graphics.line(0, 0, inner_w, 0)
			love.graphics.setColor(1, 1, 1, 1)
		end
	elseif selectedRoom and not mp_client:isInRoom() then
		imgui.text(selectedRoom.name)
		password = imgui.input("LobbyView password", password, "Password")
		just.sameline()
		just.offset(inner_w - 144)
		if imgui.button("LobbyView join", "Join") then
			mp_client:joinRoom(selectedRoom.id, password)
			just.focus()
		end
		if imgui.button("LobbyView back", "Back") then
			selectedRoom = nil
			just.focus()
		end
	else
		close = true
		self.game.ui.gameView.view:changeScreen("multiplayerView")
	end
	return close
end

function section_draw.players(self, inner_w)
	---@type sphere.GameController
	local game = self.game
	for _, user in ipairs(game.multiplayerModel.client.users) do
		imgui.text(user.name or "unknown")
	end
end

return modal
