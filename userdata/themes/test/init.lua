local theme = {}

theme.newView = function(self, name)
    if name == "ResultView" then
        local ResultView = dofile(self.path .. "/views/ResultView.lua")
        local resultView = ResultView:new()
        resultView.path = self.path
        return resultView
    end
	return self.viewFactory:newView(name)
end

return function(self)
    self.newView = theme.newView
end

