--[[
    =======================================================
    SataNet Hub v2.0 - Bubble Gum Simulator
    100% Offline Standalone Lifetime Build (No Server Dependencies)
    - Custom Triangle Geometric Logo (Local Offline Standalone/assets/logo.png)
    - Left Sidebar Vertical Tabs Navigation
    - Custom Imgur / SataNet Background Image
    - Splash Loading Screen with "Satanet" Animation
    - "Show Hub" Top Capsule (Positioned at top edge)
    - Refined Minimalist 'x' and '-' Window Controls
    - Window Dragging Bounded to Screen (Cannot be dragged off-screen)
    - UNIVERSAL ULTRA-FAST AUTOCOLLECT (COLLECTS ALL PICKUPS Y >= 150)
    =======================================================
--]]

-- [0] Clean up all previous GUI instances & terminate previous hub state
_G.HubActive = false
task.wait(0.05)
_G.HubActive = true

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Safe Executor API Wrappers
local function safeGetHui()
    if typeof(gethui) == "function" then
        local ok, res = pcall(gethui)
        if ok and res then return res end
    end
    return nil
end

local function protectGui(gui)
    pcall(function()
        local hui = safeGetHui()
        if hui then
            gui.Parent = hui
            return
        end
        if syn and typeof(syn.protect_gui) == "function" then
            pcall(function() syn.protect_gui(gui) end)
            gui.Parent = CoreGui
            return
        end
        gui.Parent = CoreGui
    end)
    if not gui.Parent then
        pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
    end
end

pcall(function()
    local hui = safeGetHui()
    local targets = {CoreGui, hui, LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")}
    for _, parent in ipairs(targets) do
        if parent then
            for _, name in ipairs({"SataNet_MainGui", "SataNet_RayfieldPill", "SataNet_Splash", "Rayfield", "Fluent"}) do
                local old = parent:FindFirstChild(name)
                if old then pcall(function() old:Destroy() end) end
            end
        end
    end
end)


-- INTEGRATED ROBUST ANTI-AFK SYSTEM (PREVENTS 20-MIN IDLE KICK)
pcall(function()
    local vu = game:GetService("VirtualUser")
    if LocalPlayer then
        LocalPlayer.Idled:Connect(function()
            pcall(function()
                vu:CaptureController()
                vu:ClickButton2(Vector2.new(0, 0))
            end)
            print("[SataNet Anti-AFK] Prevented idle kick via Idled signal!")
        end)
    end
end)

task.spawn(function()
    while _G.HubActive do
        task.wait(480) -- Periodic VirtualUser pulse every 8 minutes
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new(0, 0))
        end)
    end
end)

-- OVERRIDE BGS CLIENT EGG QUEUE & ANIMATION SPEEDS TO ZERO
pcall(function()
    local eggService = require(game.ReplicatedStorage.Assets.Modules.EggService)
    if eggService then
        eggService.GetHatchCooldown = function() return 0 end
        eggService.GetHatchDuration = function() return 0 end
        eggService.GetHatchAnimationSpeed = function() return 9999 end
    end
end)

-- Global Hub State (CRASH-PROOF SAFETY: AutoCollect always starts FALSE)
_G.AutoBlow = false
_G.AutoSell = false
_G.SellCooldown = 3
_G.SelectedSellMode = "🌟 Авто локация (Автоматический выбор лучшего 2x - 25x)"
_G.ReturnToFarmPos = false
_G.ReturnToCollectPos = false
_G.AutoHatch = false
_G.SelectedEgg = nil
_G.HatchAmount = 1
_G.PetWebhookEnabled = false
_G.PetWebhookUrl = ""
_G.WebhookRarityFilter = "All Pets"
_G.InfJump = false
_G.SpeedrunUnlocking = false
_G.AutoCollect = false -- ALWAYS FALSE ON SCRIPT LOAD
_G.AutoCollectRewards = false
_G.CollectCoins = true
_G.CollectGems = true
_G.CollectXP = true
_G.CollectDelay = 0.01 -- ULTRA-FAST 10MS
_G.AutoBuyUpgrades = false
_G.UpgradeGum = true
_G.UpgradeFlavors = true
_G.UpgradeFaces = true
_G.AutoEquipBest = false
_G.AutoEquipGum = true
_G.AutoEquipFlavors = true
_G.AutoEquipFaces = true
_G.AutoBuyWorlds = false
_G.GuiScale = 1

_G.IsCollectingNow = false
_G.IsSellingNow = false
_G.IsTeleporting = false

-- HARDCODED ULTRA-FAST SERVER HATCH INTERVAL (0.60s)
_G.LastHatchTime = 0
_G.HatchCooldown = 0.60

-- Per-world collection filter map (DEFAULT ALL FALSE)
_G.CollectWorlds = {
    Overworld = false,
    ["Event World"] = false,
    ["Candy Land"] = false,
    ["Beach World"] = false,
    Atlantis = false,
    ["Mystic Forest"] = false,
    Underworld = false,
    Heaven = false,
    ["Rainbow Land"] = false,
    ["Toy Land"] = false
}

-- CONFIG MANAGEMENT ENGINE
local CONFIG_FILE_NAME = "SataNet_BGS_Config.json"

local function getSerializedConfig()
    local cfg = {
        AutoBlow = _G.AutoBlow,
        AutoSell = _G.AutoSell,
        SellCooldown = _G.SellCooldown,
        SelectedSellMode = _G.SelectedSellMode,
        ReturnToFarmPos = _G.ReturnToFarmPos,
        ReturnToCollectPos = _G.ReturnToCollectPos,
        AutoCollect = _G.AutoCollect,
        CollectCoins = _G.CollectCoins,
        CollectGems = _G.CollectGems,
        CollectXP = _G.CollectXP,
        CollectDelay = _G.CollectDelay,
        CollectWorlds = _G.CollectWorlds,
        AutoCollectRewards = _G.AutoCollectRewards,
        AutoBuyUpgrades = _G.AutoBuyUpgrades,
        UpgradeGum = _G.UpgradeGum,
        UpgradeFlavors = _G.UpgradeFlavors,
        UpgradeFaces = _G.UpgradeFaces,
        AutoEquipBest = _G.AutoEquipBest,
        AutoEquipGum = _G.AutoEquipGum,
        AutoEquipFlavors = _G.AutoEquipFlavors,
        AutoEquipFaces = _G.AutoEquipFaces,
        AutoHatch = _G.AutoHatch,
        SelectedEgg = _G.SelectedEgg,
        HatchAmount = _G.HatchAmount,
        PetWebhookEnabled = _G.PetWebhookEnabled,
        PetWebhookUrl = _G.PetWebhookUrl,
        WebhookRarityFilter = _G.WebhookRarityFilter,
        InfJump = _G.InfJump,
        AutoBuyWorlds = _G.AutoBuyWorlds,
        GuiScale = _G.GuiScale
    }
    return HttpService:JSONEncode(cfg)
end

local function applySerializedConfig(jsonStr)
    local s, cfg = pcall(function() return HttpService:JSONDecode(jsonStr) end)
    if not s or type(cfg) ~= "table" then return false end

    if cfg.AutoBlow ~= nil then _G.AutoBlow = cfg.AutoBlow end
    if cfg.AutoSell ~= nil then _G.AutoSell = cfg.AutoSell end
    if cfg.SellCooldown ~= nil then _G.SellCooldown = cfg.SellCooldown end
    if cfg.SelectedSellMode ~= nil then _G.SelectedSellMode = cfg.SelectedSellMode end
    if cfg.ReturnToFarmPos ~= nil then _G.ReturnToFarmPos = cfg.ReturnToFarmPos end
    if cfg.ReturnToCollectPos ~= nil then _G.ReturnToCollectPos = cfg.ReturnToCollectPos end
    if cfg.AutoCollect ~= nil then _G.AutoCollect = cfg.AutoCollect end
    if cfg.CollectCoins ~= nil then _G.CollectCoins = cfg.CollectCoins end
    if cfg.CollectGems ~= nil then _G.CollectGems = cfg.CollectGems end
    if cfg.CollectXP ~= nil then _G.CollectXP = cfg.CollectXP end
    if cfg.CollectDelay ~= nil then _G.CollectDelay = cfg.CollectDelay end
    if cfg.CollectWorlds ~= nil and type(cfg.CollectWorlds) == "table" then _G.CollectWorlds = cfg.CollectWorlds end
    if cfg.AutoCollectRewards ~= nil then _G.AutoCollectRewards = cfg.AutoCollectRewards end
    if cfg.AutoBuyUpgrades ~= nil then _G.AutoBuyUpgrades = cfg.AutoBuyUpgrades end
    if cfg.UpgradeGum ~= nil then _G.UpgradeGum = cfg.UpgradeGum end
    if cfg.UpgradeFlavors ~= nil then _G.UpgradeFlavors = cfg.UpgradeFlavors end
    if cfg.UpgradeFaces ~= nil then _G.UpgradeFaces = cfg.UpgradeFaces end
    if cfg.AutoEquipBest ~= nil then _G.AutoEquipBest = cfg.AutoEquipBest end
    if cfg.AutoEquipGum ~= nil then _G.AutoEquipGum = cfg.AutoEquipGum end
    if cfg.AutoEquipFlavors ~= nil then _G.AutoEquipFlavors = cfg.AutoEquipFlavors end
    if cfg.AutoEquipFaces ~= nil then _G.AutoEquipFaces = cfg.AutoEquipFaces end
    if cfg.AutoHatch ~= nil then _G.AutoHatch = cfg.AutoHatch end
    if cfg.SelectedEgg ~= nil then _G.SelectedEgg = cfg.SelectedEgg end
    if cfg.HatchAmount ~= nil then _G.HatchAmount = cfg.HatchAmount end
    if cfg.PetWebhookEnabled ~= nil then _G.PetWebhookEnabled = cfg.PetWebhookEnabled end
    if cfg.PetWebhookUrl ~= nil then _G.PetWebhookUrl = cfg.PetWebhookUrl end
    if cfg.WebhookRarityFilter ~= nil then _G.WebhookRarityFilter = cfg.WebhookRarityFilter end
    if cfg.InfJump ~= nil then _G.InfJump = cfg.InfJump end
    if cfg.AutoBuyWorlds ~= nil then _G.AutoBuyWorlds = cfg.AutoBuyWorlds end
    if cfg.GuiScale ~= nil then _G.GuiScale = cfg.GuiScale end

    return true
end

local function saveConfigToFile()
    if typeof(writefile) == "function" then
        local json = getSerializedConfig()
        local ok, err = pcall(function() writefile(CONFIG_FILE_NAME, json) end)
        return ok
    end
    return false
end

local function loadConfigFromFile()
    if typeof(readfile) == "function" and typeof(isfile) == "function" then
        if isfile(CONFIG_FILE_NAME) then
            local ok, json = pcall(function() return readfile(CONFIG_FILE_NAME) end)
            if ok and json and #json > 2 then
                return applySerializedConfig(json)
            end
        end
    end
    return false
end

-- AUTO-LOAD SAVED CONFIG ON SCRIPT INITIALIZATION
loadConfigFromFile()

-- OFFICIAL WORLDS TABLE IN ASCENDING PRICE ORDER
local OFFICIAL_WORLDS = {
    {name = "Candy Land", priceCoins = 2500000, label = "🍭 Candy Land (2.500.000 Монет)"},
    {name = "Atlantis", priceCoins = 20000000, label = "🔱 Atlantis (20.000.000 Монет)"},
    {name = "Toy Land", priceCoins = 50000000, label = "🧸 Toy Land (50.000.000 Монет)"},
    {name = "Beach World", priceCoins = 150000000, label = "🏖 Beach World (150.000.000 Монет)"},
    {name = "Rainbow Land", priceCoins = 1500000000, label = "🌈 Rainbow Land (1.500.000.000 Монет)"},
    {name = "Underworld", priceCoins = 2000000000, label = "🔥 Underworld (2.000.000.000 Монет)"},
    {name = "Mystic Forest", priceCoins = 4000000000, label = "🌲 Mystic Forest (4.000.000.000 Монет)"},
    {name = "Heaven", priceCoins = 10000000000, label = "☁ Heaven World (10.000.000.000 Монет)"}
}

-- Global Execution Connections
local HubConnections = {}
local function trackConnection(conn)
    table.insert(HubConnections, conn)
    return conn
end

-- Helper: Safe Teleport with Dynamic Floor Raycasting
local function safeTeleport(cframeOrPos)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local targetPos = typeof(cframeOrPos) == "CFrame" and cframeOrPos.Position or cframeOrPos
    
    local ray = Ray.new(Vector3.new(targetPos.X, targetPos.Y + 80, targetPos.Z), Vector3.new(0, -200, 0))
    local hitPart, hitPos = workspace:FindPartOnRayWithIgnoreList(ray, {char})
    
    local finalY = targetPos.Y
    if hitPart and hitPos then
        finalY = hitPos.Y + 5.8
    else
        finalY = targetPos.Y + 6.2
    end

    hrp.CFrame = CFrame.new(targetPos.X, finalY, targetPos.Z)
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
end

local function safeTouch(hrpPart, targetPart)
    if not hrpPart or not targetPart then return end
    if typeof(firetouchinterest) == "function" then
        pcall(function()
            firetouchinterest(hrpPart, targetPart, 0)
            task.wait(0.02)
            firetouchinterest(hrpPart, targetPart, 1)
        end)
    end
end

-- Helper: Ensure safety platform directly under portal circle or island
local function ensurePortalPlatform(name, pos)
    local pName = "SataNet_PortalPlatform_" .. tostring(name)
    local platform = workspace:FindFirstChild(pName)
    local offsetY = (name == "OverworldSpawn") and 12 or 2.5
    local transparencyVal = (name == "OverworldSpawn") and 1 or 0.5

    if not platform then
        platform = Instance.new("Part")
        platform.Name = pName
        platform.Size = Vector3.new(40, 1, 40)
        platform.CFrame = CFrame.new(pos.X, pos.Y - offsetY, pos.Z)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Material = Enum.Material.SmoothPlastic
        platform.Color = Color3.fromRGB(70, 150, 255)
        platform.Transparency = transparencyVal
        platform.Parent = workspace
    else
        platform.CFrame = CFrame.new(pos.X, pos.Y - offsetY, pos.Z)
        platform.Transparency = transparencyVal
    end
    return platform
end

-- PORTAL ENTRANCE POSITIONS IN OVERWORLD
local PORTAL_ENTRANCE_POSITIONS = {
    ["EventPortal"] = Vector3.new(-8.7, 43.6, -283.1),
    ["Candy Land"] = Vector3.new(10.2, 42.6, -450.4),
    ["Toy Land"] = Vector3.new(-21.2, 42.7, -492.1),
    ["Beach World"] = Vector3.new(-15.1, 42.7, -537.4),
    ["Atlantis"] = Vector3.new(10.8, 42.7, -576.8),
    ["Mystic Forest"] = Vector3.new(140.4, 42.7, -501.2),
    ["Underworld"] = Vector3.new(120.5, 42.7, -555.0),
    ["Heaven"] = Vector3.new(124.1, 42.9, -448.1),
    ["Rainbow Land"] = Vector3.new(63.2, 42.7, -584.8)
}

-- EXACT OVERWORLD SPAWN POSITION
local OVERWORLD_SPAWN_POS = Vector3.new(-92.98, 48.00, -159.76)

-- HELPER: CHECK IF PLAYER IS CURRENTLY IN SPECIFIC WORLD DIMENSION
local function isPlayerInWorld(worldName)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local pos = hrp.Position

    if worldName == "Overworld" then
        return (pos.Z >= -1500 and pos.Z <= 500 and pos.X >= -1000 and pos.X <= 1000)
    elseif worldName == "Event World" then
        return (pos.Y >= 400 and pos.Y <= 700 and pos.X >= 2000 and pos.X <= 3000)
    elseif worldName == "Candy Land" then
        return (pos.Z >= -4000 and pos.Z <= -1800)
    elseif worldName == "Toy Land" then
        return (pos.Z >= -6800 and pos.Z <= -4200)
    elseif worldName == "Beach World" then
        return (pos.Z >= -10000 and pos.Z <= -7000)
    elseif worldName == "Atlantis" then
        return (pos.Z >= -14200 and pos.Z <= -11000)
    elseif worldName == "Rainbow Land" then
        return (pos.Z >= -18500 and pos.Z <= -16500)
    elseif worldName == "Mystic Forest" then
        return (pos.Z >= -16500 and pos.Z <= -14500 and pos.X >= 3500)
    elseif worldName == "Heaven" then
        return (pos.Z >= -15000 and pos.Z <= -12500 and pos.X >= 6500)
    elseif worldName == "Underworld" then
        return (pos.Z >= -22000 and pos.Z <= -19000)
    end
    return false
end

