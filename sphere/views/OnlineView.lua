local just = require("just")
local ModalImView = require("sphere.imviews.ModalImView")
local _transform = require("gfx_util").transform
local spherefonts = require("sphere.assets.fonts")
local imgui = require("imgui")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local email = ""
local password = ""

return ModalImView(function(self)
	if not self then
		return true
	end

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate(279 + 454 * 3 / 4, 1080 / 4)
	local w, h = 454 * 1.5, 1080 / 2

	imgui.setSize(w, h, w / 2, 55)

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, 8)
	love.graphics.setColor(1, 1, 1, 1)

	just.clip(love.graphics.rectangle, "fill", 0, 0, w, h, 8)

	local window_id = "ContextMenuImView"
	local over = just.is_over(w, h)
	just.container(window_id, over)
	just.button(window_id, over)
	just.wheel_over(window_id, over)

	local active = next(self.game.configModel.configs.online.session)
	if active then
		imgui.text("You are logged in")
		if active and imgui.button("logout", "Logout") then
			self.game.onlineModel.authManager:logout()
		end
	else
		email = imgui.input("Email", email, "Email")
		password = imgui.input("Password", password, "Password")
		if imgui.button("Login", "Login") then
			self.game.onlineModel.authManager:login(email, password)
		end
		if imgui.button("Quick login", "Quick login using browser") then
			self.game.onlineModel.authManager:quickLogin()
		end
	end

	just.container()
	just.clip()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, 8)
end)
