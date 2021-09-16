local Class = require("aqua.util.Class")
local s3dc = require("s3dc")

local CameraView = Class:new()

CameraView.sensitivity = 0.5
CameraView.speed = 500

CameraView.load = function(self)
	local state = self.state

	local perspective = self.perspective
	state.camera = perspective.camera
	if not state.camera then
		return
	end
	self:loadCamera()
end

CameraView.loadCamera = function(self)
	s3dc.load()
	local w, h = love.graphics.getDimensions()
	local perspective = self.perspective
	s3dc.translate(perspective.x * w, perspective.y * h, perspective.z * h)
	s3dc.rotate(perspective.pitch, perspective.yaw)
end

CameraView.unload = function(self)
	local state = self.state

	if not state.camera then
		return
	end

	local w, h = love.graphics.getDimensions()
	local x, y, z = unpack(s3dc.pos)
	x = x / w
	y = y / h
	z = z / h
	self.navigator:saveCamera(x, y, z, s3dc.angle.pitch, s3dc.angle.yaw)
end

CameraView.receive = function(self, event)
	local state = self.state

	if event.name == "keypressed" and state.camera then
		local key = event.args[2]
		if key == "f10" then
			s3dc.show(0, 0, love.graphics.getDimensions())
		elseif key == "f9" then
			state.moveCamera = not state.moveCamera
		end
	elseif event.name == "mousepressed" and state.moveCamera then
		local button = event.args[3]
		if button == 1 then
			state.dragging = true
			love.mouse.setRelativeMode(true)
		end
	elseif event.name == "mousereleased" and state.moveCamera then
		local button = event.args[3]
		if button == 1 then
			state.dragging = false
			love.mouse.setRelativeMode(false)
		end
	elseif event.name == "mousemoved" and state.dragging and state.camera and state.moveCamera then
		local dx, dy = event.args[3], event.args[4]
		local angle = self.sensitivity

		local perspective = self.perspective
		if not perspective.ry then
			dy = 0
		end
		if not perspective.rx then
			dx = 0
		end
		s3dc.rotate(math.rad(-dy) * angle, math.rad(dx) * angle)
	elseif event.name == "resize" and state.camera then
		self:loadCamera()
	end
end

CameraView.update = function(self, dt)
	local state = self.state

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
