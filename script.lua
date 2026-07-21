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
    EnableWorldZero = true
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
    l.TextXAlignment = alignX or Enum.TextXAlignment.Left
    return l
end

MkLabel(Card, UDim2.new(0,24,0,20),  UDim2.new(1,-48,0,28), "BADDIE404 MULTIHUB", 22, Enum.Font.GothamBold, Color3.new(1,1,1))
MkLabel(Card, UDim2.new(0,24,0,48),  UDim2.new(1,-48,0,16), "v5.1 - Senior Developer WindUI Edition", 12, nil, BaddieHubSettings.AccentColor)
local StatusL = MkLabel(Card, UDim2.new(0,24,0,84), UDim2.new(1,-48,0,16), "Initializing Engine...", 12, nil, Color3.fromRGB(170,165,200))

local Track = Instance.new("Frame", Card)
Track.Position = UDim2.new(0,24,0,112); Track.Size = UDim2.new(1,-48,0,8)
Track.BackgroundColor3 = Color3.fromRGB(30,28,40); Track.BorderSizePixel = 0
Instance.new("UICorner", Track).CornerRadius = UDim.new(1,0)

local Fill = Instance.new("Frame", Track)
Fill.Size = UDim2.fromScale(0, 1)
Fill.BackgroundColor3 = BaddieHubSettings.AccentColor
Fill.BorderSizePixel = 0; Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0)

local PctL = MkLabel(Card, UDim2.new(0,24,0,126), UDim2.new(1,-48,0,14), "0%", 11, Enum.Font.GothamBold, BaddieHubSettings.AccentColor, Enum.TextXAlignment.Right)

local function SetProgress(pct, dur)
    TweenService:Create(Fill, TweenInfo.new(dur or 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.fromScale(pct/100, 1)}):Play()
    PctL.Text = pct .. "%"
end
local function SetStatus(t) StatusL.Text = t end

-- =============================================================================
-- REVERSE-ENGINEERED GAME DETECTION (PlaceId & Marketplace Metadata Fallback)
-- =============================================================================
SetStatus("Analyzing Universe IDs..."); SetProgress(30, 0.2); task.wait(0.2)
local Games = {
    ["Blox Fruits"] = {275391513, 4442272121, 7449423635, 11349191060, 2753915549, 5261459311},
    ["JJK Zero"]    = {7973578035, 8049346128, 7901843281},
    ["World Zero"]  = {4157004456, 4616238637, 4616888069},
}
local DetectedGame = nil
for name, ids in pairs(Games) do
    for _, id in ipairs(ids) do
        if id == PlaceId then DetectedGame = name; break end
    end
    if DetectedGame then break end
end

-- Fallback game-name scan via MarketplaceService
if not DetectedGame then
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(PlaceId)
    end)
    if success and info then
        local lowerName = info.Name:lower()
        if lowerName:find("blox fruit") or lowerName:find("blox-fruit") then
            DetectedGame = "Blox Fruits"
        elseif lowerName:find("jjk") or lowerName:find("jujutsu") or lowerName:find("zero") and lowerName:find("jjk") then
            DetectedGame = "JJK Zero"
        elseif lowerName:find("world zero") or lowerName:find("world-zero") then
            DetectedGame = "World Zero"
        end
    end
end

local Universal = not DetectedGame
if Universal then DetectedGame = "Universal" end
SetStatus("Detected Sandbox Game: " .. DetectedGame); SetProgress(60, 0.3); task.wait(0.3)

-- [4. WindUI Official Loader Setup]
SetStatus("Injecting Footagesus WindUI Assets..."); SetProgress(85, 0.2); task.wait(0.2)
local WindUI, Window
local loaderSuccess, loaderErr = pcall(function()
    local httpResponse = nil
    local getSuccess, getErr = pcall(function()
        if game.HttpGet then
            httpResponse = game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
        elseif HttpGet then
            httpResponse = HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
        end
    end)
    
    if getSuccess and httpResponse and #httpResponse > 0 then
        local loadFunc, loadErr = loadstring(httpResponse)
        if loadFunc then
            local runSuccess, runResult = pcall(loadFunc)
            if runSuccess and runResult then
                WindUI = runResult
            else
                error("WindUI execution error: " .. tostring(runResult or "unknown"))
            end
        else
            error("WindUI compilation error: " .. tostring(loadErr or "unknown"))
        end
    else
        error("WindUI fetch error: " .. tostring(getErr or "empty response"))
    end

    Window = WindUI:CreateWindow({
        Title = "BADDIE404 MULTIHUB",
        Subtitle = DetectedGame .. " Mode",
        Author = "Baddie404 Team",
        Folder = "BaddieHub_Config",
        Size = UDim2.fromOffset(580, 460),
        Transparent = true,
        Theme = BaddieHubSettings.Theme
    })
    
    if WindUI.SetTheme then
        pcall(function()
            WindUI:SetTheme({
                Accent = BaddieHubSettings.AccentColor
            })
        end)
    end
end)

