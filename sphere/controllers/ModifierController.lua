local Class = require("aqua.util.Class")
local ScreenManager			= require("sphere.screen.ScreenManager")

local ModifierController = Class:new()


ModifierController.construct = function(self)
end

ModifierController.load = function(self)
	local modifierModel = self.modifierModel
	local noteSkinModel = self.noteSkinModel
	local noteChartModel = self.noteChartModel
	local inputModel = self.inputModel
	local cacheModel = self.cacheModel
	local themeModel = self.themeModel
	local configModel = self.configModel
	local mountModel = self.mountModel
	local scoreModel = self.scoreModel
	local onlineModel = self.onlineModel
	local difficultyModel = self.difficultyModel
	local noteChartSetLibraryModel = self.noteChartSetLibraryModel
	local noteChartLibraryModel = self.noteChartLibraryModel
	local scoreLibraryModel = self.scoreLibraryModel
	local searchLineModel = self.searchLineModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("ModifierView")
	self.view = view

	view.controller = self
	view.themeModel = themeModel
	view.noteChartModel = noteChartModel
	view.modifierModel = modifierModel
	view.noteSkinModel = noteSkinModel
	view.inputModel = inputModel
	view.cacheModel = cacheModel
	view.configModel = configModel
	view.mountModel = mountModel
	view.scoreModel = scoreModel
	view.onlineModel = onlineModel
	view.noteChartSetLibraryModel = noteChartSetLibraryModel
	view.noteChartLibraryModel = noteChartLibraryModel
	view.scoreLibraryModel = scoreLibraryModel
	view.searchLineModel = searchLineModel

	-- modifierModel:load()
	noteChartModel:select()

	view:load()
end

ModifierController.unload = function(self)
	-- self.modifierModel:unload()
	self.view:unload()
end

ModifierController.update = function(self, dt)
	self.view:update(dt)
end

ModifierController.draw = function(self)
	self.view:draw()
end

ModifierController.receive = function(self, event)
	self.view:receive(event)

	if event.name == "enableBooleanModifier" then
		event.modifier.enabled = event.value
	elseif event.name == "enableNumberModifier" then
		event.modifier[event.modifier.variableName] = event.value
	elseif event.name == "disableNumberModifier" then
		event.modifier[event.modifier.variableName] = event.Modifier[event.modifier.variableName]
	elseif event.name == "addModifier" then
		self.modifierModel:add(event.modifierConfig)
	elseif event.name == "removeModifier" then
		self.modifierModel:remove(event.modifierConfig)
	elseif event.name == "setModifierValue" then
		self.modifierModel:setModifierValue(event.modifierConfig, event.value)
	elseif event.name == "adjustDifficulty" then
		self:adjustDifficulty()
	elseif event.name == "playNoteChart" then
		self:playNoteChart()
	end
end

ModifierController.playNoteChart = function(self)
	local noteChartModel = self.noteChartModel
	local info = love.filesystem.getInfo(noteChartModel.noteChartEntry.path)
	if not info then
		return
	end

	local GameplayController = require("sphere.controllers.GameplayController")
	local gameplayController = GameplayController:new()
	gameplayController.noteChartModel = noteChartModel
	gameplayController.themeModel = self.themeModel
	gameplayController.modifierModel = self.modifierModel
	gameplayController.configModel = self.configModel
	gameplayController.notificationModel = self.notificationModel
	gameplayController.scoreModel = self.scoreModel
	gameplayController.onlineModel = self.onlineModel
	gameplayController.difficultyModel = self.difficultyModel
	gameplayController.selectController = self
	return ScreenManager:set(gameplayController)
end

ModifierController.adjustDifficulty = function(self)
	local noteChartModel = self.noteChartModel
	local difficultyModel = self.difficultyModel
	local scoreModel = self.scoreModel
	local modifierModel = self.modifierModel
	local configModel = self.configModel
	local selectController = self.selectController

	local score
	local scores = scoreModel:getScoreEntries(
		noteChartModel.noteChartDataEntry.hash,
		noteChartModel.noteChartDataEntry.index
	)
	if not scores or not scores[1] then
		selectController:loadModifiedNoteChart()
		local performance = configModel:getConfig("settings").select.adjustDifficultyPerformance
		local difficulty = difficultyModel:getDifficulty(noteChartModel.noteChart)
		if difficulty == 0 or difficulty ~= difficulty then
			return
		end
		score = difficulty / performance * 1000000
	else
		score = scores[1].score
	end

	if score == 0 or score > 100000 then
		return
	end

	local accuracy = configModel:get("select.adjustDifficultyAccuracy")
	local timeRate = math.floor(accuracy / score * 1000 * 100) / 100

	local TimeRateX = require("sphere.models.ModifierModel.TimeRateX")
	for _, modifier in ipairs(modifierModel.inconsequential) do
		if modifier.Class == TimeRateX then
			modifier[modifier.variableName] = timeRate
			break
		end
	end
end

return ModifierController
