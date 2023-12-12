local imgui = require("imgui")
local spherefonts = require("sphere.assets.fonts")
local _transform = require("gfx_util").transform
local just = require("just")
local ModalImView = require("sphere.imviews.ModalImView")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local scrollY = 0
local scrollYconfig = 0
local w, h = 454, 600
-- local w, h = 768, 1080 / 2
local _w, _h = w / 2, 55
local r = 8
local window_id = "NoteSkinView"

local selectedNoteSkin
return ModalImView(function(self)
	if not self then
		if selectedNoteSkin and selectedNoteSkin.config then
			selectedNoteSkin.config:close()
		end
		return true
	end

	local inputMode = tostring(self.game.selectController.state.inputMode)
	selectedNoteSkin = self.game.noteSkinModel:getNoteSkin(inputMode)
	if not selectedNoteSkin then
		return true
	end

	local skinInfos = self.game.noteSkinModel:getSkinInfos(inputMode)

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate(270, 240)
	-- love.graphics.translate((1920 - w) / 2, (1080 - h) / 2)

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)

	just.push()
	imgui.Container(window_id, w, h, _h / 3, _h * 2, scrollY)

	local itemHeight = 44
	for i, skinInfo in ipairs(skinInfos) do
		local name = skinInfo.name
		if selectedNoteSkin.path == skinInfo:getPath() then
			love.graphics.setColor(1, 1, 1, 0.1)
			love.graphics.rectangle("fill", 0, 0, w, itemHeight)
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.rectangle("fill", 0, 0, 10, itemHeight)
			just.next(10, itemHeight)
			just.sameline()
		end
		if imgui.TextOnlyButton("skin item" .. i, name, w, itemHeight, "left") then
			self.game.noteSkinModel:setDefaultNoteSkin(inputMode, skinInfo:getPath())
		end
	end

	scrollY = imgui.Container()
	just.pop()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)

	local config = selectedNoteSkin.config
	if not config or not config.draw then
		return
	end

	do
		local w, h = config.w or w, config.h or h
		love.graphics.replaceTransform(_transform(transform))
		love.graphics.translate(733, 240)
		love.graphics.setColor(0, 0, 0, 0.8)
		love.graphics.rectangle("fill", 0, 0, w, h, r)
		love.graphics.setColor(1, 1, 1, 1)

		just.push()
		imgui.Container(window_id .. "skin", w, h, _h / 3, _h * 2, scrollYconfig)
		config:draw(w, h)
		scrollYconfig = imgui.Container()
		just.pop()

		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.rectangle("line", 0, 0, w, h, r)
	end
end)
