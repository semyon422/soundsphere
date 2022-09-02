local just = require("just")
local LabelImView = require("sphere.imviews.LabelImView")
local HotkeyImView = require("sphere.imviews.HotkeyImView")
local TextButtonImView = require("sphere.imviews.TextButtonImView")
local TextButtonImView2 = require("sphere.imviews.TextButtonImView2")
local ModalImView = require("sphere.imviews.ModalImView")
local ContainerImView = require("sphere.imviews.ContainerImView")
local ListImView = require("sphere.imviews.ListImView")
local _transform = require("aqua.graphics.transform")
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
	local mountModel = self.game.mountModel
	local items = self.game.configModel.configs.mount
	selectedItem = selectedItem or items[1]

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate((1920 - w) / 2, (1080 - h) / 2)

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)

	just.push()
	ContainerImView(window_id, w, h, _h * 2, scrollY)

	ListImView("mount points", w, h / 2, _h, scrollYlist)
	for i = 1, #items do
		local item = items[i]
		local name = item[2]
		if selectedItem == item then
			name = "> " .. name
		end
		if TextButtonImView("mount item" .. i, name, w, _h, "left") then
			selectedItem = item
		end
	end
	scrollYlist = ListImView()

	if selectedItem then
		just.indent(8)
		just.text("Status: " .. (mountModel.mountStatuses[selectedItem[1]] or "unknown"))
		just.indent(8)
		just.text("Real path: ")
		just.indent(8)
		just.text(selectedItem[1], w)
		if TextButtonImView2("open dir", "Open", 200, _h) then
			love.system.openURL(selectedItem[1])
		end
		just.sameline()
		if TextButtonImView2("remove dir", "Remove", 200, _h) then
			for i = 1, #items do
				if items[i] == selectedItem then
					table.remove(items, i)
					selectedItem = nil
					break
				end
			end
		end
	end

	scrollY = ContainerImView()
	just.pop()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
end)
