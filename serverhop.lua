local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- Удаление старой версии интерфейса при повторном запуске
if CoreGui:FindFirstChild("ServerHopGui") then
    CoreGui.ServerHopGui:Destroy()
end

-- Создание ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ServerHopGui"
screenGui.ResetOnSpawn = false

if gethui then
    screenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(screenGui)
    screenGui.Parent = CoreGui
else
    screenGui.Parent = CoreGui
end

-- Основной контейнер для перемещения
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 160, 0, 75)
mainFrame.Position = UDim2.new(0.5, -80, 0.1, 0)
mainFrame.BackgroundTransparency = 1
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Надпись с ником beladonna
local nameLabel = Instance.new("TextLabel")
nameLabel.Name = "UserLabel"
nameLabel.Size = UDim2.new(1, 0, 0, 22)
nameLabel.Position = UDim2.new(0, 0, 0, 0)
nameLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
nameLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- Золотистый цвет
nameLabel.Text = "beladonna"
nameLabel.Font = Enum.Font.SourceSansBold
nameLabel.TextSize = 15
nameLabel.Parent = mainFrame

local labelCorner = Instance.new("UICorner")
labelCorner.CornerRadius = UDim.new(0, 6)
labelCorner.Parent = nameLabel

local labelStroke = Instance.new("UIStroke")
labelStroke.Thickness = 1
labelStroke.Color = Color3.fromRGB(255, 215, 0)
labelStroke.Parent = nameLabel

-- Кнопка Server Hop
local button = Instance.new("TextButton")
button.Name = "HopButton"
button.Size = UDim2.new(1, 0, 0, 45)
button.Position = UDim2.new(0, 0, 0, 28)
button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Text = "Server Hop"
button.Font = Enum.Font.SourceSansBold
button.TextSize = 18
button.Parent = mainFrame

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = button

local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 1.5
uiStroke.Color = Color3.fromRGB(80, 80, 80)
uiStroke.Parent = button

-- Логика переподключения на другой сервер
local function serverHop()
    button.Text = "Поиск..."
    local placeId = game.PlaceId
    local currentJobId = game.JobId
    
    local success, result = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/0?sortOrder=Asc&limit=100")
    end)
    
    if success and result then
        local decoded = HttpService:JSONDecode(result)
        if decoded and decoded.data then
            for _, server in ipairs(decoded.data) do
                if server.id ~= currentJobId and server.playing < server.maxPlayers then
                    button.Text = "Телепорт..."
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
                    return
                end
            end
        end
    end
    
    button.Text = "Ошибка / Нет мест"
    task.wait(2)
    button.Text = "Server Hop"
end

button.MouseButton1Click:Connect(serverHop)
