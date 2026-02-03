--!strict
-- Unit tests for Validation module (conceptual, runnable in Luau test harness).

local Validation = require(game:GetService("ReplicatedStorage"):WaitForChild("GardenGame"):WaitForChild("Modules"):WaitForChild("Validation"))

--- Simple assertion helper.
local function expect(condition: boolean, message: string)
	if not condition then
		error(message)
	end
end

--- Validates assertInList behavior.
local function testAssertInList()
	expect(Validation.assertInList("A", {"A", "B"}), "Expected 'A' to be in list.")
	expect(not Validation.assertInList("C", {"A", "B"}), "Expected 'C' to be missing from list.")
end

--- Validates assertNumberInRange behavior.
local function testAssertNumberInRange()
	expect(Validation.assertNumberInRange(5, 1, 10), "Expected 5 in range 1..10.")
	expect(not Validation.assertNumberInRange(0, 1, 10), "Expected 0 out of range 1..10.")
end

testAssertInList()
testAssertNumberInRange()
