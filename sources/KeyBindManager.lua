KeyBindManager = createClass(soul.SoulObject)

KeyBindManager.setBinding = function(self, key, pressed, released, enabled)
	self.bindings[key] = {
		pressed = pressed,
		released = released,
		enabled = enabled
	}
end

KeyBindManager.enableBinding = function(self, key, enabled)
	self.bindings[key].enabled = enabled
end

KeyBindManager.load = function(self)
	self.bindings = {}
end

KeyBindManager.receiveEvent = function(self, event)
	local key = event.data and event.data[1]
	
	if event.name == "love.keypressed" then
		for bindedKey, binding in pairs(self.bindings) do
			if binding.enabled and key == bindedKey and binding.pressed then
				binding.pressed()
			end
		end
	elseif event.name == "love.keyreleased" then
		for bindedKey, binding in pairs(self.bindings) do
			if binding.enabled and key == bindedKey and binding.released then
				binding.released()
			end
		end
	end
end