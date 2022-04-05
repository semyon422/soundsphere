
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local baseline_print = require("aqua.graphics.baseline_print")
local spherefonts		= require("sphere.assets.fonts")
local TextInput = require("aqua.util.TextInput")

local SearchFieldView = Class:new()

SearchFieldView.load = function(self)
	local state = self.state
	state.textInput = TextInput:new()
	state.textInput:setText(self.gameController.searchModel.searchString)
end

SearchFieldView.receive = function(self, event)
	if not (event.name == "textinput" or event.name == "keypressed" and event[1] == "backspace") then
		return
	end

	local state = self.state
	state.textInput:receive(event)
	self.navigator:setSearchString(state.textInput.text)
end

SearchFieldView.update = function(self)
	self.state.textInput:setText(self.gameController.searchModel.searchString)
end

SearchFieldView.draw = function(self)
	local searchModel = self.gameController.searchModel
	local noteChartSetLibraryModel = self.gameController.noteChartSetLibraryModel
	local config = self.config

	local tf = transform(config.transform):translate(config.x, config.y)
	love.graphics.replaceTransform(tf)
	tf:release()

	local searchString = searchModel.searchString
	if searchString == "" then
		love.graphics.setColor(1, 1, 1, 0.5)
		searchString = "Search..."
	else
		love.graphics.setColor(1, 1, 1, 1)
	end

	local font = spherefonts.get(config.text.font)
	love.graphics.setFont(font)
	baseline_print(
		searchString,
		config.text.x,
		config.text.baseline,
		config.text.limit,
		1,
		config.text.align
	)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setLineWidth(config.frame.lineWidth)
	love.graphics.setLineStyle(config.frame.lineStyle)
	love.graphics.rectangle(
		"line",
		config.frame.x,
		config.frame.y,
		config.frame.w,
		config.frame.h,
		config.frame.h / 2,
		config.frame.h / 2
	)

	if searchModel.searchMode == "lamp" then
		love.graphics.circle(
			"line",
			config.frame.x + config.frame.w - config.frame.h / 2,
			config.frame.y + config.frame.h / 2,
			config.point.r
		)
		love.graphics.circle(
			"fill",
			config.frame.x + config.frame.w - config.frame.h / 2,
			config.frame.y + config.frame.h / 2,
			config.point.r
		)
	end

	if noteChartSetLibraryModel.collapse then
		love.graphics.circle(
			"line",
			config.frame.x + config.frame.w - config.frame.h,
			config.frame.y + config.frame.h / 2,
			config.point.r
		)
	end
end

return SearchFieldView
