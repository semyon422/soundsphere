local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")

local LightingView = Class:new()

LightingView.root = "."

local states = {"beforeStart", "afterStart", "between", "beforeEnd", "afterEnd"}

LightingView.load = function(self)
	local config = self.config
	local state = self.state

	local images = {}
	state.images = images
	for _, name in pairs(states) do
		local a = config[name]
		if a then
			local range = a.range
			a.frames = math.abs(range[2] - range[1]) + 1
			for i = range[1], range[2], range[1] < range[2] and 1 or -1 do
				local fileName = a.image:format(i)
				images[fileName] = images[fileName] or love.graphics.newImage(self.root .. "/" .. fileName)
			end
		end
	end

	state.startTime = 10
	state.endTime = 12
	state.currentTime = 8

	state.timeState = nil
end

LightingView.draw = function(self)
	local config = self.config
	local state = self.state

	local animation = state.animation
	if not animation then
		return
	end

	local tf = transform(config.transform)
	love.graphics.replaceTransform(tf)
	tf:release()

	local image = state.images[state.imageFileName]
	love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        image,
		animation.x,
		animation.y,
        0,
        animation.w / image:getWidth(),
	    animation.h / image:getHeight()
    )
end

LightingView.update = function(self, dt)
	local config = self.config
	local state = self.state

	state.currentTime = state.currentTime + dt

	local currentTime = state.currentTime
	local startTime = state.startTime
	local endTime = state.endTime

	local beforeStart = config.beforeStart
	local afterStart = config.afterStart
	local between = config.between
	local beforeEnd = config.beforeEnd
	local afterEnd = config.afterEnd

	local bs = currentTime - startTime < 0
	local as = currentTime - startTime > 0
	local be = currentTime - endTime < 0
	local ae = currentTime - endTime > 0
	if beforeStart then
		bs = (currentTime - startTime) * beforeStart.rate < -beforeStart.frames
	end
	if afterStart then
		as = (currentTime - startTime) * afterStart.rate > afterStart.frames
	end
	if beforeEnd then
		be = (currentTime - endTime) * beforeEnd.rate < -beforeEnd.frames
	end
	if afterEnd then
		ae = (currentTime - endTime) * afterEnd.rate > afterEnd.frames
	end

	-- check < <= > >=
	local animation
	if bs or ae then
		animation = nil
	elseif beforeStart and (currentTime - startTime) * beforeStart.rate < 0 then
		animation = beforeStart
	elseif afterStart and (currentTime - startTime) * afterStart.rate < afterStart.frames then
		animation = afterStart
	elseif between and as and be then
		animation = between
	elseif beforeEnd and (currentTime - endTime) * beforeStart.rate < 0 then
		animation = beforeEnd
	elseif afterEnd and (currentTime - endTime) * beforeStart.rate < afterEnd.frames then
		animation = afterEnd
	end
	state.animation = animation

	local frame
	local imageFileName
	local counter
	local time
	if animation == beforeStart then
		time = startTime
	elseif animation == afterStart then
		time = startTime
	elseif animation == between then
		time = startTime - afterStart.frames / afterStart.rate
	elseif animation == beforeEnd then
		time = endTime
	elseif animation == afterEnd then
		time = endTime
	end

	if animation then
		counter = math.floor((currentTime - time) * animation.rate)
		frame = counter % animation.frames * (animation.range[2] - animation.range[1]) / (animation.frames - 1) + animation.range[1]
		imageFileName = animation.image:format(frame)
	end

	state.imageFileName = imageFileName

	print(state.currentTime, frame, imageFileName)
end

LightingView.receive = function(self, event)
	local config = self.config
	local state = self.state
end

return LightingView
