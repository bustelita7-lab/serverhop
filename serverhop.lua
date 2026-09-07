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

-- Кнопка с ником beladonna (переключатель видимости)
local nameButton = Instance.new("TextButton")
nameButton.Name = "UserButton"
nameButton.Size = UDim2.new(1, 0, 0, 25)
nameButton.Position = UDim2.new(0, 0, 0, 0)
nameButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
nameButton.TextColor3 = Color3.fromRGB(255, 215, 0) -- Золотистый цвет
nameButton.Text = "beladonna"
nameButton.Font = Enum.Font.SourceSansBold
nameButton.TextSize = 15
nameButton.Parent = mainFrame

local labelCorner = Instance.new("UICorner")
labelCorner.CornerRadius = UDim.new(0, 6)
labelCorner.Parent = nameButton

local labelStroke = Instance.new("UIStroke")
labelStroke.Thickness = 1
labelStroke.Color = Color3.fromRGB(255, 215, 0)
labelStroke.Parent = nameButton

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

-- Переключение видимости кнопки при нажатии на beladonna
nameButton.MouseButton1Click:Connect(function()
    button.Visible = not button.Visible
end)

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
