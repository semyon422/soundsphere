local DropdownView = require("sphere.views.DropdownView")

local JudgementsDropdownView = DropdownView:new()

JudgementsDropdownView.load = function(self)
	self.items = {}
	for k in pairs(self.game.rhythmModel.scoreEngine.scoreSystem.judgement.judgementLists) do
		table.insert(self.items, k)
	end
	table.sort(self.items)
end

JudgementsDropdownView.getCount = function(self)
	return #self.items
end

JudgementsDropdownView.scroll = function(self, delta) end

JudgementsDropdownView.getPreview = function(self)
	return self.game.configModel.configs.select.judgements
end

JudgementsDropdownView.select = function(self, i)
	self.game.configModel.configs.select.judgements = self.items[i]
end

JudgementsDropdownView.getItemText = function(self, i)
	return self.items[i]
end

return JudgementsDropdownView
