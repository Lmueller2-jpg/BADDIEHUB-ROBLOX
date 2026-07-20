-- =============================================================================
-- BADDIE404 MULTIHUB v3.1
-- Executors: Delta, Fluxus, Solara, Synapse X
-- 100% ASCII - no UTF-8 special chars
-- =============================================================================

-- Cleanup: remove old instances
for _, name in ipairs({"Orion", "Baddie404Hub", "Baddie404Loading"}) do
    local old = game:GetService("CoreGui"):FindFirstChild(name)
    if old then old:Destroy() end
end

-- Services
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local Workspace        = game:GetService("Workspace")
local Camera           = Workspace.CurrentCamera

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
Bg.BackgroundColor3 = Color3.fromRGB(12,12,18)
Bg.BorderSizePixel = 0

local Card = Instance.new("Frame", Bg)
Card.AnchorPoint = Vector2.new(0.5,0.5)
Card.Position = UDim2.fromScale(0.5,0.5)
Card.Size = UDim2.new(0,360,0,160)
Card.BackgroundColor3 = Color3.fromRGB(22,22,32)
Card.BorderSizePixel = 0
Instance.new("UICorner", Card).CornerRadius = UDim.new(0,10)
local cs = Instance.new("UIStroke", Card)
cs.Color = Color3.fromRGB(120,80,255)
cs.Thickness = 1.5

local TitleL = Instance.new("TextLabel", Card)
TitleL.Position = UDim2.new(0,18,0,18)
TitleL.Size = UDim2.new(1,-36,0,24)
TitleL.BackgroundTransparency = 1
TitleL.Text = "BADDIE404 MULTIHUB"
TitleL.TextColor3 = Color3.new(1,1,1)
TitleL.TextSize = 18
TitleL.Font = Enum.Font.GothamBold
TitleL.TextXAlignment = Enum.TextXAlignment.Left

local SubL = Instance.new("TextLabel", Card)
SubL.Position = UDim2.new(0,18,0,44)
SubL.Size = UDim2.new(1,-36,0,16)
SubL.BackgroundTransparency = 1
SubL.Text = "v3.1"
SubL.TextColor3 = Color3.fromRGB(120,100,200)
SubL.TextSize = 12
SubL.Font = Enum.Font.Gotham
SubL.TextXAlignment = Enum.TextXAlignment.Left

local StatusL = Instance.new("TextLabel", Card)
StatusL.Position = UDim2.new(0,18,0,80)
StatusL.Size = UDim2.new(1,-36,0,16)
StatusL.BackgroundTransparency = 1
StatusL.Text = "Loading..."
StatusL.TextColor3 = Color3.fromRGB(170,165,200)
StatusL.TextSize = 12
StatusL.Font = Enum.Font.Gotham
StatusL.TextXAlignment = Enum.TextXAlignment.Left

local Track = Instance.new("Frame", Card)
Track.Position = UDim2.new(0,18,0,108)
Track.Size = UDim2.new(1,-36,0,7)
Track.BackgroundColor3 = Color3.fromRGB(38,36,55)
Track.BorderSizePixel = 0
Instance.new("UICorner", Track).CornerRadius = UDim.new(1,0)

local Fill = Instance.new("Frame", Track)
Fill.Size = UDim2.new(0,0,1,0)
Fill.BackgroundColor3 = Color3.fromRGB(120,80,255)
Fill.BorderSizePixel = 0
Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0)

local PctL = Instance.new("TextLabel", Card)
PctL.Position = UDim2.new(0,18,0,122)
PctL.Size = UDim2.new(1,-36,0,14)
PctL.BackgroundTransparency = 1
PctL.Text = "0%"
PctL.TextColor3 = Color3.fromRGB(120,80,255)
PctL.TextSize = 11
PctL.Font = Enum.Font.GothamBold
PctL.TextXAlignment = Enum.TextXAlignment.Right

local function SetProgress(pct, dur)
    dur = dur or 0.35
    TweenService:Create(Fill, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(pct/100, 0, 1, 0)
    }):Play()
    PctL.Text = pct .. "%"
end

local function SetStatus(txt)
    StatusL.Text = txt
end

-- =============================================================================
-- ORION LOAD  (safeGet works on Delta, Fluxus, Synapse X, Solara)
-- =============================================================================

local function safeGet(url)
    if request then
        return request({ Url = url, Method = "GET" }).Body
    elseif http_request then
        return http_request({ Url = url, Method = "GET" }).Body
    elseif syn and syn.request then
        return syn.request({ Url = url, Method = "GET" }).Body
    else
        return game:HttpGet(url)
    end
end

SetStatus("Loading Orion...")
SetProgress(15, 0.3)
task.wait(0.3)

