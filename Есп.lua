local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Создаем GUI в CoreGui, чтобы меню не пропадало
local CoreGui = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Mobile_ESP_Fixed"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Настройки функций
local Settings = {
    TeamCheck = false,
    ShowDistance = false,
    ShowHealth = false,
    MasterToggle = true
}

-- Глобальная кнопка скрытия интерфейса (в углу экрана)
local GlobalHideButton = Instance.new("TextButton")
GlobalHideButton.Size = UDim2.new(0, 45, 0, 45)
GlobalHideButton.Position = UDim2.new(0, 10, 0, 10)
GlobalHideButton.Text = "GUI"
GlobalHideButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
GlobalHideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GlobalHideButton.Font = Enum.Font.SourceSansBold
GlobalHideButton.TextSize = 16
GlobalHideButton.Parent = ScreenGui

local CornerHide = Instance.new("UICorner")
CornerHide.CornerRadius = UDim.new(0, 8)
CornerHide.Parent = GlobalHideButton

-- Маленькая круглая иконка
local MenuIcon = Instance.new("TextButton")
MenuIcon.Size = UDim2.new(0, 55, 0, 55)
MenuIcon.Position = UDim2.new(0.5, -27, 0.1, 0)
MenuIcon.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
MenuIcon.Text = "ESP"
MenuIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuIcon.Font = Enum.Font.SourceSansBold
MenuIcon.TextSize = 18
MenuIcon.Visible = false
MenuIcon.Parent = ScreenGui

local CornerIcon = Instance.new("UICorner")
CornerIcon.CornerRadius = UDim.new(0, 30)
CornerIcon.Parent = MenuIcon

-- Главное меню
local MainWindow = Instance.new("Frame")
MainWindow.Size = UDim2.new(0, 220, 0, 260)
MainWindow.Position = UDim2.new(0.5, -110, 0.3, 0)
MainWindow.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainWindow.Active = true
MainWindow.Draggable = true -- Перетаскивание пальцем
MainWindow.Parent = ScreenGui

local CornerMain = Instance.new("UICorner")
CornerMain.CornerRadius = UDim.new(0, 10)
CornerMain.Parent = MainWindow

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "ESP Mobile Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = MainWindow

local CornerTitle = Instance.new("UICorner")
CornerTitle.CornerRadius = UDim.new(0, 10)
CornerTitle.Parent = Title

-- Кнопка закрытия (X)
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -40, 0, 2)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 75, 75)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 20
CloseButton.Parent = MainWindow

-- Логика переключения окон
CloseButton.MouseButton1Click:Connect(function()
    MainWindow.Visible = false
    MenuIcon.Visible = true
end)

MenuIcon.MouseButton1Click:Connect(function()
    MenuIcon.Visible = false
    MainWindow.Visible = true
end)

GlobalHideButton.MouseButton1Click:Connect(function()
    local isVisible = MainWindow.Visible or MenuIcon.Visible
    if isVisible then
        MainWindow.Visible = false
        MenuIcon.Visible = false
    else
        MainWindow.Visible = true
    end
end)

-- Конструктор кнопок меню
local function CreateToggleButton(text, positionY, settingKey)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 190, 0, 35)
    Button.Position = UDim2.new(0.5, -95, 0, positionY)
    Button.Font = Enum.Font.SourceSansBold
    Button.TextSize = 15
    Button.Parent = MainWindow
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button

    local function UpdateVisuals()
        if Settings[settingKey] then
            Button.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Зеленый
            Button.Text = text .. ": ВКЛ"
        else
            Button.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Красный
            Button.Text = text .. ": ВЫКЛ"
        end
    end

    Button.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        UpdateVisuals()
    end)

    UpdateVisuals()
end

CreateToggleButton("Team Check", 55, "TeamCheck")
CreateToggleButton("Дистанция врагов", 105, "ShowDistance")
CreateToggleButton("Здоровье врагов", 155, "ShowHealth")
CreateToggleButton("Включить ESP", 205, "MasterToggle")

-- =========================================================
-- НАДЕЖНЫЙ ESP НА FRAME И BILLBOARD GUI (100% РАБОТАЕТ НА МОБИЛКАХ)
-- =========================================================

local function CreateESP(player)
    if player == LocalPlayer then return end

    -- Основной контейнер 2D графики поверх персонажа
    local BoxGui = Instance.new("BillboardGui")
    BoxGui.Size = UDim2.new(4.5, 0, 6, 0) -- Пропорции рамки вокруг игрока
    BoxGui.AlwaysOnTop = true
    BoxGui.ResetOnSpawn = false
    BoxGui.Enabled = false

    -- Сама рамка (ESP Box)
    local BoxFrame = Instance.new("Frame")
    BoxFrame.Size = UDim2.new(1, 0, 1, 0)
    BoxFrame.BackgroundTransparency = 1
    BoxFrame.BorderSizePixel = 0
    BoxFrame.Parent = BoxGui

    -- Отрисовка линий рамки (через UIStroke, чтобы не лагало)
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 2
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = BoxFrame

    -- Текстовый лейбл для инфы (Имя, ХП, Дистанция)
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, 0, 0, 20)
    InfoLabel.Position = UDim2.new(0, 0, 1, 2) -- Снизу под рамкой
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Font = Enum.Font.SourceSansBold
    InfoLabel.TextSize = 13
    InfoLabel.TextStrokeTransparency = 0
    InfoLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    InfoLabel.Parent = BoxGui

    local function ApplyESP(character)
        local root = character:WaitForChild("HumanoidRootPart", 10)
        if root then
            BoxGui.Parent = root
            BoxGui.Adornee = root
        end
    end

    if player.Character then ApplyESP(player.Character) end
    player.CharacterAdded:Connect(ApplyESP)

    -- Постоянное обновление состояния
    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        -- Если игрок вышел — чистим память
        if not player.Parent then
            BoxGui:Destroy()
            Connection:Disconnect()
            return
        end

        local char = player.Character
        local lChar = LocalPlayer.Character

        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and lChar and lChar:FindFirstChild("HumanoidRootPart") then
            
            local isTeam = (player.Team == LocalPlayer.Team and player.Team ~= nil)
            
            -- Проверка Team Check
            if Settings.TeamCheck and isTeam then
                BoxGui.Enabled = false
                return
            end

            -- Проверка главного тумблера
            if not Settings.MasterToggle then
                BoxGui.Enabled = false
                return
            end

            -- Цвет: Синий для своих, Красный для врагов
            local CurrentColor = isTeam and Color3.fromRGB(0, 0, 255) or Color3.fromRGB(255, 0, 0)
            Stroke.Color = CurrentColor
            InfoLabel.TextColor3 = CurrentColor

            -- Сборка текста
            local infoText = player.Name
            
            if Settings.ShowHealth then
                infoText = infoText .. " [" .. math.floor(char.Humanoid.Health) .. " HP]"
            end
            
            if Settings.ShowDistance then
                local distance = math.floor((lChar.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude)
                infoText = infoText .. " (" .. distance .. "m)"
            end

            InfoLabel.Text = infoText
            BoxGui.Enabled = true
        else
            BoxGui.Enabled = false
        end
    end)
end

-- Запуск для всех
for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
