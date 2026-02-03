# Garden Game Generator Plugin (.rbxmx) Specification

This document describes the **single .rbxmx plugin model** (Instances + hierarchy) and the **full Luau source** for each Script/ModuleScript/LocalScript in that model. The plugin generates a cozy farming / garden simulator in the open place when the toolbar button is clicked.

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
-- Garden Game Generator Plugin
-- Creates/updates a complete cozy farming game with a single toolbar click.

local toolbar = plugin:CreateToolbar("Garden Game")
local button = toolbar:CreateButton(
	"Generate Game",
	"Generate or update the Cozy Garden game in the open place",
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

	cleanGenerated(workspace)
	cleanGenerated(replicatedStorage)
	cleanGenerated(serverScriptService)
	cleanGenerated(starterGui)

	-- Workspace map
	local worldRoot = ensureChild(workspace, "Folder", ROOT_NAME)
	local plotsFolder = ensureChild(worldRoot, "Folder", "Plots")
	local decorFolder = ensureChild(worldRoot, "Folder", "Decorations")

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
Settings.StartingCoins = 100
Settings.SellMultiplier = 1
Settings.HarvestXp = 2

--// Growth and farming
Settings.PlotSize = Vector2.new(8, 8)
Settings.GrowthTickSeconds = 5
Settings.WaterBonus = 0.85 -- growth time multiplier when watered

--// Backpack
Settings.BaseBackpack = 20
Settings.BackpackUpgradeCost = 250
Settings.BackpackUpgradeAmount = 10

--// Upgrades
Settings.UpgradeCosts = {
	WateringCan = 150,
	FasterGrowth = 300,
	BiggerBackpack = 250,
}

Settings.UpgradeEffects = {
	WateringCan = { waterBonus = 0.75 },
	FasterGrowth = { growthMultiplier = 0.8 },
	BiggerBackpack = { capacityBonus = 10 },
}

--// Cosmetics (non-pay-to-win)
Settings.CosmeticCatalog = {
	"WhiteFence",
	"GardenLamp",
	"FlowerPot",
	"Gazebo",
}

--// Monetization hooks (soft, non-pay-to-win)
Settings.Monetization = {
	StarterBundleSeedBonus = 10,
	CosmeticThemeSkins = {
		"Sunrise",
		"Moonlight",
		"Autumn",
	},
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

--- Returns default data for new players.
local function defaultData(): table
	return {
		Coins = Settings.StartingCoins,
		Seeds = { Carrot = 5, Tomato = 0, Pumpkin = 0 },
		Inventory = {},
		Upgrades = {},
		Cosmetics = {},
		Plot = {},
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
	pcall(function()
		dataStore:SetAsync(player.UserId, data)
	end)
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

--- Creates a plant record.
function GrowthService.createPlant(seedId: string, growTime: number, watered: boolean, now: number): table
	local multiplier = 1
	if watered then
		multiplier = Settings.WaterBonus
	end
	return {
		SeedId = seedId,
		PlantedAt = now,
		ReadyAt = now + math.floor(growTime * multiplier),
		Watered = watered,
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
	}
end

local function ensurePlotRecord(data: table)
	data.Plot = data.Plot or {}
end

Players.PlayerAdded:Connect(function(player)
	local data = PlayerDataService.load(player)
	ensurePlotRecord(data)
	PlotService.assignPlot(player)
end)

-- Remote handlers

remotes.RequestPlotSnapshot.OnServerInvoke = function(player)
	return getSnapshot(player)
end

remotes.RequestPlant.OnServerEvent:Connect(function(player, seedId: string, gridX: number, gridY: number, watered: boolean)
	local data = PlayerDataService.get(player)
	if not data then
		log("error", "Missing player data", { player = player.UserId })
		return
	end
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

	ensurePlotRecord(data)
	local key = gridX .. ":" .. gridY
	if data.Plot[key] then
		log("warn", "Plot already occupied", { player = player.UserId, key = key })
		return
	end

	data.Seeds[seedId] -= 1
	local seed = Catalog.Seeds[seedId]
	local plant = GrowthService.createPlant(seedId, seed.GrowTime, watered, os.time())
	data.Plot[key] = plant
end)

remotes.RequestHarvest.OnServerEvent:Connect(function(player, gridX: number, gridY: number)
	local data = PlayerDataService.get(player)
	if not data then
		log("error", "Missing player data", { player = player.UserId })
		return
	end

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
end)

remotes.RequestSell.OnServerEvent:Connect(function(player)
	local data = PlayerDataService.get(player)
	if not data then
		log("error", "Missing player data", { player = player.UserId })
		return
	end

	local total = 0
	for _, seedId in ipairs(data.Inventory) do
		local seed = Catalog.Seeds[seedId]
		if seed then
			total += seed.SellPrice
		end
	end
	data.Inventory = {}
	EconomyService.addCoins(data, total)
end)

remotes.RequestUpgrade.OnServerEvent:Connect(function(player, upgradeId: string)
	local data = PlayerDataService.get(player)
	if not data then
		log("error", "Missing player data", { player = player.UserId })
		return
	end
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
]]

CLIENT_MAIN_SOURCE = [[
--!strict
-- Client UI and local interactions.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("GardenGame"):WaitForChild("Remotes")

local screenGui = script.Parent :: ScreenGui

-- UI setup
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 220)
frame.Position = UDim2.new(0, 20, 1, -240)
frame.BackgroundColor3 = Color3.fromRGB(34, 42, 52)
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32)
title.Text = "Cozy Garden"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

local coinLabel = Instance.new("TextLabel")
coinLabel.Position = UDim2.new(0, 12, 0, 40)
coinLabel.Size = UDim2.new(1, -24, 0, 24)
coinLabel.TextColor3 = Color3.fromRGB(255, 214, 91)
coinLabel.BackgroundTransparency = 1
coinLabel.TextXAlignment = Enum.TextXAlignment.Left
coinLabel.Font = Enum.Font.Gotham
coinLabel.TextSize = 14
coinLabel.Parent = frame

local plantButton = Instance.new("TextButton")
plantButton.Position = UDim2.new(0, 12, 0, 80)
plantButton.Size = UDim2.new(0, 140, 0, 32)
plantButton.Text = "Plant Carrot"
plantButton.BackgroundColor3 = Color3.fromRGB(74, 140, 100)
plantButton.TextColor3 = Color3.fromRGB(255, 255, 255)
plantButton.Font = Enum.Font.GothamSemibold
plantButton.TextSize = 14
plantButton.Parent = frame

local harvestButton = Instance.new("TextButton")
harvestButton.Position = UDim2.new(0, 168, 0, 80)
harvestButton.Size = UDim2.new(0, 140, 0, 32)
harvestButton.Text = "Harvest (1,1)"
harvestButton.BackgroundColor3 = Color3.fromRGB(140, 98, 74)
harvestButton.TextColor3 = Color3.fromRGB(255, 255, 255)
harvestButton.Font = Enum.Font.GothamSemibold
harvestButton.TextSize = 14
harvestButton.Parent = frame

local sellButton = Instance.new("TextButton")
sellButton.Position = UDim2.new(0, 12, 0, 124)
sellButton.Size = UDim2.new(0, 140, 0, 32)
sellButton.Text = "Sell Backpack"
sellButton.BackgroundColor3 = Color3.fromRGB(140, 90, 130)
sellButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sellButton.Font = Enum.Font.GothamSemibold
sellButton.TextSize = 14
sellButton.Parent = frame

local upgradeButton = Instance.new("TextButton")
upgradeButton.Position = UDim2.new(0, 168, 0, 124)
upgradeButton.Size = UDim2.new(0, 140, 0, 32)
upgradeButton.Text = "Upgrade: Watering"
upgradeButton.BackgroundColor3 = Color3.fromRGB(70, 120, 165)
upgradeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
upgradeButton.Font = Enum.Font.GothamSemibold
upgradeButton.TextSize = 14
upgradeButton.Parent = frame

local giftBox = Instance.new("TextBox")
giftBox.Position = UDim2.new(0, 12, 0, 168)
giftBox.Size = UDim2.new(0, 140, 0, 28)
giftBox.PlaceholderText = "Friend UserId"
giftBox.Text = ""
giftBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
giftBox.TextColor3 = Color3.fromRGB(50, 50, 50)
giftBox.Font = Enum.Font.Gotham
giftBox.TextSize = 12
giftBox.Parent = frame

local giftButton = Instance.new("TextButton")
giftButton.Position = UDim2.new(0, 168, 0, 168)
giftButton.Size = UDim2.new(0, 140, 0, 32)
giftButton.Text = "Gift Seed"
giftButton.BackgroundColor3 = Color3.fromRGB(75, 110, 85)
giftButton.TextColor3 = Color3.fromRGB(255, 255, 255)
giftButton.Font = Enum.Font.GothamSemibold
giftButton.TextSize = 14
giftButton.Parent = frame

local function refresh()
	local snapshot = remotes.RequestPlotSnapshot:InvokeServer()
	coinLabel.Text = "Coins: " .. tostring(snapshot.Coins)
end

plantButton.Activated:Connect(function()
	remotes.RequestPlant:FireServer("Carrot", 1, 1, true)
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

upgradeButton.Activated:Connect(function()
	remotes.RequestUpgrade:FireServer("WateringCan")
	refresh()
end)

giftButton.Activated:Connect(function()
	local targetUserId = tonumber(giftBox.Text)
	if targetUserId then
		remotes.RequestGiftSeed:FireServer(targetUserId, "Carrot")
	end
end)

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
2. Click the **Garden Game** toolbar.
3. Click **Generate Game** to create/update the full game content.

> Re-run any time to update. The plugin removes and recreates content it tagged with `GG_CREATED`.
