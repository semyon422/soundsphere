local theme = {}

theme.newView = function(self, name)
    if name == "SelectView" then
        local SelectView = dofile(self.path .. "/views/SelectView.lua")
        local selectView = SelectView:new()
        selectView.__path = self.path
        return selectView
    end
	return self.viewFactory:newView(name)
end

return function(self)
    self.newView = theme.newView
end
