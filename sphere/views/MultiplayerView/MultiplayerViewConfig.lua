local just = require("just")
local spherefonts		= require("sphere.assets.fonts")
local gfx_util = require("gfx_util")

local RectangleView = require("sphere.views.RectangleView")
local BackgroundView = require("sphere.views.BackgroundView")
local ValueView = require("sphere.views.ValueView")
local GaussianBlurView = require("sphere.views.GaussianBlurView")
local UserInfoView = require("sphere.views.UserInfoView")
local LogoImView = require("sphere.imviews.LogoImView")
local RoomUsersListView = require("sphere.views.MultiplayerView.RoomUsersListView")

local PointGraphView = require("sphere.views.GameplayView.PointGraphView")
local ModifierIconGridView = require("sphere.views.SelectView.ModifierIconGridView")
local MatchPlayersView	= require("sphere.views.GameplayView.MatchPlayersView")
local TextCellImView = require("sphere.imviews.TextCellImView")
local BarCellImView = require("sphere.imviews.BarCellImView")
local IconButtonImView = require("sphere.imviews.IconButtonImView")
local TextButtonImView = require("sphere.imviews.TextButtonImView")
local CheckboxImView = require("sphere.imviews.CheckboxImView")
local LabelImView = require("sphere.imviews.LabelImView")
local JudgementBarImView = require("sphere.imviews.JudgementBarImView")
local Format = require("sphere.views.Format")
local RoundedRectangle = require("sphere.views.RoundedRectangle")

local inspect = require("inspect")
local time_util = require("time_util")
local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local Layout = require("sphere.views.MultiplayerView.Layout")

local function drawFrameRect(w, h, _r)
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, _r or 36)
	love.graphics.setColor(r, g, b, a)
end

local Frames = {draw = function(self)
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
end}

local ScreenMenu = {draw = function(self)
	local multiplayerModel = self.game.multiplayerModel

	love.graphics.replaceTransform(gfx_util.transform(transform))

	local w, h = Layout:move("column3", "header")

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	if TextButtonImView("Leave", "Leave", 120, h) then
		multiplayerModel:leaveRoom()
	end
end}

local Cells = {draw = function(self)
	local w, h = Layout:move("column2row1")

	local multiplayerModel = self.game.multiplayerModel

	local baseTimeRate = self.game.rhythmModel.timeEngine.baseTimeRate
	local noteChartItem = self.game.selectModel.noteChartItem or multiplayerModel.notechart

	local bpm = 0
	local length = 0
	local noteCount = 0
	local level = 0
	local longNoteRatio = 0
	local localOffset = 0
	if noteChartItem then
		bpm = (noteChartItem.bpm or 0) * baseTimeRate
		length = (noteChartItem.length or 0) / baseTimeRate
		noteCount = noteChartItem.noteCount or 0
		level = noteChartItem.level or 0
		longNoteRatio = noteChartItem.longNoteRatio or 0
		localOffset = noteChartItem.localOffset or 0
	end

	love.graphics.translate(0, h - 118)
	w = (w - 44) / 4
	h = 50

	love.graphics.setColor(1, 1, 1, 1)

	just.row(true)
	just.indent(22)
	TextCellImView(w, h, "right", "bpm", ("%d"):format(bpm))
	TextCellImView(w, h, "right", "duration", time_util.format(length))
	TextCellImView(w, h, "right", "notes", noteCount)
	TextCellImView(w, h, "right", "level", level)

	just.row(true)
	just.indent(22)
	BarCellImView(2 * w, h, "right", "long notes", longNoteRatio)
	TextCellImView(2 * w, h, "right", "local offset", localOffset * 1000)
	just.row(false)
end}

local Background = {
	draw = function(self)
		love.graphics.replaceTransform(gfx_util.transform(transform))

		local dim = self.game.configModel.configs.settings.graphics.dim.select
		BackgroundView.game = self.game
		BackgroundView:draw(1920, 1080, dim, 0.01)
	end
}

local BackgroundBanner = {
	load = function(self)
		self.gradient = gfx_util.newGradient(
			"vertical",
			{0, 0, 0, 0},
			{0, 0, 0, 1}
		)
	end,
	draw = function(self)
		local w, h = Layout:move("column2row1")

		just.clip(love.graphics.rectangle, "fill", 0, 0, w, h, 36)
		love.graphics.setColor(1, 1, 1, 1)
		BackgroundView.game = self.game
		BackgroundView:draw(w, h, 0, 0)
		love.graphics.draw(self.gradient, 0, 0, 0, w, h)
		just.clip()
	end,
}

local DownloadButton = {draw = function(self)
	local w, h = Layout:move("column2", "header")
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	local multiplayerModel = self.game.multiplayerModel
	local notechart = multiplayerModel.notechart
	if notechart.osuSetId and not multiplayerModel.noteChartItem and not multiplayerModel:isHost() then
		local beatmap = multiplayerModel.downloadingBeatmap
		if beatmap then
			just.text(beatmap.status, w, true)
		else
			just.indent(w - 144)
			if TextButtonImView("Download", "Download", 144, h) then
				multiplayerModel:downloadNoteChart()
			end
		end
	end
end}

