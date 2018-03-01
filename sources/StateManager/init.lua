StateManager = {}

StateManager_metatable = {}
StateManager_metatable.__index = StateManager

StateManager.new = function(self)
	local state = {}
	
	state.states = {}
	
	setmetatable(state, StateManager_metatable)
	
	return state
end

require("StateManager.State")

StateManager.setState = function(self, state, stateId)
	self.states[stateId] = state
end

StateManager.getState = function(self, stateId)
	return self.states[stateId]
end

StateManager.switchState = function(self, stateId)
	self.states[stateId]:switch()
end