-- EXACT IN-WORLD RETURN CIRCLE STEPPING INTERNAL
local function teleportToOverworldUniversalInternal()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local hrpPos = hrp.Position
    -- Check if player is currently in Overworld
    local isInOverworld = (hrpPos.Z >= -1500 and hrpPos.Z <= 500 and hrpPos.X >= -500 and hrpPos.X <= 500 and hrpPos.Y <= 200)

    if isInOverworld then
        -- Lower invisible safety platform beneath spawn ground
        ensurePortalPlatform("OverworldSpawn", OVERWORLD_SPAWN_POS)
        hrp.CFrame = CFrame.new(OVERWORLD_SPAWN_POS.X, OVERWORLD_SPAWN_POS.Y, OVERWORLD_SPAWN_POS.Z)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        return
    end

    -- If in another world, find closest ReturnHome circle in that world to exit back to Overworld!
    local closestRoot = nil
    local minDistance = 999999

    local acts = workspace:FindFirstChild("Activations")
    if acts then
        for _, c in ipairs(acts:GetChildren()) do
            local name = c.Name
            if name == "ReturnHome" or name == "EventLeave" or name == "ReturnHomeFromShard" or name:find("Return") or name:find("Leave") then
                local p = c:FindFirstChild("Root") or c:FindFirstChild("Tag") or c:FindFirstChildWhichIsA("BasePart")
                if p then
                    local dist = (p.Position - hrpPos).Magnitude
                    if dist < minDistance then
                        minDistance = dist
                        closestRoot = p
                    end
                end
            end
        end
    end

    if not closestRoot then
        for _, desc in ipairs(workspace:GetChildren()) do
            local dName = desc.Name
            if dName:find("Return") or dName:find("Leave") or dName == "Activations" then
                for _, sub in ipairs(desc:GetDescendants()) do
                    if sub.Name == "ReturnHome" or sub.Name == "EventLeave" or sub.Name == "ReturnHomeFromShard" then
                        local p = sub:FindFirstChild("Root") or sub:FindFirstChild("Tag") or sub:FindFirstChildWhichIsA("BasePart")
                        if p then
                            local dist = (p.Position - hrpPos).Magnitude
                            if dist < minDistance then
                                minDistance = dist
                                closestRoot = p
                            end
                        end
                    end
                end
            end
        end
    end

    if closestRoot and minDistance < 5000 then
        ensurePortalPlatform("ReturnHome", closestRoot.Position)
        hrp.CFrame = CFrame.new(closestRoot.Position.X, closestRoot.Position.Y + 3.0, closestRoot.Position.Z)
        hrp.AssemblyLinearVelocity = Vector3.new(0, -10, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        task.wait(0.15)
        safeTouch(hrp, closestRoot)
        return
    end

    local netFunc = game:GetService("ReplicatedStorage"):FindFirstChild("NetworkRemoteFunction")
    if netFunc then
        pcall(function()
            netFunc:InvokeServer("Teleport", "OverworldSpawn")
        end)
        task.wait(0.3)
    end

    ensurePortalPlatform("OverworldSpawn", OVERWORLD_SPAWN_POS)
    hrp.CFrame = CFrame.new(OVERWORLD_SPAWN_POS.X, OVERWORLD_SPAWN_POS.Y, OVERWORLD_SPAWN_POS.Z)
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
end

-- UNIVERSAL PUBLIC OVERWORLD TELEPORT WITH SCRIPT FREEZING
local function teleportToOverworldUniversal()
    if _G.IsTeleporting then return end
    _G.IsTeleporting = true

    pcall(teleportToOverworldUniversalInternal)

    task.wait(0.5)
    _G.IsTeleporting = false
end

-- SMART WORLD-TO-WORLD TELEPORT ENGINE WITH FREEZING
local function teleportToPortalCircle(portalName)
    if _G.IsTeleporting then return end
    _G.IsTeleporting = true

    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local hrpPos = hrp.Position
        -- Check if player is currently in another world (far from Overworld entrance area)
        local isFarFromOverworld = (hrpPos.Z < -1500) or (hrpPos.Y > 200) or (hrpPos.X > 500) or (hrpPos.X < -500)

        -- If in another world, STEP 1: Return to Overworld via current world's ReturnHome circle!
        if isFarFromOverworld then
            teleportToOverworldUniversalInternal()
            task.wait(0.4)
        end

        -- Re-fetch character and acts in Overworld
        char = LocalPlayer.Character
        hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local acts = workspace:FindFirstChild("Activations")
        local model = acts and acts:FindFirstChild(portalName)
        local rootPart = model and (model:FindFirstChild("Root") or model:FindFirstChild("Tag") or model:FindFirstChildWhichIsA("BasePart"))

        local targetPos = rootPart and rootPart.Position or PORTAL_ENTRANCE_POSITIONS[portalName]

        if targetPos then
            -- STEP 2: Place calibrated platform at pos.Y - 2.5
            ensurePortalPlatform(portalName, targetPos)

            -- STEP 3: Step directly onto the entrance portal circle
            hrp.CFrame = CFrame.new(targetPos.X, targetPos.Y + 3.0, targetPos.Z)
            hrp.AssemblyLinearVelocity = Vector3.new(0, -10, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            task.wait(0.15)
            if rootPart then safeTouch(hrp, rootPart) end
        end
    end)

    task.wait(0.5)
    _G.IsTeleporting = false
end

-- Helper: Exact check if player's bubble is 100% full
local function isBubble100PercentFull()
    local s, full = pcall(function()
        local capService = require(game.ReplicatedStorage.Assets.Modules.CapacityService)
        return capService:IsBubbleFull(LocalPlayer)
    end)
    if s and full ~= nil then
        return full == true
    end

    local gui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
    if gui then
        local bf = gui:FindFirstChild("BubbleFull")
        if bf and bf.Visible then return true end

        local sf = gui:FindFirstChild("StatsFrame")
        if sf then
            for _, d in ipairs(sf:GetDescendants()) do
                if d:IsA("TextLabel") and d.Text:find("/") then
                    local curStr, maxStr = d.Text:match("([%d%,]+)%s*/%s*([%d%,]+)")
                    if curStr and maxStr then
                        local c = tonumber((curStr:gsub(",", "")))
                        local m = tonumber((maxStr:gsub(",", "")))
                        if c and m and m > 0 then
                            return c >= m
                        end
                    end
                end
            end
        end
    end
    return false
end

-- BGS Item Module Loader
local function getBGSItemModules()
    local s, res = pcall(function()
        local itemDS = game:GetService("ReplicatedStorage").Assets.Modules.ItemDataService
        return {
            ShopModule = require(itemDS.ShopModule),
            GumModule = require(itemDS.GumModule),
            FlavorModule = require(itemDS.FlavorModule),
            FaceModule = require(itemDS.FaceModule),
            PetModule = require(itemDS.PetModule),
            EggModule = require(itemDS.EggModule)
        }
    end)
    if s and res then return res end
    return nil
end

-- Helper to check all unlocked worlds
local unlockedWorldsCache = {}
local unlockedWorldsCacheTime = 0

local function getUnlockedWorlds()
    local now = tick()
    if (now - unlockedWorldsCacheTime) < 3 then return unlockedWorldsCache end
    unlockedWorldsCacheTime = now

    local result = {Overworld = true, ["The Twilight"] = true, ["Event World"] = true}

    pcall(function()
        local netFunc = game:GetService("ReplicatedStorage"):FindFirstChild("NetworkRemoteFunction")
        if netFunc then
            local pData = netFunc:InvokeServer("GetPlayerData")
            if type(pData) == "table" then
                if pData[11] or pData["11"] then
                    for _, w in ipairs(pData[11] or pData["11"]) do result[w] = true end
                end
                if pData[37] or pData["37"] then
                    for _, w in ipairs(pData[37] or pData["37"]) do result[w] = true end
                end
            end
        end
    end)

    unlockedWorldsCache = result
    return result
end

-- NOCLIP HELPER
local noclipConn = nil
local function enableNoclip(state)
    if state then
        if not noclipConn then
            noclipConn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, p in ipairs(char:GetChildren()) do
                        if p:IsA("BasePart") then
                            p.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if noclipConn then
            pcall(function() noclipConn:Disconnect() end)
            noclipConn = nil
        end
    end
end

local WORLD_BOUNDS = {
    ["Event World"] = {minX = 2000, maxX = 3200, minZ = -1600, maxZ = -700},
    Overworld = {minX = -1000, maxX = 1000, minZ = -1000, maxZ = 500},
    ["Candy Land"] = {minX = -1500, maxX = 500, minZ = -4000, maxZ = -1800},
    ["Toy Land"] = {minX = -1000, maxX = 500, minZ = -6800, maxZ = -4200},
    ["Beach World"] = {minX = -800, maxX = 1200, minZ = -10000, maxZ = -7000},
    Atlantis = {minX = -500, maxX = 1500, minZ = -14200, maxZ = -11000},
    Heaven = {minX = 6500, maxX = 9000, minZ = -15000, maxZ = -12500},
    ["Mystic Forest"] = {minX = 3500, maxX = 6000, minZ = -17500, maxZ = -15000},
    ["Rainbow Land"] = {minX = 0, maxX = 2500, minZ = -19000, maxZ = -17000},
    Underworld = {minX = 500, maxX = 3800, minZ = -22000, maxZ = -19000}
}

local function getItemWorldName(item, pos)
    local wVal = item:FindFirstChild("World")
    if wVal and wVal:IsA("StringValue") and wVal.Value ~= "" then
        return wVal.Value
    end

    for wName, bounds in pairs(WORLD_BOUNDS) do
        if pos.X >= bounds.minX and pos.X <= bounds.maxX and
           pos.Z >= bounds.minZ and pos.Z <= bounds.maxZ then
            return wName
        end
    end
    return "Overworld"
end

local function getVisiblePart(item)
    if item:IsA("MeshPart") and item.Transparency < 0.5 then return item end
    if item:IsA("BasePart") and item.Transparency < 0.5 then return item end
    if item:IsA("Model") then
        local mp = item:FindFirstChildWhichIsA("MeshPart")
        if mp and mp.Transparency < 0.5 then return mp end
        local p = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
        if p and p.Transparency < 0.5 then return p end
    end
    return nil
end

-- UNIVERSAL ULTRA-FAST PICKUP ALLOWANCE CHECK
local function isPickupAllowed(item, mainPart)
    local itemPos = mainPart.Position
    
    -- Exclude 0m ground pickups (Y < 150)
    if itemPos.Y < 150 then return false end

    -- Exclude non-pickups (Must have TouchInterest or be inside Pickups folder)
    local hasTouch = item:FindFirstChildWhichIsA("TouchTransmitter", true) or item:FindFirstChild("TouchInterest", true)
    local isPickupFolder = item.Parent and item.Parent.Name:lower():find("pickup")
    if not hasTouch and not isPickupFolder then return false end

    -- World / Location Filter
    local itemWorld = getItemWorldName(item, itemPos)
    local hasAnyWorldEnabled = false
    if _G.CollectWorlds then
        for _, isEnabled in pairs(_G.CollectWorlds) do
            if isEnabled == true then
                hasAnyWorldEnabled = true
                break
            end
        end
    end

    if hasAnyWorldEnabled then
        if not _G.CollectWorlds[itemWorld] then
            return false
        end
    end

    return true
end

-- Helper: Get Position of Selected Egg
local function getSelectedEggPosition()
    if not _G.SelectedEgg or _G.SelectedEgg == "" or _G.SelectedEgg:find("Выберите") then return nil end
    pcall(function()
        if workspace:FindFirstChild("Eggs") then
            local eM = workspace.Eggs:FindFirstChild(_G.SelectedEgg)
            if eM then
                local p = eM.PrimaryPart or eM:FindFirstChildWhichIsA("BasePart")
                if p then return p.Position end
            end
        end
        if workspace:FindFirstChild("FloatingIslands") then
            for _, grp in ipairs(workspace.FloatingIslands:GetChildren()) do
                for _, isl in ipairs(grp:GetChildren()) do
                    local eFolder = isl:FindFirstChild("Eggs")
                    if eFolder then
                        local eM = eFolder:FindFirstChild(_G.SelectedEgg)
                        if eM then
                            local p = eM.PrimaryPart or eM:FindFirstChildWhichIsA("BasePart")
                            if p then return p.Position end
                        end
                    end
                end
            end
        end
    end)
    return nil
end

local function teleportToEggByName(eggName)
    local eggPos = getSelectedEggPosition()
    if eggPos then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local dist = (hrp.Position - eggPos).Magnitude
            if dist > 6 then
                safeTeleport(Vector3.new(eggPos.X, eggPos.Y + 4.5, eggPos.Z))
            end
        end
        return true
    end
    return false
end

-- Helper: Get Current "Eggs Opened" Stat Value
local function getEggsOpenedValue()
    local ls = LocalPlayer and LocalPlayer:FindFirstChild("leaderstats")
    local stat = ls and (ls:FindFirstChild("Eggs Opened") or ls:FindFirstChild("EggsOpened") or ls:FindFirstChild("Eggs"))
    return stat and stat.Value or 0
end

-- CRASH-PROOF OPTIMIZED AUTOCOLLECT LOOP WITH MANDATORY YIELD
task.spawn(function()
    while _G.HubActive do
        if _G.IsSellingNow or _G.IsTeleporting or (_G.AutoSell and isBubble100PercentFull()) then
            task.wait(0.2)
        elseif _G.AutoCollect and not _G.IsCollectingNow and not _G.SpeedrunUnlocking then
            _G.IsCollectingNow = true
            
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local originalCF = hrp and hrp.CFrame
            local eggTargetPos = getSelectedEggPosition()

            pcall(function()
                local folder = workspace:FindFirstChild("Pickups")
                if not hrp or not folder then return end
                
                local validPickups = {}

                for _, item in ipairs(folder:GetChildren()) do
                    if not _G.AutoCollect or not _G.HubActive or _G.IsSellingNow or _G.IsTeleporting or (_G.AutoSell and isBubble100PercentFull()) then break end
                    
                    local mainPart = getVisiblePart(item)
                    if mainPart and isPickupAllowed(item, mainPart) then
                        local pos = mainPart.Position
                        local distToEgg = eggTargetPos and (pos - eggTargetPos).Magnitude or 99999
                        table.insert(validPickups, {item = item, part = mainPart, posY = pos.Y, pos = pos, distEgg = distToEgg})
                    end
                end

                pcall(function()
                    if workspace:FindFirstChild("FloatingIslands") then
                        for _, islandGroup in ipairs(workspace.FloatingIslands:GetChildren()) do
                            for _, island in ipairs(islandGroup:GetChildren()) do
                                local pFolder = island:FindFirstChild("Pickups")
                                if pFolder then
                                    for _, item in ipairs(pFolder:GetChildren()) do
                                        if not _G.AutoCollect or not _G.HubActive or _G.IsSellingNow or _G.IsTeleporting or (_G.AutoSell and isBubble100PercentFull()) then break end
                                        local mainPart = getVisiblePart(item)
                                        if mainPart and isPickupAllowed(item, mainPart) then
                                            local pos = mainPart.Position
                                            local distToEgg = eggTargetPos and (pos - eggTargetPos).Magnitude or 99999
                                            table.insert(validPickups, {item = item, part = mainPart, posY = pos.Y, pos = pos, distEgg = distToEgg})
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)

                if #validPickups > 0 then
                    if _G.AutoHatch and eggTargetPos then
                        local eggPickups = {}
                        for _, p in ipairs(validPickups) do
                            if p.distEgg <= 700 then
                                table.insert(eggPickups, p)
                            end
                        end
                        validPickups = eggPickups
                        table.sort(validPickups, function(a, b) return a.distEgg < b.distEgg end)
                    else
                        table.sort(validPickups, function(a, b) return a.posY > b.posY end)
                    end

                    enableNoclip(true)
                    
                    local sweepCount = math.min(#validPickups, 20)
                    for i = 1, sweepCount do
                        if not _G.AutoCollect or not _G.HubActive or _G.IsSellingNow or _G.IsTeleporting or (_G.AutoSell and isBubble100PercentFull()) then break end
                        
                        local entry = validPickups[i]
                        if entry and entry.part and entry.part.Parent then
                            hrp.CFrame = CFrame.new(entry.pos.X, entry.pos.Y + 3.0, entry.pos.Z)
                            hrp.AssemblyLinearVelocity = Vector3.new(0, -5, 0)
                            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                            safeTouch(hrp, entry.part)
                            task.wait(_G.CollectDelay or 0.04)
                        end
                    end

                    enableNoclip(false)
                end
            end)
            
            -- RETURN TO EGG SPOT OR ORIGINAL SPOT AFTER SWEEP
            if _G.AutoHatch and eggTargetPos then
                teleportToEggByName(_G.SelectedEgg)
                pcall(performInstantEggHatch)
            elseif originalCF and _G.ReturnToCollectPos and hrp and hrp.Parent and not _G.IsSellingNow and not _G.IsTeleporting then
                hrp.CFrame = originalCF
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                task.wait(0.04)
                hrp.CFrame = originalCF
            end
            
            _G.IsCollectingNow = false
            task.wait(0.25) -- CRITICAL MANDATORY YIELD TO PREVENT CPU FREEZE CRASH!
        else
            task.wait(0.25)
        end
    end
end)

-- AUTO-BUY & AUTO-EQUIP REAL TIME ENGINES
local SHOP_CATEGORIES = {
    Gum = {catName = "Gum", shops = {"EarthGum", "CandyGum", "BeachGum", "SpaceGum", "UnderworldGum"}},
    Flavors = {catName = "Flavors", shops = {"EarthFlavors", "CandyFlavors", "BeachFlavors", "SpaceFlavors", "UnderworldFlavors"}},
    Faces = {catName = "Faces", shops = {"EarthFaces", "CandyFaces", "BeachFaces", "SpaceFaces", "UnderworldFaces"}}
}

local function executeAutoBuyUpgrades()
    if not _G.AutoBuyUpgrades or not _G.HubActive or _G.IsTeleporting then return end
    
    local mods = getBGSItemModules()
    local shopMod = mods and mods.ShopModule
    local netFunc = game:GetService("ReplicatedStorage"):FindFirstChild("NetworkRemoteFunction")
    local netEvent = game:GetService("ReplicatedStorage"):FindFirstChild("NetworkRemoteEvent")
    if not shopMod or not netFunc or not netEvent then return end

    local pData = nil
    pcall(function() pData = netFunc:InvokeServer("GetPlayerData") end)
    if not pData then return end

    local coins = LocalPlayer.leaderstats and LocalPlayer.leaderstats:FindFirstChild("Coins") and LocalPlayer.leaderstats.Coins.Value or 0

    local ownedFlavors = pData[5] or pData["5"] or {}
    local ownedGums = pData[6] or pData["6"] or {}
    local ownedFaces = pData[74] or pData["74"] or {}

    local ownedGumsSet = {}
    if type(ownedGums) == "table" then for _, g in ipairs(ownedGums) do ownedGumsSet[g] = true end end
    local ownedFlavorsSet = {}
    if type(ownedFlavors) == "table" then for _, f in ipairs(ownedFlavors) do ownedFlavorsSet[f] = true end end
    local ownedFacesSet = {}
    if type(ownedFaces) == "table" then for _, fc in ipairs(ownedFaces) do ownedFacesSet[fc] = true end end

    -- 1. Upgrade Gums
    if _G.UpgradeGum then
        for _, sName in ipairs(SHOP_CATEGORIES.Gum.shops) do
            local shopData = shopMod[sName]
            if type(shopData) == "table" then
                for _, item in ipairs(shopData) do
                    if type(item) == "table" and item.Name and not ownedGumsSet[item.Name] then
                        local costAmt = item.Cost and item.Cost[1] or 0
                        local costType = item.Cost and item.Cost[2] or "Coins"
                        if costType == "Coins" and coins >= costAmt then
                            netEvent:FireServer("BuyShopItem", sName, "Gum", item.Name)
                            task.wait(0.25)
                            coins = LocalPlayer.leaderstats and LocalPlayer.leaderstats.Coins.Value or coins
                        end
                    end
                end
            end
        end
    end

    -- 2. Upgrade Flavors
    if _G.UpgradeFlavors then
        for _, sName in ipairs(SHOP_CATEGORIES.Flavors.shops) do
            local shopData = shopMod[sName]
            if type(shopData) == "table" then
                for _, item in ipairs(shopData) do
                    if type(item) == "table" and item.Name and not ownedFlavorsSet[item.Name] then
                        local costAmt = item.Cost and item.Cost[1] or 0
                        local costType = item.Cost and item.Cost[2] or "Coins"
                        if costType == "Coins" and coins >= costAmt then
                            netEvent:FireServer("BuyShopItem", sName, "Flavors", item.Name)
                            task.wait(0.25)
                            coins = LocalPlayer.leaderstats and LocalPlayer.leaderstats.Coins.Value or coins
                        end
                    end
                end
            end
        end
    end

    -- 3. Upgrade Faces
    if _G.UpgradeFaces then
        for _, sName in ipairs(SHOP_CATEGORIES.Faces.shops) do
            local shopData = shopMod[sName]
            if type(shopData) == "table" then
                for _, item in ipairs(shopData) do
                    if type(item) == "table" and item.Name and not ownedFacesSet[item.Name] then
                        local costAmt = item.Cost and item.Cost[1] or 0
                        local costType = item.Cost and item.Cost[2] or "Coins"
                        if costType == "Coins" and coins >= costAmt then
                            netEvent:FireServer("BuyShopItem", sName, "Faces", item.Name)
                            task.wait(0.25)
                            coins = LocalPlayer.leaderstats and LocalPlayer.leaderstats.Coins.Value or coins
                        end
                    end
                end
            end
        end
    end
end

local function executeAutoEquipBest()
    if not _G.AutoEquipBest or not _G.HubActive or _G.IsTeleporting then return end

    local mods = getBGSItemModules()
    local shopMod = mods and mods.ShopModule
    local gumMod = mods and mods.GumModule
    local flavorMod = mods and mods.FlavorModule
    local faceMod = mods and mods.FaceModule
    local netFunc = game:GetService("ReplicatedStorage"):FindFirstChild("NetworkRemoteFunction")
    local netEvent = game:GetService("ReplicatedStorage"):FindFirstChild("NetworkRemoteEvent")
    if not netFunc or not netEvent or not shopMod then return end

    local pData = nil
    pcall(function() pData = netFunc:InvokeServer("GetPlayerData") end)
    if not pData then return end

    local equipped = pData[2] or pData["2"] or {}
    local equippedFlavor = equipped[1]
    local equippedGum = equipped[2]
    local equippedFace = equipped[3]

    local ownedFlavors = pData[5] or pData["5"] or {}
    local ownedGums = pData[6] or pData["6"] or {}
    local ownedFaces = pData[74] or pData["74"] or {}

    -- Auto-Equip Best Gum
    if _G.AutoEquipGum and type(ownedGums) == "table" and #ownedGums > 0 then
        local bestGumName, bestGumShop = nil, nil
        local maxCap = -1

        for _, sName in ipairs(SHOP_CATEGORIES.Gum.shops) do
            local sData = shopMod[sName]
            if type(sData) == "table" then
                for _, item in ipairs(sData) do
                    if type(item) == "table" and item.Name then
                        for _, og in ipairs(ownedGums) do
                            if og == item.Name then
                                local gInfo = gumMod and gumMod[item.Name]
                                local cap = gInfo and (gInfo.AirCapacity or gInfo.Capacity or gInfo.MaxBubbles or gInfo.Multiplier) or 1
                                if cap > maxCap then
                                    maxCap = cap
                                    bestGumName = item.Name
                                    bestGumShop = sName
                                end
                            end
                        end
                    end
                end
            end
        end

        if bestGumName and bestGumName ~= equippedGum and bestGumShop then
            netEvent:FireServer("EquipItem", bestGumShop, "Gum", bestGumName)
        end
    end

    -- Auto-Equip Best Flavor
    if _G.AutoEquipFlavors and type(ownedFlavors) == "table" and #ownedFlavors > 0 then
        local bestFlavorName, bestFlavorShop = nil, nil
        local maxMult = -1

        for _, sName in ipairs(SHOP_CATEGORIES.Flavors.shops) do
            local sData = shopMod[sName]
            if type(sData) == "table" then
                for _, item in ipairs(sData) do
                    if type(item) == "table" and item.Name then
                        for _, of in ipairs(ownedFlavors) do
                            if of == item.Name then
                                local fInfo = flavorMod and flavorMod[item.Name]
                                local mult = fInfo and (fInfo.BubbleIncrease or fInfo.Multiplier or fInfo.Bubbles) or 1
                                if mult > maxMult then
                                    maxMult = mult
                                    bestFlavorName = item.Name
                                    bestFlavorShop = sName
                                end
                            end
                        end
                    end
                end
            end
        end

        if bestFlavorName and bestFlavorName ~= equippedFlavor and bestFlavorShop then
            netEvent:FireServer("EquipItem", bestFlavorShop, "Flavors", bestFlavorName)
        end
    end

    -- Auto-Equip Best Face
    if _G.AutoEquipFaces and type(ownedFaces) == "table" and #ownedFaces > 0 then
        local bestFaceName, bestFaceShop = nil, nil
        local maxMult = -1

        for _, sName in ipairs(SHOP_CATEGORIES.Faces.shops) do
            local sData = shopMod[sName]
            if type(sData) == "table" then
                for _, item in ipairs(sData) do
                    if type(item) == "table" and item.Name then
                        for _, ofc in ipairs(ownedFaces) do
                            if ofc == item.Name then
                                local fcInfo = faceMod and faceMod[item.Name]
                                local mult = fcInfo and (fcInfo.BubbleIncrease or fcInfo.Multiplier or fcInfo.Bubbles) or 1
                                if mult > maxMult then
                                    maxMult = mult
                                    bestFaceName = item.Name
                                    bestFaceShop = sName
                                end
                            end
                        end
                    end
                end
            end
        end

        if bestFaceName and bestFaceName ~= equippedFace and bestFaceShop then
            netEvent:FireServer("EquipItem", bestFaceShop, "Faces", bestFaceName)
        end
    end
end

_G.ExecuteAutoBuyUpgrades = executeAutoBuyUpgrades
_G.ExecuteAutoEquipBest = executeAutoEquipBest

-- Persistent Master Background Loops
task.spawn(function()
    while _G.HubActive do
        if _G.AutoBlow and not _G.IsTeleporting then
            if not isBubble100PercentFull() then
                pcall(function()
                    game:GetService("ReplicatedStorage").NetworkRemoteEvent:FireServer("BlowBubble")
                end)
            end
            task.wait(0.08)
        else
            task.wait(0.4)
        end
    end
end)

task.spawn(function()
    while _G.HubActive do
        if _G.AutoBuyUpgrades and not _G.IsTeleporting then
            executeAutoBuyUpgrades()
            task.wait(2.5)
        else
            task.wait(0.6)
        end
    end
end)

task.spawn(function()
    while _G.HubActive do
        if _G.AutoEquipBest and not _G.IsTeleporting then
            executeAutoEquipBest()
            task.wait(3.0)
        else
            task.wait(0.6)
        end
    end
end)

-- Persistent Master Infinite Jump Connection
trackConnection(UserInputService.JumpRequest:Connect(function()
    if _G.InfJump and _G.HubActive and not _G.IsTeleporting then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

-- AUTO-SELL ENGINE & PLATFORM DECLARATIONS
local SELL_PRIORITY = {
    {world = "Heaven", actName = "HeavenSell", spawnTag = "HeavenSpawn", pos = Vector3.new(7804.8, 98.2, -13922.4), mult = "25x", name = "Heaven World (25x)"},
    {world = "Underworld", actName = "UnderworldSell", spawnTag = "UnderworldSpawn", pos = Vector3.new(2181.1, 19.6, -20071.2), mult = "20x", name = "Underworld (20x)"},
    {world = "Mystic Forest", actName = "Mystic ForestSpawn", pos = Vector3.new(4699.8, 33.2, -16051.9), mult = "10x", name = "Mystic Forest (10x)"},
    {world = "Atlantis", actName = "AtlantisSell", spawnTag = "AtlantisSpawn", pos = Vector3.new(306.8, 45.4, -13041.5), mult = "8x", name = "Atlantis (8x)"},
    {world = "Beach World", actName = "BeachSell", spawnTag = "Beach WorldSpawn", pos = Vector3.new(412.8, 47.4, -8574.0), mult = "6x", name = "Beach World (6x)"},
    {world = "Candy Land", actName = "CandySell", spawnTag = "Candy LandSpawn", pos = Vector3.new(-513.2, 42.3, -2919.5), mult = "4x", name = "Candy Land (4x)"},
    {world = "The Twilight", actName = "TwilightSell", spawnTag = "OverworldSpawn", pos = Vector3.new(72.4, 11381.2, -315.8), mult = "2x", name = "The Twilight (2x)"},
    {world = "Overworld", actName = "Sell", spawnTag = "OverworldSpawn", pos = Vector3.new(-160.3, 42.7, -147.0), mult = "1x", name = "Overworld Spawn (1x)"}
}

local SellLocationsMap = {
    ["☁ Heaven World (25x Multiplier)"] = {actName = "HeavenSell", spawnTag = "HeavenSpawn", pos = Vector3.new(7804.8, 98.2, -13922.4), mult = "25x"},
    ["🔥 Underworld (20x Multiplier)"] = {actName = "UnderworldSell", spawnTag = "UnderworldSpawn", pos = Vector3.new(2181.1, 19.6, -20071.2), mult = "20x"},
    ["🌲 Mystic Forest (10x Multiplier)"] = {actName = "Mystic ForestSell", spawnTag = "Mystic ForestSpawn", pos = Vector3.new(4699.8, 33.2, -16051.9), mult = "10x"},
    ["🔱 Atlantis (8x Multiplier)"] = {actName = "AtlantisSell", spawnTag = "AtlantisSpawn", pos = Vector3.new(306.8, 45.4, -13041.5), mult = "8x"},
    ["🏖 Beach World (6x Multiplier)"] = {actName = "BeachSell", spawnTag = "Beach WorldSpawn", pos = Vector3.new(412.8, 47.4, -8574.0), mult = "6x"},
    ["🍭 Candy Land (4x Multiplier)"] = {actName = "CandySell", spawnTag = "Candy LandSpawn", pos = Vector3.new(-513.2, 42.3, -2919.5), mult = "4x"},
    ["🌙 The Twilight (2x - 11,378m)"] = {actName = "TwilightSell", spawnTag = "OverworldSpawn", pos = Vector3.new(72.4, 11381.2, -315.8), mult = "2x"},
    ["🏠 Спавн: Overworld Sell (1x Стандарт)"] = {actName = "Sell", spawnTag = "OverworldSpawn", pos = Vector3.new(-160.3, 42.7, -147.0), mult = "1x"}
}

local function ensureSellPlatform(actName, sellPos)
    local pName = "SataNet_SellPlatform_" .. actName
    local platform = workspace:FindFirstChild(pName)
    if not platform then
        platform = Instance.new("Part")
        platform.Name = pName
        platform.Size = Vector3.new(50, 1, 50)
        platform.CFrame = CFrame.new(sellPos.X, sellPos.Y - 2.5, sellPos.Z)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Material = Enum.Material.SmoothPlastic
        platform.Color = Color3.fromRGB(70, 150, 255)
        platform.Transparency = 0.5
        platform.Parent = workspace
    else
        platform.CFrame = CFrame.new(sellPos.X, sellPos.Y - 2.5, sellPos.Z)
    end
    return platform
end

local function getBestUnlockedSellLocation()
    local acts = workspace:FindFirstChild("Activations")
    for _, entry in ipairs(SELL_PRIORITY) do
        if acts and acts:FindFirstChild(entry.actName) then
            return entry
        end
    end
    return SELL_PRIORITY[1]
end

local lastSellTime = 0
local function performSmartSell()
    if _G.IsSellingNow or _G.IsTeleporting then return end
    
    local now = tick()
    local cd = _G.SellCooldown or 3.0
    if now - lastSellTime < cd then return end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local netFunc = game:GetService("ReplicatedStorage"):FindFirstChild("NetworkRemoteFunction")
    local netEvent = game:GetService("ReplicatedStorage"):FindFirstChild("NetworkRemoteEvent")
    if not hrp or not netEvent then return end

    _G.IsSellingNow = true
    lastSellTime = tick()
    local savedFarmCF = hrp.CFrame

    local targetSellInfo = nil
    if _G.SelectedSellMode:find("Авто") or _G.SelectedSellMode:find("авто") then
        targetSellInfo = getBestUnlockedSellLocation()
    else
        targetSellInfo = SellLocationsMap[_G.SelectedSellMode] or getBestUnlockedSellLocation()
    end

    -- Step 1: Teleport using native portal touch or remote
    if netFunc and targetSellInfo and targetSellInfo.spawnTag then
        pcall(function()
            netFunc:InvokeServer("Teleport", targetSellInfo.spawnTag)
        end)
        task.wait(0.35)
    end

    local actName = targetSellInfo.actName or "HeavenSell"
    local actModel = workspace:FindFirstChild("Activations") and (workspace.Activations:FindFirstChild(actName) or workspace.Activations:FindFirstChild("Sell"))
    local actPart = actModel and (actModel:FindFirstChild("Root") or actModel:FindFirstChild("Tag") or actModel:FindFirstChildWhichIsA("BasePart"))

    local sellPos = actPart and actPart.Position or targetSellInfo.pos

    -- Step 2: Physical safety platform placed lower (Y - 2.5)
    ensureSellPlatform(actName, sellPos)

    -- Step 3: Teleport player higher above sell circle (Y + 8) so character falls naturally onto the sell pad!
    hrp.CFrame = CFrame.new(sellPos.X, sellPos.Y + 8, sellPos.Z)
    hrp.AssemblyLinearVelocity = Vector3.new(0, -10, 0)
    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    
    task.wait(0.2)

    if actPart then safeTouch(hrp, actPart) end
    netEvent:FireServer("SellBubble", actName)

    -- Step 4: Dynamic SOLD verification loop while waiting on sell pad
    local sellStartTime = tick()
    while isBubble100PercentFull() and (tick() - sellStartTime) < 3.0 and _G.HubActive do
        if actPart then safeTouch(hrp, actPart) end
        netEvent:FireServer("SellBubble", actName)
        task.wait(0.2)
    end
    task.wait(0.2)

    -- Step 5: Return to saved farm position cleanly
    if _G.ReturnToFarmPos and savedFarmCF and hrp and hrp.Parent then
        hrp.CFrame = savedFarmCF
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        task.wait(0.1)
    end

    _G.IsSellingNow = false
end

_G.PerformSmartSell = performSmartSell

-- Persistent Master Auto-Sell Loop
task.spawn(function()
    while _G.HubActive do
        if _G.AutoSell and not _G.IsTeleporting and isBubble100PercentFull() then
            performSmartSell()
            task.wait(_G.SellCooldown or 3.0)
        else
            task.wait(0.4)
        end
    end
end)

-- DISCORD WEBHOOK & PET HATCHING ENGINE
local RARITY_COLORS = {
    Common = 10066329,
    Unique = 10066329,
    Rare = 3381759,
    Epic = 13408767,
    Legendary = 16766720,
    Secret = 9055202
}

local RARITY_LEVELS = {
    Common = 1,
    Unique = 1,
    Rare = 2,
    Epic = 3,
    Legendary = 4,
    Secret = 5
}

local function formatPetBuffs(buffs)
    if type(buffs) ~= "table" then return "Статы: Стандарт" end
    local strList = {}
    for k, v in pairs(buffs) do
        table.insert(strList, tostring(k) .. ": x" .. tostring(v))
    end
    if #strList > 0 then
        return table.concat(strList, " | ")
    end
    return "Статы: Стандарт"
end

local function sendPetWebhook(webhookUrl, petName, eggName, isShiny, isMythic)
    if not webhookUrl or webhookUrl == "" or not webhookUrl:find("http") then return end

    local mods = getBGSItemModules()
    local petDS = mods and mods.PetModule
    local pDataInfo = petDS and petDS[petName] or {}

    local rarity = pDataInfo.Rarity or "Common"
    local rawIcon = pDataInfo.Image or pDataInfo.Icon or pDataInfo.AssetId
    local buffs = pDataInfo.Buffs or pDataInfo.Multiplier

    local color = RARITY_COLORS[rarity] or 10066329
    
    local iconIdNum = rawIcon and tostring(rawIcon):match("%d+")
    local iconUrl = iconIdNum and ("https://www.roblox.com/asset-thumbnail/image?assetId=" .. iconIdNum .. "&width=420&height=420&format=png") or "https://www.roblox.com/headshot-thumbnail/image?userId=1&width=420&height=420&format=png"

    local statStr = formatPetBuffs(buffs)

    local prefix = ""
    if isShiny then prefix = "✨ Shiny " end
    if isMythic then prefix = prefix .. "🌟 Mythic " end

    local fullName = prefix .. petName

    local embed = {
        title = "🎉 Выпал новый питомец!",
        color = color,
        fields = {
            {name = "🐾 Питомец", value = "**" .. fullName .. "**", inline = true},
            {name = "⭐ Редкость", value = rarity, inline = true},
            {name = "🥚 Яйцо", value = eggName or "Неизвестно", inline = true},
            {name = "📊 Множители", value = statStr, inline = false}
        },
        thumbnail = {url = iconUrl},
        footer = {text = "SataNet BGS Hub v2.0 • Webhook Engine"},
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }

    local payload = {
        username = "SataNet BGS Notifier",
        avatar_url = "https://www.roblox.com/headshot-thumbnail/image?userId=1&width=420&height=420&format=png",
        embeds = {embed}
    }

    local req = (typeof(request) == "function" and request) or (typeof(http_request) == "function" and http_request) or (syn and typeof(syn.request) == "function" and syn.request)
    if req then
        pcall(function()
            req({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end
end

local function checkAndSendNewPetWebhooks(pDataBefore, pDataAfter, eggName)
    local petsBefore = pDataBefore and (pDataBefore[10] or pDataBefore["10"]) or {}
    local petsAfter = pDataAfter and (pDataAfter[10] or pDataAfter["10"]) or {}

    if type(petsAfter) == "table" and type(petsBefore) == "table" and #petsAfter > #petsBefore then
        for i = #petsBefore + 1, #petsAfter do
            local petEntry = petsAfter[i]
            if type(petEntry) == "table" then
                local petBaseName = petEntry[2] or petEntry[3] or "Unknown Pet"
                local isShiny = petEntry[6] == true
                local isMythic = petEntry[7] == true

                local mods = getBGSItemModules()
                local petDS = mods and mods.PetModule
                local pInfo = petDS and petDS[petBaseName] or {}
                local rarity = pInfo.Rarity or "Common"

                local minLevel = 1
                if _G.WebhookRarityFilter == "Rare+" then minLevel = 2
                elseif _G.WebhookRarityFilter == "Epic+" then minLevel = 3
                elseif _G.WebhookRarityFilter == "Legendary+" then minLevel = 4
                elseif _G.WebhookRarityFilter == "Secret Only" then minLevel = 5
                end

                local petLevel = RARITY_LEVELS[rarity] or 1
                if petLevel >= minLevel then
                    sendPetWebhook(_G.PetWebhookUrl, petBaseName, eggName, isShiny, isMythic)
                end
            end
        end
    end
end

-- Helper: Get Position of Selected Egg
local function getSelectedEggPosition()
    if not _G.SelectedEgg or _G.SelectedEgg == "" or _G.SelectedEgg:find("Выберите") then return nil end
    if workspace:FindFirstChild("Eggs") then
        local eM = workspace.Eggs:FindFirstChild(_G.SelectedEgg)
        if eM then
            local p = eM.PrimaryPart or eM:FindFirstChildWhichIsA("BasePart")
            if p then return p.Position end
        end
    end
    if workspace:FindFirstChild("FloatingIslands") then
        for _, grp in ipairs(workspace.FloatingIslands:GetChildren()) do
            for _, isl in ipairs(grp:GetChildren()) do
                local eFolder = isl:FindFirstChild("Eggs")
                if eFolder then
                    local eM = eFolder:FindFirstChild(_G.SelectedEgg)
                    if eM then
                        local p = eM.PrimaryPart or eM:FindFirstChildWhichIsA("BasePart")
                        if p then return p.Position end
                    end
                end
            end
        end
    end
    return nil
end

-- Helper: Teleport to Egg by Name (Only teleports if distance > 6 studs!)
local function teleportToEggByName(eggName)
    local eggPos = getSelectedEggPosition()
    if eggPos then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local dist = (hrp.Position - eggPos).Magnitude
            if dist > 6 then
                safeTeleport(Vector3.new(eggPos.X, eggPos.Y + 4.5, eggPos.Z))
            end
        end
        return true
    end
    return false
end

-- Helper: Get Current "Eggs Opened" Stat Value
local function getEggsOpenedValue()
    local ls = LocalPlayer and LocalPlayer:FindFirstChild("leaderstats")
    local stat = ls and ls:FindFirstChild("Eggs Opened")
    return stat and stat.Value or 0
end

-- HIGHEST PRIORITY GUARANTEED HATCH ENGINE WITH VERIFICATION VIA LEADERSTATS "EGGS OPENED"
local function performInstantEggHatch()
    if not _G.SelectedEgg or _G.SelectedEgg == "" or _G.SelectedEgg:find("Выберите") or _G.IsTeleporting or _G.IsSellingNow then return false end
    
    _G.LastHatchTime = tick()
    local hatchSuccess = false

    pcall(function()
        -- 1. TOP PRIORITY TELEPORT: Immediately step right next to the selected egg
        teleportToEggByName(_G.SelectedEgg)

        local netFunc = game:GetService("ReplicatedStorage"):FindFirstChild("NetworkRemoteFunction")
        local netEvent = game:GetService("ReplicatedStorage"):FindFirstChild("NetworkRemoteEvent")

        local pDataBefore = nil
        if _G.PetWebhookEnabled and _G.PetWebhookUrl ~= "" and netFunc then
            pcall(function() pDataBefore = netFunc:InvokeServer("GetPlayerData") end)
        end

        local valBefore = getEggsOpenedValue()

        local amount = _G.HatchAmount or 1
        if netEvent then
            if amount == 3 then
                netEvent:FireServer("PurchaseEgg", _G.SelectedEgg, true)
            else
                netEvent:FireServer("PurchaseEgg", _G.SelectedEgg)
            end
        end

        -- 2. DYNAMIC VERIFICATION LOOP: Stand at egg and wait for +1 "Eggs Opened" stat!
        local waitStart = tick()
        while (tick() - waitStart) < 0.35 and _G.HubActive and not _G.IsTeleporting do
            if getEggsOpenedValue() > valBefore then
                hatchSuccess = true
                break
            end
            task.wait(0.01)
        end

        -- 3. Non-blocking asynchronous Webhook checking thread
        if _G.PetWebhookEnabled and _G.PetWebhookUrl ~= "" and pDataBefore and netFunc then
            task.spawn(function()
                task.wait(0.5)
                local pDataAfter = nil
                pcall(function() pDataAfter = netFunc:InvokeServer("GetPlayerData") end)
                if pDataAfter then
                    checkAndSendNewPetWebhooks(pDataBefore, pDataAfter, _G.SelectedEgg)
                end
            end)
        end
    end)

    return hatchSuccess
end

-- Persistent Auto-Hatch Thread (HIGH PRIORITY)
task.spawn(function()
    while _G.HubActive do
        if _G.AutoHatch and not _G.IsTeleporting and not _G.IsSellingNow and _G.SelectedEgg and _G.SelectedEgg ~= "" and not _G.SelectedEgg:find("Выберите") then
            local now = tick()
            local cd = _G.HatchCooldown or 0.60
            if (now - _G.LastHatchTime) >= cd then
                performInstantEggHatch()
            end
            task.wait(0.015)
        else
            task.wait(0.3)
        end
    end
end)

-- [2] Splash Loading Screen ("Satanet" + Custom Logo)
local SplashGui = Instance.new("ScreenGui")
SplashGui.Name = "SataNet_Splash"
SplashGui.DisplayOrder = 999999
SplashGui.ResetOnSpawn = false
protectGui(SplashGui)

local SplashCard = Instance.new("Frame")
SplashCard.Name = "SplashCard"
SplashCard.Size = UDim2.new(0, 340, 0, 220)
SplashCard.Position = UDim2.new(0.5, -170, 0.5, -110)
SplashCard.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
SplashCard.BorderSizePixel = 0
SplashCard.ClipsDescendants = true
SplashCard.Parent = SplashGui

local SplashCorner = Instance.new("UICorner")
SplashCorner.CornerRadius = UDim.new(0, 14)
SplashCorner.Parent = SplashCard

local SplashStroke = Instance.new("UIStroke")
SplashStroke.Color = Color3.fromRGB(80, 150, 255)
SplashStroke.Thickness = 1.8
SplashStroke.Transparency = 0.2
SplashStroke.Parent = SplashCard





local SplashTitle = Instance.new("TextLabel")
SplashTitle.Size = UDim2.new(1, 0, 0, 28)
SplashTitle.Position = UDim2.new(0, 0, 0, 56)
SplashTitle.BackgroundTransparency = 1
SplashTitle.Font = Enum.Font.GothamBold
SplashTitle.Text = "SATANET"
SplashTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SplashTitle.TextSize = 22
SplashTitle.ZIndex = 2
SplashTitle.Parent = SplashCard

local SplashSub = Instance.new("TextLabel")
SplashSub.Size = UDim2.new(1, 0, 0, 18)
SplashSub.Position = UDim2.new(0, 0, 0, 84)
SplashSub.BackgroundTransparency = 1
SplashSub.Font = Enum.Font.Gotham
SplashSub.Text = "Загрузка Bubble Gum Simulator Hub..."
SplashSub.TextColor3 = Color3.fromRGB(180, 190, 210)
SplashSub.TextSize = 12
SplashSub.ZIndex = 2
SplashSub.Parent = SplashCard

local BarBg = Instance.new("Frame")
BarBg.Size = UDim2.new(0.85, 0, 0, 6)
BarBg.Position = UDim2.new(0.075, 0, 0, 118)
BarBg.BackgroundColor3 = Color3.fromRGB(30, 32, 45)
BarBg.BorderSizePixel = 0
BarBg.ZIndex = 2
BarBg.Parent = SplashCard
Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(70, 150, 255)
BarFill.BorderSizePixel = 0
BarFill.ZIndex = 3
BarFill.Parent = BarBg
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

-- RESET CONFIG BUTTON ON SPLASH LOADING SCREEN
local ResetSplashBtn = Instance.new("TextButton")
ResetSplashBtn.Name = "ResetSplashBtn"
ResetSplashBtn.Size = UDim2.new(0.85, 0, 0, 30)
ResetSplashBtn.Position = UDim2.new(0.075, 0, 0, 160)
ResetSplashBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 55)
ResetSplashBtn.BorderSizePixel = 0
ResetSplashBtn.Font = Enum.Font.GothamBold
ResetSplashBtn.Text = "⚠️ Сбросить конфигурацию"
ResetSplashBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetSplashBtn.TextSize = 12
ResetSplashBtn.ZIndex = 4
ResetSplashBtn.Parent = SplashCard
Instance.new("UICorner", ResetSplashBtn).CornerRadius = UDim.new(0, 6)

local ResetStroke = Instance.new("UIStroke")
ResetStroke.Color = Color3.fromRGB(255, 80, 90)
ResetStroke.Thickness = 1
ResetStroke.Transparency = 0.4
ResetStroke.Parent = ResetSplashBtn

ResetSplashBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if typeof(delfile) == "function" and typeof(isfile) == "function" and isfile(CONFIG_FILE_NAME) then
            delfile(CONFIG_FILE_NAME)
        end
    end)
    _G.AutoCollect = false
    _G.AutoBlow = false
    _G.AutoSell = false
    _G.AutoHatch = false
    ResetSplashBtn.Text = "✅ КОНФИГУРАЦИЯ СБРОШЕНА!"
    ResetSplashBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 70)
    ResetStroke.Color = Color3.fromRGB(80, 220, 120)
end)

TweenService:Create(BarFill, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
    Size = UDim2.new(1, 0, 1, 0)
}):Play()

-- USER REQUEST: Keep Splash Loading Screen visible for 3 SECONDS after loading
task.wait(3.0)

TweenService:Create(SplashCard, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
    Position = UDim2.new(0.5, -170, 0.45, -110),
    BackgroundTransparency = 1
}):Play()
task.wait(0.26)
SplashGui:Destroy()

-- [3] Main Hub GUI Construction
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "SataNet_MainGui"
MainGui.DisplayOrder = 1000
MainGui.ResetOnSpawn = false
protectGui(MainGui)

-- Main Window Frame
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 630, 0, 430)
MainWindow.Position = UDim2.new(0.5, -315, 0.5, -215)
MainWindow.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
MainWindow.BorderSizePixel = 0
MainWindow.ClipsDescendants = true
MainWindow.ZIndex = 10
MainWindow.Parent = MainGui

