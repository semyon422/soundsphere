local aquafonts			= require("aqua.assets.fonts")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Rectangle			= require("aqua.graphics.Rectangle")
local Stencil			= require("aqua.graphics.Stencil")
local sign				= require("aqua.math").sign
local belong			= require("aqua.math").belong
local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local Theme				= require("aqua.ui.Theme")
local spherefonts		= require("sphere.assets.fonts")

local CustomList = Class:new()

CustomList.sender = "CustomList"
CustomList.needFocusToInteract = false

CustomList.visualItemIndex = 1
CustomList.focusedItemIndex = 1

CustomList.x = 0
CustomList.y = 0
CustomList.w = 1
CustomList.h = 1
CustomList.textColor = {255, 255, 255, 255}
CustomList.rectangleColor = {255, 255, 255, 0}
CustomList.mode = "fill"
CustomList.limit = 1
CustomList.textAlign = {
	x = "left", y = "center"
}
CustomList.buttonCount = 17
CustomList.middleOffset = 9
CustomList.startOffset = 9
CustomList.endOffset = 9

CustomList.construct = function(self)
	self.observable = Observable:new()
	self.font = aquafonts.getFont(spherefonts.NotoSansRegular, 24)
	self.items = {}
end

CustomList.load = function(self)
	self.scrollCurrentDelta = 0
	self:loadStencil()
	self.visualItemIndex = self.focusedItemIndex
	self:unloadButtons()
	self:calculateButtons()
end

CustomList.draw = function(self)
	self.stencil:draw()
	self.stencil:set("greater", 0)
	for button in pairs(self.buttons) do
		button:draw()
	end
	self.stencil:set()
end

