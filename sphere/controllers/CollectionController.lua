local Class					= require("aqua.util.Class")

local CollectionController = Class:new()

CollectionController.load = function(self)
	local themeModel = self.gameController.themeModel
	local collectionModel = self.gameController.collectionModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("CollectionView")
	self.view = view

	view.controller = self
	view.cacheModel = self.gameController.cacheModel
	view.configModel = self.gameController.configModel
	view.backgroundModel = self.gameController.backgroundModel
	view.collectionModel = collectionModel

	collectionModel:load()

	view:load()
end

CollectionController.unload = function(self)
	self.view:unload()
end

CollectionController.update = function(self)
	self.view:update()
end

CollectionController.draw = function(self)
	self.view:draw()
end

CollectionController.receive = function(self, event)
	self.view:receive(event)

	if event.name == "setCollection" then
		self.gameController.collectionModel:setCollection(event.collection)
	elseif event.name == "goSelectScreen" then
		return self.gameController.screenManager:set(self.selectController)
	end
end

return CollectionController
