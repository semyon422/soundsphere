local print = global.print

local view = {}

view.load = function() end

view.unload = function() end

view.receive = function(self, event)
	if event.name == "Notification" then
		print(event.message)
	end
end

view.update = function(self, dt) end

view.draw = function() end

return view
