local Inputmodes = require("sea.storage.old_server.Inputmodes")
local Filehash = require("sea.storage.old_server.Filehash")

---@class sea.old.Score
---@field id integer
---@field user_id integer
---@field notechart_id integer
---@field modifierset_id integer
---@field file_id integer
---@field replay_hash string
---@field hash string
---@field index integer
---@field inputmode sea.old.Inputmodes
---@field is_complete boolean
---@field is_valid boolean
---@field is_ranked boolean
---@field is_top boolean
---@field created_at integer
---@field score number
---@field accuracy number
---@field max_combo integer
---@field misses_count integer
---@field difficulty number
---@field rating number
---@field rate number
---@field const boolean

---@type rdb.ModelOptions
local scores = {}

scores.table_name = "scores"

scores.subquery = [[
SELECT
scores.*,
f1.hash AS replay_hash,
f2.hash AS hash,
notecharts.`index`
FROM scores
INNER JOIN notecharts ON
scores.notechart_id = notecharts.id
INNER JOIN files f1 ON
scores.file_id = f1.id
INNER JOIN files f2 ON
notecharts.file_id = f2.id
]]

scores.types = {
	inputmode = Inputmodes,
	hash = Filehash,
	replay_hash = Filehash,
	is_complete = "boolean",
	is_valid = "boolean",
	is_ranked = "boolean",
	is_top = "boolean",
	const = "boolean",
}

scores.relations = {
	user = {belongs_to = "users", key = "user_id"},
	notechart = {belongs_to = "notecharts", key = "notechart_id"},
	file = {belongs_to = "files", key = "file_id"},
}

return scores
