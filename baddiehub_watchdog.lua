-- =============================================================================
-- BADDIE404 WATCHDOG & DEBUGGING WRAPPER SYSTEM (v1.0)
-- Senior Roblox Software Engineer & Advanced Reverse-Engineering Edition
-- Designed for: Blox Fruits, JJK Zero, World Zero, and Universal Exploits
-- Stabilitäts-Garantie: Fängt alle Fehler ab, verhindert Abstürze und loggt Traces.
-- =============================================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LogService        = game:GetService("LogService")
local Players           = game:GetService("Players")
local LP                = Players.LocalPlayer

local Watchdog = {
    _VERSION = "1.0.0",
    _AUTHOR = "Baddie404 Dev Team",
    DebugMode = true,
    AlertColor = "🔴 [WATCHDOG ALERT]",
    WarningColor = "⚠️ [WATCHDOG WARNING]",
    InfoColor = "ℹ️ [WATCHDOG INFO]"
}

-- Helper-Funktion für konsolenlesbare Logs
local function log(prefix, msg)
    if Watchdog.DebugMode then
        print(string.format("%s [%s] %s", prefix, os.date("%H:%M:%S"), tostring(msg)))
    end
end

-- =============================================================================
-- 1. GLOBALER FEHLER-SCHUTZ (pcall & xpcall Wrapper mit Stack-Trace)
-- =============================================================================

-- Handler für xpcall, um den genauen Stack-Trace bei Fehlern abzufangen
local function errorHandler(err)
    local stackTrace = debug.traceback()
    local detailedError = string.format(
        "\n==================================================\n" ..
        "%s CRITICAL RUNTIME EXCEPTION DETECTED!\n" ..
        "Error: %s\n" ..
        "--------------------------------------------------\n" ..
        "STACK TRACE:\n%s\n" ..
        "==================================================",
        Watchdog.AlertColor,
        tostring(err),
        stackTrace
    )
    warn(detailedError)
    return err
end

--- Führt eine Funktion in einer geschützten Umgebung (xpcall) aus.
-- Verhindert jegliche Abstürze des Haupt-Threads und loggt genaue Dateipfade und Zeilennummern.
-- @param func Die auszuführende Funktion
-- @param ... Argumente, die an die Funktion übergeben werden sollen
-- @return success (boolean), und entweder die Rückgabewerte der Funktion oder die Fehlermeldung
function Watchdog.SafeExecute(func, ...)
    assert(type(func) == "function", "SafeExecute erwartet eine ausführbare Funktion als ersten Parameter!")
    
    local args = {...}
    local results = {xpcall(function()
        return func(unpack(args))
    end, errorHandler)}
    
    local success = results[1]
    if success then
        -- Entferne das success-Flag und gebe die echten Rückgabewerte zurück
        table.remove(results, 1)
        return true, unpack(results)
    else
        return false, results[2]
    end
end

-- =============================================================================
-- 2. UNIVERSALER NIL-CHECKER (Laufzeit-Objektüberprüfung)
-- =============================================================================

--- Prüft sicher, ob ein Kind-Objekt in einem Parent existiert, bevor darauf zugegriffen wird.
-- Verhindert den berüchtigten "Attempt to index nil with ..." Fehler.
-- @param parent Das Eltern-Instanz-Objekt (z.B. Character, Workspace, etc.)
-- @param childName Der Name des gesuchten Objekts als String
-- @param timeout (Optional) Maximale Wartezeit in Sekunden (Default: 0 für direkten Check)
-- @return Das Objekt falls gefunden, ansonsten nil (ohne Absturz!)
function Watchdog.SafeGet(parent, childName, timeout)
    if not parent then
        log(Watchdog.WarningColor, string.format("SafeGet fehlgeschlagen: Eltern-Instanz (Parent) existiert nicht für '%s'!", tostring(childName)))
        return nil
    end
    
    timeout = timeout or 0
    local foundChild = nil
    
    if timeout > 0 then
        -- Nutze WaitForChild für asynchrone Instanzen (z.B. Humanoid beim Spawn)
        local success, res = pcall(function()
            return parent:WaitForChild(childName, timeout)
        end)
        if success then foundChild = res end
    else
        -- Schneller synchroner Check
        local success, res = pcall(function()
            return parent:FindFirstChild(childName)
        end)
        if success then foundChild = res end
    end
    
    if not foundChild then
        warn(string.format("%s MISSING OBJECT: Das Objekt '%s' konnte in '%s' nicht gefunden werden!", 
            Watchdog.WarningColor, 
            tostring(childName), 
            tostring(parent.Name or parent)
        ))
        return nil
    end
    
    return foundChild
end

