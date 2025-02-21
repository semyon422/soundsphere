local Enum = require("rdb.Enum")

---@enum (key) sea.RatingCalc
local RatingCalc = {
	level = 0,
	difftable = 1,
	enps = 2,
	pp = 3,
	msd = 4,
}

RatingCalc = Enum(RatingCalc)
---@cast RatingCalc +{column: fun(self: rdb.Enum, rating_calc: sea.RatingCalc): string}

local columns = {
	level = "chartmeta_level",
	difftable = "difftable_level",
	enps = "rating",
	pp = "rating_pp",
	msd = "rating_msd",
}

---@param rating_calc sea.RatingCalc
function RatingCalc:column(rating_calc)
	return assert(columns[rating_calc])
end

return RatingCalc
