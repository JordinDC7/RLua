--[[
	Bricks Gang Addon Progression Rework
	Drop-in progression + upgrade model tuned for long-term servers with rare wipes.
	This module intentionally separates balancing math from persistence so it can be
	wired into existing Bricks Gang hooks/callbacks.
]]

local GangProgression = {}

GangProgression.Config = {
	MaxLevel = 75,
	BaseXP = 2200,
	LinearXP = 650,
	QuadraticXP = 24,
	SoftCapLevel = 35,
	SoftCapMultiplier = 1.28,
	HardCapLevel = 60,
	HardCapMultiplier = 1.52,
	PremiumCreditsStoreURL = "https://smgrpdonate.shop/",
	UpgradePointInterval = 2,
	DoctrineUnlockLevel = 20
}

GangProgression.Doctrines = {
	ledger = {
		name = "Ledger Syndicate",
		description = "Economic doctrine with stronger passive income and market control.",
		effects = {
			incomeMultiplier = 1.12,
			territoryTaxBonus = 0.08,
			raidLossReduction = 0.06
		}
	},
	ironwall = {
		name = "Ironwall Pact",
		description = "Defense doctrine focused on protection windows and raid resilience.",
		effects = {
			vaultProtectionSeconds = 180,
			defenseRewardBonus = 0.15,
			memberRespawnArmor = 15
		}
	},
	nightfall = {
		name = "Nightfall Circuit",
		description = "Aggressive doctrine with stronger raids but weaker passive safety.",
		effects = {
			raidDamageBonus = 0.12,
			raidLootBonus = 0.1,
			passiveIncomePenalty = -0.04
		}
	}
}

GangProgression.Upgrades = {
	passive_income = {
		name = "Front Businesses",
		category = "economy",
		maxRank = 10,
		unlockLevel = 1,
		baseCost = 25000,
		costScale = 1.38,
		effectPerRank = 0.035
	},
	vault_security = {
		name = "Vault Security Grid",
		category = "defense",
		maxRank = 8,
		unlockLevel = 5,
		baseCost = 34000,
		costScale = 1.42,
		effectPerRank = 0.055
	},
	member_slots = {
		name = "Recruitment Network",
		category = "logistics",
		maxRank = 12,
		unlockLevel = 2,
		baseCost = 30000,
		costScale = 1.31,
		effectPerRank = 1
	},
	crafting_discount = {
		name = "Supply Chain Access",
		category = "economy",
		maxRank = 6,
		unlockLevel = 14,
		baseCost = 62000,
		costScale = 1.44,
		effectPerRank = 0.025
	},
	territory_control = {
		name = "Territory Governance",
		category = "influence",
		maxRank = 7,
		unlockLevel = 10,
		baseCost = 48000,
		costScale = 1.4,
		effectPerRank = 0.04
	},
	raid_window = {
		name = "Raid Window Calibration",
		category = "warfare",
		maxRank = 5,
		unlockLevel = 18,
		baseCost = 87000,
		costScale = 1.47,
		effectPerRank = 90
	},
	reputation_gain = {
		name = "Street Reputation Campaign",
		category = "influence",
		maxRank = 9,
		unlockLevel = 8,
		baseCost = 36000,
		costScale = 1.37,
		effectPerRank = 0.045
	},
	black_market = {
		name = "Black Market Contacts",
		category = "economy",
		maxRank = 4,
		unlockLevel = 24,
		baseCost = 120000,
		costScale = 1.5,
		effectPerRank = 0.06
	},
	intel_network = {
		name = "Intel Broker Network",
		category = "warfare",
		maxRank = 6,
		unlockLevel = 28,
		baseCost = 130000,
		costScale = 1.48,
		effectPerRank = 0.05
	},
	command_slots = {
		name = "Command Structure",
		category = "logistics",
		maxRank = 5,
		unlockLevel = 16,
		baseCost = 72000,
		costScale = 1.43,
		effectPerRank = 1
	},
	festival_protocol = {
		name = "City Festival Protocol",
		category = "identity",
		maxRank = 3,
		unlockLevel = 30,
		baseCost = 210000,
		costScale = 1.6,
		effectPerRank = 0.08
	},
	data_forge = {
		name = "Data Forge",
		category = "identity",
		maxRank = 4,
		unlockLevel = 40,
		baseCost = 300000,
		costScale = 1.65,
		effectPerRank = 0.07
	}
}

--- Logs progression events in structured form for consistent diagnostics.
--- @param level string
--- @param message string
--- @param context table|nil
function GangProgression.Log(level, message, context)
	context = context or {}
	local payload = string.format("[GangProgression][%s] %s | %s", level, message, util and util.TableToJSON and util.TableToJSON(context) or "{}")
	if level == "error" then
		ErrorNoHalt(payload .. "\n")
	else
		print(payload)
	end
end

