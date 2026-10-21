-- ============================================================
-- GUESS THE COUNTRY - AUTO LOCK (v2 corrigée)
-- ============================================================

local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local CoreGui            = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

-- ============================================================
-- STATE
-- ============================================================

local state = {
    enabled          = true,
    autoClick        = true,
    lockCamera       = true,
    tweenSpeed       = 0.4,
    currentCountry   = "",
    lastRoundCountry = "",
    lockedPart       = nil,
}

-- ============================================================
-- UTILS
-- ============================================================

local function normalizeName(s)
    if not s or type(s) ~= "string" then return "" end
    return s:lower():gsub("[^%a]", "")
end

local function looksLikeCountry(str)
    if not str or type(str) ~= "string" then return false end
    local clean = str:lower():gsub("[^%a%s%-]", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if #clean < 3 or #clean > 40 then return false end
    local banned = { "score","timer","round","wait","km","player","you","skip","guess","correct","wrong","points","time" }
    for _, b in ipairs(banned) do
        if clean:find(b, 1, true) then return false end
    end
    if clean:find("it was", 1, true) then return false end
    if clean:find("the country", 1, true) then return false end
    return true
end

-- ============================================================
-- GUI
-- ============================================================

local oldGui = CoreGui:FindFirstChild("GTC_AutoLock")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GTC_AutoLock"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 300, 0, 400)
Main.Position = UDim2.new(1, -320, 0, 20)
Main.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
Main.BorderSizePixel = 0
Main.Active = true
Main.ClipsDescendants = false
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(0, 200, 81)
Stroke.Thickness = 1
Stroke.Transparency = 0.5
Stroke.Parent = Main

-- ------------------------------------------------------------
-- TITLE BAR
-- ------------------------------------------------------------

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Active = true
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🌍 GUESS THE COUNTRY"
Title.TextColor3 = Color3.fromRGB(0, 255, 136)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 26, 0, 26)
MinBtn.Position = UDim2.new(1, -60, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 44, 54)
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.BorderSizePixel = 0
MinBtn.AutoButtonColor = false
MinBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- ------------------------------------------------------------
-- DRAG (manual, plus fiable que Draggable)
-- ------------------------------------------------------------

local dragging = false
local dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ------------------------------------------------------------
-- CONTENT
-- ------------------------------------------------------------

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 1, -36)
Content.Position = UDim2.new(0, 0, 0, 36)
Content.BackgroundTransparency = 1
Content.Parent = Main

local function makeLabel(parent, text, y, height, color, bold)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -24, 0, height or 22)
    lbl.Position = UDim2.new(0, 12, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(200, 200, 210)
    lbl.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function makeToggle(parent, y, name, initial, onChange)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 30)
    btn.Position = UDim2.new(0, 12, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(30, 33, 42)
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -70, 1, 0)
    nameLbl.Position = UDim2.new(0, 12, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.TextColor3 = Color3.fromRGB(220, 220, 230)
    nameLbl.Font = Enum.Font.Gotham
    nameLbl.TextSize = 13
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = btn

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 36, 0, 20)
    dot.Position = UDim2.new(1, -50, 0.5, -10)
    dot.BackgroundColor3 = initial and Color3.fromRGB(0, 200, 81) or Color3.fromRGB(60, 60, 70)
    dot.BorderSizePixel = 0
    dot.Parent = btn

    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(1, 0)
    dc.Parent = dot

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = initial and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = dot

    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob

    local value = initial

    local function update()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        TweenService:Create(dot, TweenInfo.new(0.15), {
            BackgroundColor3 = value and Color3.fromRGB(0, 200, 81) or Color3.fromRGB(60, 60, 70)
        }):Play()
    end

    btn.MouseButton1Click:Connect(function()
        value = not value
        update()
        if onChange then onChange(value) end
    end)

    return btn
end

local function makeButton(parent, text, y, color, onClick)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 32)
    btn.Position = UDim2.new(0, 12, 0, y)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(10, 10, 15)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn

    btn.MouseButton1Click:Connect(onClick)
    return btn
end

-- Status / Target labels
local StatusLbl = makeLabel(Content, "Statut : en attente", 12, 20, Color3.fromRGB(150, 150, 160), false)
local TargetLbl = makeLabel(Content, "Pays : --",         34, 26, Color3.fromRGB(0, 212, 255), true)

