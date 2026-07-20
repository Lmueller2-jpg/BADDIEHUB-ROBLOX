-- =============================================================================
-- BADDIE404 MULTIHUB v5.0
-- Delta / Fluxus / Solara / Synapse X
-- 100% ASCII | Mobile-safe buttons instead of broken sliders
-- Features: Sea1 AutoQuest, AutoSpin, AntiCheat, Custom Drag, Hover
-- =============================================================================

-- Cleanup old instances
for _, n in ipairs({"Orion","Baddie404Hub","Baddie404Loading","Baddie404Drag"}) do
    local old = game:GetService("CoreGui"):FindFirstChild(n)
    if old then old:Destroy() end
end

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UIS              = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local WS               = game:GetService("Workspace")
local TeleportService  = game:GetService("TeleportService")
local Camera           = WS.CurrentCamera
local LP               = Players.LocalPlayer
local Mouse            = LP:GetMouse()
local PlaceId          = game.PlaceId
local ICON             = "rbxassetid://4483345998"

-- =============================================================================
-- LOADING SCREEN
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
Card.Size = UDim2.new(0,380,0,170)
Card.BackgroundColor3 = Color3.fromRGB(20,20,30)
Card.BorderSizePixel = 0
Instance.new("UICorner", Card).CornerRadius = UDim.new(0,12)
local cs = Instance.new("UIStroke", Card)
cs.Color = Color3.fromRGB(140,80,255); cs.Thickness = 1.5

local function MkLabel(parent, pos, size, text, size2, font, color, alignX)
    local l = Instance.new("TextLabel", parent)
    l.Position = pos; l.Size = size
    l.BackgroundTransparency = 1
    l.Text = text; l.TextSize = size2
    l.Font = font or Enum.Font.Gotham
    l.TextColor3 = color or Color3.new(1,1,1)
    l.TextXAlignment = alignX or Enum.TextXAlignment.Left
    return l
end

MkLabel(Card, UDim2.new(0,18,0,16),  UDim2.new(1,-36,0,26), "BADDIE404 MULTIHUB", 20, Enum.Font.GothamBold, Color3.new(1,1,1))
MkLabel(Card, UDim2.new(0,18,0,44),  UDim2.new(1,-36,0,16), "v5.0", 12, nil, Color3.fromRGB(140,90,255))
local StatusL = MkLabel(Card, UDim2.new(0,18,0,78), UDim2.new(1,-36,0,16), "Loading...", 12, nil, Color3.fromRGB(170,165,200))
local Track = Instance.new("Frame", Card)
Track.Position = UDim2.new(0,18,0,106); Track.Size = UDim2.new(1,-36,0,8)
Track.BackgroundColor3 = Color3.fromRGB(35,32,52); Track.BorderSizePixel = 0
Instance.new("UICorner", Track).CornerRadius = UDim.new(1,0)
local Fill = Instance.new("Frame", Track)
Fill.Size = UDim2.new(0,0,1,0); Fill.BackgroundColor3 = Color3.fromRGB(140,80,255)
Fill.BorderSizePixel = 0; Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0)
local PctL = MkLabel(Card, UDim2.new(0,18,0,120), UDim2.new(1,-36,0,14), "0%", 11, Enum.Font.GothamBold, Color3.fromRGB(140,80,255), Enum.TextXAlignment.Right)

local function SetProgress(pct, dur)
    TweenService:Create(Fill, TweenInfo.new(dur or 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(pct/100,0,1,0)}):Play()
    PctL.Text = pct .. "%"
end
local function SetStatus(t) StatusL.Text = t end

-- =============================================================================
-- HTTP HELPER
-- =============================================================================
local function safeGet(url)
    if request       then return request({Url=url,Method="GET"}).Body end
    if http_request  then return http_request({Url=url,Method="GET"}).Body end
    if syn and syn.request then return syn.request({Url=url,Method="GET"}).Body end
    return game:HttpGet(url)
end

-- =============================================================================
-- LOAD ORION
-- =============================================================================
SetStatus("Loading Orion..."); SetProgress(12, 0.2); task.wait(0.2)

