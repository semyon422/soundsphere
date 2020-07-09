local json			= require("json")
local Class			= require("aqua.util.Class")
local StaticImage	= require("sphere.ui.StaticImage")
local Button		= require("sphere.ui.Button")
local ImageButton	= require("sphere.ui.ImageButton")

local GUI = Class:new()

GUI.classes = {
	StaticImage = StaticImage,
	Button = Button,
	ImageButton = ImageButton
}
GUI.classes.__index = GUI.classes

GUI.functions = {
	["print"] = function(...) print(...) end
}
GUI.functions.__index = GUI.functions

GUI.load = function(self, path)
	local file = io.open(path, "r")
	local t = json.decode(file:read("*all"))
	file:close()

	self:loadTable(t)
end

GUI.loadTable = function(self, t)
	self.jsonData = t

	self.objects = {}
	
	for _, objectData in ipairs(self.jsonData) do
		local Object = self.classes[objectData.class]
		if Object then
			local object = Object:new()
			object.data = objectData
			object.gui = self
			object:loadGui()
			self.objects[#self.objects + 1] = object
		end
	end
end

GUI.update = function(self, dt)
	for _, object in ipairs(self.objects) do
		object:update(dt)
	end
end

GUI.unload = function(self)
	for _, object in ipairs(self.objects) do
		object:unload()
	end
end

GUI.reload = function(self)
	for _, object in ipairs(self.objects) do
		object:reload()
	end
end

GUI.receive = function(self, event)
	for _, object in ipairs(self.objects) do
		object:receive(event)
	end
end

return GUI
