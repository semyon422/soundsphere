local CS = require("aqua.graphics.CS")
local Rectangle = require("aqua.graphics.Rectangle")
local Text = require("aqua.graphics.Text")
local aquafonts = require("aqua.assets.fonts")
local spherefonts = require("sphere.assets.fonts")
local clone = require("aqua.table").clone

local CLI = {}

CLI.hidden = true

CLI.init = function(self)
	self.commands = {}
	self.log = {}
	self.history = {}
	self.currentLine = {"h", "e", "l", "l", "o"}
	self.currentLineOffset = #self.currentLine
	self.historyOffset = 0
	self.cs = CS:new({
		bx = 0,
		by = 0,
		rx = 0,
		ry = 0,
		binding = "all"
	})
	
	self.font = aquafonts.getFont(spherefonts.NotoMonoRegular, 16)
	
	self.rectangleObject = Rectangle:new({
		x = 0,
		y = 0,
		w = 1,
		h = 1,
		color = {0, 0, 0, 191},
		cs = self.cs,
		mode = "fill"
	})
	self.rectangleObject:reload()
	
	self.textObject = Text:new({
		x = 0,
		y = 0.5,
		w = 0,
		h = 0,
		limit = 1,
		align = {x = "left", y = "top"},
		text = "",
		font = self.font,
		color = {255, 255, 255, 255},
		cs = self.cs,
		baseScale = 1
	})
	
	self.cursorObject = Text:new({
		x = 0,
		y = 0.5,
		w = 0,
		h = 0,
		limit = 1,
		align = {x = "left", y = "top"},
		text = "",
		font = self.font,
		color = {255, 255, 255, 255},
		cs = self.cs,
		baseScale = 1
	})
	
	self:addDefaultCommands()
	self:reload()
end

CLI.concatLog = function(self)
	local log = {}
	for i = #self.log, #self.log - self.cs:Y(0.5) / self.font:getHeight(), -1 do
		local line = self.log[i]
		if line then
			if type(line) == "function" then
				table.insert(log, 1, line())
			else
				table.insert(log, 1, tostring(line))
			end
		end
	end
	return table.concat(log, "\n")
end

CLI.update = function(self) end

CLI.updateText = function(self)
	self.textObject.text = self:concatLog() .. "\n> " .. table.concat(self.currentLine)
	self.cursorObject.text = (" "):rep(self.currentLineOffset) .. "  _"
	self:reload()
end

CLI.draw = function(self)
	if not self.hidden then
		self.rectangleObject:draw()
		self.textObject:draw()
		self.cursorObject:draw()
	end
end

CLI.reload = function(self)
	self.cs:reload()
	self.rectangleObject:reload()
	self.textObject:reload()
	self.cursorObject:reload()
end

CLI.receive = function(self, event)
	if event.name == "keypressed" and event.args[1] == "`" then
		self:switch()
	end
	
	if self.hidden then
		return
	end
	
	if event.name == "resize" then
		self:reload()
	elseif event.name == "textinput" and event.args[1] ~= "`" then
		self.currentLineOffset = self.currentLineOffset + 1
		table.insert(self.currentLine, self.currentLineOffset, event.args[1])
		self:updateText()
	elseif event.name == "keypressed" then
		local key = event.args[1]
		if key == "backspace" then
			if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
				self:removeLastWord()
			else
				self:removeLastSymbol()
			end
		elseif key == "return" then
			self:processCurrentLine()
		elseif key == "up" then
			if self.historyOffset > 1 then
				self.historyOffset = self.historyOffset - 1
			end
			if #self.history > 0 then
				self.currentLine = clone(self.history[self.historyOffset])
				self.currentLineOffset = #self.currentLine
			end
		elseif key == "down" then
			if self.historyOffset < #self.history then
				self.historyOffset = self.historyOffset + 1
			end
			if #self.history > 0 then
				self.currentLine = clone(self.history[self.historyOffset])
				self.currentLineOffset = #self.currentLine
			end
		elseif key == "left" then
			if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
				self:moveByWord("left")
			else
				self:moveBySymbol("left")
			end
		elseif key == "right" then
			if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
				self:moveByWord("right")
			else
				self:moveBySymbol("right")
			end
		elseif key == "end" then
			self.currentLineOffset = #self.currentLine
		elseif key == "home" then
			self.currentLineOffset = 0
		end
		self:updateText()
	end
end

CLI.moveBySymbol = function(self, direction)
	if direction == "left" then
		if self.currentLineOffset > 0 then
			self.currentLineOffset = self.currentLineOffset - 1
		end
	elseif direction == "right" then
		if self.currentLineOffset < #self.currentLine then
			self.currentLineOffset = self.currentLineOffset + 1
		end
	end
end

CLI.moveByWord = function(self, direction)
	if direction == "left" then
		while self.currentLineOffset > 0 and self.currentLine[self.currentLineOffset] ~= " " do
			self.currentLineOffset = self.currentLineOffset - 1
		end
		while self.currentLineOffset > 0 and self.currentLine[self.currentLineOffset] == " " do
			self.currentLineOffset = self.currentLineOffset - 1
		end
	elseif direction == "right" then
		while self.currentLineOffset < #self.currentLine and self.currentLine[self.currentLineOffset + 1] ~= " " do
			self.currentLineOffset = self.currentLineOffset + 1
		end
		while self.currentLineOffset < #self.currentLine and self.currentLine[self.currentLineOffset + 1] == " " do
			self.currentLineOffset = self.currentLineOffset + 1
		end
	end
end

CLI.removeLastSymbol = function(self)
	if #self.currentLine > 0 then
		table.remove(self.currentLine, self.currentLineOffset)
		self.currentLineOffset = self.currentLineOffset - 1
	end
end

CLI.removeLastWord = function(self)
	while #self.currentLine > 0 and self.currentLine[#self.currentLine] ~= " " do
		table.remove(self.currentLine, self.currentLineOffset)
		self.currentLineOffset = self.currentLineOffset - 1
	end
	while #self.currentLine > 0 and self.currentLine[#self.currentLine] == " " do
		table.remove(self.currentLine, self.currentLineOffset)
		self.currentLineOffset = self.currentLineOffset - 1
	end
end

CLI.processCurrentLine = function(self)
	table.insert(self.log, "> " .. table.concat(self.currentLine))
	local args = table.concat(self.currentLine):split(" ")
	local command = args[1]
	table.remove(args, 1)
	
	table.insert(self.history, self.currentLine)
	self.historyOffset = #self.history + 1
	
	self.currentLine = {}
	self.currentLineOffset = 0
	self:runCommand(command, args)
end

CLI.unload = function(self)
	
end

CLI.show = function(self)
	self.hidden = false
end

CLI.hide = function(self)
	self.hidden = true
end

CLI.switch = function(self)
	if self.hidden then
		self:show()
	else
		self:hide()
	end
end

CLI.print = function(self, line)
	table.insert(self.log, line)
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
	self:addCommand(
		"fps",
		function()
			self:print(function()
				return love.timer.getFPS()
			end)
		end
	)
	self:addCommand(
		"fullscreen",
		function(...)
			love.window.setFullscreen(not love.window.getFullscreen())
		end
	)
	
	local helpFunction = function()
		local cell = 0
		local commandSet = {}
		for key,value in pairs(self.commands) do
			cell = cell + 1
			commandSet[cell] = key
		end
		self:print("Available commands: ")
		self:print(table.concat(commandSet, ", "))
	end
	
	self:addCommand("help", helpFunction)
	self:addCommand("?", helpFunction)
end

return CLI
