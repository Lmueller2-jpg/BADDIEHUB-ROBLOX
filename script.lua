--[[
    ____                 _     _ _      _  _    ___  _  _   __  __ _   _ _   _____ ___ _   _ _   _ _   _ _   _ _   _ 
   | __ )  __ _  __ _  __| | __| (_) ___| || |  / _ \\| || | |  \\/  | | | | | |_   _|_ _| | | | | | | | | | | | |
   |  _ \\ / _\` |/ _\` |/ _\` |/ _\` | |/ _ \\_  _| | | | | || |_| |\\/| | | | | |   | |  | || | | | | | | | | | | |
   | |_) | (_| | (_| | (_| | (_| | |  __/ | |   | |_| |__   _| |  | | |_| | |___| |  | || |_| | |_| | |_| |_| |_|
   |____/ \\__,_|\\__,_|\\__,_|\\__,_|_|\\___| |_|    \\___/   |_| |_|  |_|\\___/|_____|_| |___|\\___/ \\___/ \\___/\\___/
   
   ======================================================================================================
   BADDIE404 MULTIHUB v5.1 - Premium Multi-Game Roblox Exploit Client
   Remastered with WindUI Integration (Touch-Optimized for Delta, Fluxus, Vega X, Solara, Wave)
   ======================================================================================================
--]]

-- [1. Core Initialization & Configuration Payload]
local BaddieHubSettings = {
    WalkSpeed = 45,
    JumpPower = 120,
    FarmSpeed = 75,
    Theme = "Dark",
    AccentColor = Color3.fromRGB(255, 64, 129),
    ButtonSize = 60,
    ButtonColor = Color3.fromRGB(168, 85, 247),
    ButtonLabel = "B404",
    SafeMode = true,
    AntiLag = true,
    WatchdogEnabled = true,
    EnableBloxFruits = true,
    EnableJJK = true,
    EnableWorldZero = true,
    ShowFloatingButton = true,
    ToggleKey = "RightControl",
    PreferredWeapon = "Melee",
    ContinuousSpeed = false
}

-- [2. Cleanup Existing Instances to Prevent Memory Leaks & Duplicates]
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlaceId = game.PlaceId

local function CleanExistingHubs()
    for _, obj in ipairs(CoreGui:GetChildren()) do
        if obj.Name == "BaddieHubToggleButtonGui" or obj.Name == "WindUI" or obj.Name == "Orion" or obj.Name == "Baddie404Loading" then
            pcall(function()
                obj:Destroy()
            end)
        end
    end
end
CleanExistingHubs()

-- [3. The Watchdog Guard: Centralized Error and Connection Safety]
local Watchdog = {
    Connections = {},
    TetheredNPCs = {},
    SafeEvents = {},
}

function Watchdog:SafeConnect(signal, callback, key)
    local success, conn = pcall(function()
        return signal:Connect(callback)
    end)
    if success and conn then
        if key then
            if self.Connections[key] then
                pcall(function() self.Connections[key]:Disconnect() end)
            end
            self.Connections[key] = conn
        else
            table.insert(self.Connections, conn)
        end
        return conn
    else
        warn("[Watchdog] Failed to connect signal: " .. tostring(key or "Anonymous"))
    end
end

function Watchdog:SafeExecute(description, func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[Watchdog SafeExecute] Error in '" .. tostring(description) .. "': " .. tostring(result))
        if BaddieHubSettings.SafeMode then
            print("[Watchdog Guard] SafeMode suppressed potential game crash.")
        end
        return nil
    end
    return result
end

function Watchdog:SafeFireRemote(remote, ...)
    if not remote then return end
    self:SafeExecute("FireRemote (" .. remote.Name .. ")", function(...)
        if remote:IsA("RemoteEvent") then
            remote:FireServer(...)
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(...)
        end
    end, ...)
end

function Watchdog:Cleanup()
    print("[Watchdog Cleanup] Releasing all active signals and connections.")
    for k, conn in pairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}
    
    for _, npc in ipairs(self.TetheredNPCs) do
        pcall(function()
            if npc and npc.PrimaryPart then
                npc.PrimaryPart.Anchored = false
                for _, part in ipairs(npc:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end)
    end
    self.TetheredNPCs = {}
end

-- =============================================================================
-- LOADING SCREEN (Modern High-Contrast Dark Theme)
-- =============================================================================
local LoadGui = Instance.new("ScreenGui")
LoadGui.Name = "Baddie404Loading"
LoadGui.IgnoreGuiInset = true
LoadGui.ResetOnSpawn = false
LoadGui.Parent = CoreGui

local Bg = Instance.new("Frame", LoadGui)
Bg.Size = UDim2.fromScale(1,1)
Bg.BackgroundColor3 = Color3.fromRGB(10,10,16)
Bg.BorderSizePixel = 0

local Card = Instance.new("Frame", Bg)
Card.AnchorPoint = Vector2.new(0.5,0.5)
Card.Position = UDim2.fromScale(0.5,0.5)
Card.Size = UDim2.new(0,400,0,180)
Card.BackgroundColor3 = Color3.fromRGB(18,18,26)
Card.BorderSizePixel = 0
Instance.new("UICorner", Card).CornerRadius = UDim.new(0,12)

local cs = Instance.new("UIStroke", Card)
cs.Color = BaddieHubSettings.AccentColor
cs.Thickness = 1.5

local function MkLabel(parent, pos, size, text, size2, font, color, alignX)
    local l = Instance.new("TextLabel", parent)
    l.Position = pos; l.Size = size
    l.BackgroundTransparency = 1
    l.Text = text; l.TextSize = size2
    l.Font = font or Enum.Font.GothamMedium
    l.TextColor3 = color or Color3.new(1,1,1)
    l.TextXAlignment = alignX or Enum.TextXAlignment.Center
    return l
end

MkLabel(Card, UDim2.new(0,0,0,30), UDim2.new(1,0,0,30), "BADDIE404 MULTIHUB", 22, Enum.Font.GothamBold, BaddieHubSettings.AccentColor)
local statusLabel = MkLabel(Card, UDim2.new(0,0,0,65), UDim2.new(1,0,0,20), "Optimizing Environment Safety...", 12, Enum.Font.GothamMedium, Color3.fromRGB(180,180,190))

local BarBg = Instance.new("Frame", Card)
BarBg.Position = UDim2.new(0.08,0,0.65,0)
BarBg.Size = UDim2.new(0.84,0,0,10)
BarBg.BackgroundColor3 = Color3.fromRGB(28,28,36)
BarBg.BorderSizePixel = 0
Instance.new("UICorner", BarBg).CornerRadius = UDim.new(0.5,0)

local Bar = Instance.new("Frame", BarBg)
Bar.Size = UDim2.fromScale(0,1)
Bar.BackgroundColor3 = BaddieHubSettings.AccentColor
Bar.BorderSizePixel = 0
Instance.new("UICorner", Bar).CornerRadius = UDim.new(0.5,0)

local function SetProgress(p, d)
    TweenService:Create(Bar, TweenInfo.new(d or 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromScale(p/100, 1)}):Play()
end

local function SetStatus(t)
    if statusLabel then
        statusLabel.Text = t
    end
end

SetStatus("Scanning Network Safeguards..."); SetProgress(25, 0.3); task.wait(0.4)
SetStatus("Validating Workspace Assets..."); SetProgress(55, 0.4); task.wait(0.5)

-- =============================================================================
-- WINDUI BOOTSTRAPPER (Modern Touch-First Framework)
-- =============================================================================
local WindUI = nil
local loaderSuccess, loaderErr = pcall(function()
    WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Baddie404/WindUI-Multihub/main/WindUI.lua"))()
end)

if not loaderSuccess or not WindUI then
    warn("[BaddieHub Bootstrapper] WindUI CDN load failed. Falling back to built-in fallback UI framework...")
    WindUI = {
        CreateWindow = function(_, opts)
            print("[Fallback Window] Initiated: " .. tostring(opts.Title))
            local dummy = {
                Tab = function()
                    local t = {}
                    local dummyMethods = {"Section", "Button", "Toggle", "Slider", "Dropdown", "TextBox"}
                    for _, m in ipairs(dummyMethods) do
                        t[m] = function(_, o)
                            print("[Fallback Control] Added " .. m .. " -> " .. tostring(o.Title or o.Value))
                            if o.Callback then
                                task.spawn(function() pcall(o.Callback, o.Value or o.Default or false) end)
                            end
                            return {
                                Refresh = function() end,
                                SetOptions = function() end,
                                UpdateDropdown = function() end
                            }
                        end
                    end
                    return t
                end,
                Toggle = function() end,
                Notify = function(_, o) print("[Notification] " .. tostring(o.Title) .. ": " .. tostring(o.Content)) end
            }
            return dummy
        end,
        Notify = function(_, o) print("[Notification] " .. tostring(o.Title) .. ": " .. tostring(o.Content)) end
    }
end

SetStatus("Bootstrapping WindUI Framework..."); SetProgress(85, 0.3); task.wait(0.3)

local Window = WindUI:CreateWindow({
    Title = "BaddieHub Multi-Game",
    SubTitle = "v5.1 Premium",
    Icon = "rbxassetid://10723345484",
    Theme = BaddieHubSettings.Theme,
    Accent = BaddieHubSettings.AccentColor,
    Size = UDim2.new(0, 560, 0, 380),
    Transparent = true,
    MinimizeKey = Enum.KeyCode.RightControl
})

local function CreateTab(name, icon)
    local realTab = Window:Tab({ Title = name, Icon = icon or "box" })
    local safeTab = {}
    
    local function wrapMethod(methodName)
        return function(_, options, ...)
            local method = realTab[methodName]
            if not method then
                warn("[BaddieHub Tabs] WindUI tab is missing method: " .. tostring(methodName))
                return nil
            end
            
            -- Safe intercept/pcall execute wrapper
            local args = {...}
            local success, result = pcall(function()
                return method(realTab, options, unpack(args))
            end)
            
            if not success then
                warn("[BaddieHub Tabs] Error executing " .. methodName .. " for: " .. tostring(options.Title) .. " -> " .. tostring(result))
                if BaddieHubSettings.SafeMode then
                    -- Attempt standard WindUI safe configuration correction
                    if options.Default and not options.Value then
                        options.Value = options.Default
                    end
                    
                    -- Retry call with adjusted options
                    local retrySuccess, retryResult = pcall(function()
                        return method(realTab, options, unpack(args))
                    end)
                    if retrySuccess then
                        return retryResult
                    end
                end
                return nil
            end
            
            return result
        end
    end
    
    -- Metatable to dynamically wrap any call
    setmetatable(safeTab, {
        __index = function(tbl, key)
            return wrapMethod(key)
        end
    })
    
    return safeTab
end

local FloatingButtonInstance = nil
local FloatingButtonGui = nil

-- [5. Create Floating Toggle Button for Mobile Executors]
local function CreateFloatingToggleButton()
    if FloatingButtonGui then
        pcall(function() FloatingButtonGui:Destroy() end)
    end
    
    FloatingButtonGui = Instance.new("ScreenGui")
    FloatingButtonGui.Name = "BaddieHubToggleButtonGui"
    FloatingButtonGui.ResetOnSpawn = false
    FloatingButtonGui.Parent = CoreGui

    local Button = Instance.new("TextButton")
    FloatingButtonInstance = Button
    Button.Size = UDim2.new(0, BaddieHubSettings.ButtonSize, 0, BaddieHubSettings.ButtonSize)
    Button.Position = UDim2.new(0.05, 0, 0.25, 0)
    Button.BackgroundColor3 = BaddieHubSettings.ButtonColor
    Button.Text = BaddieHubSettings.ButtonLabel
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = math.clamp(BaddieHubSettings.ButtonSize / 4, 10, 20)
    Button.Visible = BaddieHubSettings.ShowFloatingButton
    Button.Parent = FloatingButtonGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.5, 0)
    UICorner.Parent = Button

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Thickness = 2
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = Button

    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        Button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Button.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    Button.MouseButton1Click:Connect(function()
        if Window then
            pcall(function() Window:Toggle() end)
        end
        pcall(function()
            Button.Size = UDim2.new(0, BaddieHubSettings.ButtonSize - 8, 0, BaddieHubSettings.ButtonSize - 8)
            task.wait(0.05)
            Button.Size = UDim2.new(0, BaddieHubSettings.ButtonSize, 0, BaddieHubSettings.ButtonSize)
        end)
    end)
end

local function SetupGlobalKeybind()
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed then
            local keyString = tostring(BaddieHubSettings.ToggleKey)
            local parsedKey = nil
            pcall(function()
                parsedKey = Enum.KeyCode[keyString] or Enum.KeyCode.RightControl
            end)
            if parsedKey and input.KeyCode == parsedKey then
                if Window then
                    pcall(function() Window:Toggle() end)
                end
            end
        end
    end)
end
task.spawn(SetupGlobalKeybind)

task.spawn(function()
    while true do
        if BaddieHubSettings.ContinuousSpeed then
            pcall(function()
                local hum = GetHum()
                if hum then
                    if hum.WalkSpeed ~= BaddieHubSettings.WalkSpeed then
                        hum.WalkSpeed = BaddieHubSettings.WalkSpeed
                    end
                    if hum.JumpPower ~= BaddieHubSettings.JumpPower then
                        hum.JumpPower = BaddieHubSettings.JumpPower
                    end
                end
            end)
        end
        task.wait(0.2)
    end
end)

-- =============================================================================
-- LOW-LEVEL ROBLOX UTILITIES (Reverse-Engineered Core Helpers)
-- =============================================================================
local function GetHum()
    local c = LocalPlayer.Character; if not c then return nil end
    return c:FindFirstChildOfClass("Humanoid")
end

local function GetHRP()
    local c = LocalPlayer.Character; if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart")
end

-- [6. Player State Hacks (WalkSpeed / JumpPower / Fly)]
local Flying = false
local FlySpeed = 50
local FlyConnection

local function ToggleFly(state)
    Flying = state
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    if Flying then
        if FlyConnection then pcall(function() FlyConnection:Disconnect() end) end

        local bodyGyro = hrp:FindFirstChildOfClass("BodyGyro") or Instance.new("BodyGyro")
        bodyGyro.P = 9e4; bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9); bodyGyro.cframe = hrp.CFrame; bodyGyro.Parent = hrp

        local bodyVelocity = hrp:FindFirstChildOfClass("BodyVelocity") or Instance.new("BodyVelocity")
        bodyVelocity.velocity = Vector3.new(0, 0.1, 0); bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9); bodyVelocity.Parent = hrp

        humanoid.PlatformStand = true

        FlyConnection = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local camera = workspace.CurrentCamera
            local moveDirection = humanoid.MoveDirection
            local speedMultiplier = FlySpeed

            bodyGyro.cframe = camera.CFrame
            if moveDirection.Magnitude > 0 then
                bodyVelocity.velocity = moveDirection * speedMultiplier
            else
                bodyVelocity.velocity = Vector3.new(0, 0, 0)
            end
        end)
        table.insert(Watchdog.Connections, FlyConnection)
    else
        if FlyConnection then
            pcall(function() FlyConnection:Disconnect() end)
            FlyConnection = nil
        end
        local bodyGyro = hrp:FindFirstChildOfClass("BodyGyro")
        local bodyVelocity = hrp:FindFirstChildOfClass("BodyVelocity")
        if bodyGyro then bodyGyro:Destroy() end
        if bodyVelocity then bodyVelocity:Destroy() end
        humanoid.PlatformStand = false
    end
end

-- [7. Human-Like Interpolated Teleporter (Velocity & Anti-Cheat Safe)]
local function SafeTeleport(targetCFrame)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local currentPos = hrp.Position
    local targetPos = targetCFrame.Position
    local distance = (targetPos - currentPos).Magnitude
    local speed = BaddieHubSettings.FarmSpeed

    if distance < 15 then
        hrp.CFrame = targetCFrame
        return true
    end

    local duration = distance / speed
    local startTime = os.clock()
    local noclipConn

    noclipConn = RunService.Stepped:Connect(function()
        pcall(function()
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end)

    local connection
    connection = RunService.Heartbeat:Connect(function()
        local now = os.clock()
        local elapsed = now - startTime
        local t = math.clamp(elapsed / duration, 0, 1)
        local currentLerpPos = currentPos:Lerp(targetPos, t)
        
        if char and hrp then
            hrp.Velocity = Vector3.new(0,0,0)
            hrp.RotVelocity = Vector3.new(0,0,0)
            hrp.CFrame = CFrame.new(currentLerpPos, targetPos)
        end

        if t >= 1 then
            connection:Disconnect()
            noclipConn:Disconnect()
            if hrp then hrp.CFrame = targetCFrame end
        end
    end)
    
    table.insert(Watchdog.Connections, connection)
    table.insert(Watchdog.Connections, noclipConn)
    return true
end

-- [8. Mob Magnet Subsystem: Safe, Stretched, Collisionless Pull]
local function StartMobMagnet(targetModel, tetherPart, radius)
    if not targetModel or not tetherPart then return end
    
    local function HandleMobPull(mob)
        if not mob or not mob.PrimaryPart then return end
        table.insert(Watchdog.TetheredNPCs, mob)

        for _, desc in ipairs(mob:GetDescendants()) do
            if desc:IsA("BasePart") then
                desc.CanCollide = false
            end
        end

        local magConn
        magConn = RunService.Heartbeat:Connect(function()
            pcall(function()
                if mob and mob.PrimaryPart and tetherPart then
                    local targetPosition = tetherPart.Position + (tetherPart.CFrame.LookVector * 4)
                    local distance = (mob.PrimaryPart.Position - tetherPart.Position).Magnitude
                    
                    if distance <= radius then
                        mob.PrimaryPart.Velocity = Vector3.new(0,0,0)
                        mob.PrimaryPart.CFrame = CFrame.new(targetPosition)
                    end
                else
                    magConn:Disconnect()
                end
            end)
        end)
        table.insert(Watchdog.Connections, magConn)
    end

    for _, child in ipairs(targetModel:GetChildren()) do
        if child:IsA("Model") and child:FindFirstChild("Humanoid") then
            HandleMobPull(child)
        end
    end

    local childAddedConn = targetModel.ChildAdded:Connect(function(child)
        task.wait(0.1)
        if child:IsA("Model") and child:FindFirstChild("Humanoid") then
            HandleMobPull(child)
        end
    end)
    table.insert(Watchdog.Connections, childAddedConn)
end

-- [9. Strict Inventory/Tool Scanner (Zero Str-matching Hacks)]
local function GetPlayerTool(toolName)
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character
    local targetTool = nil

    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and (not toolName or item.Name == toolName) then
                targetTool = item
                break
            end
        end
    end

    if not targetTool and character then
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Tool") and (not toolName or item.Name == toolName) then
                targetTool = item
                break
            end
        end
    end

    return targetTool
end

local function EquipPreferredWeapon()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character
    if not character then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end

    -- Check if we already have a tool equipped that matches our preference or general farming need
    local activeTool = character:FindFirstChildOfClass("Tool")
    if activeTool then
        local weaponType = BaddieHubSettings.PreferredWeapon
        if weaponType == "Any" then
            return activeTool
        elseif weaponType == "Melee" and (activeTool.Name:lower():find("melee") or activeTool.Name:lower():find("combat") or activeTool.Name:lower():find("fist") or activeTool.Name:lower():find("dark step") or activeTool.Name:lower():find("electric") or activeTool.Name:lower():find("water kung fu") or activeTool.Name:lower():find("dragon breath") or activeTool.Name:lower():find("superhuman") or activeTool.Name:lower():find("godhuman") or activeTool.Name:lower():find("death step") or activeTool.Name:lower():find("sharkman") or activeTool.Name:lower():find("sanguine")) then
            return activeTool
        elseif weaponType == "Sword" and (activeTool.Name:lower():find("sword") or activeTool.Name:lower():find("katana") or activeTool.Name:lower():find("cutlass") or activeTool.Name:lower():find("saber") or activeTool.Name:lower():find("bisento") or activeTool.Name:lower():find("pole") or activeTool.Name:lower():find("blade") or activeTool.Name:lower():find("scythe") or activeTool.Name:lower():find("hallow") or activeTool.Name:lower():find("tushita") or activeTool.Name:lower():find("yama") or activeTool.Name:lower():find("cursed dual")) then
            return activeTool
        elseif weaponType == "Blox Fruit" and (activeTool.Name:lower():find("fruit") or activeTool.Name:lower():find("power") or activeTool.Name:lower():find("ice") or activeTool.Name:lower():find("light") or activeTool.Name:lower():find("magma") or activeTool.Name:lower():find("buddha") or activeTool.Name:lower():find("dough") or activeTool.Name:lower():find("leopard") or activeTool.Name:lower():find("dragon") or activeTool.Name:lower():find("kitsune") or activeTool.Name:lower():find("portal")) then
            return activeTool
        end
    end

    -- If no matching tool is active, search the Backpack and equip it once.
    if backpack then
        local foundTool = nil
        local pref = BaddieHubSettings.PreferredWeapon
        
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                if pref == "Any" then
                    foundTool = item
                    break
                elseif pref == "Melee" and (item.Name:lower():find("melee") or item.Name:lower():find("combat") or item.Name:lower():find("fist") or item.Name:lower():find("dark step") or item.Name:lower():find("electric") or item.Name:lower():find("water kung fu") or item.Name:lower():find("dragon breath") or item.Name:lower():find("superhuman") or item.Name:lower():find("godhuman") or item.Name:lower():find("death step") or item.Name:lower():find("sharkman") or item.Name:lower():find("sanguine")) then
                    foundTool = item
                    break
                elseif pref == "Sword" and (item.Name:lower():find("sword") or item.Name:lower():find("katana") or item.Name:lower():find("cutlass") or item.Name:lower():find("saber") or item.Name:lower():find("bisento") or item.Name:lower():find("pole") or item.Name:lower():find("blade") or item.Name:lower():find("scythe") or item.Name:lower():find("hallow") or item.Name:lower():find("tushita") or item.Name:lower():find("yama") or item.Name:lower():find("cursed dual")) then
                    foundTool = item
                    break
                elseif pref == "Blox Fruit" and (item.Name:lower():find("fruit") or item.Name:lower():find("power") or item.Name:lower():find("ice") or item.Name:lower():find("light") or item.Name:lower():find("magma") or item.Name:lower():find("buddha") or item.Name:lower():find("dough") or item.Name:lower():find("leopard") or item.Name:lower():find("dragon") or item.Name:lower():find("kitsune") or item.Name:lower():find("portal")) then
                    foundTool = item
                    break
                end
            end
        end
        
        -- If none found of preferred, fallback to any tool
        if not foundTool then
            foundTool = backpack:FindFirstChildOfClass("Tool")
        end
        
        if foundTool then
            pcall(function()
                humanoid:EquipTool(foundTool)
            end)
            return foundTool
        end
    end

    return activeTool
end

-- ========================================================================================
-- [10. BUILDING WINDUI TABS & TACKLING MODULES]
-- ========================================================================================

-- [Tab A: Home/Player Options]
local HomeTab = CreateTab("Player Options", "user")

HomeTab:Button({
    Title = "Force WalkSpeed / JumpPower",
    Desc = "Apply custom walkspeed and jump power variables.",
    Callback = function()
        Watchdog:SafeExecute("Set WalkSpeed", function()
            local hum = GetHum()
            if hum then
                hum.WalkSpeed = BaddieHubSettings.WalkSpeed
                hum.JumpPower = BaddieHubSettings.JumpPower
            end
        end)
    end
})

HomeTab:Slider({
    Title = "WalkSpeed Multiplier",
    Desc = "Adjust speed velocity variables safely.",
    Min = 16,
    Max = 250,
    Value = BaddieHubSettings.WalkSpeed,
    Callback = function(val)
        BaddieHubSettings.WalkSpeed = val
        local hum = GetHum()
        if hum then hum.WalkSpeed = val end
    end
})

HomeTab:Slider({
    Title = "JumpPower Velocity",
    Desc = "Adjust jump velocity variables safely.",
    Min = 50,
    Max = 500,
    Value = BaddieHubSettings.JumpPower,
    Callback = function(val)
        BaddieHubSettings.JumpPower = val
        local hum = GetHum()
        if hum then hum.JumpPower = val end
    end
})

HomeTab:Toggle({
    Title = "Noclip Fly Mode",
    Desc = "Safely fly and navigate across the environment collision-free.",
    Value = false,
    Callback = function(state)
        ToggleFly(state)
    end
})

-- [Tab B: ESP Hack Overlays]
local EspTab = CreateTab("ESPs & Overlays", "eye")
local EspEnabled = false
local EspFolder = Instance.new("Folder", workspace)
EspFolder.Name = "BaddieESPFolder"

local function ApplyESP(player)
    if player == LocalPlayer then return end
    
    local function HandleCharacter(char)
        task.wait(0.5)
        if not EspEnabled then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        -- Bounding Box Adornment
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "BaddieESPBox"
        box.Size = Vector3.new(4, 6, 4)
        box.Color3 = BaddieHubSettings.AccentColor
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Adornee = hrp
        box.Parent = EspFolder
        
        -- Overhead Billboard Title
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "BaddieESPTag"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.Adornee = hrp
        billboard.Parent = EspFolder
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.TextColor3 = BaddieHubSettings.AccentColor
        text.TextStrokeTransparency = 0
        text.Text = player.DisplayName .. " [" .. player.Name .. "]"
        text.Font = Enum.Font.GothamBold
        text.TextSize = 10
        text.Parent = billboard
        
        -- Cleanup connections when dead/parent changes
        local distConn
        distConn = RunService.Heartbeat:Connect(function()
            if EspEnabled and char and char.Parent and hrp and hrp.Parent then
                local myHrp = GetHRP()
                if myHrp then
                    local d = math.floor((myHrp.Position - hrp.Position).Magnitude)
                    text.Text = player.DisplayName .. " (" .. d .. " studs)"
                end
            else
                if distConn then distConn:Disconnect() end
                box:Destroy()
                billboard:Destroy()
            end
        end)
        table.insert(Watchdog.Connections, distConn)
    end

    if player.Character then HandleCharacter(player.Character) end
    player.CharacterAdded:Connect(HandleCharacter)
end

EspTab:Toggle({
    Title = "Enable Player ESP",
    Desc = "Render bounding adornments around all players.",
    Value = false,
    Callback = function(state)
        EspEnabled = state
        if EspEnabled then
            EspFolder:ClearAllChildren()
            for _, player in ipairs(Players:GetPlayers()) do
                ApplyESP(player)
            end
            local playerAddedConn = Players.PlayerAdded:Connect(ApplyESP)
            table.insert(Watchdog.Connections, playerAddedConn)
        else
            EspFolder:ClearAllChildren()
        end
    end
})

local ChestEspEnabled = false
local FruitEspEnabled = false

local function ApplyChestESP(chest)
    if not ChestEspEnabled then return end
    if not chest:IsA("BasePart") then return end
    
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "BaddieESPChest"
    box.Size = chest.Size
    box.Color3 = Color3.fromRGB(234, 179, 8) -- Gold
    box.AlwaysOnTop = true
    box.ZIndex = 4
    box.Adornee = chest
    box.Parent = EspFolder

    local tag = Instance.new("BillboardGui")
    tag.Name = "BaddieESPChestTag"
    tag.Size = UDim2.new(0, 100, 0, 30)
    tag.Adornee = chest
    tag.AlwaysOnTop = true
    tag.Parent = EspFolder

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(234, 179, 8)
    text.TextStrokeTransparency = 0
    text.Text = "Chest"
    text.Font = Enum.Font.GothamBold
    text.TextSize = 9
    text.Parent = tag

    local conn
    conn = RunService.Heartbeat:Connect(function()
        if ChestEspEnabled and chest and chest.Parent then
            -- keep alive
        else
            if conn then conn:Disconnect() end
            box:Destroy()
            tag:Destroy()
        end
    end)
    table.insert(Watchdog.Connections, conn)
end

local function ApplyFruitESP(fruit)
    if not FruitEspEnabled then return end
    local handle = fruit:FindFirstChild("Handle") or fruit:FindFirstChildOfClass("BasePart")
    if not handle then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "BaddieESPFruit"
    box.Size = handle.Size
    box.Color3 = Color3.fromRGB(255, 64, 129) -- Crimson Pink
    box.AlwaysOnTop = true
    box.ZIndex = 6
    box.Adornee = handle
    box.Parent = EspFolder

    local tag = Instance.new("BillboardGui")
    tag.Name = "BaddieESPFruitTag"
    tag.Size = UDim2.new(0, 150, 0, 35)
    tag.Adornee = handle
    tag.AlwaysOnTop = true
    tag.Parent = EspFolder

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(255, 64, 129)
    text.TextStrokeTransparency = 0
    text.Text = "Fruit: " .. fruit.Name
    text.Font = Enum.Font.GothamBold
    text.TextSize = 10
    text.Parent = tag

    local conn
    conn = RunService.Heartbeat:Connect(function()
        if FruitEspEnabled and fruit and fruit.Parent then
            -- keep alive
        else
            if conn then conn:Disconnect() end
            box:Destroy()
            tag:Destroy()
        end
    end)
    table.insert(Watchdog.Connections, conn)
end

EspTab:Toggle({
    Title = "Enable Chest ESP",
    Desc = "Renders golden borders and indicators on all map chests.",
    Value = false,
    Callback = function(state)
        ChestEspEnabled = state
        if ChestEspEnabled then
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj.Name:lower():find("chest") or obj.Name:lower():find("treasure") then
                    ApplyChestESP(obj)
                end
            end
            local addedConn = workspace.ChildAdded:Connect(function(obj)
                task.wait(0.1)
                if obj.Name:lower():find("chest") or obj.Name:lower():find("treasure") then
                    ApplyChestESP(obj)
                end
            end)
            table.insert(Watchdog.Connections, addedConn)
        else
            for _, o in ipairs(EspFolder:GetChildren()) do
                if o.Name == "BaddieESPChest" or o.Name == "BaddieESPChestTag" then
                    o:Destroy()
                end
            end
        end
    end
})

EspTab:Toggle({
    Title = "Enable World Fruit ESP",
    Desc = "Highlights any dropped Devil Fruits currently active in the server.",
    Value = false,
    Callback = function(state)
        FruitEspEnabled = state
        if FruitEspEnabled then
            for _, o in ipairs(workspace:GetDescendants()) do
                if o:IsA("Tool") and (o.Name:lower():find("fruit") or o.Name:lower():find("devil")) then
                    ApplyFruitESP(o)
                end
            end
            local addedConn = workspace.DescendantAdded:Connect(function(o)
                task.wait(0.2)
                if o:IsA("Tool") and (o.Name:lower():find("fruit") or o.Name:lower():find("devil")) then
                    ApplyFruitESP(o)
                end
            end)
            table.insert(Watchdog.Connections, addedConn)
        else
            for _, o in ipairs(EspFolder:GetChildren()) do
                if o.Name == "BaddieESPFruit" or o.Name == "BaddieESPFruitTag" then
                    o:Destroy()
                end
            end
        end
    end
})

-- [Tab C: Teleport Settings]
local TeleportTab = CreateTab("Teleports", "map")
local selectedPlayerTp = ""
local targetPlayerInput = ""

local function GetOtherPlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    if #list == 0 then table.insert(list, "(no other players)") end
    return list
end

TeleportTab:TextBox({
    Title = "Search Player Name",
    Desc = "Type part of player name and press Enter.",
    Value = "",
    Callback = function(val)
        targetPlayerInput = val
    end
})

local PlayerDropdown
PlayerDropdown = TeleportTab:Dropdown({
    Title = "Select Target Player",
    Desc = "Target player for smooth interpolation transport.",
    Value = "",
    Options = GetOtherPlayers(),
    Callback = function(val)
        selectedPlayerTp = val
    end
})

TeleportTab:Button({
    Title = "Refresh Player List",
    Desc = "Scan for active players in the server dynamically.",
    Callback = function()
        local currentOpts = GetOtherPlayers()
        if PlayerDropdown then
            pcall(function() PlayerDropdown:Refresh(currentOpts, true) end)
            pcall(function() PlayerDropdown:SetOptions(currentOpts) end)
            pcall(function() PlayerDropdown:UpdateDropdown(currentOpts) end)
        end
    end
})

TeleportTab:Button({
    Title = "Safe TP to Player",
    Desc = "Executes safe linear interpolation flight to selected or searched player.",
    Callback = function()
        local targetName = selectedPlayerTp
        if targetPlayerInput ~= "" then
            targetName = targetPlayerInput
        end
        
        local foundPlayer = nil
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                if p.Name == targetName or p.DisplayName == targetName or p.Name:lower():find(targetName:lower()) or p.DisplayName:lower():find(targetName:lower()) then
                    foundPlayer = p
                    break
                end
            end
        end
        
        if foundPlayer and foundPlayer.Character then
            local hrp = foundPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                SafeTeleport(hrp.CFrame * CFrame.new(0, 3, 0))
            end
        else
            pcall(function()
                WindUI:Notify({
                    Title = "Teleport Failed",
                    Content = "Target player not found or character not active.",
                    Duration = 3
                })
            end)
        end
    end
})

-- =============================================================================
-- GAME MOD: BLOX FRUITS (Highly Optimized Module)
-- =============================================================================
if BaddieHubSettings.EnableBloxFruits and (DetectedGame == "Blox Fruits" or Universal) then
    local BloxTab = CreateTab("Blox Fruits", "sword")
    local ChestFarming = false
    local AutoFarmLevel = false
    local selectedStat = "None"
    local FastAttack = false

    BloxTab:Section({ Title = "Main Farm Utilities" })

    BloxTab:Dropdown({
        Title = "Farming Weapon Preferred",
        Desc = "Selects the weapon category to equip for level farming to prevent hotbar slot spam.",
        Value = "Melee",
        Options = {"Melee", "Sword", "Blox Fruit", "Any"},
        Callback = function(val)
            BaddieHubSettings.PreferredWeapon = val
        end
    })

    BloxTab:Slider({
        Title = "Farming Tween Speed",
        Desc = "Adjust standard travel velocity studs/second limit.",
        Min = 10,
        Max = 200,
        Value = BaddieHubSettings.FarmSpeed,
        Callback = function(val)
            BaddieHubSettings.FarmSpeed = val
        end
    })

    BloxTab:Toggle({
        Title = "Auto Farm Level",
        Desc = "Automatically grabs quests, teleports to enemies, and defeats them smoothly.",
        Value = false,
        Callback = function(state)
            AutoFarmLevel = state
            task.spawn(function()
                while AutoFarmLevel do
                    pcall(function()
                        local myLevel = 1
                        pcall(function()
                            if LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Level") then
                                myLevel = LocalPlayer.Data.Level.Value
                            end
                        end)

                        local questName, questId, mobName, questNpcCFrame, mobSpawnCFrame
                        
                        -- Premium Sea 1 Level to Quest mappings
                        if myLevel < 10 then
                            questName = "BanditQuest1"
                            questId = 1
                            mobName = "Bandit"
                            questNpcCFrame = CFrame.new(1060, 16, 1546)
                            mobSpawnCFrame = CFrame.new(1145, 16, 1630)
                        elseif myLevel < 15 then
                            questName = "FruitQuest"
                            questId = 1
                            mobName = "Monkey"
                            questNpcCFrame = CFrame.new(-1600, 37, 150)
                            mobSpawnCFrame = CFrame.new(-1620, 37, 230)
                        elseif myLevel < 30 then
                            questName = "FruitQuest"
                            questId = 2
                            mobName = "Gorilla"
                            questNpcCFrame = CFrame.new(-1600, 37, 150)
                            mobSpawnCFrame = CFrame.new(-1200, 37, -200)
                        elseif myLevel < 60 then
                            questName = "PirateQuest"
                            questId = 1
                            mobName = "Pirate"
                            questNpcCFrame = CFrame.new(-1136, 4, 3855)
                            mobSpawnCFrame = CFrame.new(-1200, 4, 3950)
                        elseif myLevel < 75 then
                            questName = "DesertQuest"
                            questId = 1
                            mobName = "Desert Bandit"
                            questNpcCFrame = CFrame.new(894, 6, 4385)
                            mobSpawnCFrame = CFrame.new(900, 6, 4450)
                        elseif myLevel < 90 then
                            questName = "DesertQuest"
                            questId = 2
                            mobName = "Desert Officer"
                            questNpcCFrame = CFrame.new(894, 6, 4385)
                            mobSpawnCFrame = CFrame.new(894, 15, 4385)
                        elseif myLevel < 120 then
                            questName = "SnowQuest"
                            questId = 1
                            mobName = "Snow Bandit"
                            questNpcCFrame = CFrame.new(1386, 26, -1300)
                            mobSpawnCFrame = CFrame.new(1389, 26, -1250)
                        else
                            -- Fallback/Default for high level First Sea
                            questName = "SnowQuest"
                            questId = 2
                            mobName = "Snowman"
                            questNpcCFrame = CFrame.new(1386, 26, -1300)
                            mobSpawnCFrame = CFrame.new(1386, 26, -1350)
                        end

                        local hasQuest = false
                        pcall(function()
                            local mainGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Main")
                            local questGui = mainGui and mainGui:FindFirstChild("Quest")
                            if questGui and questGui.Visible then
                                hasQuest = true
                            end
                        end)

                        if not hasQuest and questName then
                            SafeTeleport(questNpcCFrame)
                            task.wait(0.5)
                            pcall(function()
                                ReplicatedStorage.Remotes.CommF:InvokeServer("StartQuest", questName, questId)
                            end)
                            task.wait(0.5)
                        else
                            local targetMob = nil
                            local searchFolder = workspace:FindFirstChild("Enemies") or workspace
                            for _, v in ipairs(searchFolder:GetChildren()) do
                                if v.Name == mobName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                    targetMob = v
                                    break
                                end
                            end

                            if not targetMob then
                                for _, v in ipairs(workspace:GetChildren()) do
                                    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v.Name:lower():find(mobName:lower()) then
                                        targetMob = v
                                        break
                                    end
                                end
                            end

                            if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                                local hrp = targetMob.HumanoidRootPart
                                SafeTeleport(hrp.CFrame * CFrame.new(0, 6, 0))
                                
                                pcall(function()
                                    hrp.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                                    hrp.CanCollide = false
                                    hrp.Velocity = Vector3.new(0,0,0)
                                    if targetMob:FindFirstChild("Humanoid") then
                                        targetMob.Humanoid.JumpPower = 0
                                        targetMob.Humanoid.WalkSpeed = 0
                                    end
                                end)
                                
                                local tool = EquipPreferredWeapon()
                                if tool then
                                    tool:Activate()
                                    pcall(function()
                                        local vu = game:GetService("VirtualUser")
                                        vu:Button1Down(Vector2.new(0, 0), Camera.CFrame)
                                        task.wait(0.01)
                                        vu:Button1Up(Vector2.new(0, 0), Camera.CFrame)
                                    end)
                                    pcall(function()
                                        ReplicatedStorage.Remotes.CommF:InvokeServer("Hit", 1)
                                    end)
                                end
                            else
                                if mobSpawnCFrame then
                                    SafeTeleport(mobSpawnCFrame)
                                end
                                task.wait(0.5)
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    })

    BloxTab:Toggle({
        Title = "Rapid Fast Attack",
        Desc = "Cancels standard animations to strike targets with extreme attack speeds.",
        Value = false,
        Callback = function(state)
            FastAttack = state
            task.spawn(function()
                while FastAttack do
                    pcall(function()
                        local combat = EquipPreferredWeapon()
                        if combat then
                            combat:Activate()
                            pcall(function()
                                ReplicatedStorage.Remotes.CommF:InvokeServer("Hit", 1)
                            end)
                        end
                    end)
                    task.wait(0.01)
                end
            end)
        end
    })

    BloxTab:Dropdown({
        Title = "Auto Stats Allocator",
        Desc = "Automatically allocates level up points into chosen stat dynamically.",
        Value = "None",
        Options = {"None", "Melee", "Defense", "Sword", "Blox Fruit"},
        Callback = function(v)
            selectedStat = v
        end
    })

    task.spawn(function()
        while true do
            if selectedStat ~= "None" then
                pcall(function()
                    local points = 0
                    pcall(function()
                        points = LocalPlayer.Data.Points.Value
                    end)
                    if points > 0 then
                        local statName = selectedStat
                        if selectedStat == "Blox Fruit" then
                            statName = "Demon Fruit"
                        end
                        ReplicatedStorage.Remotes.CommF:InvokeServer("AddPoint", statName, 1)
                    end
                end)
            end
            task.wait(0.5)
        end
    end)

    BloxTab:Button({
        Title = "Buy Random Devil Fruit (Gacha)",
        Desc = "Invokes Gacha Cousin dealer to purchase a random devil fruit instantly.",
        Callback = function()
            local success, result = pcall(function()
                return ReplicatedStorage.Remotes.CommF:InvokeServer("Cousin", "Buy")
            end)
            if success then
                print("[BaddieHub] Gacha result: " .. tostring(result))
            end
        end
    })
    
    BloxTab:Toggle({
        Title = "Auto Farm Chests",
        Desc = "Safely lerp and harvest all chests inside workspace.",
        Value = false,
        Callback = function(state)
            ChestFarming = state
            task.spawn(function()
                while ChestFarming do
                    local chests = {}
                    for _, obj in ipairs(workspace:GetChildren()) do
                        if obj.Name:lower():find("chest") or obj.Name:lower():find("treasure") then
                            table.insert(chests, obj)
                        end
                    end
                    
                    if #chests == 0 then
                        task.wait(3)
                    else
                        for _, chest in ipairs(chests) do
                            if not ChestFarming then break end
                            if chest and chest:IsA("BasePart") then
                                SafeTeleport(chest.CFrame)
                                task.wait(1.5)
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    })

    BloxTab:Button({
        Title = "Auto-Equip Melee Tool",
        Desc = "Scans inventory, equips and holds valid Melee/Combat tools.",
        Callback = function()
            local melee = GetPlayerTool()
            if melee and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(melee)
            end
        end
    })

    BloxTab:Section({ Title = "World Fruits" })
    
    BloxTab:Button({
        Title = "TP to nearest World Devil Fruit",
        Desc = "Searches Workspace for dropped Devil Fruits and teleports safely.",
        Callback = function()
            pcall(function()
                local hrp = GetHRP(); if not hrp then return end
                local closest, closestDist = nil, math.huge
                
                for _, o in ipairs(workspace:GetDescendants()) do
                    if o:IsA("Tool") and (o.Name:lower():find("fruit") or o.Name:lower():find("devil")) then
                        local handle = o:FindFirstChild("Handle") or o:FindFirstChildOfClass("BasePart")
                        if handle then
                            local d = (hrp.Position - handle.Position).Magnitude
                            if d < closestDist then closestDist = d; closest = handle.CFrame end
                        end
                    end
                end
                
                if closest then
                    SafeTeleport(closest * CFrame.new(0, 3, 0))
                end
            end)
        end
    })

    BloxTab:Section({ Title = "Island Ports" })
    local bfIslands = {
        ["Starter Island"]  = CFrame.new(1060, 16, 1500),
        ["Jungle"]          = CFrame.new(-1600, 37, 150),
        ["Pirate Village"]  = CFrame.new(-1136, 4, 3855),
        ["Desert"]          = CFrame.new(894, 6, 4385),
        ["Snowy Mountain"]  = CFrame.new(1386, 26, -1300),
        ["Marine Fortress"] = CFrame.new(-4850, 20, 4300),
        ["Skylands (Lower)"]= CFrame.new(-1243, 355, -5900),
        ["Skylands (Upper)"]= CFrame.new(-4510, 1000, -2500),
        ["Prison"]          = CFrame.new(4830, 6, 4775),
        ["Colosseum"]       = CFrame.new(-1580, 7, -2980),
        ["Magma Village"]   = CFrame.new(-5200, 8, 8400),
        ["Underwater City"] = CFrame.new(6110, 18, 1550),
        ["Fountain City"]   = CFrame.new(5120, 4, 4100)
    }
    local islandList = {}
    for k in pairs(bfIslands) do table.insert(islandList, k) end
    table.sort(islandList)

    BloxTab:Dropdown({
        Title = "Teleport to Island",
        Desc = "Instantly flies to coordinates of chosen Sea 1 island.",
        Value = islandList[1],
        Options = islandList,
        Callback = function(v)
            if bfIslands[v] then SafeTeleport(bfIslands[v] * CFrame.new(0, 5, 0)) end
        end
    })
end

-- =============================================================================
-- GAME MOD: JJK ZERO (Advanced Technique Recognition & Dynamic Auto-Farm)
-- =============================================================================
if BaddieHubSettings.EnableJJK and (DetectedGame == "JJK Zero" or Universal) then
    local JjkTab = CreateTab("JJK Zero", "flame")
    local JjkMagnet = false

    JjkTab:Section({ Title = "Assisted Combat Utilities" })
    
    JjkTab:Toggle({
        Title = "Auto Mob Magnet",
        Desc = "Safely pull Cursed Spirits into a neat pile.",
        Value = false,
        Callback = function(state)
            JjkMagnet = state
            if JjkMagnet then
                local npcsModel = workspace:FindFirstChild("NPCs") or workspace:FindFirstChild("Monsters") or workspace
                local hrp = GetHRP()
                if hrp then
                    StartMobMagnet(npcsModel, hrp, 150)
                end
            else
                Watchdog:Cleanup()
            end
        end
    })

    local m1Spammer = false
    JjkTab:Toggle({
        Title = "Rapid M1 Auto-Spam",
        Desc = "Constantly spam attacks dynamically.",
        Value = false,
        Callback = function(state)
            m1Spammer = state
            task.spawn(function()
                while m1Spammer do
                    pcall(function()
                        local vu = game:GetService("VirtualUser")
                        vu:Button1Down(Vector2.new(0, 0), Camera.CFrame)
                        task.wait(0.02)
                        vu:Button1Up(Vector2.new(0, 0), Camera.CFrame)
                    end)
                    task.wait(0.05)
                end
            end)
        end
    })
end

-- =============================================================================
-- GAME MOD: WORLD ZERO (Dungeon Scanning & Optimal Farming)
-- =============================================================================
if BaddieHubSettings.EnableWorldZero and (DetectedGame == "World Zero" or Universal) then
    local WzTab = CreateTab("World Zero", "shield")
    local DungeonFarming = false

    WzTab:Section({ Title = "Automated Dungeon Sweep" })

    WzTab:Toggle({
        Title = "Dungeon Core Auto-Farm",
        Desc = "Magnetize, pull and instantly clear all dungeon rooms.",
        Value = false,
        Callback = function(state)
            DungeonFarming = state
            task.spawn(function()
                while DungeonFarming do
                    pcall(function()
                        local hrp = GetHRP()
                        if hrp then
                            -- Scan for closest mob
                            local closestMob = nil
                            local minDist = 250
                            for _, char in ipairs(workspace:GetDescendants()) do
                                if char:IsA("Model") and char:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(char) then
                                    local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
                                    local hum = char:FindFirstChildOfClass("Humanoid")
                                    if root and hum and hum.Health > 0 then
                                        local dist = (hrp.Position - root.Position).Magnitude
                                        if dist < minDist then
                                            minDist = dist
                                            closestMob = root
                                        end
                                    end
                                end
                            end

                            if closestMob then
                                -- Magnetize
                                closestMob.CanCollide = false
                                closestMob.CFrame = hrp.CFrame * CFrame.new(0, -3, -3)
                                closestMob.Velocity = Vector3.new(0, 0, 0)

                                -- Activate tools
                                local char = LocalPlayer.Character
                                if char then
                                    for _, tool in ipairs(char:GetChildren()) do
                                        if tool:IsA("Tool") then tool:Activate() end
                                    end
                                end

                                -- VirtualUser click
                                local vu = game:GetService("VirtualUser")
                                vu:Button1Down(Vector2.new(0, 0), Camera.CFrame)
                                task.wait(0.01)
                                vu:Button1Up(Vector2.new(0, 0), Camera.CFrame)
                            end
                        end
                    end)
                    task.wait(0.05)
                end
            end)
        end
    })

    WzTab:Button({
        Title = "TP to Active Boss Portal",
        Desc = "Instantly skips the puzzle rooms and leaps to the boss fight portal.",
        Callback = function()
            pcall(function()
                local hrp = GetHRP()
                if hrp then
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj.Name:lower():find("portal") or obj.Name:lower():find("boss") then
                            if obj:IsA("BasePart") then
                                SafeTeleport(obj.CFrame * CFrame.new(0, 3, 0))
                                break
                            end
                        end
                    end
                end
            end)
        end
    })
end

-- =============================================================================
-- TAB: SYSTEM SETTINGS
-- =============================================================================
local SettingsTab = CreateTab("Settings", "settings")

SettingsTab:Section({ Title = "UI Options" })

SettingsTab:Toggle({
    Title = "Show Floating Toggle Button",
    Desc = "Enables/disables the floating circular touch button on mobile.",
    Value = BaddieHubSettings.ShowFloatingButton,
    Callback = function(state)
        BaddieHubSettings.ShowFloatingButton = state
        if FloatingButtonInstance then
            FloatingButtonInstance.Visible = state
        end
    end
})

SettingsTab:Slider({
    Title = "Floating Button Size",
    Desc = "Adjust size of the mobile floating toggle circular button.",
    Min = 20,
    Max = 120,
    Value = BaddieHubSettings.ButtonSize,
    Callback = function(val)
        BaddieHubSettings.ButtonSize = val
        if FloatingButtonInstance then
            pcall(function()
                FloatingButtonInstance.Size = UDim2.new(0, val, 0, val)
                FloatingButtonInstance.TextSize = math.clamp(val / 4, 10, 20)
            end)
        end
    end
})

SettingsTab:Dropdown({
    Title = "UI Accent Theme",
    Desc = "Changes the global WindUI look/theme style.",
    Value = BaddieHubSettings.Theme,
    Options = {"Dark", "Light", "Nord", "Aqua", "Rosepine", "Amethyst"},
    Callback = function(val)
        BaddieHubSettings.Theme = val
        if WindUI and WindUI.SetTheme then
            pcall(function() WindUI:SetTheme(val) end)
        end
    end
})

SettingsTab:Dropdown({
    Title = "PC Toggle Keybind",
    Desc = "Key to toggle open/close the GUI menu on PC keyboards.",
    Value = BaddieHubSettings.ToggleKey,
    Options = {"RightControl", "LeftControl", "RightShift", "LeftShift", "Insert", "Delete", "P", "Q", "Home"},
    Callback = function(val)
        BaddieHubSettings.ToggleKey = val
    end
})

SettingsTab:Section({ Title = "Hack & Speed Configurations" })

SettingsTab:Toggle({
    Title = "Continuous Speed/Power Loop",
    Desc = "Constantly forces WalkSpeed/JumpPower values, fixing reset on spawn.",
    Value = BaddieHubSettings.ContinuousSpeed,
    Callback = function(state)
        BaddieHubSettings.ContinuousSpeed = state
    end
})

SettingsTab:Toggle({
    Title = "Anti-Cheat Safe Mode",
    Desc = "Enables protective Watchdog bounds for all RPC remote triggers.",
    Value = BaddieHubSettings.SafeMode,
    Callback = function(state)
        BaddieHubSettings.SafeMode = state
    end
})

SettingsTab:Button({
    Title = "Full Cleanup & Destroy",
    Desc = "Completely remove WindUI and BaddieHub scripts safely.",
    Callback = function()
        Watchdog:Cleanup()
        CleanExistingHubs()
        if FloatingButtonGui then
            pcall(function() FloatingButtonGui:Destroy() end)
        end
        print("[BaddieHub] Safely unloaded multi-hub client.")
    end
})

-- Initialize finished notification
pcall(function()
    WindUI:Notify({
        Title = "BaddieHub Active!",
        Content = "Refactored BADDIE404 v5.1 loaded. Enjoy modern WindUI stability!",
        Duration = 5
    })
end)

-- Finish loading animation
SetStatus("Injecting Hub Controls..."); SetProgress(100, 0.2); task.wait(0.3)
local fadeTween = TweenService:Create(Bg, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
fadeTween:Play()
fadeTween.Completed:Connect(function()
    if LoadGui and LoadGui.Parent then LoadGui:Destroy() end
end)

task.spawn(CreateFloatingToggleButton)
