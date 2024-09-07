
local just = require("just")
local class = require("class")
local spherefonts = require("sphere.assets.fonts")
local gfx_util = require("gfx_util")

---@class sphere.UserInfoView
---@operator call: sphere.UserInfoView
local UserInfoView = class()

---@param w number
---@param h number
---@param username string
---@param is_active boolean?
---@return number?
function UserInfoView:draw(w, h, username, is_active)
	local changed, active, hovered = just.button(self, just.is_over(w, h))

	love.graphics.setFont(spherefonts.get("Noto Sans", 26))
	love.graphics.setColor(1, 1, 1, 1)

	gfx_util.printBaseline(username or "", 0, 54, w - h, 1, "right")

	if self.image == nil then
		self.image = false
		local path = "userdata/avatar.png"
		if love.filesystem.getInfo(path) then
			self.image = love.graphics.newImage(path)
		end
	end
	local image = self.image
	local x, y, s = w - h + 21, 20, 48
	if image then
		love.graphics.draw(image, x, y, 0, s / image:getWidth(), s / image:getHeight())
	end

	love.graphics.circle("line", x + s / 2, y + s / 2, s / 2)
	if hovered then
		local alpha = active and 0.2 or 0.1
		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.circle("fill", x + s / 2, y + s / 2, s / 2)
	end

	if is_active then
		local x, y, r = w - h + 97, 44, 8
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.circle("fill", x, y, r)
		love.graphics.circle("line", x, y, r)
	end

	return changed
end

return UserInfoView
