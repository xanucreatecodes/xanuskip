if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local NetworkFolder = ReplicatedStorage:WaitForChild("ModuleLoader"):WaitForChild("Shared"):WaitForChild("Network"):WaitForChild("RemoteEvent")
local RemoteFunctionFolder = ReplicatedStorage:WaitForChild("ModuleLoader"):WaitForChild("Shared"):WaitForChild("Network"):WaitForChild("RemoteFunction")
local TowerAddEvent = NetworkFolder:WaitForChild("TowerAdd")
local TowerUpgradeEvent = NetworkFolder:WaitForChild("TowerUpgrade")
local TowerSellEvent = NetworkFolder:FindFirstChild("TowerSell") or NetworkFolder:WaitForChild("TowerSell", 2)
local WaveSkipEvent = NetworkFolder:WaitForChild("WaveSkip")

local ALTURA_REAL = 618.4

local POS_STARTER = {Vector3.new(438.0, ALTURA_REAL, 341.4)}
local POS_GRANJAS = {
    Vector3.new(443.0, ALTURA_REAL, 313.8),
    Vector3.new(462.0, ALTURA_REAL, 312.8),
    Vector3.new(462.6, ALTURA_REAL, 302.2),
    Vector3.new(440.9, ALTURA_REAL, 298.9)
}
local POS_REPARADOR = {Vector3.new(441.0, ALTURA_REAL, 330.0)} 
local POS_MEDIOS = {
    Vector3.new(443.6, ALTURA_REAL, 334.0),
    Vector3.new(443.6, ALTURA_REAL, 334.0),
    Vector3.new(443.6, ALTURA_REAL, 334.0),
    Vector3.new(443.6, ALTURA_REAL, 334.0),
    Vector3.new(443.6, ALTURA_REAL, 334.0),
    Vector3.new(443.6, ALTURA_REAL, 334.0)
}
local POS_TITANES = {
    Vector3.new(434.0, ALTURA_REAL, 333.0),
    Vector3.new(449.5, ALTURA_REAL, 333.0)
}

local ID_TITAN_CINEMA = "a94988c3-99cf-4207-82ca-c607ab1f208e"
local ID_GLITCH_CAM = "81a94448-bc55-42c7-967a-c1123ecdcfdd"
local ID_LARGE_SCIENT = "1c3cd513-b663-4253-9ea4-3f6279256bf2"
local ID_PUMPKIN = "24a79db5-8b5b-4d6d-b875-1fa8f01f572a"
local ID_REPARADOR = "60fee940-972d-452e-a709-a51a57945ad1" 

local contadorSkip = 1
local permitirSkip = true
_G.activarEscanerRejoin = false
_G.TorresColocadas = {Starter = {}, Granjas = {}, Reparador = {}, Medios = {}, Titanes = {}}

local function obtenerOlaActual()
    local n = 1
    pcall(function()
        local stats = PlayerGui:FindFirstChild("GameUI") and PlayerGui.GameUI:FindFirstChild("Stats") or PlayerGui:FindFirstChild("Stats", true)
        local waveLabel = stats and stats:FindFirstChild("Wave")
        if waveLabel and waveLabel.Text then
            local match = string.match(waveLabel.Text, "%d+")
            if match then n = tonumber(match) end
        end
    end)
    return n
end

TowerAddEvent.OnClientEvent:Connect(function(data)
    if data and data.Pos and data.Id and data.Index then
        for i, pos in ipairs(POS_STARTER) do
            if (data.Pos - pos).Magnitude < 4 then _G.TorresColocadas.Starter[i] = {Id = data.Id, Index = data.Index} end
        end
        for i, pos in ipairs(POS_GRANJAS) do
            if (data.Pos - pos).Magnitude < 4 then _G.TorresColocadas.Granjas[i] = {Id = data.Id, Index = data.Index} end
        end
        for i, pos in ipairs(POS_REPARADOR) do
            if (data.Pos - pos).Magnitude < 4 then _G.TorresColocadas.Reparador[i] = {Id = data.Id, Index = data.Index} end
        end
        for i, pos in ipairs(POS_MEDIOS) do
            if (data.Pos - pos).Magnitude < 4 then _G.TorresColocadas.Medios[i] = {Id = data.Id, Index = data.Index} end
        end
        for i, pos in ipairs(POS_TITANES) do
            if (data.Pos - pos).Magnitude < 4 then _G.TorresColocadas.Titanes[i] = {Id = data.Id, Index = data.Index} end
        end
    end
end)

local function miDinero()
    local stats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("Data")
    if stats then
        local cashObj = stats:FindFirstChild("Cash") or stats:FindFirstChild("Money")
        if cashObj then return cashObj.Value end
    end
    return 99999
end

_G.esperarDinero = function(cantidad)
    if miDinero() == 99999 then task.wait(0.5) return end
    while miDinero() < cantidad do task.wait(0.05) end
end

_G.colocarTorreDirecto = function(nombreInterno, unitId, posicion)
    local struct = {
        UnitId = unitId,
        CFrame = CFrame.new(posicion.X, posicion.Y, posicion.Z, 1, 0, 0, 0, 1, 0, 0, 0, 1),
        Name = nombreInterno,
        Pos = posicion
    }
    TowerAddEvent:FireServer(struct)
    task.wait(1.5)
end

_G.colocarTorreConFondos = function(nombreInterno, unitId, posicion, costoUnidad)
    _G.esperarDinero(costoUnidad)
    _G.colocarTorreDirecto(nombreInterno, unitId, posicion)
end

