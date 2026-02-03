--!strict
-- Roblox Studio Command Bar Installer Script

local SETTINGS = {
	DataStoreName = "RLua_Obby_Data",
	Coin = {
		Value = 1,
		RespawnTime = 8,
	},
	Shop = {
		SpeedBoost = {
			Cost = 25,
			WalkSpeed = 24,
		},
	},
	Obby = {
		Platforms = 18,
		Spacing = 24,
		HeightStep = 6,
		Size = Vector3.new(18, 2, 18),
	},
}

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local INSTALL_TAG = "RLuaInstaller"

-- Utility: create and configure an instance.
local function createInstance(className: string, props: {[string]: any}?, parent: Instance?): Instance
	local instance = Instance.new(className)
	if props then
		for key, value in pairs(props) do
			(instance :: any)[key] = value
		end
	end
	if parent then
		instance.Parent = parent
	end
	return instance
end

-- Utility: mark an instance as belonging to this installer.
local function tagInstance(instance: Instance)
	CollectionService:AddTag(instance, INSTALL_TAG)
	instance:SetAttribute(INSTALL_TAG, true)
end

-- Utility: set Lua source for script-like instances.
local function setSource(scriptInstance: LuaSourceContainer, source: string)
	scriptInstance.Source = source
end

-- Utility: clean up previous installer content.
local function cleanupPreviousInstall()
	for _, instance in ipairs(CollectionService:GetTagged(INSTALL_TAG)) do
		if instance and instance.Parent then
			instance:Destroy()
		end
	end
end

cleanupPreviousInstall()

-- ReplicatedStorage structure
local modulesFolder = createInstance("Folder", {Name = "Modules"}, ReplicatedStorage)
local remotesFolder = createInstance("Folder", {Name = "Remotes"}, ReplicatedStorage)

for _, folder in ipairs({modulesFolder, remotesFolder}) do
	tagInstance(folder)
end

local purchaseFunction = createInstance("RemoteFunction", {Name = "PurchaseItem"}, remotesFolder)
local clientEvent = createInstance("RemoteEvent", {Name = "ClientEvent"}, remotesFolder)

for _, remote in ipairs({purchaseFunction, clientEvent}) do
	tagInstance(remote)
end

local configModule = createInstance("ModuleScript", {Name = "Config"}, modulesFolder)
local utilsModule = createInstance("ModuleScript", {Name = "Utils"}, modulesFolder)

for _, moduleScript in ipairs({configModule, utilsModule}) do
	tagInstance(moduleScript)
end

setSource(configModule, [[
--!strict

local Config = {
	DataStoreName = "]] .. SETTINGS.DataStoreName .. [[",
	Coin = {
		Value = ]] .. tostring(SETTINGS.Coin.Value) .. [[,
		RespawnTime = ]] .. tostring(SETTINGS.Coin.RespawnTime) .. [[,
	},
	Shop = {
		SpeedBoost = {
			Cost = ]] .. tostring(SETTINGS.Shop.SpeedBoost.Cost) .. [[,
			WalkSpeed = ]] .. tostring(SETTINGS.Shop.SpeedBoost.WalkSpeed) .. [[,
		},
	},
	Obby = {
		Platforms = ]] .. tostring(SETTINGS.Obby.Platforms) .. [[,
		Spacing = ]] .. tostring(SETTINGS.Obby.Spacing) .. [[,
		HeightStep = ]] .. tostring(SETTINGS.Obby.HeightStep) .. [[,
		Size = Vector3.new(]] .. SETTINGS.Obby.Size.X .. [[, ]] .. SETTINGS.Obby.Size.Y .. [[, ]] .. SETTINGS.Obby.Size.Z .. [[),
	},
}

return Config
]])

setSource(utilsModule, [[
--!strict

local Utils = {}

-- Utility: format numbers with commas.
function Utils.formatNumber(value: number): string
	local formatted = tostring(math.floor(value))
	while true do
		local result, count = formatted:gsub("^(%-?%d+)(%d%d%d)", "%1,%2")
		formatted = result
		if count == 0 then
			break
		end
	end
	return formatted
end

return Utils
]])

