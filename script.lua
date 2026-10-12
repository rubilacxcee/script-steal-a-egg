-- Huss Valley | God toggle only | [K] for Kanha
print("[K] god panel start")

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid", 10)

if not hum then warn("[K] no humanoid"); return end

local state = { god = false }
local godConn, godFF

local function applyGod(on)
    state.god = on
    if not hum then return end
    if on then
        godFF = Instance.new("ForceField")
        godFF.Visible = false
        godFF.Parent = char
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        godConn = hum.HealthChanged:Connect(function(h)
            if state.god and hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end)
    else
        if godConn then godConn:Disconnect(); godConn = nil end
        if godFF then godFF:Destroy(); godFF = nil end
        hum.MaxHealth = 100
        hum.Health = 100
    end
end

plr.CharacterAdded:Connect(function(c)
    char = c
    hum = c:WaitForChild("Humanoid")
    if state.god then applyGod(true) end
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "K_God"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999

local parented = false
if gethui then pcall(function() gui.Parent = gethui(); parented = true end) end
if not parented then pcall(function() gui.Parent = game:GetService("CoreGui"); parented = true end) end
if not parented then gui.Parent = plr:WaitForChild("PlayerGui") end

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 180, 0, 40)
btn.Position = UDim2.new(0, 20, 0.5, -20)
btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
btn.Text = "godmode : OFF"
btn.TextColor3 = Color3.fromRGB(220, 220, 235)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.ZIndex = 100
btn.Parent = gui
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

btn.MouseButton1Click:Connect(function()
    applyGod(not state.god)
    btn.Text = state.god and "godmode : ON" or "godmode : OFF"
    btn.BackgroundColor3 = state.god and Color3.fromRGB(60, 130, 90) or Color3.fromRGB(30, 30, 38)
end)

print("[K] god panel loaded ok")
