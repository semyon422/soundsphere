local print = global.print

load = function() end

unload = function() end

receive = function(event)
	if event.name == "Notification" then
		print(event.message)
	end
end

update = function(dt) end

draw = function() end