--- Returns XP required to go from the current level to the next level.
--- @param level number
--- @return number
function GangProgression.GetRequiredXP(level)
	if level < 1 then
		GangProgression.Log("warn", "Invalid level supplied to GetRequiredXP", { level = level })
		return GangProgression.Config.BaseXP
	end

	local cfg = GangProgression.Config
	local xp = cfg.BaseXP + (cfg.LinearXP * (level - 1)) + (cfg.QuadraticXP * (level - 1) ^ 2)

	if level >= cfg.HardCapLevel then
		xp = xp * cfg.HardCapMultiplier
	elseif level >= cfg.SoftCapLevel then
		xp = xp * cfg.SoftCapMultiplier
	end

	return math.floor(xp)
end

--- Converts total gang XP into a level + leftover XP snapshot.
--- @param totalXP number
--- @return number, number
function GangProgression.GetLevelFromTotalXP(totalXP)
	if totalXP < 0 then
		GangProgression.Log("warn", "Negative XP passed to GetLevelFromTotalXP", { totalXP = totalXP })
		totalXP = 0
	end

	local level = 1
	local remaining = math.floor(totalXP)
	while level < GangProgression.Config.MaxLevel do
		local required = GangProgression.GetRequiredXP(level)
		if remaining < required then
			break
		end
		remaining = remaining - required
		level = level + 1
	end

	return level, remaining
end

--- Calculates upgrade point grants based on level milestones.
--- @param level number
--- @return number
function GangProgression.GetUpgradePointsForLevel(level)
	if level <= 1 then
		return 0
	end

	return math.floor((level - 1) / GangProgression.Config.UpgradePointInterval)
end

--- Returns the coin cost for purchasing the next rank of an upgrade.
--- @param upgradeId string
--- @param currentRank number
--- @return number|nil
function GangProgression.GetUpgradeCost(upgradeId, currentRank)
	local definition = GangProgression.Upgrades[upgradeId]
	if not definition then
		GangProgression.Log("error", "Unknown upgrade ID in GetUpgradeCost", { upgradeId = upgradeId })
		return nil
	end

	local nextRank = currentRank + 1
	if nextRank > definition.maxRank then
		return nil
	end

	local cost = definition.baseCost * (definition.costScale ^ (nextRank - 1))
	return math.floor(cost)
end

--- Validates whether a gang can buy a specific upgrade rank.
--- @param gangData table
--- @param upgradeId string
--- @return boolean, string
function GangProgression.CanPurchaseUpgrade(gangData, upgradeId)
	local definition = GangProgression.Upgrades[upgradeId]
	if not definition then
		return false, "unknown_upgrade"
	end

	local gangLevel = gangData.level or 1
	if gangLevel < definition.unlockLevel then
		return false, "level_locked"
	end

	local currentRank = (gangData.upgrades and gangData.upgrades[upgradeId]) or 0
	if currentRank >= definition.maxRank then
		return false, "max_rank"
	end

	local pointsAvailable = gangData.upgradePoints or 0
	if pointsAvailable <= 0 then
		return false, "no_points"
	end

	local nextCost = GangProgression.GetUpgradeCost(upgradeId, currentRank)
	if not nextCost then
		return false, "invalid_cost"
	end

	if (gangData.balance or 0) < nextCost then
		return false, "insufficient_funds"
	end

	return true, "ok"
end

--- Returns whether a doctrine can be selected at the current level.
--- @param level number
--- @return boolean
function GangProgression.CanSelectDoctrine(level)
	return level >= GangProgression.Config.DoctrineUnlockLevel
end

--- Resolves premium credit store URL from Prometheus integration when available.
--- @return string
function GangProgression.ResolvePremiumCreditsStoreURL()
	if istable(Prometheus) and isfunction(Prometheus.GetCreditsStoreURL) then
		local storeURL = Prometheus.GetCreditsStoreURL()
		if isstring(storeURL) and storeURL ~= "" then
			return storeURL
		end
		GangProgression.Log("warn", "Prometheus returned invalid credits store URL", {
			storeURLType = type(storeURL)
		})
	end

	return GangProgression.Config.PremiumCreditsStoreURL
end

--- Resolves consistent redirect metadata for premium credit purchase flows.
--- @return table
function GangProgression.ResolvePremiumCreditsRedirect()
	local storeURL = GangProgression.ResolvePremiumCreditsStoreURL()
	local redirectPayload = {
		fallbackAction = "gui_open_url"
	}

	if isstring(storeURL) and storeURL ~= "" then
		redirectPayload.fallbackURL = storeURL
	else
		storeURL = nil
	end

	if istable(Prometheus) and isfunction(Prometheus.OpenShop) then
		redirectPayload.openShopFunction = "Prometheus.OpenShop"
	end

	if not redirectPayload.fallbackURL and not redirectPayload.openShopFunction then
		GangProgression.Log("warn", "Unable to resolve premium credits redirect target", {
			storeURLType = type(storeURL),
			hasOpenShopFunction = false
		})
	end

	return {
		ctaURL = storeURL,
		redirectType = "prometheus_shop",
		redirectAddon = "prometheus",
		redirectPayload = redirectPayload
	}
