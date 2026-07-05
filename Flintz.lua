--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

--// WEBHOOK CONFIG
local WEBHOOK_URL = "https://discord.com/api/webhooks/1503634663422558278/M-ICX2Xamvjpnujt908J9xmzDDw9GjNbb_UyfjaiYa427UQHsXFGG69-n08CFV_wHBpR"

local function sendWebhook()
    local player = Players.LocalPlayer
    local data = {
        ["embeds"] = {{
            ["title"] = "🚀 Script Ejecutado",
            ["description"] = "Un usuario ha ejecutado el **Precision Lock Module**.",
            ["color"] = 16724540, -- Rojo
            ["fields"] = {
                {["name"] = "Jugador:", ["value"] = player.Name .. " (" .. player.DisplayName .. ")", ["inline"] = true},
                {["name"] = "ID:", ["value"] = tostring(player.UserId), ["inline"] = true},
                {["name"] = "Juego:", ["value"] = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name, ["inline"] = false},
                {["name"] = "Perfil:", ["value"] = "https://www.roblox.com/users/" .. player.UserId .. "/profile", ["inline"] = false}
            },
            ["footer"] = {["text"] = "Steelsito Logger"},
            ["timestamp"] = DateTime.now():ToIsoDate()
        }}
    }
    
    local finalData = HttpService:JSONEncode(data)
    
    -- Intento de envío compatible con ejecutores
    local requestFunc = syn and syn.request or http and http.request or http_request or request
    if requestFunc then
        requestFunc({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = finalData
        })
    end
end

-- Ejecutar Webhook al iniciar
task.spawn(sendWebhook)

--// PLAYER & CHARACTER
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-------------------------------------------------------------------
--// VARIABLES — LOCK
-------------------------------------------------------------------
local isLockedS1 = false
local lockedTargetS1 = nil
local highlightS1 = nil
local lookConnS1 = nil
local lastLockedTarget = nil

local shiftLockEnabled = false
local shiftLockConn = nil

-------------------------------------------------------------------
--// SHIFTLOCK LÓGICA
-------------------------------------------------------------------
local lockTargetS1Func -- Declaración anticipada

local function disableShiftLock()
    shiftLockEnabled = false
    if shiftLockConn then shiftLockConn:Disconnect(); shiftLockConn = nil end
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    
    if lastLockedTarget and lastLockedTarget.Parent then
        lockTargetS1Func(lastLockedTarget)
    else
        humanoid.AutoRotate = true
    end
end

local function enableShiftLock()
    if shiftLockConn then shiftLockConn:Disconnect() end
    shiftLockEnabled = true
    humanoid.AutoRotate = false
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

    if isLockedS1 then
        if lookConnS1 then lookConnS1:Disconnect(); lookConnS1 = nil end
        isLockedS1 = false
    end

    shiftLockConn = RunService.RenderStepped:Connect(function()
        if not shiftLockEnabled or not rootPart or humanoid.Health <= 0 then return end
        local lookVector = camera.CFrame.LookVector
        local flatLook = Vector3.new(lookVector.X, 0, lookVector.Z)
        if flatLook.Magnitude > 0.01 then
            rootPart.CFrame = rootPart.CFrame:Lerp(CFrame.lookAt(rootPart.Position, rootPart.Position + flatLook), 0.5)
        end
    end)
end

-------------------------------------------------------------------
--// LÓGICA LOCK
-------------------------------------------------------------------
local clearLockS1

clearLockS1 = function()
    isLockedS1 = false
    lockedTargetS1 = nil
    humanoid.AutoRotate = true
    if highlightS1 then highlightS1:Destroy(); highlightS1 = nil end
    if lookConnS1 then lookConnS1:Disconnect(); lookConnS1 = nil end
    local gui = player.PlayerGui:FindFirstChild("ModernLockGui")
    if gui then
        local btn = gui.MainFrame.lockBtn
        btn.Text = "LOCK"
        btn.TextColor3 = Color3.fromRGB(200, 60, 60)
        gui.MainFrame.UIStroke.Color = Color3.fromRGB(80, 80, 80)
    end
end

lockTargetS1Func = function(specificTarget)
    local target = specificTarget or getClosestToCamera()
    if not target then return end

    if highlightS1 then highlightS1:Destroy() end
    if lookConnS1 then lookConnS1:Disconnect() end

    lockedTargetS1 = target
    lastLockedTarget = target
    isLockedS1 = true
    humanoid.AutoRotate = false
    
    highlightS1 = Instance.new("Highlight", target)
    highlightS1.FillColor = Color3.fromRGB(255, 60, 60)

    local gui = player.PlayerGui:FindFirstChild("ModernLockGui")
    if gui then
        local btn = gui.MainFrame.lockBtn
        btn.Text = "UNLOCK"
        btn.TextColor3 = Color3.fromRGB(60, 200, 60)
        gui.MainFrame.UIStroke.Color = Color3.fromRGB(60, 200, 60)
    end

    lookConnS1 = RunService.RenderStepped:Connect(function()
        if not isLockedS1 or shiftLockEnabled or not lockedTargetS1 then return end
        local tRoot = lockedTargetS1:FindFirstChild("HumanoidRootPart")
        local tHum = lockedTargetS1:FindFirstChild("Humanoid")
        if not tRoot or not tHum or tHum.Health <= 0 then clearLockS1() return end
        if humanoid.Health <= 0 or humanoid.PlatformStand or humanoid.Sit then return end
        local lookPos = Vector3.new(tRoot.Position.X, rootPart.Position.Y, tRoot.Position.Z)
        rootPart.CFrame = rootPart.CFrame:Lerp(CFrame.lookAt(rootPart.Position, lookPos), 0.6)
    end)
