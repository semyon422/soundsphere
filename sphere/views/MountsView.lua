local just = require("just")
local imgui = require("imgui")
local ModalImView = require("sphere.imviews.ModalImView")
local _transform = require("gfx_util").transform
local spherefonts = require("sphere.assets.fonts")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local scrollY = 0
local scrollYlist = 0

local w, h = 768, 1080 / 2
local _w, _h = w / 2, 55
local r = 8
local window_id = "MountsView"
local selectedItem

return ModalImView(function(self)
	if not self then
		return true
	end

	local mountModel = self.game.mountModel
	local items = mountModel.cf_locations
	selectedItem = selectedItem or items[1]

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate((1920 - w) / 2, (1080 - h) / 2)

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)

	just.push()
	imgui.Container(window_id, w, h, _h / 3, _h * 2, scrollY)

	imgui.List("mount points", w, h / 3, _h / 2, _h, scrollYlist)
	for i, item in ipairs(items) do
		local name = item.name
		if selectedItem == item then
			name = "> " .. name
		end
		if imgui.TextOnlyButton("mount item" .. i, name, w, _h, "left") then
			selectedItem = item
		end
	end
	scrollYlist = imgui.List()

	if selectedItem then
		local path = selectedItem.path
		just.indent(8)
		just.text("Status: " .. (mountModel.status[path] or "unknown"))
		just.indent(8)
		just.text("Real path: ")
		just.indent(8)
		just.text(path, w)
		if imgui.TextButton("open dir", "Open", 200, _h) then
			love.system.openURL(path)
		end
		just.sameline()
		-- if imgui.TextButton("remove dir", "Remove", 200, _h) then
		-- 	for i = 1, #items do
		-- 		if items[i] == selectedItem then
		-- 			table.remove(items, i)
		-- 			selectedItem = nil
		-- 			break
		-- 		end
		-- 	end
		-- end
	end

	scrollY = imgui.Container()
	just.pop()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
end)
