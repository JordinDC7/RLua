-- RLua weapon stat system.
-- Mimics rarity-based random stat rolls from unboxing and applies those rolls to SWEP stat tables.

RLuaWeaponStats = RLuaWeaponStats or {}

local LOG_TAG = "[RLua][WeaponStats]"

--- Emits a structured log message for the weapon stats system.
--- @param level string
--- @param message string
--- @param context table|nil
local function log(level, message, context)
	context = context or {}
	local payload = "{}"
	if util and util.TableToJSON then
		payload = util.TableToJSON(context) or "{}"
	end
	MsgC(Color(180, 220, 255), string.format("%s[%s] %s %s\n", LOG_TAG, string.upper(tostring(level)), message, payload))
end

--- Returns whether the value is a finite number.
--- @param value any
--- @return boolean
local function isFiniteNumber(value)
	return isnumber(value) and value == value and value > -math.huge and value < math.huge
end

--- Deep-copies a table while preserving scalar values.
--- @param value any
--- @return any
local function deepCopy(value)
	if not istable(value) then
		return value
	end

	local copy = {}
	for key, nested in pairs(value) do
		copy[key] = deepCopy(nested)
	end
	return copy
end

-- Rarity quality bounds. Higher rarities get stronger rolls and more stat lines.
RLuaWeaponStats.RARITY_RULES = {
	common = { minLines = 1, maxLines = 2, strengthMin = 0.35, strengthMax = 0.55 },
	uncommon = { minLines = 2, maxLines = 3, strengthMin = 0.5, strengthMax = 0.7 },
	rare = { minLines = 2, maxLines = 4, strengthMin = 0.65, strengthMax = 0.85 },
	epic = { minLines = 3, maxLines = 5, strengthMin = 0.8, strengthMax = 1.0 },
	legendary = { minLines = 4, maxLines = 6, strengthMin = 0.95, strengthMax = 1.2 },
	glitched = { minLines = 5, maxLines = 6, strengthMin = 1.1, strengthMax = 1.35 },
	mythical = { minLines = 5, maxLines = 6, strengthMin = 1.25, strengthMax = 1.5 }
}

-- Stat pool with per-line ranges at full quality (quality scales these values).
RLuaWeaponStats.STAT_POOL = {
	damage = { min = 0.03, max = 0.25, appliesTo = "DamageMult" },
	fire_rate = { min = 0.02, max = 0.2, appliesTo = "FireRateMult" },
	recoil_control = { min = 0.04, max = 0.3, appliesTo = "RecoilMult" },
	accuracy = { min = 0.03, max = 0.25, appliesTo = "SpreadMult" },
	reload_speed = { min = 0.03, max = 0.25, appliesTo = "ReloadMult" },
	magazine_size = { min = 1, max = 12, appliesTo = "ClipAdd", integer = true }
}

--- Returns a random float between min and max.
--- @param min number
--- @param max number
--- @return number
local function randomFloat(min, max)
	return min + (max - min) * math.Rand(0, 1)
end

--- Picks and removes a random element from an array.
--- @param list table
--- @return any
local function popRandom(list)
	local index = math.random(1, #list)
	local value = list[index]
	table.remove(list, index)
	return value
end

--- Rolls randomized stat modifiers based on rarity.
--- @param rarity string
--- @return table
function RLuaWeaponStats.RollStats(rarity)
	rarity = string.lower(tostring(rarity or "common"))
	local rules = RLuaWeaponStats.RARITY_RULES[rarity]
	if not rules then
		log("warn", "Unknown rarity requested; falling back to common", { rarity = rarity })
		rules = RLuaWeaponStats.RARITY_RULES.common
		rarity = "common"
	end

	local strength = randomFloat(rules.strengthMin, rules.strengthMax)
	local statLines = math.random(rules.minLines, rules.maxLines)

	local keys = {}
	for statKey in pairs(RLuaWeaponStats.STAT_POOL) do
		table.insert(keys, statKey)
	end

	local modifiers = {}
	for _ = 1, math.min(statLines, #keys) do
		local statKey = popRandom(keys)
		local definition = RLuaWeaponStats.STAT_POOL[statKey]
		local rolled = randomFloat(definition.min, definition.max) * strength
		if definition.integer then
			rolled = math.max(1, math.floor(rolled + 0.5))
		end
		modifiers[statKey] = rolled
	end

	return {
		rarity = rarity,
		strength = strength,
		modifiers = modifiers
	}
end

--- Applies rolled modifiers to a SWEP-like weapon stat table.
--- @param weaponData table
--- @param rolled table
--- @return table
function RLuaWeaponStats.ApplyRoll(weaponData, rolled)
	if not istable(weaponData) then
		log("error", "weaponData must be a table", { type = type(weaponData) })
		return {}
	end
	if not istable(rolled) or not istable(rolled.modifiers) then
		log("error", "rolled stat payload missing modifiers", { rolledType = type(rolled) })
		return deepCopy(weaponData)
	end

	local updated = deepCopy(weaponData)
	updated.Primary = updated.Primary or {}
	local modifiers = rolled.modifiers

	if isFiniteNumber(modifiers.damage) and isFiniteNumber(updated.Primary.Damage) then
		updated.Primary.Damage = math.max(1, updated.Primary.Damage * (1 + modifiers.damage))
	end

	if isFiniteNumber(modifiers.fire_rate) and isFiniteNumber(updated.Primary.Delay) then
		updated.Primary.Delay = math.max(0.01, updated.Primary.Delay * (1 - modifiers.fire_rate))
	end

	if isFiniteNumber(modifiers.recoil_control) and isFiniteNumber(updated.Primary.Recoil) then
		updated.Primary.Recoil = math.max(0, updated.Primary.Recoil * (1 - modifiers.recoil_control))
	end

	if isFiniteNumber(modifiers.accuracy) and isFiniteNumber(updated.Primary.Spread) then
		updated.Primary.Spread = math.max(0, updated.Primary.Spread * (1 - modifiers.accuracy))
	end

	if isFiniteNumber(modifiers.reload_speed) and isFiniteNumber(updated.Primary.ReloadTime) then
		updated.Primary.ReloadTime = math.max(0.1, updated.Primary.ReloadTime * (1 - modifiers.reload_speed))
	end

	if isFiniteNumber(modifiers.magazine_size) and isFiniteNumber(updated.Primary.ClipSize) then
		updated.Primary.ClipSize = math.max(1, updated.Primary.ClipSize + math.floor(modifiers.magazine_size + 0.5))
	end

	updated.__rolledStats = rolled
	return updated
end

--- Creates a user-facing stat summary for UI display.
--- @param rolled table
--- @return table
function RLuaWeaponStats.BuildSummary(rolled)
	if not istable(rolled) or not istable(rolled.modifiers) then
		return {}
	end

	local summary = {}
	for statKey, value in pairs(rolled.modifiers) do
		if statKey == "magazine_size" then
			table.insert(summary, string.format("+%d Magazine Size", math.floor(value + 0.5)))
		else
			table.insert(summary, string.format("+%d%% %s", math.floor(value * 100 + 0.5), string.upper(statKey:gsub("_", " "))))
		end
	end
	table.sort(summary)
	return summary
end

log("info", "Weapon stat system loaded", {
	rarities = table.Count(RLuaWeaponStats.RARITY_RULES),
	stats = table.Count(RLuaWeaponStats.STAT_POOL)
})
