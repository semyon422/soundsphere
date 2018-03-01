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
	
	soul.setCallback("keypressed", self, function(key)
		for bindedKey, binding in pairs(self.bindings) do
			if binding.enabled and key == bindedKey and binding.pressed then
				binding.pressed()
			end
		end
	end)
	soul.setCallback("keyreleased", self, function(key)
		for bindedKey, binding in pairs(self.bindings) do
			if binding.enabled and key == bindedKey and binding.released then
				binding.released()
			end
		end
	end)
	
	self.loaded = true
end

KeyBindManager.unload = function(self, key, binding)
	soul.setCallback("keypressed", self, nil)
	soul.setCallback("keyreleased", self, nil)
	
	self.loaded = false
end