local OrionLib
local ok, err = pcall(function()
    OrionLib = loadstring(safeGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
end)

if not ok or type(OrionLib) ~= "table" then
    SetStatus("Primary failed, trying fallback...")
    SetProgress(30, 0.3)
    task.wait(0.5)
    local ok2 = pcall(function()
        OrionLib = loadstring(safeGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
    end)
    if not ok2 or type(OrionLib) ~= "table" then
        SetStatus("Load failed - check connection")
        SetProgress(100, 0.3)
        task.wait(3)
        LoadGui:Destroy()
        return
    end
end

SetStatus("Orion loaded")
SetProgress(50, 0.4)
task.wait(0.3)

-- =============================================================================
-- GAME DETECTION
-- =============================================================================

SetStatus("Detecting game...")
SetProgress(70, 0.4)
task.wait(0.3)

local Games = {
    ["Blox Fruits"] = {275391513, 4442272121, 7449423635, 11349191060, 2753915549},
    ["JJK Zero"]    = {7973578035, 8049346128, 7901843281},
    ["World Zero"]  = {4157004456, 4616238637, 4616888069},
}

local DetectedGame = nil
for name, ids in pairs(Games) do
    if table.find(ids, PlaceId) then
        DetectedGame = name
        break
    end
end

local Universal = (DetectedGame == nil)
if Universal then DetectedGame = "Unknown" end

SetStatus("Game: " .. DetectedGame)
SetProgress(88, 0.3)
task.wait(0.3)

-- =============================================================================
-- BUILD UI
-- =============================================================================

SetStatus("Building UI...")
SetProgress(96, 0.3)
task.wait(0.3)

local Window = OrionLib:MakeWindow({
    Name        = "Baddie404  |  " .. DetectedGame,
    HidePremium = false,
    SaveConfig  = true,
    ConfigFolder = "Baddie404",
    IntroText   = "Baddie404 Hub",
    IntroIcon   = ICON,
})

-- =============================================================================
-- HOME TAB
-- =============================================================================

local HomeTab = Window:MakeTab({ Name = "Home", Icon = ICON, PremiumOnly = false })

HomeTab:AddSection({ Name = "Info" })
HomeTab:AddLabel("Player: " .. LP.Name)
HomeTab:AddLabel("Game: " .. DetectedGame .. "  |  PlaceId: " .. tostring(PlaceId))

if Universal then
    HomeTab:AddParagraph("Game not detected",
        "Your game is not in the list. Only universal features are active. "
        .. "PlaceId " .. tostring(PlaceId))
end

HomeTab:AddSection({ Name = "Misc" })
HomeTab:AddButton({
    Name = "Test Notification",
    Callback = function()
        OrionLib:MakeNotification({ Name = "Test", Content = "Everything works.", Image = ICON, Time = 3 })
    end
})

-- =============================================================================
-- PLAYER TAB
-- =============================================================================

local PlayerTab = Window:MakeTab({ Name = "Player", Icon = ICON, PremiumOnly = false })

local function GetHum()
    local char = LP.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local function GetHRP()
    local char = LP.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

-- Movement
PlayerTab:AddSection({ Name = "Movement" })

PlayerTab:AddSlider({
    Name = "WalkSpeed", Min = 0, Max = 500, Default = 16,
    Color = Color3.fromRGB(90,160,255), Increment = 1, ValueName = "studs/s",
    Callback = function(v)
        pcall(function() GetHum().WalkSpeed = v end)
    end
})

PlayerTab:AddSlider({
    Name = "JumpPower", Min = 0, Max = 600, Default = 50,
    Color = Color3.fromRGB(90,255,160), Increment = 5, ValueName = "power",
    Callback = function(v)
        pcall(function()
            local h = GetHum()
            h.UseJumpPower = true
            h.JumpPower = v
        end)
    end
})

PlayerTab:AddSlider({
    Name = "Gravity", Min = 0, Max = 196, Default = 196,
    Color = Color3.fromRGB(255,180,90), Increment = 1, ValueName = "",
    Callback = function(v)
        Workspace.Gravity = v
    end
})

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
            ijConn = h.Jumping:Connect(function(jumping)
                if jumping and InfJump then
                    task.wait(0.05)
                    pcall(function()
                        local hrp = GetHRP()
                        if hrp then
                            hrp.Velocity = Vector3.new(hrp.Velocity.X, GetHum().JumpPower or 50, hrp.Velocity.Z)
                        end
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
        local h = GetHum()
        if h then h.PlatformStand = false end
    end)
end

local function StartFly()
    FlyEnabled = true
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then StopFly(); return end

    hum.PlatformStand = true

    flyBV = Instance.new("BodyVelocity", hrp)
    flyBV.Velocity = Vector3.zero
    flyBV.MaxForce = Vector3.new(1e9,1e9,1e9)

    flyBG = Instance.new("BodyGyro", hrp)
    flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9)
    flyBG.D = 100

    flyConn = RunService.Heartbeat:Connect(function()
        if not FlyEnabled then return end
        pcall(function()
            local dir = Vector3.zero
            local cf  = Camera.CFrame
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
            flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
            flyBG.CFrame = cf
        end)
    end)
end

PlayerTab:AddToggle({
    Name = "Fly", Default = false,
    Callback = function(on)
        if on then StartFly() else StopFly() end
    end
})

PlayerTab:AddSlider({
    Name = "Fly Speed", Min = 10, Max = 500, Default = 60,
    Color = Color3.fromRGB(255,120,200), Increment = 5, ValueName = "studs/s",
    Callback = function(v) flySpeed = v end
})

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
                    local char = LP.Character
                    if not char then return end
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") and p.CanCollide then
                            p.CanCollide = false
                        end
                    end
                end)
            end)
        else
            pcall(function()
                local char = LP.Character
                if not char then return end
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end)
        end
    end
})

