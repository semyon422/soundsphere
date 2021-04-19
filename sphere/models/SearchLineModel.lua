local Class					= require("aqua.util.Class")
local TextInput				= require("aqua.util.TextInput")

local SearchLineModel = Class:new()

SearchLineModel.searchString = ""

SearchLineModel.construct = function(self)
	self.textInput = TextInput:new()
end

SearchLineModel.receive = function(self, event)
	if event.name == "textinput" or event.name == "keypressed" and event.args[1] == "backspace" then
		self.textInput:receive(event)
		self.searchString = self.textInput.text:lower()
	end
end

SearchLineModel.setSearchString = function(self, text)
	self.searchString = text
	return self.textInput:setText(text)
end

return SearchLineModel