local MainScale = Instance.new("UIScale")
MainScale.Name = "MainScale"
MainScale.Scale = _G.GuiScale or 1.0
MainScale.Parent = MainWindow

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainWindow

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(70, 140, 255)
MainStroke.Thickness = 1.8
MainStroke.Transparency = 0.3
MainStroke.Parent = MainWindow



local DarkOverlay = Instance.new("Frame")
DarkOverlay.Size = UDim2.new(1, 0, 1, 0)
DarkOverlay.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
DarkOverlay.BackgroundTransparency = 0.4
DarkOverlay.ZIndex = 12
DarkOverlay.Parent = MainWindow
Instance.new("UICorner", DarkOverlay).CornerRadius = UDim.new(0, 12)

-- [4] Left Sidebar (Categories / Tabs)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 175, 1, 0)
Sidebar.Position = UDim2.new(0, 0, 0, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 13, 18)
Sidebar.BackgroundTransparency = 0.2
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 20
Sidebar.Parent = MainWindow

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 12)
SidebarCorner.Parent = Sidebar

local BrandBox = Instance.new("Frame")
BrandBox.Size = UDim2.new(1, 0, 0, 60)
BrandBox.BackgroundTransparency = 1
BrandBox.ZIndex = 21
BrandBox.Parent = Sidebar

