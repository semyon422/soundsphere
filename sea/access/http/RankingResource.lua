local http_util = require("web.http.util")
local math_util = require("math_util")
local IResource = require("web.framework.IResource")
local User = require("sea.access.User")

---@class sea.RankingResource: web.IResource
---@operator call: sea.RankingResource
local RankingResource = IResource + {}

RankingResource.uri = "/ranking"
RankingResource.maxUsersPerPage = 50
RankingResource.flagUrlFormat = "https://raw.githubusercontent.com/lipis/flag-icons/refs/heads/main/flags/4x3/%s.svg"

---@param views web.Views
function RankingResource:new(views)
	self.views = views
	self.testUsers = {}
	local flags = { "de", "ru", "es", "fi", "jp", "kz", "gb", "us" }

	for i = 1, 500, 1 do
		table.insert(self.testUsers, {
			rank = i,
			rankChange = math.random(-5, 5),
			username = ("User %i"):format(i),
			pr = 30 - (i * 0.039),
			pp = 10000 - (i * 12.3),
			msd = 32 - (i * 0.032),
			accuracy = math.random(95, 100) * 0.01,
			scoreCount = math.random(200, 30000),
			flag = self.flagUrlFormat:format(flags[math.random(1, #flags)]),
			playTime = math.random(400, 1000000),
			hardcodeHealth = math.random(1, 10)
		})
	end

	self.testGamemodes = {
		{
			name = "Mania",
			id = "mania"
		},
		{
			name = "Taiko",
			id = "taiko"
		},
		{
			name = "osu!",
			id = "osu"
		}
	}

	-- Category: { name: string, Leaderboard: { name: string, id: integer } }
	self.testManiaLeaderboards = {
		{
			name = "All ranked",
			items = {
				{ name = "All ranked", id = 0 },
				{ name = "Hardcore", id = 1 }
			}
		},
		{
			name = "Other games",
			items = {
				{ name = "osu!", id = 2 },
				{ name = "Quaver", id = 3 },
				{ name = "Etterna", id = 4 },
				{ name = "osu! + Quaver + Etterna", id = 5 }
			}
		}
	}

	self.testOsuOrTaikoLeaderboards = {
		{
			name = "All ranked",
			items = {
				{ name = "All ranked", id = 6 },
				{ name = "Hardcore", id = 7 }
			}
		},
		{
			name = "Other games",
			items = {
				{ name = "osu!", id = 8 },
			}
		}
	}

	self.testKeyModes = {
		{
			name = "Filters",
			items = {
				{ name = "All", id = "all" },
				{ name = "Less than 4K", id = "less_than_4k" },
				{ name = "Greater than 10K", id = "greater_than_10k" }
			},
		},
		{
			name = "Specific key modes",
			items = {
				{ name = "4K", id = "4key" },
				{ name = "7K1S", id = "7key1scratch" },
				{ name = "10K", id = "10key" },
			}
		}
	}

	self.testRankingTypes = {
		{ name = "Performance", id = "performance" },
		{ name = "Accuracy", id = "accuracy" },
		{ name = "Unique scores", id = "unique_scores" },
		{ name = "Play count", id = "play_count" },
		{ name = "Play time", id = "play_time" },
		{ name = "Social rating", id = "social_rating" }
	}
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function RankingResource:GET(req, res, ctx)
	local query = http_util.decode_query_string(ctx.parsed_uri.query)
	local page_count = math.ceil(#self.testUsers / self.maxUsersPerPage)

	local page = 1
	local gamemode_id = "mania"
	local leaderboard_id = 0
	local key_mode_id = "10key"
	local ranking_type_id = "performance"

	if query then
		page = math.floor(math_util.clamp(tonumber(query.page) or 1, 1, page_count)) or page
		gamemode_id = query.gamemode_id or gamemode_id
		leaderboard_id = tonumber(query.leaderboard_id) or leaderboard_id
		key_mode_id = query.key_mode_id or key_mode_id
		ranking_type_id = query.ranking_type_id or ranking_type_id
	end

	ctx.users = {}
	local first = (page - 1) * self.maxUsersPerPage
	local last = math.min(first + self.maxUsersPerPage, #self.testUsers)

	-- Let's say we want these values from the database for the table
	ctx.table_cell_names = {"PP", "Accuracy", "Scores"}

	-- API should return a page slice, we don't have to do this here
	for i = first, last - 1 do
		local user = self.testUsers[i + 1]
		local t = {
			rank = user.rank,
			rankChange = user.rankChange,
			flag = user.flag,
			username = user.username,
			cellValues = { -- We can put here as many values as we want. Don't forget to add a name for a column to ctx.table_cell_names
				{
					label = ("%i"):format(user.pp),
					dimmed = false
				},
				{
					label = ("%0.02f%%"):format(user.accuracy * 100),
					dimmed = true,
				},
				{
					label = tostring(user.scoreCount),
					dimmed = true
				}
			}
		}
		table.insert(ctx.users, t)
	end

	ctx.page_count = page_count
	ctx.ranking_types = self.testRankingTypes
	ctx.gamemodes = self.testGamemodes
	ctx.query = {
		page = page,
		gamemode_id = gamemode_id,
		leaderboard_id = leaderboard_id,
		ranking_type_id = ranking_type_id
	}

	if gamemode_id == "mania" then
		ctx.leaderboards = self.testManiaLeaderboards
		ctx.key_modes = self.testKeyModes
		ctx.display_key_modes = true
		ctx.query.key_mode_id = key_mode_id
	else
		ctx.leaderboards = self.testOsuOrTaikoLeaderboards
		ctx.display_key_modes = false
	end

	if ctx.query.leaderboard_id == -1 then
		ctx.query.leaderboard_id = ctx.leaderboards[1].items[1].id
	end

	ctx.display_leaderboards = true

	if ranking_type_id == "play_time" or ranking_type_id == "social_rating" then
		ctx.display_leaderboards = false
	end

	self.views:render_send(res, "sea/access/http/ranking.etlua", ctx, true)
end

return RankingResource
