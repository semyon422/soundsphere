local Button = require("sphere.ui.Button")

local CacheDataDisplay = Button:new()

CacheDataDisplay.loadGui = function(self)
	self.field = self.data.field

	Button.loadGui(self)
end

CacheDataDisplay.receive = function(self, event)
	if event.action == "updateMetaData" then
		self.text = event.entry[self.field] or ""
		self:reload()
	end
	Button.receive(self, event)
end

return CacheDataDisplay