local LogoIcon = Instance.new("ImageLabel")
LogoIcon.Size = UDim2.new(0, 26, 0, 26)
LogoIcon.Position = UDim2.new(0, 14, 0, 16)
LogoIcon.BackgroundTransparency = 1
LogoIcon.Image = logoAssetId or "rbxassetid://13837920786"
LogoIcon.ImageColor3 = Color3.fromRGB(100, 180, 255)
LogoIcon.ScaleType = Enum.ScaleType.Fit
LogoIcon.ZIndex = 22
LogoIcon.Parent = BrandBox

local BrandTitle = Instance.new("TextLabel")
BrandTitle.Size = UDim2.new(1, -50, 0, 20)
BrandTitle.Position = UDim2.new(0, 46, 0, 12)
BrandTitle.BackgroundTransparency = 1
BrandTitle.Font = Enum.Font.GothamBold
BrandTitle.Text = "SATANET"
BrandTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
BrandTitle.TextSize = 14
BrandTitle.TextXAlignment = Enum.TextXAlignment.Left
BrandTitle.ZIndex = 22
BrandTitle.Parent = BrandBox

local BrandSub = Instance.new("TextLabel")
BrandSub.Size = UDim2.new(1, -50, 0, 16)
BrandSub.Position = UDim2.new(0, 46, 0, 31)
BrandSub.BackgroundTransparency = 1
BrandSub.Font = Enum.Font.Gotham
BrandSub.Text = "BGS Hub v2.0"
BrandSub.TextColor3 = Color3.fromRGB(140, 160, 200)
BrandSub.TextSize = 10
BrandSub.TextXAlignment = Enum.TextXAlignment.Left
BrandSub.ZIndex = 22
BrandSub.Parent = BrandBox

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -24, 0, 1)
Divider.Position = UDim2.new(0, 12, 0, 58)
Divider.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
Divider.BorderSizePixel = 0
Divider.ZIndex = 21
Divider.Parent = Sidebar

local TabListHolder = Instance.new("ScrollingFrame")
TabListHolder.Name = "TabList"
TabListHolder.Size = UDim2.new(1, -12, 1, -70)
TabListHolder.Position = UDim2.new(0, 6, 0, 65)
TabListHolder.BackgroundTransparency = 1
TabListHolder.BorderSizePixel = 0
TabListHolder.ScrollBarThickness = 2
TabListHolder.ScrollBarImageColor3 = Color3.fromRGB(70, 130, 255)
TabListHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
TabListHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabListHolder.ZIndex = 21
TabListHolder.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Parent = TabListHolder

-- [5] Right Content Container
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -185, 1, -16)
ContentArea.Position = UDim2.new(0, 180, 0, 8)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 20
ContentArea.Parent = MainWindow

local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, 0, 0, 36)
Topbar.BackgroundTransparency = 1
Topbar.ZIndex = 21
Topbar.Parent = ContentArea

local CurrentTabTitle = Instance.new("TextLabel")
CurrentTabTitle.Name = "CurrentTabTitle"
CurrentTabTitle.Size = UDim2.new(1, -110, 1, 0)
CurrentTabTitle.Position = UDim2.new(0, 6, 0, 0)
CurrentTabTitle.BackgroundTransparency = 1
CurrentTabTitle.Font = Enum.Font.GothamBold
CurrentTabTitle.Text = "Авто-Фарм"
CurrentTabTitle.TextColor3 = Color3.fromRGB(240, 245, 255)
CurrentTabTitle.TextSize = 16
CurrentTabTitle.TextXAlignment = Enum.TextXAlignment.Left
CurrentTabTitle.ZIndex = 22
CurrentTabTitle.Parent = Topbar

