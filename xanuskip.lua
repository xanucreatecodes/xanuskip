if not game:IsLoaded() then game.Loaded:Wait() end
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetworkFolder = ReplicatedStorage:WaitForChild("ModuleLoader"):WaitForChild("Shared"):WaitForChild("Network"):WaitForChild("RemoteEvent")
local WaveSkipEvent = NetworkFolder:WaitForChild("WaveSkip")

local contadorSkip = 1

task.spawn(function()
    while true do
        pcall(function() 
            WaveSkipEvent:FireServer(contadorSkip) 
            WaveSkipEvent:FireServer(contadorSkip + 1)
            WaveSkipEvent:FireServer(contadorSkip + 2)
            contadorSkip = contadorSkip + 3 
        end)
        task.wait(0.1)
    end
end)
