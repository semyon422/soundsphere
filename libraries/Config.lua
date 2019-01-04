Config = createClass()

Config.read = function(self, filePath)
	local file = io.open(filePath, "r")
	self.data = json.decode(file:read("*all"))
	file:close()
	
	return self
end

Config.write = function(self, filePath)
	local file = io.open(filePath, "w")
	print(json.encode(self.data))
	file:write(json.encode(self.data))
	file:close()
	
	return self
end