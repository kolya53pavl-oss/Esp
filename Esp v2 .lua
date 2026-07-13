local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Создаем главное хранилище UI, которое не пропадет при перезагрузке
local CoreGui = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileESP_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Переменные для настроек функций (по умолчанию выключены)
local Settings = {
    TeamCheck = false,
    ShowDistance = false,
    ShowHealth = false,
    MasterToggle = true -- Главный выключатель ESP
}

-- Глобальная кнопка ПОЛНОГО скрытия интерфейса для телефонов (чтобы не мешало играть)
local GlobalHideButton = Instance.new("TextButton")
GlobalHideButton.Size = UUDim2.new(0, 40, 0, 40)
GlobalHideButton.Position = UDim2.new(0, 10, 0, 10)
GlobalHideButton.Text = "GUI"
GlobalHideButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
GlobalHideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GlobalHideButton.Font = Enum.Font.SourceSansBold
GlobalHideButton.TextSize = 14
GlobalHideButton.Parent = ScreenGui

local CornerHide = Instance.new("UICorner")
CornerHide.CornerRadius = UDim.new(0, 8)
CornerHide.Parent = GlobalHideButton

-- =========================================================
-- СОЗДАНИЕ ПЛАВАЮЩЕГО ОКНА (МЕНЮ) И ИКОНКИ
-- =========================================================

-- Маленькая иконка (появляется при закрытии)
local MenuIcon = Instance.new("TextButton")
MenuIcon.Size = UDim2.new(0, 50, 0, 50)
MenuIcon.Position = UDim2.new(0.5, -25, 0.1, 0)
MenuIcon.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
MenuIcon.Text = "ESP"
MenuIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuIcon.Font = Enum.Font.SourceSansBold
MenuIcon.TextSize = 18
MenuIcon.Visible = false
MenuIcon.Parent = ScreenGui

local CornerIcon = Instance.new("UICorner")
CornerIcon.CornerRadius = UDim.new(0, 25) -- Круглая
CornerIcon.Parent = MenuIcon

-- Главное плавающее окно
local MainWindow = Instance.new("Frame")
MainWindow.Size = UDim2.new(0, 220, 0, 260)
MainWindow.Position = UDim2.new(0.5, -110, 0.3, 0)
MainWindow.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainWindow.BorderSizePixel = 0
MainWindow.Active = true
MainWindow.Draggable = true -- Встроенный метод перетаскивания (отлично для мобилок)
MainWindow.Parent = ScreenGui

local CornerMain = Instance.new("UICorner")
CornerMain.CornerRadius = UDim.new(0, 10)
CornerMain.Parent = MainWindow

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "ESP Mobile Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = MainWindow

local CornerTitle = Instance.new("UICorner")
CornerTitle.CornerRadius = UDim.new(0, 10)
CornerTitle.Parent = Title

-- Кнопка Закрыть (X)
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 2)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 70, 70)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 18
CloseButton.Parent = MainWindow

-- Переключение между Окном и Иконкой
CloseButton.MouseButton1Click:Connect(function()
    MainWindow.Visible = false
    MenuIcon.Visible = true
end)

MenuIcon.MouseButton1Click:Connect(function()
    MenuIcon.Visible = false
    MainWindow.Visible = true
end)

-- Скрытие вообще всего интерфейса по кнопке GUI
GlobalHideButton.MouseButton1Click:Connect(function()
    local targetVisibility = not MainWindow.Visible and not MenuIcon.Visible
    if targetVisibility == true then
        MainWindow.Visible = true
    else
        MainWindow.Visible = false
        MenuIcon.Visible = false
    end
end)

-- =========================================================
-- ДОБАВЛЕНИЕ ФУНКЦИЙ И КНОПОК В МЕНЮ
-- =========================================================

