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
task.spawn(sendWebhook)
createPasswordGui()