local Title = {draw = function(self)
	local w, h = Layout:move("column2row2")
	love.graphics.translate(22, 0)
	local noteChartItem = self.game.selectModel.noteChartItem or self.game.multiplayerModel.notechart
	if not noteChartItem or not noteChartItem.title then
		return
	end
	TextCellImView(w, 52, "left", noteChartItem.artist, noteChartItem.title)
	TextCellImView(w, 52, "left", noteChartItem.creator, noteChartItem.name)
end}

local ModifierIconGrid = {
	draw = function(self)
		local w, h = Layout:move("column2row3")
		-- drawFrameRect(w, h)
		love.graphics.translate(21, 4)

		local modifierModel = self.game.modifierModel

		ModifierIconGridView.game = self.game
		ModifierIconGridView:draw(modifierModel.config, w - 42, h, h - 8)
	end,
}

local Header = {draw = function(self)
	local w, h = Layout:move("column1", "header")

	local username = self.game.configModel.configs.online.user.name
	local session = self.game.configModel.configs.online.session
	just.row(true)
	if UserInfoView:draw(w, h, username, session and session.active) then
		self.game.gameView:setModal(require("sphere.views.OnlineView"))
	end
	just.offset(0)

	LogoImView("logo", h, 0.5)
	if IconButtonImView("quit game", "clear", h, 0.5) then
		love.event.quit()
	end
	just.row(false)
end}

local RoomUsersList = {
	draw = function(self)
		local w, h = Layout:move("column1")

		RoomUsersListView.game = self.game
		RoomUsersListView:draw(w, h)
	end,
}

local noRoom = {
	name = "No room"
}
local noUser = {}
local RoomInfo = {draw = function(self)
	local w, h = Layout:move("column2", "header")

	local multiplayerModel = self.game.multiplayerModel
	local room = multiplayerModel.room or noRoom

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	gfx_util.printFrame(room.name, 22, 0, w, h, "left", "center")
end}

local RoomSettings = {draw = function(self)
	local w, h = Layout:move("column3")

	local multiplayerModel = self.game.multiplayerModel
	local room = multiplayerModel.room or noRoom
	local user = multiplayerModel.user or noUser

	love.graphics.translate(0, 36)

	local isHost = multiplayerModel:isHost()
	if isHost then
		if CheckboxImView("Free chart", room.isFreeNotechart, 72, 0.5) then
			multiplayerModel:setFreeNotechart(not room.isFreeNotechart)
		end
		just.sameline()
		LabelImView("Free chart", "Free chart", 72)

		if CheckboxImView("Free mods", room.isFreeModifiers, 72, 0.5) then
			multiplayerModel:setFreeModifiers(not room.isFreeModifiers)
		end
		just.sameline()
		LabelImView("Free mods", "Free mods", 72)

		just.emptyline(36)
	end

	if CheckboxImView("Ready", user.isReady, 72, 0.5) then
		multiplayerModel:switchReady()
	end
	just.sameline()
	LabelImView("Ready", "Ready", 72)

	w, h = Layout:move("column3")
	love.graphics.translate(36, h - 72 * 3)

	if isHost or room.isFreeNotechart then
		if TextButtonImView("Select chart", "Select", w - 72, 72) then
			self.screenView:changeScreen("selectView")
		end
	end
	if isHost or room.isFreeModifiers then
		if TextButtonImView("Modifiers", "Modifiers", w - 72, 72) then
			self.game.gameView:setModal(require("sphere.views.ModifierView"))
		end
	end

	w, h = Layout:move("column3")
	love.graphics.translate(36, h - 72)
	if isHost then
		if not room.isPlaying and TextButtonImView("Start match", "Start match", w - 72, 72) then
			multiplayerModel:startMatch()
		elseif room.isPlaying and TextButtonImView("Stop match", "Stop match", w - 72, 72) then
			multiplayerModel:stopMatch()
		end
	end
end}

local ChatWindow = {
	message = "",
	messageIndex = 1,
	draw = function(self)
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

		local scroll = just.wheel_over(self, just.is_over(w, h))

		self.scroll = self.scroll or 0
		love.graphics.translate(0, -self.scroll)

		local startHeight = just.height

		for i = 1, #roomMessages do
			local message = roomMessages[i]
			just.text(message)
		end

		self.height = just.height - startHeight
		just.clip()

		local content = self.height
		local overlap = math.max(content - h, 0)
		if overlap > 0 then
			if scroll then
				self.scroll = math.min(math.max(self.scroll - scroll * 50, 0), overlap)
			elseif self.messageCount ~= #roomMessages then
				self.scroll = overlap
				self.messageCount = #roomMessages
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
		changed, self.message, self.messageIndex, left, right = just.textinput(self.message, self.messageIndex)
		just.text(left)
		love.graphics.line(0, 0, 0, lineHeight)
		just.text(right)
		just.row(false)

		if changed then
			self.scroll = overlap
		end
		if just.keypressed("return") then
			multiplayerModel:sendMessage(self.message)
			self.message = ""
		end
	end,
}

return {
	Layout,
	Background,
	Frames,
	BackgroundBanner,
	DownloadButton,
	Cells,
	ModifierIconGrid,
	ScreenMenu,
	Title,
	Header,
	RoomInfo,
	RoomSettings,
	RoomUsersList,
	ChatWindow,
}
