local class = require("class")
local Changes = require("Changes")

---@class sphere.EditorChanges
---@operator call: sphere.EditorChanges
local EditorChanges = class()

function EditorChanges:new()
	self.changes = Changes()
end

function EditorChanges:undo()
	for i in self.changes:undo() do
		self.editorModel.layerData:syncChanges(i - 1)
		print("undo i", i - 1)
	end
	self.editorModel.graphicEngine:reset()
	print("undo", self.changes)
end

function EditorChanges:redo()
	for i in self.changes:redo() do
		self.editorModel.layerData:syncChanges(i)
		print("redo i", i)
	end
	self.editorModel.graphicEngine:reset()
	print("redo", self.changes)
end

function EditorChanges:reset()
	self.changes:reset()
	self.editorModel.layerData:resetRedos()
end

function EditorChanges:add()
	local i = self.changes:add()
	self.editorModel.layerData:syncChanges(i)
	print("add i", i)
end

function EditorChanges:next()
	self.changes:next()
	print("next", self.changes)
end

return EditorChanges
