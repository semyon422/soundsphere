local Class = require("aqua.util.Class")

local ModifierController = Class:new()


ModifierController.construct = function(self)
end

ModifierController.load = function(self)
	local noteChartModel = self.gameController.noteChartModel
	local themeModel = self.gameController.themeModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("ModifierView")
	self.view = view

	view.controller = self
	view.noteChartModel = noteChartModel
	view.modifierModel = self.gameController.modifierModel
	view.configModel = self.gameController.configModel
	view.backgroundModel = self.gameController.backgroundModel

	noteChartModel:select()

	view:load()
end

ModifierController.unload = function(self)
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

	if event.name == "addModifier" then
		self.gameController.modifierModel:add(event.modifierConfig, event.index)
	elseif event.name == "removeModifier" then
		self.gameController.modifierModel:remove(event.modifierConfig)
	elseif event.name == "setModifierValue" then
		self.gameController.modifierModel:setModifierValue(event.modifierConfig, event.value)
	elseif event.name == "adjustDifficulty" then
		self:adjustDifficulty()
	elseif event.name == "goSelectScreen" then
		return self.gameController.screenManager:set(self.selectController)
	end
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
