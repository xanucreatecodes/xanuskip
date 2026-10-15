-- ====================================================================
-- CAMERA TD - AUTO-FARM INVISIBLE RED PURA (VERSIÓN SUPREMA V19.24 - PARTE 1)
-- PROPIEDAD DE: xanu_7 (MAXEO DE NINJA SINCRONIZADO CON PRIORIDAD TOTAL)
-- ====================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ENRUTAMIENTO DE RED DIRECTO VERIFICADO POR COBALT SPY
local NetworkFolder = ReplicatedStorage:WaitForChild("ModuleLoader"):WaitForChild("Shared"):WaitForChild("Network"):WaitForChild("RemoteEvent")
local TowerAddEvent = NetworkFolder:WaitForChild("TowerAdd")
local TowerUpgradeEvent = NetworkFolder:WaitForChild("TowerUpgrade")
local TowerSellEvent = NetworkFolder:FindFirstChild("TowerSell") or NetworkFolder:WaitForChild("TowerSell", 2)
local WaveSkipEvent = NetworkFolder:WaitForChild("WaveSkip")

-- ALTURA REAL EXACTA DEL SUELO DETECTADA POR COBALT SPY
local ALTURA_REAL = -47.456172943115234

-- CONTROL DE COORDENADAS RECTIFICADAS E INDEXADAS
local COORD_NINJA = Vector3.new(-28.6, ALTURA_REAL, 13.0) 
local POS_GRANJAS = {
    Vector3.new(-42.2, ALTURA_REAL, 28.5), -- Científico 1
    Vector3.new(-40.0, ALTURA_REAL, 43.5), -- Científico 2
    Vector3.new(-62.64520263671875, ALTURA_REAL, 34.223361968994141), -- Científico 3
    Vector3.new(-60.9, ALTURA_REAL, 42.9)  -- Científico 4
}
local POS_TITANES = {
    Vector3.new(-18.5, ALTURA_REAL, 6.2),  -- Titán 1
    Vector3.new(-24.9, ALTURA_REAL, 4.0), -- Titán 2
    Vector3.new(-30.9, ALTURA_REAL, 4.0), -- Titán 3
    Vector3.new(-36.9, ALTURA_REAL, 4.0),  -- Titán 4
    Vector3.new(-42.9, ALTURA_REAL, 4.0), -- Titán 5
    Vector3.new(-48.9, ALTURA_REAL, 4.0),-- Titán 6
    Vector3.new(-54.9, ALTURA_REAL, 4.0)  -- Titán 7
}

local ID_CIENTIFICO = "197db902-78aa-48d8-bb47-2fe8a49e8158"
local ID_NINJA = "223ddc29-f04c-4998-92ae-da96d97f955e"
local ID_TITAN = "4dc48afd-ab0d-4d2a-b0c9-7660403559bf"

local contadorSkip = 1
_G.NinjaMaxeado = false -- CANDADO DE PRIORIDAD CRÍTICO
_G.activarEscanerRejoin = false
_G.TorresColocadas = { Granjas = {}, Titanes = {}, Ninja = nil }

