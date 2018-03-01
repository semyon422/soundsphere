soul = {}

require("soul.SoulObject")
require("soul.CS")
require("soul.Thread")
require("soul.graphics")
require("soul.ui")

soul.objects = {}
soul.callbacks = {}
soul.waitingCallbacks = {}

local callbackNames = {
	"keypressed",
	"keyreleased",
	"mousepressed",
	"mousemoved",
	"mousereleased",
	"wheelmoved",
	"resize",
	"quit"
}

soul.init = function()
	love.run = soul.run
	love.update = soul.update
	love.draw = soul.draw
	
	for _, name in pairs(callbackNames) do
		soul.callbacks[name] = soul.callbacks[name] or {}
		soul.waitingCallbacks[name] = soul.waitingCallbacks[name] or {}
		love[name] = function(...)
			soul.inCallback = true
			for _, callback in pairs(soul.callbacks[name]) do
				callback(...)
			end
			soul.inCallback = false
			soul.processWaitingCallbacks()
		end
	end
end

soul.inCallback = false

soul.setCallback = function(callbackName, index, callback)
	if not soul.inCallback then
		soul.callbacks[callbackName][index] = callback
	else
		soul.waitingCallbacks[callbackName][index] = callback
	end
end

soul.unsetCallback = function(callbackName, index)
	soul.callbacks[callbackName][index] = nil
end

soul.processWaitingCallbacks = function()
	for _,  callbackName in ipairs(callbackNames) do
		for index, callback in pairs(soul.waitingCallbacks[callbackName]) do
			soul.callbacks[callbackName][index] = callback
			soul.waitingCallbacks[callbackName][index] = nil
		end
	end
end

soul.run = function()
	love.math.setRandomSeed(os.time())
	love.timer.step()

	while true do
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
		
		love.timer.step()
		love.update(love.timer.getDelta())
		
		if love.graphics and love.graphics.isActive() then
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.origin()
			if love.draw then love.draw() end
			love.graphics.present()
		end
	end
end

soul.update = function(deltaTime)
	soul.deltaTime = deltaTime
	for _, object in pairs(soul.objects) do
		object:update()
	end
end

soul.draw = function()
	local layersInit = {}
	for _, object in pairs(soul.graphics.objects) do
		if object.layer and not layersInit[object.layer] then
			layersInit[object.layer] = true
		end
	end
	
	local layers = {}
	for layer in pairs(layersInit) do
		table.insert(layers, layer)
	end
	table.sort(layers)
	
	for _, layer in ipairs(layers) do
		for _, object in pairs(soul.graphics.objects) do
			if object.layer == layer then
				object:draw()
			end
		end
	end
end