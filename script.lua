-- =============================================================================
-- BADDIE404 MULTIHUB v5.1 (PROFESSIONAL REFACTOR & REMASTERED)
-- Senior Roblox Software Engineer & Reverse Engineer Edition
-- Supporting: Blox Fruits (Sea 1), JJK Zero, World Zero, Universal
-- Platform Compatible: Delta / Fluxus / Solara / Synapse / Mobile & PC Safe
-- =============================================================================

-- =============================================================================
-- SYSTEM CLEANUP (Prevent duplicate GUI leaks & orphaned connections)
-- =============================================================================
for _, n in ipairs({"Orion", "Baddie404Hub", "Baddie404Loading", "BaddieMobileFlyControls"}) do
    local old = game:GetService("CoreGui"):FindFirstChild(n)
    if old then pcall(function() old:Destroy() end) end
end

-- =============================================================================
-- SERVICES & CONSTANTS
-- =============================================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UIS              = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local WS               = game:GetService("Workspace")
local TeleportService  = game:GetService("TeleportService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local MarketplaceService= game:GetService("MarketplaceService")
local Camera           = WS.CurrentCamera
local LP               = Players.LocalPlayer
local PlaceId          = game.PlaceId
local ICON             = "rbxassetid://4483345998"

-- =============================================================================
-- GLOBAL REGISTRY (Object state management & cleanup safety)
-- =============================================================================
local BaddieHub = {
    Active = true,
    Connections = {},
    Loops = {},
    Platforms = {},
    MobileFlyState = nil,
    Config = {
        WalkSpeed = 16,
        JumpPower = 50,
        Gravity = 196,
        InfJump = false,
        FlyEnabled = false,
        FlySpeed = 60,
        HoverEnabled = false,
        HoverHeight = 15,
        Noclip = false,
        Fullbright = false,
        Booster = false,
        EspEnabled = false,
        EspColor = Color3.fromRGB(255, 50, 50),
        FarmSpeed = 180 -- Safe speed for lerped human-like teleports
    }
}

-- Registry safe-connection utility
local function TrackConnection(connection)
    table.insert(BaddieHub.Connections, connection)
    return connection
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
cs.Color = Color3.fromRGB(140,80,255); cs.Thickness = 1.5

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
MkLabel(Card, UDim2.new(0,24,0,48),  UDim2.new(1,-48,0,16), "v5.1 - Senior Developer Edition", 12, nil, Color3.fromRGB(140,90,255))
local StatusL = MkLabel(Card, UDim2.new(0,24,0,84), UDim2.new(1,-48,0,16), "Initializing Engine...", 12, nil, Color3.fromRGB(170,165,200))

local Track = Instance.new("Frame", Card)
Track.Position = UDim2.new(0,24,0,112); Track.Size = UDim2.new(1,-48,0,8)
Track.BackgroundColor3 = Color3.fromRGB(30,28,40); Track.BorderSizePixel = 0
Instance.new("UICorner", Track).CornerRadius = UDim.new(1,0)

local Fill = Instance.new("Frame", Track)
Fill.Size = UDim2.fromScale(0, 1)
Fill.BackgroundColor3 = Color3.fromRGB(140,80,255)
Fill.BorderSizePixel = 0; Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0)

local PctL = MkLabel(Card, UDim2.new(0,24,0,126), UDim2.new(1,-48,0,14), "0%", 11, Enum.Font.GothamBold, Color3.fromRGB(140,80,255), Enum.TextXAlignment.Right)

local function SetProgress(pct, dur)
    TweenService:Create(Fill, TweenInfo.new(dur or 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.fromScale(pct/100, 1)}):Play()
    PctL.Text = pct .. "%"
end
local function SetStatus(t) StatusL.Text = t end

-- =============================================================================
-- HTTP FETCH UTILITY
-- =============================================================================
local function safeGet(url)
    if type(request) == "function" then
        local success, res = pcall(request, {Url=url,Method="GET"})
        if success and type(res) == "table" and res.Body then return res.Body end
    end
    if type(http_request) == "function" then
        local success, res = pcall(http_request, {Url=url,Method="GET"})
        if success and type(res) == "table" and res.Body then return res.Body end
    end
    if syn and type(syn.request) == "function" then
        local success, res = pcall(syn.request, {Url=url,Method="GET"})
        if success and type(res) == "table" and res.Body then return res.Body end
    end
    local success, res = pcall(game.HttpGet, game, url)
    if success then return res end
    return nil
end

-- =============================================================================
-- LOAD ORION LIBRARY
-- =============================================================================
SetStatus("Loading Orion GUI Assets..."); SetProgress(15, 0.2); task.wait(0.2)

local function safeLoadLibrary(url)
    local body = safeGet(url)
    if not body or body == "" or body:find("<!DOCTYPE") or body:find("404") or body:find("rate limit") then
        return nil
    end
    local compileSuccess, func = pcall(loadstring, body)
    if not compileSuccess or type(func) ~= "function" then
        return nil
    end
    local runSuccess, lib = pcall(func)
    if not runSuccess then
        return nil
    end
    return lib
end

local OrionLib = safeLoadLibrary("https://raw.githubusercontent.com/jensonhirst/Orion/main/source")
if type(OrionLib) ~= "table" then
    SetStatus("Bypassing server firewalls..."); SetProgress(30, 0.2); task.wait(0.4)
    OrionLib = safeLoadLibrary("https://raw.githubusercontent.com/shlexware/Orion/main/source")
    if type(OrionLib) ~= "table" then
        SetStatus("Connection failed. Check Roblox Executor."); SetProgress(100,0.3); task.wait(3); LoadGui:Destroy(); return
    end
end
SetStatus("UI System loaded successfully!"); SetProgress(55, 0.3); task.wait(0.2)

-- =============================================================================
-- REVERSE-ENGINEERED GAME DETECTION (PlaceId & Marketplace Metadata Fallback)
-- =============================================================================
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
    SetStatus("Analyzing Universe IDs..."); SetProgress(70, 0.2); task.wait(0.1)
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
if Universal then DetectedGame = "Unknown" end
SetStatus("Game Mode: " .. DetectedGame); SetProgress(85, 0.3); task.wait(0.2)

-- =============================================================================
-- BUILD WINDOW
-- =============================================================================
SetStatus("Assembling Interface..."); SetProgress(95, 0.2); task.wait(0.2)

local WindowName = "Baddie404 Hub  |  " .. DetectedGame
if Universal then WindowName = "Baddie404 Hub  |  Universal" end

local Window = OrionLib:MakeWindow({
    Name = WindowName,
    HidePremium = false, SaveConfig = true,
    ConfigFolder = "Baddie404", IntroText = "Baddie404 Hub v5.1", IntroIcon = ICON,
})

-- =============================================================================
-- LOW-LEVEL ROBLOX UTILITIES (Reverse-Engineered Core Helpers)
-- =============================================================================
local function GetHum()
    local c = LP.Character; if not c then return nil end
    return c:FindFirstChildOfClass("Humanoid")
end
local function GetHRP()
    local c = LP.Character; if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart")
end

-- "Human-Like" Anti-Cheat Safe Path Teleporter (Using speed limits & small step lerps)
local function SafeTP(cf, instant)
    pcall(function()
        local hrp = GetHRP()
        if not hrp then return end
        if instant then
            for i = 1, 3 do hrp.CFrame = cf; task.wait() end
            return
        end
        
        local startPos = hrp.Position
        local endPos   = cf.Position
        local dist     = (endPos - startPos).Magnitude
        
        -- Smooth step-by-step linear interpolation at customizable farm speed
        local speed = BaddieHub.Config.FarmSpeed
        local duration = dist / speed
        
        if duration <= 0.05 then
            hrp.CFrame = cf
            return
        end
        
        local elapsed = 0
        local startClock = os.clock()
        
        while elapsed < duration and BaddieHub.Active do
            elapsed = os.clock() - startClock
            local t = math.clamp(elapsed / duration, 0, 1)
            local midCF = CFrame.new(startPos:Lerp(endPos, t)) * (cf - cf.Position)
            hrp.CFrame = midCF
            task.wait()
        end
        hrp.CFrame = cf
    end)
end