local OrionLib
local ok = pcall(function()
    OrionLib = loadstring(safeGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
end)
if not ok or type(OrionLib) ~= "table" then
    SetStatus("Trying fallback..."); SetProgress(28, 0.2); task.wait(0.4)
    local ok2 = pcall(function()
        OrionLib = loadstring(safeGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
    end)
    if not ok2 or type(OrionLib) ~= "table" then
        SetStatus("FAILED - check connection"); SetProgress(100,0.3); task.wait(3); LoadGui:Destroy(); return
    end
end
SetStatus("Orion OK"); SetProgress(50, 0.3); task.wait(0.2)

-- =============================================================================
-- GAME DETECTION
-- =============================================================================
local Games = {
    ["Blox Fruits"] = {275391513,4442272121,7449423635,11349191060,2753915549,5261459311},
    ["JJK Zero"]    = {7973578035,8049346128,7901843281},
    ["World Zero"]  = {4157004456,4616238637,4616888069},
}
local DetectedGame = nil
for name, ids in pairs(Games) do
    if table.find(ids, PlaceId) then DetectedGame = name; break end
end
local Universal = not DetectedGame
if Universal then DetectedGame = "Unknown" end
SetStatus("Game: "..DetectedGame); SetProgress(80, 0.3); task.wait(0.2)

-- =============================================================================
-- BUILD WINDOW
-- =============================================================================
SetStatus("Building..."); SetProgress(95, 0.2); task.wait(0.2)

local Window = OrionLib:MakeWindow({
    Name = "Baddie404  |  "..DetectedGame,
    HidePremium = false, SaveConfig = true,
    ConfigFolder = "Baddie404", IntroText = "Baddie404 Hub", IntroIcon = ICON,
})

-- =============================================================================
-- UTILITY FUNCTIONS
-- =============================================================================
local function GetHum()
    local c = LP.Character; if not c then return nil end
    return c:FindFirstChildOfClass("Humanoid")
end
local function GetHRP()
    local c = LP.Character; if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart")
end

-- Anti-cheat safe teleport: lerps in small steps so velocity looks natural
local function SafeTP(cf, instant)
    pcall(function()
        local hrp = GetHRP()
        if not hrp then return end
        if instant then
            for _ = 1,3 do hrp.CFrame = cf; task.wait() end
            return
        end
        -- Smooth incremental TP: move max 80 studs per step
        local startPos = hrp.Position
        local endPos   = cf.Position
        local dist     = (endPos - startPos).Magnitude
        local steps    = math.max(1, math.ceil(dist / 80))
        for i = 1, steps do
            local t = i / steps
            local midCF = CFrame.new(startPos:Lerp(endPos, t)) * (cf - cf.Position)
            hrp.CFrame = midCF
            task.wait(0.04)
        end
        hrp.CFrame = cf
    end)
end

-- Fire proximity prompt if executor supports it
local function TryFireProximity(part, maxDist)
    maxDist = maxDist or 15
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

-- Try ClickDetector
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

-- Attack the nearest mob (multi-method - OPTIMIZED WITH SPATIAL QUERIES)
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
        hrp.CFrame = nearest.CFrame * CFrame.new(0,0,3.5)
        task.wait(0.05)
        -- Method 1: VirtualUser screen click
        pcall(function()
            local vu = game:GetService("VirtualUser")
            local sp = Camera:WorldToScreenPoint(nearest.Position)
            vu:Button1Down(Vector2.new(sp.X,sp.Y), Camera.CFrame); task.wait(0.07)
            vu:Button1Up(Vector2.new(sp.X,sp.Y),   Camera.CFrame)
        end)
        -- Method 2: ClickDetector
        pcall(function() TryClickDetector(nearest.Parent) end)
        -- Method 3: TouchInterest
        pcall(function()
            local char = LP.Character
            if char then
                local lhrp = char:FindFirstChild("HumanoidRootPart")
                if lhrp then
                    for _, part in ipairs(nearest.Parent:GetDescendants()) do
                        if part:IsA("BasePart") then
                            pcall(function() firetouchinterest(lhrp,part,0) end)
                            pcall(function() firetouchinterest(lhrp,part,1) end)
                        end
                    end
                end
            end
        end)
    end
    return nearest
end

-- =============================================================================
-- PERSISTENT STAT VARIABLES
-- (RunService loop applies these every frame - sliders/buttons update the vars)
-- =============================================================================
local statWalkSpeed = 16
local statJumpPower = 50
local statGravity   = 196

RunService.Heartbeat:Connect(function()
    pcall(function()
        local h = GetHum()
        if h then
            if h.WalkSpeed  ~= statWalkSpeed then h.WalkSpeed = statWalkSpeed end
            if h.UseJumpPower and h.JumpPower ~= statJumpPower then h.JumpPower = statJumpPower end
        end
        if WS.Gravity ~= statGravity then WS.Gravity = statGravity end
    end)
end)

-- =============================================================================
-- HELPER: Button-pair widget (replaces slider for mobile compatibility)
-- Creates:  [Label: NAME]  [Value: XX]  [ - ]  [ + ]
-- =============================================================================
local function AddButtonSlider(tab, name, min, max, default, step, suffix, onChange)
    local val = default
    local labelText = name .. ": " .. val .. (suffix or "")
    -- We store a reference to the label so we can update it
    local lbl = tab:AddLabel(labelText)

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
    -- Also allow direct text input
    tab:AddTextbox({
        Name = name .. " (type value)", Default = tostring(default), TextDisappear = false,
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
-- HOME TAB
-- =============================================================================
local HomeTab = Window:MakeTab({ Name = "Home", Icon = ICON, PremiumOnly = false })
HomeTab:AddSection({ Name = "Info" })
HomeTab:AddLabel("Player: "  .. LP.Name)
HomeTab:AddLabel("Game: "    .. DetectedGame)
HomeTab:AddLabel("PlaceId: " .. tostring(PlaceId))
HomeTab:AddLabel("Version: v5.0")
if Universal then
    HomeTab:AddParagraph("Universal Mode", "Your game is not in the list. Universal features only. PlaceId: "..tostring(PlaceId))
end
HomeTab:AddSection({ Name = "Test" })
HomeTab:AddButton({
    Name = "Ping Notification",
    Callback = function()
        OrionLib:MakeNotification({ Name = "Baddie404", Content = "Hub is working!", Image = ICON, Time = 3 })
    end
})

-- =============================================================================
-- PLAYER TAB
-- =============================================================================
local PlayerTab = Window:MakeTab({ Name = "Player", Icon = ICON, PremiumOnly = false })

-- Movement section -- using ButtonSlider for mobile compatibility
PlayerTab:AddSection({ Name = "Movement (tap - / + or type value)" })

AddButtonSlider(PlayerTab, "WalkSpeed", 0, 500, 16, 16, " studs/s", function(v) statWalkSpeed = v end)
AddButtonSlider(PlayerTab, "JumpPower", 0, 600, 50, 25, "", function(v)
    statJumpPower = v
    pcall(function() local h = GetHum(); if h then h.UseJumpPower = true end end)
end)
AddButtonSlider(PlayerTab, "Gravity", 0, 196, 196, 20, "", function(v) statGravity = v end)

-- Inf Jump
local InfJump = false
local ijConn = nil
PlayerTab:AddToggle({
    Name = "Inf Jump", Default = false,
    Callback = function(on)
        InfJump = on
        if ijConn then ijConn:Disconnect(); ijConn = nil end
        if on then
            local char = LP.Character or LP.CharacterAdded:Wait()
            local h = char:WaitForChild("Humanoid")
            ijConn = h.Jumping:Connect(function(j)
                if j and InfJump then
                    task.wait(0.05)
                    pcall(function()
                        local hrp = GetHRP()
                        if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X, statJumpPower, hrp.Velocity.Z) end
                    end)
                end
            end)
        end
    end
})

-- Fly
local FlyEnabled = false
local flySpeed = 60
local flyConn, flyBV, flyBG

local function StopFly()
    FlyEnabled = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    pcall(function()
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
        local h = GetHum(); if h then h.PlatformStand = false end
    end)
end
local function StartFly()
    FlyEnabled = true
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then StopFly(); return end
    hum.PlatformStand = true
    flyBV = Instance.new("BodyVelocity", hrp); flyBV.Velocity = Vector3.zero; flyBV.MaxForce = Vector3.new(1e9,1e9,1e9)
    flyBG = Instance.new("BodyGyro", hrp); flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9); flyBG.D = 100
    flyConn = RunService.Heartbeat:Connect(function()
        if not FlyEnabled then return end
        pcall(function()
            local dir = Vector3.zero
            local cf  = Camera.CFrame
            if UIS:IsKeyDown(Enum.KeyCode.W)          then dir = dir + cf.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S)          then dir = dir - cf.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A)          then dir = dir - cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D)          then dir = dir + cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space)      then dir = dir + Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift)  then dir = dir - Vector3.new(0,1,0) end
            flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
            flyBG.CFrame = cf
        end)
    end)
end

PlayerTab:AddToggle({ Name = "Fly (W/A/S/D + Space/Shift)", Default = false,
    Callback = function(on) if on then StartFly() else StopFly() end end })

AddButtonSlider(PlayerTab, "Fly Speed", 10, 500, 60, 20, " studs/s", function(v) flySpeed = v end)

-- Hover
local HoverOn = false
local hoverConn = nil
local hoverHeight = 15
local hoverBP = nil

local function StopHover()
    HoverOn = false
    if hoverConn then hoverConn:Disconnect(); hoverConn = nil end
    pcall(function()
        if hoverBP then hoverBP:Destroy(); hoverBP = nil end
        local h = GetHum(); if h then h.PlatformStand = false end
    end)
end

PlayerTab:AddToggle({
    Name = "Hover (float above ground)", Default = false,
    Callback = function(on)
        HoverOn = on
        if hoverConn then hoverConn:Disconnect(); hoverConn = nil end
        if not on then StopHover(); return end
        hoverConn = RunService.Heartbeat:Connect(function()
            if not HoverOn then return end
            pcall(function()
                local hrp = GetHRP(); local hum = GetHum()
                if not hrp or not hum then return end
                hum.PlatformStand = true
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {LP.Character}
                params.FilterType = Enum.RaycastFilterType.Exclude
                local ray = WS:Raycast(hrp.Position, Vector3.new(0,-500,0), params)
                local groundY = ray and ray.Position.Y or (hrp.Position.Y - hoverHeight)
                if not hoverBP or not hoverBP.Parent then
                    hoverBP = Instance.new("BodyPosition", hrp)
                    hoverBP.Name = "HoverBP"
                    hoverBP.MaxForce = Vector3.new(0,1e9,0)
                    hoverBP.D = 500; hoverBP.P = 15000
                end
                hoverBP.Position = Vector3.new(hrp.Position.X, groundY + hoverHeight, hrp.Position.Z)
            end)
        end)
    end
})

AddButtonSlider(PlayerTab, "Hover Height", 3, 200, 15, 5, " studs", function(v) hoverHeight = v end)

-- Noclip
local NoclipOn = false
local noclipConn = nil
PlayerTab:AddToggle({
    Name = "Noclip", Default = false,
    Callback = function(on)
        NoclipOn = on
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
        end
    end
})

-- Visuals
PlayerTab:AddSection({ Name = "Visuals" })
local fbConn = nil
local oldAmbient, oldFogEnd
PlayerTab:AddToggle({ Name = "Fullbright", Default = false,
    Callback = function(on)
        local L = game:GetService("Lighting")
        if on then
            oldAmbient = L.Ambient; oldFogEnd = L.FogEnd
            L.Ambient = Color3.new(1,1,1); L.Brightness = 2; L.FogEnd = 1e6
            if fbConn then fbConn:Disconnect() end
            fbConn = RunService.Heartbeat:Connect(function()
                L.Ambient = Color3.new(1,1,1); L.Brightness = 2
            end)
        else
            if fbConn then fbConn:Disconnect(); fbConn = nil end
            L.Ambient = oldAmbient or Color3.fromRGB(70,70,70)
            L.Brightness = 1; L.FogEnd = oldFogEnd or 1e4
        end
    end
})

AddButtonSlider(PlayerTab, "FOV", 30, 120, 70, 5, " deg",
    function(v) Camera.FieldOfView = v end)