local function CreateToggleButton(text, positionY, settingKey)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 180, 0, 35)
    Button.Position = UDim2.new(0.5, -90, 0, positionY)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 16
    Button.Parent = MainWindow
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button

    local function UpdateVisuals()
        if Settings[settingKey] then
            Button.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Зеленый (ВКЛ)
            Button.Text = text .. ": ВКЛ"
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            Button.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Красный (ВЫКЛ)
            Button.Text = text .. ": ВЫКЛ"
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end

    Button.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        UpdateVisuals()
    end)

    UpdateVisuals()
end

-- Создаем 3 нужные кнопки
CreateToggleButton("Team Check", 60, "TeamCheck")
CreateToggleButton("Дистанция врагов", 110, "ShowDistance")
CreateToggleButton("Здоровье врагов", 160, "ShowHealth")

-- Кнопка выключения самого ESP (чтобы можно было просто всё выключить)
CreateToggleButton("Включить ESP", 210, "MasterToggle")

-- =========================================================
-- ЛОГИКА ESP НА СТАНДАРТНЫХ ОБЪЕКТАХ (РАБОТАЕТ ВЕЗДЕ)
-- =========================================================

local function CreateESP(player)
    if player == LocalPlayer then return end

    -- Создаем контейнер для элементов над головой игрока
    local Billboard = Instance.new("BillboardGui")
    Billboard.Size = UDim2.new(0, 200, 0, 100)
    Billboard.AlwaysOnTop = true
    Billboard.ExtentsOffset = Vector3.new(0, 3, 0) -- Высота над головой
    Billboard.Enabled = false

    -- Лейбл для текста (Имя, Дистанция, ХП)
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, 0, 1, 0)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Font = Enum.Font.SourceSansBold
    InfoLabel.TextSize = 14
    InfoLabel.TextStrokeTransparency = 0 -- Обводка текста для читаемости
    InfoLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    InfoLabel.Parent = Billboard

    -- Подсветка персонажа (Бокс) через Highlight — идеально видно сквозь стены на телефонах
    local Highlight = Instance.new("Highlight")
    Highlight.FillTransparency = 0.6
    Highlight.OutlineTransparency = 0
    Highlight.Enabled = false

    local function ApplyESP(character)
        Billboard.Parent = character:WaitForChild("HumanoidRootPart", 5)
        Highlight.Parent = character
    end

    if player.Character then ApplyESP(player.Character) end
    player.CharacterAdded:Connect(ApplyESP)

    -- Поток обновления данных
    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        if not player.Parent then
            Billboard:Destroy()
            Highlight:Destroy()
            Connection:Disconnect()
            return
        end

        local char = player.Character
        local lChar = LocalPlayer.Character

        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and lChar and lChar:FindFirstChild("HumanoidRootPart") then
            
            local isTeam = (player.Team == LocalPlayer.Team and player.Team ~= nil)
            
            -- Если включен TeamCheck и это тимейт — полностью скрываем ESP для него
            if Settings.TeamCheck and isTeam then
                Billboard.Enabled = false
                Highlight.Enabled = false
                return
            end

            -- Проверяем главный выключатель
            if not Settings.MasterToggle then
                Billboard.Enabled = false
                Highlight.Enabled = false
                return
            end

            -- Настройка цвета (Тимейт — синий, Враг — красный)
            local MainColor = isTeam and Color3.fromRGB(0, 0, 255) or Color3.fromRGB(255, 0, 0)
            Highlight.FillColor = MainColor
            Highlight.OutlineColor = MainColor
            InfoLabel.TextColor3 = MainColor

            -- Сбор текста информации
            local text = player.Name
            
            if Settings.ShowHealth then
                text = text .. " [" .. math.floor(char.Humanoid.Health) .. " HP]"
            end
            
            if Settings.ShowDistance then
                local dist = math.floor((lChar.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude)
                text = text .. " (" .. dist .. "m)"
            end

            InfoLabel.Text = text
            Billboard.Enabled = true
            Highlight.Enabled = true
        else
            Billboard.Enabled = false
            Highlight.Enabled = false
        end
    end)
end

-- Инициализация для всех
for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
