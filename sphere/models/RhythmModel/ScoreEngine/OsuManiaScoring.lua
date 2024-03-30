local class = require("class")

local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

---@class sphere.OsuManiaScoring: sphere.ScoreSystem
---@operator call: sphere.OsuManiaScoring
local OsuManiaScoring = ScoreSystem + {}

OsuManiaScoring.name = "osuMania"
OsuManiaScoring.metadata = {
	name = "osu!mania OD%d",
	range = {0, 10}
}

local Judge = class()

local orderedCounters = {"perfect", "great", "good", "ok", "meh"}

---@param od number
function Judge:new(od)
    self.accuracy = 1
    self.notes = 0
    self.lastCounter = nil
    self.lastUpdateTime = 0

    self.weights = {
        perfect = 305,
        great = 300,
        good = 200,
        ok = 100,
        meh = 50,
        miss = 0
    }

    local od3 = 3 * od
    self.windows = {
        perfect = 0.016,
        great = (64 - od3) / 1000,
        good = (97 - od3) / 1000,
        ok = (127 - od3) / 1000,
        meh = (157 - od3) / 1000,
        miss = (188 - od3) / 1000
    }

    self.counters = {
        perfect = 0,
        great = 0,
        good = 0,
        ok = 0,
        meh = 0,
        miss = 0
    }

    self.hitWindow = self.windows.meh
    self.missWindow = self.windows.miss

    self.windowReleaseMultiplier = 1.5
end

---@param key string
---@param deltaTime number
function Judge:addCounter(key, deltaTime)
    self.notes = self.notes + 1
    self.counters[key] = self.counters[key] + 1
    self.lastCounter = key
    self.lastUpdateTime = deltaTime
end

---@param event table
function Judge:processEvent(event)
    local isRelease = event.newState == "endPassed" or event.newState == "endMissedPassed"

    local deltaTime = event.deltaTime
    deltaTime = isRelease and deltaTime / self.windowReleaseMultiplier or deltaTime

    if deltaTime > self.hitWindow then
        self:addCounter("miss", deltaTime)
        return
    end

    deltaTime = math.abs(deltaTime)

    for _, key in ipairs(orderedCounters) do
        local window = self.windows[key]

        if deltaTime < window then
            self:addCounter(key, deltaTime)
            return
        end
    end
end

function Judge:calculateAccuracy()
    local maxScore = self.notes * self.weights.perfect
    local score = 0

    for key, count in pairs(self.counters) do
        score = score + (self.weights[key] * count)
    end

    self.accuracy = maxScore > 0 and score / maxScore or 1
end

function Judge:getTimings()
    local hit = self.hitWindow
    local miss = self.missWindow
    local releaseHit = hit * self.windowReleaseMultiplier
    local releaseMiss = miss * self.windowReleaseMultiplier

    return {
        nearest = true,
        ShortNote = {hit = {-hit, hit}, miss = {-miss, miss}},
        LongNoteStart = {hit = {-hit, hit}, miss = {-miss, miss}},
        LongNoteEnd = {
            hit = {-releaseHit, releaseHit},
            miss = {-releaseMiss, releaseMiss}
        }
    }
end

---@return table
function Judge:getOrderedCounterNames()
	return orderedCounters
end

function OsuManiaScoring:load()
    self.judges = {}

    local range = self.metadata.range
    local name = self.metadata.name

    for od = range[1], range[2], 1 do
        self.judges[name:format(od)] = Judge(od)
    end
end

---@param event table
function OsuManiaScoring:hit(event)
    for _, judge in pairs(self.judges) do
        judge:processEvent(event)
        judge:calculateAccuracy()
    end
end

---@param event table
function OsuManiaScoring:miss(event)
    for _, judge in pairs(self.judges) do
        judge:addCounter("miss", event.deltaTime)
        judge:calculateAccuracy()
    end
end

---@param od number
---@return table
function OsuManiaScoring:getTimings(od)
	local judge = Judge(od)
    return judge:getTimings()
end

OsuManiaScoring.notes = {
    ShortNote = {
		clear = {
			passed = "hit",
			missed = "miss",
			clear = nil
		}
	},
    LongNote = {
        clear = {
            startPassedPressed = "hit",
            startMissed = "miss",
            startMissedPressed = "miss",
            clear = nil
        },
        startPassedPressed = {
            startMissed = "miss",
            endMissed = "miss",
            endPassed = "hit"
        },
        startMissedPressed = {
            endMissedPassed = "hit",
            startMissed = nil,
            endMissed = nil
        },
        startMissed = {
			startMissedPressed = nil,
			endMissed = "miss"
		}
    }
}

return OsuManiaScoring
