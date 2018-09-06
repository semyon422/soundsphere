CLI = createClass(soul.SoulObject)

CLI.focus = "CLI"
CLI.layer = 101
CLI.hidden = true

CLI.load = function(self)
	self.commands = {}
	self.log = {}
	self.currentLine = "hello"
	self.cs = soul.CS:new(nil, 0, 0, 0, 0, "all")
	
	self.rectangleObject = soul.graphics.Rectangle:new({
		x = 0,
		y = 0,
		w = 1,
		h = 0.5,
		color = {0, 0, 0, 127},
		layer = self.layer + 1,
		cs = self.cs,
		mode = "fill"
	})
	
	self.textObject = soul.graphics.Text:new({
		x = 0,
		y = 0.5,
		w = 0,
		h = 0,
		limit = math.huge,
		align = {x = "left", y = "top"},
		text = table.concat(self.log, "\n") .. "\n" .. self.currentLine,
		font = self.core.fonts.main16,
		color = {255, 255, 255, 255},
		layer = self.layer + 2,
		cs = self.cs
	})
	
	self:addDefaultCommands()
end

CLI.receiveEvent = function(self, event)
	if soul.focus[self.focus] and event.name == "love.update" then
		self.textObject.text = table.concat(self.log, "\n") .. "\n> " .. self.currentLine
	elseif soul.focus[self.focus] and event.name == "love.textinput" and event.data[1] ~= "`" then
		self.currentLine = self.currentLine .. event.data[1]
	elseif soul.focus[self.focus] and event.name == "love.keypressed" then
		if event.data[1] == "backspace" then
			local byteoffset = utf8.offset(self.currentLine, -1)
			if byteoffset then
				self.currentLine = string.sub(self.currentLine, 1, byteoffset - 1)
			end
		elseif event.data[1] == "return" then
			table.insert(self.log, self.currentLine)
			local args = self.currentLine:split(" ")
			local command = args[1]
			table.remove(args, 1)
			self.currentLine = ""
			self:runCommand(command, args)
		end
	end
end

CLI.unload = function(self)
	
end

CLI.show = function(self)
	self.hidden = false
	self.rectangleObject:activate()
	self.textObject:activate()
	
	self.soulFocusTable = soul.cloneFocusTable()
	soul.focus = {
		[self.focus] = true
	}
end

CLI.hide = function(self)
	self.hidden = true
	self.rectangleObject:deactivate()
	self.textObject:deactivate()
	soul.focus = self.soulFocusTable
end

CLI.switch = function(self)
	if self.hidden then
		self:show()
	else
		self:hide()
	end
end

CLI.print = function(self, line)
	table.insert(self.log, tostring(line))
end

CLI.runCommand = function(self, command, args)
	if self.commands[command] then
		self.commands[command](unpack(args or {}))
	else
		self:print("unknown command")
	end
end

CLI.addCommand = function(self, command, callback)
	self.commands[command] = callback
end

CLI.removeCommand = function(self, command)
	self.commands[command] = nil
end

CLI.addDefaultCommands = function(self)
	self:addCommand(
		"lua",
		function(...)
			local chunk = table.concat({...}, " ")
			local func, err = loadstring(chunk)
			if not func then
				self:print(err)
				return
			end
			local out = {pcall(func)}
			for _, value in pairs(out) do
				self:print(value)
			end
		end
	)
	self:addCommand(
		"hello",
		function()
			self:print("Hello, World!")
		end
	)
end