-- Steal a Egg | Panel by [K] for Kanha
-- loadstring en LocalScript / executor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- state
local state = {
    speed = false,
    god = false,
    superJump = false,
    fly = false,
    flySpeed = 80,
    autoEgg = false,
    selectedEgg = nil,
}

-- rebuild refs on respawn
plr.CharacterAdded:Connect(function(c)
    char = c
    hrp = c:WaitForChild("HumanoidRootPart")
    hum = c:WaitForChild("Humanoid")
    if state.god then hum.MaxHealth = math.huge; hum.Health = math.huge end
    if state.speed then hum.WalkSpeed = 120 end
    if state.superJump then hum.JumpPower = 200 end
end)

--------------------------------------------------------------------
-- GUI
--------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "K_StealEgg"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = plr:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 260, 0, 400)
main.Position = UDim2.new(0, 20, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(90, 90, 110)
stroke.Thickness = 1
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32)
title.BackgroundTransparency = 1
title.Text = "  steal a egg  |  [K]"
title.TextColor3 = Color3.fromRGB(230, 230, 240)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamMedium
title.TextSize = 14
title.Parent = main

-- hide button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 34, 0, 34)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -17)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
toggleBtn.Text = "K"
toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.Visible = false
toggleBtn.Parent = gui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

-- container for buttons
local holder = Instance.new("Frame")
holder.Size = UDim2.new(1, -20, 1, -80)
holder.Position = UDim2.new(0, 10, 0, 42)
holder.BackgroundTransparency = 1
holder.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = holder

local function makeToggle(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(210, 210, 225)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = holder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.BackgroundColor3 = on and Color3.fromRGB(60, 130, 90) or Color3.fromRGB(32, 32, 40)
        callback(on)
    end)
    return btn
end

-- SPEED
makeToggle("speed hack", function(on)
    state.speed = on
    if hum then hum.WalkSpeed = on and 120 or 16 end
end)

-- GOD
makeToggle("godmode", function(on)
    state.god = on
    if hum then
        hum.MaxHealth = on and math.huge or 100
        hum.Health = on and math.huge or 100
    end
end)

-- SUPER JUMP
makeToggle("super jump", function(on)
    state.superJump = on
    if hum then hum.UseJumpPower = true; hum.JumpPower = on and 200 or 50 end
end)

