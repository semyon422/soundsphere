local just = require("just")
local spherefonts = require("sphere.assets.fonts")
local icons = require("sphere.assets.icons")
local gfx_util = require("gfx_util")
local imgui = require("imgui")

local BackgroundView = require("sphere.views.BackgroundView")
local UserInfoView = require("sphere.views.UserInfoView")
local LogoImView = require("sphere.imviews.LogoImView")
local RoomUsersListView = require("sphere.views.MultiplayerView.RoomUsersListView")

local ModifierIconGridView = require("sphere.views.SelectView.ModifierIconGridView")
local TextCellImView = require("sphere.imviews.TextCellImView")
local BarCellImView = require("sphere.imviews.BarCellImView")
local RoundedRectangle = require("sphere.views.RoundedRectangle")
local Format = require("sphere.views.Format")

local time_util = require("time_util")

local Layout = require("sphere.views.MultiplayerView.Layout")

---@param w number
---@param h number
---@param _r number?
local function drawFrameRect(w, h, _r)
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, _r or 36)
	love.graphics.setColor(r, g, b, a)
end

---@param self table
local function Frames(self)
	local w, h = Layout:move("base")
	love.graphics.setColor(1, 1, 1, 0.2)
	love.graphics.rectangle("fill", 0, 0, w, h)

	local w, h = Layout:move("base", "header")
	drawFrameRect(w, h, 0)

	local w, h = Layout:move("base", "footer")
	drawFrameRect(w, h, 0)

	drawFrameRect(Layout:move("column3"))
	drawFrameRect(Layout:move("column1"))
	drawFrameRect(Layout:move("column2row1"))

	love.graphics.setColor(0, 0, 0, 0.9)
	w, h = Layout:move("column2row2")
	RoundedRectangle("fill", 0, -1, w, h + 1, 36, false, false, 2)

	love.graphics.setColor(0, 0, 0, 0.8)
	w, h = Layout:move("column2row3")
	RoundedRectangle("fill", 0, 0, w, h, 36, false, false, 2)
end

---@param self table
local function ScreenMenu(self)
	local multiplayerModel = self.game.multiplayerModel

	local w, h = Layout:move("column3", "header")
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	if imgui.TextOnlyButton("Leave", "Leave", 120, h) then
		multiplayerModel:leaveRoom()
	end
end

---@param self table
local function Cells(self)
	local w, h = Layout:move("column2row1")

	local multiplayerModel = self.game.multiplayerModel

	local baseTimeRate = self.game.playContext.rate
	local chartview = self.game.selectModel.chartview or multiplayerModel.notechart

	local bpm = 0
	local length = 0
	local notes_count = 0
	local level = 0
	local longNoteRatio = 0
	local localOffset = 0
	local format = ""
	if chartview then
		bpm = (chartview.tempo or 0) * baseTimeRate
		length = (chartview.duration or 0) / baseTimeRate
		notes_count = chartview.notes_count or 0
		level = chartview.level or 0
		longNoteRatio = chartview.longNoteRatio or 0
		localOffset = chartview.localOffset or 0
		format = chartview.format or ""
	end

	love.graphics.translate(0, h - 118)
	w = (w - 44) / 4
	h = 50

	love.graphics.setColor(1, 1, 1, 1)

	just.row(true)
	just.indent(22)
	TextCellImView(w, h, "right", "bpm", ("%d"):format(bpm))
	TextCellImView(w, h, "right", "duration", time_util.format(length))
	TextCellImView(w, h, "right", "notes", notes_count)
	TextCellImView(w, h, "right", "level", level)

	just.row(true)
	just.indent(22)
	BarCellImView(2 * w, h, "right", "long notes", longNoteRatio)
	TextCellImView(w, h, "right", "offset", localOffset * 1000)
	TextCellImView(w, h, "right", "format", format)
	just.row()
end

---@param self table
local function Background(self)
	local w, h = Layout:move("base")

	local dim = self.game.configModel.configs.settings.graphics.dim.select
	BackgroundView.game = self.game
	BackgroundView:draw(w, h, dim, 0.01)