if not loaderSuccess or not WindUI then
    warn("[BaddieHub] WindUI Library failure: " .. tostring(loaderErr))
    SetStatus("Network block! Check Roblox executor."); SetProgress(100, 0.5); task.wait(2)
    LoadGui:Destroy()
    return
end

-- Compatibility helper to wrap any tab control methods dynamically using a safe proxy wrapper
local function CreateTab(title, icon)
    local realTab = nil
    pcall(function()
        realTab = Window:Tab({
            Title = title,
            Icon = icon or "grid"
        })
    end)
    
    -- We return a proxy table that intercepts all method calls
    local safeTab = {}
    
    -- Define safety wrapper for adding elements
    local function wrapMethod(methodName)
        return function(self, options, ...)
            if not realTab then
                warn("[BaddieHub SafeTab] Cannot call '" .. methodName .. "' because realTab is nil")
                return nil
            end
            
            -- Find the actual method on the real tab
            local method = realTab[methodName]
            if not method then
                -- Check alternative names
                local alternatives = {
                    Button = "AddButton", AddButton = "Button",
                    Toggle = "AddToggle", AddToggle = "Toggle",
                    Slider = "AddSlider", AddSlider = "Slider",
                    Dropdown = "AddDropdown", AddDropdown = "Dropdown",
                    TextBox = "AddTextbox", AddTextbox = "TextBox", AddTextBox = "TextBox", TextBox = "AddTextBox",
                    Keybind = "AddKeybind", AddKeybind = "Keybind", AddBind = "Keybind", Bind = "Keybind",
                    Section = "AddSection", AddSection = "Section"
                }
                local altName = alternatives[methodName]
                if altName then
                    method = realTab[altName]
                end
            end
            
            if not method then
                warn("[BaddieHub SafeTab] Method '" .. methodName .. "' does not exist on tab")
                return nil
            end
            
            local args = {...}
            -- Call the method safely inside pcall
            local success, result = pcall(function()
                return method(realTab, options, unpack(args))
            end)
            
            if not success then
                warn("[BaddieHub SafeTab] Error calling '" .. methodName .. "': " .. tostring(result))
                
                -- Fallback: if options is a table, check if the library expected positional parameters or vice versa,
                -- or just try to invoke it with common parameters.
                if type(options) == "table" then
                    -- If we passed Value but it expects Default, copy Value to Default and vice-versa
                    if options.Value and not options.Default then
                        options.Default = options.Value
                    elseif options.Default and not options.Value then
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

-- [5. Create Floating Toggle Button for Mobile Executors]
local function CreateFloatingToggleButton()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BaddieHubToggleButtonGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, BaddieHubSettings.ButtonSize, 0, BaddieHubSettings.ButtonSize)
    Button.Position = UDim2.new(0.05, 0, 0.25, 0)
    Button.BackgroundColor3 = BaddieHubSettings.ButtonColor
    Button.Text = BaddieHubSettings.ButtonLabel
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.Parent = ScreenGui

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
    Title = "Toggle Fly Hack",
    Desc = "Fly smoothly using camera directions.",
    Value = false,
    Callback = function(state)
        ToggleFly(state)
    end
})

HomeTab:Slider({
    Title = "Fly Flight Speed",
    Desc = "Adjust standard fly velocity limit.",
    Min = 16,
    Max = 250,
    Value = FlySpeed,
    Callback = function(val)
        FlySpeed = val
    end
})

