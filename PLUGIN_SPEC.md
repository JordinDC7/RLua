# Garden Legends Generator Plugin (.rbxmx) Specification

This document describes the **single .rbxmx plugin model** (Instances + hierarchy) and the **full Luau source** for each Script/ModuleScript/LocalScript in that model. The plugin generates a modern, live-ops-ready farming adventure with quests, daily rewards, pets, crafting, boosts, and polished visuals in the open place when the toolbar button is clicked.

---

## 1) Plugin Model Structure (Instances + Hierarchy)

```
GardenGameGeneratorPlugin (Folder)
└── PluginMain (Script)
```

> The plugin consists of a single Script inside a model/folder. Running the script in Studio creates the toolbar button and generates/updates all game content.

---

## 2) Full Luau Source Code for Each Script

### Script: `PluginMain`
```lua
--!strict
-- Garden Legends Generator Plugin
-- Creates/updates a modern farming adventure game with a single toolbar click.

local toolbar = plugin:CreateToolbar("Garden Legends")
local button = toolbar:CreateButton(
	"Generate Game",
	"Generate or update the Garden Legends game in the open place",
	"rbxassetid://4458901886"
)
button.ClickableWhenViewportHidden = true

local ROOT_ATTR = "GG_CREATED"
local ROOT_NAME = "GardenGame"

local SETTINGS_SOURCE
local VALIDATION_SOURCE
local CATALOG_SOURCE
local PLAYER_DATA_SOURCE
local PLOT_SERVICE_SOURCE
local ECONOMY_SERVICE_SOURCE
local GROWTH_SERVICE_SOURCE
local SOCIAL_SERVICE_SOURCE
local QUEST_SERVICE_SOURCE
local REWARD_SERVICE_SOURCE
local CRAFTING_SERVICE_SOURCE
local PET_SERVICE_SOURCE
local BOOST_SERVICE_SOURCE
local WORLD_SERVICE_SOURCE
local SERVER_MAIN_SOURCE
local CLIENT_MAIN_SOURCE

--// Utilities

--- Returns or creates a child with className and name.
local function ensureChild(parent: Instance, className: string, name: string): Instance
	local child = parent:FindFirstChild(name)
	if child and child.ClassName == className then
		return child
	end
	if child then
		child:Destroy()
	end
	local created = Instance.new(className)
	created.Name = name
	created.Parent = parent
	return created
end

--- Removes previously generated content from the container.
local function cleanGenerated(container: Instance)
	for _, child in ipairs(container:GetChildren()) do
		if child:GetAttribute(ROOT_ATTR) == true then
			child:Destroy()
		end
	end
end

--- Marks an instance and its descendants as generated content.
local function markGenerated(instance: Instance)
	instance:SetAttribute(ROOT_ATTR, true)
	for _, descendant in ipairs(instance:GetDescendants()) do
		descendant:SetAttribute(ROOT_ATTR, true)
	end
end

--- Builds ModuleScript or Script with provided source.
local function createScript(parent: Instance, className: string, name: string, source: string): Instance
	local scriptInstance = ensureChild(parent, className, name)
	scriptInstance.Source = source
	return scriptInstance
end

--- Builds folders and fills them with children content.
local function buildGame()
	local workspace = game:GetService("Workspace")
	local replicatedStorage = game:GetService("ReplicatedStorage")
	local serverScriptService = game:GetService("ServerScriptService")
	local starterGui = game:GetService("StarterGui")
	local lighting = game:GetService("Lighting")

	cleanGenerated(workspace)
	cleanGenerated(replicatedStorage)
	cleanGenerated(serverScriptService)
	cleanGenerated(starterGui)

	-- Workspace map
	local worldRoot = ensureChild(workspace, "Folder", ROOT_NAME)
	local plotsFolder = ensureChild(worldRoot, "Folder", "Plots")
	local decorFolder = ensureChild(worldRoot, "Folder", "Decorations")

	-- Lighting pass for a polished look
	lighting.Ambient = Color3.fromRGB(122, 130, 150)
	lighting.OutdoorAmbient = Color3.fromRGB(160, 165, 180)
	lighting.Brightness = 2.5
	lighting.ClockTime = 15
	local atmosphere = ensureChild(lighting, "Atmosphere", "GardenAtmosphere") :: Atmosphere
	atmosphere.Color = Color3.fromRGB(199, 220, 255)
	atmosphere.Decay = Color3.fromRGB(92, 111, 156)
	atmosphere.Density = 0.3
	local bloom = ensureChild(lighting, "BloomEffect", "GardenBloom") :: BloomEffect
	bloom.Intensity = 0.7
	bloom.Size = 20
	local colorCorrection = ensureChild(lighting, "ColorCorrectionEffect", "GardenGrade") :: ColorCorrectionEffect
	colorCorrection.Brightness = 0.05
	colorCorrection.Contrast = 0.1
	colorCorrection.Saturation = 0.1

	-- Simple map: central plaza + boundary
	local baseplate = ensureChild(worldRoot, "Part", "Baseplate") :: Part
	baseplate.Anchored = true
	baseplate.Size = Vector3.new(512, 1, 512)
	baseplate.Position = Vector3.new(0, 0, 0)
	baseplate.Material = Enum.Material.Grass
	baseplate.Color = Color3.fromRGB(88, 142, 58)

	local plaza = ensureChild(worldRoot, "Part", "Plaza") :: Part
	plaza.Anchored = true
	plaza.Size = Vector3.new(64, 1, 64)
	plaza.Position = Vector3.new(0, 1, 0)
	plaza.Material = Enum.Material.Concrete
	plaza.Color = Color3.fromRGB(200, 200, 200)

	local market = ensureChild(worldRoot, "Part", "Market") :: Part
	market.Anchored = true
	market.Size = Vector3.new(48, 1, 32)
	market.Position = Vector3.new(-90, 1, -40)
	market.Material = Enum.Material.WoodPlanks
	market.Color = Color3.fromRGB(162, 123, 95)

	local questBoard = ensureChild(worldRoot, "Part", "QuestBoard") :: Part
	questBoard.Anchored = true
	questBoard.Size = Vector3.new(12, 8, 1)
	questBoard.Position = Vector3.new(32, 5, -30)
	questBoard.Material = Enum.Material.Wood
	questBoard.Color = Color3.fromRGB(103, 71, 56)

	-- ReplicatedStorage: Modules and Remotes
	local rsRoot = ensureChild(replicatedStorage, "Folder", ROOT_NAME)
	local modulesFolder = ensureChild(rsRoot, "Folder", "Modules")
	local remotesFolder = ensureChild(rsRoot, "Folder", "Remotes")

	-- Remotes
	ensureChild(remotesFolder, "RemoteEvent", "RequestPlant")
	ensureChild(remotesFolder, "RemoteEvent", "RequestHarvest")
	ensureChild(remotesFolder, "RemoteEvent", "RequestSell")
	ensureChild(remotesFolder, "RemoteEvent", "RequestUpgrade")
	ensureChild(remotesFolder, "RemoteEvent", "RequestDecorate")
	ensureChild(remotesFolder, "RemoteEvent", "RequestGiftSeed")
	ensureChild(remotesFolder, "RemoteEvent", "RequestClaimDaily")
	ensureChild(remotesFolder, "RemoteEvent", "RequestQuestStart")
	ensureChild(remotesFolder, "RemoteEvent", "RequestQuestClaim")
	ensureChild(remotesFolder, "RemoteEvent", "RequestCraft")
	ensureChild(remotesFolder, "RemoteEvent", "RequestEquipPet")
	ensureChild(remotesFolder, "RemoteEvent", "RequestBoost")
	ensureChild(remotesFolder, "RemoteFunction", "RequestPlotSnapshot")

	-- Modules
	createScript(modulesFolder, "ModuleScript", "Settings", SETTINGS_SOURCE)
	createScript(modulesFolder, "ModuleScript", "Validation", VALIDATION_SOURCE)
	createScript(modulesFolder, "ModuleScript", "Catalog", CATALOG_SOURCE)

	-- ServerScriptService: systems
	local sssRoot = ensureChild(serverScriptService, "Folder", ROOT_NAME)
	createScript(sssRoot, "Script", "ServerMain", SERVER_MAIN_SOURCE)
	createScript(sssRoot, "ModuleScript", "PlotService", PLOT_SERVICE_SOURCE)
	createScript(sssRoot, "ModuleScript", "EconomyService", ECONOMY_SERVICE_SOURCE)
	createScript(sssRoot, "ModuleScript", "GrowthService", GROWTH_SERVICE_SOURCE)
	createScript(sssRoot, "ModuleScript", "SocialService", SOCIAL_SERVICE_SOURCE)
	createScript(sssRoot, "ModuleScript", "PlayerDataService", PLAYER_DATA_SOURCE)
	createScript(sssRoot, "ModuleScript", "QuestService", QUEST_SERVICE_SOURCE)
	createScript(sssRoot, "ModuleScript", "RewardService", REWARD_SERVICE_SOURCE)
	createScript(sssRoot, "ModuleScript", "CraftingService", CRAFTING_SERVICE_SOURCE)
	createScript(sssRoot, "ModuleScript", "PetService", PET_SERVICE_SOURCE)
	createScript(sssRoot, "ModuleScript", "BoostService", BOOST_SERVICE_SOURCE)
	createScript(sssRoot, "ModuleScript", "WorldService", WORLD_SERVICE_SOURCE)

	-- StarterGui: UI
	local guiRoot = ensureChild(starterGui, "ScreenGui", "GardenGui") :: ScreenGui
	guiRoot.ResetOnSpawn = false
	createScript(guiRoot, "LocalScript", "ClientMain", CLIENT_MAIN_SOURCE)

	-- Mark everything so it can be cleaned up on re-run
	markGenerated(worldRoot)
	markGenerated(rsRoot)
	markGenerated(sssRoot)
	markGenerated(guiRoot)
	markGenerated(plotsFolder)
	markGenerated(decorFolder)
end

-- Source code constants for generated scripts/modules.
-- Each block is defined below.

--// ===================== SOURCE CODE BLOCKS =====================

SETTINGS_SOURCE = [[
--!strict
-- Settings module for tuning gameplay balance and monetization.

local Settings = {}

--// Economy
Settings.StartingCoins = 250
Settings.SellMultiplier = 1
Settings.HarvestXp = 5
Settings.CraftXp = 10
Settings.QuestXp = 20
Settings.LevelXpBase = 100
Settings.LevelXpGrowth = 1.2

--// Growth and farming
Settings.PlotSize = Vector2.new(8, 8)
Settings.GrowthTickSeconds = 5
Settings.WaterBonus = 0.85 -- growth time multiplier when watered
Settings.FertilizerBonus = 0.75

--// Backpack
Settings.BaseBackpack = 24
Settings.BackpackUpgradeCost = 350
Settings.BackpackUpgradeAmount = 12

--// Upgrades
Settings.UpgradeCosts = {
	WateringCan = 150,
	FasterGrowth = 300,
	BiggerBackpack = 250,
	Fertilizer = 450,
	MarketHaggler = 600,
}

Settings.UpgradeEffects = {
	WateringCan = { waterBonus = 0.75 },
	FasterGrowth = { growthMultiplier = 0.8 },
	BiggerBackpack = { capacityBonus = 10 },
	Fertilizer = { fertilizerBonus = 0.7 },
	MarketHaggler = { sellBonus = 1.15 },
}

--// Cosmetics (non-pay-to-win)
Settings.CosmeticCatalog = {
	"WhiteFence",
	"GardenLamp",
	"FlowerPot",
	"Gazebo",
	"Fountain",
	"Topiary",
	"SeasonalArch",
}

--// Monetization hooks (soft, non-pay-to-win)
Settings.Monetization = {
	StarterBundleSeedBonus = 10,
	CosmeticThemeSkins = {
		"Sunrise",
		"Moonlight",
		"Autumn",
		"Bloom",
	},
}

--// Daily rewards
Settings.DailyRewards = {
	{ Coins = 100, Seeds = { Carrot = 3 } },
	{ Coins = 150, Seeds = { Tomato = 2 } },
	{ Coins = 200, Seeds = { Pumpkin = 1 } },
	{ Coins = 250, Seeds = { Strawberry = 2 } },
	{ Coins = 300, Seeds = { Sunflower = 2 } },
}

--// Quests
Settings.QuestPool = {
	{ Id = "Plant3", Type = "Plant", Target = 3, RewardCoins = 50 },
	{ Id = "Harvest5", Type = "Harvest", Target = 5, RewardCoins = 75 },
	{ Id = "Sell1", Type = "Sell", Target = 1, RewardCoins = 40 },
	{ Id = "Craft1", Type = "Craft", Target = 1, RewardCoins = 80 },
}

--// Boosts
Settings.Boosts = {
	Growth = { Duration = 900, Multiplier = 0.75 },
	Profit = { Duration = 900, Multiplier = 1.25 },
}

Settings.BoostCosts = {
	Growth = 120,
	Profit = 150,
}

--// Pets
Settings.PetBonuses = {
	Bunny = { HarvestXpBonus = 2 },
	Fox = { SellBonus = 1.1 },
	Deer = { GrowthBonus = 0.9 },
}

return Settings
]]

VALIDATION_SOURCE = [[
--!strict
-- Validation helpers for server-authoritative checks.

local Validation = {}

--- Validates a string against a whitelist.
function Validation.assertInList(value: string, list: {string}): boolean
	for _, item in ipairs(list) do
		if item == value then
			return true
		end
	end
	return false
end

--- Validates a numeric range.
function Validation.assertNumberInRange(value: number, minValue: number, maxValue: number): boolean
	return value >= minValue and value <= maxValue
end

--- Validates a positive integer.
function Validation.assertPositiveInteger(value: number): boolean
	return value > 0 and math.floor(value) == value
end

--- Validates a non-empty string.
function Validation.assertNonEmptyString(value: string): boolean
	return value ~= nil and value ~= ""
end

--- Validates a table contains expected keys.
function Validation.assertTableHasKeys(data: table, keys: {string}): boolean
	for _, key in ipairs(keys) do
		if data[key] == nil then
			return false
		end
	end
	return true
end

--- Clamps a number into a range.
function Validation.clampNumber(value: number, minValue: number, maxValue: number): number
	return math.max(minValue, math.min(maxValue, value))
end

return Validation
]]

CATALOG_SOURCE = [[
--!strict
-- Seed and crop catalog definitions.

local Catalog = {}

Catalog.Seeds = {
	Carrot = {
		Cost = 5,
		GrowTime = 60,
		SellPrice = 12,
	},
	Tomato = {
		Cost = 8,
		GrowTime = 90,
		SellPrice = 20,
	},
	Pumpkin = {
		Cost = 15,
		GrowTime = 120,
		SellPrice = 35,
	},
	Strawberry = {
		Cost = 18,
		GrowTime = 110,
		SellPrice = 40,
	},
	Sunflower = {
		Cost = 22,
		GrowTime = 150,
		SellPrice = 55,
	},
	Orchid = {
		Cost = 30,
		GrowTime = 210,
		SellPrice = 80,
	},
}

Catalog.Recipes = {
	GardenStew = {
		Inputs = { Carrot = 2, Tomato = 1 },
		SellPrice = 60,
	},
	SummerBouquet = {
		Inputs = { Sunflower = 2, Strawberry = 1 },
		SellPrice = 90,
	},
}

Catalog.Pets = {
	Bunny = { Cost = 250 },
	Fox = { Cost = 400 },
	Deer = { Cost = 550 },
}

return Catalog
]]

PLAYER_DATA_SOURCE = [[
--!strict
-- Player data service for persistent state.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local Settings = require(game:GetService("ReplicatedStorage"):WaitForChild("GardenGame"):WaitForChild("Modules"):WaitForChild("Settings"))

local PlayerDataService = {}

local dataStore = DataStoreService:GetDataStore("GardenGameData")
local sessionData: {[number]: any} = {}

--- Emits structured log payloads.
local function log(level: string, message: string, context: table?)
	warn({
		level = level,
		message = message,
		context = context or {},
	})
end

--- Returns default data for new players.
local function defaultData(): table
	return {
		Coins = Settings.StartingCoins,
		Seeds = { Carrot = 5, Tomato = 0, Pumpkin = 0, Strawberry = 0, Sunflower = 0, Orchid = 0 },
		Inventory = {},
		Upgrades = {},
		Cosmetics = {},
		Plot = {},
		Level = 1,
		Xp = 0,
		Daily = { LastClaim = 0, Streak = 0 },
		Quests = {},
		Pets = {},
		EquippedPet = nil,
		Boosts = {},
		Stats = {
			Plant = 0,
			Harvest = 0,
			Sell = 0,
			Craft = 0,
		},
	}
end

--- Loads player data from DataStore.
function PlayerDataService.load(player: Player): table
	local success, result = pcall(function()
		return dataStore:GetAsync(player.UserId)
	end)
	if success and result then
		sessionData[player.UserId] = result
		return result
	end
	if not success then
		log("error", "Failed to load player data", { player = player.UserId })
	end
	local data = defaultData()
	sessionData[player.UserId] = data
	return data
end

--- Saves player data to DataStore.
function PlayerDataService.save(player: Player)
	local data = sessionData[player.UserId]
	if not data then
		return
	end
	local success = pcall(function()
		dataStore:SetAsync(player.UserId, data)
	end)
	if not success then
		log("error", "Failed to save player data", { player = player.UserId })
	end
end

--- Returns mutable session data for a player.
function PlayerDataService.get(player: Player): table
	return sessionData[player.UserId]
end

--- Clears session data on player removal.
function PlayerDataService.clear(player: Player)
	sessionData[player.UserId] = nil
end

Players.PlayerRemoving:Connect(PlayerDataService.save)

return PlayerDataService
]]

PLOT_SERVICE_SOURCE = [[
--!strict
-- Plot service: assigns and manages plot slots for players.

local Players = game:GetService("Players")

local Settings = require(game:GetService("ReplicatedStorage"):WaitForChild("GardenGame"):WaitForChild("Modules"):WaitForChild("Settings"))

local PlotService = {}
local plotAssignments: {[number]: Vector3} = {}

--- Returns a spawn position for a player's plot.
local function calculatePlotPosition(index: number): Vector3
	local spacing = 48
	local row = math.floor((index - 1) / 4)
	local col = (index - 1) % 4
	return Vector3.new(col * spacing - 72, 1, row * spacing + 48)
end

--- Assigns a plot position for a player.
function PlotService.assignPlot(player: Player): Vector3
	if plotAssignments[player.UserId] then
		return plotAssignments[player.UserId]
	end
	local index = #plotAssignments + 1
	local position = calculatePlotPosition(index)
	plotAssignments[player.UserId] = position
	return position
end

--- Gets a plot position for a player.
function PlotService.getPlot(player: Player): Vector3
	return plotAssignments[player.UserId]
end

Players.PlayerRemoving:Connect(function(player)
	plotAssignments[player.UserId] = nil
end)

return PlotService
]]

ECONOMY_SERVICE_SOURCE = [[
--!strict
-- Economy service: handles coins and inventory.

local Settings = require(game:GetService("ReplicatedStorage"):WaitForChild("GardenGame"):WaitForChild("Modules"):WaitForChild("Settings"))

local EconomyService = {}

--- Adds coins to the player data.
function EconomyService.addCoins(data: table, amount: number)
	data.Coins += amount
end

--- Adds XP and returns true when player leveled up.
function EconomyService.addXp(data: table, amount: number): boolean
	data.Xp = (data.Xp or 0) + amount
	local leveledUp = false
	while data.Xp >= EconomyService.getXpForNextLevel(data.Level) do
		data.Xp -= EconomyService.getXpForNextLevel(data.Level)
		data.Level += 1
		leveledUp = true
	end
	return leveledUp
end

--- Returns XP needed for next level.
function EconomyService.getXpForNextLevel(level: number): number
	return math.floor(Settings.LevelXpBase * (Settings.LevelXpGrowth ^ (level - 1)))
end

--- Removes coins from the player data.
function EconomyService.spendCoins(data: table, amount: number): boolean
	if data.Coins < amount then
		return false
	end
	data.Coins -= amount
	return true
end

--- Calculates backpack capacity for a player.
function EconomyService.getBackpackCapacity(data: table): number
	local capacity = Settings.BaseBackpack
	if data.Upgrades.BiggerBackpack then
		capacity += Settings.BackpackUpgradeAmount
	end
	return capacity
end

--- Calculates sell multiplier with upgrades, pets, and boosts.
function EconomyService.getSellMultiplier(data: table): number
	local multiplier = Settings.SellMultiplier
	if data.Upgrades.MarketHaggler then
		multiplier *= Settings.UpgradeEffects.MarketHaggler.sellBonus
	end
	local petBonus = Settings.PetBonuses[data.EquippedPet or ""]
	if petBonus and petBonus.SellBonus then
		multiplier *= petBonus.SellBonus
	end
	local boost = data.Boosts and data.Boosts.Profit
	if boost and boost.ExpiresAt and os.time() < boost.ExpiresAt then
		multiplier *= Settings.Boosts.Profit.Multiplier
	end
	return multiplier
end

return EconomyService
]]

GROWTH_SERVICE_SOURCE = [[
--!strict
-- Growth service: simulates crop growth.

local Settings = require(game:GetService("ReplicatedStorage"):WaitForChild("GardenGame"):WaitForChild("Modules"):WaitForChild("Settings"))

local GrowthService = {}

--- Calculates remaining grow time for a plant.
function GrowthService.getRemaining(plant: table, currentTime: number): number
	return math.max(0, plant.ReadyAt - currentTime)
end

--- Returns a grow time multiplier from upgrades and boosts.
function GrowthService.getGrowthMultiplier(data: table, watered: boolean, fertilized: boolean): number
	local multiplier = 1
	if watered then
		multiplier *= Settings.WaterBonus
	end
	if fertilized then
		multiplier *= Settings.FertilizerBonus
		if data.Upgrades.Fertilizer then
			multiplier *= Settings.UpgradeEffects.Fertilizer.fertilizerBonus
		end
	end
	if data.Upgrades.FasterGrowth then
		multiplier *= Settings.UpgradeEffects.FasterGrowth.growthMultiplier
	end
	local boost = data.Boosts and data.Boosts.Growth
	if boost and boost.ExpiresAt and os.time() < boost.ExpiresAt then
		multiplier *= Settings.Boosts.Growth.Multiplier
	end
	return multiplier
end

--- Creates a plant record.
function GrowthService.createPlant(seedId: string, growTime: number, data: table, watered: boolean, fertilized: boolean, now: number): table
	local multiplier = GrowthService.getGrowthMultiplier(data, watered, fertilized)
	return {
		SeedId = seedId,
		PlantedAt = now,
		ReadyAt = now + math.floor(growTime * multiplier),
		Watered = watered,
		Fertilized = fertilized,
	}
end

return GrowthService
]]

SOCIAL_SERVICE_SOURCE = [[
--!strict
-- Social service: gifting and visiting helpers.

local SocialService = {}

--- Adds a gifted seed to the receiver data.
function SocialService.giftSeed(data: table, seedId: string)
	data.Seeds[seedId] = (data.Seeds[seedId] or 0) + 1
end

return SocialService
]]

QUEST_SERVICE_SOURCE = [[
--!strict
-- Quest service: daily quest generation and progress.

local Settings = require(game:GetService("ReplicatedStorage"):WaitForChild("GardenGame"):WaitForChild("Modules"):WaitForChild("Settings"))

local QuestService = {}

--- Ensures daily quests exist for a player.
function QuestService.ensureDailyQuests(data: table, now: number)
	data.Quests = data.Quests or {}
	local daily = data.Quests.Daily
	local today = os.date("!*t", now).yday
	if daily and daily.Day == today then
		return
	end
	local questPool = Settings.QuestPool
	local firstQuest = questPool[1]
	local secondQuest = questPool[2]
	data.Quests.Daily = {
		Day = today,
		Items = {
			{ Id = firstQuest.Id, Type = firstQuest.Type, Target = firstQuest.Target, Progress = 0, RewardCoins = firstQuest.RewardCoins },
			{ Id = secondQuest.Id, Type = secondQuest.Type, Target = secondQuest.Target, Progress = 0, RewardCoins = secondQuest.RewardCoins },
		},
		Claimed = {},
	}
end

--- Updates quest progress for a stat type.
function QuestService.progressQuest(data: table, questType: string, amount: number)
	if not data.Quests or not data.Quests.Daily then
		return
	end
	for _, quest in ipairs(data.Quests.Daily.Items) do
		if quest.Type == questType then
			quest.Progress = math.min(quest.Target, quest.Progress + amount)
		end
	end
end

--- Claims a quest reward if complete.
function QuestService.claimQuest(data: table, questId: string): number
	if not data.Quests or not data.Quests.Daily then
		return 0
	end
	if data.Quests.Daily.Claimed[questId] then
		return 0
	end
	for _, quest in ipairs(data.Quests.Daily.Items) do
		if quest.Id == questId and quest.Progress >= quest.Target then
			data.Quests.Daily.Claimed[questId] = true
			return quest.RewardCoins
		end
	end
	return 0
end

return QuestService
]]

REWARD_SERVICE_SOURCE = [[
--!strict
-- Reward service: daily rewards and starter bundles.

local Settings = require(game:GetService("ReplicatedStorage"):WaitForChild("GardenGame"):WaitForChild("Modules"):WaitForChild("Settings"))

local RewardService = {}

--- Returns true if daily reward can be claimed.
function RewardService.canClaimDaily(data: table, now: number): boolean
	local lastClaim = data.Daily and data.Daily.LastClaim or 0
	local lastDay = os.date("!*t", lastClaim).yday
	local today = os.date("!*t", now).yday
	return lastDay ~= today
end

--- Applies daily reward and returns reward data.
function RewardService.claimDaily(data: table, now: number): table
	local rewardIndex = (data.Daily.Streak % #Settings.DailyRewards) + 1
	local reward = Settings.DailyRewards[rewardIndex]
	data.Daily.LastClaim = now
	data.Daily.Streak += 1
	data.Coins += reward.Coins
	for seedId, amount in pairs(reward.Seeds) do
		data.Seeds[seedId] = (data.Seeds[seedId] or 0) + amount
	end
	return reward
end

return RewardService
]]

CRAFTING_SERVICE_SOURCE = [[
--!strict
-- Crafting service: turns harvested crops into crafted goods.

local Catalog = require(game:GetService("ReplicatedStorage"):WaitForChild("GardenGame"):WaitForChild("Modules"):WaitForChild("Catalog"))

local CraftingService = {}

--- Counts items in inventory list.
local function countInventory(inventory: {string}): {[string]: number}
	local counts: {[string]: number} = {}
	for _, item in ipairs(inventory) do
		counts[item] = (counts[item] or 0) + 1
	end
	return counts
end

--- Removes items from inventory.
local function removeInventory(inventory: {string}, required: {[string]: number})
	local remaining: {string} = {}
	local counts = table.clone(required)
	for _, item in ipairs(inventory) do
		local needed = counts[item]
		if needed and needed > 0 then
			counts[item] -= 1
		else
			table.insert(remaining, item)
		end
	end
	table.clear(inventory)
	for _, item in ipairs(remaining) do
		table.insert(inventory, item)
	end
end

--- Crafts a recipe if inputs exist.
function CraftingService.craft(data: table, recipeId: string): boolean
	local recipe = Catalog.Recipes[recipeId]
	if not recipe then
		return false
	end
	local counts = countInventory(data.Inventory)
	for seedId, amount in pairs(recipe.Inputs) do
		if (counts[seedId] or 0) < amount then
			return false
		end
	end
	removeInventory(data.Inventory, recipe.Inputs)
	table.insert(data.Inventory, recipeId)
	return true
end

return CraftingService
]]

PET_SERVICE_SOURCE = [[
--!strict
-- Pet service: manages pet ownership and equips.

local Catalog = require(game:GetService("ReplicatedStorage"):WaitForChild("GardenGame"):WaitForChild("Modules"):WaitForChild("Catalog"))

local PetService = {}

--- Returns true if pet can be purchased.
function PetService.canPurchase(data: table, petId: string): boolean
	return Catalog.Pets[petId] ~= nil and not data.Pets[petId]
end

--- Adds a pet to player data.
function PetService.grantPet(data: table, petId: string)
	data.Pets[petId] = true
	data.EquippedPet = petId
end

--- Equips a pet if owned.
function PetService.equipPet(data: table, petId: string): boolean
	if not data.Pets[petId] then
		return false
	end
	data.EquippedPet = petId
	return true
end

return PetService
]]

BOOST_SERVICE_SOURCE = [[
--!strict
-- Boost service: timed boost logic.

local Settings = require(game:GetService("ReplicatedStorage"):WaitForChild("GardenGame"):WaitForChild("Modules"):WaitForChild("Settings"))

local BoostService = {}

--- Starts a boost and returns expiry timestamp.
function BoostService.activateBoost(data: table, boostId: string, now: number): number?
	local boost = Settings.Boosts[boostId]
	if not boost then
		return nil
	end
	data.Boosts = data.Boosts or {}
	data.Boosts[boostId] = { ExpiresAt = now + boost.Duration }
	return data.Boosts[boostId].ExpiresAt
end

return BoostService
]]

WORLD_SERVICE_SOURCE = [[
--!strict
-- World service: helper utilities for map logic.

local WorldService = {}

--- Returns a default spawn position for the player hub.
function WorldService.getHubSpawn(): Vector3
	return Vector3.new(0, 5, -12)
end

return WorldService
]]

SERVER_MAIN_SOURCE = [[
--!strict
-- Main server script: authoritative logic for farming game.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local rsRoot = ReplicatedStorage:WaitForChild("GardenGame")
local remotes = rsRoot:WaitForChild("Remotes")
local modules = rsRoot:WaitForChild("Modules")

local Settings = require(modules:WaitForChild("Settings"))
local Validation = require(modules:WaitForChild("Validation"))
local Catalog = require(modules:WaitForChild("Catalog"))

local PlotService = require(script.Parent:WaitForChild("PlotService"))
local EconomyService = require(script.Parent:WaitForChild("EconomyService"))
local GrowthService = require(script.Parent:WaitForChild("GrowthService"))
local SocialService = require(script.Parent:WaitForChild("SocialService"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local QuestService = require(script.Parent:WaitForChild("QuestService"))
local RewardService = require(script.Parent:WaitForChild("RewardService"))
local CraftingService = require(script.Parent:WaitForChild("CraftingService"))
local PetService = require(script.Parent:WaitForChild("PetService"))
local BoostService = require(script.Parent:WaitForChild("BoostService"))
local WorldService = require(script.Parent:WaitForChild("WorldService"))

local function log(level: string, message: string, context: table?)
	local payload = {
		level = level,
		message = message,
		context = context or {},
	}
	warn(payload)
end

--- Sends a snapshot of player data to client.
local function getSnapshot(player: Player): table
	local data = PlayerDataService.get(player)
	return {
		Coins = data.Coins,
		Seeds = data.Seeds,
		Inventory = data.Inventory,
		Upgrades = data.Upgrades,
		Plot = data.Plot,
		Level = data.Level,
		Xp = data.Xp,
		Daily = data.Daily,
		Quests = data.Quests,
		Pets = data.Pets,
		EquippedPet = data.EquippedPet,
		Boosts = data.Boosts,
	}
end

local function ensurePlotRecord(data: table)
	data.Plot = data.Plot or {}
end

--- Ensures player data has required tracking tables.
local function ensureTracking(data: table, now: number)
	data.Seeds = data.Seeds or {}
	data.Inventory = data.Inventory or {}
	data.Upgrades = data.Upgrades or {}
	data.Cosmetics = data.Cosmetics or {}
	data.Boosts = data.Boosts or {}
	data.Pets = data.Pets or {}
	data.Stats = data.Stats or { Plant = 0, Harvest = 0, Sell = 0, Craft = 0 }
	data.Daily = data.Daily or { LastClaim = 0, Streak = 0 }
	data.Level = data.Level or 1
	data.Xp = data.Xp or 0
	QuestService.ensureDailyQuests(data, now)
end

--- Records stat progress and forwards it to quests.
local function recordStat(data: table, statKey: string, amount: number)
	data.Stats[statKey] = (data.Stats[statKey] or 0) + amount
	QuestService.progressQuest(data, statKey, amount)
end

Players.PlayerAdded:Connect(function(player)
	local data = PlayerDataService.load(player)
	ensurePlotRecord(data)
	ensureTracking(data, os.time())
	PlotService.assignPlot(player)
	player.RespawnLocation = nil
	player.CharacterAdded:Connect(function(character)
		local root = character:WaitForChild("HumanoidRootPart", 5)
		if root then
			root.CFrame = CFrame.new(WorldService.getHubSpawn())
		end
	end)
end)

-- Remote handlers

remotes.RequestPlotSnapshot.OnServerInvoke = function(player)
	local data = PlayerDataService.get(player)
	if data then
		ensureTracking(data, os.time())
	end
	return getSnapshot(player)
end

remotes.RequestPlant.OnServerEvent:Connect(function(player, seedId: string, gridX: number, gridY: number, watered: boolean, fertilized: boolean)
	local data = PlayerDataService.get(player)
	if not data then
		log("error", "Missing player data", { player = player.UserId })
		return
	end
	ensureTracking(data, os.time())
	if not Catalog.Seeds[seedId] then
		log("warn", "Invalid seed request", { player = player.UserId, seed = seedId })
		return
	end
	if not Validation.assertNumberInRange(gridX, 1, Settings.PlotSize.X) or not Validation.assertNumberInRange(gridY, 1, Settings.PlotSize.Y) then
		log("warn", "Invalid plot coordinates", { player = player.UserId, x = gridX, y = gridY })
		return
	end
	if data.Seeds[seedId] == nil or data.Seeds[seedId] <= 0 then
		log("warn", "Insufficient seeds", { player = player.UserId, seed = seedId })
		return
	end
	if fertilized and not data.Upgrades.Fertilizer then
		log("warn", "Fertilizer not unlocked", { player = player.UserId })
		return
	end

	ensurePlotRecord(data)
	local key = gridX .. ":" .. gridY
	if data.Plot[key] then
		log("warn", "Plot already occupied", { player = player.UserId, key = key })
		return
	end

	data.Seeds[seedId] -= 1
	local seed = Catalog.Seeds[seedId]
	local plant = GrowthService.createPlant(seedId, seed.GrowTime, data, watered, fertilized, os.time())
	data.Plot[key] = plant
	recordStat(data, "Plant", 1)
end)

remotes.RequestHarvest.OnServerEvent:Connect(function(player, gridX: number, gridY: number)
	local data = PlayerDataService.get(player)
	if not data then
		log("error", "Missing player data", { player = player.UserId })
		return
	end
	ensureTracking(data, os.time())

	local key = gridX .. ":" .. gridY
	local plant = data.Plot[key]
	if not plant then
		log("warn", "No plant to harvest", { player = player.UserId, key = key })
		return
	end

	if os.time() < plant.ReadyAt then
		log("warn", "Plant not ready", { player = player.UserId, key = key })
		return
	end

	local capacity = EconomyService.getBackpackCapacity(data)
	if #data.Inventory >= capacity then
		log("warn", "Backpack full", { player = player.UserId })
		return
	end

	table.insert(data.Inventory, plant.SeedId)
	data.Plot[key] = nil
	recordStat(data, "Harvest", 1)
	local xpBonus = 0
	local petBonus = Settings.PetBonuses[data.EquippedPet or ""]
	if petBonus then
		xpBonus = petBonus.HarvestXpBonus or 0
	end
	EconomyService.addXp(data, Settings.HarvestXp + xpBonus)
end)

remotes.RequestSell.OnServerEvent:Connect(function(player)
	local data = PlayerDataService.get(player)
	if not data then
		log("error", "Missing player data", { player = player.UserId })
		return
	end
	ensureTracking(data, os.time())

	local total = 0
	for _, seedId in ipairs(data.Inventory) do
		local seed = Catalog.Seeds[seedId]
		if seed then
			total += seed.SellPrice
		else
			local recipe = Catalog.Recipes[seedId]
			if recipe then
				total += recipe.SellPrice
			end
		end
	end
	data.Inventory = {}
	local multiplier = EconomyService.getSellMultiplier(data)
	EconomyService.addCoins(data, math.floor(total * multiplier))
	if total > 0 then
		recordStat(data, "Sell", 1)
		EconomyService.addXp(data, Settings.QuestXp)
	end
end)

remotes.RequestUpgrade.OnServerEvent:Connect(function(player, upgradeId: string)
	local data = PlayerDataService.get(player)
	if not data then
		log("error", "Missing player data", { player = player.UserId })
		return
	end
	ensureTracking(data, os.time())
	local cost = Settings.UpgradeCosts[upgradeId]
	if not cost then
		log("warn", "Invalid upgrade", { player = player.UserId, upgrade = upgradeId })
		return
	end
	if data.Upgrades[upgradeId] then
		log("warn", "Upgrade already owned", { player = player.UserId, upgrade = upgradeId })
		return
	end
	if not EconomyService.spendCoins(data, cost) then
		log("warn", "Not enough coins", { player = player.UserId, upgrade = upgradeId })
		return
	end
	data.Upgrades[upgradeId] = true
end)

remotes.RequestDecorate.OnServerEvent:Connect(function(player, cosmeticId: string)
	local data = PlayerDataService.get(player)
	if not data then
		log("error", "Missing player data", { player = player.UserId })
		return
	end
	ensureTracking(data, os.time())
	if not Validation.assertInList(cosmeticId, Settings.CosmeticCatalog) then
		log("warn", "Invalid cosmetic", { player = player.UserId, cosmetic = cosmeticId })
		return
	end
	data.Cosmetics[cosmeticId] = true
end)

remotes.RequestGiftSeed.OnServerEvent:Connect(function(player, targetUserId: number, seedId: string)
	local data = PlayerDataService.get(player)
	if not data then
		log("error", "Missing player data", { player = player.UserId })
		return
	end
	ensureTracking(data, os.time())
	if not Catalog.Seeds[seedId] then
		log("warn", "Invalid seed gift", { player = player.UserId, seed = seedId })
		return
	end
	if data.Seeds[seedId] == nil or data.Seeds[seedId] <= 0 then
		log("warn", "No seed to gift", { player = player.UserId, seed = seedId })
		return
	end
	local targetPlayer = Players:GetPlayerByUserId(targetUserId)
	if not targetPlayer then
		log("warn", "Target not online", { player = player.UserId, target = targetUserId })
		return
	end
	local targetData = PlayerDataService.get(targetPlayer)
	if not targetData then
		log("error", "Target data missing", { player = targetUserId })
		return
	end
	data.Seeds[seedId] -= 1
	SocialService.giftSeed(targetData, seedId)
end)

remotes.RequestClaimDaily.OnServerEvent:Connect(function(player)
	local data = PlayerDataService.get(player)
	if not data then
		log("error", "Missing player data", { player = player.UserId })
		return
	end
	ensureTracking(data, os.time())
	if not RewardService.canClaimDaily(data, os.time()) then
		log("warn", "Daily already claimed", { player = player.UserId })
		return
	end
	RewardService.claimDaily(data, os.time())
end)

remotes.RequestQuestStart.OnServerEvent:Connect(function(player)
	local data = PlayerDataService.get(player)
	if not data then
		log("error", "Missing player data", { player = player.UserId })
		return
	end
	QuestService.ensureDailyQuests(data, os.time())
end)

remotes.RequestQuestClaim.OnServerEvent:Connect(function(player, questId: string)
	local data = PlayerDataService.get(player)
	if not data then
		log("error", "Missing player data", { player = player.UserId })
		return
	end
	ensureTracking(data, os.time())
	if not Validation.assertNonEmptyString(questId) then
		log("warn", "Invalid quest id", { player = player.UserId })
		return
	end
	local rewardCoins = QuestService.claimQuest(data, questId)
	if rewardCoins <= 0 then
		log("warn", "Quest not complete", { player = player.UserId, quest = questId })
		return
	end
	EconomyService.addCoins(data, rewardCoins)
	EconomyService.addXp(data, Settings.QuestXp)
end)

remotes.RequestCraft.OnServerEvent:Connect(function(player, recipeId: string)
	local data = PlayerDataService.get(player)
	if not data then
		log("error", "Missing player data", { player = player.UserId })
		return
	end
	ensureTracking(data, os.time())
	if not Validation.assertNonEmptyString(recipeId) then
		log("warn", "Invalid recipe", { player = player.UserId })
		return
	end
	if not CraftingService.craft(data, recipeId) then
		log("warn", "Craft failed", { player = player.UserId, recipe = recipeId })
		return
	end
	recordStat(data, "Craft", 1)
	EconomyService.addXp(data, Settings.CraftXp)
end)

remotes.RequestEquipPet.OnServerEvent:Connect(function(player, petId: string)
	local data = PlayerDataService.get(player)
	if not data then
		log("error", "Missing player data", { player = player.UserId })
		return
	end
	ensureTracking(data, os.time())
	if not Validation.assertNonEmptyString(petId) then
		log("warn", "Invalid pet", { player = player.UserId })
		return
	end
	if data.Pets[petId] then
		PetService.equipPet(data, petId)
		return
	end
	local pet = Catalog.Pets[petId]
	if not pet then
		log("warn", "Unknown pet", { player = player.UserId, pet = petId })
		return
	end
	if not EconomyService.spendCoins(data, pet.Cost) then
		log("warn", "Not enough coins for pet", { player = player.UserId, pet = petId })
		return
	end
	PetService.grantPet(data, petId)
end)

remotes.RequestBoost.OnServerEvent:Connect(function(player, boostId: string)
	local data = PlayerDataService.get(player)
	if not data then
		log("error", "Missing player data", { player = player.UserId })
		return
	end
	ensureTracking(data, os.time())
	if not Validation.assertNonEmptyString(boostId) then
		log("warn", "Invalid boost", { player = player.UserId })
		return
	end
	local cost = Settings.BoostCosts[boostId]
	if not cost then
		log("warn", "Unknown boost", { player = player.UserId, boost = boostId })
		return
	end
	if not EconomyService.spendCoins(data, cost) then
		log("warn", "Not enough coins for boost", { player = player.UserId, boost = boostId })
		return
	end
	BoostService.activateBoost(data, boostId, os.time())
end)
]]

CLIENT_MAIN_SOURCE = [[
--!strict
-- Client UI and local interactions.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("GardenGame"):WaitForChild("Remotes")

local screenGui = script.Parent :: ScreenGui

--- Creates a themed button.
local function createButton(text: string, size: UDim2, position: UDim2, color: Color3, parent: Instance): TextButton
	local button = Instance.new("TextButton")
	button.Size = size
	button.Position = position
	button.Text = text
	button.BackgroundColor3 = color
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.GothamSemibold
	button.TextSize = 14
	button.Parent = parent
	return button
end

-- UI layout
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 320)
frame.Position = UDim2.new(0, 24, 1, -350)
frame.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 32)
title.Position = UDim2.new(0, 12, 0, 8)
title.Text = "Garden Legends"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local statsLabel = Instance.new("TextLabel")
statsLabel.Position = UDim2.new(0, 12, 0, 40)
statsLabel.Size = UDim2.new(1, -24, 0, 24)
statsLabel.TextColor3 = Color3.fromRGB(255, 214, 91)
statsLabel.BackgroundTransparency = 1
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextSize = 14
statsLabel.Parent = frame

local actionPanel = Instance.new("Frame")
actionPanel.Size = UDim2.new(0, 190, 0, 220)
actionPanel.Position = UDim2.new(0, 12, 0, 70)
actionPanel.BackgroundTransparency = 1
actionPanel.Parent = frame

local questPanel = Instance.new("Frame")
questPanel.Size = UDim2.new(0, 200, 0, 220)
questPanel.Position = UDim2.new(0, 210, 0, 70)
questPanel.BackgroundTransparency = 1
questPanel.Parent = frame

local plantCarrot = createButton("Plant Carrot", UDim2.new(0, 180, 0, 32), UDim2.new(0, 0, 0, 0), Color3.fromRGB(74, 140, 100), actionPanel)
local plantBerry = createButton("Plant Strawberry", UDim2.new(0, 180, 0, 32), UDim2.new(0, 0, 0, 40), Color3.fromRGB(170, 76, 100), actionPanel)
local harvestButton = createButton("Harvest (1,1)", UDim2.new(0, 180, 0, 32), UDim2.new(0, 0, 0, 80), Color3.fromRGB(140, 98, 74), actionPanel)
local sellButton = createButton("Sell Backpack", UDim2.new(0, 180, 0, 32), UDim2.new(0, 0, 0, 120), Color3.fromRGB(140, 90, 130), actionPanel)
local dailyButton = createButton("Claim Daily", UDim2.new(0, 180, 0, 32), UDim2.new(0, 0, 0, 160), Color3.fromRGB(72, 130, 180), actionPanel)
local boostButton = createButton("Boost Growth", UDim2.new(0, 180, 0, 32), UDim2.new(0, 0, 0, 200), Color3.fromRGB(90, 140, 200), actionPanel)

local questTitle = Instance.new("TextLabel")
questTitle.Size = UDim2.new(1, 0, 0, 24)
questTitle.Text = "Daily Quests"
questTitle.TextColor3 = Color3.fromRGB(226, 230, 255)
questTitle.BackgroundTransparency = 1
questTitle.Font = Enum.Font.GothamBold
questTitle.TextSize = 14
questTitle.TextXAlignment = Enum.TextXAlignment.Left
questTitle.Parent = questPanel

local questLines: {TextLabel} = {}
local questButtons: {TextButton} = {}

for index = 1, 2 do
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -60, 0, 30)
	label.Position = UDim2.new(0, 0, 0, 24 + (index - 1) * 44)
	label.TextColor3 = Color3.fromRGB(210, 210, 210)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = questPanel
	table.insert(questLines, label)

	local claimButton = createButton("Claim", UDim2.new(0, 54, 0, 24), UDim2.new(1, -54, 0, 26 + (index - 1) * 44), Color3.fromRGB(86, 170, 120), questPanel)
	claimButton.TextSize = 12
	table.insert(questButtons, claimButton)
end

local petButton = createButton("Adopt Bunny", UDim2.new(0, 180, 0, 32), UDim2.new(0, 0, 0, 120), Color3.fromRGB(110, 120, 180), questPanel)
local craftButton = createButton("Craft Garden Stew", UDim2.new(0, 180, 0, 32), UDim2.new(0, 0, 0, 160), Color3.fromRGB(180, 120, 90), questPanel)
local profitBoostButton = createButton("Boost Profit", UDim2.new(0, 180, 0, 32), UDim2.new(0, 0, 0, 200), Color3.fromRGB(140, 110, 200), questPanel)

--- Updates quest labels and claim buttons.
local function updateQuestUi(snapshot: table)
	for index, label in ipairs(questLines) do
		local quest = snapshot.Quests and snapshot.Quests.Daily and snapshot.Quests.Daily.Items[index]
		if quest then
			label.Text = string.format("%s %d/%d", quest.Id, quest.Progress, quest.Target)
			questButtons[index].Visible = quest.Progress >= quest.Target
			questButtons[index].AutoButtonColor = quest.Progress >= quest.Target
		else
			label.Text = "Quest slot empty"
			questButtons[index].Visible = false
		end
	end
end

--- Refreshes UI from server snapshot.
local function refresh()
	local snapshot = remotes.RequestPlotSnapshot:InvokeServer()
	statsLabel.Text = string.format("Lvl %d | XP %d | Coins %d", snapshot.Level, snapshot.Xp, snapshot.Coins)
	updateQuestUi(snapshot)
end

plantCarrot.Activated:Connect(function()
	remotes.RequestPlant:FireServer("Carrot", 1, 1, true, false)
	refresh()
end)

plantBerry.Activated:Connect(function()
	remotes.RequestPlant:FireServer("Strawberry", 1, 2, true, false)
	refresh()
end)

harvestButton.Activated:Connect(function()
	remotes.RequestHarvest:FireServer(1, 1)
	refresh()
end)

sellButton.Activated:Connect(function()
	remotes.RequestSell:FireServer()
	refresh()
end)

dailyButton.Activated:Connect(function()
	remotes.RequestClaimDaily:FireServer()
	refresh()
end)

boostButton.Activated:Connect(function()
	remotes.RequestBoost:FireServer("Growth")
	refresh()
end)

profitBoostButton.Activated:Connect(function()
	remotes.RequestBoost:FireServer("Profit")
	refresh()
end)

petButton.Activated:Connect(function()
	remotes.RequestEquipPet:FireServer("Bunny")
	refresh()
end)

craftButton.Activated:Connect(function()
	remotes.RequestCraft:FireServer("GardenStew")
	refresh()
end)

for index, button in ipairs(questButtons) do
	button.Activated:Connect(function()
		local snapshot = remotes.RequestPlotSnapshot:InvokeServer()
		local quest = snapshot.Quests and snapshot.Quests.Daily and snapshot.Quests.Daily.Items[index]
		if quest then
			remotes.RequestQuestClaim:FireServer(quest.Id)
			refresh()
		end
	end)
end

refresh()
]]

button.Click:Connect(function()
	buildGame()
end)
```

---

## README (Short)

### Save as Local Plugin
1. In Roblox Studio, create a new **Plugin** and insert the above `GardenGameGeneratorPlugin` model structure.
2. Paste the `PluginMain` script source into the Script.
3. Right-click the plugin in Explorer → **Save as Local Plugin**.

### Where to place the `.rbxmx`
- Put the `.rbxmx` file in your local **Plugins** folder:
  - **Windows:** `%LocalAppData%\Roblox\Plugins`
  - **macOS:** `~/Library/Application Support/Roblox/Plugins`

### How to run it
1. Open your place in Roblox Studio.
2. Click the **Garden Legends** toolbar.
3. Click **Generate Game** to create/update the full game content.

> Re-run any time to update. The plugin removes and recreates content it tagged with `GG_CREATED`.