end

local bannerGradient

---@param self table
local function BackgroundBanner(self)
	bannerGradient = bannerGradient or gfx_util.newGradient(
		"vertical",
		{0, 0, 0, 0},
		{0, 0, 0, 1}
	)

	local w, h = Layout:move("column2row1")
	drawFrameRect(w, h)

	just.clip(love.graphics.rectangle, "fill", 0, 0, w, h, 36)
	BackgroundView.game = self.game
	BackgroundView:draw(w, h, 0, 0)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(bannerGradient, 0, 0, 0, w, h)
	just.clip()
end

---@param self table
local function DownloadButton(self)
	local w, h = Layout:move("column2", "header")
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	love.graphics.setColor(1, 1, 1, 1)

	local multiplayerModel = self.game.multiplayerModel
	local notechart = multiplayerModel.notechart
	if not notechart.osuSetId then
		return
	end
	local beatmap = multiplayerModel.downloadingBeatmap
	if beatmap then
		just.indent(w / 2)
		imgui.Label("beatmap status", beatmap.status, h)
	else
		just.indent(w / 2)
		if imgui.TextOnlyButton("Download", multiplayerModel.chartview and "Redownload" or "Download", 144, h) then
			multiplayerModel:downloadNoteChart()
		end
	end
end

---@param self table
local function Title(self)
	local w, h = Layout:move("column2row2")
	love.graphics.translate(22, 0)
	local chartview = self.game.selectModel.chartview or self.game.multiplayerModel.notechart
	if not chartview or not chartview.title then
		return
	end
	TextCellImView(w, 52, "left", chartview.artist, chartview.title)

	local baseTimeRate = self.game.playContext.rate
	local difficulty = Format.difficulty((chartview.difficulty or 0) * baseTimeRate)

	TextCellImView(72, h, "right", Format.inputMode(chartview.inputmode), difficulty, true)
	just.sameline()
	just.indent(44)
	TextCellImView(w, 52, "left", chartview.creator, chartview.name)
end

---@param self table
local function ModifierIconGrid(self)
	local w, h = Layout:move("column2row3")
	-- drawFrameRect(w, h)
	love.graphics.translate(21, 4)

	ModifierIconGridView.game = self.game
	ModifierIconGridView:draw(self.game.playContext.modifiers, w - 42, h, h - 8)
end

---@param self table
local function Header(self)
	local w, h = Layout:move("column1", "header")

	local username = self.game.configModel.configs.online.user.name
	local session = self.game.configModel.configs.online.session
	just.row(true)
	if UserInfoView:draw(w, h, username, not not (session and next(session))) then
		self.game.gameView:setModal(require("sphere.views.OnlineView"))
	end
	just.offset(0)

	LogoImView("logo", h, 0.5)

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	local w = h
	local gameView = self.game.gameView
	if imgui.IconOnlyButton("settings", icons("settings"), h, 0.5) then
		gameView:setModal(require("sphere.views.SettingsView"))
	end
	if imgui.TextOnlyButton("noteskins", "skins", w, h) then
		gameView:setModal(require("sphere.views.NoteSkinView"))
	end
	if imgui.TextOnlyButton("input", "input", w, h) then
		gameView:setModal(require("sphere.views.InputView"))
	end
	just.row()
end

---@param self table
local function RoomUsersList(self)
	local w, h = Layout:move("column1")

	RoomUsersListView.game = self.game
	RoomUsersListView:draw(w, h)
end

local noRoom = {
	name = "No room"
}
local noUser = {}

---@param self table
local function RoomInfo(self)
	local w, h = Layout:move("column2", "header")

	local multiplayerModel = self.game.multiplayerModel
	local room = multiplayerModel.room or noRoom

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	gfx_util.printFrame(room.name, 22, 0, w, h, "left", "center")
end

