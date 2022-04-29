local url = require("socket.url")
local escape = url.escape

local urls = {}

--[[
	Modes (r):
	4 All
	0 Ranked
	7 Ranked (Played)
	3 Qualified
	2 Pending/Help
	5 Graveyard

	Search (q):
	Newest
	Top Rated
	Most Played
]]
function urls.search(q, r, p)
	return ("/web/osu-search.php?m=3&q=%s&r=%s&p=%s"):format(escape(q), r or 4, p or 0)
end

function urls.download(setId)
	return ("/d/%s"):format(setId)
end

function urls.thumbnail(setId, large)
	return ("/thumb/%s%s.jpg"):format(setId, large and "l" or "")
end

function urls.card(setId, large)
	return ("/beatmaps/%s/covers/card%s.jpg"):format(setId, large and "@2x" or "")
end

function urls.cover(setId, large)
	return ("/beatmaps/%s/covers/cover%s.jpg"):format(setId, large and "@2x" or "")
end

function urls.preview(setId)
	return ("/preview/%s.mp3"):format(setId)
end

return urls
