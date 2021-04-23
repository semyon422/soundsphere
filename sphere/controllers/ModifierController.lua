local Class = require("aqua.util.Class")

local ModifierController = Class:new()

ModifierController.receive = function(self, event)
	if event.name == "enableBooleanModifier" then
		event.modifier.enabled = event.value
	elseif event.name == "enableNumberModifier" then
		event.modifier[event.modifier.variableName] = event.value
	elseif event.name == "disableNumberModifier" then
		event.modifier[event.modifier.variableName] = event.Modifier[event.modifier.variableName]
	elseif event.name == "addModifier" then
		self.modifierModel:add(event.Modifier)
	elseif event.name == "removeModifier" then
		self.modifierModel:remove(event.modifier)
	elseif event.name == "updateNumberModifier" then
		event.modifier[event.modifier.variableName] = event.value
	elseif event.name == "adjustDifficulty" then
		self:adjustDifficulty()
	elseif event.name == "decreaseTimeRate" then
		self:changeTimeRate(-0.05)
	elseif event.name == "increaseTimeRate" then
		self:changeTimeRate(0.05)
	end
end

ModifierController.changeTimeRate = function(self, delta)
	local modifierModel = self.modifierModel

	local TimeRateX = require("sphere.models.ModifierModel.TimeRateX")
	for _, modifier in ipairs(modifierModel.inconsequential) do
		if modifier.Class == TimeRateX then
			local timeRate = math.min(math.max(modifier[modifier.variableName] + delta, 0.5), 2)
			modifier[modifier.variableName] = timeRate
			break
		end
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
		local performance = configModel:get("select.adjustDifficultyPerformance")
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