_G.mejorarTorreInvisibly = function(datosTorre, nivelDestino)
    if not datosTorre or not datosTorre.Id or not datosTorre.Index then return end
    TowerUpgradeEvent:FireServer({Id = datosTorre.Id, Index = datosTorre.Index, Level = nivelDestino})
    task.wait(1.0)
end

task.spawn(function()
    while true do
        if permitirSkip then
            if obtenerOlaActual() >= 49 then
                permitirSkip = false
            else
                pcall(function() WaveSkipEvent:FireServer(contadorSkip) contadorSkip = contadorSkip + 1 end)
            end
        end
        task.wait(1.2)
    end
end)

task.spawn(function()
    task.wait(1.5)
    pcall(function()
        local CS = RemoteFunctionFolder:WaitForChild("ChangeSpeed", 5) or RemoteFunctionFolder:FindFirstChild("ChangeSpeed")
        if CS then CS:InvokeServer(2) end
    end)
    task.wait(0.2)
    pcall(function()
        local GameUI = PlayerGui:WaitForChild("GameUI", 5)
        local AutoSkipBtn = GameUI and GameUI:FindFirstChild("Stats") and GameUI.Stats:FindFirstChild("AutoSkip")
        if AutoSkipBtn then
            local conns = AutoSkipBtn:GetConnections("MouseButton1Click")
            if conns and #conns > 0 then conns:Fire() else firesignal(AutoSkipBtn.MouseButton1Click) end
        end
    end)
    task.wait(0.2)
    pcall(function()
        local ModeVoteEvent = NetworkFolder:WaitForChild("ModeVote", 5)
        if ModeVoteEvent then ModeVoteEvent:FireServer("Nightmare") end
    end)
end)

task.spawn(function()
    task.wait(5.0)
    
    _G.colocarTorreConFondos("Pumpkin Farmer", ID_PUMPKIN, POS_GRANJAS[1], 200)
    
    _G.esperarDinero(300)
    task.wait(1.5)
    _G.colocarTorreConFondos("Large Scientist Cameraman", ID_LARGE_SCIENT, POS_STARTER[1], 300)
    task.wait(0.5)
    
    _G.colocarTorreConFondos("Pumpkin Farmer", ID_PUMPKIN, POS_GRANJAS[2], 200)
    _G.colocarTorreConFondos("Pumpkin Farmer", ID_PUMPKIN, POS_GRANJAS[3], 200)
    _G.colocarTorreConFondos("Pumpkin Farmer", ID_PUMPKIN, POS_GRANJAS[4], 200)
    
    local costosLarge = {750, 1200, 2000, 3000}
    for lvl = 2, 5 do
        _G.esperarDinero(costosLarge[lvl-1])
        _G.mejorarTorreInvisibly(_G.TorresColocadas.Starter[1], lvl)
    end
    
    local mejorasPumkin = {300, 600, 900, 1800}
    for lvl = 2, 5 do
        for i = 1, 4 do
            _G.esperarDinero(mejorasPumkin[lvl-1])
            _G.mejorarTorreInvisibly(_G.TorresColocadas.Granjas[i], lvl)
        end
    end
    
    local costosCinema = {2000, 3000, 5000, 9000, 19000}
    for t = 1, 2 do
        _G.colocarTorreConFondos("Titan Cinemaman", ID_TITAN_CINEMA, POS_TITANES[t], 2000)
        task.wait(0.5)
        for lvl = 2, 6 do
            _G.esperarDinero(costosCinema[lvl-1])
            _G.mejorarTorreInvisibly(_G.TorresColocadas.Titanes[t], lvl)
        end
    end
    
    task.wait(2.0)
    
    _G.colocarTorreConFondos("Camera Repair Drone", ID_REPARADOR, POS_REPARADOR[1], 400) 
    local costosDrone = {500, 1000, 2000, 4000} 
    for lvl = 2, 5 do
        _G.esperarDinero(costosDrone[lvl-1])
        _G.mejorarTorreInvisibly(_G.TorresColocadas.Reparador[1], lvl)
    end
    
    local costosGlitch = {1500, 3500, 8500}
    for m = 1, 6 do
        _G.colocarTorreConFondos("Glitch Cameraman", ID_GLITCH_CAM, POS_MEDIOS[m], 600)
        task.wait(0.5)
        for lvl = 2, 4 do
            _G.esperarDinero(costosGlitch[lvl-1])
            _G.mejorarTorreInvisibly(_G.TorresColocadas.Medios[m], lvl)
        end
    end
    
    task.wait(2)
    _G.activarEscanerRejoin = true
end)

task.spawn(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local partidaTerminadaReal = false
    while not partidaTerminadaReal do
        pcall(function()
            local LocalPlayer = game:GetService("Players").LocalPlayer
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            local GameUI = PlayerGui:FindFirstChild("GameUI")
            local FinalUI = GameUI and GameUI:FindFirstChild("FinalUI")
            if FinalUI and FinalUI.Visible == true then
                for _, obj in pairs(FinalUI:GetDescendants()) do
                    if obj.Name == "PlayAgain" and obj:IsA("GuiButton") and obj.AbsoluteSize.X > 0 then
                        task.wait(3.5)
                        local posX = obj.AbsolutePosition.X + (obj.AbsoluteSize.X / 2) + 25
                        local posY = obj.AbsolutePosition.Y + (obj.AbsoluteSize.Y / 2) + 55
                        VirtualInputManager:SendMouseButtonEvent(posX, posY, 0, true, game, 1)
                        task.wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(posX, posY, 0, false, game, 1)
                        partidaTerminadaReal = true
                        break
                    end
                end
            end
        end)
        if partidaTerminadaReal then break end
        task.wait(1.0)
    end
end)
