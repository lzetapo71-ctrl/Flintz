--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// PLAYER & CHARACTER
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local inputEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Input")

-------------------------------------------------------------------
--// VARIABLES
-------------------------------------------------------------------
local TARGET_ANIMS_S1 = { ["rbxassetid://18790224306"] = true, ["rbxassetid://18783040383"] = true }
local ANIMS_GOLPE_S2 = { ["rbxassetid://18783040383"] = true, ["rbxassetid://18783044488"] = true, ["rbxassetid://18790224306"] = true }

local PASSWORDS = { ["Flintz2"] = true, ["Martina"] = true, ["potoloko"] = true }
local usedPasswords = {}
local scriptUnlocked = false

local device = UserInputService.TouchEnabled and "Mobile" or "PC"

-- DETECCIÓN SEGURA DEL EXECUTOR
local executor = "Unknown"
local function safeCheck(name)
    return pcall(function() return getgenv()[name] end)
end
if pcall(function() return syn end) and syn then executor = "Synapse X"
elseif pcall(function() return KRNL_LOADED end) and KRNL_LOADED then executor = "Krnl"
elseif pcall(function() return Delta end) and Delta then executor = "Delta"
elseif pcall(function() return fluxus end) and fluxus then executor = "Fluxus"
elseif pcall(function() return getgenv().is_sirhurt_closure end) and getgenv().is_sirhurt_closure then executor = "Sirhurt"
elseif pcall(function() return EXECUTORLABEL end) and EXECUTORLABEL then executor = tostring(EXECUTORLABEL)
end

local function getDateTime()
    local months = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}
    local t = os.date("*t")
    local hour = t.hour
    local ampm = hour >= 12 and "PM" or "AM"
    hour = hour % 12
    if hour == 0 then hour = 12 end
    local timeStr = string.format("%d:%02d:%02d %s", hour, t.min, t.sec, ampm)
    local dateStr = string.format("%s %d, %d", months[t.month], t.day, t.year)
    return timeStr, dateStr
end

-------------------------------------------------------------------
--// FUNCIONES
-------------------------------------------------------------------
local function lanzarGolpe()
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then tool:Activate() end
    inputEvent:FireServer("M1")
end

local function setupDetection(hum)
    hum.AnimationPlayed:Connect(function(track)
        if not scriptUnlocked then return end
        local id = tostring(track.Animation.AnimationId)
        if TARGET_ANIMS_S1[id] or ANIMS_GOLPE_S2[id] then lanzarGolpe() end
    end)
end

