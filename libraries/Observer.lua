Observer = {}

Observer.new = function(self)
	local observer = {}
	
	setmetatable(observer, self)
	self.__index = self
	
	return observer
end

Observer.receiveEvent = function(self, event) end

Observable = Observer:new()

Observable.new = function(self)
	local observable = {}
	observable.observers = {}
	
	setmetatable(observable, self)
	self.__index = self
	
	return observable
end

Observer.subscribe = function(self, observable)
	observable:addObserver(self)
end

Observable.getGlobal = function(self)
	self.globalObservable = self.globalObservable or Observable:new()
	return self.globalObservable
end

Observable.addObserver = function(self, observer)
	self.observers[observer] = true
end

Observable.removeObserver = function(self, observer)
	self.observers[observer] = nil
end

Observable.sendEvent = function(self, event)
	local observers = {}
	
	for observer in pairs(self.observers) do
		table.insert(observers, observer)
	end
	
	for _, observer in pairs(observers) do
		observer:receiveEvent(event)
	end
end

Observable.receiveEvent = Observable.sendEvent