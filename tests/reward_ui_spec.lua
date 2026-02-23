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

--- Validates streak calculations across normal and wrap-around states.
local function testGetClaimedCount()
	expect(getClaimedCount(0, 7) == 0, "Expected no claimed rewards at streak 0.")
	expect(getClaimedCount(1, 7) == 1, "Expected first reward to be claimed at streak 1.")
	expect(getClaimedCount(7, 7) == 7, "Expected full week claimed at streak 7.")
	expect(getClaimedCount(8, 7) == 1, "Expected week to wrap after streak 8.")
	expect(getClaimedCount(14, 7) == 7, "Expected full week claimed at streak 14.")
	expect(getClaimedCount(3, 0) == 0, "Expected no claimed rewards for empty reward table.")
end

testGetClaimedCount()