CustomList.setItems = function(self, items)
	self.items = items
	
	local numItems = math.max(1, #items)
	if self.focusedItemIndex > numItems then
		self.focusedItemIndex = numItems
		self.visualItemIndex = numItems
	end
end

CustomList.unload = function(self)
	return self:unloadButtons()
end

CustomList.reload = function(self)
	self.buttonsFrame:reload()
	self:unloadButtons()
	self:calculateButtons()
end

CustomList.sendInitial = function(self)
	self:send({
		sender = self.sender,
		action = "scrollTarget",
		itemIndex = self.focusedItemIndex,
		list = self
	})
	self:send({
		sender = self.sender,
		action = "scrollStop",
		itemIndex = self.focusedItemIndex,
		list = self
	})
end

CustomList.update = function(self)
	local dt =  math.min(1/60, love.timer.getDelta())
	local sign = sign(self.scrollCurrentDelta)
	local scrollCurrentDelta = sign * math.max(math.abs(self.scrollCurrentDelta), 1) * 8 * dt
	
	if self.focusedItemIndex < 1 then
		self.focusedItemIndex = 1
	elseif self.focusedItemIndex > #self.items then
		self.focusedItemIndex = #self.items
	end
	
	if self.continueScrolling then
		scrollCurrentDelta = self.continueScrollDelta * 8 * dt
	end
	
	if (scrollCurrentDelta > 0 and self.visualItemIndex + scrollCurrentDelta > self.focusedItemIndex)
	or (scrollCurrentDelta < 0 and self.visualItemIndex + scrollCurrentDelta < self.focusedItemIndex)
	then
		self.visualItemIndex = self.focusedItemIndex
		self.scrollCurrentDelta = 0
		self:send({
			sender = self.sender,
			action = "scrollStop",
			itemIndex = self.focusedItemIndex,
			list = self
		})
	else
		self.visualItemIndex = self.visualItemIndex + scrollCurrentDelta
	end
	
	return self:calculateButtons()
end

CustomList.send = function(self, event)
	return self.observable:send(event)
end

CustomList.receive = function(self, event)
	if self.buttons then
		for button in pairs(self.buttons) do
			button:receive(event)
		end
	end
	
	if event.name == "resize" then
		self.buttonsFrame:reload()
	elseif event.name == "wheelmoved" then
		local mx = self.cs:x(love.mouse.getX(), true)
		local my = self.cs:y(love.mouse.getY(), true)
		if belong(mx, self.x, self.x + self.w) and belong(my, self.y, self.y + self.h) then
			self:scrollBy(-event.args[2])
		end
	elseif event.name == "keyreleased" then
		local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
		if not shift then
			self:stopContinueScrolling()
		end
	elseif event.name == "keypressed" then
		if self.keyControl then
			local key = event.args[1]
			local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
			if key == "home" then
				self:scrollToItemIndex(1)
			elseif key == "end" then
				self:scrollToItemIndex(#self.items)
			elseif key == "pageup" then
				if shift then
					self:continueScrollBy(-self.buttonCount)
				end
				self:scrollBy(-self.buttonCount)
			elseif key == "pagedown" then
				if shift then
					self:continueScrollBy(self.buttonCount)
				end
				self:scrollBy(self.buttonCount)
			elseif key == "up" then
				if shift then
					self:continueScrollBy(-1)
				end
				self:scrollBy(-1)
			elseif key == "down" then
				if shift then
					self:continueScrollBy(1)
				end
				self:scrollBy(1)
			elseif key == "return" then
				self:send({
					sender = self.sender,
					action = "return",
					itemIndex = self.focusedItemIndex,
					list = self
				})
			end
		end
	end
end

CustomList.getStartItemIndex = function(self)
	return math.floor(self.visualItemIndex) - self.startOffset
end

CustomList.getEndItemIndex = function(self)
	return math.ceil(self.visualItemIndex) + self.endOffset
end

CustomList.loadStencil = function(self)
	self.buttonsFrame = Rectangle:new({
		x = self.x, y = self.y,
		w = self.w, h = self.h,
		cs = self.cs,
		color = {255, 255, 255, 255},
		mode = "fill"
	})
	self.buttonsFrame:reload()
	
	self.stencil = Stencil:new({
		stencilfunction = function() self.buttonsFrame:draw() end,
		action = "replace",
		value = 1,
		keepvalues = false
	})
	self.stencil:reload()
end

CustomList.scrollToItemIndex = function(self, itemIndex, scrollCurrentDelta)
	if self.items[itemIndex] then
		self.focusedItemIndex = itemIndex
		self.scrollCurrentDelta = scrollCurrentDelta or (self.focusedItemIndex - self.visualItemIndex)
		
		self:send({
			sender = self.sender,
			action = "scrollTarget",
			itemIndex = itemIndex,
			list = self
		})
	end
end

CustomList.stopContinueScrolling = function(self, scrollDelta)
	if self.continueScrolling then
		self.continueScrolling = false
		local scrollTo
		if self.continueScrollDelta > 0 then
			scrollTo = math.ceil(self.visualItemIndex)
		else
			scrollTo = math.floor(self.visualItemIndex)
		end
		self:scrollToItemIndex(scrollTo, self.continueScrollDelta)
	end
end

CustomList.continueScrollBy = function(self, scrollDelta)
	self.continueScrolling = true
	self.continueScrollDelta = scrollDelta
	if scrollDelta > 0 then
		self.focusedItemIndex = #self.items
	elseif scrollDelta < 0 then
		self.focusedItemIndex = 1
	end
end

CustomList.scrollBy = function(self, scrollDelta)
	local itemIndex = self.focusedItemIndex + scrollDelta
	return self:scrollToItemIndex(
		math.min(math.max(itemIndex, 1), #self.items),
		itemIndex - self.visualItemIndex
	)
end

CustomList.calculateButtons = function(self)
	self.buttons = self.buttons or {}
	
	local itemIndexKeys = {}
	for button in pairs(self.buttons) do
		button:update()
		itemIndexKeys[button.itemIndex] = button
	end
	
	for itemIndex = self:getStartItemIndex(), self:getEndItemIndex() do
		local item = self.items[itemIndex]
		if item and not itemIndexKeys[itemIndex] then
			self:addButton(itemIndex)
		end
	end
end

CustomList.addButton = function(self, itemIndex)
	local item = self.items[itemIndex]
	
	local button = self.Button:new({
		itemIndex = itemIndex,
		item = item,
		text = item.name,
		interact = item.onClick,
		
		x = self.x, y = self.y,
		w = self.w, h = self.h / self.buttonCount,
		cs = self.cs,
		rectangleColor = self.rectangleColor,
		mode = self.mode,
		limit = self.limit,
		textAlign = self.textAlign,
		textColor = self.textColor,
		font = self.font,
		list = self,
	})
	button:reload()
	button:update()
	
	self.buttons[button] = button
end

CustomList.unloadButtons = function(self)
	self.buttons = nil
end

CustomList.Button = Theme.Button:new()

CustomList.Button.update = function(self)
	self.x = self.list.x
	self.y = self.list.y + (self.list.middleOffset - 1 + self.itemIndex - self.list.visualItemIndex) * (self.list.h / self.list.buttonCount)
	
	if self.itemIndex < self.list:getStartItemIndex() or
		self.itemIndex > self.list:getEndItemIndex()
	then
		self.list.buttons[self] = nil
	else
		return self:reload()
	end
end

CustomList.Button.interact = function(self, event)
	local mx = self.cs:x(love.mouse.getX(), true)
	local my = self.cs:y(love.mouse.getY(), true)
	if
		belong(mx, self.list.x, self.list.x + self.list.w) and
		belong(my, self.list.y, self.list.y + self.list.h)
	then
		if
			self.list.needFocusToInteract and
			self.itemIndex == self.list.focusedItemIndex or
			not self.list.needFocusToInteract
		then
			self.list:send({
				sender = self.list.sender,
				action = "buttonInteract",
				itemIndex = self.itemIndex,
				list = self.list,
				button = event.args[3]
			})
		else
			return self.list:scrollToItemIndex(self.itemIndex)
		end
	end
end

return CustomList
