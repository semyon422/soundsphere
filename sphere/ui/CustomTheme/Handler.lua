local Handler = {}

Handler.receive = function(self, event)
	if self[event.name] and event.name ~= "receive" then
		self[event.name](event)
	end
end

Handler.print = function(self, event)
	print(event.name)
end

return Handler
