local View = require("yi.views.View")
local Colors = require("yi.Colors")
local utf8 = require("utf8")

---@class yi.TextContainer : yi.View
local TextContainer = View + {}

function TextContainer:new(textbox)
	View.new(self)
	self.textbox = textbox
end

function TextContainer:draw()
	local textbox = self.textbox
	local w, h = self:getCalculatedWidth(), self:getCalculatedHeight()
	local font = textbox.font
	local text = textbox.text
	local is_focused = textbox.is_focused

	local text_y = math.floor((h - font:getHeight()) / 2)
	
	local before_cursor = string.sub(text, 1, utf8.offset(text, textbox.cursor_pos + 1) - 1)
	local cursor_x = font:getWidth(before_cursor)
	local cursor_w = 2

	-- Calculate offset to keep cursor in view
	if cursor_x + textbox.scroll_offset < 0 then
		textbox.scroll_offset = -cursor_x
	elseif cursor_x + textbox.scroll_offset > w - cursor_w then
		textbox.scroll_offset = (w - cursor_w) - cursor_x
	end

	-- Clamp scroll_offset so text doesn't fly away to the right
	local text_w = font:getWidth(text)
	if text_w + textbox.scroll_offset < w - cursor_w and text_w > w - cursor_w then
		textbox.scroll_offset = (w - cursor_w) - text_w
	elseif text_w <= w - cursor_w then
		textbox.scroll_offset = 0
	end
	
	local offset = textbox.scroll_offset

	-- Text
	if text == "" and not is_focused then
		love.graphics.setColor(0.5, 0.5, 0.6, 1) -- Placeholder color
		love.graphics.print(textbox.placeholder, font, 0, text_y)
	else
		love.graphics.setColor(Colors.text)
		love.graphics.print(text, font, offset, text_y)
	end
	
	-- Cursor
	if is_focused and (love.timer.getTime() % 1 > 0.5) then
		love.graphics.setColor(Colors.accent)
		love.graphics.rectangle("fill", math.floor(cursor_x + offset), 8, cursor_w, h - 16)
	end
end

---@class yi.Textbox : yi.View
---@overload fun(text: string?, placeholder: string?, on_change: fun(text: string)): yi.Textbox
local Textbox = View + {}

---@param text string?
---@param placeholder string?
---@param on_change fun(text: string)
function Textbox:new(text, placeholder, on_change)
	View.new(self)
	self.text = text or ""
	self.placeholder = placeholder or ""
	self.on_change = on_change
	self.is_focused = false
	self.cursor_pos = utf8.len(self.text)
	self.scroll_offset = 0
	
	self:setup({
		w = 200,
		h = 36,
		mouse = true,
		handles_keyboard_input = true,
		padding = {0, 8, 0, 8},
		arrange = "flex_row",
	})
end

function Textbox:load()
	local res = self:getResources()
	self.font = res:getFont("regular", 16)

	self:add(TextContainer(self), {
		w = "100%",
		h = "100%",
		stencil = true,
	})
end

function Textbox:onMouseClick()
	self:getInputs():setKeyboardFocus(self, {control = false, shift = false, alt = false, super = false})
end

function Textbox:onFocus()
	self.is_focused = true
end

function Textbox:onFocusLost()
	self.is_focused = false
end

---@param e ui.TextInputEvent
function Textbox:onTextInput(e)
	if not self.is_focused then
		return
	end

	local left = string.sub(self.text, 1, utf8.offset(self.text, self.cursor_pos + 1) - 1)
	local right = string.sub(self.text, utf8.offset(self.text, self.cursor_pos + 1))
	self.text = left .. e.key .. right
	self.cursor_pos = self.cursor_pos + 1

	if self.on_change then
		self.on_change(self.text)
	end

	e:stopPropagation()
	return true
end

---@param e ui.KeyDownEvent
function Textbox:onKeyDown(e)
	if not self.is_focused then
		return
	end

	local k = e.key
	if k == "backspace" then
		if self.cursor_pos > 0 then
			local left = string.sub(self.text, 1, utf8.offset(self.text, self.cursor_pos) - 1)
			local right = string.sub(self.text, utf8.offset(self.text, self.cursor_pos + 1))
			self.text = left .. right
			self.cursor_pos = self.cursor_pos - 1
			if self.on_change then
				self.on_change(self.text)
			end
		end
	elseif k == "delete" then
		if self.cursor_pos < utf8.len(self.text) then
			local left = string.sub(self.text, 1, utf8.offset(self.text, self.cursor_pos + 1) - 1)
			local right = string.sub(self.text, utf8.offset(self.text, self.cursor_pos + 2))
			self.text = left .. right
			if self.on_change then
				self.on_change(self.text)
			end
		end
	elseif k == "left" then
		self.cursor_pos = math.max(0, self.cursor_pos - 1)
	elseif k == "right" then
		self.cursor_pos = math.min(utf8.len(self.text), self.cursor_pos + 1)
	elseif k == "c" and e.control_pressed then
		love.system.setClipboardText(self.text)
	elseif k == "v" and e.control_pressed then
		local clip = love.system.getClipboardText()
		if clip ~= "" then
			local left = string.sub(self.text, 1, utf8.offset(self.text, self.cursor_pos + 1) - 1)
			local right = string.sub(self.text, utf8.offset(self.text, self.cursor_pos + 1))
			self.text = left .. clip .. right
			self.cursor_pos = self.cursor_pos + utf8.len(clip)
			if self.on_change then
				self.on_change(self.text)
			end
		end
	elseif k == "return" or k == "escape" then
		self:getInputs():setKeyboardFocus(nil, {control = false, shift = false, alt = false, super = false})
	end

	e:stopPropagation()
	return true
end

function Textbox:draw()
	local w, h = self:getCalculatedWidth(), self:getCalculatedHeight()
	
	-- Background
	love.graphics.setColor(Colors.panels)
	love.graphics.rectangle("fill", 0, 0, w, h, 4, 4)
	
	-- Outline
	if self.is_focused then
		love.graphics.setColor(Colors.accent)
		love.graphics.setLineWidth(2)
	else
		love.graphics.setColor(Colors.outline)
		love.graphics.setLineWidth(1)
	end
	love.graphics.rectangle("line", 0, 0, w, h, 4, 4)
end

return Textbox
