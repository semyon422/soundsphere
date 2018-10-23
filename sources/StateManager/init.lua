StateManager = {}

StateManager_metatable = {}
StateManager_metatable.__index = StateManager

StateManager.new = function(self)
	local state = {}
	
	state.states = {}
	state.currentStateId = nil
	
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
	if self.currentStateId then
		self.states[self.currentStateId]:deactivate()
	end
	self.currentStateId = stateId
	self.states[self.currentStateId]:activate()
end