-- Visuals
PlayerTab:AddSection({ Name = "Visuals" })

local fbOn = false
local fbConn = nil
local oldAmbient, oldFogEnd

PlayerTab:AddToggle({
    Name = "Fullbright", Default = false,
    Callback = function(on)
        fbOn = on
        local lighting = game:GetService("Lighting")
        if on then
            oldAmbient = lighting.Ambient
            oldFogEnd  = lighting.FogEnd
            lighting.Ambient = Color3.new(1,1,1)
            lighting.Brightness = 2
            lighting.FogEnd = 1e6
            if fbConn then fbConn:Disconnect() end
            fbConn = RunService.Heartbeat:Connect(function()
                lighting.Ambient = Color3.new(1,1,1)
                lighting.Brightness = 2
            end)
        else
            if fbConn then fbConn:Disconnect(); fbConn = nil end
            lighting.Ambient = oldAmbient or Color3.fromRGB(70,70,70)
            lighting.Brightness = 1
            lighting.FogEnd = oldFogEnd or 1e4
        end
    end
})

PlayerTab:AddSlider({
    Name = "FOV", Min = 30, Max = 120, Default = 70,
    Color = Color3.fromRGB(255,200,80), Increment = 1, ValueName = "deg",
    Callback = function(v) Camera.FieldOfView = v end
})

PlayerTab:AddSlider({
    Name = "Max Zoom", Min = 5, Max = 200, Default = 60,
    Color = Color3.fromRGB(160,200,255), Increment = 5, ValueName = "studs",
    Callback = function(v)
        pcall(function() LP.CameraMaxZoomDistance = v end)
    end
})

-- Character
PlayerTab:AddSection({ Name = "Character" })

local afkConn = nil
PlayerTab:AddToggle({
    Name = "Anti-AFK", Default = false,
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
                        vu:Button1Down(Vector2.new(0,0), Camera.CFrame)
                        task.wait(0.1)
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
    Name = "God Mode (HP Lock)", Default = false,
    Callback = function(on)
        if godConn then godConn:Disconnect(); godConn = nil end
        if on then
            godConn = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local h = GetHum()
                    if h then h.Health = h.MaxHealth end
                end)
            end)
        end
    end
})

PlayerTab:AddToggle({
    Name = "Invisible", Default = false,
    Callback = function(on)
        pcall(function()
            local char = LP.Character
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    p.LocalTransparencyModifier = on and 1 or 0
                end
                if p:IsA("Decal") then
                    p.Transparency = on and 1 or 0
                end
            end
        end)
    end
})

PlayerTab:AddButton({
    Name = "Respawn",
    Callback = function() pcall(function() LP:LoadCharacter() end) end
})

-- Teleport
PlayerTab:AddSection({ Name = "Teleport" })

PlayerTab:AddTextbox({
    Name = "Teleport to Player", Default = "", TextDisappear = false,
    Callback = function(input)
        local name = input:match("^%s*(.-)%s*$")
        if name == "" then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name:lower() == name:lower() or p.DisplayName:lower() == name:lower() then
                pcall(function()
                    local hrp = GetHRP()
                    local tHrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and tHrp then
                        hrp.CFrame = tHrp.CFrame * CFrame.new(3,0,3)
                        OrionLib:MakeNotification({ Name = "Teleport", Content = "To " .. p.Name, Image = ICON, Time = 2 })
                    end
                end)
                return
            end
        end
        OrionLib:MakeNotification({ Name = "Teleport", Content = '"' .. name .. '" not found.', Image = ICON, Time = 3 })
    end
})

-- =============================================================================
-- ESP TAB
-- =============================================================================

local EspTab = Window:MakeTab({ Name = "ESP", Icon = ICON, PremiumOnly = false })
EspTab:AddSection({ Name = "Visuals" })

local EspOn    = false
local EspColor = Color3.fromRGB(255,50,50)
local EspBoxes = {}
local espLoop  = nil

