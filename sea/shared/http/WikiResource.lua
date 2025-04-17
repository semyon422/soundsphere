local IResource = require("web.framework.IResource")
local http_util = require("http_util")

---@class sea.WikiResource: web.IResource
---@operator call: sea.WikiResource
local WikiResource = IResource + {}

---@class sea.Wiki.PageMetadata
---@field name string Localized name of the page.
---@field filename string A name of the file WITHOUT extension. A path is relative to the metadata file.

---@class sea.Wiki.CategoryMetadata
---@field name string Localized name of the category
---@field pages sea.Wiki.PageMetadata[]

---@class sea.Wiki.LanguageMetadata
---@field name string Language name
---@field code string https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oe376/6c085406-a698-4e12-9d4d-c3b0ee3dbc4a
---@field flag string Country code
---@field categories sea.Wiki.CategoryMetadata[]

WikiResource.routes = {
	{"/wiki", {
		GET = "getPage",
	}},
}

---@type sea.Wiki.LanguageMetadata[]
local language_metadatas = {
	require("sea.wiki.en_us.pages"),
	require("sea.wiki.ru.pages"),
	require("sea.wiki.jp_jp.pages"),
	require("sea.wiki.zh_tw.pages")
}

---@param views web.Views
function WikiResource:new(views)
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function WikiResource:getPage(req, res, ctx)
	local query = http_util.decode_query_string(ctx.parsed_uri.query)
	local selected_language_code = query.language_code or "en_us"
	local selected_page = query.page or "installation"

	ctx.selected_language_code = selected_language_code
	ctx.selected_page = selected_page
	ctx.language_metadatas = language_metadatas

	for _, metadata in ipairs(language_metadatas) do
		if metadata.code == selected_language_code then
			ctx.categories = metadata.categories
			break
		end
	end

	if not ctx.categories then
		ctx.categories = language_metadatas[1].categories
	end

	ctx.markdown_file_path = ("sea/wiki/%s/%s.md"):format(selected_language_code, selected_page)

	self.views:render_send(res, "sea/shared/http/wiki.etlua", ctx, true)
end

return WikiResource
