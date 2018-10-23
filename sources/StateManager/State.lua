StateManager.State = {}

StateManager.State_metatable = {}
StateManager.State_metatable.__index = StateManager.State

StateManager.State.new = function(self, activateData, deactivateData)
	local state = {}
	
	state.activateData = activateData or {}
	state.deactivateData = deactivateData or {}
	
	setmetatable(state, StateManager.State_metatable)
	
	return state
end

StateManager.State.deactivate = function(self)
	if type(self.deactivateData) == "table" then
		for _, object in pairs(self.deactivateData) do
			object:deactivate()
		end
	elseif type(self.deactivateData) == "function" then
		self.deactivateData()
	end
end

StateManager.State.activate = function(self)
	if type(self.activateData) == "table" then
		for _, object in pairs(self.activateData) do
			object:activate()
		end
	elseif type(self.activateData) == "function" then
		self.activateData()
	end
end