local function MakeBox(player)
    if player == LP then return end
    pcall(function()
        if EspBoxes[player] then
            EspBoxes[player].Root:Destroy()
            EspBoxes[player] = nil
        end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local bb = Instance.new("BillboardGui")
        bb.AlwaysOnTop = true
        bb.Size = UDim2.new(0,4,0,5)
        bb.SizeOffset = Vector2.new(3.5,4)
        bb.StudsOffset = Vector3.new(0,2.5,0)
        bb.Adornee = hrp
        bb.Parent = CoreGui

        local box = Instance.new("Frame", bb)
        box.Size = UDim2.fromScale(1,1)
        box.BackgroundTransparency = 1
        local stroke = Instance.new("UIStroke", box)
        stroke.Color = EspColor
        stroke.Thickness = 1.5

        local nameL = Instance.new("TextLabel", bb)
        nameL.AnchorPoint = Vector2.new(0.5,1)
        nameL.Position = UDim2.new(0.5,0,0,-3)
        nameL.Size = UDim2.new(1,50,0,16)
        nameL.BackgroundTransparency = 1
        nameL.Text = player.Name
        nameL.TextColor3 = Color3.new(1,1,1)
        nameL.TextSize = 12
        nameL.Font = Enum.Font.GothamBold
        nameL.TextStrokeTransparency = 0

        local distL = Instance.new("TextLabel", bb)
        distL.AnchorPoint = Vector2.new(0.5,0)
        distL.Position = UDim2.new(0.5,0,1,2)
        distL.Size = UDim2.new(1,50,0,14)
        distL.BackgroundTransparency = 1
        distL.Text = "0m"
        distL.TextColor3 = Color3.fromRGB(210,210,210)
        distL.TextSize = 11
        distL.Font = Enum.Font.Gotham
        distL.TextStrokeTransparency = 0

        local hpTrack = Instance.new("Frame", bb)
        hpTrack.AnchorPoint = Vector2.new(0,0.5)
        hpTrack.Position = UDim2.new(0,-10,0.5,0)
        hpTrack.Size = UDim2.new(0,4,1,0)
        hpTrack.BackgroundColor3 = Color3.fromRGB(50,50,50)
        hpTrack.BorderSizePixel = 0

        local hpFill = Instance.new("Frame", hpTrack)
        hpFill.AnchorPoint = Vector2.new(0,1)
        hpFill.Position = UDim2.fromScale(0,1)
        hpFill.Size = UDim2.fromScale(1,1)
        hpFill.BackgroundColor3 = Color3.fromRGB(80,255,80)
        hpFill.BorderSizePixel = 0

        EspBoxes[player] = { Root = bb, Stroke = stroke, NameL = nameL, DistL = distL, HpFill = hpFill }
    end)
end

local function RemoveBox(p)
    if EspBoxes[p] then
        pcall(function() EspBoxes[p].Root:Destroy() end)
        EspBoxes[p] = nil
    end
end

local function ClearEsp()
    for p in pairs(EspBoxes) do RemoveBox(p) end
    if espLoop then espLoop:Disconnect(); espLoop = nil end
end

EspTab:AddToggle({
    Name = "Box + Name + HP ESP", Default = false,
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
                            if tHrp then
                                data.DistL.Text = math.floor((myHrp.Position - tHrp.Position).Magnitude) .. "m"
                            end
                        end
                        local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
                        if h then
                            local pct = h.Health / math.max(h.MaxHealth, 1)
                            data.HpFill.Size = UDim2.fromScale(1, pct)
                            data.HpFill.BackgroundColor3 = Color3.fromRGB(
                                math.floor(255*(1-pct)), math.floor(255*pct), 0)
                        end
                    end)
                end
            end)
        else
            ClearEsp()
        end
    end
})

EspTab:AddDropdown({
    Name = "ESP Color", Default = "Red",
    Options = {"Red","Green","Blue","Yellow","White","Cyan"},
    Callback = function(v)
        local m = {
            ["Red"]=Color3.fromRGB(255,50,50), ["Green"]=Color3.fromRGB(50,255,80),
            ["Blue"]=Color3.fromRGB(60,130,255), ["Yellow"]=Color3.fromRGB(255,220,30),
            ["White"]=Color3.fromRGB(255,255,255), ["Cyan"]=Color3.fromRGB(0,230,230)
        }
        EspColor = m[v] or Color3.fromRGB(255,50,50)
    end
})

Players.PlayerAdded:Connect(function(p)
    if EspOn then
        p.CharacterAdded:Connect(function() task.wait(0.5); MakeBox(p) end)
        MakeBox(p)
    end
end)
Players.PlayerRemoving:Connect(function(p) RemoveBox(p) end)

-- =============================================================================
-- SERVER TAB
-- =============================================================================

local ServerTab = Window:MakeTab({ Name = "Server", Icon = ICON, PremiumOnly = false })
ServerTab:AddSection({ Name = "Server Tools" })

ServerTab:AddButton({
    Name = "Server Hop",
    Callback = function()
        local ok2, e = pcall(function()
            game:GetService("TeleportService"):Teleport(PlaceId, LP)
        end)
        if not ok2 then
            OrionLib:MakeNotification({ Name = "Server Hop", Content = "Error: " .. tostring(e), Image = ICON, Time = 3 })
        end
    end
})