-- Log box (créé AVANT les fonctions qui l'utilisent)
local LogFrame = Instance.new("Frame")
LogFrame.Size = UDim2.new(1, -24, 0, 110)
LogFrame.Position = UDim2.new(0, 12, 0, 262)
LogFrame.BackgroundColor3 = Color3.fromRGB(8, 9, 13)
LogFrame.BorderSizePixel = 0
LogFrame.Parent = Content

local lfc = Instance.new("UICorner")
lfc.CornerRadius = UDim.new(0, 6)
lfc.Parent = LogFrame

local lfs = Instance.new("UIStroke")
lfs.Color = Color3.fromRGB(0, 200, 81)
lfs.Thickness = 1
lfs.Transparency = 0.7
lfs.Parent = LogFrame

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -8, 1, -8)
LogScroll.Position = UDim2.new(0, 4, 0, 4)
LogScroll.BackgroundTransparency = 1
LogScroll.BorderSizePixel = 0
LogScroll.ScrollBarThickness = 4
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.Parent = LogFrame

local LogLayout = Instance.new("UIListLayout")
LogLayout.Padding = UDim.new(0, 2)
LogLayout.SortOrder = Enum.SortOrder.LayoutOrder
LogLayout.Parent = LogScroll

local _logOrder = 0
local _logLines = {}

local function LogLine(msg, color)
    _logOrder = _logOrder + 1
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 14)
    lbl.BackgroundTransparency = 1
    lbl.Text = "• " .. tostring(msg)
    lbl.TextColor3 = color or Color3.fromRGB(180, 180, 190)
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = _logOrder
    lbl.Parent = LogScroll

    table.insert(_logLines, lbl)
    if #_logLines > 60 then
        if _logLines[1] then _logLines[1]:Destroy() end
        table.remove(_logLines, 1)
    end

    task.defer(function()
        pcall(function()
            LogScroll.CanvasPosition = Vector2.new(0, LogLayout.AbsoluteContentSize.Y)
        end)
    end)
end

-- wrapper public
local function log(msg, color)
    pcall(function() LogLine(msg, color) end)
    pcall(function() print("[GTC]", msg) end)
end

-- Toggles
makeToggle(Content, 70,  "Activer le script", true,  function(v) state.enabled    = v; log("Script "      .. (v and "activé" or "désactivé")) end)
makeToggle(Content, 106, "Lock caméra",        true,  function(v) state.lockCamera = v; log("Lock caméra " .. (v and "activé" or "désactivé")) end)
makeToggle(Content, 142, "Auto-click",         true,  function(v) state.autoClick  = v; log("Auto-click "  .. (v and "activé" or "désactivé")) end)

-- Actions
makeButton(Content, "🔍 RESCAN MAINTENANT", 184, Color3.fromRGB(88, 101, 242), function()
    local c = getTargetCountry()
    if c then
        state.lastRoundCountry = ""
        log("Rescan lancé, pays trouvé : " .. c)
    else
        log("Rescan : aucun pays détecté", Color3.fromRGB(255, 90, 90))
    end
end)

makeButton(Content, "🎥 UNLOCK CAMÉRA (F5)", 222, Color3.fromRGB(120, 120, 130), function()
    Camera.CameraType = Enum.CameraType.Custom
    StatusLbl.Text = "Statut : caméra libre"
    StatusLbl.TextColor3 = Color3.fromRGB(200, 200, 210)
    log("Caméra libérée")
end)

-- Minimize / Close
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Content.Visible = not minimized
    Main.Size = minimized and UDim2.new(0, 300, 0, 36) or UDim2.new(0, 300, 0, 400)
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ============================================================
-- DÉTECTION DU PAYS
-- ============================================================

local function getTargetCountryFromGui()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end

    local best, bestWeight = nil, -1

    for _, obj in ipairs(playerGui:GetDescendants()) do
        local txt = nil
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            txt = obj.Text
        elseif obj:IsA("StringValue") then
            txt = obj.Value
        end

        if txt and looksLikeCountry(txt) then
            local weight = 0
            if txt == txt:upper() then weight = weight + 2 end
            if obj.Parent then
                local pn = obj.Parent.Name:lower()
                if pn:find("country") then weight = weight + 5 end
                if pn:find("target")  then weight = weight + 5 end
                if pn:find("guess")   then weight = weight + 3 end
            end
            if weight > bestWeight then
                bestWeight = weight
                best = txt
            end
        end
    end

    return best
end

local function getTargetCountryFromRS()
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("StringValue") and obj.Name:lower():find("country") then
            return obj.Value
        end
    end
    return nil
end

local function getTargetCountry()
    return getTargetCountryFromGui() or getTargetCountryFromRS()
end

-- ============================================================
-- RECHERCHE DU PART DU PAYS
-- ============================================================

