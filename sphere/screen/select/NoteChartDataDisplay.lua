local Button = require("sphere.ui.Button")

local NoteChartDataDisplay = Button:new()

NoteChartDataDisplay.loadGui = function(self)
	self.field = self.data.field

	Button.loadGui(self)
end

NoteChartDataDisplay.receive = function(self, event)
	if event.action == "updateMetaData" then
		self.text = event.noteChartDataEntry[self.field] or ""
		self:reload()
	end
	Button.receive(self, event)
end

return NoteChartDataDisplay