ServerTab:AddLabel("Players on server: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers)
ServerTab:AddLabel("Job ID: " .. tostring(game.JobId):sub(1,18) .. "...")

-- =============================================================================
-- BLOX FRUITS TAB
-- =============================================================================

if DetectedGame == "Blox Fruits" then

    local BFTab = Window:MakeTab({ Name = "Blox Fruits", Icon = ICON, PremiumOnly = false })

    -- Auto Farm
    BFTab:AddSection({ Name = "Auto Farm" })

    local bfFarmOn = false
    local bfFarmConn = nil
    local bfFarmRange = 40

    BFTab:AddToggle({
        Name = "Auto Farm (nearest mob)", Default = false,
        Callback = function(on)
            bfFarmOn = on
            if bfFarmConn then bfFarmConn:Disconnect(); bfFarmConn = nil end
            if on then
                bfFarmConn = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        local hrp = GetHRP()
                        if not hrp then return end
                        local closest, closestDist = nil, bfFarmRange
                        for _, obj in ipairs(Workspace:GetDescendants()) do
                            if obj:IsA("Humanoid") and obj.Health > 0 then
                                local rootPart = obj.Parent and obj.Parent:FindFirstChild("HumanoidRootPart")
                                if rootPart and not Players:GetPlayerFromCharacter(obj.Parent) then
                                    local dist = (hrp.Position - rootPart.Position).Magnitude
                                    if dist < closestDist then
                                        closestDist = dist
                                        closest = rootPart
                                    end
                                end
                            end
                        end
                        if closest then
                            hrp.CFrame = closest.CFrame * CFrame.new(0,0,4)
                        end
                    end)
                end)
            end
        end
    })

    BFTab:AddSlider({
        Name = "Farm Range", Min = 10, Max = 300, Default = 40,
        Color = Color3.fromRGB(255,100,50), Increment = 5, ValueName = "studs",
        Callback = function(v) bfFarmRange = v end
    })

    -- Kill Aura (VirtualUser M1 click - no Health=0)
    BFTab:AddSection({ Name = "Combat" })

    local bfAuraOn = false
    local bfAuraRange = 20

    BFTab:AddToggle({
        Name = "Kill Aura", Default = false,
        Callback = function(on)
            bfAuraOn = on
            if on then
                task.spawn(function()
                    local vu = game:GetService("VirtualUser")
                    while bfAuraOn do
                        pcall(function()
                            local hrp = GetHRP()
                            if not hrp then return end
                            local nearest, nearestDist = nil, bfAuraRange
                            for _, obj in ipairs(Workspace:GetDescendants()) do
                                if obj:IsA("Humanoid") and obj.Health > 0 then
                                    local rp = obj.Parent and obj.Parent:FindFirstChild("HumanoidRootPart")
                                    if rp and not Players:GetPlayerFromCharacter(obj.Parent)
                                       and rp.Position.Y < 5000 then
                                        local dist = (hrp.Position - rp.Position).Magnitude
                                        if dist < nearestDist then
                                            nearestDist = dist
                                            nearest = rp
                                        end
                                    end
                                end
                            end
                            if nearest then
                                hrp.CFrame = nearest.CFrame * CFrame.new(0,0,3)
                                task.wait(0.05)
                                local sp = Camera:WorldToScreenPoint(nearest.Position)
                                vu:Button1Down(Vector2.new(sp.X, sp.Y), Camera.CFrame)
                                task.wait(0.08)
                                vu:Button1Up(Vector2.new(sp.X, sp.Y), Camera.CFrame)
                            end
                        end)
                        task.wait(0.15)
                    end
                end)
            end
        end
    })

    BFTab:AddSlider({
        Name = "Kill Aura Range", Min = 5, Max = 100, Default = 20,
        Color = Color3.fromRGB(255,50,50), Increment = 1, ValueName = "studs",
        Callback = function(v) bfAuraRange = v end
    })

    -- Fruit Sniper
    BFTab:AddSection({ Name = "Fruits" })

    BFTab:AddButton({
        Name = "Teleport to nearest Fruit",
        Callback = function()
            pcall(function()
                local hrp = GetHRP()
                if not hrp then return end
                local closest, closestDist = nil, math.huge
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj:FindFirstChild("Handle") and
                       (obj.Name:find("Fruit") or obj.Name:find("fruit") or obj.Name:find("Devil")) then
                        local pos = obj:GetPivot().Position
                        local dist = (hrp.Position - pos).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closest = pos
                        end
                    end
                end
                if closest then
                    hrp.CFrame = CFrame.new(closest + Vector3.new(0,3,0))
                    OrionLib:MakeNotification({ Name = "Fruit Sniper", Content = "Fruit found! " .. math.floor(closestDist) .. " studs", Image = ICON, Time = 3 })
                else
                    OrionLib:MakeNotification({ Name = "Fruit Sniper", Content = "No fruit nearby.", Image = ICON, Time = 3 })
                end
            end)
        end
    })

    -- Island Teleport
    BFTab:AddSection({ Name = "Teleport" })

    local bfIslands = {
        ["Spawn Island"]    = CFrame.new(977, 14, 1430),
        ["Marine Fortress"] = CFrame.new(-1640, 9, 512),
        ["Jungle"]          = CFrame.new(-150, 12, 1560),
        ["Pirate Village"]  = CFrame.new(-1410, 8, -400),
        ["Skylands"]        = CFrame.new(-5000, 600, -5000),
        ["Middle Town"]     = CFrame.new(580, 8, 940),
    }

    BFTab:AddDropdown({
        Name = "Select Island", Default = "Spawn Island",
        Options = (function()
            local list = {}
            for k in pairs(bfIslands) do table.insert(list, k) end
            table.sort(list)
            return list
        end)(),
        Callback = function(v)
            pcall(function()
                local hrp = GetHRP()
                if hrp and bfIslands[v] then
                    hrp.CFrame = bfIslands[v]
                    OrionLib:MakeNotification({ Name = "Teleport", Content = v, Image = ICON, Time = 2 })
                end
            end)
        end
    })

    -- Auto Quest
    BFTab:AddSection({ Name = "Quests" })

    local bfQuestOn = false
    BFTab:AddToggle({
        Name = "Auto Quest (click quest giver)", Default = false,
        Callback = function(on)
            bfQuestOn = on
            if on then
                task.spawn(function()
                    while bfQuestOn do
                        pcall(function()
                            for _, npc in ipairs(Workspace:GetDescendants()) do
                                if npc:IsA("Model") and (npc.Name:find("Quest") or npc.Name:find("quest")) then
                                    local root = npc:FindFirstChild("HumanoidRootPart")
                                    if root then
                                        local hrp = GetHRP()
                                        if hrp then
                                            hrp.CFrame = root.CFrame * CFrame.new(0,0,5)
                                        end
                                    end
                                end
                            end
                        end)
                        task.wait(1)
                    end
                end)
            end
        end
    })

