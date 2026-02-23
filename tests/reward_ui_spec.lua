--!strict
-- Unit tests for reward UI streak display behavior.

--- Simple assertion helper.
local function expect(condition: boolean, message: string)
	if not condition then
		error(message)
	end
end

--- Mirrors the reward UI claimed-day calculation logic.
local function getClaimedCount(streak: number, rewardCount: number): number
	if rewardCount <= 0 then
		return 0
	end
	local claimedCount = streak % rewardCount
	if claimedCount == 0 and streak > 0 then
		claimedCount = rewardCount
	end
	return claimedCount
end

--- Mirrors the reward UI day-boundary claim availability check.
local function canClaimDailyReward(lastClaim: number, nowUtc: number): boolean
	if lastClaim <= 0 then
		return true
	end
	local claimDate = os.date("!*t", lastClaim)
	local nowDate = os.date("!*t", nowUtc)
	return claimDate.yday ~= nowDate.yday or claimDate.year ~= nowDate.year
end

--- Validates streak calculations across normal and wrap-around states.
local function testGetClaimedCount()
	expect(getClaimedCount(0, 7) == 0, "Expected no claimed rewards at streak 0.")
	expect(getClaimedCount(1, 7) == 1, "Expected first reward to be claimed at streak 1.")
	expect(getClaimedCount(7, 7) == 7, "Expected full week claimed at streak 7.")
	expect(getClaimedCount(8, 7) == 1, "Expected week to wrap after streak 8.")
	expect(getClaimedCount(14, 7) == 7, "Expected full week claimed at streak 14.")
	expect(getClaimedCount(3, 0) == 0, "Expected no claimed rewards for empty reward table.")
end

--- Validates claim availability changes only once per UTC day.
local function testCanClaimDailyReward()
	expect(canClaimDailyReward(0, 1000), "Expected missing claim timestamp to be claimable.")
	expect(not canClaimDailyReward(1704067200, 1704067200 + 3600), "Expected same UTC day to be unclaimable.")
	expect(canClaimDailyReward(1704067200, 1704153600), "Expected next UTC day to be claimable.")
	expect(canClaimDailyReward(1735686000, 1735689600), "Expected new UTC year/day to be claimable.")
end

testGetClaimedCount()
testCanClaimDailyReward()