-- Workspace obby
local obbyFolder = createInstance("Folder", {Name = "RLuaObby"}, Workspace)
local checkpointsFolder = createInstance("Folder", {Name = "Checkpoints"}, obbyFolder)
local coinsFolder = createInstance("Folder", {Name = "Coins"}, obbyFolder)

for _, folder in ipairs({obbyFolder, checkpointsFolder, coinsFolder}) do
	tagInstance(folder)
end

local startSpawn = createInstance("SpawnLocation", {
	Name = "Start",
	Anchored = true,
	Size = Vector3.new(12, 1, 12),
	Position = Vector3.new(0, 5, 0),
	Neutral = true,
	CanCollide = true,
}, obbyFolder)

tagInstance(startSpawn)

local lastPosition = startSpawn.Position
for i = 1, SETTINGS.Obby.Platforms do
	local offset = Vector3.new(SETTINGS.Obby.Spacing, SETTINGS.Obby.HeightStep, 0)
	local platform = createInstance("Part", {
		Name = "Platform_" .. tostring(i),
		Anchored = true,
		Size = SETTINGS.Obby.Size,
		Position = lastPosition + offset,
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
		Material = Enum.Material.SmoothPlastic,
		Color = Color3.fromRGB(80, 170, 255),
	}, obbyFolder)
	tagInstance(platform)

	local checkpoint = createInstance("Part", {
		Name = "Checkpoint_" .. tostring(i),
		Anchored = true,
		Size = Vector3.new(10, 1, 10),
		Position = platform.Position + Vector3.new(0, 3, 0),
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
		Material = Enum.Material.Neon,
		Color = Color3.fromRGB(255, 215, 0),
	}, checkpointsFolder)
	checkpoint:SetAttribute("IsCheckpoint", true)
	tagInstance(checkpoint)

	local coin = createInstance("Part", {
		Name = "Coin_" .. tostring(i),
		Anchored = true,
		CanCollide = false,
		Size = Vector3.new(2, 2, 1),
		Position = platform.Position + Vector3.new(0, 6, 0),
		Shape = Enum.PartType.Cylinder,
		Material = Enum.Material.Neon,
		Color = Color3.fromRGB(255, 221, 64),
	}, coinsFolder)
	coin.Orientation = Vector3.new(0, 0, 90)
	coin:SetAttribute("IsCoin", true)
	coin:SetAttribute("CoinValue", SETTINGS.Coin.Value)
	coin:SetAttribute("RespawnTime", SETTINGS.Coin.RespawnTime)
	tagInstance(coin)

	lastPosition = platform.Position
end

-- StarterGui UI
local shopGui = createInstance("ScreenGui", {Name = "ShopGui", ResetOnSpawn = false}, StarterGui)
local mainFrame = createInstance("Frame", {
	Name = "MainFrame",
	Size = UDim2.new(0, 240, 0, 160),
	Position = UDim2.new(0, 20, 0, 200),
	BackgroundColor3 = Color3.fromRGB(20, 20, 30),
	BorderSizePixel = 0,
}, shopGui)
local titleLabel = createInstance("TextLabel", {
	Name = "Title",
	Size = UDim2.new(1, 0, 0, 30),
	BackgroundTransparency = 1,
	Text = "Speed Shop",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.GothamBold,
	TextSize = 18,
}, mainFrame)
local coinsLabel = createInstance("TextLabel", {
	Name = "Coins",
	Size = UDim2.new(1, 0, 0, 24),
	Position = UDim2.new(0, 0, 0, 34),
	BackgroundTransparency = 1,
	Text = "Coins: 0",
	TextColor3 = Color3.fromRGB(255, 221, 64),
	Font = Enum.Font.Gotham,
	TextSize = 16,
}, mainFrame)
local buyButton = createInstance("TextButton", {
	Name = "BuyButton",
	Size = UDim2.new(1, -20, 0, 46),
	Position = UDim2.new(0, 10, 0, 70),
	BackgroundColor3 = Color3.fromRGB(46, 200, 120),
	TextColor3 = Color3.fromRGB(0, 0, 0),
	Text = "Buy Speed Boost",
	Font = Enum.Font.GothamBold,
	TextSize = 16,
}, mainFrame)
local statusLabel = createInstance("TextLabel", {
	Name = "Status",
	Size = UDim2.new(1, -20, 0, 34),
	Position = UDim2.new(0, 10, 0, 120),
	BackgroundTransparency = 1,
	Text = "Reach checkpoints to save!",
	TextColor3 = Color3.fromRGB(200, 200, 200),
	Font = Enum.Font.Gotham,
	TextSize = 14,
}, mainFrame)

