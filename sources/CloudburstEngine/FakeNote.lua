CloudburstEngine.FakeNote = createClass(CloudburstEngine.LogicalNote)
local FakeNote = CloudburstEngine.FakeNote

FakeNote.update = function(self)
	if self.state == "skipped" then
		return
	end
	
	self.state = "skipped"
	self:next()
end