-- FLY
local flyBV, flyBG
makeToggle("fly (WASD + space/ctrl)", function(on)
    state.fly = on
    if not hum or not hrp then return end
    if on then
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyBV.Velocity = Vector3.zero
        flyBV.Parent = hrp

        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        flyBG.P = 1000
        flyBG.D = 50
        flyBG.Parent = hrp

        RunService.RenderStepped:Connect(function()
            if not state.fly or not hrp or not flyBV then return end
            local cam = workspace.CurrentCamera
            local dir = Vector3.zero
            local move = hum.MoveDirection
            if move.Magnitude > 0 then
                dir = cam.CFrame:VectorToWorldSpace(move) * state.flySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                dir = dir + Vector3.new(0, state.flySpeed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                dir = dir - Vector3.new(0, state.flySpeed, 0)
            end
            flyBV.Velocity = dir
            flyBG.CFrame = cam.CFrame
        end)
    else
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
    end
end)

-- EGG SELECTOR
local eggLabel = Instance.new("TextLabel")
eggLabel.Size = UDim2.new(1, 0, 0, 26)
eggLabel.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
eggLabel.Text = "  œuf ciblé : aucun"
eggLabel.TextColor3 = Color3.fromRGB(190, 190, 210)
eggLabel.Font = Enum.Font.Gotham
eggLabel.TextSize = 12
eggLabel.TextXAlignment = Enum.TextXAlignment.Left
eggLabel.Parent = holder
Instance.new("UICorner", eggLabel).CornerRadius = UDim.new(0, 6)

local eggListBtn = Instance.new("TextButton")
eggListBtn.Size = UDim2.new(1, 0, 0, 30)
eggListBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
eggListBtn.Text = "  choisir un œuf"
eggListBtn.TextColor3 = Color3.fromRGB(220, 220, 235)
eggListBtn.Font = Enum.Font.Gotham
eggListBtn.TextSize = 13
eggListBtn.TextXAlignment = Enum.TextXAlignment.Left
eggListBtn.Parent = holder
Instance.new("UICorner", eggListBtn).CornerRadius = UDim.new(0, 6)

-- egg list popup
local eggFrame = Instance.new("ScrollingFrame")
eggFrame.Size = UDim2.new(0, 220, 0, 240)
eggFrame.Position = UDim2.new(1, 10, 0, 0)
eggFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
eggFrame.BorderSizePixel = 0
eggFrame.Visible = false
eggFrame.ScrollBarThickness = 4
eggFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
eggFrame.Parent = main
Instance.new("UICorner", eggFrame).CornerRadius = UDim.new(0, 8)

local eggLayout = Instance.new("UIListLayout")
eggLayout.Padding = UDim.new(0, 4)
eggLayout.Parent = eggFrame

local function isEgg(obj)
    local n = obj.Name:lower()
    return obj:IsA("BasePart") and (n:find("egg") or n:find("oeuf"))
end

local function collectEggs()
    local found = {}
    for _, d in ipairs(workspace:GetDescendants()) do
        if isEgg(d) then
            table.insert(found, d)
        end
    end
    return found
end

local function refreshEggList()
    for _, c in ipairs(eggFrame:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local eggs = collectEggs()
    for i, egg in ipairs(eggs) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -8, 0, 26)
        b.BackgroundColor3 = Color3.fromRGB(34, 34, 44)
        b.Text = "  " .. egg.Name
        b.TextColor3 = Color3.fromRGB(210, 210, 225)
        b.TextSize = 12
        b.Font = Enum.Font.Gotham
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.Parent = eggFrame
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        b.MouseButton1Click:Connect(function()
            state.selectedEgg = egg
            eggLabel.Text = "  œuf ciblé : " .. egg.Name
            eggFrame.Visible = false
        end)
    end
    eggFrame.CanvasSize = UDim2.new(0, 0, 0, eggLayout.AbsoluteContentSize.Y + 10)
end

eggListBtn.MouseButton1Click:Connect(function()
    eggFrame.Visible = not eggFrame.Visible
    if eggFrame.Visible then refreshEggList() end
end)

-- AUTO EGG: tp -> take -> tp back
local basePos = nil

local function pickupEgg(egg)
    if not hrp or not egg or not egg.Parent then return end
    local oldPos = hrp.CFrame
    -- tp to egg
    hrp.CFrame = CFrame.new(egg.Position + Vector3.new(0, 3, 0))
    task.wait(0.15)
    -- fire touch on all BaseParts of the egg to trigger pickup
    for _, p in ipairs(egg:GetDescendants()) do
        if p:IsA("BasePart") then
            firetouchinterest(hrp, p, 0)
            firetouchinterest(hrp, p, 1)
        end
    end
    if egg:IsA("BasePart") then
        firetouchinterest(hrp, egg, 0)
        firetouchinterest(hrp, egg, 1)
    end
    task.wait(0.15)
    -- tp back to base (saved position or spawn)
    if basePos then
        hrp.CFrame = basePos
    else
        local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
        if spawn then hrp.CFrame = spawn.CFrame + Vector3.new(0, 5, 0) end
    end
end

local function grabEggByName(name)
    for _, d in ipairs(workspace:GetDescendants()) do
        if isEgg(d) and d.Name == name then
            pickupEgg(d)
            return true
        end
    end
    return false
end

makeToggle("auto pick œuf ciblé (loop)", function(on)
    state.autoEgg = on
end)

task.spawn(function()
    while true do
        task.wait(0.4)
        if state.autoEgg and state.selectedEgg then
            if state.selectedEgg.Parent then
                pickupEgg(state.selectedEgg)
            else
                grabEggByName(state.selectedEgg.Name)
            end
        end
    end
end)

-- save base when you press B (or just before teleport)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.B then
        if hrp then basePos = hrp.CFrame end
        eggLabel.Text = "  base enregistrée ✓"
        task.wait(1)
        eggLabel.Text = state.selectedEgg and ("  œuf ciblé : " .. state.selectedEgg.Name) or "  œuf ciblé : aucun"
    end
    if input.KeyCode == Enum.KeyCode.RightShift then
        main.Visible = not main.Visible
        toggleBtn.Visible = not main.Visible
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    main.Visible = true
    toggleBtn.Visible = false
end)
