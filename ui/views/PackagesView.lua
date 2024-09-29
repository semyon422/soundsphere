local just = require("just")
local imgui = require("imgui")
local thread = require("thread")
local ModalImView = require("ui.imviews.ModalImView")
local _transform = require("gfx_util").transform
local spherefonts = require("sphere.assets.fonts")
local theme = require("imgui.theme")
local repo = require("sphere.pkg.repo")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local scrollY = 0
local scrollYlist = 0

local w, h = 1024, 1080 / 2
local _w, _h = w / 2, 55
local r = 8
local window_id = "PackagesView"

local sections = {
	"local",
	"remote",
}
local section = sections[1]

local section_draw = {}

local modal

modal = ModalImView(function(self, quit)
	if self == "set_section" then
		section = quit
	end

	if quit then
		return true
	end

	imgui.setSize(w, h, w, _h)

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate((1920 - w) / 2, (1080 - h) / 2)

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)

	just.push()
	just.push()
	local tabsw
	section, tabsw = imgui.vtabs("packages tabs", section, sections)
	just.pop()
	love.graphics.translate(tabsw, 0)

	local inner_w = w - tabsw
	imgui.setSize(inner_w, h, inner_w / 2, _h)

	imgui.Container(window_id, inner_w, h, _h / 3, _h * 2, scrollY)

	love.graphics.setColor(1, 1, 1, 1)
	section_draw[section](self, inner_w)
	just.emptyline(8)

	scrollY = imgui.Container()
	just.pop()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
end)

section_draw["local"] = function(self, inner_w)
	---@type sphere.PackageManager
	local packageManager = self.game.packageManager

	local pkgs = packageManager:getPackages()

	imgui.text("installed packages")

	if imgui.button("open packages", "open packages") then
		love.system.openURL(packageManager.pkgs_path)
	end

	imgui.separator()

	for _, pkg in ipairs(pkgs) do
		local id = "pkg " .. pkg.name
		imgui.label(id, ("%s v%s by %s"):format(pkg.name, pkg.version, pkg.creator))
		if just.mouse_over(id, false, "mouse") then
			self.tooltip = ("type: %s\ndesc: %s\npath: %s"):format(
				pkg.type,
				pkg.desc,
				packageManager:getPackageRealPath(pkg.name)
			)
		end
	end
end

function section_draw.remote(self)
	---@type sphere.PackageManager
	local packageManager = self.game.packageManager
	local packageDownloader = packageManager.packageDownloader

	imgui.text("downloadable packages")
	imgui.separator()

	imgui.text("NOTICE!!!")
	imgui.text("I am not responsible for the code that you can download on this tab.")
	imgui.text("This code does not go through any moderation.")
	imgui.text("For technical support, contact the corresponding authors.")

	imgui.separator()

	for _, pkg_info in ipairs(repo) do
		if imgui.button(pkg_info.url, "download") then
			packageDownloader:download(pkg_info)
		end
		just.sameline()
		if imgui.button(pkg_info.source, "source") then
			love.system.openURL(pkg_info.github)
		end
		just.sameline()
		local label_text = pkg_info.name
		if pkg_info.status then
			label_text = pkg_info.name .. ": " .. pkg_info.status
		end
		if pkg_info.isDownloading then
			local shared = thread.shared.download[pkg_info.url]
			if shared then
				label_text = ("%s (%.1fMB)"):format(label_text, (shared.total or 0) / 1e6)
			end
		end
		imgui.label(pkg_info.url, label_text)
	end
end

return modal
