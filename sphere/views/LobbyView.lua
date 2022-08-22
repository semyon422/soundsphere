local just = require("just")
local Class = require("aqua.util.Class")
local LabelImView = require("sphere.imviews.LabelImView")
local TextButtonImView = require("sphere.imviews.TextButtonImView")
local TextInputImView = require("sphere.imviews.TextInputImView")
local _transform = require("aqua.graphics.transform")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local LobbyView = Class:new()

LobbyView.name = ""
LobbyView.nameIndex = 1
LobbyView.password = ""
LobbyView.passwordIndex = 1
LobbyView.isOpen = false

LobbyView.toggle = function(self, state)
	if state == nil then
		self.isOpen = not self.isOpen
	else
		self.isOpen = state
	end
end

LobbyView.draw = function(self)
	if not self.isOpen then
		return
	end

	local multiplayerModel = self.game.multiplayerModel

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate(279 + 454 * 3 / 4, 1080 / 4)
	local w, h = 454 * 1.5, 1080 / 2
	local r = 8

	love.graphics.push()

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)

	just.clip(love.graphics.rectangle, "fill", 0, 0, w, h, r)
	just.container("ContextMenuImView", just.is_over(w, h))

	local inputHeight = 55
	local status = multiplayerModel.status
	if status ~= "connected" then
		LabelImView("Connection status", status, inputHeight)
	elseif not multiplayerModel.user then
		LabelImView("Login status", "Not logged in", inputHeight)
	elseif not multiplayerModel.selectedRoom and not multiplayerModel.room then
		just.indent(r)
		LabelImView("Create room", "Create room", inputHeight)

		local _
		love.graphics.translate(r, r)
		_, self.name, self.nameIndex = TextInputImView("LobbyView name", self.name, self.nameIndex, w / 2 - 2 * r, inputHeight)
		just.sameline()
		just.indent(r)
		LabelImView("LobbyView name", "Name", inputHeight)
		just.emptyline(r)

		_, self.password, self.passwordIndex = TextInputImView("LobbyView password", self.password, self.passwordIndex, w / 2 - 2 * r, inputHeight)
		just.sameline()
		just.indent(r)
		LabelImView("LobbyView password", "Password", inputHeight)

		just.sameline()
		just.offset(w - 144)
		if TextButtonImView("Create", "Create", 144, inputHeight) and self.name ~= "" then
			multiplayerModel:createRoom(self.name, self.password)
		end

		love.graphics.translate(-r, r)

		love.graphics.line(0, 0, w, 0)

		for i = 1, #multiplayerModel.rooms do
			local room = multiplayerModel.rooms[i]
			local name = room.name
			if room.isPlaying then
				name = name .. " (playing)"
			end
			just.row(true)
			just.indent(36)
			LabelImView(i, name, 72)
			if not multiplayerModel.room then
				just.offset(w - 144)
				if TextButtonImView(i, "Join", 144, 72) then
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
		local _
		love.graphics.translate(r, r)
		_, self.password, self.passwordIndex = TextInputImView("LobbyView password", self.password, self.passwordIndex, w / 2 - 2 * r, inputHeight)
		just.sameline()
		just.indent(r)
		LabelImView("LobbyView password", "Password", inputHeight)
		just.sameline()
		just.offset(w - 144)
		if TextButtonImView("LobbyView join", "Join", 144, inputHeight) then
			multiplayerModel:joinRoom(self.password)
			just.focus()
		end
		if TextButtonImView("LobbyView back", "Back", 144, inputHeight) then
			multiplayerModel.selectedRoom = nil
			just.focus()
		end
	else
		self.isOpen = false
		self.game.gameView.view:changeScreen("multiplayerView")
	end

	just.container()
	just.clip()

	love.graphics.pop()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
end

return LobbyView