end -- end Blox Fruits

-- =============================================================================
-- JJK ZERO TAB
-- =============================================================================

if DetectedGame == "JJK Zero" then

    local JJKTab = Window:MakeTab({ Name = "JJK Zero", Icon = ICON, PremiumOnly = false })

    JJKTab:AddSection({ Name = "Auto Farm" })

    local jjkFarmOn = false
    local jjkFarmRange = 30

    JJKTab:AddToggle({
        Name = "Auto Farm Mobs", Default = false,
        Callback = function(on)
            jjkFarmOn = on
            if on then
                task.spawn(function()
                    local vu = game:GetService("VirtualUser")
                    while jjkFarmOn do
                        pcall(function()
                            local hrp = GetHRP()
                            if not hrp then return end
                            local nearest, nearestDist = nil, jjkFarmRange
                            for _, hum in ipairs(Workspace:GetDescendants()) do
                                if hum:IsA("Humanoid") and hum.Health > 0
                                   and not Players:GetPlayerFromCharacter(hum.Parent) then
                                    local rp = hum.Parent:FindFirstChild("HumanoidRootPart")
                                    if rp and rp.Position.Y < 5000 then
                                        local dist = (hrp.Position - rp.Position).Magnitude
                                        if dist < nearestDist then
                                            nearestDist = dist
                                            nearest = rp
                                        end
                                    end
                                end
                            end
                            if nearest then
                                hrp.CFrame = nearest.CFrame * CFrame.new(0,0,3)
                                task.wait(0.05)
                                local sp = Camera:WorldToScreenPoint(nearest.Position)
                                vu:Button1Down(Vector2.new(sp.X, sp.Y), Camera.CFrame)
                                task.wait(0.08)
                                vu:Button1Up(Vector2.new(sp.X, sp.Y), Camera.CFrame)
                            end
                        end)
                        task.wait(0.15)
                    end
                end)
            end
        end
    })

    JJKTab:AddSlider({
        Name = "Farm Range", Min = 5, Max = 150, Default = 30,
        Color = Color3.fromRGB(100,50,255), Increment = 5, ValueName = "studs",
        Callback = function(v) jjkFarmRange = v end
    })

    JJKTab:AddSection({ Name = "Combat" })

    local jjkAutoSkillOn = false
    local jjkSkillConn = nil

    JJKTab:AddToggle({
        Name = "Auto Attack / Skill Spam", Default = false,
        Callback = function(on)
            jjkAutoSkillOn = on
            if jjkSkillConn then jjkSkillConn:Disconnect(); jjkSkillConn = nil end
            if on then
                jjkSkillConn = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        local vu = game:GetService("VirtualUser")
                        vu:Button1Down(Vector2.new(Mouse.X, Mouse.Y), Camera.CFrame)
                        task.wait(0.05)
                        vu:Button1Up(Vector2.new(Mouse.X, Mouse.Y), Camera.CFrame)
                    end)
                end)
            end
        end
    })

    JJKTab:AddToggle({
        Name = "Auto Dash (Z-key spam)", Default = false,
        Callback = function(on)
            if on then
                task.spawn(function()
                    while jjkAutoSkillOn or on do
                        pcall(function()
                            local vu = game:GetService("VirtualUser")
                            vu:KeyDown("z")
                            task.wait(0.05)
                            vu:KeyUp("z")
                        end)
                        task.wait(0.15)
                        if not on then break end
                    end
                end)
            end
        end
    })

    JJKTab:AddSection({ Name = "Stats" })

    JJKTab:AddToggle({
        Name = "Infinite Cursed Energy (Mana Lock)", Default = false,
        Callback = function(on)
            if on then
                task.spawn(function()
                    while on do
                        pcall(function()
                            local char = LP.Character
                            if char then
                                for _, v in ipairs(char:GetDescendants()) do
                                    if (v.Name:lower():find("mana") or v.Name:lower():find("energy")
                                        or v.Name:lower():find("cursed")) and v:IsA("NumberValue") then
                                        v.Value = v.Value + 9999
                                    end
                                end
                            end
                        end)
                        task.wait(0.1)
                        if not on then break end
                    end
                end)
            end
        end
    })

    JJKTab:AddSection({ Name = "Teleport" })

    JJKTab:AddButton({
        Name = "Teleport to nearest Mob",
        Callback = function()
            pcall(function()
                local hrp = GetHRP()
                if not hrp then return end
                local closest, closestPos = math.huge, nil
                for _, h in ipairs(Workspace:GetDescendants()) do
                    if h:IsA("Humanoid") and h.Health > 0 and not Players:GetPlayerFromCharacter(h.Parent) then
                        local rp = h.Parent:FindFirstChild("HumanoidRootPart")
                        if rp then
                            local d = (hrp.Position - rp.Position).Magnitude
                            if d < closest then closest = d; closestPos = rp.CFrame end
                        end
                    end
                end
                if closestPos then
                    hrp.CFrame = closestPos * CFrame.new(0,0,4)
                end
            end)
        end
    })

    JJKTab:AddButton({
        Name = "Teleport to random Player",
        Callback = function()
            pcall(function()
                local list = {}
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character then table.insert(list, p) end
                end
                if #list == 0 then return end
                local target = list[math.random(1, #list)]
                local hrp = GetHRP()
                local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
                if hrp and tHrp then
                    hrp.CFrame = tHrp.CFrame * CFrame.new(4,0,0)
                end
            end)
        end
    })

end -- end JJK Zero

-- =============================================================================
-- WORLD ZERO TAB
-- =============================================================================

if DetectedGame == "World Zero" then

    local WZTab = Window:MakeTab({ Name = "World Zero", Icon = ICON, PremiumOnly = false })

    WZTab:AddSection({ Name = "Auto Farm" })

    local wzFarmOn = false
    local wzAuraRange = 25

    WZTab:AddToggle({
        Name = "Auto Farm (Kill Aura)", Default = false,
        Callback = function(on)
            wzFarmOn = on
            if on then
                task.spawn(function()
                    local vu = game:GetService("VirtualUser")
                    while wzFarmOn do
                        pcall(function()
                            local hrp = GetHRP()
                            if not hrp then return end
                            local nearest, nearestDist = nil, wzAuraRange
                            for _, h in ipairs(Workspace:GetDescendants()) do
                                if h:IsA("Humanoid") and h.Health > 0
                                   and not Players:GetPlayerFromCharacter(h.Parent) then
                                    local rp = h.Parent:FindFirstChild("HumanoidRootPart")
                                    if rp and rp.Position.Y < 5000 then
                                        local dist = (hrp.Position - rp.Position).Magnitude
                                        if dist < nearestDist then
                                            nearestDist = dist
                                            nearest = rp
                                        end
                                    end
                                end
                            end
                            if nearest then
                                hrp.CFrame = nearest.CFrame * CFrame.new(0,0,3)
                                task.wait(0.05)
                                local sp = Camera:WorldToScreenPoint(nearest.Position)
                                vu:Button1Down(Vector2.new(sp.X, sp.Y), Camera.CFrame)
                                task.wait(0.08)
                                vu:Button1Up(Vector2.new(sp.X, sp.Y), Camera.CFrame)
                            end
                        end)
                        task.wait(0.15)
                    end
                end)
            end
        end
    })

    WZTab:AddSlider({
        Name = "Aura Range", Min = 5, Max = 100, Default = 25,
        Color = Color3.fromRGB(50,200,255), Increment = 1, ValueName = "studs",
        Callback = function(v) wzAuraRange = v end
    })

    WZTab:AddSection({ Name = "Dungeon" })

    WZTab:AddButton({
        Name = "Kill all Dungeon Mobs",
        Callback = function()
            task.spawn(function()
                local count = 0
                local vu = game:GetService("VirtualUser")
                pcall(function()
                    local hrp = GetHRP()
                    if not hrp then return end
                    for _, h in ipairs(Workspace:GetDescendants()) do
                        if h:IsA("Humanoid") and h.Health > 0
                           and not Players:GetPlayerFromCharacter(h.Parent) then
                            local rp = h.Parent:FindFirstChild("HumanoidRootPart")
                            if rp and rp.Position.Y < 5000 then
                                hrp.CFrame = rp.CFrame * CFrame.new(0,0,3)
                                task.wait(0.05)
                                local sp = Camera:WorldToScreenPoint(rp.Position)
                                vu:Button1Down(Vector2.new(sp.X, sp.Y), Camera.CFrame)
                                task.wait(0.08)
                                vu:Button1Up(Vector2.new(sp.X, sp.Y), Camera.CFrame)
                                task.wait(0.1)
                                count = count + 1
                            end
                        end
                    end
                end)
                OrionLib:MakeNotification({ Name = "Dungeon", Content = count .. " mobs attacked.", Image = ICON, Time = 3 })
            end)
        end
    })

    WZTab:AddButton({
        Name = "Teleport to Dungeon Center",
        Callback = function()
            pcall(function()
                local hrp = GetHRP()
                if hrp then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj.Name:lower():find("dungeon") or obj.Name:lower():find("boss") then
                            local pos = obj:IsA("BasePart") and obj.Position or
                                       (obj:IsA("Model") and obj:GetPivot().Position)
                            if pos then
                                hrp.CFrame = CFrame.new(pos + Vector3.new(0,5,0))
                                break
                            end
                        end
                    end
                end
            end)
        end
    })

    WZTab:AddSection({ Name = "Loot" })

    WZTab:AddButton({
        Name = "Collect all Items (Magnetize)",
        Callback = function()
            task.spawn(function()
                pcall(function()
                    local hrp = GetHRP()
                    if not hrp then return end
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if (obj:IsA("BasePart") or obj:IsA("Model")) and
                           (obj.Name:lower():find("loot") or obj.Name:lower():find("drop")
                            or obj.Name:lower():find("item") or obj.Name:lower():find("gem")) then
                            local pos = obj:IsA("BasePart") and obj.Position or
                                       (obj:IsA("Model") and obj:GetPivot().Position)
                            if pos and (hrp.Position - pos).Magnitude < 200 then
                                hrp.CFrame = CFrame.new(pos + Vector3.new(0,2,0))
                                task.wait(0.1)
                            end
                        end
                    end
                end)
                OrionLib:MakeNotification({ Name = "Loot", Content = "Loot sweep done.", Image = ICON, Time = 2 })
            end)
        end
    })

    WZTab:AddToggle({
        Name = "Auto Revive Teammates", Default = false,
        Callback = function(on)
            if on then
                task.spawn(function()
                    while on do
                        pcall(function()
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p ~= LP and p.Character then
                                    local h = p.Character:FindFirstChildOfClass("Humanoid")
                                    if h and h.Health <= 0 then
                                        local hrp = GetHRP()
                                        local tHrp = p.Character:FindFirstChild("HumanoidRootPart")
                                        if hrp and tHrp then
                                            hrp.CFrame = tHrp.CFrame * CFrame.new(0,0,3)
                                        end
                                    end
                                end
                            end
                        end)
                        task.wait(0.5)
                        if not on then break end
                    end
                end)
            end
        end
    })

end -- end World Zero

-- =============================================================================
-- SETTINGS TAB
-- =============================================================================

local SettingsTab = Window:MakeTab({ Name = "Settings", Icon = ICON, PremiumOnly = false })
SettingsTab:AddSection({ Name = "Keybinds" })

SettingsTab:AddBind({
    Name = "UI Toggle", Default = Enum.KeyCode.RightControl, Hold = false,
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

SettingsTab:AddSection({ Name = "Hub" })

SettingsTab:AddButton({
    Name = "Unload Hub",
    Callback = function()
        ClearEsp()
        StopFly()
        if noclipConn then noclipConn:Disconnect() end
        if ijConn then ijConn:Disconnect() end
        if godConn then godConn:Disconnect() end
        if fbConn then fbConn:Disconnect() end
        if afkConn then afkConn:Disconnect() end
        Workspace.Gravity = 196
        OrionLib:Destroy()
    end
})

-- =============================================================================
-- CREDITS TAB
-- =============================================================================

local CreditsTab = Window:MakeTab({ Name = "Credits", Icon = ICON, PremiumOnly = false })
CreditsTab:AddSection({ Name = "Dev" })
CreditsTab:AddLabel("Baddie404  -  v3.1")
CreditsTab:AddLabel("Orion Library (jensonhirst fork)")
CreditsTab:AddParagraph("Note", "Game-specific features only show in the correct game. Universal features work everywhere.")

-- =============================================================================
-- CHARACTER RESPAWN HANDLER
-- =============================================================================

LP.CharacterAdded:Connect(function(newChar)
    if InfJump then
        local h = newChar:WaitForChild("Humanoid")
        if ijConn then ijConn:Disconnect(); ijConn = nil end
        ijConn = h.Jumping:Connect(function(j)
            if j and InfJump then
                task.wait(0.05)
                pcall(function()
                    local hrp = newChar:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X, GetHum().JumpPower or 50, hrp.Velocity.Z) end
                end)
            end
        end)
    end
    if FlyEnabled then
        task.wait(0.5)
        StartFly()
    end
end)

-- =============================================================================
-- DONE
-- =============================================================================

SetStatus("Done.")
SetProgress(100, 0.3)
task.wait(0.5)

local ft = TweenService:Create(Bg, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    BackgroundTransparency = 1
})
ft:Play()
ft.Completed:Connect(function() if LoadGui and LoadGui.Parent then LoadGui:Destroy() end end)

task.wait(0.4)
OrionLib:Init()

task.wait(0.8)
OrionLib:MakeNotification({
    Name = "Loaded",
    Content = Universal
        and ("Universal Mode  -  PlaceId " .. tostring(PlaceId))
        or  (DetectedGame .. " detected  -  all features active"),
    Image = ICON, Time = 5
})
