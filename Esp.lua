local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Настройки цветов
local EnemyColor = Color3.fromRGB(255, 0, 0)   -- Красный
local TeamColor = Color3.fromRGB(0, 0, 255)    -- Синий

local function CreateESP(player)
    if player == LocalPlayer then return end

    -- Создаем квадрат для ESP
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.new(1, 1, 1)
    Box.Thickness = 1
    Box.Filled = false

    local function Update()
        local Connection
        Connection = game:GetService("RunService").RenderStepped:Connect(function()
            -- Проверяем, существует ли еще игрок и его персонаж
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                
                local RootPart = player.Character.HumanoidRootPart
                local Position, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)

                if OnScreen then
                    -- Рассчитываем размер бокса в зависимости от дистанции
                    local Scale = 1000 / Position.Z
                    Box.Size = Vector2.new(2 * Scale, 3 * Scale)
                    Box.Position = Vector2.new(Position.X - Box.Size.X / 2, Position.Y - Box.Size.Y / 2)
                    
                    -- Проверка на тимейта/врага
                    if player.Team == LocalPlayer.Team and player.Team ~= nil then
                        Box.Color = TeamColor
                    else
                        Box.Color = EnemyColor
                    end
                    
                    Box.Visible = true
                else
                    Box.Visible = false
                end
            else
                Box.Visible = false
                if not Players:FindFirstChild(player.Name) then
                    Box:Remove()
                    Connection:Disconnect()
                end
            end
        end)
    end

    coroutine.wrap(Update)()
end

-- Включаем ESP для тех, кто уже на сервере
for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end

-- Включаем ESP для новых игроков, которые заходят в игру
Players.PlayerAdded:Connect(CreateESP)