---@param self table
local function RoomSettings(self)
	local w, h = Layout:move("column3")

	local multiplayerModel = self.game.multiplayerModel
	local room = multiplayerModel.room or noRoom
	local user = multiplayerModel.user or noUser

	love.graphics.translate(0, 36)

	local _h = 55
	local isHost = multiplayerModel:isHost()
	if isHost then
		if imgui.Checkbox("Free chart", room.isFreeNotechart, _h) then
			multiplayerModel:setFreeNotechart(not room.isFreeNotechart)
		end
		just.sameline()
		imgui.Label("Free chart", "Free chart", _h)

		if imgui.Checkbox("Free mods", room.isFreeModifiers, _h) then
			multiplayerModel:setFreeModifiers(not room.isFreeModifiers)
		end
		just.sameline()
		imgui.Label("Free mods", "Free mods", _h)

		just.emptyline(36)
	end

	if imgui.Checkbox("Ready", user.isReady, _h) then
		multiplayerModel:switchReady()
	end
	just.sameline()
	imgui.Label("Ready", "Ready", _h)

	w, h = Layout:move("column3")
	love.graphics.translate(36, h - 72 * 3)

	if isHost or room.isFreeNotechart then
		if imgui.TextOnlyButton("Select chart", "Select", w - 72, 72) then
			self:changeScreen("selectView")
		end
	end
	if isHost or room.isFreeModifiers then
		if imgui.TextOnlyButton("Modifiers", "Modifiers", w - 72, 72) then
			self.game.gameView:setModal(require("sphere.views.ModifierView"))
		end
	end

	w, h = Layout:move("column3")
	love.graphics.translate(36, h - 72)
	if isHost then
		if not room.isPlaying and imgui.TextOnlyButton("Start match", "Start match", w - 72, 72) then
			multiplayerModel:startMatch()
		elseif room.isPlaying and imgui.TextOnlyButton("Stop match", "Stop match", w - 72, 72) then
			multiplayerModel:stopMatch()
		end
	end
end

local chat = {
	message = "",
	index = 1
}

---@param self table
local function ChatWindow(self)
	local _p = 10

	local font = spherefonts.get("Noto Sans", 24)
	love.graphics.setFont(font)
	local lineHeight = font:getHeight()

	local w, h = Layout:move("footer")
	love.graphics.translate(_p, _p)
	w = w - _p * 2
	h = h - _p * 2 - lineHeight

	just.clip(love.graphics.rectangle, "fill", 0, 0, w, h)

	local multiplayerModel = self.game.multiplayerModel
	local roomMessages = multiplayerModel.roomMessages

	local scroll = just.wheel_over(chat, just.is_over(w, h))

	chat.scroll = chat.scroll or 0
	love.graphics.translate(0, -chat.scroll)

	local startHeight = just.height

	for i = 1, #roomMessages do
		local message = roomMessages[i]
		just.text(message)
	end

	chat.height = just.height - startHeight
	just.clip()

	local content = chat.height
	local overlap = math.max(content - h, 0)
	if overlap > 0 then
		if scroll then
			chat.scroll = math.min(math.max(chat.scroll - scroll * 50, 0), overlap)
		elseif chat.messageCount ~= #roomMessages then
			chat.scroll = overlap
			chat.messageCount = #roomMessages
		end
	end

	w, h = Layout:move("footer")
	love.graphics.translate(_p, h - _p - lineHeight)
	w = w - _p * 2
	h = 50

	love.graphics.line(0, 0, w, 0)

	just.row(true)
	just.text(">")
	just.indent(10)

	local changed, left, right
	changed, chat.message, chat.index, left, right = just.textinput(chat.message, chat.index)
	just.text(left)
	love.graphics.line(0, 0, 0, lineHeight)
	just.text(right)
	just.row()

	if changed then
		chat.scroll = overlap
	end
	if just.keypressed("return") then
		multiplayerModel:sendMessage(chat.message)
		chat.message = ""
	end
end

return function(self)
	Background(self)
	Frames(self)
	BackgroundBanner(self)
	DownloadButton(self)
	Cells(self)
	ModifierIconGrid(self)
	ScreenMenu(self)
	Title(self)
	Header(self)
	RoomInfo(self)
	RoomSettings(self)
	RoomUsersList(self)
	ChatWindow(self)
end