for _, gui in ipairs({shopGui, mainFrame, titleLabel, coinsLabel, buyButton, statusLabel}) do
	tagInstance(gui)
end

local shopLocalScript = createInstance("LocalScript", {Name = "ShopClient"}, shopGui)

tagInstance(shopLocalScript)

setSource(shopLocalScript, [[
--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local purchaseFunction = remotes:WaitForChild("PurchaseItem") :: RemoteFunction

local gui = script.Parent :: ScreenGui
local mainFrame = gui:WaitForChild("MainFrame") :: Frame
local coinsLabel = mainFrame:WaitForChild("Coins") :: TextLabel
local buyButton = mainFrame:WaitForChild("BuyButton") :: TextButton
local statusLabel = mainFrame:WaitForChild("Status") :: TextLabel

-- UI helper: update coin label based on leaderstats.
local function updateCoins()
	local stats = player:FindFirstChild("leaderstats")
	local coins = stats and stats:FindFirstChild("Coins")
	if coins and coins:IsA("IntValue") then
		coinsLabel.Text = "Coins: " .. tostring(coins.Value)
	end
end

-- UI helper: update button state if owned.
local function updateOwnership()
	local owns = player:GetAttribute("SpeedBoost")
	if owns then
		buyButton.Text = "Owned"
		buyButton.AutoButtonColor = false
		buyButton.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
	else
		buyButton.Text = "Buy Speed Boost"
		buyButton.AutoButtonColor = true
		buyButton.BackgroundColor3 = Color3.fromRGB(46, 200, 120)
	end
end

local function onPurchase()
	statusLabel.Text = "Processing..."
	local success, result = pcall(function()
		return purchaseFunction:InvokeServer("SpeedBoost")
	end)
	if not success then
		statusLabel.Text = "Purchase failed. Try again."
		return
	end
	if result and result.ok then
		statusLabel.Text = "Speed boost unlocked!"
	else
		statusLabel.Text = result and result.message or "Not enough coins."
	end
	updateCoins()
	updateOwnership()
end

buyButton.MouseButton1Click:Connect(onPurchase)

local function bindLeaderstats()
	local stats = player:WaitForChild("leaderstats", 10)
	if stats then
		local coins = stats:WaitForChild("Coins", 10)
		if coins then
			coins.Changed:Connect(updateCoins)
		end
	end
	updateCoins()
end

player.AttributeChanged:Connect(function(attribute)
	if attribute == "SpeedBoost" then
		updateOwnership()
	end
end)

bindLeaderstats()
updateOwnership()
]])

-- Server script
local serverScript = createInstance("Script", {Name = "GameServer"}, ServerScriptService)

tagInstance(serverScript)

