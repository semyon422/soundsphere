local Class = require("Class")
local Changes = require("Changes")

local EditorChanges = Class:new()

EditorChanges.construct = function(self)
	self.changes = Changes:new()
end

EditorChanges.undo = function(self)
	for i in self.changes:undo() do
		self.layerData:syncChanges(i - 1)
		print("undo i", i - 1)
	end
	self.graphicEngine:reset()
	print("undo", self.changes)
end

EditorChanges.redo = function(self)
	for i in self.changes:redo() do
		self.layerData:syncChanges(i)
		print("redo i", i)
	end
	self.graphicEngine:reset()
	print("redo", self.changes)
end

EditorChanges.reset = function(self)
	self.changes:reset()
	self.layerData:resetRedos()
end

EditorChanges.add = function(self)
	local i = self.changes:add()
	self.layerData:syncChanges(i)
	print("add i", i)
end

EditorChanges.next = function(self)
	self.changes:next()
	print("next", self.changes)
end

return EditorChanges
