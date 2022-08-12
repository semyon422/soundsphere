local aquaevent = require("aqua.event")
local just = require("just")

local midistate = aquaevent.midistate
local keystate = aquaevent.keystate
local gamepadstate = aquaevent.gamepadstate
local joystickstate = aquaevent.joystickstate

local allstates = {
	midi = midistate,
	keyboard = keystate,
	gamepad = gamepadstate,
	joystick = joystickstate,
}

return function(id, device, key, w, h)
	local _key = key
	local changed = false

	if just.focused_id == id then
		local states = allstates[device]
		local k = next(states)
		if k then
			key = k
			states[k] = nil
			changed = true
			just.focus()
		end
	end

	if just.keypressed("escape") then
		changed = false
		key = _key
		just.focus()
	end

	if just.button(id, just.is_over(w, h)) then
		just.focus(id)
	end

	just.push()

	local font = love.graphics.getFont()
	local lh = font:getHeight()
	h = h or lh

	local r = 8
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
	if just.focused_id == id then
		love.graphics.setColor(1, 1, 1, 0.2)
		love.graphics.rectangle("fill", 0, 0, w, h, r)
	end
	love.graphics.translate(r, (h - lh) / 2)

	love.graphics.setColor(1, 1, 1, 1)
	if just.focused_id == id then
		just.text("???")
	else
		just.text(key)
	end

	just.pop()
	just.next(w, h)

	return changed, key
end