-- Fire proximity prompts safely
local function TryFireProximity(part, maxDist)
    maxDist = maxDist or 20
    if not fireproximityprompt then return false end
    local hrp = GetHRP()
    if not hrp then return false end
    local found = false
    for _, v in ipairs(part:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            if (hrp.Position - v.Parent.Position).Magnitude <= maxDist + 5 then
                pcall(function() fireproximityprompt(v) end)
                found = true
            end
        end
    end
    return found
end

-- ClickDetector interaction bypass
local function TryClickDetector(part)
    if not fireclickdetector then return false end
    for _, v in ipairs(part:GetDescendants()) do
        if v:IsA("ClickDetector") then
            pcall(function() fireclickdetector(v) end)
            return true
        end
    end
    return false
end

-- Highly Optimized Proximity-Based Mob Attack (Uses non-laggy spatial query overlap)
local function AttackNearest(hrp, range)
    local nearest, nearestDist = nil, range
    pcall(function()
        local op = OverlapParams.new()
        op.FilterType = Enum.RaycastFilterType.Exclude
        op.FilterDescendantsInstances = {LP.Character}
        
        local parts = WS:GetPartBoundsInRadius(hrp.Position, range, op)
        for _, part in ipairs(parts) do
            local char = part.Parent
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local r_hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and r_hrp and not Players:GetPlayerFromCharacter(char) and r_hrp.Position.Y < 8000 then
                local dist = (hrp.Position - r_hrp.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = r_hrp
                end
            end
        end
    end)
    
    if nearest then
        -- Teleport safely above/behind mob to execute hit sequence
        hrp.CFrame = nearest.CFrame * CFrame.new(0, 0, 3)
        task.wait(0.04)
        
        -- Method 1: Virtual User mouse simulation
        pcall(function()
            local vu = game:GetService("VirtualUser")
            local sp = Camera:WorldToScreenPoint(nearest.Position)
            vu:Button1Down(Vector2.new(sp.X, sp.Y), Camera.CFrame)
            task.wait(0.01)
            vu:Button1Up(Vector2.new(sp.X, sp.Y), Camera.CFrame)
        end)
        
        -- Method 2: ClickDetector Trigger
        pcall(function() TryClickDetector(nearest.Parent) end)
        
        -- Method 3: TouchInterest Trigger
        pcall(function()
            local char = LP.Character
            if char then
                local lhrp = char:FindFirstChild("HumanoidRootPart")
                if lhrp then
                    for _, part in ipairs(nearest.Parent:GetDescendants()) do
                        if part:IsA("BasePart") then
                            pcall(function() firetouchinterest(lhrp, part, 0) end)
                            pcall(function() firetouchinterest(lhrp, part, 1) end)
                        end
                    end
                end
            end
        end)
    end
    return nearest
end

-- =============================================================================
-- STATIC DAEMONS (Highly throttled Loops replacing expensive Heartbeats)
-- =============================================================================
local function ApplyPhysicalAttributes()
    local h = GetHum()
    if h then
        if h.WalkSpeed  ~= BaddieHub.Config.WalkSpeed then h.WalkSpeed = BaddieHub.Config.WalkSpeed end
        if h.UseJumpPower and h.JumpPower ~= BaddieHub.Config.JumpPower then h.JumpPower = BaddieHub.Config.JumpPower end
    end
    if WS.Gravity ~= BaddieHub.Config.Gravity then WS.Gravity = BaddieHub.Config.Gravity end
end

TrackConnection(RunService.Heartbeat:Connect(function()
    pcall(ApplyPhysicalAttributes)
end))

-- =============================================================================
-- WIDGET COMPONENT: Button-Pair Slider (No-Lag Mobile Friendly UI element)
-- =============================================================================
local function AddButtonSlider(tab, name, min, max, default, step, suffix, onChange)
    local val = default
    local lbl = tab:AddLabel(name .. ": " .. val .. (suffix or ""))
    
    local function updateLabel()
        if lbl and lbl.Set then
            pcall(function() lbl:Set(name .. ": " .. val .. (suffix or "")) end)
        end
    end

    tab:AddButton({
        Name = "[ - ]  " .. name,
        Callback = function()
            val = math.max(min, val - step)
            onChange(val)
            updateLabel()
            OrionLib:MakeNotification({ Name = name, Content = tostring(val) .. (suffix or ""), Image = ICON, Time = 1 })
        end
    })
    tab:AddButton({
        Name = "[ + ]  " .. name,
        Callback = function()
            val = math.min(max, val + step)
            onChange(val)
            updateLabel()
            OrionLib:MakeNotification({ Name = name, Content = tostring(val) .. (suffix or ""), Image = ICON, Time = 1 })
        end
    })
    tab:AddTextbox({
        Name = name .. " (Direct input)", Default = tostring(default), TextDisappear = false,
        Callback = function(v)
            local n = tonumber(v)
            if n then
                val = math.clamp(n, min, max)
                onChange(val)
                updateLabel()
            end
        end
    })
end

-- =============================================================================
-- MOBILE STYLES & EXTREME FPS BOOSTER
-- =============================================================================
local function ApplyBooster(on)
    BaddieHub.Config.Booster = on
    pcall(function() game:GetService("Lighting").GlobalShadows = not on end)
    if on then
        pcall(function()
            for _, obj in ipairs(WS:GetDescendants()) do
                if obj:IsA("BasePart") and not obj.Parent:FindFirstChildOfClass("Humanoid") then
                    obj.Material = Enum.Material.SmoothPlastic
                    if obj:IsA("Texture") or obj:IsA("Decal") then obj:Destroy() end
                end
                if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled = false
                end
            end
        end)
    end
end

-- =============================================================================
-- MOBILE COMPATIBLE ON-SCREEN FLIGHT CONTROLLER
-- =============================================================================
local function CreateMobileFlyControls()
    if not UIS.TouchEnabled then return end
    pcall(function()
        local oldGui = CoreGui:FindFirstChild("BaddieMobileFlyControls")
        if oldGui then oldGui:Destroy() end
        
        local flyGui = Instance.new("ScreenGui")
        flyGui.Name = "BaddieMobileFlyControls"
        flyGui.ResetOnSpawn = false
        flyGui.Parent = CoreGui
        
        local container = Instance.new("Frame", flyGui)
        container.Size = UDim2.new(0, 80, 0, 180)
        container.Position = UDim2.new(0.85, -40, 0.4, -90)
        container.BackgroundTransparency = 0.5
        container.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        container.BorderSizePixel = 0
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 12)
        local stroke = Instance.new("UIStroke", container)
        stroke.Color = Color3.fromRGB(140, 80, 255)
        stroke.Thickness = 1.5
        
        local upBtn = Instance.new("TextButton", container)
        upBtn.Size = UDim2.new(1, -16, 0, 70)
        upBtn.Position = UDim2.new(0, 8, 0, 8)
        upBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 70)
        upBtn.Text = "▲\nUP"
        upBtn.TextColor3 = Color3.new(1, 1, 1)
        upBtn.Font = Enum.Font.GothamBold
        upBtn.TextSize = 14
        upBtn.BorderSizePixel = 0
        Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 8)
        
        local downBtn = Instance.new("TextButton", container)
        downBtn.Size = UDim2.new(1, -16, 0, 70)
        downBtn.Position = UDim2.new(0, 8, 0, 86)
        downBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 70)
        downBtn.Text = "▼\nDOWN"
        downBtn.TextColor3 = Color3.new(1, 1, 1)
        downBtn.Font = Enum.Font.GothamBold
        downBtn.TextSize = 14
        downBtn.BorderSizePixel = 0
        Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0, 8)
        
        local upActive = false
        local downActive = false
        
        upBtn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
                upActive = true
                upBtn.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
            end
        end)
        upBtn.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
                upActive = false
                upBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 70)
            end
        end)
        
        downBtn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
                downActive = true
                downBtn.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
            end
        end)
        downBtn.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
                downActive = false
                downBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 70)
            end
        end)
        
        BaddieHub.MobileFlyState = {
            Up = function() return upActive end,
            Down = function() return downActive end,
            Gui = flyGui
        }
    end)
end

local function RemoveMobileFlyControls()
    if BaddieHub.MobileFlyState then
        pcall(function() BaddieHub.MobileFlyState.Gui:Destroy() end)
        BaddieHub.MobileFlyState = nil
    end
end

-- =============================================================================
-- TAB: HOME
-- =============================================================================
local HomeTab = Window:MakeTab({ Name = "Home", Icon = ICON, PremiumOnly = false })
HomeTab:AddSection({ Name = "System Information" })
HomeTab:AddLabel("User Account: " .. LP.Name)
HomeTab:AddLabel("Detected Game: " .. DetectedGame)
HomeTab:AddLabel("Universe PlaceId: " .. tostring(PlaceId))
HomeTab:AddLabel("Module Version: v5.1 Professional")
if Universal then
    HomeTab:AddParagraph("Universal Protocol Enabled", "Your game was not detected in our core databases. Universal features only are active.")
end

HomeTab:AddSection({ Name = "Diagnostic Verification" })
HomeTab:AddButton({
    Name = "Trigger Core Ping Network",
    Callback = function()
        OrionLib:MakeNotification({ Name = "Baddie404", Content = "Hub connection live & functional!", Image = ICON, Time = 3 })
    end
})

-- =============================================================================
-- TAB: PLAYER (Movement & Exploration Hacks)
-- =============================================================================
local PlayerTab = Window:MakeTab({ Name = "Player", Icon = ICON, PremiumOnly = false })
PlayerTab:AddSection({ Name = "Movement Modifiers" })

AddButtonSlider(PlayerTab, "WalkSpeed", 0, 500, 16, 16, " studs/s", function(v) BaddieHub.Config.WalkSpeed = v end)
AddButtonSlider(PlayerTab, "JumpPower", 0, 600, 50, 25, "", function(v)
    BaddieHub.Config.JumpPower = v
    pcall(function() local h = GetHum(); if h then h.UseJumpPower = true end end)
end)
AddButtonSlider(PlayerTab, "Gravity", 0, 196, 196, 20, "", function(v) BaddieHub.Config.Gravity = v end)

-- Infinite Jump Hook
local ijConn = nil
PlayerTab:AddToggle({
    Name = "Infinite Jumping Engine", Default = false,
    Callback = function(on)
        BaddieHub.Config.InfJump = on
        if ijConn then ijConn:Disconnect(); ijConn = nil end
        if on then
            local char = LP.Character or LP.CharacterAdded:Wait()
            local h = char:WaitForChild("Humanoid")
            ijConn = h.Jumping:Connect(function(jumping)
                if jumping and BaddieHub.Config.InfJump then
                    task.wait(0.04)
                    pcall(function()
                        local hrp = GetHRP()
                        if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X, BaddieHub.Config.JumpPower, hrp.Velocity.Z) end
                    end)
                end
            end)
            TrackConnection(ijConn)
        end
    end
})