-------------------------------------------------------------------
--// GUI
-------------------------------------------------------------------
local function createPasswordGui()
    local gui = Instance.new("ScreenGui", player.PlayerGui)
    gui.Name = "PasswordGui"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true

    local overlay = Instance.new("Frame", gui)
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.3
    overlay.BorderSizePixel = 0

    local container = Instance.new("Frame", gui)
    container.Size = UDim2.fromOffset(420, 220)
    container.Position = UDim2.new(0.5, -210, 0.5, -110)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0

    -- PANEL IZQUIERDO
    local leftPanel = Instance.new("Frame", container)
    leftPanel.Size = UDim2.fromOffset(140, 220)
    leftPanel.Position = UDim2.new(0, 0, 0, 0)
    leftPanel.BackgroundColor3 = Color3.fromRGB(10, 18, 35)
    leftPanel.BorderSizePixel = 0
    Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 14)
    local leftStroke = Instance.new("UIStroke", leftPanel)
    leftStroke.Color = Color3.fromRGB(40, 90, 180); leftStroke.Thickness = 1.5

    local avatarFrame = Instance.new("Frame", leftPanel)
    avatarFrame.Size = UDim2.fromOffset(55, 55)
    avatarFrame.Position = UDim2.new(0.5, -27, 0, 14)
    avatarFrame.BackgroundColor3 = Color3.fromRGB(20, 35, 65)
    avatarFrame.BorderSizePixel = 0
    Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(0, 10)
    local avatarStroke = Instance.new("UIStroke", avatarFrame)
    avatarStroke.Color = Color3.fromRGB(50, 110, 220); avatarStroke.Thickness = 2

    local avatarImg = Instance.new("ImageLabel", avatarFrame)
    avatarImg.Size = UDim2.fromScale(1, 1)
    avatarImg.BackgroundTransparency = 1
    avatarImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png"
    Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(0, 10)

    local welcomeLabel = Instance.new("TextLabel", leftPanel)
    welcomeLabel.Size = UDim2.new(1, 0, 0, 18)
    welcomeLabel.Position = UDim2.new(0, 0, 0, 74)
    welcomeLabel.BackgroundTransparency = 1
    welcomeLabel.Text = "Welcome, " .. player.Name
    welcomeLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
    welcomeLabel.Font = Enum.Font.GothamBold
    welcomeLabel.TextSize = 11

    local sep1 = Instance.new("Frame", leftPanel)
    sep1.Size = UDim2.new(0.85, 0, 0, 1)
    sep1.Position = UDim2.new(0.075, 0, 0, 98)
    sep1.BackgroundColor3 = Color3.fromRGB(40, 70, 140)
    sep1.BorderSizePixel = 0

    local execTitle = Instance.new("TextLabel", leftPanel)
    execTitle.Size = UDim2.new(1, -10, 0, 14)
    execTitle.Position = UDim2.new(0, 8, 0, 104)
    execTitle.BackgroundTransparency = 1
    execTitle.Text = "Executor"
    execTitle.TextColor3 = Color3.fromRGB(100, 130, 200)
    execTitle.Font = Enum.Font.Gotham
    execTitle.TextSize = 10
    execTitle.TextXAlignment = Enum.TextXAlignment.Left

    local execValue = Instance.new("TextLabel", leftPanel)
    execValue.Size = UDim2.new(1, -10, 0, 16)
    execValue.Position = UDim2.new(0, 8, 0, 116)
    execValue.BackgroundTransparency = 1
    execValue.Text = executor
    execValue.TextColor3 = Color3.fromRGB(80, 140, 255)
    execValue.Font = Enum.Font.GothamBold
    execValue.TextSize = 12
    execValue.TextXAlignment = Enum.TextXAlignment.Left

    local devTitle = Instance.new("TextLabel", leftPanel)
    devTitle.Size = UDim2.new(1, -10, 0, 14)
    devTitle.Position = UDim2.new(0, 8, 0, 136)
    devTitle.BackgroundTransparency = 1
    devTitle.Text = "Device"
    devTitle.TextColor3 = Color3.fromRGB(100, 130, 200)
    devTitle.Font = Enum.Font.Gotham
    devTitle.TextSize = 10
    devTitle.TextXAlignment = Enum.TextXAlignment.Left

    local devValue = Instance.new("TextLabel", leftPanel)
    devValue.Size = UDim2.new(1, -10, 0, 16)
    devValue.Position = UDim2.new(0, 8, 0, 148)
    devValue.BackgroundTransparency = 1
    devValue.Text = device
    devValue.TextColor3 = Color3.fromRGB(80, 140, 255)
    devValue.Font = Enum.Font.GothamBold
    devValue.TextSize = 12
    devValue.TextXAlignment = Enum.TextXAlignment.Left

    local sep2 = Instance.new("Frame", leftPanel)
    sep2.Size = UDim2.new(0.85, 0, 0, 1)
    sep2.Position = UDim2.new(0.075, 0, 0, 170)
    sep2.BackgroundColor3 = Color3.fromRGB(40, 70, 140)
    sep2.BorderSizePixel = 0

    local timeLabel = Instance.new("TextLabel", leftPanel)
    timeLabel.Size = UDim2.new(1, 0, 0, 18)
    timeLabel.Position = UDim2.new(0, 0, 0, 175)
    timeLabel.BackgroundTransparency = 1
    timeLabel.TextColor3 = Color3.fromRGB(80, 140, 255)
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.TextSize = 12

    local dateLabel = Instance.new("TextLabel", leftPanel)
    dateLabel.Size = UDim2.new(1, 0, 0, 14)
    dateLabel.Position = UDim2.new(0, 0, 0, 195)
    dateLabel.BackgroundTransparency = 1
    dateLabel.TextColor3 = Color3.fromRGB(120, 150, 200)
    dateLabel.Font = Enum.Font.Gotham
    dateLabel.TextSize = 10

    local timeStr, dateStr = getDateTime()
    timeLabel.Text = timeStr
    dateLabel.Text = dateStr
    task.spawn(function()
        while gui and gui.Parent do
            local t, d = getDateTime()
            timeLabel.Text = t
            dateLabel.Text = d
            task.wait(1)
        end
    end)

    -- PANEL DERECHO
    local rightPanel = Instance.new("Frame", container)
    rightPanel.Size = UDim2.fromOffset(268, 220)
    rightPanel.Position = UDim2.new(0, 152, 0, 0)
    rightPanel.BackgroundColor3 = Color3.fromRGB(12, 20, 40)
    rightPanel.BorderSizePixel = 0
    Instance.new("UICorner", rightPanel).CornerRadius = UDim.new(0, 14)
    local rightStroke = Instance.new("UIStroke", rightPanel)
    rightStroke.Color = Color3.fromRGB(40, 90, 180); rightStroke.Thickness = 1.5

    local closeBtn = Instance.new("TextButton", rightPanel)
    closeBtn.Size = UDim2.fromOffset(22, 22)
    closeBtn.Position = UDim2.new(1, -28, 0, 6)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.BorderSizePixel = 0
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    local brandLabel = Instance.new("TextLabel", rightPanel)
    brandLabel.Size = UDim2.new(1, -40, 0, 24)
    brandLabel.Position = UDim2.new(0, 10, 0, 10)
    brandLabel.BackgroundTransparency = 1
    brandLabel.Text = "⚡ Flintz"
    brandLabel.TextColor3 = Color3.fromRGB(80, 140, 255)
    brandLabel.Font = Enum.Font.GothamBold
    brandLabel.TextSize = 15
    brandLabel.TextXAlignment = Enum.TextXAlignment.Left

    local enterKeyFrame = Instance.new("Frame", rightPanel)
    enterKeyFrame.Size = UDim2.new(0.88, 0, 0, 32)
    enterKeyFrame.Position = UDim2.new(0.06, 0, 0, 42)
    enterKeyFrame.BackgroundColor3 = Color3.fromRGB(18, 30, 60)
    enterKeyFrame.BorderSizePixel = 0
    Instance.new("UICorner", enterKeyFrame).CornerRadius = UDim.new(0, 8)

    local enterKeyLabel = Instance.new("TextLabel", enterKeyFrame)
    enterKeyLabel.Size = UDim2.fromScale(1, 1)
    enterKeyLabel.BackgroundTransparency = 1
    enterKeyLabel.Text = "🔑  Enter your key to continue"
    enterKeyLabel.TextColor3 = Color3.fromRGB(80, 130, 220)
    enterKeyLabel.Font = Enum.Font.GothamBold
    enterKeyLabel.TextSize = 11

    local input = Instance.new("TextBox", rightPanel)
    input.Size = UDim2.new(0.88, 0, 0, 32)
    input.Position = UDim2.new(0.06, 0, 0, 82)
    input.BackgroundColor3 = Color3.fromRGB(18, 30, 60)
    input.TextColor3 = Color3.fromRGB(200, 210, 255)
    input.PlaceholderText = "Enter your key..."
    input.PlaceholderColor3 = Color3.fromRGB(70, 90, 140)
    input.Text = ""
    input.Font = Enum.Font.Gotham
    input.TextSize = 12
    input.BorderSizePixel = 0
    input.ClearTextOnFocus = false
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)
    local inputStroke = Instance.new("UIStroke", input)
    inputStroke.Color = Color3.fromRGB(40, 70, 150); inputStroke.Thickness = 1

    local statusLabel = Instance.new("TextLabel", rightPanel)
    statusLabel.Size = UDim2.new(1, 0, 0, 16)
    statusLabel.Position = UDim2.new(0, 0, 0, 120)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = Color3.fromRGB(200, 60, 60)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 11

    local redeemBtn = Instance.new("TextButton", rightPanel)
    redeemBtn.Size = UDim2.new(0.88, 0, 0, 34)
    redeemBtn.Position = UDim2.new(0.06, 0, 0, 140)
    redeemBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 200)
    redeemBtn.Text = "⊖  Redeem Key"
    redeemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    redeemBtn.Font = Enum.Font.GothamBold
    redeemBtn.TextSize = 13
    redeemBtn.BorderSizePixel = 0
    Instance.new("UICorner", redeemBtn).CornerRadius = UDim.new(0, 8)

    local creatorLabel = Instance.new("TextLabel", rightPanel)
    creatorLabel.Size = UDim2.new(1, 0, 0, 16)
    creatorLabel.Position = UDim2.new(0, 0, 0, 198)
    creatorLabel.BackgroundTransparency = 1
    creatorLabel.Text = "Creado por Flintz (ll1207z)"
    creatorLabel.TextColor3 = Color3.fromRGB(60, 80, 130)
    creatorLabel.Font = Enum.Font.Gotham
    creatorLabel.TextSize = 10

    local function shake()
        TweenService:Create(container, TweenInfo.new(0.05), {Position = UDim2.new(0.5, -200, 0.5, -110)}):Play() task.wait(0.05)
        TweenService:Create(container, TweenInfo.new(0.05), {Position = UDim2.new(0.5, -220, 0.5, -110)}):Play() task.wait(0.05)
        TweenService:Create(container, TweenInfo.new(0.05), {Position = UDim2.new(0.5, -210, 0.5, -110)}):Play()
    end

    redeemBtn.MouseButton1Click:Connect(function()
        local typed = input.Text
        if PASSWORDS[typed] and not usedPasswords[typed] then
            usedPasswords[typed] = true
            scriptUnlocked = true
            statusLabel.TextColor3 = Color3.fromRGB(60, 200, 60)
            statusLabel.Text = "✅ Access granted"
            task.wait(0.8)
            TweenService:Create(container, TweenInfo.new(0.4), {Position = UDim2.new(0.5, -210, 1.5, 0)}):Play()
            task.wait(0.5); gui:Destroy()
        else
            statusLabel.TextColor3 = Color3.fromRGB(200, 60, 60)
            statusLabel.Text = usedPasswords[typed] and "❌ Key already used" or "❌ Invalid key"
            task.spawn(shake)
        end
    end)
end

-------------------------------------------------------------------
--// INICIO
-------------------------------------------------------------------
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    setupDetection(humanoid)
end)

setupDetection(humanoid)
createPasswordGui()
