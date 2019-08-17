local Class	= require("aqua.util.Class")
local json	= require("json")

local InputManager = Class:new()

InputManager.filePath = "userdata/input.json"

InputManager.load = function(self)
	local file = io.open(self.filePath, "r")
	local jsonData = json.decode(file:read("*all"))
	file:close()
	
	self.data = {}
	for _, keyData in ipairs(jsonData) do
		self.data[keyData[2]] = self.data[keyData[2]] or {}
		table.insert(self.data[keyData[2]], keyData[1])
	end
end

InputManager.receive = function(self, event, object)
	if event.name == "keypressed" or event.name == "keyreleased" then
		local key = event.args[1]
		local keyData = self.data[key]
		if keyData then
			local args = {unpack(event.args)}
			local newEvent = {
				name = event.name,
				args = args
			}
			
			for _, key in ipairs(keyData) do
				args[1] = key
				object:receive(newEvent)
			end
		end
	end
end

return InputManager
