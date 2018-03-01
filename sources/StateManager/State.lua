StateManager.State = {}

StateManager.State_metatable = {}
StateManager.State_metatable.__index = StateManager.State

StateManager.State.new = function(self, activate, deactivate)
	local state = {}
	
	state.activate = activate or {}
	state.deactivate = deactivate or {}
	
	setmetatable(state, StateManager.State_metatable)
	
	return state
end

StateManager.State.switch = function(self)
	if type(self.deactivate) == "table" then
		for _, object in pairs(self.deactivate) do
			object:deactivate()
		end
	elseif type(self.deactivate) == "function" then
		self.deactivate()
	end
	if type(self.activate) == "table" then
		for _, object in pairs(self.activate) do
			object:activate()
		end
	elseif type(self.activate) == "function" then
		self.activate()
	end
end