-- INTERCEPTOR DE RED PASIVO (RECOLECTOR DE IDS E INDEX NATIVOS)
TowerAddEvent.OnClientEvent:Connect(function(data)
    if data and data.Pos and data.Id and data.Index then
        if (data.Pos - COORD_NINJA).Magnitude < 4 then
            _G.TorresColocadas.Ninja = { Id = data.Id, Index = data.Index }
        else
            for i, pos in ipairs(POS_GRANJAS) do
                if (data.Pos - pos).Magnitude < 4 then _G.TorresColocadas.Granjas[i] = { Id = data.Id, Index = data.Index } end
            end
            for i, pos in ipairs(POS_TITANES) do
                if (data.Pos - pos).Magnitude < 4 then _G.TorresColocadas.Titanes[i] = { Id = data.Id, Index = data.Index } end
            end
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
    if miDinero() == 99999 then task.wait(2) return end
    while miDinero() < cantidad do task.wait(0.1) end
end

_G.colocarTorreDirecto = function(nombreInterno, unitId, posicion)
    local struct = {
        UnitId = unitId,
        CFrame = CFrame.new(posicion.X, posicion.Y, posicion.Z, 1, 0, 0, 0, 1, 0, 0, 0, 1),
        Name = nombreInterno,
        Pos = posicion
    }
    TowerAddEvent:FireServer(struct)
    task.wait(0.5)
end

_G.colocarTorreConFondos = function(nombreInterno, unitId, posicion, costoUnidad)
    _G.esperarDinero(costoUnidad) 
    _G.colocarTorreDirecto(nombreInterno, unitId, posicion)
end

_G.mejorarTorreInvisibly = function(datosTorre, nivelDestino)
    if not datosTorre or not datosTorre.Id or not datosTorre.Index then return end
    TowerUpgradeEvent:FireServer({ Id = datosTorre.Id, Index = datosTorre.Index, Level = nivelDestino })
    task.wait(0.15)
end

_G.venderTorreInvisibly = function(datosTorre)
    if datosTorre and datosTorre.Id and TowerSellEvent then TowerSellEvent:FireServer({ Id = datosTorre.Id }) end
    task.wait(0.2)
end

-- HILO COMPLEMENTARIO: AUTO WAVE SKIP CON CONTADOR CORRELATIVO
task.spawn(function()
    while true do
        pcall(function() WaveSkipEvent:FireServer(contadorSkip) contadorSkip = contadorSkip + 1 end)
        task.wait(1.2)
    end
end)

-- CONFIGURACIÓN AUTOMÁTICA DE INTERFAZ Y RED AL INICIO ABSOLUTO
task.spawn(function()
    pcall(function()
        local CS = ReplicatedStorage:WaitForChild("ModuleLoader"):WaitForChild("Shared"):WaitForChild("Network"):WaitForChild("RemoteFunction"):FindFirstChild("ChangeSpeed")
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

-- HILO CRONOLÓGICO: PARTE A DEL FARM (COLOCACIÓN COMPLETA Y MAXEO DEL NINJA)
task.spawn(function()
    task.wait(5.5)

    -- [OLA 1]
    _G.colocarTorreDirecto("Scientist Cameraman", ID_CIENTIFICO, POS_GRANJAS[1])
    _G.colocarTorreDirecto("Scientist Cameraman", ID_CIENTIFICO, POS_GRANJAS[2])
    
    -- [OLA 2]
    _G.colocarTorreConFondos("Scientist Cameraman", ID_CIENTIFICO, POS_GRANJAS[3], 100)
    
    -- [OLA 3]
     _G.colocarTorreConFondos("Ninja Cameraman", ID_NINJA, COORD_NINJA, 200)
    task.wait(0.5) -- Colchón anti-lag de red
    _G.colocarTorreConFondos("Scientist Cameraman", ID_CIENTIFICO, POS_GRANJAS[4], 100)

    -- [FASE MEJORA NINJA - PRIORIDAD ABSOLUTA EN LA PARTE 1]
    local costosNinja = {300, 600, 900, 1000}
    for lvl, costo in ipairs(costosNinja) do
        _G.esperarDinero(costo)
        _G.mejorarTorreInvisibly(_G.TorresColocadas.Ninja, lvl + 1)
        task.wait(0.1)
    end
    
    print("[AutoFarm V19.24]: Ninja maxeado por completo. Liberando candado...")
    _G.NinjaMaxeado = true -- SE ABRE EL CANDADO PARA LA PARTE 2
end)
-- ====================================================================
-- CAMERA TD - AUTO-FARM INVISIBLE RED PURA (VERSIÓN SUPREMA V19.25 - PARTE 2)
-- PROPIEDAD DE: xanu_7 (FIX DE ECONOMÍA: 4TO CIENTÍFICO ASEGURADO AL 100%)
-- ====================================================================

-- FRENO DE SEGURIDAD INTERNO: No avanza hasta que el Ninja de la Parte 1 esté al máximo nivel
while not _G.NinjaMaxeado do task.wait(0.1) end

-- ====================================================================
-- HILO CRONOLÓGICO: PARTE B DEL FARM (ARRANCA ESTRICTAMENTE TRAS EL NINJA)
-- ====================================================================
task.spawn(function()
    print("[AutoFarm V19.25]: Candado abierto. Iniciando mejoras en científicos...")

    -- [FASE GRANJAS EN PARALELO]: Sube de nivel las 4 granjas separadas por ID
    local costosGranja = {300, 600, 900, 2000}
    for lvl, costo in ipairs(costosGranja) do
        for i = 1, 4 do
            _G.esperarDinero(costo)
            _G.mejorarTorreInvisibly(_G.TorresColocadas.Granjas[i], lvl + 1)
            task.wait(0.25) -- Más tiempo para que el servidor procese cada granja
        end
    end

    -- ASEGURAR EL MÁXIMO NIVEL DEL CUARTO CIENTÍFICO CON REINTENTO
    _G.esperarDinero(2000)
    task.wait(0.5) -- Pausa de oro para asegurar que el dinero cargó de verdad
    if _G.TorresColocadas.Granjas[4] then
        _G.mejorarTorreInvisibly(_G.TorresColocadas.Granjas[4], 5)
    end
    task.wait(0.2)
    end

    -- CORRECCIÓN CRÍTICA: Forzamos la espera del dinero y la última mejora del 4to Científico
    -- Esto evita que el script pase de largo a los Titanes si el servidor se queda sin fondos un milisegundo
    _G.esperarDinero(2000)
    _G.mejorarTorreInvisibly(_G.TorresColocadas.Granjas[4], 5)
    task.wait(0.2)
    print("[AutoFarm V19.25]: Las 4 granjas han sido maxeadas perfectamente.")

    -- [PRIMER TITÁN]: Colocado de forma exacta en el índice 1 de la tabla original
    _G.colocarTorreConFondos("Upgraded Titan Speakerman", ID_TITAN, POS_TITANES[1], 1000)
    
    local costosTitan = {1500, 2500, 5500, 9500}
    for lvl, costo in ipairs(costosTitan) do
        _G.esperarDinero(costo)
        _G.mejorarTorreInvisibly(_G.TorresColocadas.Titanes[1], lvl + 1)
        task.wait(0.1)
    end

    -- [VENTA DEL NINJA]: Ejecutado a través del ID guardado en red pura
    _G.venderTorreInvisibly(_G.TorresColocadas.Ninja)

    -- [DESPLIEGUE Y MEJORA DE LOS TITANES RESTANTES (DEL 2 AL 7 TOTALMENTE SEPARADOS)]
    for t = 2, 7 do
        _G.colocarTorreConFondos("Upgraded Titan Speakerman", ID_TITAN, POS_TITANES[t], 1000)
        
        for lvl, costo in ipairs(costosTitan) do
            _G.esperarDinero(costo)
            _G.mejorarTorreInvisibly(_G.TorresColocadas.Titanes[t], lvl + 1)
            task.wait(0.1)
        end
    end
    
    print("[AutoFarm V19.25]: ¡Estrategia completada! Encendiendo Rejoin de red pura...")
    task.wait(2)
    _G.activarEscanerRejoin = true 
end)
-- ====================================================================
-- REJOIN FÍSICO BLINDADO V19.45 (UNIFICADO AL FINAL ABSOLUTO)
-- PROPIEDAD DE: xanu_7 (FRENO ESTRICTO POR VISIBILIDAD DE INTERFAZ)
-- ====================================================================
task.spawn(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    print("[Rejoin V19.45]: Escáner de píxeles activo de fondo. Vigilando fin de partida...")
    local partidaTerminadaReal = false

    while not partidaTerminadaReal do
        pcall(function()
            local LocalPlayer = game:GetService("Players").LocalPlayer
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            
            -- Verificamos de forma estricta que la carpeta visual final de tu Dex esté visible en pantalla
            local GameUI = PlayerGui:FindFirstChild("GameUI")
            local FinalUI = GameUI and GameUI:FindFirstChild("FinalUI")
            
            if FinalUI and FinalUI.Visible == true then
                -- Una vez que el cartel azul/rojo nace en tu pantalla, buscamos el botón
                for _, obj in pairs(FinalUI:GetDescendants()) do
                    if obj.Name == "PlayAgain" and obj:IsA("GuiButton") and obj.AbsoluteSize.X > 0 then
                        
                        -- TU COLCHÓN CRÍTICO: 3.5 segundos obligatorios para asegurar tus monedas
                        print("[Rejoin V19.45]: ¡Cartel detectado! Esperando 3.5 segundos de resguardo...")
                        task.wait(3.5)
                        
                        -- INGENIERÍA DE PÍXELES ULTRA CALIBRADA (ABAJO Y A LA DERECHA)
                        local posX = obj.AbsolutePosition.X + (obj.AbsoluteSize.X / 2) + 25
                        local posY = obj.AbsolutePosition.Y + (obj.AbsoluteSize.Y / 2) + 55
                        
                        print("[Rejoin Xanu]: Clickeando centro real en: X = " .. posX .. ", Y = " .. posY)
                        
                        -- Simula la pulsación física perfecta en el centro del botón verde
                        VirtualInputManager:SendMouseButtonEvent(posX, posY, 0, true, game, 1) -- Presiona
                        task.wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(posX, posY, 0, false, game, 1) -- Suelta
                        
                        print("[Rejoin V19.45]: ¡Pulsación física completada con éxito!")
                        partidaTerminadaReal = true
                        break
                    end
                end
            end
        end)
        if partidaTerminadaReal then break end
        task.wait(1.0) -- Escaneo pasivo libre de lag cada segundo
    end
end)
