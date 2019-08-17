local ScoreDatabase = require("sphere.database.ScoreDatabase")

local ScoreManager = {}

ScoreManager.selectScoresRequest = [[
	SELECT * FROM `scores`;
]]

ScoreManager.load = function(self)
	ScoreDatabase:load()
	self.db = ScoreDatabase.db
	self.selectScoresRequest = self.db:prepare(self.selectScoresRequest)
	self:select()
end

ScoreManager.unload = function(self)
	ScoreDatabase:unload()
end

local sortByScore = function(a, b)
	return a.score > b.score
end

ScoreManager.select = function(self)
	local scoreList = {}
	self.scoreList = scoreList
	
	local scoreColumns = ScoreDatabase.scoreColumns
	local scoreNumberColumns = ScoreDatabase.scoreNumberColumns
	
	local stmt = self.selectScoresRequest:reset()
	local row = stmt:step()
	while row do
		local scoreData = {}
		for i = 1, #scoreColumns do
			scoreData[scoreColumns[i]] = row[i]
		end
		for i = 1, #scoreNumberColumns do
			scoreData[scoreNumberColumns[i]] = tonumber(scoreData[scoreNumberColumns[i]])
		end
		scoreList[#scoreList + 1] = scoreData
		row = stmt:step()
	end
	
	local scoreDict = {}
	self.scoreDict = scoreDict
	
	for _, scoreData in ipairs(scoreList) do
		scoreDict[scoreData.id] = scoreData
	end
	
	local scoresByHash = {}
	self.scoresByHash = scoresByHash
	
	for _, scoreData in ipairs(scoreList) do
		scoresByHash[scoreData.chartHash] = scoresByHash[scoreData.chartHash] or {}
		local list = scoresByHash[scoreData.chartHash]
		list[#list + 1] = scoreData
	end
	for _, list in pairs(scoresByHash) do
		table.sort(list, sortByScore)
	end
end

ScoreManager.insertScore = function(self, score)
	ScoreDatabase:insertScore({
		chartHash = score.hash,
		playerName = "Player",
		time = os.time(),
		score = score.score,
		accuracy = score.accuracy,
		maxCombo = score.maxcombo,
		scoreRating = 0,
		mods = "None"
	})
	self:select()
end

return ScoreManager