local ControlsHolder = Instance.new("Frame")
ControlsHolder.Size = UDim2.new(0, 60, 0, 24)
ControlsHolder.Position = UDim2.new(1, -66, 0, 6)
ControlsHolder.BackgroundTransparency = 1
ControlsHolder.ZIndex = 25
ControlsHolder.Parent = Topbar

local ControlsLayout = Instance.new("UIListLayout")
ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ControlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
ControlsLayout.Padding = UDim.new(0, 6)
ControlsLayout.Parent = ControlsHolder

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeButton"
MinimizeBtn.LayoutOrder = 1
MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
MinimizeBtn.BackgroundTransparency = 0.3
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 210, 235)
MinimizeBtn.Font = Enum.Font.GothamMedium
MinimizeBtn.TextSize = 14
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.ZIndex = 26
MinimizeBtn.Parent = ControlsHolder
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseScriptButton"
CloseBtn.LayoutOrder = 2
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.BackgroundColor3 = Color3.fromRGB(55, 22, 28)
CloseBtn.BackgroundTransparency = 0.2
CloseBtn.Text = "x"
CloseBtn.TextColor3 = Color3.fromRGB(255, 110, 120)
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.TextSize = 13
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 26
CloseBtn.Parent = ControlsHolder
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Color = Color3.fromRGB(255, 80, 90)
CloseStroke.Thickness = 1
CloseStroke.Transparency = 0.4
CloseStroke.Parent = CloseBtn

local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, 0, 1, -44)
PagesContainer.Position = UDim2.new(0, 0, 0, 40)
PagesContainer.BackgroundTransparency = 1
PagesContainer.ZIndex = 21
PagesContainer.Parent = ContentArea

-- [6] Window Draggable Implementation (BOUNDED TO SCREEN)
local isDraggingWindow = false
local dragStart, startPosOffset

trackConnection(MainWindow.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingWindow = true
        dragStart = input.Position
        startPosOffset = Vector2.new(MainWindow.AbsolutePosition.X, MainWindow.AbsolutePosition.Y)

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDraggingWindow = false
            end
        end)
    end
end))

trackConnection(UserInputService.InputChanged:Connect(function(input)
    if isDraggingWindow and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        local cam = workspace.CurrentCamera
        local viewport = cam and cam.ViewportSize or Vector2.new(1920, 1080)
        
        local scale = MainScale.Scale
        local winW = MainWindow.AbsoluteSize.X * scale
        local winH = MainWindow.AbsoluteSize.Y * scale
        
        local minX = 0
        local maxX = math.max(0, viewport.X - winW)
        local minY = 0
        local maxY = math.max(0, viewport.Y - winH)

        local targetX = math.clamp(startPosOffset.X + delta.X, minX, maxX)
        local targetY = math.clamp(startPosOffset.Y + delta.Y, minY, maxY)

        MainWindow.Position = UDim2.new(0, targetX, 0, targetY)
    end
end))

-- [7] "Show Hub" Top Capsule
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "SataNet_RayfieldPill"
ToggleGui.DisplayOrder = 999999
ToggleGui.ResetOnSpawn = false
protectGui(ToggleGui)

local Capsule = Instance.new("TextButton")
Capsule.Name = "ShowHubPill"
Capsule.AnchorPoint = Vector2.new(0.5, 0)
Capsule.Size = UDim2.new(0, 136, 0, 30)
Capsule.Position = UDim2.new(0.5, 0, 0, 2)
Capsule.BackgroundColor3 = Color3.fromRGB(16, 17, 24)
Capsule.BackgroundTransparency = 0.12
Capsule.BorderSizePixel = 0
Capsule.AutoButtonColor = false
Capsule.Active = true
Capsule.Text = ""
Capsule.Visible = false
Capsule.ZIndex = 99999
Capsule.Parent = ToggleGui

local CapCorner = Instance.new("UICorner")
CapCorner.CornerRadius = UDim.new(0, 15)
CapCorner.Parent = Capsule

local CapStroke = Instance.new("UIStroke")
CapStroke.Color = Color3.fromRGB(70, 140, 255)
CapStroke.Thickness = 1.4
CapStroke.Transparency = 0.15
CapStroke.Parent = Capsule

local CapIcon = Instance.new("ImageLabel")
CapIcon.Size = UDim2.new(0, 16, 0, 16)
CapIcon.Position = UDim2.new(0, 10, 0.5, -8)
CapIcon.BackgroundTransparency = 1
CapIcon.Image = logoAssetId or "rbxassetid://13837920786"
CapIcon.ImageColor3 = Color3.fromRGB(100, 180, 255)
CapIcon.ScaleType = Enum.ScaleType.Fit
CapIcon.ZIndex = 100000
CapIcon.Parent = Capsule

local CapText = Instance.new("TextLabel")
CapText.Size = UDim2.new(1, -38, 1, 0)
CapText.Position = UDim2.new(0, 30, 0, 0)
CapText.BackgroundTransparency = 1
CapText.Font = Enum.Font.GothamMedium
CapText.Text = "Show Hub"
CapText.TextColor3 = Color3.fromRGB(240, 245, 255)
CapText.TextSize = 12
CapText.TextXAlignment = Enum.TextXAlignment.Left
CapText.ZIndex = 100000
CapText.Parent = Capsule

local isDraggingCap = false
local capTotalDelta = 0

trackConnection(Capsule.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingCap = true
        capTotalDelta = 0
    end
end))

trackConnection(UserInputService.InputChanged:Connect(function(input)
    if isDraggingCap and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        capTotalDelta = capTotalDelta + math.abs(input.Delta.X) + math.abs(input.Delta.Y)
    end
end))

local isWindowOpen = true
local savedWindowPos = MainWindow.Position

local function hideHubWindow()
    if not isWindowOpen then return end
    isWindowOpen = false
    savedWindowPos = MainWindow.Position

    local hideTween = TweenService:Create(MainWindow, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Position = UDim2.new(savedWindowPos.X.Scale, savedWindowPos.X.Offset, 1.2, 0)
    })
    hideTween:Play()
    hideTween.Completed:Connect(function()
        if not isWindowOpen then
            MainWindow.Visible = false
        end
    end)

    Capsule.Position = UDim2.new(0.5, 0, 0, -35)
    Capsule.Visible = true
    TweenService:Create(Capsule, TweenInfo.new(0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0, 2)
    }):Play()
end

local function showHubWindow()
    if isWindowOpen then return end
    isWindowOpen = true

    local pillOut = TweenService:Create(Capsule, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 0, 0, -35)
    })
    pillOut:Play()
    pillOut.Completed:Connect(function()
        if isWindowOpen then
            Capsule.Visible = false
        end
    end)

    MainWindow.Visible = true
    TweenService:Create(MainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = savedWindowPos
    }):Play()
end

local function terminateHubScript()
    _G.HubActive = false
    _G.AutoBlow = false
    _G.AutoSell = false
    _G.AutoHatch = false
    _G.InfJump = false
    _G.SpeedrunUnlocking = false
    _G.AutoCollect = false
    _G.AutoCollectRewards = false
    _G.AutoBuyUpgrades = false
    _G.AutoEquipBest = false
    _G.AutoBuyWorlds = false

    if _G.InfJumpConn then
        pcall(function() _G.InfJumpConn:Disconnect() end)
        _G.InfJumpConn = nil
    end

    for _, conn in ipairs(HubConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(HubConnections)

    pcall(function()
        for _, child in ipairs(workspace:GetChildren()) do
            if child.Name:find("SataNet_SellPlatform_") or child.Name:find("SataNet_PortalPlatform_") then
                pcall(function() child:Destroy() end)
            end
        end
    end)

    pcall(function()
        local services = require(game.ReplicatedStorage.Assets.Modules.Services)
        local guiService = services:GetService("GuiService")
        if guiService and guiService:GetCurrentFrame() == "BubbleFull" then
            guiService:DisplayFrame("")
        end
    end)

    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
    end)

    pcall(function()
        TweenService:Create(MainWindow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(MainWindow.Position.X.Scale, MainWindow.Position.X.Offset, 1.2, 0)
        }):Play()
    end)
    task.wait(0.22)

    pcall(function() MainGui:Destroy() end)
    pcall(function() ToggleGui:Destroy() end)
    print("[SataNet Hub] Script terminated and un-loaded.")
end

MinimizeBtn.MouseButton1Click:Connect(hideHubWindow)
CloseBtn.MouseButton1Click:Connect(terminateHubScript)

trackConnection(Capsule.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if isDraggingCap then
            isDraggingCap = false
            if capTotalDelta < 8 then
                showHubWindow()
            end
        end
    end
end))

trackConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        if isWindowOpen then
            hideHubWindow()
        else
            showHubWindow()
        end
    end
end))

-- Smart Auto-Dismiss & Display for 'BubbleFull' frame
task.spawn(function()
    while _G.HubActive do
        if _G.AutoBlow and _G.AutoSell then
            pcall(function()
                local services = require(game.ReplicatedStorage.Assets.Modules.Services)
                local guiService = services:GetService("GuiService")
                if guiService and guiService:GetCurrentFrame() == "BubbleFull" then
                    guiService:DisplayFrame("")
                end
                
                local lp = LocalPlayer
                local sg = lp and lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("ScreenGui")
                local bf = sg and sg:FindFirstChild("BubbleFull")
                if bf and bf.Visible then
                    bf.Visible = false
                end
            end)
        elseif _G.AutoBlow and not _G.AutoSell then
            pcall(function()
                if isBubble100PercentFull() then
                    local lp = LocalPlayer
                    local sg = lp and lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("ScreenGui")
                    local bf = sg and sg:FindFirstChild("BubbleFull")
                    if bf and not bf.Visible then
                        bf.Visible = true
                    end
                end
            end)
        end
        task.wait(0.2)
    end
end)

-- [8] UI Library Component Engine
local Library = {
    Tabs = {},
    CurrentTab = nil
}

