local class = require("class")

---@class yi.packer.ImageAtlasPacker
---@operator call: yi.packer.ImageAtlasPacker
local ImageAtlasPacker = class()

ImageAtlasPacker.gap = 1

---@class yi.packer.ImageAtlasPacker.Entry
---@field name string
---@field image_data love.ImageData
---@field width integer
---@field height integer
---@field x integer
---@field y integer

---@private
---@param sprites {[string]: love.ImageData}
---@return yi.packer.ImageAtlasPacker.Entry[]
---@return string?
function ImageAtlasPacker:buildEntries(sprites)
	---@type yi.packer.ImageAtlasPacker.Entry[]
	local entries = {}
	local atlas_format = nil ---@type string

	for name, image_data in pairs(sprites) do
		local width, height = image_data:getDimensions()
		local format = image_data.getFormat and image_data:getFormat() or nil

		if atlas_format and format and atlas_format ~= format then
			error(("all sprites must share the same ImageData format: `%s` ~= `%s`"):format(atlas_format, format))
		end

		atlas_format = atlas_format or format

		entries[#entries + 1] = {
			name = name,
			image_data = image_data,
			width = width,
			height = height,
			x = 0,
			y = 0,
		}
	end

	table.sort(entries, function(a, b)
		if a.height ~= b.height then
			return a.height > b.height
		end
		if a.width ~= b.width then
			return a.width > b.width
		end
		return a.name < b.name
	end)

	return entries, atlas_format
end

---@private
---@param entries yi.packer.ImageAtlasPacker.Entry[]
---@param atlas_width integer
---@return {width: integer, height: integer, area: integer}
function ImageAtlasPacker:packShelves(entries, atlas_width)
	local x = 0
	local y = 0
	local row_height = 0
	local used_width = 0

	for _, entry in ipairs(entries) do
		if x > 0 and x + entry.width > atlas_width then
			x = 0
			y = y + row_height + self.gap
			row_height = 0
		end

		entry.x = x
		entry.y = y

		x = x + entry.width + self.gap
		row_height = math.max(row_height, entry.height)
		used_width = math.max(used_width, x - self.gap) ---@type number
	end

	local atlas_height = y + row_height

	return {
		width = math.max(used_width, 1),
		height = math.max(atlas_height, 1),
		area = math.max(used_width, 1) * math.max(atlas_height, 1),
	}
end

---@private
---@param entries yi.packer.ImageAtlasPacker.Entry[]
---@return {width: integer, height: integer}
function ImageAtlasPacker:selectLayout(entries)
	local max_width = 1
	local total_width = 0
	local total_area = 0

	for _, entry in ipairs(entries) do
		max_width = math.max(max_width, entry.width)
		total_width = total_width + entry.width + self.gap
		total_area = total_area + (entry.width + self.gap) * (entry.height + self.gap)
	end

	total_width = math.max(total_width - self.gap, max_width)

	local target_width = math.max(max_width, math.ceil(math.sqrt(total_area)))
	local candidate_widths = {[max_width] = true, [target_width] = true, [total_width] = true}

	local width = max_width
	while width < total_width do
		candidate_widths[width] = true
		width = width * 2
	end

	---@type integer[]
	local candidates = {}
	for candidate_width in pairs(candidate_widths) do
		candidates[#candidates + 1] = candidate_width
	end
	table.sort(candidates)

	local best_layout = nil
	local best_score = nil
	local best_aspect_delta = nil

	for _, candidate_width in ipairs(candidates) do
		local layout = self:packShelves(entries, candidate_width)
		local aspect_delta = math.abs(layout.width - layout.height)

		if not best_layout
			or layout.area < best_score
			or (layout.area == best_score and aspect_delta < best_aspect_delta)
			or (layout.area == best_score and aspect_delta == best_aspect_delta and layout.width < best_layout.width)
		then
			best_layout = {
				width = layout.width,
				height = layout.height,
			}
			best_score = layout.area
			best_aspect_delta = aspect_delta
		end
	end

	assert(best_layout)
	self:packShelves(entries, best_layout.width)

	return best_layout
end

---@param sprites {[string]: love.ImageData}
---@return love.ImageData
---@return {[string]: love.Quad}
function ImageAtlasPacker:pack(sprites)
	local entries, atlas_format = self:buildEntries(sprites)

	if #entries == 0 then
		return love.image.newImageData(1, 1), {}
	end

	local layout = self:selectLayout(entries)

	local atlas ---@type love.ImageData
	if atlas_format then
		atlas = love.image.newImageData(layout.width, layout.height, atlas_format)
	else
		atlas = love.image.newImageData(layout.width, layout.height)
	end

	---@type {[string]: love.Quad}
	local quads = {}

	for _, entry in ipairs(entries) do
		atlas:paste(entry.image_data, entry.x, entry.y, 0, 0, entry.width, entry.height)
		quads[entry.name] = love.graphics.newQuad(entry.x, entry.y, entry.width, entry.height, layout.width, layout.height)
	end

	return atlas, quads
end

return ImageAtlasPacker
