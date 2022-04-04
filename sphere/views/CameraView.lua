local Class = require("aqua.util.Class")
local s3dc = require("s3dc")

local CameraView = Class:new()

CameraView.sensitivity = 0.5
CameraView.speed = 500

CameraView.load = function(self)
	local state = self.state
	local config = self.config

	local perspective = self.gameController.configModel.configs.settings.graphics.perspective
	state.camera = perspective.camera
	if not state.camera or not config.draw_start then
		return
	end
	self:loadCamera()
end

CameraView.loadCamera = function(self)
	local state = self.state
	s3dc.load()
	local w, h = love.graphics.getDimensions()
	state.w, state.h = w, h
	local perspective = self.gameController.configModel.configs.settings.graphics.perspective
	s3dc.translate(perspective.x * w, perspective.y * h, perspective.z * h)
	s3dc.rotate(perspective.pitch, perspective.yaw)
end

CameraView.unload = function(self)
	local state = self.state
	local config = self.config

	if not state.camera or not config.draw_start then
		return
	end

	local w, h = state.w, state.h
	local x, y, z = unpack(s3dc.pos)
	x = x / w
	y = y / h
	z = z / h
	self.navigator:saveCamera(x, y, z, s3dc.angle.pitch, s3dc.angle.yaw)
	self.state = state  -- bug fix when calling from receive
	--[[
		saveCamera sends state, calls receive of playfield and changes self.state because there are 2 cameras
	]]
end

CameraView.receive = function(self, event)
	local state = self.state
	local config = self.config

	if not config.draw_start then
		return
	end

	if event.name == "keypressed" and state.camera then
		local key = event[2]
		if key == "f10" then
			s3dc.show(0, 0, love.graphics.getDimensions())
		elseif key == "f9" then
			state.moveCamera = not state.moveCamera
		end
	elseif event.name == "mousepressed" and state.moveCamera then
		local button = event[3]
		if button == 1 then
			state.dragging = true
			love.mouse.setRelativeMode(true)
		end
	elseif event.name == "mousereleased" and state.moveCamera then
		local button = event[3]
		if button == 1 then
			state.dragging = false
			love.mouse.setRelativeMode(false)
		end
	elseif event.name == "mousemoved" and state.dragging and state.camera and state.moveCamera then
		local dx, dy = event[3], event[4]
		local angle = self.sensitivity

		local perspective = self.gameController.configModel.configs.settings.graphics.perspective
		if not perspective.ry then
			dy = 0
		end
		if not perspective.rx then
			dx = 0
		end
		s3dc.rotate(math.rad(-dy) * angle, math.rad(dx) * angle)
	end
end

CameraView.update = function(self, dt)
	local state = self.state
	local config = self.config

	if not config.draw_start then
		return
	end

	local w, h = love.graphics.getDimensions()
	if state.w ~= w or state.h ~= h then
		self:unload()
		self:loadCamera()
	end

	if not state.camera or not state.moveCamera then
		return
	end

	local dx = self.speed * dt
	if love.keyboard.isDown("a") then
		s3dc.left(dx)
	elseif love.keyboard.isDown("d") then
		s3dc.right(dx)
	end
	if love.keyboard.isDown("w") then
		s3dc.forward(dx)
	elseif love.keyboard.isDown("s") then
		s3dc.backward(dx)
	end
	if love.keyboard.isDown("lshift") then
		s3dc.down(dx)
	elseif love.keyboard.isDown("space") then
		s3dc.up(dx)
	end
end

CameraView.draw = function(self)
	local config = self.config
	local state = self.state

	if not state.camera then
		return
	end

	if config.draw_start then
		s3dc.draw_start()
	end
	if config.draw_end then
		s3dc.draw_end()
	end
end

return CameraView