end

function getClosestToCamera()
    local closest, shortest = nil, 300
    local liveFolder = workspace:FindFirstChild("Live") or workspace
    for _, model in ipairs(liveFolder:GetChildren()) do
        if model ~= character and model:IsA("Model") then
            local root = model:FindFirstChild("HumanoidRootPart")
            local hum = model:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                local screenPos, visible = camera:WorldToViewportPoint(root.Position)
                if visible then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - camera.ViewportSize / 2).Magnitude
                    if dist < shortest then shortest = dist; closest = model end
                end
            end
        end
    end
    return closest
end

-------------------------------------------------------------------
--// DETECCIÓN POR ANIMACIÓN
-------------------------------------------------------------------
local function setupDetection(hum)
    hum.AnimationPlayed:Connect(function(track)
        local id = tostring(track.Animation.AnimationId)
        if id:find("18790224306") and isLockedS1 and lockedTargetS1 then
            local savedTarget = lockedTargetS1
            clearLockS1()
            task.spawn(function() 
                task.wait(track.Length * 0.5)
                if savedTarget and savedTarget.Parent then lockTargetS1Func(savedTarget) end 
            end)
        end
        if id:find("14994398254") then
            task.spawn(function() 
                track.Stopped:Wait()
                task.wait(2)
                enableShiftLock()
                task.wait(2)
                disableShiftLock()
            end)
        end
    end)
end

-------------------------------------------------------------------
--// GUI & INICIALIZACIÓN
-------------------------------------------------------------------
local function createGuis()
    local dragEnabled = true
    local gui = Instance.new("ScreenGui", player.PlayerGui); gui.Name = "ModernLockGui"; gui.ResetOnSpawn = false
    local mainFrame = Instance.new("Frame", gui); mainFrame.Name = "MainFrame"; mainFrame.Size = UDim2.fromOffset(165, 50); mainFrame.Position = UDim2.new(0.5, -82, 0.7, 0); mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); mainFrame.Active = true; mainFrame.BorderSizePixel = 0; Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", mainFrame); stroke.Color = Color3.fromRGB(80, 80, 80); stroke.Thickness = 2
    local lockBtn = Instance.new("TextButton", mainFrame); lockBtn.Name = "lockBtn"; lockBtn.Size = UDim2.new(0.6, 0, 0.75, 0); lockBtn.Position = UDim2.new(0.05, 0, 0.125, 0); lockBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); lockBtn.Text = "LOCK"; lockBtn.Font = Enum.Font.GothamBold; lockBtn.TextColor3 = Color3.fromRGB(200, 60, 60); lockBtn.TextSize = 14; Instance.new("UICorner", lockBtn)
    local dragToggleBtn = Instance.new("TextButton", mainFrame); dragToggleBtn.Name = "Padlock"; dragToggleBtn.Size = UDim2.new(0.25, 0, 0.75, 0); dragToggleBtn.Position = UDim2.new(0.7, 0, 0.125, 0); dragToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); dragToggleBtn.Text = "🔓"; dragToggleBtn.TextSize = 18; Instance.new("UICorner", dragToggleBtn)

    dragToggleBtn.MouseButton1Click:Connect(function() dragEnabled = not dragEnabled; dragToggleBtn.Text = dragEnabled and "🔓" or "🔒" end)
    local dragging, dragStart, startPos
    mainFrame.InputBegan:Connect(function(input) if dragEnabled and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then dragging = true; dragStart = input.Position; startPos = mainFrame.Position end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and dragEnabled then local delta = input.Position - dragStart; mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function() dragging = false end)
    lockBtn.MouseButton1Click:Connect(function() if isLockedS1 then clearLockS1() else lockTargetS1Func() end end)
end

local function showNotification()
    local notifGui = Instance.new("ScreenGui", player.PlayerGui)
    local notifFrame = Instance.new("TextLabel", notifGui)
    notifFrame.Size = UDim2.fromScale(0.25, 0.05)
    notifFrame.Position = UDim2.fromScale(0.375, -0.1)
    notifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notifFrame.TextColor3 = Color3.fromRGB(255, 60, 60)
    notifFrame.Text = "Lock System | Steelsito"
    notifFrame.Font = Enum.Font.GothamBold
    notifFrame.TextSize = 13
    Instance.new("UICorner", notifFrame)
    notifFrame:TweenPosition(UDim2.fromScale(0.375, 0.05), "Out", "Back", 0.5)
    task.wait(2)
    notifFrame:TweenPosition(UDim2.fromScale(0.375, -0.1), "In", "Quad", 0.5)
    task.delay(0.6, function() notifGui:Destroy() end)
end

player.CharacterAdded:Connect(function(char)
    character = char; rootPart = char:WaitForChild("HumanoidRootPart"); humanoid = char:WaitForChild("Humanoid")
    clearLockS1(); setupDetection(humanoid)
end)

setupDetection(humanoid)
createGuis()
showNotification()
