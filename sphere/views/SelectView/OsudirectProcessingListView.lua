local ListView = require("sphere.views.ListView")

local OsudirectProcessingListView = ListView:new()

OsudirectProcessingListView.reloadItems = function(self)
	self.items = self.game.osudirectModel.processing
end

return OsudirectProcessingListView