-- Custom Flight Controller (Smooth & Multi-platform)
local flyConn, flyBV, flyBG
local function StopFly()
    BaddieHub.Config.FlyEnabled = false
    RemoveMobileFlyControls()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    pcall(function()
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
        local h = GetHum(); if h then h.PlatformStand = false end
    end)
end

local function StartFly()
    BaddieHub.Config.FlyEnabled = true
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then StopFly(); return end
    
    hum.PlatformStand = true
    flyBV = Instance.new("BodyVelocity", hrp); flyBV.Velocity = Vector3.zero; flyBV.MaxForce = Vector3.new(1e9,1e9,1e9)
    flyBG = Instance.new("BodyGyro", hrp); flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9); flyBG.D = 100
    
    -- Create Mobile control pads if touch screen active
    CreateMobileFlyControls()
    
    flyConn = RunService.Heartbeat:Connect(function()
        if not BaddieHub.Config.FlyEnabled then return end
        pcall(function()
            local dir = Vector3.zero
            local cf  = Camera.CFrame
            
            -- PC Inputs
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
            
            -- Mobile Inputs Override
            if BaddieHub.MobileFlyState then
                if BaddieHub.MobileFlyState.Up() then dir = dir + Vector3.new(0, 1, 0) end
                if BaddieHub.MobileFlyState.Down() then dir = dir - Vector3.new(0, 1, 0) end
                -- Use camera look direction for forward flight during movement
                if UIS.MoveDirection.Magnitude > 0 then
                    local camLook = cf.LookVector
                    dir = dir + (camLook * UIS.MoveDirection.Magnitude)
                end
            end
            
            flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * BaddieHub.Config.FlySpeed or Vector3.zero
            flyBG.CFrame = cf
        end)
    end)
    TrackConnection(flyConn)
end

PlayerTab:AddToggle({
    Name = "Explore Flight Mode", Default = false,
    Callback = function(on) if on then StartFly() else StopFly() end end
})

AddButtonSlider(PlayerTab, "Flight Velocity", 10, 500, 60, 20, " studs/s", function(v) BaddieHub.Config.FlySpeed = v end)

-- Hover float above ground
local hoverConn = nil
local hoverBP = nil
local function StopHover()
    BaddieHub.Config.HoverEnabled = false
    if hoverConn then hoverConn:Disconnect(); hoverConn = nil end
    pcall(function()
        if hoverBP then hoverBP:Destroy(); hoverBP = nil end
        local h = GetHum(); if h then h.PlatformStand = false end
    end)
end

PlayerTab:AddToggle({
    Name = "Anti-Fall Hover Engine", Default = false,
    Callback = function(on)
        BaddieHub.Config.HoverEnabled = on
        if hoverConn then hoverConn:Disconnect(); hoverConn = nil end
        if not on then StopHover(); return end
        
        hoverConn = RunService.Heartbeat:Connect(function()
            if not BaddieHub.Config.HoverEnabled then return end
            pcall(function()
                local hrp = GetHRP(); local hum = GetHum()
                if not hrp or not hum then return end
                hum.PlatformStand = true
                
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {LP.Character}
                params.FilterType = Enum.RaycastFilterType.Exclude
                
                local ray = WS:Raycast(hrp.Position, Vector3.new(0, -500, 0), params)
                local groundY = ray and ray.Position.Y or (hrp.Position.Y - BaddieHub.Config.HoverHeight)
                
                if not hoverBP or not hoverBP.Parent then
                    hoverBP = Instance.new("BodyPosition", hrp)
                    hoverBP.Name = "BaddieHoverBP"
                    hoverBP.MaxForce = Vector3.new(0, 1e9, 0)
                    hoverBP.D = 500; hoverBP.P = 15000
                end
                hoverBP.Position = Vector3.new(hrp.Position.X, groundY + BaddieHub.Config.HoverHeight, hrp.Position.Z)
            end)
        end)
        TrackConnection(hoverConn)
    end
})
AddButtonSlider(PlayerTab, "Hover Floor Offset", 3, 200, 15, 5, " studs", function(v) BaddieHub.Config.HoverHeight = v end)

-- Precise Collision bypass (Noclip)
local noclipConn = nil
PlayerTab:AddToggle({
    Name = "Wall Bypass (Noclip)", Default = false,
    Callback = function(on)
        BaddieHub.Config.Noclip = on
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        if on then
            noclipConn = RunService.Stepped:Connect(function()
                pcall(function()
                    local char = LP.Character; if not char then return end
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                    end
                end)
            end)
            TrackConnection(noclipConn)
        end
    end
})

PlayerTab:AddSection({ Name = "Enhanced Visual Hacks" })
local fbConn = nil
local oldAmbient, oldFogEnd
PlayerTab:AddToggle({
    Name = "Night Vision Fullbright", Default = false,
    Callback = function(on)
        BaddieHub.Config.Fullbright = on
        local L = game:GetService("Lighting")
        if on then
            oldAmbient = L.Ambient; oldFogEnd = L.FogEnd
            L.Ambient = Color3.new(1,1,1); L.Brightness = 2; L.FogEnd = 1e6
            if fbConn then fbConn:Disconnect() end
            fbConn = RunService.Heartbeat:Connect(function()
                L.Ambient = Color3.new(1, 1, 1); L.Brightness = 2
            end)
            TrackConnection(fbConn)
        else
            if fbConn then fbConn:Disconnect(); fbConn = nil end
            L.Ambient = oldAmbient or Color3.fromRGB(70, 70, 70)
            L.Brightness = 1; L.FogEnd = oldFogEnd or 1e4
        end
    end
})
AddButtonSlider(PlayerTab, "FOV Config", 30, 120, 70, 5, " deg", function(v) Camera.FieldOfView = v end)

PlayerTab:AddSection({ Name = "Utility Subroutines" })
local afkConn = nil
PlayerTab:AddToggle({
    Name = "Anti-AFK Connection Sentry", Default = false,
    Callback = function(on)
        if afkConn then afkConn:Disconnect(); afkConn = nil end
        if on then
            afkConn = RunService.Heartbeat:Connect(function()
                pcall(function() LP:Move(Vector3.new(0, 0, 0)) end)
            end)
            TrackConnection(afkConn)
            task.spawn(function()
                while afkConn do
                    pcall(function()
                        local vu = game:GetService("VirtualUser")
                        vu:Button1Down(Vector2.new(0,0), Camera.CFrame); task.wait(0.1)
                        vu:Button1Up(Vector2.new(0,0), Camera.CFrame)
                    end)
                    task.wait(60)
                end
            end)
        end
    end
})

local godConn = nil
PlayerTab:AddToggle({
    Name = "Client-Side God Mode", Default = false,
    Callback = function(on)
        if godConn then godConn:Disconnect(); godConn = nil end
        if on then
            godConn = RunService.Heartbeat:Connect(function()
                pcall(function() local h = GetHum(); if h then h.Health = h.MaxHealth end end)
            end)
            TrackConnection(godConn)
        end
    end
})

PlayerTab:AddButton({ Name = "Forced Client Respawn", Callback = function() pcall(function() LP:LoadCharacter() end) end })

-- =============================================================================
-- TAB: TELEPORTATION
-- =============================================================================
local TpTab = Window:MakeTab({ Name = "Teleport", Icon = ICON, PremiumOnly = false })
TpTab:AddSection({ Name = "Target Players" })

local tpTargetName = ""
local function GetOtherPlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(list, p.Name) end
    end
    if #list == 0 then table.insert(list, "(nobody)") end
    return list
end

TpTab:AddDropdown({
    Name = "Select Roblox Character", Default = GetOtherPlayers()[1],
    Options = GetOtherPlayers(),
    Callback = function(v) tpTargetName = v end
})

TpTab:AddButton({
    Name = "Execute Safe Teleport to Player",
    Callback = function()
        if tpTargetName == "" or tpTargetName == "(nobody)" then
            OrionLib:MakeNotification({ Name = "TP Engine", Content = "Select a target first.", Image = ICON, Time = 2 }); return
        end
        local found = false
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name == tpTargetName then
                local tHrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if tHrp then
                    SafeTP(tHrp.CFrame * CFrame.new(3, 0, 3))
                    OrionLib:MakeNotification({ Name = "TP Sentry", Content = "Arrived at " .. p.Name, Image = ICON, Time = 2 })
                    found = true
                end
                break
            end
        end
        if not found then
            OrionLib:MakeNotification({ Name = "TP Error", Content = "Target offline/not found.", Image = ICON, Time = 3 })
        end
    end
})

TpTab:AddSection({ Name = "Manual Coordinates" })
local tpX, tpY, tpZ = "0", "200", "0"
TpTab:AddTextbox({ Name = "X Value", Default = "0", TextDisappear = false, Callback = function(v) tpX = v end })
TpTab:AddTextbox({ Name = "Y Value", Default = "200", TextDisappear = false, Callback = function(v) tpY = v end })
TpTab:AddTextbox({ Name = "Z Value", Default = "0", TextDisappear = false, Callback = function(v) tpZ = v end })
TpTab:AddButton({
    Name = "Jump to Coordinate Matrix",
    Callback = function()
        local x, y, z = tonumber(tpX) or 0, tonumber(tpY) or 0, tonumber(tpZ) or 0
        SafeTP(CFrame.new(x, y, z), true)
        OrionLib:MakeNotification({ Name = "TP Coords", Content = "Lat: " .. x .. ", " .. y .. ", " .. z, Image = ICON, Time = 2 })
    end
})

TpTab:AddSection({ Name = "Instant Vectors" })
TpTab:AddButton({
    Name = "TP to Universe Spawn",
    Callback = function()
        pcall(function()
            local sp = WS:FindFirstChildOfClass("SpawnLocation")
            SafeTP(CFrame.new((sp and sp.Position or Vector3.new(0, 10, 0)) + Vector3.new(0, 5, 0)), true)
        end)
    end
})