function Library:CreateTab(name, iconId)
    local tabObj = {
        Name = name,
        Page = nil,
        Button = nil
    }

    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = "Tab_" .. name
    TabBtn.Size = UDim2.new(1, 0, 0, 38)
    TabBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
    TabBtn.BackgroundTransparency = 1
    TabBtn.BorderSizePixel = 0
    TabBtn.AutoButtonColor = false
    TabBtn.Text = ""
    TabBtn.ZIndex = 23
    TabBtn.Parent = TabListHolder
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

    local ActiveIndicator = Instance.new("Frame")
    ActiveIndicator.Name = "ActiveIndicator"
    ActiveIndicator.Size = UDim2.new(0, 3, 0, 20)
    ActiveIndicator.Position = UDim2.new(0, 4, 0.5, -10)
    ActiveIndicator.BackgroundColor3 = Color3.fromRGB(70, 150, 255)
    ActiveIndicator.BorderSizePixel = 0
    ActiveIndicator.BackgroundTransparency = 1
    ActiveIndicator.ZIndex = 24
    ActiveIndicator.Parent = TabBtn
    Instance.new("UICorner", ActiveIndicator).CornerRadius = UDim.new(1, 0)

    local TabIcon = Instance.new("ImageLabel")
    TabIcon.Size = UDim2.new(0, 18, 0, 18)
    TabIcon.Position = UDim2.new(0, 14, 0.5, -9)
    TabIcon.BackgroundTransparency = 1
    TabIcon.Image = "rbxassetid://" .. tostring(iconId or 4483362458)
    TabIcon.ImageColor3 = Color3.fromRGB(150, 165, 195)
    TabIcon.ZIndex = 24
    TabIcon.Parent = TabBtn

    local TabLabel = Instance.new("TextLabel")
    TabLabel.Size = UDim2.new(1, -40, 1, 0)
    TabLabel.Position = UDim2.new(0, 38, 0, 0)
    TabLabel.BackgroundTransparency = 1
    TabLabel.Font = Enum.Font.GothamMedium
    TabLabel.Text = name
    TabLabel.TextColor3 = Color3.fromRGB(150, 165, 195)
    TabLabel.TextSize = 13
    TabLabel.TextXAlignment = Enum.TextXAlignment.Left
    TabLabel.ZIndex = 24
    TabLabel.Parent = TabBtn

    local Page = Instance.new("ScrollingFrame")
    Page.Name = "Page_" .. name
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Color3.fromRGB(70, 140, 255)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.ScrollingDirection = Enum.ScrollingDirection.Y
    Page.Visible = false
    Page.ZIndex = 22
    Page.Parent = PagesContainer

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Parent = Page

    local PagePad = Instance.new("UIPadding")
    PagePad.PaddingRight = UDim.new(0, 8)
    PagePad.PaddingBottom = UDim.new(0, 30)
    PagePad.Parent = Page

    tabObj.Page = Page
    tabObj.Button = TabBtn

    local function selectTab()
        for _, t in ipairs(Library.Tabs) do
            t.Page.Visible = false
            TweenService:Create(t.Button, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(t.Button.ActiveIndicator, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            t.Button.TextLabel.TextColor3 = Color3.fromRGB(150, 165, 195)
            t.Button.ImageLabel.ImageColor3 = Color3.fromRGB(150, 165, 195)
        end
        Page.Visible = true
        CurrentTabTitle.Text = name
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2, BackgroundColor3 = Color3.fromRGB(24, 28, 42)}):Play()
        TweenService:Create(ActiveIndicator, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        TabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabIcon.ImageColor3 = Color3.fromRGB(90, 170, 255)
        Library.CurrentTab = tabObj
    end

    TabBtn.MouseButton1Click:Connect(selectTab)

    function tabObj:CreateSection(secTitle)
        local Sec = Instance.new("Frame")
        Sec.Size = UDim2.new(1, 0, 0, 24)
        Sec.BackgroundTransparency = 1
        Sec.ZIndex = 23
        Sec.Parent = Page

        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1, 0, 1, 0)
        Lbl.BackgroundTransparency = 1
        Lbl.Font = Enum.Font.GothamBold
        Lbl.Text = secTitle
        Lbl.TextColor3 = Color3.fromRGB(90, 160, 255)
        Lbl.TextSize = 13
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.ZIndex = 24
        Lbl.Parent = Sec
    end

    function tabObj:CreateToggle(opts, customParent)
        local parentTarget = customParent or Page
        local toggled = (opts.Default == true)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, opts.Compact and 36 or 44)
        card.BackgroundColor3 = opts.Compact and Color3.fromRGB(22, 25, 36) or Color3.fromRGB(18, 20, 28)
        card.BackgroundTransparency = 0.25
        card.BorderSizePixel = 0
        card.ZIndex = 23
        card.Parent = parentTarget
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(50, 60, 85)
        stroke.Transparency = 0.6
        stroke.Parent = card

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -70, 1, 0)
        title.Position = UDim2.new(0, 12, 0, 0)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamMedium
        title.Text = opts.Name
        title.TextColor3 = Color3.fromRGB(240, 245, 255)
        title.TextSize = opts.Compact and 12 or 13
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 24
        title.Parent = card

        local switch = Instance.new("Frame")
        switch.Size = UDim2.new(0, 38, 0, 20)
        switch.Position = UDim2.new(1, -50, 0.5, -10)
        switch.BackgroundColor3 = toggled and Color3.fromRGB(60, 140, 255) or Color3.fromRGB(35, 38, 52)
        switch.BorderSizePixel = 0
        switch.ZIndex = 24
        switch.Parent = card
        Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = toggled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.ZIndex = 25
        knob.Parent = switch
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local clickBtn = Instance.new("TextButton")
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""
        clickBtn.ZIndex = 26
        clickBtn.Parent = card

        local function updateToggleState(val)
            toggled = val
            TweenService:Create(switch, TweenInfo.new(0.2), {
                BackgroundColor3 = toggled and Color3.fromRGB(60, 140, 255) or Color3.fromRGB(35, 38, 52)
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {
                Position = toggled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            }):Play()
            if opts.Callback then opts.Callback(toggled) end
        end

        clickBtn.MouseButton1Click:Connect(function()
            updateToggleState(not toggled)
        end)

        return {Card = card, SetState = updateToggleState}
    end

    function tabObj:CreateSlider(opts, customParent)
        local parentTarget = customParent or Page
        local currentVal = opts.Default or opts.Min
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, opts.Compact and 48 or 52)
        card.BackgroundColor3 = opts.Compact and Color3.fromRGB(22, 25, 36) or Color3.fromRGB(18, 20, 28)
        card.BackgroundTransparency = 0.25
        card.BorderSizePixel = 0
        card.ZIndex = 23
        card.Parent = parentTarget
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -80, 0, 22)
        title.Position = UDim2.new(0, 12, 0, 4)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamMedium
        title.Text = opts.Name
        title.TextColor3 = Color3.fromRGB(240, 245, 255)
        title.TextSize = 12
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 24
        title.Parent = card

        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0, 60, 0, 22)
        valLbl.Position = UDim2.new(1, -72, 0, 4)
        valLbl.BackgroundTransparency = 1
        valLbl.Font = Enum.Font.GothamBold
        valLbl.Text = tostring(currentVal) .. (opts.Suffix or "")
        valLbl.TextColor3 = Color3.fromRGB(90, 170, 255)
        valLbl.TextSize = 12
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.ZIndex = 24
        valLbl.Parent = card

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -24, 0, 6)
        track.Position = UDim2.new(0, 12, 0, opts.Compact and 30 or 34)
        track.BackgroundColor3 = Color3.fromRGB(35, 38, 52)
        track.BorderSizePixel = 0
        track.ZIndex = 24
        track.Parent = card
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame")
        local initPercent = math.clamp((currentVal - opts.Min) / (opts.Max - opts.Min), 0, 1)
        fill.Size = UDim2.new(initPercent, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(70, 150, 255)
        fill.BorderSizePixel = 0
        fill.ZIndex = 25
        fill.Parent = track
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local dragging = false
        local function updateSlider(input)
            local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local val = math.floor(opts.Min + (opts.Max - opts.Min) * percent)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            valLbl.Text = tostring(val) .. (opts.Suffix or "")
            if opts.Callback then opts.Callback(val) end
        end

        card.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateSlider(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        return {Card = card, SetValue = function(val)
            local percent = math.clamp((val - opts.Min) / (opts.Max - opts.Min), 0, 1)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            valLbl.Text = tostring(val) .. (opts.Suffix or "")
            if opts.Callback then opts.Callback(val) end
        end}
    end

    function tabObj:CreateButton(opts, customParent)
        local parentTarget = customParent or Page
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, opts.Compact and 32 or 38)
        btn.BackgroundColor3 = opts.Danger and Color3.fromRGB(45, 22, 28) or (opts.Highlight and Color3.fromRGB(25, 55, 100) or Color3.fromRGB(24, 28, 42))
        btn.BackgroundTransparency = 0.2
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Text = ""
        btn.ZIndex = 23
        btn.Parent = parentTarget
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local stroke = Instance.new("UIStroke")
        stroke.Color = opts.Danger and Color3.fromRGB(255, 80, 90) or (opts.Highlight and Color3.fromRGB(90, 170, 255) or Color3.fromRGB(70, 140, 255))
        stroke.Thickness = opts.Highlight and 1.4 or 1
        stroke.Transparency = opts.Highlight and 0.2 or 0.5
        stroke.Parent = btn

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -24, 1, 0)
        title.Position = UDim2.new(0, 12, 0, 0)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold
        title.Text = opts.Name
        title.TextColor3 = opts.Danger and Color3.fromRGB(255, 130, 140) or (opts.Highlight and Color3.fromRGB(130, 200, 255) or Color3.fromRGB(240, 245, 255))
        title.TextSize = opts.Compact and 12 or 13
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 24
        title.Parent = btn

        btn.MouseButton1Click:Connect(function()
            local highlightColor = opts.Danger and Color3.fromRGB(220, 50, 65) or Color3.fromRGB(60, 140, 255)
            local normalColor = opts.Danger and Color3.fromRGB(45, 22, 28) or (opts.Highlight and Color3.fromRGB(25, 55, 100) or Color3.fromRGB(24, 28, 42))
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = highlightColor}):Play()
            task.delay(0.1, function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = normalColor}):Play()
            end)
            if opts.Callback then opts.Callback(btn, title) end
        end)
        return {Button = btn, Title = title}
    end

    function tabObj:CreateDropdown(opts, customParent)
        local parentTarget = customParent or Page
        local selected = opts.Default or opts.Options[1]
        local isExpanded = false

        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 42)
        card.BackgroundColor3 = opts.Compact and Color3.fromRGB(22, 25, 36) or Color3.fromRGB(18, 20, 28)
        card.BackgroundTransparency = 0.25
        card.BorderSizePixel = 0
        card.ClipsDescendants = true
        card.ZIndex = 23
        card.Parent = parentTarget
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

        local headerRow = Instance.new("Frame")
        headerRow.Size = UDim2.new(1, 0, 0, 42)
        headerRow.BackgroundTransparency = 1
        headerRow.ZIndex = 24
        headerRow.Parent = card

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(0, 110, 1, 0)
        title.Position = UDim2.new(0, 12, 0, 0)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamMedium
        title.Text = opts.Name
        title.TextColor3 = Color3.fromRGB(200, 210, 230)
        title.TextSize = 12
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 25
        title.Parent = headerRow

        local dropVal = Instance.new("TextLabel")
        dropVal.Name = "DropValLabel"
        dropVal.Size = UDim2.new(1, -130, 1, 0)
        dropVal.Position = UDim2.new(0, 120, 0, 0)
        dropVal.BackgroundTransparency = 1
        dropVal.Font = Enum.Font.GothamBold
        dropVal.Text = tostring(selected) .. "  ▼"
        dropVal.TextColor3 = Color3.fromRGB(90, 170, 255)
        dropVal.TextSize = 11
        dropVal.TextXAlignment = Enum.TextXAlignment.Right
        dropVal.TextTruncate = Enum.TextTruncate.AtEnd
        dropVal.ZIndex = 25
        dropVal.Parent = headerRow

        local listScroll = Instance.new("ScrollingFrame")
        listScroll.Size = UDim2.new(1, -20, 0, math.min(#opts.Options * 28, 160))
        listScroll.Position = UDim2.new(0, 10, 0, 44)
        listScroll.BackgroundTransparency = 1
        listScroll.BorderSizePixel = 0
        listScroll.ScrollBarThickness = 3
        listScroll.ScrollBarImageColor3 = Color3.fromRGB(70, 140, 255)
        listScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        listScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        listScroll.ScrollingDirection = Enum.ScrollingDirection.Y
        listScroll.ZIndex = 26
        listScroll.Parent = card

        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 4)
        listLayout.Parent = listScroll

        for _, opt in ipairs(opts.Options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, -6, 0, 26)
            optBtn.BackgroundColor3 = Color3.fromRGB(28, 32, 46)
            optBtn.BorderSizePixel = 0
            optBtn.Font = Enum.Font.Gotham
            optBtn.Text = "  " .. opt
            optBtn.TextColor3 = Color3.fromRGB(210, 220, 245)
            optBtn.TextSize = 11
            optBtn.TextXAlignment = Enum.TextXAlignment.Left
            optBtn.TextTruncate = Enum.TextTruncate.AtEnd
            optBtn.ZIndex = 27
            optBtn.Parent = listScroll
            Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 6)

            optBtn.MouseButton1Click:Connect(function()
                selected = opt
                dropVal.Text = tostring(selected) .. "  ▼"
                isExpanded = false
                TweenService:Create(card, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 42)}):Play()
                if opts.Callback then opts.Callback(opt) end
            end)
        end

        local toggleDrop = Instance.new("TextButton")
        toggleDrop.Size = UDim2.new(1, 0, 0, 42)
        toggleDrop.BackgroundTransparency = 1
        toggleDrop.Text = ""
        toggleDrop.ZIndex = 26
        toggleDrop.Parent = headerRow

        toggleDrop.MouseButton1Click:Connect(function()
            isExpanded = not isExpanded
            local scrollHeight = math.min(#opts.Options * 28 + 6, 160)
            local targetH = isExpanded and (48 + scrollHeight) or 42
            dropVal.Text = tostring(selected) .. (isExpanded and "  ▲" or "  ▼")
            TweenService:Create(card, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, targetH)}):Play()
        end)

        return {Card = card, DropLabel = dropVal, SetOption = function(opt)
            selected = opt
            dropVal.Text = tostring(selected) .. "  ▼"
            if opts.Callback then opts.Callback(opt) end
        end}
    end

    function tabObj:CreateCollapsibleCard(opts, customParent)
        local parentTarget = customParent or Page
        local isExpanded = opts.DefaultExpanded or false
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 46)
        card.AutomaticSize = isExpanded and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
        card.BackgroundColor3 = opts.SubCard and Color3.fromRGB(22, 25, 36) or Color3.fromRGB(16, 18, 26)
        card.BackgroundTransparency = 0.2
        card.BorderSizePixel = 0
        card.ClipsDescendants = not isExpanded
        card.ZIndex = 23
        card.Parent = parentTarget
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(70, 140, 255)
        stroke.Thickness = opts.SubCard and 1 or 1.2
        stroke.Transparency = opts.SubCard and 0.6 or 0.4
        stroke.Parent = card

        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 46)
        header.BackgroundTransparency = 1
        header.ZIndex = 24
        header.Parent = card

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, opts.HasMaster ~= false and -110 or -40, 1, 0)
        title.Position = UDim2.new(0, 14, 0, 0)
        title.BackgroundTransparency = 1
        title.Font = opts.SubCard and Enum.Font.GothamMedium or Enum.Font.GothamBold
        title.Text = opts.Name
        title.TextColor3 = Color3.fromRGB(240, 245, 255)
        title.TextSize = opts.SubCard and 12 or 13
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 25
        title.Parent = header

        local expandIcon = Instance.new("TextLabel")
        expandIcon.Size = UDim2.new(0, 26, 0, 26)
        expandIcon.Position = UDim2.new(1, opts.HasMaster ~= false and -94 or -34, 0.5, -13)
        expandIcon.BackgroundTransparency = 1
        expandIcon.Font = Enum.Font.GothamBold
        expandIcon.Text = isExpanded and "▲" or "▼"
        expandIcon.TextColor3 = Color3.fromRGB(100, 170, 255)
        expandIcon.TextSize = 11
        expandIcon.ZIndex = 25
        expandIcon.Parent = header

        local masterSwitchObj = nil
        if opts.HasMaster ~= false then
            local masterDefaultVal = (opts.MasterDefault == true)
            local masterSwitch = Instance.new("Frame")
            masterSwitch.Size = UDim2.new(0, 42, 0, 22)
            masterSwitch.Position = UDim2.new(1, -54, 0.5, -11)
            masterSwitch.BackgroundColor3 = masterDefaultVal and Color3.fromRGB(60, 140, 255) or Color3.fromRGB(35, 38, 52)
            masterSwitch.BorderSizePixel = 0
            masterSwitch.ZIndex = 25
            masterSwitch.Parent = header
            Instance.new("UICorner", masterSwitch).CornerRadius = UDim.new(1, 0)

            local masterKnob = Instance.new("Frame")
            masterKnob.Size = UDim2.new(0, 16, 0, 16)
            masterKnob.Position = masterDefaultVal and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            masterKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            masterKnob.BorderSizePixel = 0
            masterKnob.ZIndex = 26
            masterKnob.Parent = masterSwitch
            Instance.new("UICorner", masterKnob).CornerRadius = UDim.new(1, 0)

            local masterClick = Instance.new("TextButton")
            masterClick.Size = UDim2.new(0, 42, 0, 22)
            masterClick.Position = UDim2.new(1, -54, 0.5, -11)
            masterClick.BackgroundTransparency = 1
            masterClick.Text = ""
            masterClick.ZIndex = 27
            masterClick.Parent = header

            local isMasterOn = masterDefaultVal
            local function setMasterState(val)
                isMasterOn = val
                TweenService:Create(masterSwitch, TweenInfo.new(0.2), {
                    BackgroundColor3 = isMasterOn and Color3.fromRGB(60, 140, 255) or Color3.fromRGB(35, 38, 52)
                }):Play()
                TweenService:Create(masterKnob, TweenInfo.new(0.2), {
                    Position = isMasterOn and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                }):Play()
                if opts.OnMasterToggle then opts.OnMasterToggle(isMasterOn) end
            end

            masterClick.MouseButton1Click:Connect(function()
                setMasterState(not isMasterOn)
            end)

            masterSwitchObj = {SetState = setMasterState}
        end

        local headerClick = Instance.new("TextButton")
        headerClick.Size = UDim2.new(1, opts.HasMaster ~= false and -60 or -10, 1, 0)
        headerClick.BackgroundTransparency = 1
        headerClick.Text = ""
        headerClick.ZIndex = 26
        headerClick.Parent = header

        local innerContainer = Instance.new("Frame")
        innerContainer.Size = UDim2.new(1, -20, 0, 0)
        innerContainer.Position = UDim2.new(0, 10, 0, 48)
        innerContainer.BackgroundTransparency = 1
        innerContainer.AutomaticSize = Enum.AutomaticSize.Y
        innerContainer.Visible = isExpanded
        innerContainer.ZIndex = 24
        innerContainer.Parent = card

        local innerLayout = Instance.new("UIListLayout")
        innerLayout.Padding = UDim.new(0, 6)
        innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        innerLayout.Parent = innerContainer

        local innerPad = Instance.new("UIPadding")
        innerPad.PaddingBottom = UDim.new(0, 10)
        innerPad.Parent = innerContainer

        local function toggleExpand()
            isExpanded = not isExpanded
            expandIcon.Text = isExpanded and "▲" or "▼"
            innerContainer.Visible = isExpanded
            card.ClipsDescendants = not isExpanded
            card.AutomaticSize = isExpanded and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
            if not isExpanded then
                card.Size = UDim2.new(1, 0, 0, 46)
            end
        end

        headerClick.MouseButton1Click:Connect(toggleExpand)

        return innerContainer, masterSwitchObj
    end

    table.insert(Library.Tabs, tabObj)
    if #Library.Tabs == 1 then
        selectTab()
    end

    return tabObj
end

-- [9] Setup BGS Hub Tabs
local TabFarm = Library:CreateTab("Авто-Фарм", 4483362458)
local TabShops = Library:CreateTab("Магазины & Апгрейды", 4483362458)
local TabEggs = Library:CreateTab("Яйца & Питомцы", 4483362458)
local TabPlayer = Library:CreateTab("Игрок", 4483362458)
local TabTeleport = Library:CreateTab("Телепорты & Миры", 4483362458)
local TabSettings = Library:CreateTab("Настройки", 4483362458)

-- =======================================================
-- TAB 1: АВТО-ФАРМ
-- =======================================================
TabFarm:CreateSection("🌟 Авто-сбор ресурсов и наград")

local masterCollectCard, masterCollectSwitch = TabFarm:CreateCollapsibleCard({
    Name = "⚡ 100% Авто-сбор ресурсов (Coins, Gems, XP)",
    MasterDefault = _G.AutoCollect == true,
    DefaultExpanded = false,
    OnMasterToggle = function(val)
        _G.AutoCollect = val
        saveConfigToFile()
    end
})

-- EXPLICIT TOGGLE FOR RETURN TO ORIGINAL POSITION IN AUTO-COLLECT (DEFAULT OFF)
TabFarm:CreateToggle({
    Name = "📍 Возвращаться на исходную позицию после сбора ресурсов",
    Default = _G.ReturnToCollectPos == true,
    Compact = true,
    Callback = function(val)
        _G.ReturnToCollectPos = val
        saveConfigToFile()
    end
}, masterCollectCard)



local worldSubCard = TabFarm:CreateCollapsibleCard({
    Name = "🌐 Выбор миров (ограничить сбор только включенными мирами)",
    HasMaster = false,
    SubCard = true,
    DefaultExpanded = false
}, masterCollectCard)

local worldToggles = {
    {key = "Overworld", label = "🏠 Overworld (Спавн)"},
    {key = "Event World", label = "👽 Event World (Ивент Мир Пришельцев)"},
    {key = "Candy Land", label = "🍭 Candy Land"},
    {key = "Atlantis", label = "🔱 Atlantis"},
    {key = "Toy Land", label = "🧸 Toy Land"},
    {key = "Beach World", label = "🏖 Beach World"},
    {key = "Rainbow Land", label = "🌈 Rainbow Land"},
    {key = "Underworld", label = "🔥 Underworld"},
    {key = "Mystic Forest", label = "🌲 Mystic Forest"},
    {key = "Heaven", label = "☁ Heaven"}
}

for _, wt in ipairs(worldToggles) do
    TabFarm:CreateToggle({
        Name = wt.label,
        Default = _G.CollectWorlds and _G.CollectWorlds[wt.key] == true,
        Compact = true,
        Callback = function(val)
            _G.CollectWorlds[wt.key] = val
            saveConfigToFile()
        end
    }, worldSubCard)
end

TabFarm:CreateSlider({
    Name = "Задержка между сбором (Collect Delay)",
    Min = 10,
    Max = 3000,
    Default = math.floor((_G.CollectDelay or 0.04) * 1000),
    Suffix = " ms",
    Compact = true,
    Callback = function(val)
        _G.CollectDelay = val / 1000
        saveConfigToFile()
    end
}, masterCollectCard)

TabFarm:CreateToggle({
    Name = "🎁 Авто-сбор готовых сундуков и наград (Auto Chests)",
    Default = _G.AutoCollectRewards or false,
    Callback = function(val)
        _G.AutoCollectRewards = val
        saveConfigToFile()
    end
})

TabFarm:CreateSection("⚡ Надувание и Умная продажа")

TabFarm:CreateToggle({
    Name = "⚡ Авто-надувание (Turbo Blow)",
    Default = _G.AutoBlow or false,
    Callback = function(val)
        _G.AutoBlow = val
        saveConfigToFile()
    end
})

local sellContainer = TabFarm:CreateCollapsibleCard({
    Name = "💰 Авто-продажа (Auto Sell)",
    MasterDefault = _G.AutoSell or false,
    DefaultExpanded = false,
    OnMasterToggle = function(val)
        _G.AutoSell = val
        saveConfigToFile()
        if val and isBubble100PercentFull() then
            task.spawn(performSmartSell)
        end
    end
})

TabFarm:CreateSlider({
    Name = "Интервал продажи (Кулдаун)",
    Min = 1,
    Max = 10,
    Default = math.floor(_G.SellCooldown or 3),
    Suffix = " сек",
    Compact = true,
    Callback = function(val)
        _G.SellCooldown = val
        saveConfigToFile()
    end
}, sellContainer)

local sellDropdownObj = TabFarm:CreateDropdown({
    Name = "Точка продажи",
    Options = {
        "🌟 Авто локация (Автоматический выбор лучшего 2x - 25x)",
        "☁ Heaven World (25x Multiplier)",
        "🔥 Underworld (20x Multiplier)",
        "🌲 Mystic Forest (10x Multiplier)",
        "🔱 Atlantis (8x Multiplier)",
        "🏖 Beach World (6x Multiplier)",
        "🍭 Candy Land (4x Multiplier)",
        "🌙 The Twilight (2x - 11,378m)",
        "🏠 Спавн: Overworld Sell (1x Стандарт)"
    },
    Default = _G.SelectedSellMode or "🌟 Авто локация (Автоматический выбор лучшего 2x - 25x)",
    Compact = true,
    Callback = function(opt)
        _G.SelectedSellMode = opt
        saveConfigToFile()
    end
}, sellContainer)