local InfJumpConnection
HomeTab:Toggle({
    Title = "Infinite Jump Protocol",
    Desc = "Fly vertically in the sky dynamically.",
    Value = false,
    Callback = function(state)
        if InfJumpConnection then InfJumpConnection:Disconnect(); InfJumpConnection = nil end
        if state then
            InfJumpConnection = UserInputService.JumpRequest:Connect(function()
                pcall(function()
                    local hrp = GetHRP()
                    if hrp then
                        hrp.Velocity = Vector3.new(hrp.Velocity.X, BaddieHubSettings.JumpPower, hrp.Velocity.Z)
                    end
                end)
            end)
            table.insert(Watchdog.Connections, InfJumpConnection)
        end
    end
})

-- [Tab B: Universal ESP Visuals]
local EspTab = CreateTab("Visuals (ESP)", "eye")
local EspEnabled = false
local EspFolder = CoreGui:FindFirstChild("BaddieESPFolder") or Instance.new("Folder", CoreGui)
EspFolder.Name = "BaddieESPFolder"

local function ApplyESP(player)
    if player == LocalPlayer then return end
    
    local function HandleCharacter(char)
        task.wait(0.5)
        if not EspEnabled then return end
        local hrp = char:WaitForChild("HumanoidRootPart", 10)
        if not hrp then return end

        local box = Instance.new("BoxHandleAdornment")
        box.Name = "BaddieESPBox"
        box.Size = Vector3.new(4, 6, 4)
        box.Color3 = BaddieHubSettings.AccentColor
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Adornee = hrp
        box.Parent = EspFolder

        local tag = Instance.new("BillboardGui")
        tag.Name = "BaddieESPTag"
        tag.Size = UDim2.new(0, 200, 0, 50)
        tag.Adornee = hrp
        tag.AlwaysOnTop = true
        tag.Parent = EspFolder

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.TextStrokeTransparency = 0
        text.Text = player.Name
        text.Font = Enum.Font.GothamBold
        text.TextSize = 11
        text.Parent = tag

        local distConn
        distConn = RunService.Heartbeat:Connect(function()
            if EspEnabled and char and char:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = math.floor((char.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                text.Text = player.Name .. " [" .. dist .. "m]"
            else
                distConn:Disconnect()
                box:Destroy()
                tag:Destroy()
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

-- [Tab C: Teleport Settings]
local TeleportTab = CreateTab("Teleports", "map")
local selectedPlayerTp = ""

local function GetOtherPlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    if #list == 0 then table.insert(list, "(no other players)") end
    return list
end

TeleportTab:Dropdown({
    Title = "Select Target Player",
    Desc = "Target player for smooth interpolation transport.",
    Value = "",
    Options = GetOtherPlayers(),
    Callback = function(val)
        selectedPlayerTp = val
    end
})

TeleportTab:Button({
    Title = "Safe TP to Player",
    Desc = "Executes safe linear interpolation flight to selected player.",
    Callback = function()
        if selectedPlayerTp ~= "" and selectedPlayerTp ~= "(no other players)" then
            local targetPlayer = Players:FindFirstChild(selectedPlayerTp)
            if targetPlayer and targetPlayer.Character then
                local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    SafeTeleport(hrp.CFrame * CFrame.new(0, 3, 0))
                end
            end
        end
    end
})

-- =============================================================================
-- GAME MOD: BLOX FRUITS (Highly Optimized Module)
-- =============================================================================
if BaddieHubSettings.EnableBloxFruits and (DetectedGame == "Blox Fruits" or Universal) then
    local BloxTab = CreateTab("Blox Fruits", "sword")
    local ChestFarming = false
    
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
                                closestMob.CanCollide = false
                                closestMob.CFrame = hrp.CFrame * CFrame.new(0, -3, -3)
                                closestMob.Velocity = Vector3.new(0, 0, 0)

                                local char = LocalPlayer.Character
                                if char then
                                    for _, tool in ipairs(char:GetChildren()) do
                                        if tool:IsA("Tool") then tool:Activate() end
                                    end
                                end

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

SettingsTab:Button({
    Title = "Full Cleanup & Destroy",
    Desc = "Completely remove WindUI and BaddieHub scripts safely.",
    Callback = function()
        Watchdog:Cleanup()
        CleanExistingHubs()
        print("[BaddieHub] Safely unloaded multi-hub client.")
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