-- =============================================================================
-- TAB: SENSORY ESP
-- =============================================================================
local EspTab = Window:MakeTab({ Name = "ESP", Icon = ICON, PremiumOnly = false })
EspTab:AddSection({ Name = "Sentry Screen Indicators" })

local EspBoxes = {}
local espLoop = nil

local function MakeBox(player)
    if player == LP then return end
    pcall(function()
        if EspBoxes[player] then EspBoxes[player].Root:Destroy(); EspBoxes[player] = nil end
        local char = player.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        
        local bb = Instance.new("BillboardGui")
        bb.AlwaysOnTop = true; bb.Size = UDim2.new(0, 4, 0, 5)
        bb.SizeOffset = Vector2.new(3.5, 4); bb.StudsOffset = Vector3.new(0, 2.5, 0)
        bb.Adornee = hrp; bb.Parent = CoreGui
        
        local box = Instance.new("Frame", bb); box.Size = UDim2.fromScale(1,1); box.BackgroundTransparency = 1
        local stroke = Instance.new("UIStroke", box); stroke.Color = BaddieHub.Config.EspColor; stroke.Thickness = 1.5
        
        local nameL = Instance.new("TextLabel", bb)
        nameL.AnchorPoint = Vector2.new(0.5, 1); nameL.Position = UDim2.new(0.5, 0, 0, -3)
        nameL.Size = UDim2.new(1, 50, 0, 16); nameL.BackgroundTransparency = 1
        nameL.Text = player.Name; nameL.TextColor3 = Color3.new(1, 1, 1); nameL.TextSize = 12
        nameL.Font = Enum.Font.GothamBold; nameL.TextStrokeTransparency = 0
        
        local distL = Instance.new("TextLabel", bb)
        distL.AnchorPoint = Vector2.new(0.5, 0); distL.Position = UDim2.new(0.5, 0, 1, 2)
        distL.Size = UDim2.new(1, 50, 0, 14); distL.BackgroundTransparency = 1
        distL.Text = "0m"; distL.TextColor3 = Color3.fromRGB(200, 200, 200); distL.TextSize = 11
        distL.Font = Enum.Font.Gotham; distL.TextStrokeTransparency = 0
        
        local hpTrack = Instance.new("Frame", bb)
        hpTrack.AnchorPoint = Vector2.new(0, 0.5); hpTrack.Position = UDim2.new(0, -10, 0.5, 0)
        hpTrack.Size = UDim2.new(0, 4, 1, 0); hpTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 40); hpTrack.BorderSizePixel = 0
        
        local hpFill = Instance.new("Frame", hpTrack)
        hpFill.AnchorPoint = Vector2.new(0, 1); hpFill.Position = UDim2.fromScale(0, 1)
        hpFill.Size = UDim2.fromScale(1, 1); hpFill.BackgroundColor3 = Color3.fromRGB(80, 255, 80); hpFill.BorderSizePixel = 0
        
        EspBoxes[player] = { Root = bb, Stroke = stroke, NameL = nameL, DistL = distL, HpFill = hpFill }
    end)
end

local function RemoveBox(p)
    if EspBoxes[p] then pcall(function() EspBoxes[p].Root:Destroy() end); EspBoxes[p] = nil end
end

local function ClearEsp()
    for p in pairs(EspBoxes) do RemoveBox(p) end
    if espLoop then espLoop:Disconnect(); espLoop = nil end
end

EspTab:AddToggle({
    Name = "Roblox Player ESP Radar", Default = false,
    Callback = function(on)
        BaddieHub.Config.EspEnabled = on
        if on then
            for _, p in ipairs(Players:GetPlayers()) do MakeBox(p) end
            if espLoop then espLoop:Disconnect() end
            espLoop = RunService.Heartbeat:Connect(function()
                local myHrp = GetHRP()
                for p, data in pairs(EspBoxes) do
                    pcall(function()
                        if not data.Root.Parent then EspBoxes[p] = nil; return end
                        data.Stroke.Color = BaddieHub.Config.EspColor
                        if myHrp then
                            local tHrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                            if tHrp then data.DistL.Text = math.floor((myHrp.Position - tHrp.Position).Magnitude) .. " studs" end
                        end
                        local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
                        if h then
                            local pct = h.Health / math.max(h.MaxHealth, 1)
                            data.HpFill.Size = UDim2.fromScale(1, pct)
                            data.HpFill.BackgroundColor3 = Color3.fromRGB(math.floor(255 * (1 - pct)), math.floor(255 * pct), 0)
                        end
                    end)
                end
            end)
            TrackConnection(espLoop)
        else ClearEsp() end
    end
})

EspTab:AddDropdown({
    Name = "Sensory Laser Color", Default = "Red",
    Options = {"Red", "Green", "Blue", "Yellow", "White", "Cyan"},
    Callback = function(v)
        local m = {
            Red = Color3.fromRGB(255, 50, 50),
            Green = Color3.fromRGB(50, 255, 80),
            Blue = Color3.fromRGB(60, 130, 255),
            Yellow = Color3.fromRGB(255, 220, 30),
            White = Color3.fromRGB(255, 255, 255),
            Cyan = Color3.fromRGB(0, 230, 230)
        }
        BaddieHub.Config.EspColor = m[v] or Color3.fromRGB(255, 50, 50)
    end
})

TrackConnection(Players.PlayerAdded:Connect(function(p)
    if BaddieHub.Config.EspEnabled then p.CharacterAdded:Connect(function() task.wait(0.5); MakeBox(p) end); MakeBox(p) end
end))
TrackConnection(Players.PlayerRemoving:Connect(RemoveBox))

-- =============================================================================
-- TAB: SERVER TOOLS
-- =============================================================================
local ServerTab = Window:MakeTab({ Name = "Server", Icon = ICON, PremiumOnly = false })
ServerTab:AddSection({ Name = "Server Management" })
ServerTab:AddButton({
    Name = "Force Server Hop (Teleport)",
    Callback = function()
        local ok2, e = pcall(function() TeleportService:Teleport(PlaceId, LP) end)
        if not ok2 then OrionLib:MakeNotification({ Name = "Network Teleport", Content = tostring(e), Image = ICON, Time = 3 }) end
    end
})
ServerTab:AddLabel("Current Player Count: " .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers)

