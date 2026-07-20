-- =============================================================================
-- BADDIE404 MULTIHUB v3.0
-- Executor: Delta, Fluxus, Solara, Synapse X
-- =============================================================================

-- Cleanup: alte Instanzen weghauen
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
SubL.Text = "v3.0"
SubL.TextColor3 = Color3.fromRGB(120,100,200)
SubL.TextSize = 12
SubL.Font = Enum.Font.Gotham
SubL.TextXAlignment = Enum.TextXAlignment.Left

local StatusL = Instance.new("TextLabel", Card)
StatusL.Position = UDim2.new(0,18,0,80)
StatusL.Size = UDim2.new(1,-36,0,16)
StatusL.BackgroundTransparency = 1
StatusL.Text = "Starte..."
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
-- ORION LADEN
-- =============================================================================

-- safeGet: kompatibler HTTP-Wrapper für alle Executer (Delta, Fluxus, Synapse X, etc.)
-- Mobile Executer wie Delta blockieren game:HttpGet direkt, stellen aber
-- 'request' oder 'http_request' als globale Funktion bereit.
-- Wir probieren alle drei Methoden der Reihe nach.
local function safeGet(url)
    if request then
        -- Delta, Fluxus, Krnl (neuere Versionen)
        local res = request({ Url = url, Method = "GET" })
        return res.Body
    elseif http_request then
        -- Synapse X, ältere Executer
        local res = http_request({ Url = url, Method = "GET" })
        return res.Body
    elseif syn and syn.request then
        -- Synapse X Legacy
        local res = syn.request({ Url = url, Method = "GET" })
        return res.Body
    else
        -- Fallback: Standard Roblox HttpGet (PC-Executer ohne eigene HTTP-API)
        return game:HttpGet(url)
    end
end

SetStatus("Lade Orion...")
SetProgress(15, 0.3)
task.wait(0.3)

