local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

---@class sphere.SoundsphereScoring: sphere.ScoreSystem
---@operator call: sphere.SoundsphereScoring
local SoundsphereScoring = ScoreSystem + {}

SoundsphereScoring.name = "soundsphere"
SoundsphereScoring.metadata = {
	name = "Soundsphere"
}

local orderedCounterNames = {"perfect", "not perfect"}

function SoundsphereScoring:load()
    self.judges = {
        [self.metadata.name] = {
            counters = {
				perfect = 0,
				["not perfect"] = 0,
				miss = 0
			},
            earlyLate = {
				early = 0,
				late = 0
			},
            notes = 0,
            getOrderedCounterNames = function()
                return orderedCounterNames
            end
        }
    }
end

function SoundsphereScoring:hit(event)
    local judge = self.judges[self.metadata.name]

    judge.notes = judge.notes + 1

    local delta = event.deltaTime

    if delta < 0 then
        judge.earlyLate.early = judge.earlyLate.early + 1
    else
        judge.earlyLate.late = judge.earlyLate.late + 1
    end

    if math.abs(delta) < 0.016 then
        judge.counters.perfect = judge.counters.perfect + 1
        return
    end

    judge.counters["not perfect"] = judge.counters["not perfect"] + 1
end

function SoundsphereScoring:miss()
    local judge = self.judges[self.metadata.name]

    judge.notes = judge.notes + 1
    judge.counters.miss = judge.counters.miss + 1
end

SoundsphereScoring.notes = {
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
            endMissed = "hit"
        },
        startMissed = {
			startMissedPressed = nil,
			endMissed = "miss"
		}
    }
}

return SoundsphereScoring
