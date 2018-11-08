Score = createClass(soul.SoulObject)

Score.load = function(self)
	self.observer:subscribe(self.engine.observable)
	
	self.combo = 0
end

Score.receiveEvent = function(self, event)
	if event.name == "logicalNoteUpdated" then
		local state = event.logicalNote.state
		if
			state == "passed" or
			state == "startPassedPressed"
		then
			if self.combo == 0 then
				print("starting new combo")
			end
			self.combo = self.combo + 1
		elseif
			state == "missed" or
			state == "startMissed" or
			state == "startMissedPressed" or
			state == "startMissed" or
			state == "endMissed"
		then
			print("combo breaked: " .. self.combo)
			self.combo = 0
		end
	end
end

Score.unload = function(self)
	print("latest combo: " .. self.combo)
end