task.spawn(function()
    while _G.HubActive do
        if sellDropdownObj and sellDropdownObj.DropLabel and (_G.SelectedSellMode:find("Авто") or _G.SelectedSellMode:find("авто")) then
            pcall(function()
                local best = getBestUnlockedSellLocation()
                if best and best.name then
                    sellDropdownObj.DropLabel.Text = "🌟 Авто: " .. best.name .. "  ▼"
                end
            end)
        end
        task.wait(3.0)
    end
end)

TabFarm:CreateToggle({
    Name = "Возвращаться на место фарма после продажи",
    Default = _G.ReturnToFarmPos == true,
    Compact = true,
    Callback = function(val)
        _G.ReturnToFarmPos = val
        saveConfigToFile()
    end
}, sellContainer)

-- TAB 2: МАГАЗИНЫ & АПГРЕЙДЫ
TabShops:CreateSection("⚡ Авто-экипировка (Auto Equip Best)")

local equipContainer = TabShops:CreateCollapsibleCard({
    Name = "✨ Авто-одевание лучшего предмета",
    MasterDefault = _G.AutoEquipBest or false,
    DefaultExpanded = false,
    OnMasterToggle = function(val)
        _G.AutoEquipBest = val
        saveConfigToFile()
    end
})

TabShops:CreateToggle({
    Name = "🎈 Gum (Лучшая жвачка)",
    Default = _G.AutoEquipGum ~= false,
    Compact = true,
    Callback = function(val)
        _G.AutoEquipGum = val
        saveConfigToFile()
    end
}, equipContainer)

TabShops:CreateToggle({
    Name = "🍬 Flavors (Лучший вкус)",
    Default = _G.AutoEquipFlavors ~= false,
    Compact = true,
    Callback = function(val)
        _G.AutoEquipFlavors = val
        saveConfigToFile()
    end
}, equipContainer)

TabShops:CreateToggle({
    Name = "😄 Faces (Лучшее лицо)",
    Default = _G.AutoEquipFaces ~= false,
    Compact = true,
    Callback = function(val)
        _G.AutoEquipFaces = val
        saveConfigToFile()
    end
}, equipContainer)

TabShops:CreateSection("🛒 Авто-покупка (Pure Auto Buy)")

local upgradeContainer = TabShops:CreateCollapsibleCard({
    Name = "💰 Авто-покупка следующего улучшения",
    MasterDefault = _G.AutoBuyUpgrades or false,
    DefaultExpanded = false,
    OnMasterToggle = function(val)
        _G.AutoBuyUpgrades = val
        saveConfigToFile()
    end
})

TabShops:CreateToggle({
    Name = "🎈 Gum (Вместимость жвачки)",
    Default = _G.UpgradeGum ~= false,
    Compact = true,
    Callback = function(val)
        _G.UpgradeGum = val
        saveConfigToFile()
    end
}, upgradeContainer)

TabShops:CreateToggle({
    Name = "🍬 Flavors (Вкусы жвачки)",
    Default = _G.UpgradeFlavors ~= false,
    Compact = true,
    Callback = function(val)
        _G.UpgradeFlavors = val
        saveConfigToFile()
    end
}, upgradeContainer)

TabShops:CreateToggle({
    Name = "😄 Faces (Лица и Множители)",
    Default = _G.UpgradeFaces ~= false,
    Compact = true,
    Callback = function(val)
        _G.UpgradeFaces = val
        saveConfigToFile()
    end
}, upgradeContainer)

-- TAB 3: ЯЙЦА & ПИТОМЦЫ
TabEggs:CreateSection("🥚 Авто-открытие яиц")

TabEggs:CreateToggle({
    Name = "⚡ Авто-открытие выбранного яйца (Авто-Телепортация включена)",
    Default = _G.AutoHatch or false,
    Callback = function(val)
        _G.AutoHatch = val
        saveConfigToFile()
    end
})

TabEggs:CreateButton({
    Name = "📍 Телепортироваться к выбранному яйцу прямо сейчас",
    Highlight = true,
    Callback = function(btn, title)
        if not _G.SelectedEgg or _G.SelectedEgg == "" or _G.SelectedEgg:find("Выберите") then
            title.Text = "⚠️ Сначала выберите яйцо в списке ниже!"
            task.delay(2.5, function()
                title.Text = "📍 Телепортироваться к выбранному яйцу прямо сейчас"
            end)
            return
        end
        title.Text = "⏳ Телепортация к яйцу: " .. tostring(_G.SelectedEgg) .. "..."
        local ok = teleportToEggByName(_G.SelectedEgg)
        task.delay(0.5, function()
            if ok then
                title.Text = "✅ ТЕЛЕПОРТИРОВАН К " .. tostring(_G.SelectedEgg) .. "!"
            else
                title.Text = "⚠️ Яйцо " .. tostring(_G.SelectedEgg) .. " не найдено!"
            end
            task.delay(2.5, function()
                title.Text = "📍 Телепортироваться к выбранному яйцу прямо сейчас"
            end)
        end)
    end
})

TabEggs:CreateDropdown({
    Name = "Количество открытий",
    Options = {
        "1x Яйцо (Стандарт)",
        "3x Яйца (Мульти-открытие)"
    },
    Default = (_G.HatchAmount == 3) and "3x Яйца (Мульти-открытие)" or "1x Яйцо (Стандарт)",
    Compact = true,
    Callback = function(opt)
        if opt:find("3x") then _G.HatchAmount = 3
        else _G.HatchAmount = 1
        end
        saveConfigToFile()
    end
})

TabEggs:CreateSection("🔔 Discord Webhook на выпавших питомцев")

TabEggs:CreateToggle({
    Name = "🔔 Включить Discord Webhook уведомления",
    Default = _G.PetWebhookEnabled or false,
    Callback = function(val)
        _G.PetWebhookEnabled = val
        saveConfigToFile()
    end
})

-- Webhook Input Box Card
local wbCard = Instance.new("Frame")
wbCard.Size = UDim2.new(1, 0, 0, 78)
wbCard.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
wbCard.BackgroundTransparency = 0.25
wbCard.BorderSizePixel = 0
wbCard.ZIndex = 23
wbCard.Parent = TabEggs.Page
Instance.new("UICorner", wbCard).CornerRadius = UDim.new(0, 8)

local wbStroke = Instance.new("UIStroke")
wbStroke.Color = Color3.fromRGB(70, 140, 255)
wbStroke.Thickness = 1
wbStroke.Transparency = 0.5
wbStroke.Parent = wbCard

local wbInputFrame = Instance.new("Frame")
wbInputFrame.Size = UDim2.new(1, -20, 0, 30)
wbInputFrame.Position = UDim2.new(0, 10, 0, 8)
wbInputFrame.BackgroundColor3 = Color3.fromRGB(26, 30, 44)
wbInputFrame.BorderSizePixel = 0
wbInputFrame.ZIndex = 24
wbInputFrame.Parent = wbCard
Instance.new("UICorner", wbInputFrame).CornerRadius = UDim.new(0, 6)

local wbBox = Instance.new("TextBox")
wbBox.Size = UDim2.new(1, -16, 1, 0)
wbBox.Position = UDim2.new(0, 8, 0, 0)
wbBox.BackgroundTransparency = 1
wbBox.Font = Enum.Font.GothamMedium
wbBox.PlaceholderText = "Вставьте Discord Webhook URL (https://discord.com/api/webhooks/...)..."
wbBox.PlaceholderColor3 = Color3.fromRGB(120, 135, 165)
wbBox.Text = _G.PetWebhookUrl or ""
wbBox.TextColor3 = Color3.fromRGB(255, 255, 255)
wbBox.TextSize = 11
wbBox.TextXAlignment = Enum.TextXAlignment.Left
wbBox.ZIndex = 25
wbBox.Parent = wbInputFrame

wbBox.FocusLost:Connect(function()
    _G.PetWebhookUrl = wbBox.Text
    saveConfigToFile()
end)

local testWbBtn = Instance.new("TextButton")
testWbBtn.Size = UDim2.new(1, -20, 0, 28)
testWbBtn.Position = UDim2.new(0, 10, 0, 44)
testWbBtn.BackgroundColor3 = Color3.fromRGB(30, 75, 140)
testWbBtn.BorderSizePixel = 0
testWbBtn.Font = Enum.Font.GothamBold
testWbBtn.Text = "🧪 Отправить тестовый Webhook"
testWbBtn.TextColor3 = Color3.fromRGB(240, 245, 255)
testWbBtn.TextSize = 12
testWbBtn.ZIndex = 24
testWbBtn.Parent = wbCard
Instance.new("UICorner", testWbBtn).CornerRadius = UDim.new(0, 6)

testWbBtn.MouseButton1Click:Connect(function()
    _G.PetWebhookUrl = wbBox.Text
    if _G.PetWebhookUrl and _G.PetWebhookUrl:find("http") then
        testWbBtn.Text = "⏳ Отправка тестового уведомления..."
        sendPetWebhook(_G.PetWebhookUrl, "King Doggy", "Common Egg", true, false)
        task.delay(1.5, function()
            testWbBtn.Text = "✅ ТЕСТОВЫЙ WEBHOOK УСПЕШНО ОТПРАВЛЕН!"
            task.delay(2.5, function()
                testWbBtn.Text = "🧪 Отправить тестовый Webhook"
            end)
        end)
    else
        testWbBtn.Text = "⚠️ Введите корректный Webhook URL!"
        task.delay(2.5, function()
            testWbBtn.Text = "🧪 Отправить тестовый Webhook"
        end)
    end
end)

-- RARITY SELECTION CARD
TabEggs:CreateSection("⭐ Настройка фильтра редкостей для Webhook")

local rarityCard = Instance.new("Frame")
rarityCard.Size = UDim2.new(1, 0, 0, 76)
rarityCard.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
rarityCard.BackgroundTransparency = 0.25
rarityCard.BorderSizePixel = 0
rarityCard.ZIndex = 23
rarityCard.Parent = TabEggs.Page
Instance.new("UICorner", rarityCard).CornerRadius = UDim.new(0, 10)

local rarityStroke = Instance.new("UIStroke")
rarityStroke.Color = Color3.fromRGB(70, 140, 255)
rarityStroke.Thickness = 1.2
rarityStroke.Transparency = 0.4
rarityStroke.Parent = rarityCard

local rarityTitle = Instance.new("TextLabel")
rarityTitle.Size = UDim2.new(1, -20, 0, 22)
rarityTitle.Position = UDim2.new(0, 10, 0, 6)
rarityTitle.BackgroundTransparency = 1
rarityTitle.Font = Enum.Font.GothamBold
rarityTitle.Text = "⭐ Минимальная редкость петов для уведомления"
rarityTitle.TextColor3 = Color3.fromRGB(240, 245, 255)
rarityTitle.TextSize = 12
rarityTitle.TextXAlignment = Enum.TextXAlignment.Left
rarityTitle.ZIndex = 24
rarityTitle.Parent = rarityCard

local badgeHolder = Instance.new("Frame")
badgeHolder.Size = UDim2.new(1, -20, 0, 36)
badgeHolder.Position = UDim2.new(0, 10, 0, 32)
badgeHolder.BackgroundTransparency = 1
badgeHolder.ZIndex = 24
badgeHolder.Parent = rarityCard

local badgeLayout = Instance.new("UIListLayout")
badgeLayout.FillDirection = Enum.FillDirection.Horizontal
badgeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
badgeLayout.SortOrder = Enum.SortOrder.LayoutOrder
badgeLayout.Padding = UDim.new(0, 6)
badgeLayout.Parent = badgeHolder

local RARITY_TIERS = {
    {key = "All Pets", name = "⚪ Все", activeBg = Color3.fromRGB(60, 65, 80), activeText = Color3.fromRGB(255, 255, 255)},
    {key = "Rare+", name = "🔵 Rare+", activeBg = Color3.fromRGB(30, 80, 180), activeText = Color3.fromRGB(255, 255, 255)},
    {key = "Epic+", name = "💜 Epic+", activeBg = Color3.fromRGB(130, 50, 190), activeText = Color3.fromRGB(255, 255, 255)},
    {key = "Legendary+", name = "🟡 Legend+", activeBg = Color3.fromRGB(200, 150, 20), activeText = Color3.fromRGB(255, 255, 255)},
    {key = "Secret Only", name = "💖 Secret", activeBg = Color3.fromRGB(190, 40, 130), activeText = Color3.fromRGB(255, 255, 255)}
}

local badgeBtnsMap = {}

for idx, tier in ipairs(RARITY_TIERS) do
    local isSelected = (_G.WebhookRarityFilter == tier.key) or (idx == 1 and not _G.WebhookRarityFilter)

    local bBtn = Instance.new("TextButton")
    bBtn.Name = "Badge_" .. tier.key
    bBtn.Size = UDim2.new(0.188, 0, 1, 0)
    bBtn.BackgroundColor3 = isSelected and tier.activeBg or Color3.fromRGB(26, 30, 44)
    bBtn.BorderSizePixel = 0
    bBtn.Font = Enum.Font.GothamBold
    bBtn.Text = tier.name
    bBtn.TextColor3 = isSelected and tier.activeText or Color3.fromRGB(160, 175, 200)
    bBtn.TextSize = 11
    bBtn.ZIndex = 25
    bBtn.Parent = badgeHolder
    Instance.new("UICorner", bBtn).CornerRadius = UDim.new(0, 8)

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = isSelected and tier.activeBg or Color3.fromRGB(50, 60, 85)
    bStroke.Thickness = isSelected and 1.6 or 1
    bStroke.Transparency = isSelected and 0 or 0.6
    bStroke.Parent = bBtn

    bBtn.MouseButton1Click:Connect(function()
        _G.WebhookRarityFilter = tier.key
        saveConfigToFile()
        for tKey, bObj in pairs(badgeBtnsMap) do
            local tData = bObj.data
            local sel = (tKey == tier.key)
            TweenService:Create(bObj.btn, TweenInfo.new(0.2), {
                BackgroundColor3 = sel and tData.activeBg or Color3.fromRGB(26, 30, 44),
                TextColor3 = sel and tData.activeText or Color3.fromRGB(160, 175, 200)
            }):Play()
            bObj.stroke.Color = sel and tData.activeBg or Color3.fromRGB(50, 60, 85)
            bObj.stroke.Thickness = sel and 1.6 or 1
            bObj.stroke.Transparency = sel and 0 or 0.6
        end
    end)

    badgeBtnsMap[tier.key] = {btn = bBtn, stroke = bStroke, data = tier}
end

-- Searchable Egg Container
local eggSelectCard = Instance.new("Frame")
eggSelectCard.Size = UDim2.new(1, 0, 0, 220)
eggSelectCard.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
eggSelectCard.BackgroundTransparency = 0.25
eggSelectCard.BorderSizePixel = 0
eggSelectCard.ZIndex = 23
eggSelectCard.Parent = TabEggs.Page
Instance.new("UICorner", eggSelectCard).CornerRadius = UDim.new(0, 10)

local eggStroke = Instance.new("UIStroke")
eggStroke.Color = Color3.fromRGB(70, 140, 255)
eggStroke.Thickness = 1.2
eggStroke.Transparency = 0.4
eggStroke.Parent = eggSelectCard

local eggHeaderLabel = Instance.new("TextLabel")
eggHeaderLabel.Size = UDim2.new(1, -20, 0, 24)
eggHeaderLabel.Position = UDim2.new(0, 10, 0, 8)
eggHeaderLabel.BackgroundTransparency = 1
eggHeaderLabel.Font = Enum.Font.GothamBold
eggHeaderLabel.Text = _G.SelectedEgg and ("🥚 Выбор яйца: " .. _G.SelectedEgg) or "🥚 Выберите яйцо для открытия..."
eggHeaderLabel.TextColor3 = Color3.fromRGB(240, 245, 255)
eggHeaderLabel.TextSize = 13
eggHeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
eggHeaderLabel.ZIndex = 24
eggHeaderLabel.Parent = eggSelectCard

local searchBoxFrame = Instance.new("Frame")
searchBoxFrame.Size = UDim2.new(1, -20, 0, 32)
searchBoxFrame.Position = UDim2.new(0, 10, 0, 36)
searchBoxFrame.BackgroundColor3 = Color3.fromRGB(26, 30, 44)
searchBoxFrame.BorderSizePixel = 0
searchBoxFrame.ZIndex = 24
searchBoxFrame.Parent = eggSelectCard
Instance.new("UICorner", searchBoxFrame).CornerRadius = UDim.new(0, 8)

local searchIcon = Instance.new("TextLabel")
searchIcon.Size = UDim2.new(0, 26, 1, 0)
searchIcon.BackgroundTransparency = 1
searchIcon.Font = Enum.Font.GothamBold
searchIcon.Text = "🔍"
searchIcon.TextColor3 = Color3.fromRGB(120, 150, 200)
searchIcon.TextSize = 12
searchIcon.ZIndex = 25
searchIcon.Parent = searchBoxFrame

local searchInput = Instance.new("TextBox")
searchInput.Size = UDim2.new(1, -34, 1, 0)
searchInput.Position = UDim2.new(0, 28, 0, 0)
searchInput.BackgroundTransparency = 1
searchInput.Font = Enum.Font.GothamMedium
searchInput.PlaceholderText = "Поиск яйца (напр. Alien, Magma, Spotted)..."
searchInput.PlaceholderColor3 = Color3.fromRGB(120, 135, 165)
searchInput.Text = ""
searchInput.TextColor3 = Color3.fromRGB(255, 255, 255)
searchInput.TextSize = 12
searchInput.TextXAlignment = Enum.TextXAlignment.Left
searchInput.ZIndex = 25
searchInput.Parent = searchBoxFrame