setSource(serverScript, [[
--!strict

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local purchaseFunction = remotes:WaitForChild("PurchaseItem") :: RemoteFunction

local dataStore = DataStoreService:GetDataStore(Config.DataStoreName)

local function logError(code: string, details: {[string]: any})
	local payload = {code = code, details = details}
	local success, encoded = pcall(function()
		return HttpService:JSONEncode(payload)
	end)
	if success then
		warn("[RLua][Error] " .. encoded)
	else
		warn("[RLua][Error] " .. code)
	end
end

-- Utility: setup leaderstats with coins.
local function setupLeaderstats(player: Player, coins: number)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player

	local coinsValue = Instance.new("IntValue")
	coinsValue.Name = "Coins"
	coinsValue.Value = coins
	coinsValue.Parent = stats
end

-- Utility: apply upgrades to a player's character.
local function applyUpgrades(player: Player, character: Model?)
	local ownsSpeed = player:GetAttribute("SpeedBoost")
	if not ownsSpeed or not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = Config.Shop.SpeedBoost.WalkSpeed
	end
end

-- Utility: award coins with validation.
local function awardCoins(player: Player, amount: number)
	if amount <= 0 then
		logError("invalid_coin_award", {player = player.UserId, amount = amount})
		return
	end
	local stats = player:FindFirstChild("leaderstats")
	local coinsValue = stats and stats:FindFirstChild("Coins")
	if coinsValue and coinsValue:IsA("IntValue") then
		coinsValue.Value += amount
	end
end

-- Utility: load player data from DataStore.
local function loadPlayerData(player: Player)
	local success, result = pcall(function()
		return dataStore:GetAsync(tostring(player.UserId))
	end)
	if not success then
		logError("datastore_load_failed", {player = player.UserId})
		return {coins = 0, upgrades = {}} -- default
	end
	if type(result) ~= "table" then
		return {coins = 0, upgrades = {}} -- default
	end
	return result
end

-- Utility: save player data to DataStore.
local function savePlayerData(player: Player)
	local stats = player:FindFirstChild("leaderstats")
	local coinsValue = stats and stats:FindFirstChild("Coins")
	local data = {
		coins = coinsValue and coinsValue.Value or 0,
		upgrades = {
			speed = player:GetAttribute("SpeedBoost") == true,
		},
	}
	local success = pcall(function()
		dataStore:SetAsync(tostring(player.UserId), data)
	end)
	if not success then
		logError("datastore_save_failed", {player = player.UserId})
	end
end

-- Utility: process coin touch securely.
local function onCoinTouched(coin: BasePart, otherPart: BasePart)
	if coin:GetAttribute("Collected") then
		return
	end
	local character = otherPart.Parent
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end
	coin:SetAttribute("Collected", true)
	coin.Transparency = 1
	coin.CanCollide = false

	local value = tonumber(coin:GetAttribute("CoinValue")) or Config.Coin.Value
	awardCoins(player, value)

	local respawnTime = tonumber(coin:GetAttribute("RespawnTime")) or Config.Coin.RespawnTime
	task.delay(respawnTime, function()
		if coin and coin.Parent then
			coin.Transparency = 0
			coin.CanCollide = false
			coin:SetAttribute("Collected", false)
		end
	end)
end

-- Utility: process checkpoint touch.
local function onCheckpointTouched(checkpoint: BasePart, otherPart: BasePart)
	local character = otherPart.Parent
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end
	player.RespawnLocation = checkpoint
end

-- Utility: validate and handle purchase requests.
local function onPurchaseRequest(player: Player, itemId: string)
	if itemId ~= "SpeedBoost" then
		return {ok = false, message = "Invalid item."}
	end
	if player:GetAttribute("SpeedBoost") then
		return {ok = false, message = "Already owned."}
	end
	local stats = player:FindFirstChild("leaderstats")
	local coinsValue = stats and stats:FindFirstChild("Coins")
	if not coinsValue or not coinsValue:IsA("IntValue") then
		return {ok = false, message = "Coins unavailable."}
	end
	if coinsValue.Value < Config.Shop.SpeedBoost.Cost then
		return {ok = false, message = "Not enough coins."}
	end
	coinsValue.Value -= Config.Shop.SpeedBoost.Cost
	player:SetAttribute("SpeedBoost", true)
	applyUpgrades(player, player.Character)
	return {ok = true}
end

purchaseFunction.OnServerInvoke = onPurchaseRequest

local function connectCoins()
	for _, coin in ipairs(CollectionService:GetTagged("RLuaInstaller")) do
		if coin:IsA("BasePart") and coin:GetAttribute("IsCoin") then
			coin.Touched:Connect(function(otherPart)
				onCoinTouched(coin, otherPart)
			end)
		end
	end
end

local function connectCheckpoints()
	for _, checkpoint in ipairs(CollectionService:GetTagged("RLuaInstaller")) do
		if checkpoint:IsA("BasePart") and checkpoint:GetAttribute("IsCheckpoint") then
			checkpoint.Touched:Connect(function(otherPart)
				onCheckpointTouched(checkpoint, otherPart)
			end)
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	local data = loadPlayerData(player)
	setupLeaderstats(player, tonumber(data.coins) or 0)
	player:SetAttribute("SpeedBoost", data.upgrades and data.upgrades.speed == true)
	player.CharacterAdded:Connect(function(character)
		applyUpgrades(player, character)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	savePlayerData(player)
end)

connectCoins()
connectCheckpoints()
]])

print("RLua obby installer complete. Press Play to test.")
