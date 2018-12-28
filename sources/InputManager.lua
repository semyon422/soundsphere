InputManager = createClass(soul.SoulObject)

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

InputManager.receiveEvent = function(self, event)
	if event.name == "love.keypressed" or event.name == "love.keyreleased" then
		local key = event.data[1]
		local keyData = self.data[key]
		if keyData then
			local data = {unpack(event.data)}
			
			for _, key in ipairs(keyData) do
				data[1] = key
				event:callback(unpack(data))
			end
		end
	end
end
