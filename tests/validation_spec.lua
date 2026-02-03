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

--- Validates assertPositiveInteger behavior.
local function testAssertPositiveInteger()
	expect(Validation.assertPositiveInteger(3), "Expected 3 to be a positive integer.")
	expect(not Validation.assertPositiveInteger(0), "Expected 0 to be invalid.")
	expect(not Validation.assertPositiveInteger(2.5), "Expected 2.5 to be invalid.")
end

--- Validates assertNonEmptyString behavior.
local function testAssertNonEmptyString()
	expect(Validation.assertNonEmptyString("Quest"), "Expected non-empty string.")
	expect(not Validation.assertNonEmptyString(""), "Expected empty string to be invalid.")
end

--- Validates assertTableHasKeys behavior.
local function testAssertTableHasKeys()
	expect(Validation.assertTableHasKeys({ A = 1, B = 2 }, { "A", "B" }), "Expected keys to exist.")
	expect(not Validation.assertTableHasKeys({ A = 1 }, { "A", "B" }), "Expected missing key to fail.")
end

--- Validates clampNumber behavior.
local function testClampNumber()
	expect(Validation.clampNumber(5, 1, 10) == 5, "Expected 5 to remain.")
	expect(Validation.clampNumber(0, 1, 10) == 1, "Expected 0 to clamp to 1.")
	expect(Validation.clampNumber(12, 1, 10) == 10, "Expected 12 to clamp to 10.")
end

testAssertInList()
testAssertNumberInRange()
testAssertPositiveInteger()
testAssertNonEmptyString()
testAssertTableHasKeys()
testClampNumber()
