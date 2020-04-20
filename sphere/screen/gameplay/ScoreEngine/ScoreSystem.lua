local json			= require("json")
local Class			= require("aqua.util.Class")
local Observable	= require("aqua.util.Observable")
local Counter		= require("sphere.screen.gameplay.ScoreEngine.Counter")

local ScoreSystem = Class:new()

ScoreSystem.basePath = "userdata/counters"

ScoreSystem.send = function(self, event)
	return self.observable:send(event)
end

ScoreSystem.construct = function(self)
	self.observable = Observable:new()
	self.scoreTable = {}
end

ScoreSystem.loadConfig = function(self, path)
	local file = io.open(self.basePath .. "/" .. path, "r")
	self.scoreConfig = json.decode(file:read("*all"))
	file:close()

	self:loadCounters()
end

ScoreSystem.loadCounters = function(self)
	self.counters = {}
	local counters = self.counters

	for _, counterConfig in ipairs(self.scoreConfig.counters) do
		local counter = Counter:new()
		counter.config = counterConfig
		counter.scoreTable = self.scoreTable
		counter:loadFile(self.basePath .. "/" .. counterConfig.path)
		counter:load()
		counters[#counters + 1] = counter
	end
end

ScoreSystem.receive = function(self, event)
	local counters = self.counters
	for i = 1, #counters do
		counters[i]:receive(event)
	end
end

-- Score.toTable = function(self)
-- 	local score = {}


-- end

-- Score.passEdge = 0.120
-- Score.missEdge = 0.160

-- Score.timegates = {
-- 	{
-- 		time = 0.016,
-- 		name = "great"
-- 	},
-- 	{
-- 		time = 0.040,
-- 		name = "good",
-- 		nameLate = "late good",
-- 		nameEarly = "early good"
-- 	},
-- 	{
-- 		time = 0.120,
-- 		name = "bad",
-- 		nameLate = "late bad",
-- 		nameEarly = "early bad"
-- 	},
-- 	{
-- 		time = 0.160,
-- 		name = "miss"
-- 	}
-- }

-- Score.grades = {
-- 	{time = 0.001,	name = "auto"	},
-- 	{time = 0.002,	name = "cheater"},
-- 	{time = 0.004,	name = ">_<"	},
-- 	{time = 0.006,	name = "wtf?"	},
-- 	{time = 0.008,	name = "ET"		},
-- 	{time = 0.010,	name = "$$$"	},
-- 	{time = 0.012,	name = "SS"		},
-- 	{time = 0.016,	name = "S++"	},
-- 	{time = 0.020,	name = "S+"		},
-- 	{time = 0.024,	name = "S"		},
-- 	{time = 0.028,	name = "A+"		},
-- 	{time = 0.032,	name = "A"		},
-- 	{time = 0.048,	name = "B"		},
-- 	{time = 0.98,	name = "E"		},
-- 	{name = "F"},
-- }



-- Score.updateGrade = function(self)
-- 	local accuracy = self.accuracy / 1000
-- 	local grades = self.grades
-- 	for i = 1, #grades - 1 do
-- 		if accuracy <= grades[i].time then
-- 			self.grade = grades[i].name
-- 			return
-- 		end
-- 	end
-- 	self.grade = grades[#grades].name
-- end

-- Score.interval = 0.004
-- Score.scale = 3.6
-- Score.unit = 1/60
-- Score.hit = function(self, score, maxScore, deltaTime, time)
-- 	self.hits[#self.hits + 1] = {time, deltaTime}
	
-- 	local judgeIndex = self:judge(deltaTime)
-- 	self.judges[judgeIndex] = (self.judges[judgeIndex] or 0) + 1
	
-- 	self.maxScore = self.maxScore + maxScore
	
-- 	self:send({
-- 		name = "hit",
-- 		time = time,
-- 		deltaTime = deltaTime
-- 	})
	
-- 	if math.abs(deltaTime) >= self.timegates[#self.timegates - 1].time then
-- 		self:updateAccuracy()
-- 		return
-- 	end
	
-- 	-- self.count = self.count + 1
-- 	-- self.sum = self.sum + (deltaTime * 1000) ^ 2
-- 	-- self.accuracy = math.sqrt(self.sum / self.count)
-- 	-- self:updateGrade()
	
-- 	self.score = self.score
-- 		+ score
-- 		* math.exp(-(deltaTime / self.unit / self.scale) ^ 2)
-- 		/ self.scoreEngine.maxScore
-- 		* 1000000
	
-- 	self:updateAccuracy()
	
-- 	local timegateData = self.timegates[judgeIndex]
-- 	if deltaTime < 0 and timegateData.nameEarly then
-- 		self.timegate = timegateData.nameEarly
-- 	elseif deltaTime > 0 and timegateData.nameLate then
-- 		self.timegate = timegateData.nameLate
-- 	else
-- 		self.timegate = timegateData.name
-- 	end
-- end

-- Score.updateAccuracy = function(self)
-- 	self.accuracy = 1000 * math.sqrt(math.abs(-math.log(self.score / 1000000 * self.scoreEngine.maxScore / self.maxScore))) * self.unit * self.scale
-- 	-- self:updateGrade()
-- end

-- Score.judge = function(self, deltaTime)
-- 	local deltaTime = math.abs(deltaTime)
-- 	for i = 1, #self.timegates do
-- 		if deltaTime <= self.timegates[i].time then
-- 			return i
-- 		end
-- 	end
-- 	return #self.timegates
-- end

-- Score.increaseCombo = function(self)
-- 	self.combo = self.combo + 1
-- end

-- Score.breakCombo = function(self)
-- 	self.combo = 0
-- end

return ScoreSystem
