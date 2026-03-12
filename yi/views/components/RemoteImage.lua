local View = require("yi.views.View")
local Colors = require("yi.Colors")

---@class yi.components.RemoteImage : yi.View
---@overload fun(url: string?): yi.components.RemoteImage
local RemoteImage = View + {}

-- Global weak cache for images to allow GC to reclaim them
local image_cache = setmetatable({}, {__mode = "v"}) ---@type {[string]: love.Image}
local pending = {} ---@type {[string]: boolean}

---@param url string?
function RemoteImage:new(url)
	View.new(self)
	self.url = url
	self.img = nil
	self.img_scale_x = 1
	self.img_scale_y = 1
end

function RemoteImage:load()
	View.load(self)
	self:checkImage()
end

function RemoteImage:setUrl(url)
	if self.url == url then return end
	self.url = url
	self.img = nil
	self:checkImage()
end

function RemoteImage:checkImage()
	if not self.url or self.url == "" then return end
	
	if image_cache[self.url] then
		self.img = image_cache[self.url]
		return
	end

	if pending[self.url] then return end
	pending[self.url] = true

	local dlc_manager = self:getGame().dlcManager

	coroutine.wrap(function()
		-- Fetch from worker thread to avoid blocking main thread
		-- Decoding now happens on the worker side (returns ImageData)
		local imageData, err = dlc_manager:fetchThumbnail(self.url)
		pending[self.url] = nil
		
		if imageData then
			local ok, img = pcall(love.graphics.newImage, imageData)
			if ok then
				image_cache[self.url] = img
				self.img = img
			end
		end
	end)()
end

function RemoteImage:draw()
	local w, h = self:getCalculatedWidth(), self:getCalculatedHeight()
	
	if self.img then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(self.img, 0, 0, 0, self.img_scale_x, self.img_scale_y)
	else
		-- Placeholder
		love.graphics.setColor(Colors.outline)
		love.graphics.rectangle("fill", 0, 0, w, h, 4, 4)
	end
end

function RemoteImage:updateTransforms()
	View.updateTransforms(self)
	if self.img then
		local w, h = self:getCalculatedWidth(), self:getCalculatedHeight()
		local iw, ih = self.img:getDimensions()
		self.img_scale_x, self.img_scale_y = w / iw, h / ih
	end
end

RemoteImage.Setters = setmetatable({
	url = RemoteImage.setUrl,
}, {__index = View.Setters})

return RemoteImage
