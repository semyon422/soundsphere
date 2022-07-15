local ListView = require("sphere.views.ListView")

local OsudirectProcessingListView = ListView:new({construct = false})

OsudirectProcessingListView.reloadItems = function(self)
	self.items = self.game.osudirectModel.processing
end

return OsudirectProcessingListView
