Profiler = createClass(soul.SoulObject)

Profiler.receiveEvent = function(self, event)
	if event.name == "love.update" then
		if self.frame and not self.complete then
			self:stop()
			self.complete = true
		elseif not self.frame and love.keyboard.isDown("f11") then
			self:start()
			self.frame = true
			self.complete = false
		elseif self.complete and not love.keyboard.isDown("f11") then
			self.frame = false
		end
	elseif event.name == "love.keypressed" then
		if event.data[1] == "f12" then
			self:start()
		end
	elseif event.name == "love.keyreleased" then
		if event.data[1] == "f12" then
			self:stop()
		end
	end
end

Profiler.start = function(self)
	self.calls, self.total, self.this = {}, {}, {}
	debug.sethook(function(event)
		local i = debug.getinfo(2, "Sln")
		if i.what ~= 'Lua' then return end
		-- local func = i.name or (i.source..':'..i.linedefined)
		local func = i.source..':'..i.linedefined .. "\n" .. (i.name or "?")
		if event == 'call' then
			self.this[func] = os.clock()
		elseif self.this[func] then
			local time = os.clock() - self.this[func]
			self.total[func] = (self.total[func] or 0) + time
			self.calls[func] = (self.calls[func] or 0) + 1
		end
	end, "cr")
end

Profiler.stop = function(self)
	debug.sethook()
	local stats = {}
	for f, time in pairs(self.total) do
		table.insert(stats, {
			f, time, self.calls[f]
		})
	end
	table.sort(stats, function(a, b) return a[2] < b[2] end)
	print(("-"):rep(64))
	print("function, time, calls")
	for _, stat in ipairs(stats) do
		-- print(("%32s\t%.3f\t%d"):format(stat[1], stat[2], stat[3]))
		print(("%s\t%.3f\t%d"):format(stat[1], stat[2], stat[3]))
	end
end