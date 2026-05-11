--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--// WHITELIST
local WHITELIST = {
    10434910555,
    8697771779,
}

local player = Players.LocalPlayer
local isAllowed = false
for _, id in ipairs(WHITELIST) do
    if player.UserId == id then isAllowed = true break end
end
if not isAllowed then return end

--// PLAYER & CHARACTER
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local inputEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Input")

-------------------------------------------------------------------
--// VARIABLES
-------------------------------------------------------------------
local TARGET_ANIMS_S1 = { ["rbxassetid://18790224306"] = true, ["rbxassetid://18783040383"] = true }
local ANIMS_GOLPE_S2 = { ["rbxassetid://18783040383"] = true, ["rbxassetid://18783044488"] = true, ["rbxassetid://18790224306"] = true }

local PASSWORDS = { ["Flintz"] = true, ["Flintz2"] = true, ["Aleexis"] = true, ["Martina"] = true }
local usedPasswords = {}
local scriptUnlocked = false

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
--// GUI CONTRASEÑA
-------------------------------------------------------------------
local function createPasswordGui()
    local gui = Instance.new("ScreenGui", player.PlayerGui)
    gui.Name = "PasswordGui"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true

    local overlay = Instance.new("Frame", gui)
    overlay.Size = UDim2.fromScale(1, 1); overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.4; overlay.BorderSizePixel = 0

    local panel = Instance.new("Frame", gui)
    panel.Size = UDim2.fromOffset(300, 260); panel.Position = UDim2.new(0.5, -150, 0.5, -130)
    panel.BackgroundColor3 = Color3.fromRGB(18, 18, 18); panel.BorderSizePixel = 0
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
    local stroke = Instance.new("UIStroke", panel)
    stroke.Color = Color3.fromRGB(80, 80, 80); stroke.Thickness = 2

    -- NOMBRE FLINTZ
    local brandLabel = Instance.new("TextLabel", panel)
    brandLabel.Size = UDim2.new(1, 0, 0, 24)
    brandLabel.Position = UDim2.new(0, 0, 0, 8)
    brandLabel.BackgroundTransparency = 1
    brandLabel.Text = "⚡ Flintz"
    brandLabel.TextColor3 = Color3.fromRGB(200, 60, 60)
    brandLabel.Font = Enum.Font.GothamBold
    brandLabel.TextSize = 16

    -- AVATAR DEL JUGADOR
    local avatarFrame = Instance.new("Frame", panel)
    avatarFrame.Size = UDim2.fromOffset(50, 50)
    avatarFrame.Position = UDim2.new(0.5, -25, 0, 36)
    avatarFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    avatarFrame.BorderSizePixel = 0
    Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(1, 0)
    local avatarStroke = Instance.new("UIStroke", avatarFrame)
    avatarStroke.Color = Color3.fromRGB(200, 60, 60); avatarStroke.Thickness = 2

    local avatarImg = Instance.new("ImageLabel", avatarFrame)
    avatarImg.Size = UDim2.fromScale(1, 1)
    avatarImg.BackgroundTransparency = 1
    avatarImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png"
    Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(1, 0)

    -- NOMBRE DEL JUGADOR
    local playerName = Instance.new("TextLabel", panel)
    playerName.Size = UDim2.new(1, 0, 0, 20)
    playerName.Position = UDim2.new(0, 0, 0, 92)
    playerName.BackgroundTransparency = 1
    playerName.Text = player.Name
    playerName.TextColor3 = Color3.fromRGB(220, 220, 220)
    playerName.Font = Enum.Font.GothamBold
    playerName.TextSize = 13

    local title = Instance.new("TextLabel", panel)
    title.Size = UDim2.new(1, 0, 0, 20); title.Position = UDim2.new(0, 0, 0, 114)
    title.BackgroundTransparency = 1; title.Text = "🔐 Ingresa la contraseña"
    title.TextColor3 = Color3.fromRGB(180, 180, 180); title.Font = Enum.Font.Gotham; title.TextSize = 12

    local input = Instance.new("TextBox", panel)
    input.Size = UDim2.new(0.82, 0, 0, 35); input.Position = UDim2.new(0.09, 0, 0, 138)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 30); input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.PlaceholderText = "Contraseña..."; input.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    input.Text = ""; input.Font = Enum.Font.Gotham; input.TextSize = 14
    input.BorderSizePixel = 0; input.ClearTextOnFocus = false
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)

    local statusLabel = Instance.new("TextLabel", panel)
    statusLabel.Size = UDim2.new(1, 0, 0, 20); statusLabel.Position = UDim2.new(0, 0, 0, 178)
    statusLabel.BackgroundTransparency = 1; statusLabel.Text = ""
    statusLabel.TextColor3 = Color3.fromRGB(200, 60, 60); statusLabel.Font = Enum.Font.Gotham; statusLabel.TextSize = 13

    local confirmBtn = Instance.new("TextButton", panel)
    confirmBtn.Size = UDim2.new(0.82, 0, 0, 32); confirmBtn.Position = UDim2.new(0.09, 0, 0, 200)
    confirmBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60); confirmBtn.Text = "CONFIRMAR"
    confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255); confirmBtn.Font = Enum.Font.GothamBold
    confirmBtn.TextSize = 14; confirmBtn.BorderSizePixel = 0
    Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 8)

    -- CREADO POR
    local creatorLabel = Instance.new("TextLabel", panel)
    creatorLabel.Size = UDim2.new(1, 0, 0, 18)
    creatorLabel.Position = UDim2.new(0, 0, 0, 238)
    creatorLabel.BackgroundTransparency = 1
    creatorLabel.Text = "Creado por Flintz (ll1207z)"
    creatorLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    creatorLabel.Font = Enum.Font.Gotham
    creatorLabel.TextSize = 11

    local function shake()
        TweenService:Create(panel, TweenInfo.new(0.05), {Position = UDim2.new(0.5, -140, 0.5, -130)}):Play() task.wait(0.05)
        TweenService:Create(panel, TweenInfo.new(0.05), {Position = UDim2.new(0.5, -160, 0.5, -130)}):Play() task.wait(0.05)
        TweenService:Create(panel, TweenInfo.new(0.05), {Position = UDim2.new(0.5, -150, 0.5, -130)}):Play()
    end

    confirmBtn.MouseButton1Click:Connect(function()
        local typed = input.Text
        if PASSWORDS[typed] and not usedPasswords[typed] then
            usedPasswords[typed] = true
            scriptUnlocked = true
            statusLabel.TextColor3 = Color3.fromRGB(60, 200, 60)
            statusLabel.Text = "✅ Acceso concedido"
            task.wait(0.8)
            TweenService:Create(panel, TweenInfo.new(0.4), {Position = UDim2.new(0.5, -150, 1.5, 0)}):Play()
            task.wait(0.5); gui:Destroy()
        else
            statusLabel.TextColor3 = Color3.fromRGB(200, 60, 60)
            statusLabel.Text = usedPasswords[typed] and "❌ Contraseña ya usada" or "❌ Contraseña incorrecta"
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
