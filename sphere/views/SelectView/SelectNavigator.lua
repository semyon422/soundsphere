local Navigator = require("sphere.views.Navigator")

local SelectNavigator = Navigator:new({construct = false})

SelectNavigator.load = function(self)
	Navigator.load(self)
	self.activeList = "modifierList"
end

SelectNavigator.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local selectModel = self.game.selectModel
	local modifierModel = self.game.modifierModel
	local subscreen = self.screenView.subscreen
	local s = event[2]

	if self.screenView.modifierView.isOpen then
		if self.activeList == "modifierList" then
			if s == "up" then modifierModel:scrollModifier(-1)
			elseif s == "down" then modifierModel:scrollModifier(1)
			elseif s == "tab" then self.activeList = "availableModifierList"
			elseif s == "return" then
			elseif s == "backspace" then modifierModel:remove()
			elseif s == "right" then modifierModel:increaseModifierValue(nil, 1)
			elseif s == "left" then modifierModel:increaseModifierValue(nil, -1)
			end
		elseif self.activeList == "availableModifierList" then
			if s == "up" then modifierModel:scrollAvailableModifier(-1)
			elseif s == "down" then modifierModel:scrollAvailableModifier(1)
			elseif s == "tab" then self.activeList = "modifierList"
			elseif s == "return" then modifierModel:add()
			end
		end
		if s == "escape" or s == "f1" then self.screenView.modifierView:toggle(false) end
		return
	end

	if s == "f1" then self.screenView.modifierView:toggle(true)
	elseif s == "f2" then selectModel:scrollRandom()
	elseif s == "lctrl" then self.screenView:changeSearchMode()
	elseif s == "lshift" then selectModel:changeCollapse()
	end
	if subscreen == "notecharts" then
		if s == "up" then selectModel:scrollNoteChart(-1)
		elseif s == "down" then selectModel:scrollNoteChart(1)
		elseif s == "left" then selectModel:scrollNoteChartSet(-1)
		elseif s == "right" then selectModel:scrollNoteChartSet(1)
		elseif s == "pageup" then selectModel:scrollNoteChartSet(-10)
		elseif s == "pagedown" then selectModel:scrollNoteChartSet(10)
		elseif s == "home" then selectModel:scrollNoteChartSet(-math.huge)
		elseif s == "end" then selectModel:scrollNoteChartSet(math.huge)
		elseif s == "return" then self.screenView:play()
		elseif s == "lalt" then self.screenView:result()
		elseif s == "tab" then self.screenView:switchToCollections()
		end
	elseif subscreen == "collections" then
		if s == "up" or s == "left" then selectModel:scrollCollection(-1)
		elseif s == "down" or s == "right" then selectModel:scrollCollection(1)
		elseif s == "pageup" then selectModel:scrollCollection(-10)
		elseif s == "pagedown" then selectModel:scrollCollection(10)
		elseif s == "home" then selectModel:scrollCollection(-math.huge)
		elseif s == "end" then selectModel:scrollCollection(math.huge)
		elseif s == "return" or s == "tab" then self.screenView:switchToNoteCharts()
		end
	elseif subscreen == "osudirect" then
		local osudirect = self.screenView.sequenceView.viewById.OsudirectListView
		if s == "up" or s == "left" then osudirect:scroll(-1)
		elseif s == "down" or s == "right" then osudirect:scroll(1)
		elseif s == "pageup" then osudirect:scroll(-10)
		elseif s == "pagedown" then osudirect:scroll(10)
		elseif s == "home" then osudirect:scroll(-math.huge)
		elseif s == "end" then osudirect:scroll(math.huge)
		elseif s == "escape" or s == "tab" then self.screenView:switchToCollections()
		end
	end
end

return SelectNavigator