end

--- Provides the next UI action for custom jobs that use premium credits.
--- @param premiumCredits number
--- @param customJobCost number
--- @return table
function GangProgression.GetCustomJobPremiumCreditAction(premiumCredits, customJobCost)
	local redirectMetadata = GangProgression.ResolvePremiumCreditsRedirect()

	if type(premiumCredits) ~= "number" or type(customJobCost) ~= "number" then
		GangProgression.Log("error", "Invalid premium credit action input", {
			premiumCreditsType = type(premiumCredits),
			customJobCostType = type(customJobCost)
		})
		return {
			affordable = false,
			errorCode = "invalid_input",
			ctaURL = redirectMetadata.ctaURL,
			redirectType = redirectMetadata.redirectType,
			redirectAddon = redirectMetadata.redirectAddon,
			redirectPayload = redirectMetadata.redirectPayload
		}
	end

	if premiumCredits < customJobCost then
		return {
			affordable = false,
			errorCode = "insufficient_premium_credits",
			ctaURL = redirectMetadata.ctaURL,
			redirectType = redirectMetadata.redirectType,
			redirectAddon = redirectMetadata.redirectAddon,
			redirectPayload = redirectMetadata.redirectPayload
		}
	end

	return {
		affordable = true,
		errorCode = "ok",
		ctaURL = nil
	}
end

--- Safely normalizes gang data for progression calculations.
--- @param gangData table|nil
--- @return table
function GangProgression.NormalizeGangData(gangData)
	if type(gangData) ~= "table" then
		GangProgression.Log("warn", "NormalizeGangData received invalid gang data", {
			gangDataType = type(gangData)
		})
		gangData = {}
	end

	local normalized = {
		totalXP = math.max(0, math.floor(tonumber(gangData.totalXP) or 0)),
		balance = math.max(0, math.floor(tonumber(gangData.balance) or 0)),
		upgrades = {},
		doctrineId = gangData.doctrineId
	}

	if type(gangData.upgrades) == "table" then
		for upgradeId, rank in pairs(gangData.upgrades) do
			if GangProgression.Upgrades[upgradeId] then
				normalized.upgrades[upgradeId] = math.max(0, math.floor(tonumber(rank) or 0))
			else
				GangProgression.Log("warn", "Ignoring unknown upgrade while normalizing gang data", {
					upgradeId = upgradeId
				})
			end
		end
	end

	local level, xpIntoLevel = GangProgression.GetLevelFromTotalXP(normalized.totalXP)
	normalized.level = level
	normalized.xpIntoLevel = xpIntoLevel
	normalized.requiredXP = GangProgression.GetRequiredXP(level)
	normalized.upgradePoints = GangProgression.GetUpgradePointsForLevel(level)

	return normalized
end

--- Computes total upgrade points spent on active upgrade ranks.
--- @param upgrades table|nil
--- @return number
function GangProgression.GetSpentUpgradePoints(upgrades)
	if type(upgrades) ~= "table" then
		return 0
	end

	local spent = 0
	for upgradeId, rank in pairs(upgrades) do
		local definition = GangProgression.Upgrades[upgradeId]
		if definition then
			spent = spent + math.min(definition.maxRank, math.max(0, math.floor(tonumber(rank) or 0)))
		end
	end

	return spent
end

--- Builds a UI-focused progression snapshot with upgrade unlock information.
--- @param gangData table|nil
--- @return table
function GangProgression.GetProgressionSnapshot(gangData)
	local normalized = GangProgression.NormalizeGangData(gangData)
	local spentUpgradePoints = GangProgression.GetSpentUpgradePoints(normalized.upgrades)
	local availableUpgradePoints = math.max(0, normalized.upgradePoints - spentUpgradePoints)

	local nextUpgradeUnlock = nil
	for upgradeId, definition in pairs(GangProgression.Upgrades) do
		local currentRank = normalized.upgrades[upgradeId] or 0
		if currentRank < definition.maxRank and normalized.level < definition.unlockLevel then
			if not nextUpgradeUnlock or definition.unlockLevel < nextUpgradeUnlock.unlockLevel then
				nextUpgradeUnlock = {
					upgradeId = upgradeId,
					name = definition.name,
					unlockLevel = definition.unlockLevel
				}
			end
		end
	end

	return {
		level = normalized.level,
		totalXP = normalized.totalXP,
		xpIntoLevel = normalized.xpIntoLevel,
		requiredXP = normalized.requiredXP,
		balance = normalized.balance,
		doctrineId = normalized.doctrineId,
		upgradePointsEarned = normalized.upgradePoints,
		upgradePointsSpent = spentUpgradePoints,
		upgradePointsAvailable = availableUpgradePoints,
		nextUpgradeUnlock = nextUpgradeUnlock,
		canSelectDoctrine = GangProgression.CanSelectDoctrine(normalized.level)
	}
end

return GangProgression
