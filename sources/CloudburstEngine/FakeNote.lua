CloudburstEngine.FakeNote = createClass(CloudburstEngine.LogicalNote)
local FakeNote = CloudburstEngine.FakeNote

FakeNote.update = function(self)
	if self.state == "passed" then
		return
	end
	
	self.state = "passed"
	self:next()
end