-- Character
PlayerTab:AddSection({ Name = "Character" })
local afkConn = nil
PlayerTab:AddToggle({ Name = "Anti-AFK", Default = false,
    Callback = function(on)
        if afkConn then afkConn:Disconnect(); afkConn = nil end
        if on then
            afkConn = RunService.Heartbeat:Connect(function()
                pcall(function() LP:Move(Vector3.new(0,0,0)) end)
            end)
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
PlayerTab:AddToggle({ Name = "God Mode (HP Lock)", Default = false,
    Callback = function(on)
        if godConn then godConn:Disconnect(); godConn = nil end
        if on then
            godConn = RunService.Heartbeat:Connect(function()
                pcall(function() local h = GetHum(); if h then h.Health = h.MaxHealth end end)
            end)
        end
    end
})

PlayerTab:AddToggle({ Name = "Invisible", Default = false,
    Callback = function(on)
        pcall(function()
            local char = LP.Character; if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    p.LocalTransparencyModifier = on and 1 or 0
                end
                if p:IsA("Decal") then p.Transparency = on and 1 or 0 end
            end
        end)
    end
})

PlayerTab:AddButton({ Name = "Respawn",
    Callback = function() pcall(function() LP:LoadCharacter() end) end })

-- =============================================================================
-- TELEPORT TAB
-- =============================================================================
local TpTab = Window:MakeTab({ Name = "Teleport", Icon = ICON, PremiumOnly = false })
TpTab:AddSection({ Name = "Teleport to Player" })

local tpTargetName = ""

-- List players at load time for dropdown
local function GetOtherPlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(list, p.Name) end
    end
    if #list == 0 then table.insert(list, "(nobody)") end
    return list
end

TpTab:AddDropdown({
    Name = "Select Player", Default = GetOtherPlayers()[1],
    Options = GetOtherPlayers(),
    Callback = function(v) tpTargetName = v end
})

TpTab:AddButton({
    Name = "Teleport to Selected Player",
    Callback = function()
        if tpTargetName == "" or tpTargetName == "(nobody)" then
            OrionLib:MakeNotification({ Name = "TP", Content = "No player selected.", Image = ICON, Time = 2 }); return
        end
        local found = false
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name == tpTargetName then
                local tHrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if tHrp then
                    SafeTP(tHrp.CFrame * CFrame.new(3,0,3))
                    OrionLib:MakeNotification({ Name = "TP", Content = "To "..p.Name, Image = ICON, Time = 2 })
                    found = true
                end
                break
            end
        end
        if not found then
            OrionLib:MakeNotification({ Name = "TP", Content = "'"..tpTargetName.."' not found.", Image = ICON, Time = 3 })
        end
    end
})

TpTab:AddButton({
    Name = "List Players",
    Callback = function()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then table.insert(names, p.Name) end end
        local msg = #names > 0 and table.concat(names, ", ") or "No other players"
        OrionLib:MakeNotification({ Name = "Players ("..#names..")", Content = msg, Image = ICON, Time = 8 })
    end
})

TpTab:AddSection({ Name = "Coordinates" })
local tpX, tpY, tpZ = "0","200","0"
TpTab:AddTextbox({ Name = "X", Default = "0", TextDisappear = false, Callback = function(v) tpX = v end })
TpTab:AddTextbox({ Name = "Y", Default = "200", TextDisappear = false, Callback = function(v) tpY = v end })
TpTab:AddTextbox({ Name = "Z", Default = "0", TextDisappear = false, Callback = function(v) tpZ = v end })
TpTab:AddButton({ Name = "Go to XYZ",
    Callback = function()
        local x,y,z = tonumber(tpX) or 0, tonumber(tpY) or 0, tonumber(tpZ) or 0
        SafeTP(CFrame.new(x,y,z), true)
        OrionLib:MakeNotification({ Name = "TP Coords", Content = x..","..y..","..z, Image = ICON, Time = 2 })
    end
})

TpTab:AddSection({ Name = "Quick TP" })
TpTab:AddButton({ Name = "TP to Spawn",
    Callback = function()
        pcall(function()
            local sp = WS:FindFirstChildOfClass("SpawnLocation")
            SafeTP(CFrame.new((sp and sp.Position or Vector3.new(0,5,0)) + Vector3.new(0,5,0)), true)
        end)
    end
})
TpTab:AddButton({ Name = "TP to nearest Mob",
    Callback = function()
        pcall(function()
            local hrp = GetHRP(); if not hrp then return end
            local closest, closestDist = nil, math.huge
            for _, h in ipairs(WS:GetDescendants()) do
                if h:IsA("Humanoid") and h.Health > 0 and not Players:GetPlayerFromCharacter(h.Parent) then
                    local rp = h.Parent:FindFirstChild("HumanoidRootPart")
                    if rp and rp.Position.Y < 8000 then
                        local d = (hrp.Position - rp.Position).Magnitude
                        if d < closestDist then closestDist = d; closest = rp end
                    end
                end
            end
            if closest then
                SafeTP(closest.CFrame * CFrame.new(0,0,4), true)
                OrionLib:MakeNotification({ Name = "TP", Content = "Mob "..math.floor(closestDist).."st away", Image = ICON, Time = 2 })
            else
                OrionLib:MakeNotification({ Name = "TP", Content = "No mob found.", Image = ICON, Time = 2 })
            end
        end)
    end
})

-- =============================================================================
-- ESP TAB
-- =============================================================================
local EspTab = Window:MakeTab({ Name = "ESP", Icon = ICON, PremiumOnly = false })
EspTab:AddSection({ Name = "Player ESP" })

local EspOn = false
local EspColor = Color3.fromRGB(255,50,50)
local EspBoxes = {}
local espLoop = nil

local function MakeBox(player)
    if player == LP then return end
    pcall(function()
        if EspBoxes[player] then EspBoxes[player].Root:Destroy(); EspBoxes[player] = nil end
        local char = player.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local bb = Instance.new("BillboardGui")
        bb.AlwaysOnTop = true; bb.Size = UDim2.new(0,4,0,5)
        bb.SizeOffset = Vector2.new(3.5,4); bb.StudsOffset = Vector3.new(0,2.5,0)
        bb.Adornee = hrp; bb.Parent = CoreGui
        local box = Instance.new("Frame", bb); box.Size = UDim2.fromScale(1,1); box.BackgroundTransparency = 1
        local stroke = Instance.new("UIStroke", box); stroke.Color = EspColor; stroke.Thickness = 1.5
        local nameL = Instance.new("TextLabel", bb)
        nameL.AnchorPoint = Vector2.new(0.5,1); nameL.Position = UDim2.new(0.5,0,0,-3)
        nameL.Size = UDim2.new(1,50,0,16); nameL.BackgroundTransparency = 1
        nameL.Text = player.Name; nameL.TextColor3 = Color3.new(1,1,1); nameL.TextSize = 12
        nameL.Font = Enum.Font.GothamBold; nameL.TextStrokeTransparency = 0
        local distL = Instance.new("TextLabel", bb)
        distL.AnchorPoint = Vector2.new(0.5,0); distL.Position = UDim2.new(0.5,0,1,2)
        distL.Size = UDim2.new(1,50,0,14); distL.BackgroundTransparency = 1
        distL.Text = "0m"; distL.TextColor3 = Color3.fromRGB(200,200,200); distL.TextSize = 11
        distL.Font = Enum.Font.Gotham; distL.TextStrokeTransparency = 0
        local hpTrack = Instance.new("Frame", bb)
        hpTrack.AnchorPoint = Vector2.new(0,0.5); hpTrack.Position = UDim2.new(0,-10,0.5,0)
        hpTrack.Size = UDim2.new(0,4,1,0); hpTrack.BackgroundColor3 = Color3.fromRGB(40,40,40); hpTrack.BorderSizePixel = 0
        local hpFill = Instance.new("Frame", hpTrack)
        hpFill.AnchorPoint = Vector2.new(0,1); hpFill.Position = UDim2.fromScale(0,1)
        hpFill.Size = UDim2.fromScale(1,1); hpFill.BackgroundColor3 = Color3.fromRGB(80,255,80); hpFill.BorderSizePixel = 0
        EspBoxes[player] = { Root=bb, Stroke=stroke, NameL=nameL, DistL=distL, HpFill=hpFill }
    end)
end
local function RemoveBox(p)
    if EspBoxes[p] then pcall(function() EspBoxes[p].Root:Destroy() end); EspBoxes[p] = nil end
end
local function ClearEsp()
    for p in pairs(EspBoxes) do RemoveBox(p) end
    if espLoop then espLoop:Disconnect(); espLoop = nil end
end

EspTab:AddToggle({ Name = "Player Box ESP", Default = false,
    Callback = function(on)
        EspOn = on
        if on then
            for _, p in ipairs(Players:GetPlayers()) do MakeBox(p) end
            if espLoop then espLoop:Disconnect() end
            espLoop = RunService.Heartbeat:Connect(function()
                local myHrp = GetHRP()
                for p, data in pairs(EspBoxes) do
                    pcall(function()
                        if not data.Root.Parent then EspBoxes[p] = nil; return end
                        data.Stroke.Color = EspColor
                        if myHrp then
                            local tHrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                            if tHrp then data.DistL.Text = math.floor((myHrp.Position-tHrp.Position).Magnitude).."m" end
                        end
                        local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
                        if h then
                            local pct = h.Health / math.max(h.MaxHealth,1)
                            data.HpFill.Size = UDim2.fromScale(1,pct)
                            data.HpFill.BackgroundColor3 = Color3.fromRGB(math.floor(255*(1-pct)), math.floor(255*pct), 0)
                        end
                    end)
                end
            end)
        else ClearEsp() end
    end
})

EspTab:AddDropdown({ Name = "ESP Color", Default = "Red",
    Options = {"Red","Green","Blue","Yellow","White","Cyan"},
    Callback = function(v)
        local m = {Red=Color3.fromRGB(255,50,50),Green=Color3.fromRGB(50,255,80),Blue=Color3.fromRGB(60,130,255),
                   Yellow=Color3.fromRGB(255,220,30),White=Color3.fromRGB(255,255,255),Cyan=Color3.fromRGB(0,230,230)}
        EspColor = m[v] or Color3.fromRGB(255,50,50)
    end
})

Players.PlayerAdded:Connect(function(p)
    if EspOn then p.CharacterAdded:Connect(function() task.wait(0.5); MakeBox(p) end); MakeBox(p) end
end)
Players.PlayerRemoving:Connect(RemoveBox)

-- =============================================================================
-- SERVER TAB
-- =============================================================================
local ServerTab = Window:MakeTab({ Name = "Server", Icon = ICON, PremiumOnly = false })
ServerTab:AddSection({ Name = "Server Tools" })
ServerTab:AddButton({ Name = "Server Hop",
    Callback = function()
        local ok2, e = pcall(function() TeleportService:Teleport(PlaceId, LP) end)
        if not ok2 then OrionLib:MakeNotification({ Name = "Server Hop", Content = tostring(e), Image = ICON, Time = 3 }) end
    end
})
ServerTab:AddLabel("Players: "..#Players:GetPlayers().."/"..Players.MaxPlayers)
ServerTab:AddLabel("Job: "..tostring(game.JobId):sub(1,16).."...")

-- =============================================================================
-- BLOX FRUITS TAB
-- =============================================================================
if DetectedGame == "Blox Fruits" then

local BFTab = Window:MakeTab({ Name = "Blox Fruits", Icon = ICON, PremiumOnly = false })

-- ---------- AUTO FARM ----------
BFTab:AddSection({ Name = "Auto Farm" })

local bfFarmOn    = false
local bfFarmRange = 40

BFTab:AddToggle({ Name = "Auto Farm (TP + Attack)", Default = false,
    Callback = function(on)
        bfFarmOn = on
        if on then
            task.spawn(function()
                while bfFarmOn do
                    pcall(function()
                        local hrp = GetHRP()
                        if hrp then AttackNearest(hrp, bfFarmRange) end
                    end)
                    task.wait(0.25)
                end
            end)
        end
    end
})

AddButtonSlider(BFTab, "Farm Range", 10, 300, 40, 10, " studs", function(v) bfFarmRange = v end)

-- ---------- KILL AURA ----------
BFTab:AddSection({ Name = "Combat" })

local bfAuraOn    = false
local bfAuraRange = 20

BFTab:AddToggle({ Name = "Kill Aura", Default = false,
    Callback = function(on)
        bfAuraOn = on
        if on then
            task.spawn(function()
                while bfAuraOn do
                    pcall(function()
                        local hrp = GetHRP()
                        if hrp then AttackNearest(hrp, bfAuraRange) end
                    end)
                    task.wait(0.2)
                end
            end)
        end
    end
})

AddButtonSlider(BFTab, "Aura Range", 5, 100, 20, 5, " studs", function(v) bfAuraRange = v end)

-- ---------- AUTO SPIN ----------
BFTab:AddSection({ Name = "Auto Spin" })

local bfSpinOn = false

BFTab:AddToggle({ Name = "Auto Spin (fruit randomizer)", Default = false,
    Callback = function(on)
        bfSpinOn = on
        if on then
            task.spawn(function()
                while bfSpinOn do
                    -- Method 1: InvokeServer SpinFruit
                    pcall(function()
                        local rs = game:GetService("ReplicatedStorage")
                        local commF = rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("CommF_")
                        if commF then commF:InvokeServer("SpinFruit") end
                    end)
                    -- Method 2: look for spin proximity prompt
                    pcall(function()
                        for _, obj in ipairs(WS:GetDescendants()) do
                            if obj:IsA("ProximityPrompt") and
                               (obj.ActionText:lower():find("spin") or obj.ObjectText:lower():find("spin")) then
                                fireproximityprompt(obj)
                            end
                        end
                    end)
                    -- Method 3: look for spin button via UI
                    pcall(function()
                        for _, gui in ipairs(LP.PlayerGui:GetDescendants()) do
                            if gui:IsA("TextButton") and gui.Text:lower():find("spin") then
                                local vu = game:GetService("VirtualUser")
                                local pos = gui.AbsolutePosition + gui.AbsoluteSize/2
                                vu:Button1Down(pos, Camera.CFrame); task.wait(0.05); vu:Button1Up(pos, Camera.CFrame)
                            end
                        end
                    end)
                    task.wait(1.5) -- spin cooldown
                end
            end)
        end
    end
})

BFTab:AddLabel("Auto Spin tries: InvokeServer, ProximityPrompt, UI button")

-- ---------- SEA 1 AUTO QUEST ----------
BFTab:AddSection({ Name = "Sea 1 Auto Quest" })

-- Exhaustive, highly precise Sea 1 Quests database (Levels 1 to 700)
local Sea1Quests = {
    {
        name = "Bandits (Lvl 1)",
        minLevel = 1,
        npcCF = CFrame.new(1060, 16, 1500),
        questName = "BanditQuest1",
        questId = 1,
        mobKey = {"Bandit"},
        mobCF = CFrame.new(1060, 16, 1540)
    },
    {
        name = "Monkeys (Lvl 10)",
        minLevel = 10,
        npcCF = CFrame.new(-1600, 37, 150),
        questName = "JungleQuest",
        questId = 1,
        mobKey = {"Monkey"},
        mobCF = CFrame.new(-1620, 40, 120)
    },
    {
        name = "Gorillas (Lvl 15)",
        minLevel = 15,
        npcCF = CFrame.new(-1600, 37, 150),
        questName = "JungleQuest",
        questId = 2,
        mobKey = {"Gorilla"},
        mobCF = CFrame.new(-1200, 25, -230)
    },
    {
        name = "Pirates (Lvl 30)",
        minLevel = 30,
        npcCF = CFrame.new(-1136, 4, 3855),
        questName = "BuggyQuest1",
        questId = 1,
        mobKey = {"Pirate"},
        mobCF = CFrame.new(-1220, 15, 3910)
    },
    {
        name = "Brutes (Lvl 45)",
        minLevel = 45,
        npcCF = CFrame.new(-1136, 4, 3855),
        questName = "BuggyQuest1",
        questId = 2,
        mobKey = {"Brute"},
        mobCF = CFrame.new(-1145, 15, 4310)
    },
    {
        name = "Desert Bandits (Lvl 60)",
        minLevel = 60,
        npcCF = CFrame.new(894, 6, 4385),
        questName = "DesertQuest",
        questId = 1,
        mobKey = {"Desert Bandit"},
        mobCF = CFrame.new(990, 6, 4420)
    },
    {
        name = "Desert Officers (Lvl 75)",
        minLevel = 75,
        npcCF = CFrame.new(894, 6, 4385),
        questName = "DesertQuest",
        questId = 2,
        mobKey = {"Desert Officer"},
        mobCF = CFrame.new(1570, 6, 4360)
    },
    {
        name = "Snow Bandits (Lvl 90)",
        minLevel = 90,
        npcCF = CFrame.new(1386, 26, -1300),
        questName = "SnowQuest",
        questId = 1,
        mobKey = {"Snow Bandit"},
        mobCF = CFrame.new(1290, 26, -1340)
    },
    {
        name = "Snowmen (Lvl 100)",
        minLevel = 100,
        npcCF = CFrame.new(1386, 26, -1300),
        questName = "SnowQuest",
        questId = 2,
        mobKey = {"Snowman"},
        mobCF = CFrame.new(1280, 26, -1450)
    },
    {
        name = "Chief Petty Officers (Lvl 120)",
        minLevel = 120,
        npcCF = CFrame.new(-4850, 20, 4300),
        questName = "MarineQuest",
        questId = 1,
        mobKey = {"Chief Petty Officer"},
        mobCF = CFrame.new(-4830, 20, 4100)
    },
    {
        name = "Sky Bandits (Lvl 150)",
        minLevel = 150,
        npcCF = CFrame.new(-1243, 355, -5900),
        questName = "SkyQuest",
        questId = 1,
        mobKey = {"Sky Bandit"},
        mobCF = CFrame.new(-1220, 390, -5670)
    },
    {
        name = "Dark Masters (Lvl 175)",
        minLevel = 175,
        npcCF = CFrame.new(-1243, 355, -5900),
        questName = "SkyQuest",
        questId = 2,
        mobKey = {"Dark Master"},
        mobCF = CFrame.new(-900, 390, -5610)
    },
    {
        name = "Prisoners (Lvl 190)",
        minLevel = 190,
        npcCF = CFrame.new(4830, 6, 4775),
        questName = "PrisonQuest",
        questId = 1,
        mobKey = {"Prisoner"},
        mobCF = CFrame.new(4800, 6, 4650)
    },
    {
        name = "Dangerous Prisoners (Lvl 210)",
        minLevel = 210,
        npcCF = CFrame.new(4830, 6, 4775),
        questName = "PrisonQuest",
        questId = 2,
        mobKey = {"Dangerous Prisoner"},
        mobCF = CFrame.new(4850, 6, 4650)
    },
    {
        name = "Toga Warriors (Lvl 250)",
        minLevel = 250,
        npcCF = CFrame.new(-1580, 7, -2980),
        questName = "ColosseumQuest",
        questId = 1,
        mobKey = {"Toga Warrior"},
        mobCF = CFrame.new(-1800, 7, -2800)
    },
    {
        name = "Gladiators (Lvl 275)",
        minLevel = 275,
        npcCF = CFrame.new(-1580, 7, -2980),
        questName = "ColosseumQuest",
        questId = 2,
        mobKey = {"Gladiator"},
        mobCF = CFrame.new(-1400, 7, -3000)
    },
    {
        name = "Military Soldiers (Lvl 300)",
        minLevel = 300,
        npcCF = CFrame.new(-5200, 8, 8400),
        questName = "MagmaQuest",
        questId = 1,
        mobKey = {"Military Soldier"},
        mobCF = CFrame.new(-5300, 8, 8500)
    },
    {
        name = "Military Spies (Lvl 330)",
        minLevel = 330,
        npcCF = CFrame.new(-5200, 8, 8400),
        questName = "MagmaQuest",
        questId = 2,
        mobKey = {"Military Spy"},
        mobCF = CFrame.new(-5350, 8, 8350)
    },
    {
        name = "Fishman Warriors (Lvl 375)",
        minLevel = 375,
        npcCF = CFrame.new(6110, 18, 1550),
        questName = "FishmanQuest",
        questId = 1,
        mobKey = {"Fishman Warrior"},
        mobCF = CFrame.new(6000, 18, 1400)
    },
    {
        name = "Fishman Commandos (Lvl 400)",
        minLevel = 400,
        npcCF = CFrame.new(6110, 18, 1550),
        questName = "FishmanQuest",
        questId = 2,
        mobKey = {"Fishman Commando"},
        mobCF = CFrame.new(6200, 18, 1400)
    },
    {
        name = "God's Guards (Lvl 450)",
        minLevel = 450,
        npcCF = CFrame.new(-4510, 1000, -2500),
        questName = "SkyExp1Quest",
        questId = 1,
        mobKey = {"God's Guard"},
        mobCF = CFrame.new(-4600, 1000, -2600)
    },
    {
        name = "Shandas (Lvl 475)",
        minLevel = 475,
        npcCF = CFrame.new(-4510, 1000, -2500),
        questName = "SkyExp1Quest",
        questId = 2,
        mobKey = {"Shanda"},
        mobCF = CFrame.new(-4300, 1000, -2400)
    },
    {
        name = "Royal Squads (Lvl 525)",
        minLevel = 525,
        npcCF = CFrame.new(-5200, 1200, -2000),
        questName = "SkyExp2Quest",
        questId = 1,
        mobKey = {"Royal Squad"},
        mobCF = CFrame.new(-5300, 1200, -2100)
    },
    {
        name = "Royal Soldiers (Lvl 550)",
        minLevel = 550,
        npcCF = CFrame.new(-5200, 1200, -2000),
        questName = "SkyExp2Quest",
        questId = 2,
        mobKey = {"Royal Soldier"},
        mobCF = CFrame.new(-5100, 1200, -1900)
    },
    {
        name = "Galley Pirates (Lvl 575)",
        minLevel = 575,
        npcCF = CFrame.new(5120, 4, 4100),
        questName = "FountainQuest",
        questId = 1,
        mobKey = {"Galley Pirate"},
        mobCF = CFrame.new(5200, 4, 3900)
    },
    {
        name = "Galley Captains (Lvl 625)",
        minLevel = 625,
        npcCF = CFrame.new(5120, 4, 4100),
        questName = "FountainQuest",
        questId = 2,
        mobKey = {"Galley Captain"},
        mobCF = CFrame.new(5400, 4, 4000)
    }
}

-- Fetch options for manual dropdown override
local questOptions = {"(Auto Select Best)"}
for _, q in ipairs(Sea1Quests) do table.insert(questOptions, q.name) end

local manualQuestIndex = 0 -- 0 means auto-detect based on level
BFTab:AddDropdown({
    Name = "Active Farm Quest", Default = questOptions[1],
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

-- Weapon Type Selection Dropdown
local selectedWeaponType = "Melee"
BFTab:AddDropdown({
    Name = "Select Weapon Type", Default = "Melee",
    Options = {"Melee", "Sword", "Blox Fruit"},
    Callback = function(v)
        selectedWeaponType = v
    end
})

local bfAutoQuestOn = false
local bfQuestStatus = "Idle"
local farmPlatform = nil

-- Helper to get player's dynamic level
local function GetPlayerLevel()
    local lvl = 1
    pcall(function()
        if LP:FindFirstChild("Data") and LP.Data:FindFirstChild("Level") then
            lvl = LP.Data.Level.Value
        elseif LP:FindFirstChild("leaderstats") and LP.leaderstats:FindFirstChild("Level") then
            lvl = LP.leaderstats.Level.Value
        elseif LP:FindFirstChild("leaderstats") and LP.leaderstats:FindFirstChild("Lvl") then
            lvl = LP.leaderstats.Lvl.Value
        end
    end)
    return lvl
end

-- Helper to find active quest state
local function HasActiveQuest()
    local has = false
    pcall(function()
        local mainGui = LP:WaitForChild("PlayerGui", 5):FindFirstChild("Main")
        if mainGui and mainGui:FindFirstChild("Quest") and mainGui.Quest.Visible then
            has = true
        end
    end)
    return has
end

-- Find Quest NPC on Workspace
local function FindQuestNPC(npcCF, radius)
    radius = radius or 150
    local closestNPC = nil
    local closestDist = radius
    pcall(function()
        for _, obj in ipairs(WS:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():find("quest") or obj.Name:lower():find("giver") or obj.Name:lower():find("npc")) then
                local rp = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                if rp then
                    local dist = (rp.Position - npcCF.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestNPC = obj
                    end
                end
            end
        end
    end)
    return closestNPC
end

-- Create safe farm platform so player hovers stably in air
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
        farmPlatform.CFrame = CFrame.new(pos) - Vector3.new(0, 3, 0)
    end)
end

local function destroyFarmPlatform()
    pcall(function()
        if farmPlatform then
            farmPlatform:Destroy()
            farmPlatform = nil
        end
    end)
end

-- Auto equip tools based on category
local function autoEquipWeapon()
    local char = LP.Character
    if not char then return end
    -- Check if already holding a tool of the correct category
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            local isMatch = false
            if selectedWeaponType == "Melee" and (child.ToolTip == "Melee" or child.Name == "Combat" or child.Name:lower():find("step") or child.Name:lower():find("claw") or child.Name:lower():find("kung") or child.Name:lower():find("fist")) then
                isMatch = true
            elseif selectedWeaponType == "Sword" and (child.ToolTip == "Sword" or child.Name == "Katana" or child.Name == "Cutlass" or child.Name:lower():find("blade") or child.Name:lower():find("saber") or child.Name:lower():find("sword")) then
                isMatch = true
            elseif selectedWeaponType == "Blox Fruit" and (child.ToolTip == "Blox Fruit" or child.Name:lower():find("fruit") or child.Name == "Ice" or child.Name == "Light" or child.Name == "Magma") then
                isMatch = true
            end
            if isMatch then return child end
        end
    end
    -- Search Backpack
    for _, tool in ipairs(LP.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local isMatch = false
            if selectedWeaponType == "Melee" and (tool.ToolTip == "Melee" or tool.Name == "Combat" or tool.Name:lower():find("step") or tool.Name:lower():find("claw") or tool.Name:lower():find("kung") or tool.Name:lower():find("fist")) then
                isMatch = true
            elseif selectedWeaponType == "Sword" and (tool.ToolTip == "Sword" or tool.Name == "Katana" or tool.Name == "Cutlass" or tool.Name:lower():find("blade") or tool.Name:lower():find("saber") or tool.Name:lower():find("sword")) then
                isMatch = true
            elseif selectedWeaponType == "Blox Fruit" and (tool.ToolTip == "Blox Fruit" or tool.Name:lower():find("fruit") or tool.Name == "Ice" or tool.Name == "Light" or tool.Name == "Magma") then
                isMatch = true
            end
            if isMatch then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:EquipTool(tool); return tool end
            end
        end
    end
    -- Fallback: Equip first tool in backpack if preferred type is not found
    for _, tool in ipairs(LP.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:EquipTool(tool); return tool end
        end
    end
end

-- High performance mobile/PC mob magnet (pulls matching mobs to target coordinate)
local function pullMobs(keywords, targetPos)
    local myHrp = GetHRP()
    if not myHrp then return end
    pcall(function()
        local op = OverlapParams.new()
        op.FilterType = Enum.RaycastFilterType.Exclude
        op.FilterDescendantsInstances = {LP.Character}
        
        local parts = WS:GetPartBoundsInRadius(myHrp.Position, 250, op)
        for _, part in ipairs(parts) do
            local char = part.Parent
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local r_hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and r_hrp and not Players:GetPlayerFromCharacter(char) then
                local isMob = false
                for _, kw in ipairs(keywords) do
                    if char.Name:lower():find(kw:lower()) then
                        isMob = true
                        break
                    end
                end
                if isMob then
                    r_hrp.CanCollide = false
                    -- Teleport exactly in front of and slightly below player (safely within attack range)
                    r_hrp.CFrame = CFrame.new(targetPos) * CFrame.new(0, -3.5, -2.5)
                    r_hrp.Velocity = Vector3.zero
                    -- Stop mob from hitting back (God Mode platform freeze)
                    hum.PlatformStand = true
                end
            end
        end
    end)
end

-- Pro-grade combat M1 + remote attack triggering (extremely rapid no-cooldown)
local function fastAttack()
    pcall(function()
        local rtc = game:GetService("ReplicatedStorage"):FindFirstChild("RigControllerToClient")
        if rtc and rtc:FindFirstChild("ClientReady") then
            rtc.ClientReady:FireServer()
        end
    end)
    pcall(function()
        -- Activate current weapon
        local char = LP.Character
        if char then
            for _, child in ipairs(char:GetChildren()) do
                if child:IsA("Tool") then
                    child:Activate()
                end
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

-- Main Auto Farm Loop
BFTab:AddToggle({ Name = "Sea 1 Auto Quest (FULL LOOP)", Default = false,
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
                    local level = GetPlayerLevel()
                    local q = nil
                    
                    if manualQuestIndex > 0 then
                        q = Sea1Quests[manualQuestIndex]
                    else
                        -- Auto detect optimal quest by player level
                        for _, sq in ipairs(Sea1Quests) do
                            if level >= sq.minLevel then
                                q = sq
                            end
                        end
                    end
                    
                    if not q then q = Sea1Quests[1] end
                    
                    local hasQuest = HasActiveQuest()
                    
                    if not hasQuest then
                        bfQuestStatus = "Taking quest: " .. q.name
                        -- Try bypass remote invocation first (fastest, remote auto-accept)
                        pcall(function()
                            local commF = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game.ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                            if commF then
                                commF:InvokeServer("StartQuest", q.questName, q.questId)
                            end
                        end)
                        task.wait(0.5)
                        
                        -- If remote bypassed failed, walk/TP to NPC as fallback
                        if not HasActiveQuest() then
                            SafeTP(q.npcCF * CFrame.new(0, 3, 5))
                            task.wait(1)
                            local npc = FindQuestNPC(q.npcCF, 120)
                            if npc then
                                local rp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
                                if rp then SafeTP(CFrame.new(rp.Position + Vector3.new(0,0,5)), true); task.wait(0.3) end
                                TryFireProximity(npc, 25)
                                task.wait(0.2)
                                TryClickDetector(npc)
                            end
                            task.wait(1)
                        end
                    else
                        -- If we have an active quest, teleport to mob zone and group them
                        bfQuestStatus = "Farming: " .. q.name
                        local targetFarmPos = q.mobCF.Position + Vector3.new(0, 18, 0) -- safe hovering altitude
                        
                        local hrp = GetHRP()
                        if hrp then
                            createFarmPlatform(targetFarmPos)
                            SafeTP(CFrame.new(targetFarmPos))
                            
                            -- Magnet, Weapon Equip, Fast Attack
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

-- ---------- AUTO STATS ----------
BFTab:AddSection({ Name = "Auto Stats Allocator" })

local autoStats = {
    Melee = false,
    Defense = false,
    Sword = false,
    ["Blox Fruit"] = false
}

BFTab:AddToggle({ Name = "Auto Stats Melee", Default = false,
    Callback = function(on) autoStats.Melee = on end
})
BFTab:AddToggle({ Name = "Auto Stats Defense", Default = false,
    Callback = function(on) autoStats.Defense = on end
})
BFTab:AddToggle({ Name = "Auto Stats Sword", Default = false,
    Callback = function(on) autoStats.Sword = on end
})
BFTab:AddToggle({ Name = "Auto Stats Blox Fruit", Default = false,
    Callback = function(on) autoStats["Blox Fruit"] = on end
})

-- Background daemon for auto stats spending
task.spawn(function()
    while true do
        task.wait(1)
        local hasStat = false
        for _, enabled in pairs(autoStats) do
            if enabled then hasStat = true; break end
        end
        if hasStat then
            pcall(function()
                local points = 0
                if LP:FindFirstChild("Data") and LP.Data:FindFirstChild("Points") then
                    points = LP.Data.Points.Value
                elseif LP:FindFirstChild("leaderstats") and LP.leaderstats:FindFirstChild("Points") then
                    points = LP.leaderstats.Points.Value
                end
                
                if points > 0 then
                    local commF = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game.ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                    if commF then
                        for stat, enabled in pairs(autoStats) do
                            if enabled then
                                commF:InvokeServer("AddPoint", stat, points)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ---------- AUTO BUY SHOP ITEM ----------
BFTab:AddSection({ Name = "Auto Buy Shop Items" })

BFTab:AddButton({ Name = "Buy Black Leg (150,000 Beli)",
    Callback = function()
        pcall(function()
            local commF = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game.ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if commF then
                local res = commF:InvokeServer("BuyBlackLeg")
                OrionLib:MakeNotification({ Name = "Shop Purchase", Content = "Brought style Black Leg!", Image = ICON, Time = 3 })
            end
        end)
    end
})

BFTab:AddButton({ Name = "Buy Electro (500,000 Beli)",
    Callback = function()
        pcall(function()
            local commF = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game.ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if commF then
                local res = commF:InvokeServer("BuyElectro")
                OrionLib:MakeNotification({ Name = "Shop Purchase", Content = "Brought style Electro!", Image = ICON, Time = 3 })
            end
        end)
    end
})

BFTab:AddButton({ Name = "Buy Water Kung Fu (750,000 Beli)",
    Callback = function()
        pcall(function()
            local commF = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game.ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if commF then
                local res = commF:InvokeServer("BuyFishmanKungFu")
                OrionLib:MakeNotification({ Name = "Shop Purchase", Content = "Brought style Water Kung Fu!", Image = ICON, Time = 3 })
            end
        end)
    end
})

BFTab:AddButton({ Name = "Buy Katana (1,000 Beli)",
    Callback = function()
        pcall(function()
            local commF = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game.ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if commF then
                local res = commF:InvokeServer("BuyItem", "Katana")
                OrionLib:MakeNotification({ Name = "Shop Purchase", Content = "Brought Katana sword!", Image = ICON, Time = 3 })
            end
        end)
    end
})

BFTab:AddButton({ Name = "Buy Triple Katana (60,000 Beli)",
    Callback = function()
        pcall(function()
            local commF = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game.ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if commF then
                local res = commF:InvokeServer("BuyItem", "Triple Katana")
                OrionLib:MakeNotification({ Name = "Shop Purchase", Content = "Brought Triple Katana!", Image = ICON, Time = 3 })
            end
        end)
    end
})

BFTab:AddButton({ Name = "Show Quest Status",
    Callback = function()
        OrionLib:MakeNotification({ Name = "Quest Status", Content = bfQuestStatus, Image = ICON, Time = 5 })
    end
})

-- ---------- FRUITS ----------
BFTab:AddSection({ Name = "Devil Fruits" })

BFTab:AddButton({ Name = "TP to nearest Fruit",
    Callback = function()
        pcall(function()
            local hrp = GetHRP(); if not hrp then return end
            local closest, closestDist = nil, math.huge
            for _, obj in ipairs(WS:GetDescendants()) do
                if (obj.Name:lower():find("fruit") or obj.Name:lower():find("devil"))
                   and (obj:IsA("Model") or obj:IsA("BasePart")) then
                    local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                    local dist = (hrp.Position - pos).Magnitude
                    if dist < closestDist then closestDist = dist; closest = pos end
                end
            end
            if closest then
                SafeTP(CFrame.new(closest + Vector3.new(0,3,0)), true)
                OrionLib:MakeNotification({ Name = "Fruit", Content = "Found! "..math.floor(closestDist).."st", Image = ICON, Time = 3 })
            else
                OrionLib:MakeNotification({ Name = "Fruit", Content = "No fruit found.", Image = ICON, Time = 3 })
            end
        end)
    end
})

-- Auto collect fruit
local bfFruitOn = false
BFTab:AddToggle({ Name = "Auto Collect Fruits", Default = false,
    Callback = function(on)
        bfFruitOn = on
        if on then
            task.spawn(function()
                while bfFruitOn do
                    pcall(function()
                        local hrp = GetHRP(); if not hrp then return end
                        for _, obj in ipairs(WS:GetDescendants()) do
                            if not bfFruitOn then break end
                            if (obj.Name:lower():find("fruit") or obj.Name:lower():find("devil"))
                               and (obj:IsA("Model") or obj:IsA("BasePart")) then
                                local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                                if (hrp.Position - pos).Magnitude < 300 then
                                    SafeTP(CFrame.new(pos + Vector3.new(0,3,0)), true)
                                    task.wait(0.5)
                                    TryFireProximity(obj:IsA("Model") and obj or obj.Parent, 10)
                                    TryClickDetector(obj:IsA("Model") and obj or obj.Parent)
                                    task.wait(0.5)
                                end
                            end
                        end
                    end)
                    task.wait(3)
                end
            end)
        end
    end
})

-- ---------- ISLAND TP ----------
BFTab:AddSection({ Name = "Island Teleport" })

local bfIslands = {
    ["Starter Island"]       = CFrame.new(1060, 16, 1500),
    ["Jungle"]               = CFrame.new(-1600, 37, 150),
    ["Pirate Village"]       = CFrame.new(-1136, 4, 3855),
    ["Desert"]               = CFrame.new(894, 6, 4385),
    ["Snowy Mountain"]       = CFrame.new(1386, 26, -1300),
    ["Marine Fortress"]      = CFrame.new(-4850, 20, 4300),
    ["Skylands (Lower)"]     = CFrame.new(-1243, 355, -5900),
    ["Skylands (Upper)"]     = CFrame.new(-4510, 1000, -2500),
    ["Prison"]               = CFrame.new(4830, 6, 4775),
    ["Colosseum"]            = CFrame.new(-1580, 7, -2980),
    ["Magma Village"]        = CFrame.new(-5200, 8, 8400),
    ["Underwater City"]      = CFrame.new(6110, 18, 1550),
    ["Fountain City"]        = CFrame.new(5120, 4, 4100)
}

local islandList = {}
for k in pairs(bfIslands) do table.insert(islandList, k) end
table.sort(islandList)

BFTab:AddDropdown({
    Name = "Select Island", Default = islandList[1], Options = islandList,
    Callback = function(v)
        if bfIslands[v] then
            SafeTP(bfIslands[v] * CFrame.new(0,3,0))
            OrionLib:MakeNotification({ Name = "TP", Content = v, Image = ICON, Time = 2 })
        end
    end
})

end -- Blox Fruits

-- =============================================================================
-- JJK ZERO TAB
-- =============================================================================
if DetectedGame == "JJK Zero" then

local JJKTab = Window:MakeTab({ Name = "JJK Zero", Icon = ICON, PremiumOnly = false })

JJKTab:AddSection({ Name = "Auto Farm" })
local jjkFarmOn = false
local jjkFarmRange = 30

JJKTab:AddToggle({ Name = "Auto Farm Mobs", Default = false,
    Callback = function(on)
        jjkFarmOn = on
        if on then
            task.spawn(function()
                while jjkFarmOn do
                    pcall(function()
                        local hrp = GetHRP()
                        if hrp then AttackNearest(hrp, jjkFarmRange) end
                    end)
                    task.wait(0.25)
                end
            end)
        end
    end
})
AddButtonSlider(JJKTab, "Farm Range", 5, 150, 30, 5, " studs", function(v) jjkFarmRange = v end)

JJKTab:AddSection({ Name = "Combat" })
local jjkAuraOn = false
JJKTab:AddToggle({ Name = "Auto Attack (M1 spam)", Default = false,
    Callback = function(on)
        jjkAuraOn = on
        if on then
            task.spawn(function()
                while jjkAuraOn do
                    pcall(function()
                        local vu = game:GetService("VirtualUser")
                        vu:Button1Down(Vector2.new(Mouse.X,Mouse.Y), Camera.CFrame); task.wait(0.06)
                        vu:Button1Up(Vector2.new(Mouse.X,Mouse.Y), Camera.CFrame)
                    end)
                    task.wait(0.12)
                end
            end)
        end
    end
})

JJKTab:AddToggle({ Name = "Auto Dash (Z-spam)", Default = false,
    Callback = function(on)
        if on then
            task.spawn(function()
                while on do
                    pcall(function()
                        local vu = game:GetService("VirtualUser")
                        vu:KeyDown("z"); task.wait(0.05); vu:KeyUp("z")
                    end)
                    task.wait(0.15)
                    if not on then break end
                end
            end)
        end
    end
})

JJKTab:AddSection({ Name = "Teleport" })
JJKTab:AddButton({ Name = "TP to nearest Mob",
    Callback = function()
        pcall(function()
            local hrp = GetHRP(); if not hrp then return end
            local best, bestDist = nil, math.huge
            for _, h in ipairs(WS:GetDescendants()) do
                if h:IsA("Humanoid") and h.Health > 0 and not Players:GetPlayerFromCharacter(h.Parent) then
                    local rp = h.Parent:FindFirstChild("HumanoidRootPart")
                    if rp and rp.Position.Y < 8000 then
                        local d = (hrp.Position-rp.Position).Magnitude
                        if d < bestDist then bestDist = d; best = rp end
                    end
                end
            end
            if best then SafeTP(best.CFrame * CFrame.new(0,0,4), true) end
        end)
    end
})

end -- JJK Zero

-- =============================================================================
-- WORLD ZERO TAB
-- =============================================================================
if DetectedGame == "World Zero" then

local WZTab = Window:MakeTab({ Name = "World Zero", Icon = ICON, PremiumOnly = false })

WZTab:AddSection({ Name = "Auto Farm" })
local wzFarmOn = false
local wzAuraRange = 25

WZTab:AddToggle({ Name = "Auto Farm (Kill Aura)", Default = false,
    Callback = function(on)
        wzFarmOn = on
        if on then
            task.spawn(function()
                while wzFarmOn do
                    pcall(function()
                        local hrp = GetHRP()
                        if hrp then AttackNearest(hrp, wzAuraRange) end
                    end)
                    task.wait(0.25)
                end
            end)
        end
    end
})
AddButtonSlider(WZTab, "Aura Range", 5, 100, 25, 5, " studs", function(v) wzAuraRange = v end)

WZTab:AddSection({ Name = "Dungeon" })
WZTab:AddButton({ Name = "Kill all Dungeon Mobs",
    Callback = function()
        task.spawn(function()
            local count = 0
            pcall(function()
                local hrp = GetHRP(); if not hrp then return end
                for _, h in ipairs(WS:GetDescendants()) do
                    if h:IsA("Humanoid") and h.Health > 0 and not Players:GetPlayerFromCharacter(h.Parent) then
                        local rp = h.Parent:FindFirstChild("HumanoidRootPart")
                        if rp and rp.Position.Y < 8000 then
                            AttackNearest(hrp, 999); count += 1; task.wait(0.2)
                        end
                    end
                end
            end)
            OrionLib:MakeNotification({ Name = "Dungeon", Content = count.." mobs attacked.", Image = ICON, Time = 3 })
        end)
    end
})
WZTab:AddButton({ Name = "TP to Dungeon/Boss",
    Callback = function()
        pcall(function()
            local hrp = GetHRP(); if not hrp then return end
            for _, obj in ipairs(WS:GetDescendants()) do
                if obj.Name:lower():find("dungeon") or obj.Name:lower():find("boss") then
                    local pos = (obj:IsA("BasePart") and obj.Position) or (obj:IsA("Model") and obj:GetPivot().Position)
                    if pos then SafeTP(CFrame.new(pos + Vector3.new(0,5,0)), true); break end
                end
            end
        end)
    end
})

WZTab:AddSection({ Name = "Loot" })
WZTab:AddButton({ Name = "Collect all Items",
    Callback = function()
        task.spawn(function()
            pcall(function()
                local hrp = GetHRP(); if not hrp then return end
                for _, obj in ipairs(WS:GetDescendants()) do
                    if (obj:IsA("BasePart") or obj:IsA("Model")) and
                       (obj.Name:lower():find("loot") or obj.Name:lower():find("drop") or
                        obj.Name:lower():find("item") or obj.Name:lower():find("gem")) then
                        local pos = obj:IsA("BasePart") and obj.Position or (obj:IsA("Model") and obj:GetPivot().Position)
                        if pos and (hrp.Position-pos).Magnitude < 200 then
                            SafeTP(CFrame.new(pos+Vector3.new(0,2,0)), true); task.wait(0.1)
                        end
                    end
                end
            end)
            OrionLib:MakeNotification({ Name = "Loot", Content = "Sweep done.", Image = ICON, Time = 2 })
        end)
    end
})

end -- World Zero

-- =============================================================================
-- SETTINGS TAB
-- =============================================================================
local SettingsTab = Window:MakeTab({ Name = "Settings", Icon = ICON, PremiumOnly = false })
SettingsTab:AddSection({ Name = "Keybinds" })
SettingsTab:AddBind({ Name = "UI Toggle", Default = Enum.KeyCode.RightControl, Hold = false,
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

SettingsTab:AddSection({ Name = "Anti-Cheat" })
SettingsTab:AddLabel("TP uses smooth lerp steps (anti-ban)")
SettingsTab:AddLabel("Kill Aura uses 3-method attack (ClickDet/Touch/VU)")
SettingsTab:AddLabel("Stats loop reapplies on every frame")

SettingsTab:AddSection({ Name = "Hub" })
SettingsTab:AddButton({ Name = "Unload Hub",
    Callback = function()
        ClearEsp(); StopFly(); StopHover()
        if noclipConn then noclipConn:Disconnect() end
        if ijConn     then ijConn:Disconnect() end
        if godConn    then godConn:Disconnect() end
        if fbConn     then fbConn:Disconnect() end
        if afkConn    then afkConn:Disconnect() end
        statWalkSpeed = 16; statJumpPower = 50; statGravity = 196
        WS.Gravity = 196
        OrionLib:Destroy()
    end
})

-- =============================================================================
-- CREDITS
-- =============================================================================
local CreditsTab = Window:MakeTab({ Name = "Credits", Icon = ICON, PremiumOnly = false })
CreditsTab:AddSection({ Name = "Baddie404 v5.0" })
CreditsTab:AddLabel("Dev: Baddie404")
CreditsTab:AddLabel("UI: Orion Library (jensonhirst fork)")
CreditsTab:AddParagraph("v5.0 Changes",
    "Sliders replaced with +/- buttons (Delta mobile fix). "..
    "Sea 1 Full Auto Quest (12 islands). Auto Spin (3-method). "..
    "Smooth anti-cheat TP. Custom drag. Hover with raycast. "..
    "AttackNearest: VU + ClickDetector + TouchInterest.")

-- =============================================================================
-- RESPAWN HANDLER
-- =============================================================================
LP.CharacterAdded:Connect(function(newChar)
    -- Inf Jump reconnect
    if InfJump then
        local h = newChar:WaitForChild("Humanoid")
        if ijConn then ijConn:Disconnect(); ijConn = nil end
        ijConn = h.Jumping:Connect(function(j)
            if j and InfJump then
                task.wait(0.05)
                pcall(function()
                    local hrp = newChar:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X, statJumpPower, hrp.Velocity.Z) end
                end)
            end
        end)
    end
    if FlyEnabled then task.wait(0.5); StartFly() end
    -- Hover: clear old BP and let the loop recreate it
    if HoverOn and hoverBP then pcall(function() hoverBP:Destroy() end); hoverBP = nil end
    -- Force-apply stat
    task.wait(0.3)
    pcall(function()
        local h = newChar:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = statWalkSpeed; h.UseJumpPower = true; h.JumpPower = statJumpPower end
        WS.Gravity = statGravity
    end)
end)

-- =============================================================================
-- CUSTOM DRAG (mobile-safe, fires after Orion init)
-- =============================================================================
task.spawn(function()
    task.wait(2.5)
    pcall(function()
        local orionGui = CoreGui:FindFirstChild("Orion")
        if not orionGui then return end

        -- Find the main window frame (largest Frame descendant)
        local mainFrame = nil
        local biggest = 0
        for _, v in ipairs(orionGui:GetDescendants()) do
            if v:IsA("Frame") then
                local area = v.AbsoluteSize.X * v.AbsoluteSize.Y
                if area > biggest then biggest = area; mainFrame = v end
            end
        end
        if not mainFrame then return end

        -- Find drag handle: smallest tall child near top
        local dragHandle = nil
        for _, v in ipairs(mainFrame:GetChildren()) do
            if v:IsA("Frame") or v:IsA("TextLabel") or v:IsA("ImageLabel") then
                if v.AbsoluteSize.Y < 50 then dragHandle = v; break end
            end
        end
        dragHandle = dragHandle or mainFrame

        local dragging = false
        local dragStart, startPos

        dragHandle.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
               or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = inp.Position; startPos = mainFrame.Position
            end
        end)
        UIS.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
               or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UIS.InputChanged:Connect(function(inp)
            if dragging then
                local d = inp.Position - dragStart
                mainFrame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
    end)
end)

-- =============================================================================
-- FINISH
-- =============================================================================
SetStatus("Done!"); SetProgress(100, 0.3); task.wait(0.5)

local ft = TweenService:Create(Bg, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
ft:Play()
ft.Completed:Connect(function() if LoadGui and LoadGui.Parent then LoadGui:Destroy() end end)

task.wait(0.4)
OrionLib:Init()
task.wait(0.8)

OrionLib:MakeNotification({
    Name = "Baddie404 v5.0",
    Content = Universal
        and ("Universal | PlaceId "..tostring(PlaceId))
        or  (DetectedGame.." | All features active"),
    Image = ICON, Time = 6
})