--- Prüft sicher, ob ein Humanoid existiert und am Leben ist.
-- Perfekt für Auto-Farms, um "Humanoid is not a valid member of Model" Fehler zu eliminieren.
-- @param model Das Charakter-Model des Mobs oder Spielers
-- @return boolean (ist am Leben und valide)
function Watchdog.IsAlive(model)
    if not model or type(model) ~= "userdata" then return false end
    
    local hum = model:FindFirstChildOfClass("Humanoid") or model:FindFirstChild("Humanoid")
    if hum and hum:IsA("Humanoid") then
        return hum.Health > 0
    end
    
    return false
end

-- =============================================================================
-- 3. REMOTE-EVENT-WÄCHTER (Sicherer Netzwerkverkehr für Exploits)
-- =============================================================================

-- Caching-System für Remotes, um ReplicatedStorage nicht bei jedem Aufruf rekursiv zu scannen (Performance!)
local remoteCache = {}

--- Sucht ein RemoteEvent oder RemoteFunction rekursiv in ReplicatedStorage und cacht das Ergebnis.
-- @param name Der Name oder Teilname des Remotes
-- @return Das Remote-Objekt oder nil
local function findRemote(name)
    if remoteCache[name] then
        return remoteCache[name]
    end
    
    -- Rekursive Suche im ReplicatedStorage (unabhängig von der Verzeichnisstruktur des Spiels)
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and obj.Name == name then
            remoteCache[name] = obj
            return obj
        end
    end
    
    return nil
end

--- Sendet Daten sicher an ein RemoteEvent, ohne dass das Skript bei fehlenden Remotes abstürzt.
-- @param remoteName Der Name des RemoteEvents
-- @param ... Die Parameter für FireServer
-- @return boolean (ob das Event erfolgreich gefeuert wurde)
function Watchdog.SafeFireRemote(remoteName, ...)
    local remote = findRemote(remoteName)
    
    if remote and remote:IsA("RemoteEvent") then
        local args = {...}
        local success, err = pcall(function()
            remote:FireServer(unpack(args))
        end)
        
        if success then
            return true
        else
            log(Watchdog.WarningColor, string.format("Fehler beim Feuern von Remote '%s': %s", remoteName, tostring(err)))
            return false
        end
    else
        log(Watchdog.WarningColor, string.format("REMOTE WÄCHTER: RemoteEvent '%s' existiert in diesem Spiel nicht! Aufruf ignoriert.", tostring(remoteName)))
        return false
    end
end

--- Ruft Daten sicher von einer RemoteFunction ab, ohne abzustürzen.
-- @param remoteName Der Name der RemoteFunction
-- @param timeout (Optional) Maximaler Timeout für die Antwort (verhindert unendliches Hängen)
-- @param ... Die Parameter für InvokeServer
-- @return success (boolean), gefolgt von den Rückgabewerten des Servers
function Watchdog.SafeInvokeRemote(remoteName, timeout, ...)
    local remote = findRemote(remoteName)
    timeout = timeout or 5
    
    if remote and remote:IsA("RemoteFunction") then
        local args = {...}
        local success, result
        
        -- Da InvokeServer den Thread blockieren kann, packen wir es in einen Timeout-geschützten pcall
        local finished = false
        task.spawn(function()
            success, result = pcall(function()
                return remote:InvokeServer(unpack(args))
            end)
            finished = true
        end)
        
        local start = os.clock()
        while not finished do
            if os.clock() - start > timeout then
                log(Watchdog.WarningColor, string.format("REMOTE TIMEOUT: RemoteFunction '%s' hat nicht rechtzeitig geantwortet!", remoteName))
                return false, "Timeout"
            end
            task.wait(0.05)
        end
        
        if success then
            return true, result
        else
            log(Watchdog.WarningColor, string.format("Fehler beim Invoken von Remote '%s': %s", remoteName, tostring(result)))
            return false, result
        end
    else
        log(Watchdog.WarningColor, string.format("REMOTE WÄCHTER: RemoteFunction '%s' existiert in diesem Spiel nicht! Aufruf ignoriert.", tostring(remoteName)))
        return false, "Missing RemoteFunction"
    end
end

-- =============================================================================
-- AUTOMATISCHER WATCHDOG SENTRY MONITOR (Hintergrund-Überwachung)
-- =============================================================================
task.spawn(function()
    log(Watchdog.InfoColor, "Watchdog Sentry System v" .. Watchdog._VERSION .. " erfolgreich gestartet!")
    
    -- Überwache unhandled Errors in der Core-Konsole
    local success, conn = pcall(function()
        return LogService.MessageOut:Connect(function(message, messageType)
            if messageType == Enum.MessageType.MessageError then
                -- Falls ein Fehler im Roblox-Skriptkontext auftaucht, analysieren wir ihn
                if message:find("Baddie") or message:find("loadstring") or message:find("HttpGet") then
                    log(Watchdog.AlertColor, "Externer Skript-Fehler abgefangen: " .. message)
                end
            end
        end)
    end)
    
    if success and conn then
        table.insert(BaddieHub.Connections, conn)
    end
end)

return Watchdog
