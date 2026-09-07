-- Серверный скрипт: ServerScriptService/ServerhopHandler.lua
-- Отвечает на запрос от клиента, получает список публичных серверов �� телепортирует игрока в подходящий сервер.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local PLACE_ID = game.PlaceId

-- Создаём RemoteEvent, если его нет
local event = ReplicatedStorage:FindFirstChild("ServerhopEvent")
if not event then
    event = Instance.new("RemoteEvent")
    event.Name = "ServerhopEvent"
    event.Parent = ReplicatedStorage
end

-- Обработчик от клиента
event.OnServerEvent:Connect(function(player)
    -- Попробуем запросить список публичных серверов (пагинация ограничена limit)
    local success, result = pcall(function()
        return HttpService:GetAsync("https://games.roblox.com/v1/games/" .. tostring(PLACE_ID) .. "/servers/Public?sortOrder=Asc&limit=100")
    end)
    if not success then
        -- Отправляем клиенту сообщение об ошибке
        event:FireClient(player, false, "Не удалось получить список серверов.")
        return
    end

    local decoded = nil
    local ok, decodeErr = pcall(function()
        decoded = HttpService:JSONDecode(result)
    end)
    if not ok or not decoded or not decoded.data then
        event:FireClient(player, false, "Ошибка обработки ответа сервера.")
        return
    end

    -- Найдём сервер, который не полный и не текущий
    local targetServerId = nil
    for _, server in ipairs(decoded.data) do
        -- server.playing, server.maxPlayers, server.id
        if server.playing < server.maxPlayers then
            -- сравниваем id сервера с текущим job id (в API поле id обычно строка)
            local currentJobId = tostring(game.JobId)
            if tostring(server.id) ~= currentJobId then
                targetServerId = server.id
                break
            end
        end
    end

    if targetServerId then
        local okTeleport, teleportErr = pcall(function()
            TeleportService:TeleportToPlaceInstance(PLACE_ID, targetServerId, player)
        end)
        if not okTeleport then
            event:FireClient(player, false, "Ошибка телепорта: " .. tostring(teleportErr))
        end
    else
        event:FireClient(player, false, "Подходящего сервера не найдено. Попробуйте снова позже.")
    end
end)