local function findCountryPart(countryName)
    if not countryName then return nil end
    local target = normalizeName(countryName)
    if #target < 3 then return nil end

    local bestPart, bestScore = nil, 0

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("ClickDetector") or obj:IsA("Model") then
            local n = normalizeName(obj.Name)
            if n ~= "" then
                if n == target then
                    local score = 110
                    if obj:IsA("BasePart") then score = score + 10 end
                    if score > bestScore then
                        bestScore = score
                        bestPart = obj
                    end
                elseif n:find(target, 1, true) or target:find(n, 1, true) then
                    local score = 50 - math.abs(#n - #target)
                    if obj:IsA("BasePart") then score = score + 10 end
                    if score > bestScore then
                        bestScore = score
                        bestPart = obj
                    end
                end
            end
        end
    end

    return bestPart
end

-- ============================================================
-- LOCK CAMÉRA / AUTO CLICK
-- ============================================================

local function getPartPosition(part)
    if part:IsA("BasePart") then
        return part.Position
    elseif part:IsA("Model") then
        local ok, cf = pcall(function() return part:GetPivot() end)
        if ok and cf then return cf.Position end
    elseif part:IsA("ClickDetector") and part.Parent then
        return getPartPosition(part.Parent)
    end
    return nil
end

local function lockCameraOn(part)
    if not part or not state.lockCamera then return end
    local pos = getPartPosition(part)
    if not pos then return end

    local lookAt = CFrame.new(pos + Vector3.new(0, 60, 0), pos)
    Camera.CameraType = Enum.CameraType.Scriptable
    TweenService:Create(Camera, TweenInfo.new(state.tweenSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = lookAt }):Play()

    StatusLbl.Text = "Statut : lock sur " .. part.Name
    StatusLbl.TextColor3 = Color3.fromRGB(0, 255, 136)
    log("Caméra lock → " .. part.Name, Color3.fromRGB(0, 255, 136))
end

local function tryAutoClick(part)
    if not part or not state.autoClick then return end

    local cd = part:FindFirstChildWhichIsA("ClickDetector")
    if not cd and part:IsA("ClickDetector") then cd = part end
    if cd then
        pcall(function() fireclickdetector(cd) end)
        log("ClickDetector fire → " .. cd.Parent.Name, Color3.fromRGB(0, 212, 255))
        return
    end

    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local n = obj.Name:lower()
            if n:find("click") or n:find("guess") or n:find("country") or n:find("select") or n:find("answer") then
                pcall(function() obj:FireServer(part.Name, part) end)
                log("RemoteEvent fire → " .. obj.Name, Color3.fromRGB(0, 212, 255))
                return
            end
        end
    end
end

-- ============================================================
-- BOUCLE PRINCIPALE
-- ============================================================

RunService.RenderStepped:Connect(function()
    if not state.enabled then return end

    local country = getTargetCountry()
    if not country then return end

    if country ~= state.lastRoundCountry then
        state.lastRoundCountry = country
        state.currentCountry = country

        TargetLbl.Text = "Pays : " .. tostring(country):upper()
        StatusLbl.Text = "Statut : recherche..."
        StatusLbl.TextColor3 = Color3.fromRGB(200, 200, 210)
        log("Nouveau pays : " .. tostring(country):upper(), Color3.fromRGB(0, 212, 255))

        local part = findCountryPart(country)
        if part then
            state.lockedPart = part
            lockCameraOn(part)
            task.wait(0.3)
            tryAutoClick(part)
        else
            StatusLbl.Text = "Statut : part introuvable"
            StatusLbl.TextColor3 = Color3.fromRGB(255, 90, 90)
            log("Part introuvable pour " .. tostring(country), Color3.fromRGB(255, 90, 90))
        end
    end
end)

-- ============================================================
-- HOTKEYS
-- ============================================================

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.F4 then
        local country = state.currentCountry ~= "" and state.currentCountry or getTargetCountry()
        if country then
            local part = findCountryPart(country)
            if part then
                lockCameraOn(part)
                tryAutoClick(part)
            else
                log("F4 : part introuvable pour " .. tostring(country), Color3.fromRGB(255, 90, 90))
            end
        end
    elseif input.KeyCode == Enum.KeyCode.F5 then
        Camera.CameraType = Enum.CameraType.Custom
        StatusLbl.Text = "Statut : caméra libre"
        StatusLbl.TextColor3 = Color3.fromRGB(200, 200, 210)
        log("F5 : caméra libérée")
    end
end)

-- ============================================================
-- INIT
-- ============================================================

log("Script initialisé", Color3.fromRGB(0, 255, 136))
log("F4 = lock manuel | F5 = unlock", Color3.fromRGB(150, 150, 160))
StatusLbl.Text = "Statut : actif"
StatusLbl.TextColor3 = Color3.fromRGB(0, 255, 136)
