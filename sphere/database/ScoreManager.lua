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
	
	local scoresByHashIndex = {}
	self.scoresByHashIndex = scoresByHashIndex
	
	for _, scoreData in ipairs(scoreList) do
		local hash = scoreData.noteChartHash
		local index = scoreData.noteChartIndex
		scoresByHashIndex[hash] = scoresByHashIndex[hash] or {}
		scoresByHashIndex[hash][index] = scoresByHashIndex[hash][index] or {}
		local list = scoresByHashIndex[hash][index]
		list[#list + 1] = scoreData
	end
	for _, list in pairs(scoresByHashIndex) do
		for _, sublist in pairs(list) do
			table.sort(sublist, sortByScore)
		end
	end
end

ScoreManager.insertScore = function(self, score)
	ScoreDatabase:insertScore({
		noteChartHash = score.hash,
		noteChartIndex = score.index,
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
