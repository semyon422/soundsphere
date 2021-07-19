load = function()
	scoreTable.hp = 0.5
	scoreTable.failed = false
end

local prevMisscount = 0
local prevHitcount = 0
local prevHitDeltaTime = 0
receive = function(event)
	if event.name ~= "ScoreNoteState" then
		return
	end

	if scoreTable.failed then
		return
	end

	if scoreTable.misscount ~= prevMisscount then
		scoreTable.hp = math.max(scoreTable.hp - 0.05, 0)
		prevMisscount = scoreTable.misscount
		if scoreTable.hp < 1e-6 then
			scoreTable.failed = true
			print("failed")
		end
	end

	-- combo based hp increase
	if scoreTable.hitcount ~= prevHitcount then
		scoreTable.hp = math.min(scoreTable.hp + 0.001, 1)
		prevHitcount = scoreTable.hitcount
	end

	-- accuracy based hp increase
	-- if scoreTable.lastHitDeltaTime ~= prevHitDeltaTime then
	-- 	local dhp = 2 ^ (-math.abs(scoreTable.lastHitDeltaTime) / 0.01) / 100
	-- 	scoreTable.hp = math.min(scoreTable.hp + dhp, 1)
	-- 	prevHitDeltaTime = scoreTable.lastHitDeltaTime
	-- end
end

