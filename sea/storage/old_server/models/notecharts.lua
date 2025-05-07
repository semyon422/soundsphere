local Inputmodes = require("sea.storage.old_server.Inputmodes")

---@class sea.old.Notechart
---@field id integer
---@field file_id integer
---@field index integer
---@field created_at integer
---@field is_complete boolean
---@field is_valid boolean
---@field scores_count integer
---@field inputmode sea.old.Inputmodes
---@field difficulty number
---@field song_title string
---@field song_artist string
---@field difficulty_name string
---@field difficulty_creator string
---@field level integer
---@field length integer
---@field notes_count integer

---@type rdb.ModelOptions
local notecharts = {}

notecharts.types = {
	is_complete = "boolean",
	is_valid = "boolean",
	inputmode = Inputmodes,
}

notecharts.relations = {
	file = {belongs_to = "files", key = "file_id"},
	scores = {has_many = "scores", key = "notechart_id"},
}

return notecharts
