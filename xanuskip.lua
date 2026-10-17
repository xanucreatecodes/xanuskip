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

local ALTURA_REAL = -47.456172943115234

local POS_TV_WOMAN = {
    Vector3.new(-44.3, ALTURA_REAL, 13.8),
    Vector3.new(-47.9, ALTURA_REAL, -1.6)
}
local POS_GRANJAS = {
    Vector3.new(-54.0, ALTURA_REAL, 28.8),
    Vector3.new(-58.0, ALTURA_REAL, 23.8),
    Vector3.new(-62.64520263671875, ALTURA_REAL, 34.223361968994141),
    Vector3.new(-60.9, ALTURA_REAL, 42.9)
}
local POS_TITANES = {
    Vector3.new(-40.6, ALTURA_REAL, -1.0),
    Vector3.new(-50.3, ALTURA_REAL, 2.9),
    Vector3.new(-49.0, ALTURA_REAL, -6.2),
    Vector3.new(-35.4, ALTURA_REAL, -1.6),
    Vector3.new(-48.6, ALTURA_REAL, 9.7),
    Vector3.new(-47.8, ALTURA_REAL, -13.8)
}

local ID_CIENTIFICO = "a6834074-9392-47d5-9463-c642a5bcaac2"
local ID_TV_WOMAN = "aa5acbd8-6201-44d1-a8cb-567fc82724d5"
local ID_TITAN = "8499146f-b00a-4638-80c0-b69575471b48"

local contadorSkip = 1
_G.activarEscanerRejoin = false
_G.TorresColocadas = { Granjas = {}, Titanes = {}, TvWoman = {} }

TowerAddEvent.OnClientEvent:Connect(function(data)
    if data and data.Pos and data.Id and data.Index then
        for i, pos in ipairs(POS_GRANJAS) do
            if (data.Pos - pos).Magnitude < 4 then _G.TorresColocadas.Granjas[i] = { Id = data.Id, Index = data.Index } end
        end
        for i, pos in ipairs(POS_TV_WOMAN) do
            if (data.Pos - pos).Magnitude < 4 then _G.TorresColocadas.TvWoman[i] = { Id = data.Id, Index = data.Index } end
        end
        for i, pos in ipairs(POS_TITANES) do
            if (data.Pos - pos).Magnitude < 4 then _G.TorresColocadas.Titanes[i] = { Id = data.Id, Index = data.Index } end
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
    task.wait(1.5) -- TIEMPO AUMENTADO: Colchón de resguardo para la red en colocación
end

_G.colocarTorreConFondos = function(nombreInterno, unitId, posicion, costoUnidad)
    _G.esperarDinero(costoUnidad) 
    _G.colocarTorreDirecto(nombreInterno, unitId, posicion)
end

_G.mejorarTorreInvisibly = function(datosTorre, nivelDestino)
    if not datosTorre or not datosTorre.Id or not datosTorre.Index then return end
    TowerUpgradeEvent:FireServer({ Id = datosTorre.Id, Index = datosTorre.Index, Level = nivelDestino })
    task.wait(1.0) -- TIEMPO AUMENTADO: Espera de 1 segundo entre mejoras para limpiar el lag
end

task.spawn(function()
    while true do
        pcall(function() WaveSkipEvent:FireServer(contadorSkip) contadorSkip = contadorSkip + 1 end)
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
        if ModeVoteEvent then ModeVoteEvent:FireServer("Insane") end
    end)
end)

task.spawn(function()
    task.wait(5.0)

    _G.colocarTorreDirecto("Scientist Cameraman", ID_CIENTIFICO, POS_GRANJAS[1])
    _G.colocarTorreDirecto("Scientist Cameraman", ID_CIENTIFICO, POS_GRANJAS[2])
    
    _G.colocarTorreConFondos("Scientist Cameraman", ID_CIENTIFICO, POS_GRANJAS[3], 100)
    
    _G.colocarTorreConFondos("Scientist Cameraman", ID_CIENTIFICO, POS_GRANJAS[4], 100)

    _G.colocarTorreConFondos("Tv Woman", ID_TV_WOMAN, POS_TV_WOMAN[1], 650)
    task.wait(2.0) -- ESPERA DISFRUTABLE: Tiempo de resguardo tras la TV Woman
    
    -- Mejoras Nivel 2
    for i = 1, 4 do
        _G.esperarDinero(300)
        _G.mejorarTorreInvisibly(_G.TorresColocadas.Granjas[i], 2)
    end

    _G.esperarDinero(850)
    _G.mejorarTorreInvisibly(_G.TorresColocadas.TvWoman[1], 2)

    -- Mejoras Nivel 3
    for i = 1, 4 do
        _G.esperarDinero(600)
        _G.mejorarTorreInvisibly(_G.TorresColocadas.Granjas[i], 3)
    end

    _G.esperarDinero(2500)
    _G.mejorarTorreInvisibly(_G.TorresColocadas.TvWoman[1], 3)

    -- Mejoras Nivel 4 (Aquí fallaba el de 900)
    for i = 1, 4 do
        _G.esperarDinero(900)
        _G.mejorarTorreInvisibly(_G.TorresColocadas.Granjas[i], 4)
    end

    -- Mejoras Nivel 5 (Aquí fallaba el de 2000)
    for i = 1, 4 do
        _G.esperarDinero(2000)
        _G.mejorarTorreInvisibly(_G.TorresColocadas.Granjas[i], 5)
    end

    _G.esperarDinero(4000)
    _G.mejorarTorreInvisibly(_G.TorresColocadas.TvWoman[1], 4)
    _G.esperarDinero(9000)
    _G.mejorarTorreInvisibly(_G.TorresColocadas.TvWoman[1], 5)

    _G.colocarTorreConFondos("Tv Woman", ID_TV_WOMAN, POS_TV_WOMAN[2], 650)
    task.wait(2.0)
    
    local costosTvWoman = {850, 2500, 4000, 9000}
    for lvl, costo in ipairs(costosTvWoman) do
        _G.esperarDinero(costo)
        _G.mejorarTorreInvisibly(_G.TorresColocadas.TvWoman[2], lvl + 1)
    end

    -- Fase Ofensiva: 6 Titanes sin apuros de red
    local costosTitan = {1500, 2500, 5500, 9500}
    for t = 1, 6 do
        _G.colocarTorreConFondos("Upgraded Titan Speakerman", ID_TITAN, POS_TITANES[t], 1000)
        task.wait(1.5) -- TIEMPO EXTRA: Para que el servidor registre físicamente el Titán antes de mejorarlo
        for lvl, costo in ipairs(costosTitan) do
            _G.esperarDinero(costo)
            _G.mejorarTorreInvisibly(_G.TorresColocadas.Titanes[t], lvl + 1)
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