local eggListScroll = Instance.new("ScrollingFrame")
eggListScroll.Size = UDim2.new(1, -20, 0, 138)
eggListScroll.Position = UDim2.new(0, 10, 0, 74)
eggListScroll.BackgroundTransparency = 1
eggListScroll.BorderSizePixel = 0
eggListScroll.ScrollBarThickness = 3
eggListScroll.ScrollBarImageColor3 = Color3.fromRGB(70, 140, 255)
eggListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
eggListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
eggListScroll.ZIndex = 24
eggListScroll.Parent = eggSelectCard

local eggListLayout = Instance.new("UIListLayout")
eggListLayout.Padding = UDim.new(0, 4)
eggListLayout.SortOrder = Enum.SortOrder.LayoutOrder
eggListLayout.Parent = eggListScroll

local BGS_EGGS = {
    "Common Egg", "Spotted Egg", "Event Egg", "Alien Egg", "Magma Egg", "Dominus Egg",
    "Ancient Egg", "Balloon Egg", "Beach Egg", "Bee Egg", "Block Egg", "Coconut Egg",
    "Colorful Egg", "Coral Egg", "Crab Egg", "Crystal Egg", "Dark Egg", "Darkness Egg",
    "Demonic Egg", "Evil Egg", "Fancy Egg", "Fire Egg", "Guardian Egg", "Gummy Egg",
    "Halo Egg", "Heaven Egg", "Hell Egg", "Hydra Egg", "Ice Cream Egg", "Ice Shard Egg",
    "Inferno Egg", "Jelly Egg", "Kelp Egg", "Lunar Egg", "Mossy Egg", "Mushroom Egg",
    "Mythical Egg", "Nightmare Egg", "Obsidian Egg", "Orange Egg", "Pastel Egg",
    "Rainbow Egg", "Red Egg", "Royalty Egg", "Rubber Egg", "Sand Egg", "Slushy Egg",
    "Space Crystal Egg", "Sparkly Egg", "Star Egg", "Sun Egg", "Super Egg", "Toxic Egg",
    "Toy Egg", "Twilight Egg", "Underwater Egg", "Underworld Egg", "Unicorn Egg", "Void Egg"
}

local eggButtonsMap = {}

for _, eggName in ipairs(BGS_EGGS) do
    local isCurrSelected = (_G.SelectedEgg == eggName)

    local btn = Instance.new("TextButton")
    btn.Name = "EggBtn_" .. eggName
    btn.Size = UDim2.new(1, -6, 0, 28)
    btn.BackgroundColor3 = isCurrSelected and Color3.fromRGB(40, 100, 200) or Color3.fromRGB(26, 30, 44)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamMedium
    btn.Text = "   " .. eggName
    btn.TextColor3 = isCurrSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 215, 240)
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.ZIndex = 25
    btn.Parent = eggListScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        _G.SelectedEgg = eggName
        saveConfigToFile()
        for eName, eBtn in pairs(eggButtonsMap) do
            if eName == eggName then
                eBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 200)
                eBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                eBtn.BackgroundColor3 = Color3.fromRGB(26, 30, 44)
                eBtn.TextColor3 = Color3.fromRGB(200, 215, 240)
            end
        end
        eggHeaderLabel.Text = "🥚 Выбор яйца: " .. eggName
    end)

    eggButtonsMap[eggName] = btn
end

searchInput.Changed:Connect(function(property)
    if property == "Text" then
        local filterText = searchInput.Text:lower():gsub("%s+", "")
        for eName, eBtn in pairs(eggButtonsMap) do
            local cleanName = eName:lower():gsub("%s+", "")
            if filterText == "" or cleanName:find(filterText) then
                eBtn.Visible = true
            else
                eBtn.Visible = false
            end
        end
    end
end)

-- TAB 4: ИГРОК
TabPlayer:CreateSection("🏃 Параметры персонажа")

TabPlayer:CreateSlider({
    Name = "Скорость бега (WalkSpeed)",
    Min = 16,
    Max = 180,
    Default = 16,
    Suffix = " spd",
    Callback = function(val)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
})

TabPlayer:CreateSlider({
    Name = "Сила прыжка (JumpPower)",
    Min = 50,
    Max = 350,
    Default = 50,
    Suffix = " pwr",
    Callback = function(val)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = val
        end
    end
})

TabPlayer:CreateToggle({
    Name = "Бесконечный прыжок (Infinite Jump)",
    Default = _G.InfJump or false,
    Callback = function(val)
        _G.InfJump = val
        saveConfigToFile()
    end
})

-- TAB 5: ТЕЛЕПОРТЫ & АВТО-ПОКУПКА МИРОВ
TabTeleport:CreateSection("🌍 Разблокировка и Покупка Миров")

TabTeleport:CreateButton({
    Name = "🔓 Купить все доступные миры (1-Click Buy All Worlds)",
    Highlight = true,
    Callback = function(btnInstance, btnTitleInstance)
        btnTitleInstance.Text = "⏳ Покупка всех доступных миров..."
        pcall(function()
            local lp = LocalPlayer
            if lp and lp:FindFirstChild("leaderstats") then
                local coins = lp.leaderstats:FindFirstChild("Coins") and lp.leaderstats.Coins.Value or 0
                local unlockedMap = getUnlockedWorlds()
                for _, w in ipairs(OFFICIAL_WORLDS) do
                    if not unlockedMap[w.name] and coins >= w.priceCoins then
                        local net = game:GetService("ReplicatedStorage"):FindFirstChild("NetworkRemoteEvent")
                        if net then net:FireServer("BuyWorld", w.name) end
                        task.wait(0.5)
                    end
                end
            end
        end)
        task.delay(1.5, function()
            btnTitleInstance.Text = "✅ ВСЕ ДОСТУПНЫЕ МИРЫ РАЗБЛОКИРОВАНЫ!"
            task.delay(2.5, function()
                btnTitleInstance.Text = "🔓 Купить все доступные миры (1-Click Buy All Worlds)"
            end)
        end)
    end
})

TabTeleport:CreateSection("📍 Разделы Миров и Порталы")

local overworldCard = TabTeleport:CreateCollapsibleCard({
    Name = "🏠 Overworld (Главный Спавн)",
    HasMaster = false,
    DefaultExpanded = false
})

TabTeleport:CreateButton({
    Name = "📍 Спавн: Overworld",
    Compact = true,
    Highlight = true,
    Callback = function() teleportToOverworldUniversal() end
}, overworldCard)

local eventCard = TabTeleport:CreateCollapsibleCard({
    Name = "👽 Event World (Ивент Мир Пришельцев)",
    HasMaster = false,
    DefaultExpanded = false
})

TabTeleport:CreateButton({
    Name = "🌀 Войти в Event World (Встать на круг портала)",
    Compact = true,
    Highlight = true,
    Callback = function() teleportToPortalCircle("EventPortal") end
}, eventCard)

local candyCard = TabTeleport:CreateCollapsibleCard({
    Name = "🍭 Candy Land (4x Sell • 2.500.000 Монет)",
    HasMaster = false,
    DefaultExpanded = false
})

TabTeleport:CreateButton({
    Name = "🌀 Войти в Candy Land (Встать на круг портала)",
    Compact = true,
    Highlight = true,
    Callback = function() teleportToPortalCircle("Candy Land") end
}, candyCard)

local atlantisCard = TabTeleport:CreateCollapsibleCard({
    Name = "🔱 Atlantis (8x Sell • 20.000.000 Монет)",
    HasMaster = false,
    DefaultExpanded = false
})

TabTeleport:CreateButton({
    Name = "🌀 Войти в Atlantis (Встать на круг портала)",
    Compact = true,
    Highlight = true,
    Callback = function() teleportToPortalCircle("Atlantis") end
}, atlantisCard)

local toyCard = TabTeleport:CreateCollapsibleCard({
    Name = "🧸 Toy Land (50.000.000 Монет)",
    HasMaster = false,
    DefaultExpanded = false
})

TabTeleport:CreateButton({
    Name = "🌀 Войти в Toy Land (Встать на круг портала)",
    Compact = true,
    Highlight = true,
    Callback = function() teleportToPortalCircle("Toy Land") end
}, toyCard)

local beachCard = TabTeleport:CreateCollapsibleCard({
    Name = "🏖 Beach World (6x Sell • 150.000.000 Монет)",
    HasMaster = false,
    DefaultExpanded = false
})

TabTeleport:CreateButton({
    Name = "🌀 Войти в Beach World (Встать на круг портала)",
    Compact = true,
    Highlight = true,
    Callback = function() teleportToPortalCircle("Beach World") end
}, beachCard)

local rainbowCard = TabTeleport:CreateCollapsibleCard({
    Name = "🌈 Rainbow Land (1.500.000.000 Монет)",
    HasMaster = false,
    DefaultExpanded = false
})

TabTeleport:CreateButton({
    Name = "🌀 Войти в Rainbow Land (Встать на круг портала)",
    Compact = true,
    Highlight = true,
    Callback = function() teleportToPortalCircle("Rainbow Land") end
}, rainbowCard)

local underworldCard = TabTeleport:CreateCollapsibleCard({
    Name = "🔥 Underworld (20x Sell • 2.000.000.000 Монет)",
    HasMaster = false,
    DefaultExpanded = false
})

TabTeleport:CreateButton({
    Name = "🌀 Войти в Underworld (Встать на круг портала)",
    Compact = true,
    Highlight = true,
    Callback = function() teleportToPortalCircle("Underworld") end
}, underworldCard)

local mysticCard = TabTeleport:CreateCollapsibleCard({
    Name = "🌲 Mystic Forest (10x Sell • 4.000.000.000 Монет)",
    HasMaster = false,
    DefaultExpanded = false
})

TabTeleport:CreateButton({
    Name = "🌀 Войти в Mystic Forest (Встать на круг портала)",
    Compact = true,
    Highlight = true,
    Callback = function() teleportToPortalCircle("Mystic Forest") end
}, mysticCard)

local heavenCard = TabTeleport:CreateCollapsibleCard({
    Name = "☁ Heaven World (25x Sell • 10.000.000.000 Монет)",
    HasMaster = false,
    DefaultExpanded = false
})

TabTeleport:CreateButton({
    Name = "🌀 Войти в Heaven World (Встать на круг портала)",
    Compact = true,
    Highlight = true,
    Callback = function() teleportToPortalCircle("Heaven") end
}, heavenCard)

-- TAB 6: НАСТРОЙКИ
TabSettings:CreateSection("📐 Размер и масштаб интерфейса")

TabSettings:CreateSlider({
    Name = "Масштаб GUI (Scale)",
    Min = 70,
    Max = 130,
    Default = math.floor((_G.GuiScale or 1.0) * 100),
    Suffix = "%",
    Callback = function(val)
        _G.GuiScale = val / 100
        MainScale.Scale = _G.GuiScale
        saveConfigToFile()
    end
})

TabSettings:CreateSection("💾 Управление конфигурацией")

TabSettings:CreateButton({
    Name = "💾 Сохранить настройки в файл (Save Config)",
    Highlight = true,
    Callback = function(btn, title)
        local ok = saveConfigToFile()
        if ok then
            title.Text = "✅ НАСТРОЙКИ УСПЕШНО СОХРАНЕНЫ!"
        else
            title.Text = "⚠️ Ошибка записи в файл / не поддерживается"
        end
        task.delay(2.5, function()
            title.Text = "💾 Сохранить настройки в файл (Save Config)"
        end)
    end
})

TabSettings:CreateButton({
    Name = "📋 Скопировать код настроек",
    Callback = function(btn, title)
        local json = getSerializedConfig()
        if typeof(setclipboard) == "function" then
            pcall(function() setclipboard(json) end)
            title.Text = "📋 КОД НАСТРОЕК СКОПИРОВАН В БУФЕР!"
        else
            title.Text = "⚠️ setclipboard не поддерживается"
        end
        task.delay(2.5, function()
            title.Text = "📋 Скопировать код настроек"
        end)
    end
})

local pasteConfigCard = Instance.new("Frame")
pasteConfigCard.Size = UDim2.new(1, 0, 0, 78)
pasteConfigCard.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
pasteConfigCard.BackgroundTransparency = 0.25
pasteConfigCard.BorderSizePixel = 0
pasteConfigCard.ZIndex = 23
pasteConfigCard.Parent = TabSettings.Page
Instance.new("UICorner", pasteConfigCard).CornerRadius = UDim.new(0, 8)

local pasteStroke = Instance.new("UIStroke")
pasteStroke.Color = Color3.fromRGB(70, 140, 255)
pasteStroke.Thickness = 1
pasteStroke.Transparency = 0.5
pasteStroke.Parent = pasteConfigCard

local pasteInputFrame = Instance.new("Frame")
pasteInputFrame.Size = UDim2.new(1, -20, 0, 30)
pasteInputFrame.Position = UDim2.new(0, 10, 0, 8)
pasteInputFrame.BackgroundColor3 = Color3.fromRGB(26, 30, 44)
pasteInputFrame.BorderSizePixel = 0
pasteInputFrame.ZIndex = 24
pasteInputFrame.Parent = pasteConfigCard
Instance.new("UICorner", pasteInputFrame).CornerRadius = UDim.new(0, 6)

local pasteBox = Instance.new("TextBox")
pasteBox.Size = UDim2.new(1, -16, 1, 0)
pasteBox.Position = UDim2.new(0, 8, 0, 0)
pasteBox.BackgroundTransparency = 1
pasteBox.Font = Enum.Font.GothamMedium
pasteBox.PlaceholderText = "Вставьте код конфигурации (JSON)..."
pasteBox.PlaceholderColor3 = Color3.fromRGB(120, 135, 165)
pasteBox.Text = ""
pasteBox.TextColor3 = Color3.fromRGB(255, 255, 255)
pasteBox.TextSize = 11
pasteBox.TextXAlignment = Enum.TextXAlignment.Left
pasteBox.ZIndex = 25
pasteBox.Parent = pasteInputFrame

local applyPasteBtn = Instance.new("TextButton")
applyPasteBtn.Size = UDim2.new(1, -20, 0, 28)
applyPasteBtn.Position = UDim2.new(0, 10, 0, 44)
applyPasteBtn.BackgroundColor3 = Color3.fromRGB(30, 75, 140)
applyPasteBtn.BorderSizePixel = 0
applyPasteBtn.Font = Enum.Font.GothamBold
applyPasteBtn.Text = "📥 Применить код конфигурации"
applyPasteBtn.TextColor3 = Color3.fromRGB(240, 245, 255)
applyPasteBtn.TextSize = 12
applyPasteBtn.ZIndex = 24
applyPasteBtn.Parent = pasteConfigCard
Instance.new("UICorner", applyPasteBtn).CornerRadius = UDim.new(0, 6)

applyPasteBtn.MouseButton1Click:Connect(function()
    local inputCode = pasteBox.Text
    if (not inputCode or inputCode == "") and typeof(getclipboard) == "function" then
        pcall(function() inputCode = getclipboard() end)
    end

    if inputCode and type(inputCode) == "string" and #inputCode > 2 then
        local ok = applySerializedConfig(inputCode)
        if ok then
            saveConfigToFile()
            applyPasteBtn.Text = "✅ КОНФИГУРАЦИЯ УСПЕШНО ПРИМЕНЕНА!"
        else
            applyPasteBtn.Text = "⚠️ Невалидный JSON код конфигурации!"
        end
    else
        applyPasteBtn.Text = "⚠️ Поле конфигурации пустое!"
    end

    task.delay(2.5, function()
        applyPasteBtn.Text = "📥 Применить код конфигурации"
    end)
end)

TabSettings:CreateButton({
    Name = "🔄 Сбросить настройки на по умолчанию",
    Danger = true,
    Callback = function(btn, title)
        _G.AutoBlow = false
        _G.AutoSell = false
        _G.SellCooldown = 3
        _G.SelectedSellMode = "🌟 Авто локация (Автоматический выбор лучшего 2x - 25x)"
        _G.ReturnToFarmPos = false
        _G.ReturnToCollectPos = false
        _G.AutoHatch = false
        _G.SelectedEgg = nil
        _G.HatchAmount = 1
        _G.PetWebhookEnabled = false
        _G.PetWebhookUrl = ""
        _G.WebhookRarityFilter = "All Pets"
        _G.InfJump = false
        _G.AutoCollect = false
        _G.AutoCollectRewards = false
        _G.CollectCoins = true
        _G.CollectGems = true
        _G.CollectXP = true
        _G.CollectDelay = 0.01
        _G.AutoBuyUpgrades = false
        _G.UpgradeGum = true
        _G.UpgradeFlavors = true
        _G.UpgradeFaces = true
        _G.AutoEquipBest = false
        _G.AutoEquipGum = true
        _G.AutoEquipFlavors = true
        _G.AutoEquipFaces = true
        _G.AutoBuyWorlds = false
        _G.GuiScale = 1
        MainScale.Scale = 1

        _G.CollectWorlds = {
            Overworld = false,
            ["Event World"] = false,
            ["Candy Land"] = false,
            ["Beach World"] = false,
            Atlantis = false,
            ["Mystic Forest"] = false,
            Underworld = false,
            Heaven = false,
            ["Rainbow Land"] = false,
            ["Toy Land"] = false
        }

        if typeof(delfile) == "function" and typeof(isfile) == "function" and isfile(CONFIG_FILE_NAME) then
            pcall(function() delfile(CONFIG_FILE_NAME) end)
        end

        title.Text = "✅ НАСТРОЙКИ СБРОШЕНЫ НА ПО УМОЛЧАНИЮ!"
        task.delay(2.5, function()
            title.Text = "🔄 Сбросить настройки на по умолчанию"
        end)
    end
})

pcall(function()
    if MainScale and _G.GuiScale then
        MainScale.Scale = _G.GuiScale
    end
end)

print("[SataNet Hub] Universal Auto-Collect & Syntax Error Fix Deployed Successfully.")
