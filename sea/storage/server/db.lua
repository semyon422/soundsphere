---@type string[]
local buf = {}

do
	table.insert(buf, [[
		CREATE TABLE IF NOT EXISTS `leaderboard_user_histories` (
		`id` INTEGER PRIMARY KEY,
		`leaderboard_id` INTEGER NOT NULL,
		`user_id` INTEGER NOT NULL,
	]])

	for i = 1, 90 do
		table.insert(buf, ([[
			`total_rating_%s` REAL NOT NULL,
			`total_accuracy_%s` REAL NOT NULL,
			`rank_%s` INTEGER NOT NULL,
		]]):format(i, i, i))
	end

	table.insert(buf, [[
		`updated_at` INTEGER NOT NULL,
		UNIQUE(`leaderboard_id`, `user_id`)
		);
	]])
end

return table.concat(buf, "\n")