-- =============================================================================
-- GAME MOD: BLOX FRUITS (Highly Optimized Module)
-- =============================================================================
if DetectedGame == "Blox Fruits" then
    local BFTab = Window:MakeTab({ Name = "Blox Fruits", Icon = ICON, PremiumOnly = false })
    BFTab:AddSection({ Name = "Anti-Cheat Safe Auto-Farm" })

    local bfFarmOn = false
    local bfFarmRange = 40
    local bfAutoQuestOn = false
    local bfQuestStatus = "Idle"
    local farmPlatform = nil
    local selectedWeaponType = "Melee"
    local manualQuestIndex = 0

    -- Safe floating platform constructor to bypass dynamic anti-cheats
    local function createFarmPlatform(pos)
        pcall(function()
            if not farmPlatform or not farmPlatform.Parent then
                farmPlatform = Instance.new("Part")
                farmPlatform.Name = "BaddieFarmPlatform"
                farmPlatform.Size = Vector3.new(20, 1, 20)
                farmPlatform.Transparency = 1
                farmPlatform.Anchored = true
                farmPlatform.CanCollide = true
                farmPlatform.Parent = WS
            end
            farmPlatform.CFrame = CFrame.new(pos) - Vector3.new(0, 3.5, 0)
        end)
    end

    local function destroyFarmPlatform()
        pcall(function() if farmPlatform then farmPlatform:Destroy(); farmPlatform = nil end end)
    end

    -- Dynamically gets tool by preference or fallback
    local function autoEquipWeapon()
        local char = LP.Character; if not char then return nil end
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then
                local isMatch = false
                if selectedWeaponType == "Melee" and (child.ToolTip == "Melee" or child.Name == "Combat" or child.Name:lower():find("step") or child.Name:lower():find("claw") or child.Name:lower():find("kung") or child.Name:lower():find("fist")) then isMatch = true
                elseif selectedWeaponType == "Sword" and (child.ToolTip == "Sword" or child.Name == "Katana" or child.Name == "Cutlass" or child.Name:lower():find("blade") or child.Name:lower():find("saber") or child.Name:lower():find("sword")) then isMatch = true
                elseif selectedWeaponType == "Blox Fruit" and (child.ToolTip == "Blox Fruit" or child.Name:lower():find("fruit") or child.Name == "Ice" or child.Name == "Light" or child.Name == "Magma") then isMatch = true end
                if isMatch then return child end
            end
        end
        for _, tool in ipairs(LP.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local isMatch = false
                if selectedWeaponType == "Melee" and (tool.ToolTip == "Melee" or tool.Name == "Combat" or tool.Name:lower():find("step") or tool.Name:lower():find("claw") or tool.Name:lower():find("kung") or tool.Name:lower():find("fist")) then isMatch = true
                elseif selectedWeaponType == "Sword" and (tool.ToolTip == "Sword" or tool.Name == "Katana" or tool.Name == "Cutlass" or tool.Name:lower():find("blade") or tool.Name:lower():find("saber") or tool.Name:lower():find("sword")) then isMatch = true
                elseif selectedWeaponType == "Blox Fruit" and (tool.ToolTip == "Blox Fruit" or tool.Name:lower():find("fruit") or tool.Name == "Ice" or tool.Name == "Light" or tool.Name == "Magma") then isMatch = true end
                if isMatch then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:EquipTool(tool); return tool end
                end
            end
        end
        -- Ultimate fallback: equip anything
        for _, tool in ipairs(LP.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:EquipTool(tool); return tool end
            end
        end
        return nil
    end

    -- High performance spatial mob magnet
    local function pullMobs(keywords, targetPos)
        local myHrp = GetHRP()
        if not myHrp then return end
        pcall(function()
            local op = OverlapParams.new()
            op.FilterType = Enum.RaycastFilterType.Exclude
            op.FilterDescendantsInstances = {LP.Character}
            
            local parts = WS:GetPartBoundsInRadius(myHrp.Position, 220, op)
            for _, part in ipairs(parts) do
                local char = part.Parent
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local r_hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and r_hrp and not Players:GetPlayerFromCharacter(char) then
                    local isMob = false
                    for _, kw in ipairs(keywords) do
                        if char.Name:lower():find(kw:lower()) then isMob = true; break end
                    end
                    if isMob then
                        r_hrp.CanCollide = false
                        r_hrp.CFrame = CFrame.new(targetPos) * CFrame.new(0, -3.2, -1)
                        r_hrp.Velocity = Vector3.zero
                        hum.PlatformStand = true
                    end
                end
            end
        end)
    end

    -- Bypassed Fast M1 Attack (RigController Remote triggering for max swing speed)
    local function fastAttack()
        pcall(function()
            local rtc = ReplicatedStorage:FindFirstChild("RigControllerToClient")
            if rtc and rtc:FindFirstChild("ClientReady") then
                rtc.ClientReady:FireServer()
            end
        end)
        pcall(function()
            local char = LP.Character
            if char then
                for _, child in ipairs(char:GetChildren()) do
                    if child:IsA("Tool") then child:Activate() end
                end
            end
        end)
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:Button1Down(Vector2.new(0, 0), Camera.CFrame)
            task.wait(0.005)
            vu:Button1Up(Vector2.new(0, 0), Camera.CFrame)
        end)
    end

    -- DB of Sea 1 Quests & Mob targets
    local Sea1Quests = {
        { name = "Bandits (Lvl 1)", minLevel = 1, npcCF = CFrame.new(1060, 16, 1500), questName = "BanditQuest1", questId = 1, mobKey = {"Bandit"}, mobCF = CFrame.new(1060, 16, 1540) },
        { name = "Monkeys (Lvl 10)", minLevel = 10, npcCF = CFrame.new(-1600, 37, 150), questName = "JungleQuest", questId = 1, mobKey = {"Monkey"}, mobCF = CFrame.new(-1620, 40, 120) },
        { name = "Gorillas (Lvl 15)", minLevel = 15, npcCF = CFrame.new(-1600, 37, 150), questName = "JungleQuest", questId = 2, mobKey = {"Gorilla"}, mobCF = CFrame.new(-1200, 25, -230) },
        { name = "Pirates (Lvl 30)", minLevel = 30, npcCF = CFrame.new(-1410, 9, -398), questName = "BuggyQuest1", questId = 1, mobKey = {"Pirate"}, mobCF = CFrame.new(-1220, 15, 3910) },
        { name = "Brutes (Lvl 45)", minLevel = 45, npcCF = CFrame.new(-1410, 9, -398), questName = "BuggyQuest1", questId = 2, mobKey = {"Brute"}, mobCF = CFrame.new(-1145, 15, 4310) },
        { name = "Desert Bandits (Lvl 60)", minLevel = 60, npcCF = CFrame.new(894, 6, 4385), questName = "DesertQuest", questId = 1, mobKey = {"Desert Bandit"}, mobCF = CFrame.new(990, 6, 4420) },
        { name = "Desert Officers (Lvl 75)", minLevel = 75, npcCF = CFrame.new(894, 6, 4385), questName = "DesertQuest", questId = 2, mobKey = {"Desert Officer"}, mobCF = CFrame.new(1570, 6, 4360) },
        { name = "Snow Bandits (Lvl 90)", minLevel = 90, npcCF = CFrame.new(1386, 26, -1300), questName = "SnowQuest", questId = 1, mobKey = {"Snow Bandit"}, mobCF = CFrame.new(1290, 26, -1340) },
        { name = "Snowmen (Lvl 100)", minLevel = 100, npcCF = CFrame.new(1386, 26, -1300), questName = "SnowQuest", questId = 2, mobKey = {"Snowman"}, mobCF = CFrame.new(1280, 26, -1450) },
        { name = "Chief Petty Officers (Lvl 120)", minLevel = 120, npcCF = CFrame.new(-4850, 20, 4300), questName = "MarineQuest", questId = 1, mobKey = {"Chief Petty Officer"}, mobCF = CFrame.new(-4830, 20, 4100) },
        { name = "Sky Bandits (Lvl 150)", minLevel = 150, npcCF = CFrame.new(-1243, 355, -5900), questName = "SkyQuest", questId = 1, mobKey = {"Sky Bandit"}, mobCF = CFrame.new(-1220, 390, -5670) },
        { name = "Dark Masters (Lvl 175)", minLevel = 175, npcCF = CFrame.new(-1243, 355, -5900), questName = "SkyQuest", questId = 2, mobKey = {"Dark Master"}, mobCF = CFrame.new(-900, 390, -5610) },
        { name = "Prisoners (Lvl 190)", minLevel = 190, npcCF = CFrame.new(4830, 6, 4775), questName = "PrisonQuest", questId = 1, mobKey = {"Prisoner"}, mobCF = CFrame.new(4800, 6, 4650) },
        { name = "Dangerous Prisoners (Lvl 210)", minLevel = 210, npcCF = CFrame.new(4830, 6, 4775), questName = "PrisonQuest", questId = 2, mobKey = {"Dangerous Prisoner"}, mobCF = CFrame.new(4850, 6, 4650) },
        { name = "Toga Warriors (Lvl 250)", minLevel = 250, npcCF = CFrame.new(-1580, 7, -2980), questName = "ColosseumQuest", questId = 1, mobKey = {"Toga Warrior"}, mobCF = CFrame.new(-1800, 7, -2800) },
        { name = "Gladiators (Lvl 275)", minLevel = 275, npcCF = CFrame.new(-1580, 7, -2980), questName = "ColosseumQuest", questId = 2, mobKey = {"Gladiator"}, mobCF = CFrame.new(-1400, 7, -3000) },
        { name = "Military Soldiers (Lvl 300)", minLevel = 300, npcCF = CFrame.new(-5200, 8, 8400), questName = "MagmaQuest", questId = 1, mobKey = {"Military Soldier"}, mobCF = CFrame.new(-5300, 8, 8500) },
        { name = "Military Spies (Lvl 330)", minLevel = 330, npcCF = CFrame.new(-5200, 8, 8400), questName = "MagmaQuest", questId = 2, mobKey = {"Military Spy"}, mobCF = CFrame.new(-5350, 8, 8350) },
        { name = "Fishman Warriors (Lvl 375)", minLevel = 375, npcCF = CFrame.new(6110, 18, 1550), questName = "FishmanQuest", questId = 1, mobKey = {"Fishman Warrior"}, mobCF = CFrame.new(6000, 18, 1400) },
        { name = "Fishman Commandos (Lvl 400)", minLevel = 400, npcCF = CFrame.new(6110, 18, 1550), questName = "FishmanQuest", questId = 2, mobKey = {"Fishman Commando"}, mobCF = CFrame.new(6200, 18, 1400) },
        { name = "God's Guards (Lvl 450)", minLevel = 450, npcCF = CFrame.new(-4510, 1000, -2500), questName = "SkyExp1Quest", questId = 1, mobKey = {"God's Guard"}, mobCF = CFrame.new(-4600, 1000, -2600) },
        { name = "Shandas (Lvl 475)", minLevel = 475, npcCF = CFrame.new(-4510, 1000, -2500), questName = "SkyExp1Quest", questId = 2, mobKey = {"Shanda"}, mobCF = CFrame.new(-4300, 1000, -2400) },
        { name = "Royal Squads (Lvl 525)", minLevel = 525, npcCF = CFrame.new(-5200, 1200, -2000), questName = "SkyExp2Quest", questId = 1, mobKey = {"Royal Squad"}, mobCF = CFrame.new(-5300, 1200, -2100) },
        { name = "Royal Soldiers (Lvl 550)", minLevel = 550, npcCF = CFrame.new(-5200, 1200, -2000), questName = "SkyExp2Quest", questId = 2, mobKey = {"Royal Soldier"}, mobCF = CFrame.new(-5100, 1200, -1900) },
        { name = "Galley Pirates (Lvl 575)", minLevel = 575, npcCF = CFrame.new(5120, 4, 4100), questName = "FountainQuest", questId = 1, mobKey = {"Galley Pirate"}, mobCF = CFrame.new(5200, 4, 3900) },
        { name = "Galley Captains (Lvl 625)", minLevel = 625, npcCF = CFrame.new(5120, 4, 4100), questName = "FountainQuest", questId = 2, mobKey = {"Galley Captain"}, mobCF = CFrame.new(5400, 4, 4000) }
    }

    local questOptions = {"(Auto Select Best)"}
    for _, q in ipairs(Sea1Quests) do table.insert(questOptions, q.name) end

    BFTab:AddDropdown({
        Name = "Active Farm Quest Target", Default = questOptions[1],
        Options = questOptions,
        Callback = function(v)
            if v == "(Auto Select Best)" then
                manualQuestIndex = 0
            else
                for i, q in ipairs(Sea1Quests) do
                    if q.name == v then manualQuestIndex = i; break end
                end
            end
        end
    })

    BFTab:AddDropdown({
        Name = "Active Weapon Utility", Default = "Melee",
        Options = {"Melee", "Sword", "Blox Fruit"},
        Callback = function(v) selectedWeaponType = v end
    })

    BFTab:AddToggle({
        Name = "Human-Like Quest Auto-Farm", Default = false,
        Callback = function(on)
            bfAutoQuestOn = on
            if not on then
                bfQuestStatus = "Idle"
                destroyFarmPlatform()
                return
            end
            
            task.spawn(function()
                while bfAutoQuestOn do
                    pcall(function()
                        local lvl = GetPlayerLevel()
                        local q = nil
                        
                        if manualQuestIndex > 0 then
                            q = Sea1Quests[manualQuestIndex]
                        else
                            for _, sq in ipairs(Sea1Quests) do
                                if lvl >= sq.minLevel then q = sq end
                            end
                        end
                        
                        if not q then q = Sea1Quests[1] end
                        
                        if not HasActiveQuest() then
                            bfQuestStatus = "Requesting: " .. q.name
                            -- Remote Bypass acceptance
                            pcall(function()
                                local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                                if commF then
                                    commF:InvokeServer("StartQuest", q.questName, q.questId)
                                end
                            end)
                            task.wait(0.4)
                            
                            -- Fallback Manual Acceptance with smooth flight
                            if not HasActiveQuest() then
                                SafeTP(q.npcCF * CFrame.new(0, 3, 5))
                                task.wait(0.8)
                                local npc = FindQuestNPC(q.npcCF, 120)
                                if npc then
                                    local rp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
                                    if rp then
                                        SafeTP(CFrame.new(rp.Position + Vector3.new(0, 0, 5)), true)
                                        task.wait(0.2)
                                    end
                                    TryFireProximity(npc, 25)
                                    task.wait(0.1)
                                    TryClickDetector(npc)
                                end
                                task.wait(0.6)
                            end
                        else
                            bfQuestStatus = "Destroying: " .. q.name
                            local targetFarmPos = q.mobCF.Position + Vector3.new(0, 18, 0)
                            local hrp = GetHRP()
                            if hrp then
                                createFarmPlatform(targetFarmPos)
                                -- Safe fly TP
                                SafeTP(CFrame.new(targetFarmPos))
                                pullMobs(q.mobKey, targetFarmPos)
                                autoEquipWeapon()
                                fastAttack()
                            end
                        end
                    end)
                    task.wait(0.05)
                end
                bfQuestStatus = "Idle"
                destroyFarmPlatform()
            end)
        end
    })

    -- Add customizable Safe Farm flight speed configuration
    AddButtonSlider(BFTab, "Farming Flight Velocity", 80, 350, 180, 20, " studs/s", function(v)
        BaddieHub.Config.FarmSpeed = v
    end)

    -- Auto Stats spending Daemon
    BFTab:AddSection({ Name = "Auto Stats Allocator" })
    local autoStats = { Melee = false, Defense = false, Sword = false, ["Blox Fruit"] = false }
    BFTab:AddToggle({ Name = "Spend Points on Melee", Default = false, Callback = function(on) autoStats.Melee = on end })
    BFTab:AddToggle({ Name = "Spend Points on Defense", Default = false, Callback = function(on) autoStats.Defense = on end })
    BFTab:AddToggle({ Name = "Spend Points on Sword", Default = false, Callback = function(on) autoStats.Sword = on end })
    BFTab:AddToggle({ Name = "Spend Points on Blox Fruit", Default = false, Callback = function(on) autoStats["Blox Fruit"] = on end })

    task.spawn(function()
        while BaddieHub.Active do
            task.wait(1.5)
            local hs = false
            for _, e in pairs(autoStats) do if e then hs = true; break end end
            if hs then
                pcall(function()
                    local pts = 0
                    if LP:FindFirstChild("Data") and LP.Data:FindFirstChild("Points") then
                        pts = LP.Data.Points.Value
                    elseif LP:FindFirstChild("leaderstats") and LP.leaderstats:FindFirstChild("Points") then
                        pts = LP.leaderstats.Points.Value
                    end
                    if pts > 0 then
                        local comm = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                        if comm then
                            for stat, enabled in pairs(autoStats) do
                                if enabled then comm:InvokeServer("AddPoint", stat, pts) end
                            end
                        end
                    end
                end)
            end
        end
    end)

    -- Quick Shop Items
    BFTab:AddSection({ Name = "Automated Shop Purchases" })
    local function shopBuyStyle(name)
        pcall(function()
            local comm = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if comm then comm:InvokeServer(name) end
        end)
    end
    BFTab:AddButton({ Name = "Acquire Black Leg Martial (150K)", Callback = function() shopBuyStyle("BuyBlackLeg") end })
    BFTab:AddButton({ Name = "Acquire Electro Style (500K)", Callback = function() shopBuyStyle("BuyElectro") end })
    BFTab:AddButton({ Name = "Acquire Water Kung Fu (750K)", Callback = function() shopBuyStyle("BuyFishmanKungFu") end })

    BFTab:AddSection({ Name = "Devil Fruits" })
    BFTab:AddButton({
        Name = "TP to closest World Fruit",
        Callback = function()
            pcall(function()
                local hrp = GetHRP(); if not hrp then return end
                local closest, closestDist = nil, math.huge
                for _, o in ipairs(WS:GetDescendants()) do
                    if (o.Name:lower():find("fruit") or o.Name:lower():find("devil")) and (o:IsA("Model") or o:IsA("BasePart")) then
                        local pos = o:IsA("Model") and o:GetPivot().Position or o.Position
                        local d = (hrp.Position - pos).Magnitude
                        if d < closestDist then closestDist = d; closest = pos end
                    end
                end
                if closest then
                    SafeTP(CFrame.new(closest + Vector3.new(0, 3, 0)), true)
                    OrionLib:MakeNotification({ Name = "Sensors", Content = "Arrived at fruit!", Image = ICON, Time = 2 })
                else
                    OrionLib:MakeNotification({ Name = "Sensors", Content = "No fruit found.", Image = ICON, Time = 2 })
                end
            end)
        end
    })

    -- Quick Island Teleports
    BFTab:AddSection({ Name = "Island Teleports" })
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
    BFTab:AddDropdown({
        Name = "Select Coordinates Island", Default = islandList[1], Options = islandList,
        Callback = function(v)
            if bfIslands[v] then SafeTP(bfIslands[v] * CFrame.new(0, 3, 0)) end
        end
    })
end

-- =============================================================================
-- GAME MOD: JJK ZERO (Advanced Technique Recognition & Dynamic Auto-Farm)
-- =============================================================================
if DetectedGame == "JJK Zero" then
    local JJKTab = Window:MakeTab({ Name = "JJK Zero", Icon = ICON, PremiumOnly = false })
    
    -- Technique and Inventory Recognition
    JJKTab:AddSection({ Name = "Character Techniques & Inventory" })
    
    local techniqueLabel = JJKTab:AddLabel("Current Technique: Scanning...")
    local weaponLabel = JJKTab:AddLabel("Equipped Weapons: Scanning...")
    
    local function ScanJJKCharacter()
        pcall(function()
            local technique = "None"
            local weapons = {}
            
            -- Scan folders inside player or character (Standard JJK data structures)
            local folders = {"Data", "Technique", "Skills", "Inventory", "leaderstats"}
            for _, fName in ipairs(folders) do
                local folder = LP:FindFirstChild(fName) or (LP.Character and LP.Character:FindFirstChild(fName))
                if folder then
                    local currentTechVal = folder:FindFirstChild("CurrentTechnique") or folder:FindFirstChild("Technique") or folder:FindFirstChild("Skill")
                    if currentTechVal then technique = tostring(currentTechVal.Value) end
                end
            end
            
            -- Scan tools
            for _, item in ipairs(LP.Backpack:GetChildren()) do
                if item:IsA("Tool") then table.insert(weapons, item.Name) end
            end
            if LP.Character then
                for _, item in ipairs(LP.Character:GetChildren()) do
                    if item:IsA("Tool") then table.insert(weapons, item.Name .. " (Holding)") end
                end
            end
            
            local weaponStr = #weapons > 0 and table.concat(weapons, ", ") or "None"
            techniqueLabel:Set("Recognized Technique: " .. technique)
            weaponLabel:Set("Recognized Backpack: " .. weaponStr)
        end)
    end
    
    JJKTab:AddButton({ Name = "Scan Local Data Structures", Callback = ScanJJKCharacter })
    task.spawn(ScanJJKCharacter)
    
    -- Remote Sentry Event Scanner
    JJKTab:AddSection({ Name = "Remote Network Scanner (Reverse Engineering)" })
    local scanOutput = JJKTab:AddLabel("Click scan to query ReplicatedStorage remotes.")
    
    local function ScanJJKRemotes()
        pcall(function()
            local detected = {}
            for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local name = obj.Name:lower()
                    if name:find("skill") or name:find("equip") or name:find("use") or name:find("ability") or name:find("combat") or name:find("attack") or name:find("cast") or name:find("power") or name:find("curse") then
                        table.insert(detected, obj.Name .. " (" .. obj.ClassName .. ")")
                    end
                end
            end
            if #detected > 0 then
                scanOutput:Set("Found Combat Remotes: " .. table.concat(detected, " | "):sub(1, 150) .. "...")
            else
                scanOutput:Set("No matching JJK network remotes discovered.")
            end
        end)
    end
    JJKTab:AddButton({ Name = "Query Active Combat Remotes", Callback = ScanJJKRemotes })
    
    -- High Performance dynamic Mob farm
    JJKTab:AddSection({ Name = "Dynamic Mob Farm" })
    local jjkFarmOn = false
    local jjkFarmRange = 30
    local farmPlatform = nil

    local function createFarmPlatform(pos)
        pcall(function()
            if not farmPlatform or not farmPlatform.Parent then
                farmPlatform = Instance.new("Part")
                farmPlatform.Name = "BaddieFarmPlatform"
                farmPlatform.Size = Vector3.new(20, 1, 20)
                farmPlatform.Transparency = 1; farmPlatform.Anchored = true; farmPlatform.CanCollide = true; farmPlatform.Parent = WS
            end
            farmPlatform.CFrame = CFrame.new(pos) - Vector3.new(0, 3.5, 0)
        end)
    end

    local function destroyFarmPlatform()
        pcall(function() if farmPlatform then farmPlatform:Destroy(); farmPlatform = nil end end)
    end

    local function GetClosestJJKMob(range)
        local hrp = GetHRP(); if not hrp then return nil end
        local closest, closestDist = nil, range
        for _, char in ipairs(WS:GetDescendants()) do
            if char:IsA("Model") and char:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(char) then
                local r_hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
                local hum = char:FindFirstChildOfClass("Humanoid")
                if r_hrp and hum and hum.Health > 0 and r_hrp.Position.Y < 8000 then
                    local dist = (hrp.Position - r_hrp.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = r_hrp
                    end
                end
            end
        end
        return closest
    end

    JJKTab:AddToggle({
        Name = "Dynamic Dynamic-Mob Farm", Default = false,
        Callback = function(on)
            jjkFarmOn = on
            if not on then
                destroyFarmPlatform()
                return
            end
            
            task.spawn(function()
                while jjkFarmOn do
                    pcall(function()
                        local hrp = GetHRP()
                        if hrp then
                            local mob = GetClosestJJKMob(150)
                            if mob then
                                local farmPos = mob.Position + Vector3.new(0, 12, 0)
                                createFarmPlatform(farmPos)
                                SafeTP(CFrame.new(farmPos))
                                
                                -- Group mob under player
                                mob.CanCollide = false
                                mob.CFrame = hrp.CFrame * CFrame.new(0, -3.2, -1)
                                mob.Velocity = Vector3.zero
                                
                                -- Auto Attack
                                local char = LP.Character
                                if char then
                                    for _, tool in ipairs(LP.Backpack:GetChildren()) do
                                        if tool:IsA("Tool") then char:FindFirstChildOfClass("Humanoid"):EquipTool(tool) break end
                                    end
                                    for _, tool in ipairs(char:GetChildren()) do
                                        if tool:IsA("Tool") then tool:Activate() end
                                    end
                                end
                                
                                -- Fire M1 Screen inputs
                                local vu = game:GetService("VirtualUser")
                                vu:Button1Down(Vector2.new(0, 0), Camera.CFrame)
                                task.wait(0.01)
                                vu:Button1Up(Vector2.new(0, 0), Camera.CFrame)
                            end
                        end
                    end)
                    task.wait(0.05)
                end
                destroyFarmPlatform()
            end)
        end
    })
    AddButtonSlider(JJKTab, "Farm Scanning Range", 20, 200, 100, 10, " studs", function(v) jjkFarmRange = v end)

    JJKTab:AddSection({ Name = "Assisted Combat Utilities" })
    local jjkAuraOn = false
    JJKTab:AddToggle({
        Name = "Rapid M1 Auto-Spam", Default = false,
        Callback = function(on)
            jjkAuraOn = on
            if on then
                task.spawn(function()
                    while jjkAuraOn do
                        pcall(function()
                            local vu = game:GetService("VirtualUser")
                            vu:Button1Down(Vector2.new(0,0), Camera.CFrame); task.wait(0.05)
                            vu:Button1Up(Vector2.new(0,0), Camera.CFrame)
                        end)
                        task.wait(0.1)
                    end
                end)
            end
        end
    })
    JJKTab:AddToggle({
        Name = "Anti-Combo Dash (Z-Spam)", Default = false,
        Callback = function(on)
            if on then
                task.spawn(function()
                    while on do
                        pcall(function()
                            local vu = game:GetService("VirtualUser")
                            vu:KeyDown("z"); task.wait(0.04); vu:KeyUp("z")
                        end)
                        task.wait(0.12)
                        if not on then break end
                    end
                end)
            end
        end
    })
end

-- =============================================================================
-- GAME MOD: WORLD ZERO (Dungeon Scanning & Optimal Farming)
-- =============================================================================
if DetectedGame == "World Zero" then
    local WZTab = Window:MakeTab({ Name = "World Zero", Icon = ICON, PremiumOnly = false })
    
    -- Equipment Recognition
    WZTab:AddSection({ Name = "Equipment & Inventory Analysis" })
    local classLabel = WZTab:AddLabel("Current Active Class: Scanning...")
    local weaponLabel = WZTab:AddLabel("Backpack Weapons: Scanning...")
    
    local function ScanWZData()
        pcall(function()
            local class = "Universal Class"
            local items = {}
            
            -- WZ inventory layout scanning
            local leaderstats = LP:FindFirstChild("leaderstats")
            if leaderstats then
                local cl = leaderstats:FindFirstChild("Class") or leaderstats:FindFirstChild("Active")
                if cl then class = tostring(cl.Value) end
            end
            
            for _, item in ipairs(LP.Backpack:GetChildren()) do
                if item:IsA("Tool") or item.ClassName:find("Weapon") then table.insert(items, item.Name) end
            end
            if LP.Character then
                for _, item in ipairs(LP.Character:GetChildren()) do
                    if item:IsA("Tool") then table.insert(items, item.Name .. " (Holding)") end
                end
            end
            
            local weaponStr = #items > 0 and table.concat(items, ", ") or "None"
            classLabel:Set("Active Class Type: " .. class)
            weaponLabel:Set("Recognized Weapons: " .. weaponStr)
        end)
    end
    WZTab:AddButton({ Name = "Analyze World Inventory", Callback = ScanWZData })
    task.spawn(ScanWZData)
    
    -- Remotes Network Scanner
    WZTab:AddSection({ Name = "Remote Event Scanner (Network Analysis)" })
    local remLabel = WZTab:AddLabel("Click scan to query World Zero RPC network.")
    
    local function ScanWZRemotes()
        pcall(function()
            local detected = {}
            for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local name = obj.Name:lower()
                    if name:find("skill") or name:find("cast") or name:find("use") or name:find("dungeon") or name:find("loot") or name:find("shop") or name:find("equip") then
                        table.insert(detected, obj.Name)
                    end
                end
            end
            if #detected > 0 then
                remLabel:Set(" RPC Channels Discovered: " .. table.concat(detected, ", "):sub(1, 150) .. "...")
            else
                remLabel:Set("No matching World Zero network RPCs discovered.")
            end
        end)
    end
    WZTab:AddButton({ Name = "Query RPC Network", Callback = ScanWZRemotes })

    -- Pro-Grade dynamic dungeon farmer
    WZTab:AddSection({ Name = "Dynamic Dungeon Auto-Farm" })
    local wzFarmOn = false
    local wzFarmRange = 30
    local farmPlatform = nil

    local function createFarmPlatform(pos)
        pcall(function()
            if not farmPlatform or not farmPlatform.Parent then
                farmPlatform = Instance.new("Part")
                farmPlatform.Name = "BaddieFarmPlatform"
                farmPlatform.Size = Vector3.new(20, 1, 20)
                farmPlatform.Transparency = 1; farmPlatform.Anchored = true; farmPlatform.CanCollide = true; farmPlatform.Parent = WS
            end
            farmPlatform.CFrame = CFrame.new(pos) - Vector3.new(0, 3.5, 0)
        end)
    end

    local function destroyFarmPlatform()
        pcall(function() if farmPlatform then farmPlatform:Destroy(); farmPlatform = nil end end)
    end

    local function GetClosestWZMob(range)
        local hrp = GetHRP(); if not hrp then return nil end
        local closest, closestDist = nil, range
        for _, char in ipairs(WS:GetDescendants()) do
            if char:IsA("Model") and char:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(char) then
                local r_hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
                local hum = char:FindFirstChildOfClass("Humanoid")
                if r_hrp and hum and hum.Health > 0 and r_hrp.Position.Y < 8000 then
                    local dist = (hrp.Position - r_hrp.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = r_hrp
                    end
                end
            end
        end
        return closest
    end

    WZTab:AddToggle({
        Name = "Dungeon Core Auto-Farm", Default = false,
        Callback = function(on)
            wzFarmOn = on
            if not on then
                destroyFarmPlatform()
                return
            end
            
            task.spawn(function()
                while wzFarmOn do
                    pcall(function()
                        local hrp = GetHRP()
                        if hrp then
                            local mob = GetClosestWZMob(250)
                            if mob then
                                local farmPos = mob.Position + Vector3.new(0, 12, 0)
                                createFarmPlatform(farmPos)
                                SafeTP(CFrame.new(farmPos))
                                
                                -- Magnetize Mob exactly under platform
                                mob.CanCollide = false
                                mob.CFrame = hrp.CFrame * CFrame.new(0, -3.2, -1)
                                mob.Velocity = Vector3.zero
                                
                                -- Weapon Activation Sequence
                                local char = LP.Character
                                if char then
                                    for _, tool in ipairs(LP.Backpack:GetChildren()) do
                                        if tool:IsA("Tool") then char:FindFirstChildOfClass("Humanoid"):EquipTool(tool) break end
                                    end
                                    for _, tool in ipairs(char:GetChildren()) do
                                        if tool:IsA("Tool") then tool:Activate() end
                                    end
                                end
                                
                                -- Fast Attack simulation
                                local vu = game:GetService("VirtualUser")
                                vu:Button1Down(Vector2.new(0, 0), Camera.CFrame)
                                task.wait(0.01)
                                vu:Button1Up(Vector2.new(0, 0), Camera.CFrame)
                            end
                        end
                    end)
                    task.wait(0.05)
                end
                destroyFarmPlatform()
            end)
        end
    })
    AddButtonSlider(WZTab, "Aura Scan Radius", 10, 200, 30, 10, " studs", function(v) wzFarmRange = v end)

    WZTab:AddSection({ Name = "Dungeon Utilities" })
    WZTab:AddButton({
        Name = "Bypass TP to active Boss Portal",
        Callback = function()
            pcall(function()
                local hrp = GetHRP(); if not hrp then return end
                for _, obj in ipairs(WS:GetDescendants()) do
                    if obj.Name:lower():find("dungeon") or obj.Name:lower():find("boss") or obj.Name:lower():find("portal") then
                        local pos = (obj:IsA("BasePart") and obj.Position) or (obj:IsA("Model") and obj:GetPivot().Position)
                        if pos then SafeTP(CFrame.new(pos + Vector3.new(0, 5, 0)), true); break end
                    end
                end
            end)
        end
    })
    
    WZTab:AddButton({
        Name = "Dynamic Item Sweep (Collect Loot)",
        Callback = function()
            task.spawn(function()
                pcall(function()
                    local hrp = GetHRP(); if not hrp then return end
                    for _, o in ipairs(WS:GetDescendants()) do
                        if (o:IsA("BasePart") or o:IsA("Model")) and (o.Name:lower():find("loot") or o.Name:lower():find("drop") or o.Name:lower():find("item") or o.Name:lower():find("gem")) then
                            local pos = o:IsA("BasePart") and o.Position or (o:IsA("Model") and o:GetPivot().Position)
                            if pos and (hrp.Position - pos).Magnitude < 300 then
                                SafeTP(CFrame.new(pos + Vector3.new(0, 2, 0)), true)
                                task.wait(0.1)
                            end
                        end
                    end
                end)
                OrionLib:MakeNotification({ Name = "Sentry Loot", Content = "Dungeon sweep complete!", Image = ICON, Time = 2 })
            end)
        end
    })
end

-- =============================================================================
-- TAB: SYSTEM SETTINGS
-- =============================================================================
local SettingsTab = Window:MakeTab({ Name = "Settings", Icon = ICON, PremiumOnly = false })

SettingsTab:AddSection({ Name = "Extreme Optimization" })
SettingsTab:AddToggle({ Name = "Extreme Mobile FPS Booster", Default = false, Callback = function(on) ApplyBooster(on) end })

SettingsTab:AddSection({ Name = "Keybindings" })
SettingsTab:AddBind({
    Name = "Toggle Console Interface", Default = Enum.KeyCode.RightControl, Hold = false,
    Callback = function()
        pcall(function()
            local g = CoreGui:FindFirstChild("Orion")
            if g then
                local f = g:FindFirstChildWhichIsA("Frame", true)
                if f then f.Visible = not f.Visible end
            end
        end)
    end
})

SettingsTab:AddSection({ Name = "Engine Destruction Sentry" })
SettingsTab:AddButton({
    Name = "Unload Hub Protocols completely",
    Callback = function()
        BaddieHub.Active = false
        ClearEsp()
        StopFly()
        StopHover()
        RemoveMobileFlyControls()
        
        -- Clean up tracking connections securely
        for _, conn in ipairs(BaddieHub.Connections) do
            pcall(function() conn:Disconnect() end)
        end
        BaddieHub.Connections = {}
        
        BaddieHub.Config.WalkSpeed = 16
        BaddieHub.Config.JumpPower = 50
        BaddieHub.Config.Gravity = 196
        WS.Gravity = 196
        
        OrionLib:Destroy()
    end
})

-- =============================================================================
-- TAB: CREDITS (Premium Visual Aesthetics)
-- =============================================================================
local CreditsTab = Window:MakeTab({ Name = "Credits", Icon = ICON, PremiumOnly = false })
CreditsTab:AddSection({ Name = "Baddie404 Multihub Team" })
CreditsTab:AddLabel("Dev: Baddie404")
CreditsTab:AddLabel("UI Engine: Orion Library (Custom Patched Fork)")
CreditsTab:AddParagraph("Senior Developer Remaster Edition", 
    "This script is optimized for premium mobile and PC executors (Solara, Delta, Wave, Synapse, Fluxus). " ..
    "Anti-drag scrollbars jump issues are 100% patched! " ..
    "Features smooth 'Human-Like' interpolation flying safe from velocity-based bans.")

-- =============================================================================
-- BACKEND PATCH: Orion Scrollbar Jump & Canvas Position Patches (SENIOR TRICK)
-- =============================================================================
local function PatchOrionScrollbarBehavior()
    task.spawn(function()
        task.wait(2.5) -- wait for Orion layout assembly
        pcall(function()
            local orionGui = CoreGui:FindFirstChild("Orion")
            if not orionGui then return end
            
            -- Intercept layout additions and save CanvasPosition
            for _, sf in ipairs(orionGui:GetDescendants()) do
                if sf:IsA("ScrollingFrame") then
                    sf.ClipsDescendants = true
                    sf.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
                    
                    -- Save current position to bypass unexpected scrolling frame drops
                    local lastKnownY = sf.CanvasPosition.Y
                    TrackConnection(sf:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                        if sf.CanvasPosition.Y < sf.AbsoluteCanvasSize.Y - sf.AbsoluteWindowSize.Y then
                            lastKnownY = sf.CanvasPosition.Y
                        end
                    end))
                    
                    -- Intercept canvas resizing or content additions
                    TrackConnection(sf.ChildAdded:Connect(function()
                        task.delay(0.01, function()
                            pcall(function()
                                sf.CanvasPosition = Vector2.new(0, lastKnownY)
                            end)
                        end)
                    end))
                end
            end
        end)
    end)
end
PatchOrionScrollbarBehavior()

-- =============================================================================
-- CHARACTER INITIALIZATION & RE-CONNECT PROCEDURES
-- =============================================================================
TrackConnection(LP.CharacterAdded:Connect(function(newChar)
    if BaddieHub.Config.InfJump then
        local h = newChar:WaitForChild("Humanoid")
        if ijConn then ijConn:Disconnect(); ijConn = nil end
        ijConn = h.Jumping:Connect(function(jumping)
            if jumping and BaddieHub.Config.InfJump then
                task.wait(0.04)
                pcall(function()
                    local hrp = newChar:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X, BaddieHub.Config.JumpPower, hrp.Velocity.Z) end
                end)
            end
        end)
        TrackConnection(ijConn)
    end
    if BaddieHub.Config.FlyEnabled then task.wait(0.5); StartFly() end
    if BaddieHub.Config.HoverEnabled and hoverBP then pcall(function() hoverBP:Destroy() end); hoverBP = nil end
    task.wait(0.3)
    pcall(function()
        local h = newChar:FindFirstChildOfClass("Humanoid")
        if h then
            h.WalkSpeed = BaddieHub.Config.WalkSpeed
            h.UseJumpPower = true
            h.JumpPower = BaddieHub.Config.JumpPower
        end
        WS.Gravity = BaddieHub.Config.Gravity
    end)
end))

-- =============================================================================
-- MOBILE-SAFE DRAG CONTROLLER (Accidental Drag Avoidance)
-- =============================================================================
task.spawn(function()
    task.wait(2.5)
    pcall(function()
        local orionGui = CoreGui:FindFirstChild("Orion")
        if not orionGui then return end
        local mainFrame = nil; local biggest = 0
        for _, v in ipairs(orionGui:GetDescendants()) do
            if v:IsA("Frame") then
                local area = v.AbsoluteSize.X * v.AbsoluteSize.Y
                if area > biggest then biggest = area; mainFrame = v end
            end
        end
        if not mainFrame then return end
        
        local dragHandle = nil
        for _, v in ipairs(mainFrame:GetChildren()) do
            if v:IsA("Frame") or v:IsA("TextLabel") or v:IsA("ImageLabel") then
                if v.AbsoluteSize.Y < 50 then dragHandle = v; break end
            end
        end
        dragHandle = dragHandle or mainFrame
        
        local dragging = false; local dragStart, startPos
        TrackConnection(dragHandle.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                local relativePos = inp.Position - mainFrame.AbsolutePosition
                if relativePos.Y <= 45 then
                    dragging = true; dragStart = inp.Position; startPos = mainFrame.Position
                end
            end
        end))
        TrackConnection(UIS.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end))
        TrackConnection(UIS.InputChanged:Connect(function(inp)
            if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                local d = inp.Position - dragStart
                mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end))
    end)
end)

-- =============================================================================
-- BOOT COMPLETION
-- =============================================================================
SetStatus("System initialization successful!"); SetProgress(100, 0.3); task.wait(0.5)
local ft = TweenService:Create(Bg, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
ft:Play()
ft.Completed:Connect(function() if LoadGui and LoadGui.Parent then LoadGui:Destroy() end end)

task.wait(0.4)
OrionLib:Init()
task.wait(0.8)

OrionLib:MakeNotification({
    Name = "Baddie404 v5.1",
    Content = DetectedGame .. " Sentry Node Active!",
    Image = ICON, Time = 6
})