local OrionLib
local ok, err = pcall(function()
    OrionLib = loadstring(safeGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
end)

if not ok or type(OrionLib) ~= "table" then
    SetStatus("Fehler – versuche Fallback...")
    SetProgress(30, 0.3)
    task.wait(0.5)
    local ok2, err2 = pcall(function()
        OrionLib = loadstring(safeGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
    end)
    if not ok2 or type(OrionLib) ~= "table" then
        SetStatus("Laden fehlgeschlagen – check deine Verbindung")
        SetProgress(100, 0.3)
        task.wait(3)
        LoadGui:Destroy()
        return
    end
end

SetStatus("Orion geladen")
SetProgress(50, 0.4)
task.wait(0.3)

-- =============================================================================
-- SPIELERKENNUNG
-- =============================================================================

SetStatus("Erkenne Spiel...")
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
if Universal then DetectedGame = "Unbekannt" end

SetStatus("Spiel: " .. DetectedGame)
SetProgress(88, 0.3)
task.wait(0.3)

-- =============================================================================
-- UI AUFBAUEN
-- =============================================================================

SetStatus("UI wird erstellt...")
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
HomeTab:AddLabel("Spieler: " .. LP.Name)
HomeTab:AddLabel("Spiel: " .. DetectedGame .. "  |  PlaceId: " .. tostring(PlaceId))

if Universal then
    HomeTab:AddParagraph("Kein Spiel erkannt", 
        "Dein Spiel ist nicht in der Liste. Nur die Universal-Features laufen. "
        .. "PlaceId " .. tostring(PlaceId) .. " kannst du Baddie404 melden.")
end

HomeTab:AddSection({ Name = "Misc" })
HomeTab:AddButton({
    Name = "Notification testen",
    Callback = function()
        OrionLib:MakeNotification({ Name = "Test", Content = "Alles läuft.", Image = ICON, Time = 3 })
    end
})

-- =============================================================================
-- PLAYER TAB  (funktioniert überall)
-- =============================================================================

local PlayerTab = Window:MakeTab({ Name = "Player", Icon = ICON, PremiumOnly = false })

-- Hilfsfunktion: sicherer Zugriff auf Humanoid
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

-- ── Bewegung ──────────────────────────────────────
PlayerTab:AddSection({ Name = "Bewegung" })

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

-- ── Inf Jump ──────────────────────────────────────
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

-- ── Fly ───────────────────────────────────────────
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

-- ── Noclip ────────────────────────────────────────
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
            -- Collision wieder anschalten
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

-- ── Sicht & Umgebung ──────────────────────────────
PlayerTab:AddSection({ Name = "Sicht & Umgebung" })

-- Fullbright
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

-- FOV Slider
PlayerTab:AddSlider({
    Name = "FOV", Min = 30, Max = 120, Default = 70,
    Color = Color3.fromRGB(255,200,80), Increment = 1, ValueName = "°",
    Callback = function(v) Camera.FieldOfView = v end
})

-- Camera Zoom
PlayerTab:AddSlider({
    Name = "Max Zoom", Min = 5, Max = 200, Default = 60,
    Color = Color3.fromRGB(160,200,255), Increment = 5, ValueName = "studs",
    Callback = function(v)
        pcall(function() LP.CameraMaxZoomDistance = v end)
    end
})

-- ── Charakter ─────────────────────────────────────
PlayerTab:AddSection({ Name = "Charakter" })

-- Anti-AFK
local afkConn = nil
PlayerTab:AddToggle({
    Name = "Anti-AFK", Default = false,
    Callback = function(on)
        if afkConn then afkConn:Disconnect(); afkConn = nil end
        if on then
            local vs = LP:GetService and LP:GetService("VirtualUser")
            -- Fallback: sende fake input alle 60s
            afkConn = RunService.Heartbeat:Connect(function()
                -- Roblox Anti-Idle: VirtualUser simulieren
                pcall(function()
                    LP:Move(Vector3.new(0,0,0))
                end)
            end)
            -- Sauberere Methode: RemoteEvent-Ping alle 60s
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

-- God Mode (Humanoid Health auf max sperren)
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

-- Invisible (Character Parts transparent)
PlayerTab:AddToggle({
    Name = "Unsichtbar", Default = false,
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

-- Charakter respawnen
PlayerTab:AddButton({
    Name = "Respawnen",
    Callback = function() pcall(function() LP:LoadCharacter() end) end
})

-- Teleport zu Spieler
PlayerTab:AddSection({ Name = "Teleport" })

PlayerTab:AddTextbox({
    Name = "Zu Spieler teleportieren", Default = "", TextDisappear = false,
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
                        OrionLib:MakeNotification({ Name = "Teleport", Content = "Zu " .. p.Name, Image = ICON, Time = 2 })
                    end
                end)
                return
            end
        end
        OrionLib:MakeNotification({ Name = "Teleport", Content = '"' .. name .. '" nicht gefunden.', Image = ICON, Time = 3 })
    end
})

-- =============================================================================
-- ESP TAB
-- =============================================================================

local EspTab = Window:MakeTab({ Name = "ESP", Icon = ICON, PremiumOnly = false })
EspTab:AddSection({ Name = "Visuals" })

local EspOn      = false
local EspColor   = Color3.fromRGB(255,50,50)
local EspBoxes   = {}
local EspConns   = {}
local espLoop    = nil

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

        -- Health bar
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
    if EspConns[p] then EspConns[p]:Disconnect(); EspConns[p] = nil end
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
    Name = "ESP Farbe", Default = "Rot",
    Options = {"Rot","Grün","Blau","Gelb","Weiß","Cyan"},
    Callback = function(v)
        local m = {["Rot"]=Color3.fromRGB(255,50,50),["Grün"]=Color3.fromRGB(50,255,80),
            ["Blau"]=Color3.fromRGB(60,130,255),["Gelb"]=Color3.fromRGB(255,220,30),
            ["Weiß"]=Color3.fromRGB(255,255,255),["Cyan"]=Color3.fromRGB(0,230,230)}
        EspColor = m[v] or Color3.fromRGB(255,50,50)
    end
})

-- Spieler-Events für ESP
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
        local ok, e = pcall(function()
            game:GetService("TeleportService"):Teleport(PlaceId, LP)
        end)
        if not ok then
            OrionLib:MakeNotification({ Name = "Server Hop", Content = "Fehler: " .. tostring(e), Image = ICON, Time = 3 })
        end
    end
})

ServerTab:AddLabel("Spieler auf Server: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers)
ServerTab:AddLabel("Job ID: " .. tostring(game.JobId):sub(1,18) .. "...")

-- =============================================================================
-- BLOX FRUITS TAB  (nur wenn im Spiel)
-- =============================================================================

if DetectedGame == "Blox Fruits" then

    local BFTab = Window:MakeTab({ Name = "Blox Fruits", Icon = ICON, PremiumOnly = false })

    -- ── Auto Farm ────────────────────────────────────
    BFTab:AddSection({ Name = "Auto Farm" })

    local bfFarmOn = false
    local bfFarmConn = nil
    local bfFarmRange = 40

    BFTab:AddToggle({
        Name = "Auto Farm (nächster Mob)", Default = false,
        Callback = function(on)
            bfFarmOn = on
            if bfFarmConn then bfFarmConn:Disconnect(); bfFarmConn = nil end
            if on then
                bfFarmConn = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        local hrp = GetHRP()
                        if not hrp then return end
                        local closest, closestDist = nil, bfFarmRange

                        -- Suche alle Mobs (Humanoids die nicht LP gehören)
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
                            -- Teleport direkt zum Mob
                            hrp.CFrame = closest.CFrame * CFrame.new(0,0,4)
                        end
                    end)
                end)
            end
        end
    })

    BFTab:AddSlider({
        Name = "Farm Reichweite", Min = 10, Max = 300, Default = 40,
        Color = Color3.fromRGB(255,100,50), Increment = 5, ValueName = "studs",
        Callback = function(v) bfFarmRange = v end
    })

    -- ── Kill Aura ────────────────────────────────────
    BFTab:AddSection({ Name = "Combat" })

    local bfAuraOn = false
    local bfAuraConn = nil
    local bfAuraRange = 20

    BFTab:AddToggle({
        Name = "Kill Aura", Default = false,
        Callback = function(on)
            bfAuraOn = on
            if bfAuraConn then bfAuraConn:Disconnect(); bfAuraConn = nil end
            if on then
                bfAuraConn = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        local hrp = GetHRP()
                        if not hrp then return end
                        for _, obj in ipairs(Workspace:GetDescendants()) do
                            if obj:IsA("Humanoid") and obj.Health > 0 then
                                local rp = obj.Parent:FindFirstChild("HumanoidRootPart")
                                if rp and not Players:GetPlayerFromCharacter(obj.Parent) then
                                    if (hrp.Position - rp.Position).Magnitude <= bfAuraRange then
                                        obj.Health = 0
                                    end
                                end
                            end
                        end
                    end)
                end)
            end
        end
    })

    BFTab:AddSlider({
        Name = "Kill Aura Reichweite", Min = 5, Max = 100, Default = 20,
        Color = Color3.fromRGB(255,50,50), Increment = 1, ValueName = "studs",
        Callback = function(v) bfAuraRange = v end
    })

    -- ── Fruit Sniper ─────────────────────────────────
    BFTab:AddSection({ Name = "Früchte" })

    BFTab:AddButton({
        Name = "Zu nächster Frucht teleportieren",
        Callback = function()
            pcall(function()
                local hrp = GetHRP()
                if not hrp then return end
                local closest, closestDist = nil, math.huge

                -- Blox Fruits speichert Früchte als Models mit bestimmten Namen
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
                    OrionLib:MakeNotification({ Name = "Fruit Sniper", Content = "Frucht gefunden! " .. math.floor(closestDist) .. " studs", Image = ICON, Time = 3 })
                else
                    OrionLib:MakeNotification({ Name = "Fruit Sniper", Content = "Keine Frucht in der Nähe.", Image = ICON, Time = 3 })
                end
            end)
        end
    })

    -- ── Teleport zu Insel ────────────────────────────
    BFTab:AddSection({ Name = "Teleport" })

    -- Bekannte Blox Fruits Inseln (ungefähre Koordinaten)
    local bfIslands = {
        ["Spawn Island"]        = CFrame.new(977, 14, 1430),
        ["Marine Fortress"]     = CFrame.new(-1640, 9, 512),
        ["Jungle"]              = CFrame.new(-150, 12, 1560),
        ["Pirate Village"]      = CFrame.new(-1410, 8, -400),
        ["Skylands (Sea 1)"]    = CFrame.new(-5000, 600, -5000),
        ["Middle Town"]         = CFrame.new(580, 8, 940),
    }

    BFTab:AddDropdown({
        Name = "Insel auswählen", Default = "Spawn Island",
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

    -- ── Auto Quest ───────────────────────────────────
    BFTab:AddSection({ Name = "Quests" })

    local bfQuestOn = false
    BFTab:AddToggle({
        Name = "Auto Quest (Questgeber anklicken)", Default = false,
        Callback = function(on)
            bfQuestOn = on
            if on then
                task.spawn(function()
                    while bfQuestOn do
                        pcall(function()
                            -- Suche Quest-NPCs
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

end -- Ende Blox Fruits

-- =============================================================================
-- JJK ZERO TAB  (nur wenn im Spiel)
-- =============================================================================

if DetectedGame == "JJK Zero" then

    local JJKTab = Window:MakeTab({ Name = "JJK Zero", Icon = ICON, PremiumOnly = false })

    -- ── Auto Farm ────────────────────────────────────
    JJKTab:AddSection({ Name = "Auto Farm" })

    local jjkFarmOn = false
    local jjkFarmConn = nil
    local jjkFarmRange = 30

    JJKTab:AddToggle({
        Name = "Auto Farm Mobs", Default = false,
        Callback = function(on)
            jjkFarmOn = on
            if jjkFarmConn then jjkFarmConn:Disconnect(); jjkFarmConn = nil end
            if on then
                jjkFarmConn = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        local hrp = GetHRP()
                        if not hrp then return end
                        for _, hum in ipairs(Workspace:GetDescendants()) do
                            if hum:IsA("Humanoid") and hum.Health > 0 and
                               not Players:GetPlayerFromCharacter(hum.Parent) then
                                local rp = hum.Parent:FindFirstChild("HumanoidRootPart")
                                if rp and (hrp.Position - rp.Position).Magnitude < jjkFarmRange then
                                    hum.Health = 0
                                end
                            end
                        end
                    end)
                end)
            end
        end
    })

    JJKTab:AddSlider({
        Name = "Farm Reichweite", Min = 5, Max = 150, Default = 30,
        Color = Color3.fromRGB(100,50,255), Increment = 5, ValueName = "studs",
        Callback = function(v) jjkFarmRange = v end
    })

    -- ── Combat ───────────────────────────────────────
    JJKTab:AddSection({ Name = "Combat" })

    -- Auto Skills (feuert Mouse1Click im Takt)
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
                        -- Simuliere Mausklick und Skill-Tasten
                        local vu = game:GetService("VirtualUser")
                        vu:Button1Down(Vector2.new(Mouse.X, Mouse.Y), Camera.CFrame)
                        task.wait(0.05)
                        vu:Button1Up(Vector2.new(Mouse.X, Mouse.Y), Camera.CFrame)
                    end)
                end)
            end
        end
    })

    -- Dash Spam (Space + beliebige Richtung)
    JJKTab:AddToggle({
        Name = "Auto Dash (Z-Taste spam)", Default = false,
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

    -- ── Cursed Energy Lock ───────────────────────────
    JJKTab:AddSection({ Name = "Stats" })

    JJKTab:AddToggle({
        Name = "Infinite Cursed Energy (Mana Lock)", Default = false,
        Callback = function(on)
            if on then
                task.spawn(function()
                    while on do
                        pcall(function()
                            -- Suche Mana/Energy Wert im Character
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

    -- ── Teleport ─────────────────────────────────────
    JJKTab:AddSection({ Name = "Teleport" })

    JJKTab:AddButton({
        Name = "Zu nächstem Mob teleportieren",
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
        Name = "Zu zufälligem Spieler",
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

end -- Ende JJK Zero

-- =============================================================================
-- WORLD ZERO TAB  (nur wenn im Spiel)
-- =============================================================================

if DetectedGame == "World Zero" then

    local WZTab = Window:MakeTab({ Name = "World Zero", Icon = ICON, PremiumOnly = false })

    -- ── Auto Farm ────────────────────────────────────
    WZTab:AddSection({ Name = "Auto Farm" })

    local wzFarmOn = false
    local wzFarmConn = nil
    local wzAuraRange = 25

    WZTab:AddToggle({
        Name = "Auto Farm (Kill Aura)", Default = false,
        Callback = function(on)
            wzFarmOn = on
            if wzFarmConn then wzFarmConn:Disconnect(); wzFarmConn = nil end
            if on then
                wzFarmConn = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        local hrp = GetHRP()
                        if not hrp then return end
                        for _, h in ipairs(Workspace:GetDescendants()) do
                            if h:IsA("Humanoid") and h.Health > 0 and
                               not Players:GetPlayerFromCharacter(h.Parent) then
                                local rp = h.Parent:FindFirstChild("HumanoidRootPart")
                                if rp and (hrp.Position - rp.Position).Magnitude <= wzAuraRange then
                                    h.Health = 0
                                end
                            end
                        end
                    end)
                end)
            end
        end
    })

    WZTab:AddSlider({
        Name = "Aura Reichweite", Min = 5, Max = 100, Default = 25,
        Color = Color3.fromRGB(50,200,255), Increment = 1, ValueName = "studs",
        Callback = function(v) wzAuraRange = v end
    })

    -- ── Dungeon ───────────────────────────────────────
    WZTab:AddSection({ Name = "Dungeon" })

    WZTab:AddButton({
        Name = "Dungeon Mobs killen (alle in Workspace)",
        Callback = function()
            local count = 0
            pcall(function()
                for _, h in ipairs(Workspace:GetDescendants()) do
                    if h:IsA("Humanoid") and h.Health > 0 and not Players:GetPlayerFromCharacter(h.Parent) then
                        h.Health = 0
                        count = count + 1
                    end
                end
            end)
            OrionLib:MakeNotification({ Name = "Dungeon", Content = count .. " Mobs gekillt.", Image = ICON, Time = 3 })
        end
    })

    WZTab:AddButton({
        Name = "Zur Dungeon-Mitte",
        Callback = function()
            pcall(function()
                local hrp = GetHRP()
                if hrp then
                    -- World Zero Dungeons haben oft ein zentrales Teil
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

    -- ── Auto Quest ───────────────────────────────────
    WZTab:AddSection({ Name = "Quests & Loot" })

    WZTab:AddButton({
        Name = "Alle Items aufsammeln (Magnetize)",
        Callback = function()
            task.spawn(function()
                pcall(function()
                    local hrp = GetHRP()
                    if not hrp then return end
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        -- Loot-Items in World Zero sind meist kleine Parts oder Models
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
                OrionLib:MakeNotification({ Name = "Loot", Content = "Loot-Sweep fertig.", Image = ICON, Time = 2 })
            end)
        end
    })

    -- Party-Skip (falls vorhanden)
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

end -- Ende World Zero

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
    Name = "Hub entladen",
    Callback = function()
        -- Alles sauber aufräumen
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
CreditsTab:AddLabel("Baddie404  –  v3.0")
CreditsTab:AddLabel("Orion Library (jensonhirst fork)")
CreditsTab:AddParagraph("Hinweis", "Alle game-spezifischen Features laufen nur im jeweiligen Spiel. Universal-Features gehen überall.")

-- =============================================================================
-- CHARAKTER RESPAWN HANDLER
-- =============================================================================

LP.CharacterAdded:Connect(function(newChar)
    -- Inf Jump nach Respawn neu verbinden
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
    -- Fly nach Respawn neu starten
    if FlyEnabled then
        task.wait(0.5)
        StartFly()
    end
end)

-- =============================================================================
-- FERTIG
-- =============================================================================

SetStatus("Fertig.")
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
    Name = "Geladen",
    Content = Universal
        and ("Universal Modus  ·  PlaceId " .. tostring(PlaceId))
        or  (DetectedGame .. " erkannt  ·  alle Features aktiv"),
    Image = ICON, Time = 5
})
