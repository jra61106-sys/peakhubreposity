


local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local LP = player
local playerGui = player:WaitForChild("PlayerGui")

local COLORS = {
    Background = Color3.fromRGB(0, 0, 0),
    Row = Color3.fromRGB(0, 0, 0),
    RowDark = Color3.fromRGB(0, 0, 0),
    Badge = Color3.fromRGB(0, 0, 0),
    TabBar = Color3.fromRGB(0, 0, 0),
    TabActive = Color3.fromRGB(255, 120, 0),
    ToggleActive = Color3.fromRGB(255, 120, 0),
    White = Color3.fromRGB(255, 255, 255),
    PurpleText = Color3.fromRGB(255, 120, 0),
    TextDim = Color3.fromRGB(255, 120, 0),
    Stroke = Color3.fromRGB(255, 120, 0),
    Accent = Color3.fromRGB(255, 120, 0),
    AccentSoft = Color3.fromRGB(100, 35, 0),
    Success = Color3.fromRGB(255, 120, 0),
    Red = Color3.fromRGB(255, 120, 0),
    Blue = Color3.fromRGB(255, 120, 0),
    Purple = Color3.fromRGB(100, 35, 0),
}

local State = {
    autoLeftEnabled = false,
    autoRightEnabled = false,
    autoBatToggled = false,
    hittingCooldown = false,
}

local dropActive = false
local mobBtnRefs = {}


local carrySpeedEnabled = false
local laggerModeEnabled = false
local laggerSpeedEnabled = false
local laggerCarryEnabled = false
local autoCarryBoost = false

local Config = {
    NormalSpeed = 59.5,
    CarrySpeed = 29,
    AutoCarrySpeed = false,
    CarrySpeedKey = "C",
    LaggerSpeed = 40,
    LaggerCarry = 20,
    LaggerCarryKey = "X",
    TPDownKey = "E",
    DropKey = "F",
    InstaResetKey = "G",
    TPDownGamepadKey = "ButtonY",
    DropGamepadKey = "ButtonX",
    InstaResetGamepadKey = "ButtonB",
    TPDownDistance = 10,
    AutoTPDown = false,
    TPDownHeight = 20,
    AutoLeft = false,
    AutoLeftKey = "A",
    AutoRight = false,
    AutoRightKey = "D",
    InfiniteJump = false,
    InfJumpMode = "Hold",
    AntiRagdoll = false,
    BatCounter = false,
    MedusaCounter = false,
    AntiDie = false,
    SafeMode = false,
    UIScale = 50,
    LockUI = false,
    HideUI = false,
    HideUIKey = "RightControl",
    MobileButtonSize = 50,
    StealBarSize = 50,
    UIBackgroundIndex = 1,
    CircleButtons = false,
    IntroEnabled = true,
    UIBackgroundUrl = "https://files.catbox.moe/sz7icy.png",
    PlayerESP = false,
    PlayerTracers = false,
    RagdollCountdown = false,
    CustomSky = false,
    CustomSkyTheme = "Night",
    CustomAnim = false,
    Unwalk = false,
    AnimPack = "Bubbly",
    BatSkin = "Katana",
    AntiLag = false,
    StretchRes = false,
    FOVChange = false,
    FOVValue = 70,
    BatAimbot = false,
    BatAimbotKey = "H",
    AimbotSpeed = 58,
    AutoSwing = true,
    MirrorTPDown = false,
    NoCamCollision = true,
    AutoSteal = false,
    AutoStealMode = "Normal",
    AutoStealVersion = "V1",
    AutoStealStopAt = 75,
    AutoStealStopWhenHit = false,
    AutoStealHitPauseSeconds = 1.3,
    AutoStealRadius = 61,
    AutoStealRadiusNormal = 61,
    AutoStealRadiusSemi = 9,
    StealBarPosX = nil,
    StealBarPosY = nil,
}

local CONFIG_FILE = "VyzeCC2_Config.json"

function saveConfig()
    pcall(function()
        if writefile then
            writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
        end
    end)
end

function loadConfig()


Config.UIBackgroundUrl = "https://files.catbox.moe/sz7icy.png"
    pcall(function()
        if readfile and isfile and isfile(CONFIG_FILE) then
            local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
            for k, v in pairs(data) do
                if Config[k] ~= nil then
                    Config[k] = v
                end
            end
        end
    end)
end

loadConfig()


Config.UIBackgroundUrl = "https://files.catbox.moe/sz7icy.png"


local DEFAULT_KEYS = {
    CarrySpeedKey="C",
    LaggerCarryKey="X",
    TPDownKey="E",
    DropKey="F",
    InstaResetKey="G",
    TPDownGamepadKey="ButtonY",
    DropGamepadKey="ButtonX",
    InstaResetGamepadKey="ButtonB",
    AutoLeftKey="A",
    AutoRightKey="D",
    BatAimbotKey="H",
    HideUIKey="RightControl",
}
for k, v in pairs(DEFAULT_KEYS) do
    if type(Config[k]) ~= "string" or Config[k] == "" then Config[k] = v end
end
Config.NoCamCollision = true
State.autoBatToggled = Config.BatAimbot

function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

function stroke(parent, thickness, color, transparency)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness or 1
    s.Color = color or COLORS.Stroke
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

function padding(parent, l, r, t, b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, l)
    p.PaddingRight = UDim.new(0, r)
    p.PaddingTop = UDim.new(0, t)
    p.PaddingBottom = UDim.new(0, b)
    p.Parent = parent
    return p
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EspoHubUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 340, 0, 545)
main.Position = UDim2.new(0, 24, 0.22, -200)
main.BackgroundColor3 = COLORS.Background
main.BackgroundTransparency = 1
main.BorderSizePixel = 0
main.Active = false
main.Draggable = true
main.Parent = screenGui
corner(main, 14)
stroke(main, 1, COLORS.Stroke, 0.25)



main.BackgroundTransparency = 1
main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

local uiBgImage = Instance.new("ImageLabel")
uiBgImage.Name = "UIBackground"
uiBgImage.Size = UDim2.new(1, 0, 1, 0)
uiBgImage.Position = UDim2.new(0, 0, 0, 0)
uiBgImage.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
uiBgImage.BackgroundTransparency = 0
uiBgImage.BorderSizePixel = 0
uiBgImage.Image = ""
uiBgImage.ScaleType = Enum.ScaleType.Crop
uiBgImage.ImageTransparency = 0
uiBgImage.ZIndex = 0
uiBgImage.Active = false
uiBgImage.Selectable = false
uiBgImage.Visible = true
uiBgImage.Parent = main
corner(uiBgImage, 14)

local uiBgDim = Instance.new("Frame")
uiBgDim.Name = "UIBackgroundDim"
uiBgDim.Size = UDim2.new(1, 0, 1, 0)
uiBgDim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
uiBgDim.BackgroundTransparency = 0.94
uiBgDim.BorderSizePixel = 0
uiBgDim.ZIndex = 1
uiBgDim.Active = false
uiBgDim.Selectable = false
uiBgDim.Parent = main
corner(uiBgDim, 14)

local BG_DEFAULT_URL = "https://files.catbox.moe/sz7icy.png"

local function backgroundCacheFile(url)
    return "PeakHub_UI_BG_" .. tostring(url):match("([^/]+)$"):gsub("[^%w%.%-_]", "_")
end

local function cachedBackgroundAsset(url)
    local file = backgroundCacheFile(url)
    if not (isfile and isfile(file)) then return nil end
    local id
    pcall(function()
        if getcustomasset then
            id = getcustomasset(file)
        elseif getsynasset then
            id = getsynasset(file)
        end
    end)
    return id
end

local function applyUIBackground(url)
    url = tostring(url or BG_DEFAULT_URL):gsub("^%s+", ""):gsub("%s+$", "")
    if url == "" then url = BG_DEFAULT_URL end
    local lower = string.lower(url)
    local isRobloxAsset = lower:match("^rbxassetid://%d+$") ~= nil
    if not isRobloxAsset and not (lower:sub(1, 8) == "https://" or lower:sub(1, 7) == "http://") then
        url = BG_DEFAULT_URL
    end
    Config.UIBackgroundUrl = url

    local function setImage(imageId)
        if not imageId then
            uiBgImage.Image = ""
            uiBgImage.Visible = true
            uiBgImage.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            uiBgImage.BackgroundTransparency = 0
            main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            main.BackgroundTransparency = 0
            return
        end
        uiBgImage.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        uiBgImage.BackgroundTransparency = 0
        uiBgImage.Image = imageId
        uiBgImage.Visible = true
        main.BackgroundTransparency = 1
    end

    if isRobloxAsset then
        setImage(url)
        return
    end

    -- Use the on-disk asset immediately when available. Otherwise show the URL right away
    -- while the local copy downloads, instead of waiting for the HTTP request to finish.
    local cached = cachedBackgroundAsset(url)
    if cached then
        setImage(cached)
        return
    end
    setImage(url)

    task.spawn(function()
        local data
        pcall(function() data = game:HttpGet(url) end)
        if not data or #data < 100 then
            pcall(function()
                local req = request or http_request or (syn and syn.request)
                if not req then return end
                local res = req({Url = url, Method = "GET"})
                if res then data = res.Body or res.body end
            end)
        end
        if data and #data > 100 and writefile then
            local file = backgroundCacheFile(url)
            pcall(function() writefile(file, data) end)
            local asset = cachedBackgroundAsset(url)
            -- Do not let a slow download for an older selection replace the current image.
            if asset and Config.UIBackgroundUrl == url then
                setImage(asset)
            end
        end
    end)
end

_G.VyzeApplyUIBackground = applyUIBackground
applyUIBackground(Config.UIBackgroundUrl or BG_DEFAULT_URL)


local uiScaleObj = Instance.new("UIScale")
local function getTargetUIScale()
    return math.clamp((tonumber(Config.UIScale) or 50) / 50, 0.2, 2)
end
uiScaleObj.Scale = getTargetUIScale() * 0.88
uiScaleObj.Parent = main

function applyUIScale(val)
    Config.UIScale = math.clamp(tonumber(val) or 50, 10, 100)
    local target = getTargetUIScale()
    TweenService:Create(uiScaleObj, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Scale = target
    }):Play()
end


task.defer(function()
    local target = getTargetUIScale()

    main.BackgroundTransparency = 1
    TweenService:Create(uiScaleObj, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Scale = target
    }):Play()
end)



local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 12)
header.BackgroundTransparency = 1
header.ZIndex = 2
header.Parent = main


local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -38, 0, 13)
minimizeButton.BackgroundColor3 = COLORS.Row
minimizeButton.BackgroundTransparency = 0.05
minimizeButton.BorderSizePixel = 0
minimizeButton.Text = "-"
minimizeButton.TextColor3 = COLORS.White
minimizeButton.TextSize = 20
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.AutoButtonColor = false
minimizeButton.Parent = header
corner(minimizeButton, 9)
stroke(minimizeButton, 1, COLORS.Stroke, 0.35)


local miniRestoreButton = Instance.new("ImageButton")
miniRestoreButton.Name = "MiniRestoreButton"
miniRestoreButton.Size = UDim2.new(0, 112, 0, 42)
miniRestoreButton.Position = UDim2.fromOffset(12, 12)
miniRestoreButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
miniRestoreButton.BackgroundTransparency = 0
miniRestoreButton.BorderSizePixel = 0
miniRestoreButton.Image = ""
miniRestoreButton.ScaleType = Enum.ScaleType.Fit
miniRestoreButton.ImageTransparency = 0
miniRestoreButton.AutoButtonColor = false
miniRestoreButton.Visible = false
miniRestoreButton.Parent = screenGui
corner(miniRestoreButton, 9)
stroke(miniRestoreButton, 2, Color3.fromRGB(255, 120, 0), 0)


local MINI_LOGO_URL = "https://files.catbox.moe/k9osuj.png"
local MINI_LOGO_FILE = "PeakHub_Mini_Restore_Logo.png"
task.spawn(function()
    local assetId = nil
    pcall(function()
        if isfile and isfile(MINI_LOGO_FILE) then
            if getcustomasset then
                assetId = getcustomasset(MINI_LOGO_FILE)
            elseif getsynasset then
                assetId = getsynasset(MINI_LOGO_FILE)
            end
        end
    end)
    if not assetId then
        local data = nil
        pcall(function() data = game:HttpGet(MINI_LOGO_URL) end)
        if not data or #data < 100 then
            pcall(function()
                local req = request or http_request or (syn and syn.request)
                if req then
                    local res = req({Url = MINI_LOGO_URL, Method = "GET"})
                    if res then data = res.Body or res.body end
                end
            end)
        end
        if data and #data > 100 and writefile then
            pcall(function() writefile(MINI_LOGO_FILE, data) end)
            pcall(function()
                if getcustomasset then
                    assetId = getcustomasset(MINI_LOGO_FILE)
                elseif getsynasset then
                    assetId = getsynasset(MINI_LOGO_FILE)
                end
            end)
        end
    end
    if assetId then
        miniRestoreButton.Image = assetId
    end
end)

local uiMinimized = false
local miniDragging = false
local miniDragged = false
local miniDragStart = nil
local miniStartPos = nil

function showMiniOnly()
    uiMinimized = true
    Config.HideUI = true
    local curScale = uiScaleObj and uiScaleObj.Scale or 1
    if uiScaleObj then
        TweenService:Create(uiScaleObj, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Scale = curScale * 0.92
        }):Play()
    end
    TweenService:Create(main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1,
    }):Play()
    task.delay(0.18, function()
        main.Visible = false
        main.BackgroundTransparency = 1
        if uiScaleObj then
            uiScaleObj.Scale = math.clamp((tonumber(Config.UIScale) or 50) / 50, 0.2, 2)
        end
        miniRestoreButton.Visible = true
        miniRestoreButton.BackgroundTransparency = 1
        TweenService:Create(miniRestoreButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.05,
        }):Play()
    end)
end

function restoreFromMini()
    uiMinimized = false
    Config.HideUI = false
    miniRestoreButton.Visible = false
    main.Visible = true
    main.Size = UDim2.new(0, 340, 0, 545)
    main.BackgroundTransparency = 1
    local targetScale = math.clamp((tonumber(Config.UIScale) or 50) / 50, 0.2, 2)
    if uiScaleObj then
        uiScaleObj.Scale = targetScale * 0.9
        TweenService:Create(uiScaleObj, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Scale = targetScale
        }):Play()
    end
    main.BackgroundTransparency = 1
    saveConfig()
end

minimizeButton.MouseButton1Click:Connect(function()
    showMiniOnly()
end)

miniRestoreButton.Active = true
miniRestoreButton.Selectable = true
miniRestoreButton.MouseButton1Click:Connect(function()
    if miniDragged then
        miniDragged = false
        return
    end
    restoreFromMini()
end)


miniRestoreButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        miniDragging = true
        miniDragged = false
        miniDragStart = input.Position
        miniStartPos = miniRestoreButton.Position
    end
end)

miniRestoreButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        miniDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not miniDragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    if not miniDragStart or not miniStartPos then return end

    local delta = input.Position - miniDragStart
    if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then
        miniDragged = true
    end

    local cam = workspace.CurrentCamera
    local viewport = cam and cam.ViewportSize or Vector2.new(1920, 1080)
    local size = miniRestoreButton.AbsoluteSize
    local x = math.clamp(miniStartPos.X.Offset + delta.X, 0, math.max(0, viewport.X - size.X))
    local y = math.clamp(miniStartPos.Y.Offset + delta.Y, 0, math.max(0, viewport.Y - size.Y))
    miniRestoreButton.Position = UDim2.fromOffset(x, y)
end)

function syncMiniState()
    if uiMinimized or Config.HideUI then
        main.Visible = false
        miniRestoreButton.Visible = true
    else
        main.Visible = true
        miniRestoreButton.Visible = false
    end
end

local movingLine = Instance.new("Frame")
movingLine.Name = "MovingLine"
movingLine.Size = UDim2.new(0, 90, 1, 0)
movingLine.Position = UDim2.new(0, -90, 0, 0)
movingLine.BackgroundColor3 = COLORS.TabActive
movingLine.BorderSizePixel = 0
movingLine.Parent = lineTrack
corner(movingLine, 1)

local lineGrad = Instance.new("UIGradient")
lineGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0.3),
    NumberSequenceKeypoint.new(1, 0),
})
lineGrad.Parent = movingLine

task.spawn(function()
    local speed = 150
    local x = -90
    RunService.RenderStepped:Connect(function(dt)
        x = x + speed * dt
        local trackWidth = lineTrack.AbsoluteSize.X
        if x > trackWidth then
            x = -90
        end
        movingLine.Position = UDim2.new(0, x, 0, 0)
    end)
end)

local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, -32, 0, 48)
tabBar.Position = UDim2.new(0, 16, 1, -64)
tabBar.BackgroundColor3 = COLORS.TabBar
tabBar.BackgroundTransparency = 0.25
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 2
tabBar.Parent = main
corner(tabBar, 10)
stroke(tabBar, 1, COLORS.Stroke, 0.3)
padding(tabBar, 5, 5, 5, 5)

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 4)
tabLayout.Parent = tabBar

local content = Instance.new("ScrollingFrame")
content.Name = "Content"
content.Size = UDim2.new(1, -32, 1, -244)
content.Position = UDim2.new(0, 16, 0, 172)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = COLORS.Badge
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.ZIndex = 2
content.Parent = main

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 10)
listLayout.Parent = content

local order = 0
function nextOrder()
    order = order + 1
    return order
end

function sectionLabel(parent, text)
    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(1, 0, 0, 22)
    wrap.BackgroundTransparency = 1
    wrap.LayoutOrder = nextOrder()
    wrap.ClipsDescendants = true
    wrap.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Text = string.upper(text)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = wrap


    local shine = Instance.new("Frame")
    shine.Size = UDim2.new(0, 48, 1, 0)
    shine.Position = UDim2.new(0, -60, 0, 0)
    shine.BackgroundColor3 = COLORS.White
    shine.BackgroundTransparency = 0.92
    shine.BorderSizePixel = 0
    shine.ZIndex = 2
    shine.Parent = wrap
    local g = Instance.new("UIGradient")
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.35),
        NumberSequenceKeypoint.new(1, 1),
    })
    g.Parent = shine
    task.spawn(function()
        while wrap.Parent do
            shine.Position = UDim2.new(0, -60, 0, 0)
            local tw = TweenService:Create(shine, TweenInfo.new(2.8, Enum.EasingStyle.Linear), {
                Position = UDim2.new(1, 20, 0, 0)
            })
            tw:Play()
            tw.Completed:Wait()
            task.wait(3.5)
        end
    end)
    return lbl
end

function rowBase(parent, labelText, accent)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = COLORS.Row
    row.BackgroundTransparency = 0.4
    row.BorderSizePixel = 0
    row.LayoutOrder = nextOrder()
    row.Parent = parent
    corner(row, 10)
    local rowStroke = stroke(row, 1.2, COLORS.Stroke, 0.45)
    rowStroke.Name = "RowStroke"

    local lbl = Instance.new("TextLabel")
    lbl.Text = labelText
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(0.55, 0, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    row:SetAttribute("GlowOn", false)
    row.MouseEnter:Connect(function()
        if row:GetAttribute("GlowOn") then return end
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(100, 35, 0)}):Play()
        TweenService:Create(rowStroke, TweenInfo.new(0.12), {Transparency = 0.15}):Play()
    end)
    row.MouseLeave:Connect(function()
        if row:GetAttribute("GlowOn") then return end
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.Row}):Play()
        TweenService:Create(rowStroke, TweenInfo.new(0.15), {Transparency = 0.45}):Play()
    end)

    return row
end

local function setRowGlow(row, enabled)
    if not row then return end
    row:SetAttribute("GlowOn", enabled == true)
    local st = row:FindFirstChild("RowStroke") or row:FindFirstChildOfClass("UIStroke")
    if not st then return end
    local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    if enabled then
        TweenService:Create(st, info, {
            Transparency = 0,
            Thickness = 3,
            Color = Color3.fromRGB(255, 120, 0),
        }):Play()
        TweenService:Create(row, info, {
            BackgroundColor3 = Color3.fromRGB(100, 35, 0),
            BackgroundTransparency = 0.08,
        }):Play()
    else
        TweenService:Create(st, info, {
            Transparency = 0.45,
            Thickness = 1.2,
            Color = COLORS.Stroke,
        }):Play()
        TweenService:Create(row, info, {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.4,
        }):Play()
    end
end

local keybindCaptureActive = false

function keybindDisplay(v)
    v = tostring(v or "")
    if v == "" or v == "None" or v == "NONE" then return "None" end
    return v
end

function keybindBadge(parent, initialText, offsetX, width, onKeyChanged)
    local btn = Instance.new("TextButton")
    btn.Text = keybindDisplay(initialText)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.TextColor3 = COLORS.White
    btn.BackgroundColor3 = COLORS.Badge
    btn.BackgroundTransparency = 0.35
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(0, width or 48, 0, 24)
    btn.Position = UDim2.new(1, offsetX, 0.5, -12)
    btn.AutoButtonColor = false
    btn.Parent = parent
    corner(btn, 8)
    local kbStroke = stroke(btn, 1.4, COLORS.Stroke, 0.25)
    btn.MouseEnter:Connect(function()
        if btn.Text == "..." then return end
        TweenService:Create(kbStroke, TweenInfo.new(0.1), {Transparency = 0}):Play()
    end)
    btn.MouseLeave:Connect(function()
        if btn.Text == "..." then return end
        TweenService:Create(kbStroke, TweenInfo.new(0.12), {Transparency = 0.25}):Play()
    end)

    local listening = false
    local currentValue = tostring(initialText)

    btn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keybindCaptureActive = true
        btn.Text = "..."

        btn.BackgroundColor3 = COLORS.TabActive
        btn.TextColor3 = COLORS.White
        local st = btn:FindFirstChildOfClass("UIStroke")
        if st then st.Transparency = 0; st.Color = COLORS.Stroke end

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gp)
            local isKeyboard = input.UserInputType == Enum.UserInputType.Keyboard
            local inputTypeName = input.UserInputType.Name
            local isGamepad = inputTypeName:match("^Gamepad%d+$") ~= nil
            if not (isKeyboard or isGamepad) then return end

            local key = input.KeyCode.Name
            if isKeyboard and key == "Escape" then
                currentValue = "None"
                btn.Text = "None"
            else
                currentValue = key
                btn.Text = key
            end
            if onKeyChanged then
                onKeyChanged(currentValue)
            end
            saveConfig()
            listening = false
            btn.BackgroundColor3 = COLORS.Badge
            btn.TextColor3 = COLORS.White
            if st then st.Transparency = 0.25; st.Color = COLORS.Stroke end
            conn:Disconnect()
            task.defer(function()
                keybindCaptureActive = false
            end)
        end)
    end)

    return btn, function() return currentValue end
end

function formatSpeedNum(n)
    n = tonumber(n)
    if not n then return "0" end

    if math.abs(n - math.floor(n + 1e-9)) < 1e-9 then
        return tostring(math.floor(n + 0.5))
    end
    return string.format("%.1f", n)
end

function parseNumInput(str)
    if str == nil then return nil end
    str = tostring(str):gsub("%s+", ""):gsub(",", ".")
    return tonumber(str)
end

function numberBadge(parent, initialValue, offsetX, width, onChanged)
    local btn = Instance.new("TextButton")
    btn.Text = formatSpeedNum(initialValue)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextColor3 = COLORS.White
    btn.BackgroundColor3 = COLORS.Badge
    btn.BackgroundTransparency = 0.35
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(0, width or 44, 0, 24)
    btn.Position = UDim2.new(1, offsetX, 0.5, -12)
    btn.AutoButtonColor = false
    btn.Parent = parent
    corner(btn, 8)
    local nStroke = stroke(btn, 1.4, COLORS.Stroke, 0.25)
    btn.MouseEnter:Connect(function()
        TweenService:Create(nStroke, TweenInfo.new(0.1), {Transparency = 0}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(nStroke, TweenInfo.new(0.12), {Transparency = 0.25}):Play()
    end)

    local currentValue = formatSpeedNum(initialValue)

    btn.MouseButton1Click:Connect(function()
        local box = Instance.new("TextBox")
        box.Text = currentValue
        box.Font = Enum.Font.GothamBold
        box.TextSize = 12
        box.TextColor3 = COLORS.White
        box.BackgroundColor3 = COLORS.Badge
        box.BackgroundTransparency = 0.25
        box.BorderSizePixel = 0
        box.Size = btn.Size
        box.Position = btn.Position
        box.ClearTextOnFocus = false
        box.TextXAlignment = Enum.TextXAlignment.Center
        box.Parent = parent
        corner(box, 8)
        stroke(box, 1, COLORS.Stroke, 0.2)
        btn.Visible = false
        box:CaptureFocus()
        box.CursorPosition = #box.Text + 1

        local function finish()
            local num = parseNumInput(box.Text)
            if num then

                num = math.floor(num * 10 + 0.5) / 10
                currentValue = formatSpeedNum(num)
                if onChanged then
                    onChanged(num)
                end
                saveConfig()
            end
            btn.Text = currentValue
            box:Destroy()
            btn.Visible = true
        end

        box.FocusLost:Connect(function()
            finish()
        end)
    end)

    local function getValue()
        return parseNumInput(currentValue) or tonumber(initialValue) or 0
    end

    local function setValue(v)
        currentValue = formatSpeedNum(v)
        btn.Text = currentValue
    end

    return btn, getValue, setValue
end

function toggleRow(parent, labelText, defaultOn, onToggle, initialKey, onKeyChanged)
    local row = rowBase(parent, labelText, true)

    local track = Instance.new("TextButton")
    track.Text = ""
    track.AutoButtonColor = false
    track.Size = UDim2.new(0, 44, 0, 24)
    track.Position = UDim2.new(1, -60, 0.5, -12)
    track.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    track.BackgroundTransparency = 0
    track.BorderSizePixel = 0
    track.Parent = row
    corner(track, 12)
    local toggleStroke = stroke(track, 1.5, _G.PeakHubThemeAccent or COLORS.Accent or Color3.fromRGB(255, 120, 0), 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = defaultOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = COLORS.White
    knob.BorderSizePixel = 0
    knob.Parent = track
    corner(knob, 9)

    local on = defaultOn
    local function setVisual(state)
        on = state == true
        local info = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        TweenService:Create(knob, info, {
            Position = on and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
            BackgroundColor3 = COLORS.White,
        }):Play()

        track.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        track.BackgroundTransparency = 0
        if toggleStroke then
            TweenService:Create(toggleStroke, info, {
                Color = _G.PeakHubThemeAccent or COLORS.ToggleActive or COLORS.Accent or Color3.fromRGB(255, 120, 0),
                Transparency = 0,
                Thickness = on and 2 or 1.5,
            }):Play()
        end

        if toggleStroke then
            toggleStroke.Color = _G.PeakHubThemeAccent or COLORS.ToggleActive or COLORS.Accent or Color3.fromRGB(255, 120, 0)
        end
        local rowStroke = row:FindFirstChild("RowStroke")
        if rowStroke then
            TweenService:Create(rowStroke, info, {
                Color = COLORS.Stroke,
                Transparency = 0.25,
                Thickness = on and 1.6 or 1.2,
            }):Play()
        end
    end

    track.MouseButton1Click:Connect(function()
        on = not on
        setVisual(on)
        if onToggle then onToggle(on) end
        saveConfig()
    end)

    if initialKey and tostring(initialKey) ~= "" then
        keybindBadge(row, initialKey, -112, 34, function(key)
            if onKeyChanged then onKeyChanged(key) end
            saveConfig()
        end)
    end
    return row, setVisual
end

function toggleWithKeybindRow(parent, labelText, defaultOn, initialKey, onToggle, onKeyChanged)
    local row = rowBase(parent, labelText, true)

    local track = Instance.new("TextButton")
    track.Text = ""
    track.AutoButtonColor = false
    track.Size = UDim2.new(0, 44, 0, 24)
    track.Position = UDim2.new(1, -60, 0.5, -12)
    track.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    track.BackgroundTransparency = 0
    track.BorderSizePixel = 0
    track.Parent = row
    corner(track, 12)
    stroke(track, 1, Color3.fromRGB(255, 120, 0), 0.4)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = defaultOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = COLORS.White
    knob.BorderSizePixel = 0
    knob.Parent = track
    corner(knob, 9)

    local on = defaultOn
    setRowGlow(row, defaultOn == true)
    track.MouseButton1Click:Connect(function()
        on = not on
        local info = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        TweenService:Create(knob, info, {
            Position = on and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
            BackgroundColor3 = COLORS.White,
        }):Play()
        TweenService:Create(track, info, {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0,
        }):Play()
        setRowGlow(row, on)
        if onToggle then
            onToggle(on)
        end
        saveConfig()
    end)

    keybindBadge(row, initialKey, -112, 34, function(key)
        if onKeyChanged then
            onKeyChanged(key)
        end
        saveConfig()
    end)

    _G.PeakHubSetBatAimbotUI = function(value)
        if labelText ~= "Bat Aimbot" then return end
        on = value == true
        local info = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(knob, info, {Position = on and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}):Play()
        setRowGlow(row, on)
    end
    return row
end

function toggleWithNumberRow(parent, labelText, defaultOn, initialVal, onToggle, onChanged, initialKey, onKeyChanged)
    local row = rowBase(parent, labelText, true)

    local track = Instance.new("TextButton")
    track.Text = ""
    track.AutoButtonColor = false
    track.Size = UDim2.new(0, 44, 0, 24)
    track.Position = UDim2.new(1, -112, 0.5, -12)
    track.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    track.BackgroundTransparency = 0
    track.BorderSizePixel = 0
    track.Parent = row
    corner(track, 12)
    stroke(track, 1, Color3.fromRGB(255, 120, 0), 0.4)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = defaultOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = COLORS.White
    knob.BorderSizePixel = 0
    knob.Parent = track
    corner(knob, 9)

    local on = defaultOn
    setRowGlow(row, defaultOn == true)
    track.MouseButton1Click:Connect(function()
        on = not on
        local info = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        TweenService:Create(knob, info, {
            Position = on and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
            BackgroundColor3 = COLORS.White,
        }):Play()
        TweenService:Create(track, info, {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0,
        }):Play()
        setRowGlow(row, on)
        if onToggle then
            onToggle(on)
        end
        saveConfig()
    end)

    if initialKey and tostring(initialKey) ~= "" then
        keybindBadge(row, initialKey, -156, 34, function(key)
            if onKeyChanged then onKeyChanged(key) end
            saveConfig()
        end)
    end

    numberBadge(row, initialVal, -60, 44, function(val)
        if onChanged then
            onChanged(val)
        end
        saveConfig()
    end)

    return row
end


function cycleSelectorRow(parent, labelText, options, currentValue, onChanged)
    local row = rowBase(parent, labelText, false)
    local opts = options or {}
    local idx = 1
    for i, o in ipairs(opts) do
        if o == currentValue then idx = i break end
    end

    local valueLbl = Instance.new("TextLabel")
    valueLbl.BackgroundTransparency = 1
    valueLbl.Size = UDim2.new(0, 110, 0, 22)
    valueLbl.Position = UDim2.new(1, -150, 0.5, -11)
    valueLbl.Font = Enum.Font.GothamBold
    valueLbl.TextSize = 12
    valueLbl.TextColor3 = COLORS.White
    valueLbl.Text = tostring(currentValue or (opts[1] or "-"))
    valueLbl.TextXAlignment = Enum.TextXAlignment.Center
    valueLbl.TextTruncate = Enum.TextTruncate.AtEnd
    valueLbl.Parent = row

    local function makeArrow(text, xOff)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 28, 0, 22)
        b.Position = UDim2.new(1, xOff, 0.5, -11)
        b.BackgroundColor3 = COLORS.Badge
        b.BackgroundTransparency = 0.25
        b.BorderSizePixel = 0
        b.Text = text
        b.Font = Enum.Font.GothamBlack
        b.TextSize = 14
        b.TextColor3 = COLORS.White
        b.AutoButtonColor = false
        b.Parent = row
        corner(b, 6)
        return b
    end

    local left = makeArrow("<", -188)
    local right = makeArrow(">", -32)

    local function setIndex(i)
        if #opts == 0 then return end
        if i < 1 then i = #opts end
        if i > #opts then i = 1 end
        idx = i
        valueLbl.Text = tostring(opts[idx])
        if onChanged then onChanged(opts[idx]) end
    end

    left.MouseButton1Click:Connect(function() setIndex(idx - 1) end)
    right.MouseButton1Click:Connect(function() setIndex(idx + 1) end)

    return {
        set = function(val)
            for i, o in ipairs(opts) do
                if o == val then
                    idx = i
                    valueLbl.Text = tostring(val)
                    break
                end
            end
        end
    }
end

function modeButtonsRow(parent, options, currentOption, onSelected)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 50)
    row.BackgroundColor3 = COLORS.RowDark
    row.BackgroundTransparency = 0.1
    row.BorderSizePixel = 0
    row.LayoutOrder = nextOrder()
    row.Parent = parent
    corner(row, 14)
    local rowSt = stroke(row, 1, COLORS.Stroke, 0.5)

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 1, -12)
    container.Position = UDim2.new(0, 8, 0, 6)
    container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    container.BackgroundTransparency = 0.15
    container.BorderSizePixel = 0
    container.Parent = row
    corner(container, 12)

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = container

    local padInner = Instance.new("UIPadding")
    padInner.PaddingLeft = UDim.new(0, 4)
    padInner.PaddingRight = UDim.new(0, 4)
    padInner.PaddingTop = UDim.new(0, 4)
    padInner.PaddingBottom = UDim.new(0, 4)
    padInner.Parent = container

    local buttons = {}
    local strokes = {}

    local function refreshAll()
        for opt, btn in pairs(buttons) do
            local active = (opt == currentOption)
            local st = strokes[opt]
            local info = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            if active then

                TweenService:Create(btn, info, {
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundTransparency = 0,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                }):Play()
                if st then
                    st.Thickness = 2
                    TweenService:Create(st, info, {Transparency = 0, Color = COLORS.Accent}):Play()
                end
            else

                TweenService:Create(btn, info, {
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundTransparency = 0,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                }):Play()
                if st then
                    st.Thickness = 1.4
                    TweenService:Create(st, info, {Transparency = 0.45, Color = COLORS.AccentSoft}):Play()
                end
            end
        end
    end

    local n = math.max(#options, 1)
    local pad = 4
    for _, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Text = opt
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 12
        btn.AutoButtonColor = false
        btn.Size = UDim2.new(1 / n, -math.floor(pad * (n - 1) / n), 1, 0)
        btn.BorderSizePixel = 0
        btn.BackgroundColor3 = COLORS.Badge
        btn.BackgroundTransparency = 0
        btn.TextColor3 = COLORS.White
        btn.Parent = container
        corner(btn, 8)
        local st = stroke(btn, 1.4, COLORS.Stroke, 0.25)
        buttons[opt] = btn
        strokes[opt] = st

        btn.MouseEnter:Connect(function()
            if opt == currentOption then return end
            local st2 = strokes[opt]
            if st2 then TweenService:Create(st2, TweenInfo.new(0.1), {Transparency = 0.15, Color = COLORS.Accent}):Play() end
        end)
        btn.MouseLeave:Connect(function()
            if opt == currentOption then return end
            local st2 = strokes[opt]
            if st2 then TweenService:Create(st2, TweenInfo.new(0.12), {Transparency = 0.45}):Play() end
        end)

        btn.MouseButton1Click:Connect(function()
            if currentOption == opt then return end
            currentOption = opt

            TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundTransparency = 0}):Play()
            refreshAll()
            if onSelected then onSelected(opt) end
            saveConfig()
        end)
    end

    refreshAll()
    return row
end

function textRow(parent, labelText, rightText)
    local row = rowBase(parent, labelText, false)
    local r = Instance.new("TextLabel")
    r.Text = rightText
    r.Font = Enum.Font.GothamBold
    r.TextSize = 12
    r.TextColor3 = COLORS.White
    r.BackgroundTransparency = 1
    r.Size = UDim2.new(0, 100, 1, 0)
    r.Position = UDim2.new(1, -116, 0, 0)
    r.TextXAlignment = Enum.TextXAlignment.Right
    r.Parent = row
    return row
end

local pages = {}

function makePage(name)
    local page = Instance.new("Frame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = page

    pages[name] = page
    return page
end

local movement = makePage("Movement")
local combat = makePage("Combat")






local VyzeSpeed = {}
do
    local function __vyzeMakeSpeedEngine()
        local MOVE_KEYS = {
            [Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true,
            [Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true,
            [Enum.KeyCode.Up] = true, [Enum.KeyCode.Left] = true,
            [Enum.KeyCode.Down] = true, [Enum.KeyCode.Right] = true,
        }

        local function isRagdollState(hum)
            if not hum then return true end
            local st = hum:GetState()
            return hum.PlatformStand == true
                or st == Enum.HumanoidStateType.Physics
                or st == Enum.HumanoidStateType.Ragdoll
                or st == Enum.HumanoidStateType.FallingDown
        end

        local S = {
            linVel = nil, att0 = nil, att1 = nil, char = nil,
            spoofed = Vector3.zero,
            lastMoveDir = Vector3.zero,
            currentPlane = Vector2.zero,
            lastApplyAt = tick(),
        }

        local function destroyLinVel()
            if S.linVel then pcall(function() S.linVel:Destroy() end) end
            if S.att0 then pcall(function() S.att0:Destroy() end) end
            if S.att1 then pcall(function() S.att1:Destroy() end) end
            S.linVel, S.att0, S.att1, S.char = nil, nil, nil, nil
            S.currentPlane = Vector2.zero
            S.lastApplyAt = tick()
        end

        local function setupLV(char)
            destroyLinVel()
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then
                local ok, res = pcall(function() return char:WaitForChild("HumanoidRootPart", 5) end)
                if ok then hrp = res end
            end
            if not hrp then return end

            local att0 = Instance.new("Attachment")
            att0.Name = "PeakHubSpeedAttachment"
            att0.Parent = hrp

            local lv = Instance.new("LinearVelocity")
            lv.Name = "PeakHubSpeedVelocity"
            lv.Attachment0 = att0
            lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
            lv.PrimaryTangentAxis = Vector3.new(1, 0, 0)
            lv.SecondaryTangentAxis = Vector3.new(0, 0, 1)
            lv.RelativeTo = Enum.ActuatorRelativeTo.World
            lv.MaxForce = 100000
            lv.PlaneVelocity = Vector2.zero
            lv.Enabled = true
            lv.Parent = hrp

            S.linVel, S.att0, S.att1, S.char = lv, att0, nil, char
            pcall(function() hrp:SetNetworkOwner(LP) end)
        end


        local WALL_FLING_CAST = 3.0
        local WALL_FLING_GAP = 0.3

        local function antiWallFling(root, maxSpd)
            if not root or not root.Parent then return end
            maxSpd = tonumber(maxSpd) or 0
            pcall(function()
                local v = root.AssemblyLinearVelocity
                local horiz = Vector3.new(v.X, 0, v.Z)
                local moving = horiz.Magnitude > 1
                local dir = moving and horiz.Unit or root.CFrame.LookVector
                dir = Vector3.new(dir.X, 0, dir.Z)
                if dir.Magnitude < 0.01 then return end
                dir = dir.Unit

                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = { LP.Character }
                params.IgnoreWater = true

                local hit = workspace:Raycast(root.Position, dir * WALL_FLING_CAST, params)
                local nearWall = hit and hit.Instance and hit.Instance.CanCollide
                    and hit.Distance <= (1.8 + WALL_FLING_GAP)

                if not nearWall then return end


                if maxSpd > 0 and horiz.Magnitude > maxSpd + 1 then
                    local flat = horiz.Unit * maxSpd
                    v = Vector3.new(flat.X, v.Y, flat.Z)
                end

                local jumpHeld = UserInputService:IsKeyDown(Enum.KeyCode.Space)
                if not jumpHeld and v.Y > 45 then
                    v = Vector3.new(v.X, 0, v.Z)
                end
                root.AssemblyLinearVelocity = v
            end)
        end

        local function setXZ(x, z)
            S.currentPlane = Vector2.new(x or 0, z or 0)
            if S.linVel and S.linVel.Parent then
                pcall(function() S.linVel.PlaneVelocity = S.currentPlane end)
            end
        end



        local function getPlane()
            return S.currentPlane
        end

        local function clear()
            S.currentPlane = Vector2.zero
            S.lastApplyAt = tick()
            if S.linVel and S.linVel.Parent then
                pcall(function() S.linVel.PlaneVelocity = Vector2.zero end)
            end
        end

        local function ensure()
            local char = LP.Character
            if not char then return false end
            if S.linVel and S.linVel.Parent and S.char == char then
                return true
            end
            setupLV(char)
            return S.linVel ~= nil and S.linVel.Parent ~= nil
        end

        local function speedLVSet(hrp, x, z)
            ensure()
            setXZ(x or 0, z or 0)
            if hrp then
                local mag = math.sqrt((x or 0) * (x or 0) + (z or 0) * (z or 0))
                antiWallFling(hrp, mag)
            end
        end

        local function speedLVClear(hrp)
            clear()
        end

        local wallParams = RaycastParams.new()
        wallParams.FilterType = Enum.RaycastFilterType.Exclude
        wallParams.IgnoreWater = true
        local lastFilterUpdate = 0
        local blockedTime = 0

        local function applySpeed(speed)
            local now = tick()
            local dt = math.clamp(now - (S.lastApplyAt or now), 0, 0.05)
            S.lastApplyAt = now

            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not char or not hum or not root or hum.Health <= 0 then return end

            if isRagdollState(hum) then
                S.lastMoveDir = Vector3.zero
                clear()
                if S.linVel then S.linVel.Enabled = false end
                return
            end

            ensure()
            local lv = S.linVel
            if not lv then return end
            if not lv.Enabled then lv.Enabled = true end

            local md = hum.MoveDirection
            local moving = md.Magnitude > 0.1
            local flatDir = moving and Vector3.new(md.X, 0, md.Z) or Vector3.zero
            if flatDir.Magnitude > 0.001 then flatDir = flatDir.Unit end

            local wallNormal = nil


            local grounded = hum.FloorMaterial ~= Enum.Material.Air
            if moving and grounded then
                local now = tick()
                if now - lastFilterUpdate > 1 then
                    lastFilterUpdate = now
                    local filter = {char}
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Character then table.insert(filter, p.Character) end
                    end
                    wallParams.FilterDescendantsInstances = filter
                end
                local hit = workspace:Raycast(root.Position + Vector3.new(0, 1, 0), flatDir * 2.5, wallParams)
                if hit and hit.Instance and hit.Instance.CanCollide then
                    local n = Vector3.new(hit.Normal.X, 0, hit.Normal.Z)
                    if n.Magnitude > 0.7 then wallNormal = n.Unit end
                end
            end

            local vel = root.AssemblyLinearVelocity
            local horizontal = Vector3.new(vel.X, 0, vel.Z)
            local blocked = wallNormal ~= nil or (moving and horizontal.Magnitude < 2)

            local targetPlane = Vector2.zero
            if moving then
                local wanted = flatDir * (tonumber(speed) or 0)
                if wallNormal then
                    wanted = wanted - wallNormal * wanted:Dot(wallNormal)
                end
                if wanted.Magnitude >= 0.5 then
                    targetPlane = Vector2.new(wanted.X, wanted.Z)
                end
                S.lastMoveDir = flatDir
            else
                S.lastMoveDir = Vector3.zero
            end




            local response = grounded and 18 or 10
            local alpha = 1 - math.exp(-response * dt)
            S.currentPlane = S.currentPlane:Lerp(targetPlane, alpha)
            if S.currentPlane.Magnitude < 0.25 and targetPlane.Magnitude == 0 then
                S.currentPlane = Vector2.zero
            end
            lv.PlaneVelocity = S.currentPlane

            if grounded and blocked then blockedTime = blockedTime + dt else blockedTime = 0 end

            lv.MaxForce = grounded and (blockedTime > 0.35 and 25000 or 100000) or 50000
        end


        pcall(function()
            if not (getrawmetatable and setreadonly and newcclosure) then return end
            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            local oldIndex = mt.__index
            mt.__index = newcclosure(function(self, key)
                if key == "AssemblyLinearVelocity" or key == "Velocity" then
                    if typeof(self) == "Instance" and self:IsA("BasePart")
                        and self.Name == "HumanoidRootPart"
                        and LP.Character and self:IsDescendantOf(LP.Character) then
                        return S.spoofed
                    end
                end
                return oldIndex(self, key)
            end)
            setreadonly(mt, true)
        end)

        RunService.Heartbeat:Connect(function()
            S.spoofed = Vector3.zero
        end)

        LP.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            pcall(setupLV, char)
            S.lastMoveDir = Vector3.zero
        end)

        task.defer(function()
            if LP.Character then
                task.wait(0.3)
                pcall(setupLV, LP.Character)
            end
        end)

        return {
            apply = applySpeed,
            set = speedLVSet,
            clear = speedLVClear,
            setup = setupLV,
            ensure = ensure,
            clearVel = clear,
            setXZ = setXZ,
            getPlane = getPlane,
        }
    end

    local eng = __vyzeMakeSpeedEngine()
    VyzeSpeed.apply = eng.apply
    VyzeSpeed.set = eng.set
    VyzeSpeed.clear = eng.clear
    VyzeSpeed.setup = eng.setup
    VyzeSpeed.ensure = eng.ensure
    VyzeSpeed.setXZ = eng.setXZ
    VyzeSpeed.getPlane = eng.getPlane
end

function applyVelocitySpeed(...)
    return VyzeSpeed.apply(...)
end
function _speedLVSet(...)
    return VyzeSpeed.set(...)
end
function _speedLVClear(...)
    return VyzeSpeed.clear(...)
end

function getActiveSpeed()
    local char = LP.Character
    local keyLaggerCarry = false
    if type(Config.LaggerCarryKey) == "string" and Config.LaggerCarryKey ~= "" and Config.LaggerCarryKey ~= "None" then
        local ok, keyCode = pcall(function() return Enum.KeyCode[Config.LaggerCarryKey] end)
        if ok and keyCode then keyLaggerCarry = UserInputService:IsKeyDown(keyCode) end
    end
    local inLagger = laggerModeEnabled or laggerSpeedEnabled or laggerCarryEnabled or keyLaggerCarry


    if carrySpeedEnabled then
        return inLagger and (tonumber(Config.LaggerCarry) or 20) or (tonumber(Config.CarrySpeed) or 29)
    end

    if autoCarryBoost and Config.AutoCarrySpeed then
        return inLagger and (tonumber(Config.LaggerCarry) or 20) or (tonumber(Config.CarrySpeed) or 29)
    end
    if laggerCarryEnabled or keyLaggerCarry then return tonumber(Config.LaggerCarry) or 20 end
    if laggerModeEnabled or laggerSpeedEnabled then return tonumber(Config.LaggerSpeed) or 40 end
    return tonumber(Config.NormalSpeed) or 59.5
end

function getPathSpeed()
    if laggerModeEnabled or laggerSpeedEnabled or laggerCarryEnabled then
        return tonumber(Config.LaggerSpeed) or 40
    end
    return tonumber(Config.NormalSpeed) or 59.5
end


local autoTPDownConn = nil

local function getTPDownLandingY(char, root, hum)
    local halfHeight = 1
    pcall(function() halfHeight = math.max(1, root.Size.Y * 0.5) end)
    local hipOffset = halfHeight * 3
    pcall(function()
        if hum.RigType == Enum.HumanoidRigType.R6 then
            hipOffset = halfHeight * 3
        else
            hipOffset = halfHeight + (hum.HipHeight or halfHeight * 2)
        end
    end)
    if hipOffset ~= hipOffset or hipOffset < 1 or hipOffset > 12 then hipOffset = halfHeight * 3 end

    local ignored = {char}
    pcall(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP and player.Character then table.insert(ignored, player.Character) end
        end
    end)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = ignored
    pcall(function() params.FilterType = Enum.RaycastFilterType.Exclude end)
    params.IgnoreWater = true
    pcall(function() params.RespectCanCollide = true end)

    local pos = root.Position
    local castY = pos.Y - math.max(1, root.Size.Y * 0.5) - 0.1
    local floorY
    for _ = 1, 12 do
        local hit
        pcall(function() hit = workspace:Raycast(Vector3.new(pos.X, castY, pos.Z), Vector3.new(0, -4000, 0), params) end)
        if not hit then break end
        local part = hit.Instance
        local skip = false
        pcall(function()
            if part:IsA("BasePart") and not part.CanCollide then skip = true end
            local model = part:FindFirstAncestorOfClass("Model")
            if model and model:FindFirstChildOfClass("Humanoid") then skip = true end
        end)
        if not skip then floorY = hit.Position.Y; break end
        table.insert(ignored, part)
        params.FilterDescendantsInstances = ignored
        castY = hit.Position.Y - 0.05
    end
    if floorY then return floorY + hipOffset + 0.15 end
    return -7
end

function doAutoTPDown(force)
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end

    if not force then
        if hum.FloorMaterial ~= Enum.Material.Air then return end
        if hrp.Position.Y < (tonumber(Config.TPDownHeight) or 20) then return end
    end

    local landingY = getTPDownLandingY(char, hrp, hum)
    local _, yaw = hrp.CFrame:ToEulerAnglesYXZ()
    -- VX7-style TP Down lands at the detected floor instead of a fixed Y=-7.
    -- Preserve horizontal speed so this doesn't switch the active speed controller.
    local currentVelocity = hrp.AssemblyLinearVelocity
    hrp.CFrame = CFrame.new(hrp.Position.X, landingY, hrp.Position.Z) * CFrame.Angles(0, yaw, 0)
    hrp.AssemblyLinearVelocity = Vector3.new(currentVelocity.X, 0, currentVelocity.Z)
    pcall(function()
        local current = hrp.Velocity
        hrp.Velocity = Vector3.new(current.X, 0, current.Z)
    end)
    pcall(function() hrp.AssemblyAngularVelocity = Vector3.zero end)
    pcall(function() hrp.RotVelocity = Vector3.zero end)
end

function startAutoTPDown()
    if autoTPDownConn then pcall(task.cancel, autoTPDownConn); autoTPDownConn = nil end
    autoTPDownConn = task.spawn(function()
        while Config.AutoTPDown do
            task.wait(0.1)
            pcall(function() doAutoTPDown(false) end)
        end
        autoTPDownConn = nil
    end)
end

function stopAutoTPDown()
    Config.AutoTPDown = false
    if autoTPDownConn then pcall(task.cancel, autoTPDownConn); autoTPDownConn = nil end
end

function performTPDown()
    pcall(function() doAutoTPDown(true) end)
end



_GACC = _GACC or {}
;(function()
 local state={applied=false,waiting=false,watchUntil=0,graceUntil=0,stealWasActive=false}
 local function ignored(n)
  local x=tostring(n or ""):lower()
  return x:find("bat",1,true) or x:find("slap",1,true) or x:find("medusa",1,true)
    or x:find("head",1,true) or x:find("stone",1,true)
 end
 _GACC.autoCarryDetect=function()
  local c=LP.Character
  if not c then return false end
  for _,n in ipairs({"Carrying","IsCarrying","Grabbed","Holding","StealHold","HasGrab"}) do
    local x=c:FindFirstChild(n,true)
    if x and ((x:IsA("BoolValue") and x.Value) or (x:IsA("ObjectValue") and x.Value)
      or (x:IsA("StringValue") and x.Value~="")) then
      return true
    end
  end

  for _,x in ipairs(c:GetChildren()) do
    local n=x.Name:lower()
    if x:IsA("Model") and x:FindFirstChildWhichIsA("BasePart",true) then
      if n:find("brainrot") or n:find("animal") or n:find("carry") or n:find("grab") then
        return true
      end
    end
  end
  return false
 end
 local function enable()
  state.waiting=false; state.watchUntil=0
  state.applied=true; state.graceUntil=tick()+0.75
  autoCarryBoost=true
 end
 local function disable()
  state.applied=false; state.waiting=false; state.watchUntil=0; state.graceUntil=0
  autoCarryBoost=false
 end
 _GACC.autoCarryWatch=function(sec)
  if Config.AutoCarrySpeed then
    state.waiting=true; state.watchUntil=tick()+(sec or 1.25)
  end
 end
 _GACC.disableAutoCarry=disable
 RunService.RenderStepped:Connect(function()
  if not Config.AutoCarrySpeed then
    if state.applied or autoCarryBoost then disable() end
    return
  end
  local c=LP.Character
  local h=c and c:FindFirstChildOfClass("Humanoid")
  local r=c and c:FindFirstChild("HumanoidRootPart")
  if not c or not h or not r then
    disable(); state.stealWasActive=false; return
  end
  local st=h:GetState()
  local hit=st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll
    or st==Enum.HumanoidStateType.FallingDown
  local stealing=LP:GetAttribute("Stealing")==true or c:GetAttribute("Stealing")==true
  local carrying=_GACC.autoCarryDetect()
  if stealing and not state.stealWasActive then
    state.stealWasActive=true; enable()
  elseif not stealing then
    state.stealWasActive=false
  end
  if state.waiting then
    if hit or tick()>state.watchUntil then
      state.waiting=false; state.watchUntil=0
    elseif carrying then
      enable()
    end
  end
  if carrying and not state.applied then enable() end
  if state.applied and (hit or (tick()>state.graceUntil and not carrying and not stealing)) then
    disable()
  end
 end)
end)()





sectionLabel(movement, "Speed Settings")


local normRow = rowBase(movement, "Normal Speed", false)
keybindBadge(normRow, Config.CarrySpeedKey or "None", -156, 48, function(key)
    Config.CarrySpeedKey = key
end)
numberBadge(normRow, Config.NormalSpeed, -102, 40, function(val)
    Config.NormalSpeed = val
end)
numberBadge(normRow, Config.CarrySpeed, -56, 40, function(val)
    Config.CarrySpeed = val
end)

local laggerRow = rowBase(movement, "Lagger Speed", false)
keybindBadge(laggerRow, Config.LaggerCarryKey or "None", -156, 48, function(key)
    Config.LaggerCarryKey = key
end)
numberBadge(laggerRow, Config.LaggerSpeed, -102, 40, function(val)
    Config.LaggerSpeed = val
end)
numberBadge(laggerRow, Config.LaggerCarry, -56, 40, function(val)
    Config.LaggerCarry = val
end)

toggleRow(movement, "Auto Carry Speed", Config.AutoCarrySpeed, function(state)
    Config.AutoCarrySpeed = state
end)

sectionLabel(movement, "Teleport")
toggleWithNumberRow(movement, "Auto TP Down", Config.AutoTPDown, Config.TPDownHeight, function(state)
    Config.AutoTPDown = state
    if state then
        startAutoTPDown()
    else
        stopAutoTPDown()
    end
    saveConfig()
end, function(val)
    Config.TPDownHeight = val
    saveConfig()
end)

sectionLabel(movement, "AUTO PATHS")

local autoLeftRow = rowBase(movement, "Auto Left", false)
mobBtnRefs.autoLeft = function(enabled) setRowGlow(autoLeftRow, enabled) end
setRowGlow(autoLeftRow, Config.AutoLeft == true)
keybindBadge(autoLeftRow, Config.AutoLeftKey, -60, 34, function(key)
    Config.AutoLeftKey = key
end)

local autoRightRow = rowBase(movement, "Auto Right", false)
mobBtnRefs.autoRight = function(enabled) setRowGlow(autoRightRow, enabled) end
setRowGlow(autoRightRow, Config.AutoRight == true)
keybindBadge(autoRightRow, Config.AutoRightKey, -60, 34, function(key)
    Config.AutoRightKey = key
end)




sectionLabel(combat, "Aim Assist")

local startBatAimbot, stopBatAimbot
local startAntiDie, stopAntiDie, syncAutoAntiDie
local startAutoStealSystem, stopAutoStealSystem
local startAutoLeft, stopAutoLeft, startAutoRight, stopAutoRight
local startBatCounter, stopBatCounter, startMedusaCounter, stopMedusaCounter
local startPlayerEsp, stopPlayerEsp, startPlayerTracers, stopPlayerTracers
local hookRagdollCountdown, stopRagdollCountdown
local applyCustomSky, applyAnimPack
local enableAntiLag, disableAntiLag, enableStretchRez, disableStretchRez
local enableCustomFov, disableCustomFov
local setNoCamCollision
local StealSys
local refreshStealBarMeta
local mirrorTPActive = false
local mirrorTPPreviousY = {}
local mirrorTPDownEnabled = Config.MirrorTPDown == true
local mirrorTPDownSetVisual = nil

-- Equipaggia la mazza una sola volta quando si attiva Bat Aimbot/Auto Swing.
-- Non forza continuamente l'equipaggiamento: il giocatore può usare altri tool.
local function peakEquipBatOnce()
    local character = LP.Character
    local backpack = LP:FindFirstChildOfClass("Backpack")
    local function isBatTool(tool)
        if not tool or not tool:IsA("Tool") then return false end
        local name = tool.Name:lower()
        return name:find("bat", 1, true) ~= nil or name:find("slap", 1, true) ~= nil
    end
    if character then
        local equipped = character:FindFirstChildOfClass("Tool")
        if isBatTool(equipped) then return true end
    end
    if not character or not backpack then return false end
    for _, tool in ipairs(backpack:GetChildren()) do
        if isBatTool(tool) then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                pcall(function() humanoid:EquipTool(tool) end)
                return true
            end
        end
    end
    return false
end

toggleWithKeybindRow(combat, "Bat Aimbot", Config.BatAimbot, Config.BatAimbotKey, function(state)
    Config.BatAimbot = state
    State.autoBatToggled = state
    if mobBtnRefs and mobBtnRefs.autoBat then pcall(mobBtnRefs.autoBat, state) end
    if state then
        peakEquipBatOnce()
        if startBatAimbot then startBatAimbot() end
    else
        if stopBatAimbot then stopBatAimbot() end
    end
end, function(key)
    Config.BatAimbotKey = key
end)

local aimbotSpeedRow = rowBase(combat, "Aimbot Speed", false)
numberBadge(aimbotSpeedRow, Config.AimbotSpeed, -60, 44, function(val)
    Config.AimbotSpeed = val
end)

toggleRow(combat, "Auto Swing", Config.AutoSwing, function(state)
    Config.AutoSwing = state
    if state then peakEquipBatOnce() end
end)

toggleRow(combat, "Mirror TP Down", Config.MirrorTPDown, function(state)
    Config.MirrorTPDown = state
    mirrorTPDownEnabled = state
    if not state then table.clear(mirrorTPPreviousY) end
    saveConfig()
end)

sectionLabel(combat, "AUTO STEAL")

toggleRow(combat, "Auto Steal", Config.AutoSteal, function(state)
    Config.AutoSteal = state
    if state then
        if os.clock() >= (Config._AutoStealHitPauseUntil or 0) then
            startAutoStealSystem()
        end
    else
        stopAutoStealSystem()
    end
end)

toggleRow(combat, "Ragdoll Steal", Config.AutoStealStopWhenHit, function(state)
    Config.AutoStealStopWhenHit = state
    if not state and os.clock() < (Config._AutoStealHitPauseUntil or 0) then
        Config._AutoStealHitPauseUntil = 0
        if Config.AutoSteal then
            stopAutoStealSystem()
            startAutoStealSystem()
        end
    end
    saveConfig()
end)

local stealVersionRow
local stealStopAtRow
local setStealRadiusBadge


if not Config.AutoStealRadiusNormal then Config.AutoStealRadiusNormal = 61 end
if not Config.AutoStealRadiusSemi then Config.AutoStealRadiusSemi = 9 end
if Config.AutoStealMode == "Semi" then
    Config.AutoStealRadius = Config.AutoStealRadiusSemi or 9
else
    Config.AutoStealRadius = Config.AutoStealRadiusNormal or 61
end

modeButtonsRow(combat, { "Normal", "Semi" }, Config.AutoStealMode, function(mode)
    Config.AutoStealMode = mode
    if mode == "Semi" then
        Config.AutoStealRadius = Config.AutoStealRadiusSemi or 9
        if stealVersionRow then stealVersionRow.Visible = false end
        if stealStopAtRow then stealStopAtRow.Visible = false end
    else
        Config.AutoStealRadius = Config.AutoStealRadiusNormal or 61
        if stealVersionRow then stealVersionRow.Visible = true end
        if stealStopAtRow then stealStopAtRow.Visible = Config.AutoStealVersion == "V2" end
    end
    if setStealRadiusBadge then setStealRadiusBadge(Config.AutoStealRadius) end
    pcall(function() refreshStealBarMeta() end)
    if Config.AutoSteal then
        stopAutoStealSystem()
        if os.clock() >= (Config._AutoStealHitPauseUntil or 0) then startAutoStealSystem() end
    end
end)


if Config.AutoStealVersion == "V3" then Config.AutoStealVersion = "V2" end

stealVersionRow = modeButtonsRow(combat, { "V1", "V2" }, Config.AutoStealVersion, function(ver)
    Config.AutoStealVersion = ver
    if stealStopAtRow then
        stealStopAtRow.Visible = Config.AutoStealMode ~= "Semi" and ver == "V2"
    end
    pcall(function() refreshStealBarMeta() end)
    if Config.AutoSteal then
        stopAutoStealSystem()
        if os.clock() >= (Config._AutoStealHitPauseUntil or 0) then startAutoStealSystem() end
    end
end)
if Config.AutoStealMode == "Semi" then
    stealVersionRow.Visible = false
end

Config.AutoStealStopAt = ({[75]=75,[80]=80,[85]=85,[90]=90,[95]=95})[tonumber(Config.AutoStealStopAt)] or 75
stealStopAtRow = rowBase(combat, "Stop At", false)
local stopAtChoices = { 75, 80, 85, 90, 95 }
local stopAtButtons = {}
local function refreshStopAtButtons()
    for percent, button in pairs(stopAtButtons) do
        local active = percent == Config.AutoStealStopAt
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        local outline = button:FindFirstChildOfClass("UIStroke")
        if outline then
            outline.Color = active and COLORS.Accent or COLORS.AccentSoft
            outline.Transparency = active and 0 or 0.45
            outline.Thickness = active and 2 or 1.2
        end
    end
end
for index, percent in ipairs(stopAtChoices) do
    local button = Instance.new("TextButton")
    button.Name = "StopAt" .. tostring(percent)
    button.Text = tostring(percent) .. "%"
    button.Font = Enum.Font.GothamBlack
    button.TextSize = 10
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.AutoButtonColor = false
    button.Size = UDim2.new(0, 30, 0, 26)
    button.Position = UDim2.new(1, -160 + (index - 1) * 31, 0.5, -13)
    button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    button.BorderSizePixel = 0
    button.Parent = stealStopAtRow
    corner(button, 6)
    stroke(button, 1.2, COLORS.AccentSoft, 0.45)
    stopAtButtons[percent] = button
    button.MouseButton1Click:Connect(function()
        Config.AutoStealStopAt = percent
        refreshStopAtButtons()
        saveConfig()
        if Config.AutoSteal then
            stopAutoStealSystem()
            if os.clock() >= (Config._AutoStealHitPauseUntil or 0) then startAutoStealSystem() end
        end
    end)
end
refreshStopAtButtons()
stealStopAtRow.Visible = Config.AutoStealMode ~= "Semi" and Config.AutoStealVersion == "V2"

local stealRadiusRow = rowBase(combat, "Steal Radius", false)
local _, _, setRad = numberBadge(stealRadiusRow, Config.AutoStealRadius, -60, 44, function(val)
    Config.AutoStealRadius = val
    if Config.AutoStealMode == "Semi" then
        Config.AutoStealRadiusSemi = val
    else
        Config.AutoStealRadiusNormal = val
    end
    pcall(function() refreshStealBarMeta() end)
end)
setStealRadiusBadge = setRad




function safeModeHoldingBrainrot() local ok,x=pcall(function() return LP:GetAttribute("Stealing") end);if ok and x then return true end;local ok2,x2=pcall(function() return LP:GetAttribute("AntiKick") end);if ok2 and x2 then return true end;local c=LP.Character;if c then local ok3,x3=pcall(function() return c:GetAttribute("Stealing") end);if ok3 and x3 then return true end end;if _GACC.autoCarryDetect then local ok4,x4=pcall(_GACC.autoCarryDetect);if ok4 and x4 then return true end end;return false end
function safeModeIsLocked() return Config.SafeMode and safeModeHoldingBrainrot() end
function safeModeAllowsAction(a) if not Config.SafeMode then return true end;if a=="drop" or a=="tpDown" or a=="reset" or a=="carrySpeed" or a=="laggerCarry" or a=="lagger" then return true end;return not safeModeIsLocked() end
function safeModeForceStop(reason) if not Config.SafeMode then return end;if State.autoBatToggled then if stopBatAimbot then stopBatAimbot() end;State.autoBatToggled=false;Config.BatAimbot=false end;if Config.AutoLeft then if stopAutoLeft then stopAutoLeft() end;Config.AutoLeft=false end;if Config.AutoRight then if stopAutoRight then stopAutoRight() end;Config.AutoRight=false end;end
function safeModeTryStart() if safeModeIsLocked() then safeModeForceStop("SAFE MODE LOCK");return false end;return true end
if not _G.__VyzeSafeModeMonitorStarted then _G.__VyzeSafeModeMonitorStarted=true;RunService.Heartbeat:Connect(function() if Config.SafeMode and safeModeIsLocked() then pcall(safeModeForceStop,"SAFE MODE LOCK") end end) end

local misc = makePage("Misc")
sectionLabel(misc, "JUMP")
toggleRow(misc, "Infinite Jump", Config.InfiniteJump, function(state)
    Config.InfiniteJump = state
    saveConfig()
end)
toggleRow(misc, "Anti Ragdoll", Config.AntiRagdoll, function(state)
    Config.AntiRagdoll = state
    if state then
        if _G._VyzeStartAntiRagdoll then _G._VyzeStartAntiRagdoll() end
    else
        if _G._VyzeStopAntiRagdoll then _G._VyzeStopAntiRagdoll() end
    end
end)

sectionLabel(misc, "COUNTERS")
toggleRow(misc, "Bat Counter", Config.BatCounter, function(state)
    Config.BatCounter = state
    if state then startBatCounter() else stopBatCounter() end
end)
toggleRow(misc, "Medusa Counter", Config.MedusaCounter, function(state)
    Config.MedusaCounter = state
    if state then startMedusaCounter() else stopMedusaCounter() end
end)

sectionLabel(misc, "SAFETY")

toggleRow(misc, "Safe Mode", Config.SafeMode, function(state)
    Config.SafeMode = state
    if state then
        safeModeForceStop("SAFE MODE LOCK")
        if Config.AutoSteal and stopAutoStealSystem then
            Config.AutoSteal = false
            pcall(stopAutoStealSystem)
        end
    end
end)

toggleRow(misc, "Anti Die", Config.AntiDie, function(state)
    Config.AntiDie = state
    if syncAutoAntiDie then
        pcall(syncAutoAntiDie)
    elseif state then
        if startAntiDie then pcall(startAntiDie) end
    else
        if stopAntiDie then pcall(stopAntiDie) end
    end
end)

sectionLabel(misc, "ACTIONS")

local dropActionRow = rowBase(misc, "Drop", false)
setRowGlow(dropActionRow, false)
keybindBadge(dropActionRow, Config.DropKey, -60, 48, function(key)
    Config.DropKey = key
end)

local tpDownActionRow = rowBase(misc, "TP Down", false)
keybindBadge(tpDownActionRow, Config.TPDownKey, -60, 48, function(key)
    Config.TPDownKey = key
end)

local instaResetActionRow = rowBase(misc, "Instant Reset", false)
keybindBadge(instaResetActionRow, Config.InstaResetKey, -60, 48, function(key)
    Config.InstaResetKey = key
end)


-- ============ PEAK HUB BAT SKIN ============
local PEAK_BAT_SKIN_ASSETS = {
    Scythe = "8699386664",
    ["Ban Hammer"] = "14701192921",
    ["Minecraft Sword"] = "minecraft_mesh",
}
-- Per-skin grip alignment, based on the actual asset proportions.
local PEAK_BAT_SKIN_ADJUST = {
    Scythe = {x = 0.09, y = -1, z = -0.8, rx = 0, ry = -90, rz = 0, size = 6},
    ["Ban Hammer"] = {x = 0, y = -1, z = 0, rx = 0, ry = 180, rz = 0, size = 4},
}
local PEAK_BAT_SKIN_FOLDER = "PeakHubBatSkin"

local function peakIsBatTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local n = string.lower(tool.Name or "")
    return string.find(n, "bat", 1, true) ~= nil or string.find(n, "slap", 1, true) ~= nil
end

local function peakGetHandle(tool)
    return tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart", true)
end

local PEAK_BAT_SKIN_ANIM_CONNECTIONS = setmetatable({}, {__mode = "k"})

local function peakRestoreBatTool(tool)
    if PEAK_BAT_SKIN_ANIM_CONNECTIONS[tool] then
        pcall(function() PEAK_BAT_SKIN_ANIM_CONNECTIONS[tool]:Disconnect() end)
        PEAK_BAT_SKIN_ANIM_CONNECTIONS[tool] = nil
    end
    local oldFolder = tool:FindFirstChild(PEAK_BAT_SKIN_FOLDER)
    if oldFolder then pcall(function() oldFolder:Destroy() end) end
    for _, obj in ipairs(tool:GetDescendants()) do
        if obj:IsA("BasePart") and obj:GetAttribute("PeakHubBatSkinHidden") then
            pcall(function()
                obj.LocalTransparencyModifier = obj:GetAttribute("PeakHubOldLTM") or 0
                obj.Transparency = obj:GetAttribute("PeakHubOldTransparency") or 0
                obj.CastShadow = true
                obj:SetAttribute("PeakHubBatSkinHidden", nil)
                obj:SetAttribute("PeakHubOldLTM", nil)
                obj:SetAttribute("PeakHubOldTransparency", nil)
            end)
        elseif obj:IsA("Sound") and obj.Name ~= "PeakBatSwingSound" then
            pcall(function()
                local oldVolume = obj:GetAttribute("PeakHubOldSoundVolume")
                local oldSoundId = obj:GetAttribute("PeakHubOldSoundId")
                if oldVolume ~= nil then obj.Volume = oldVolume end
                if oldSoundId ~= nil then obj.SoundId = oldSoundId end
                obj:SetAttribute("PeakHubOldSoundVolume", nil)
                obj:SetAttribute("PeakHubOldSoundId", nil)
            end)
        end
    end
end

local function peakMuteOriginalBatSounds(tool)
    for _, obj in ipairs(tool:GetDescendants()) do
        if obj:IsA("Sound") and obj.Name ~= "PeakBatSwingSound" then
            if obj:GetAttribute("PeakHubOldSoundVolume") == nil then
                obj:SetAttribute("PeakHubOldSoundVolume", obj.Volume)
                obj:SetAttribute("PeakHubOldSoundId", obj.SoundId)
            end
            obj.Volume = 0
            pcall(function() obj:Stop() end)
        end
    end
end

local function peakHideBatOriginal(tool)
    for _, obj in ipairs(tool:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:GetAttribute("PeakHubBatSkinPart") then
            if not obj:GetAttribute("PeakHubBatSkinHidden") then
                obj:SetAttribute("PeakHubOldLTM", obj.LocalTransparencyModifier)
                obj:SetAttribute("PeakHubOldTransparency", obj.Transparency)
                obj:SetAttribute("PeakHubBatSkinHidden", true)
            end
            obj.LocalTransparencyModifier = 1
            obj.Transparency = 1
            obj.CastShadow = false
        end
    end
end

local function peakMakeSkinPart(parent, name, size, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Color = color
    p.Material = material or Enum.Material.Metal
    p.Anchored = false
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Massless = true
    p:SetAttribute("PeakHubBatSkinPart", true)
    p.Parent = parent
    return p
end

local function peakWeldSkin(handle, part, offset)
    part.CFrame = handle.CFrame * (offset or CFrame.new())
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = handle
    weld.Part1 = part
    weld.Parent = part
end

local PEAK_BAT_SKIN_CONNECTIONS = setmetatable({}, {__mode = "k"})
local PEAK_BAT_SKIN_SOUNDS = {
    Katana = "rbxassetid://111808555599832",
    Scythe = "rbxassetid://137964779511233",
    ["Ban Hammer"] = "rbxassetid://111808555599832",
    ["Minecraft Sword"] = "rbxassetid://12222216",
}

local function peakSetupBatSkinEffects(tool, skin, folder)
    if not tool or not folder or not folder.Parent then return end
    local handle = peakGetHandle(tool)
    if not handle then return end
    if PEAK_BAT_SKIN_CONNECTIONS[tool] then
        pcall(function() PEAK_BAT_SKIN_CONNECTIONS[tool]:Disconnect() end)
        PEAK_BAT_SKIN_CONNECTIONS[tool] = nil
    end

    -- Place the swing trail on the longest visible skin part, not on the hidden handle.
    local bestPart, bestAxis, bestLength = nil, "Y", 0
    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("BasePart") then
            local sz = obj.Size
            local axis, length = "Y", sz.Y
            if sz.X > length then axis, length = "X", sz.X end
            if sz.Z > length then axis, length = "Z", sz.Z end
            if length > bestLength then bestPart, bestAxis, bestLength = obj, axis, length end
        end
    end
    if bestPart and bestLength > 0.5 then
        local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
        a0.Name, a1.Name = "PeakBatTrailTop", "PeakBatTrailBottom"
        local half = bestLength * 0.46
        if bestAxis == "X" then
            a0.Position, a1.Position = Vector3.new(-half, 0, 0), Vector3.new(half, 0, 0)
        elseif bestAxis == "Z" then
            a0.Position, a1.Position = Vector3.new(0, 0, -half), Vector3.new(0, 0, half)
        else
            a0.Position, a1.Position = Vector3.new(0, half, 0), Vector3.new(0, -half, 0)
        end
        a0.Parent, a1.Parent = bestPart, bestPart
        local trail = Instance.new("Trail")
        trail.Name = "PeakBatSwingTrail"
        trail.Attachment0, trail.Attachment1 = a0, a1
        trail.Color = ColorSequence.new(Color3.fromRGB(255, 180, 70), Color3.fromRGB(255, 95, 0))
        trail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.12), NumberSequenceKeypoint.new(1, 1)})
        trail.Lifetime = 0.22
        trail.LightEmission = 0.8
        trail.Enabled = false
        trail.Parent = folder
    end

    local swingSound = handle:FindFirstChild("PeakBatSwingSound")
    if not swingSound then
        swingSound = Instance.new("Sound")
        swingSound.Name = "PeakBatSwingSound"
        swingSound.Volume = 0.8
        swingSound.PlaybackSpeed = 1
        swingSound.Parent = handle
    end
    swingSound.SoundId = PEAK_BAT_SKIN_SOUNDS[skin] or "rbxassetid://111808555599832"

    -- L'attivazione del tool arma una finestra breve; il suono parte solo
    -- quando Roblox segnala l'avvio di un'animazione reale del personaggio.
    local pendingSwingUntil = 0
    local lastSkinSwingSound = 0
    local char = tool.Parent
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    if animator then
        PEAK_BAT_SKIN_ANIM_CONNECTIONS[tool] = animator.AnimationPlayed:Connect(function(track)
            if not tool.Parent or tool.Parent ~= char or Config.BatSkin ~= skin then return end
            local now = os.clock()
            if now > pendingSwingUntil or now - lastSkinSwingSound < 0.22 then return end
            local animationId = ""
            pcall(function() animationId = track.Animation and track.Animation.AnimationId or "" end)
            if animationId == "" then return end
            lastSkinSwingSound = now
            pendingSwingUntil = 0
            pcall(function()
                swingSound:Stop()
                swingSound.TimePosition = 0
                swingSound:Play()
            end)
        end)
    end

    PEAK_BAT_SKIN_CONNECTIONS[tool] = tool.Activated:Connect(function()
        if not tool.Parent or Config.BatSkin ~= skin then return end
        pendingSwingUntil = os.clock() + 0.45
        local trail = folder:FindFirstChild("PeakBatSwingTrail", true)
        if trail and trail:IsA("Trail") then
            trail.Enabled = true
            task.delay(0.24, function()
                if trail and trail.Parent then trail.Enabled = false end
            end)
        end
    end)
end

local function peakApplyBatSkin(tool)
    if not peakIsBatTool(tool) then return end
    local skin = Config.BatSkin or "Katana"
    if PEAK_BAT_SKIN_CONNECTIONS[tool] then
        pcall(function() PEAK_BAT_SKIN_CONNECTIONS[tool]:Disconnect() end)
        PEAK_BAT_SKIN_CONNECTIONS[tool] = nil
    end
    peakRestoreBatTool(tool)
    if skin == "None" then return end
    peakMuteOriginalBatSounds(tool)
    local handle = peakGetHandle(tool)
    if not handle then return end

    local folder = Instance.new("Folder")
    folder.Name = PEAK_BAT_SKIN_FOLDER
    folder.Parent = tool

    if skin == "Minecraft Sword" then
        peakHideBatOriginal(tool)
        local swordPart = Instance.new("Part")
        swordPart.Name = "PeakMinecraftSwordMesh"
        swordPart.Size = Vector3.new(1, 1, 1)
        swordPart.Transparency = 0
        swordPart.Anchored = false
        swordPart.CanCollide = false
        swordPart.CanTouch = false
        swordPart.CanQuery = false
        swordPart.Massless = true
        swordPart:SetAttribute("PeakHubBatSkinPart", true)
        swordPart.Parent = folder
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = "rbxassetid://8827558932"
        mesh.TextureId = "rbxassetid://8827558969"
        mesh.Scale = Vector3.new(0.2, 0.2, 0.2)
        mesh.Parent = swordPart
        local motor = Instance.new("Motor6D")
        motor.Name = "PeakMinecraftSwordGrip"
        motor.Part0 = handle
        motor.Part1 = swordPart
        motor.C0 = CFrame.new(-0.05, -0.1, -0.12)
            * CFrame.Angles(math.rad(90), math.rad(180), math.rad(300))
        motor.Parent = handle
        peakSetupBatSkinEffects(tool, skin, folder)
        return
    end

    if skin == "Katana" then
        peakHideBatOriginal(tool)
        local blade = peakMakeSkinPart(folder, "PeakKatanaBlade",
            Vector3.new(0.19, 4.15, 0.065), Color3.fromRGB(205, 215, 225), Enum.Material.Metal)
        peakWeldSkin(handle, blade, CFrame.new(0, 1.17, 0))
        local edge = peakMakeSkinPart(folder, "PeakKatanaEdge",
            Vector3.new(0.025, 4.05, 0.075), Color3.fromRGB(255, 120, 0), Enum.Material.Neon)
        peakWeldSkin(handle, edge, CFrame.new(0.105, 1.15, -0.008))
        local guard = peakMakeSkinPart(folder, "PeakKatanaGuard",
            Vector3.new(0.78, 0.09, 0.27), Color3.fromRGB(35, 35, 35), Enum.Material.Metal)
        peakWeldSkin(handle, guard, CFrame.new(0, -0.39, 0))
        local grip = peakMakeSkinPart(folder, "PeakKatanaGrip",
            Vector3.new(0.22, 0.82, 0.22), Color3.fromRGB(15, 15, 15), Enum.Material.SmoothPlastic)
        peakWeldSkin(handle, grip, CFrame.new(0, -1.15, 0))
        for i = 1, 5 do
            local wrap = peakMakeSkinPart(folder, "PeakKatanaWrap" .. i,
                Vector3.new(0.235, 0.035, 0.235),
                i % 2 == 0 and Color3.fromRGB(255, 120, 0) or Color3.fromRGB(28, 28, 28),
                Enum.Material.SmoothPlastic)
            peakWeldSkin(handle, wrap, CFrame.new(0, -1.45 + i * 0.145, 0))
        end
        local pommel = peakMakeSkinPart(folder, "PeakKatanaPommel",
            Vector3.new(0.27, 0.13, 0.27), Color3.fromRGB(255, 120, 0), Enum.Material.Metal)
        peakWeldSkin(handle, pommel, CFrame.new(0, -1.59, 0))
        -- Effects are connected below, after the skin has been built.
        task.defer(function()
            if tool and tool.Parent and folder and folder.Parent then
                peakSetupBatSkinEffects(tool, skin, folder)
            end
        end)
        return
    end

    local assetId = PEAK_BAT_SKIN_ASSETS[skin]
    if not assetId then return end
    local ok, objects = pcall(function()
        return game:GetObjects("rbxassetid://" .. assetId)
    end)
    if not ok or not objects or not objects[1] then return end

    local model = objects[1]
    if model:IsA("BasePart") then
        local wrapper = Instance.new("Model")
        wrapper.Name = "PeakHubBatSkinModel"
        model.Parent = wrapper
        model = wrapper
    end
    model.Name = "PeakHubBatSkinAsset"
    model.Parent = folder

    local parts = {}
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
            obj.Anchored = false
            obj.CanCollide = false
            obj.CanTouch = false
            obj.CanQuery = false
            obj.Massless = true
            obj:SetAttribute("PeakHubBatSkinPart", true)
        elseif obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript")
            or obj:IsA("ScreenGui") or obj:IsA("BillboardGui") then
            pcall(function() obj:Destroy() end)
        end
    end
    if #parts == 0 then pcall(function() model:Destroy() end); return end

    local adjust = PEAK_BAT_SKIN_ADJUST[skin] or {x = 0, y = 0, z = -0.5, rx = 0, ry = 0, rz = 0, size = 5}
    local bboxSize
    local okBounds = pcall(function()
        local _, size = model:GetBoundingBox()
        bboxSize = size
    end)
    if okBounds and bboxSize then
        local longest = math.max(bboxSize.X, bboxSize.Y, bboxSize.Z)
        if longest > 0 then
            pcall(function() model:ScaleTo(math.clamp((adjust.size or 5) / longest, 0.05, 8)) end)
        end
    end

    -- Rotate long models so the weapon's long axis follows the handle direction.
    local orient = CFrame.new()
    local _, scaledSize = model:GetBoundingBox()
    if scaledSize.X > scaledSize.Y and scaledSize.X > scaledSize.Z then
        orient = CFrame.Angles(0, 0, math.rad(90))
    elseif scaledSize.Z > scaledSize.Y and scaledSize.Z > scaledSize.X then
        orient = CFrame.Angles(math.rad(90), 0, 0)
    end
    local desiredBox = handle.CFrame
        * CFrame.new(adjust.x or 0, adjust.y or 0, adjust.z or 0)
        * orient
        * CFrame.Angles(math.rad(adjust.rx or 0), math.rad(adjust.ry or 0), math.rad(adjust.rz or 0))

    -- Align the model's bounding-box center to the grip target, rather than
    -- assuming the imported asset's pivot is at its handle.
    local currentPivot = model:GetPivot()
    local currentBox = select(1, model:GetBoundingBox())
    local boxFromPivot = currentPivot:ToObjectSpace(currentBox)
    pcall(function() model:PivotTo(desiredBox * boxFromPivot:Inverse()) end)

    peakHideBatOriginal(tool)
    for _, part in ipairs(parts) do
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = handle
        weld.Part1 = part
        weld.Parent = part
    end
    peakSetupBatSkinEffects(tool, skin, folder)
end

function applyPeakBatSkinToAll()
    local containers = {}
    if LP.Character then table.insert(containers, LP.Character) end
    local backpack = LP:FindFirstChildOfClass("Backpack")
    if backpack then table.insert(containers, backpack) end
    for _, container in ipairs(containers) do
        for _, tool in ipairs(container:GetChildren()) do
            if peakIsBatTool(tool) then pcall(peakApplyBatSkin, tool) end
        end
    end
end

local function peakWatchBatContainer(container)
    if not container then return end
    container.ChildAdded:Connect(function(child)
        if peakIsBatTool(child) then
            task.wait(0.15)
            pcall(peakApplyBatSkin, child)
        end
    end)
end
peakWatchBatContainer(LP:FindFirstChildOfClass("Backpack"))
peakWatchBatContainer(LP.Character)
LP.ChildAdded:Connect(function(child)
    if child:IsA("Backpack") then peakWatchBatContainer(child) end
end)
LP.CharacterAdded:Connect(function(char)
    task.wait(0.75)
    peakWatchBatContainer(char)
    pcall(applyPeakBatSkinToAll)
end)
task.defer(function()
    task.wait(1)
    pcall(applyPeakBatSkinToAll)
end)

local visual = makePage("Visual")


sectionLabel(visual, "ESP")
toggleRow(visual, "ESP", Config.PlayerESP, function(state)
    Config.PlayerESP = state
    if state then startPlayerEsp() else stopPlayerEsp() end
end)
toggleRow(visual, "Tracers", Config.PlayerTracers, function(state)
    Config.PlayerTracers = state
    if state then startPlayerTracers() else stopPlayerTracers() end
end)
toggleRow(visual, "Ragdoll Countdown", Config.RagdollCountdown, function(state)
    Config.RagdollCountdown = state
    if state then
        if type(hookRagdollCountdown) == "function" and LP.Character then
            pcall(hookRagdollCountdown, LP.Character)
        end
    else
        if type(stopRagdollCountdown) == "function" then pcall(stopRagdollCountdown) end
    end
end)


sectionLabel(visual, "VISUAL")
toggleRow(visual, "Custom Animation", Config.CustomAnim, function(state)
    if state and Config.AnimPack == "Unwalk" then
        Config.Unwalk = true
        Config.CustomAnim = false
        if type(startUnwalk) == "function" then pcall(startUnwalk) end
    else
        Config.CustomAnim = state
        if state then
            Config.Unwalk = false
            if type(stopUnwalk) == "function" then pcall(stopUnwalk) end
            task.spawn(function()
                if applyAnimPack then pcall(applyAnimPack, Config.AnimPack) end
            end)
        else
            if restoreCharacterAnimations then pcall(restoreCharacterAnimations, LP.Character) end
        end
    end
    saveConfig()
end)
cycleSelectorRow(visual, "Anim Pack", {"Unwalk","Adidas Sports","Adidas Community","Adidas Aura","Wicked Popular","Elder","Zombie","Mage","Catwalk Glam","Astronaut","Wicked Dancing Through Life","Werewolf","Superhero","Toy","No Boundaries","NFL","Amazon Unboxed","Vampire","Ninja","Robot","Levitation","Stylish","Bubbly","Cartoon"}, Config.Unwalk and "Unwalk" or Config.AnimPack, function(mode)
    if mode == "Unwalk" then
        Config.AnimPack = "Unwalk"
        Config.Unwalk = true
        Config.CustomAnim = false
        if type(startUnwalk) == "function" then pcall(startUnwalk) end
    else
        Config.AnimPack = mode
        if Config.Unwalk then
            Config.Unwalk = false
            if type(stopUnwalk) == "function" then pcall(stopUnwalk) end
        end
        if Config.CustomAnim then
            task.spawn(function()
                if applyAnimPack then pcall(applyAnimPack, mode) end
            end)
        end
    end
    saveConfig()
end)
cycleSelectorRow(visual, "Bat Skin", {"Katana", "Minecraft Sword", "Scythe", "Ban Hammer", "None"}, Config.BatSkin, function(skin)
    Config.BatSkin = skin
    if applyPeakBatSkinToAll then
        task.spawn(function() pcall(applyPeakBatSkinToAll) end)
    end
    saveConfig()
end)


sectionLabel(visual, "PERFORMANCE")
toggleRow(visual, "Anti Lag", Config.AntiLag, function(state)
    Config.AntiLag = state
    if state then enableAntiLag() else disableAntiLag() end
end)
toggleRow(visual, "Stretch Res", Config.StretchRes, function(state)
    Config.StretchRes = state
    if state then enableStretchRez() else disableStretchRez() end
end)
toggleRow(visual, "FOV Change", Config.FOVChange, function(state)
    Config.FOVChange = state
    if state then enableCustomFov() else disableCustomFov() end
end)
local fovRow = rowBase(visual, "FOV Value", false)
numberBadge(fovRow, Config.FOVValue, -60, 44, function(val)
    Config.FOVValue = math.clamp(val, 30, 120)
    if Config.FOVChange then
        pcall(function() workspace.CurrentCamera.FieldOfView = Config.FOVValue end)
    end
end)

local settings = makePage("Settings")



if Config.LockUI then
    main.Draggable = false
else
    main.Draggable = true
end
if Config.HideUI then
    main.Visible = false
    uiMinimized = true
    miniRestoreButton.Visible = true
else
    main.Visible = true
    miniRestoreButton.Visible = false
end

sectionLabel(settings, "UI")

-- Background selector: 12 slots. Background 1 is the default image; backgrounds 2-12 use supplied URLs.
do
    local BACKGROUND_URLS = {
        [1] = "https://files.catbox.moe/sz7icy.png",
        [2] = "https://files.catbox.moe/5341xz.png",
        [3] = "https://files.catbox.moe/httilb.png",
        [4] = "https://files.catbox.moe/tj68cq.png",
        [5] = "https://files.catbox.moe/qozl8g.png",
        [6] = "https://files.catbox.moe/9cpq91.jpeg",
        [7] = "https://files.catbox.moe/pc73yz.jpeg",
        [8] = "https://files.catbox.moe/ucw3ej.jpeg",
        [9] = "https://files.catbox.moe/6mwr9m.png",
        [10] = "https://files.catbox.moe/uu258w.jpeg",
        [11] = "https://files.catbox.moe/lh97zw.png",
        [12] = "https://files.catbox.moe/b2xyii.png",
    }

    -- Warm the local cache in the background so later selections can switch nearly instantly.
    -- This never blocks UI creation and leaves the currently selected background untouched.
    task.spawn(function()
        for i = 1, 12 do
            local url = BACKGROUND_URLS[i]
            if url and not cachedBackgroundAsset(url) then
                task.spawn(function()
                    local data
                    pcall(function() data = game:HttpGet(url) end)
                    if not data or #data < 100 then
                        pcall(function()
                            local req = request or http_request or (syn and syn.request)
                            if not req then return end
                            local res = req({Url = url, Method = "GET"})
                            if res then data = res.Body or res.body end
                        end)
                    end
                    if data and #data > 100 and writefile then
                        pcall(function() writefile(backgroundCacheFile(url), data) end)
                    end
                end)
                task.wait(0.08)
            end
        end
    end)

    -- Each background has its own accent palette, applied across the main UI,
    -- side buttons, toggles, rows, strokes, and overhead UI elements.
    local BACKGROUND_THEMES = {
        [1]  = {accent = Color3.fromRGB(255, 120, 0), soft = Color3.fromRGB(100, 35, 0)},
        [2]  = {accent = Color3.fromRGB(255, 75, 75), soft = Color3.fromRGB(105, 25, 25)},
        [3]  = {accent = Color3.fromRGB(255, 190, 55), soft = Color3.fromRGB(105, 70, 15)},
        [4]  = {accent = Color3.fromRGB(70, 190, 255), soft = Color3.fromRGB(15, 65, 105)},
        [5]  = {accent = Color3.fromRGB(190, 100, 255), soft = Color3.fromRGB(65, 25, 105)},
        [6]  = {accent = Color3.fromRGB(255, 90, 165), soft = Color3.fromRGB(105, 25, 65)},
        [7]  = {accent = Color3.fromRGB(70, 230, 160), soft = Color3.fromRGB(15, 85, 55)},
        [8]  = {accent = Color3.fromRGB(80, 130, 255), soft = Color3.fromRGB(20, 40, 105)},
        [9]  = {accent = Color3.fromRGB(235, 235, 245), soft = Color3.fromRGB(65, 65, 80)},
        [10] = {accent = Color3.fromRGB(255, 215, 110), soft = Color3.fromRGB(100, 75, 25)},
        [11] = {accent = Color3.fromRGB(110, 235, 95), soft = Color3.fromRGB(25, 85, 20)},
        [12] = {accent = Color3.fromRGB(55, 220, 215), soft = Color3.fromRGB(15, 80, 80)},
    }

    local function isWarmAccent(c)
        local r, g, b = math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5)
        return r >= 95 and r > g * 1.22 and g >= b * 1.18 and b <= 115 and g <= 190
    end
    local function isColoredAccent(c)
        local r, g, b = c.R, c.G, c.B
        local hi = math.max(r, g, b)
        local lo = math.min(r, g, b)
        -- Treat saturated or clearly tinted colors as theme accents, but preserve black and white.
        return hi > 0.16 and hi < 0.96 and (hi - lo) > 0.10
    end
    local function applyBackgroundTheme(index)
        local theme = BACKGROUND_THEMES[index] or BACKGROUND_THEMES[1]
        _G.PeakHubThemeAccent = theme.accent
        _G.PeakHubThemeSoft = theme.soft
        local oldAccent = COLORS.Accent
        local oldSoft = COLORS.AccentSoft
        COLORS.TabActive = theme.accent
        COLORS.ToggleActive = theme.accent
        COLORS.PurpleText = theme.accent
        COLORS.TextDim = theme.accent
        COLORS.Stroke = theme.accent
        COLORS.Accent = theme.accent
        COLORS.Success = theme.accent
        COLORS.Red = theme.accent
        COLORS.Blue = theme.accent
        COLORS.AccentSoft = theme.soft
        COLORS.Purple = theme.soft

        -- Recolor existing GUI objects using their current accent colors.
        -- White labels and black backgrounds are deliberately preserved.
        local guiRoots = {screenGui}
        local mobileGui = playerGui:FindFirstChild("VyzeMobileButtons")
        if mobileGui then table.insert(guiRoots, mobileGui) end
        for _, root in ipairs(guiRoots) do
            for _, obj in ipairs(root:GetDescendants()) do
                if obj:IsA("GuiObject") then
                    pcall(function()
                        local name = string.lower(obj.Name or "")
                        local isToggle = name == "toggle" or name == "togglestroke" or name == "track"
                        local isActiveSideButton = obj:IsA("TextButton") and obj.Parent == mobileGui and obj:GetAttribute("PeakHubActive") == true
                        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                            if isWarmAccent(obj.BackgroundColor3) or isColoredAccent(obj.BackgroundColor3) or obj.BackgroundColor3 == oldAccent or obj.BackgroundColor3 == oldSoft then
                                obj.BackgroundColor3 = theme.accent
                            end
                        elseif isWarmAccent(obj.BackgroundColor3) or isColoredAccent(obj.BackgroundColor3) or obj.BackgroundColor3 == oldAccent or obj.BackgroundColor3 == oldSoft then
                            obj.BackgroundColor3 = theme.soft
                        end
                        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                            if isWarmAccent(obj.TextColor3) or isColoredAccent(obj.TextColor3) or obj.TextColor3 == oldAccent or obj.TextColor3 == oldSoft then
                                obj.TextColor3 = theme.accent
                            end
                        end
                        if isToggle and obj:IsA("GuiObject") then
                            local strokeObj = obj:FindFirstChildOfClass("UIStroke")
                            if strokeObj then strokeObj.Color = theme.accent end
                        end
                        if name == "divider" then obj.BackgroundColor3 = theme.accent end
                    end)
                elseif obj:IsA("UIStroke") then
                    pcall(function()
                        if isWarmAccent(obj.Color) or isColoredAccent(obj.Color) or obj.Color == oldAccent or obj.Color == oldSoft then
                            obj.Color = theme.accent
                        end
                    end)
                end
            end
        end
        -- Toggle tracks, active pills, and active side buttons follow the selected theme.
        for _, obj in ipairs(screenGui:GetDescendants()) do
            if obj:IsA("UIStroke") and obj.Parent and (obj.Parent.Name == "Toggle" or obj.Parent.Name == "Track" or obj.Parent.Name == "ToggleStroke") then
                obj.Color = theme.accent
            end
        end
        if mobileGui then
            for _, btn in ipairs(mobileGui:GetChildren()) do
                if btn:IsA("TextButton") then
                    local st = btn:FindFirstChildOfClass("UIStroke")
                    if btn:GetAttribute("PeakHubActive") == true then
                        btn.BackgroundColor3 = theme.accent
                        local activeGrad = btn:FindFirstChildOfClass("UIGradient")
                        if activeGrad then activeGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, theme.soft), ColorSequenceKeypoint.new(1, theme.accent)}) end
                        if st then st.Color = theme.accent end
                    elseif st then
                        st.Color = theme.accent
                    end
                    local topAccent = btn:FindFirstChild("OrangeAccent")
                    if topAccent and topAccent:IsA("GuiObject") then topAccent.BackgroundColor3 = theme.accent end
                end
            end
        end
        if StealSys and StealSys.applyTheme then pcall(StealSys.applyTheme) end
        -- If tabs already exist, refresh the selected tab's accent now, not on the next click.
        if type(selectTab) == "function" then
            task.defer(function()
                pcall(function() selectTab(_G.PeakHubSelectedTab or "Movement") end)
            end)
        end
    end

    local row = rowBase(settings, "Background", false)
    local valLbl = Instance.new("TextLabel")
    valLbl.BackgroundTransparency = 1
    valLbl.Size = UDim2.new(0, 42, 0, 22)
    valLbl.Position = UDim2.new(1, -120, 0.5, -11)
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 13
    valLbl.TextColor3 = COLORS.White
    Config.UIBackgroundIndex = math.clamp(tonumber(Config.UIBackgroundIndex) or 1, 1, 12)
    valLbl.Text = tostring(Config.UIBackgroundIndex)
    valLbl.Parent = row
    local function mkBackgroundArrow(txt, x)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 28, 0, 22)
        b.Position = UDim2.new(1, x, 0.5, -11)
        b.BackgroundColor3 = COLORS.Badge
        b.BackgroundTransparency = 0.25
        b.BorderSizePixel = 0
        b.Text = txt
        b.Font = Enum.Font.GothamBlack
        b.TextSize = 14
        b.TextColor3 = COLORS.White
        b.Parent = row
        corner(b, 6)
        return b
    end
    local function setBackgroundIndex(n)
        Config.UIBackgroundIndex = math.clamp(tonumber(n) or 1, 1, 12)
        valLbl.Text = tostring(Config.UIBackgroundIndex)
        applyBackgroundTheme(Config.UIBackgroundIndex)
        local url = BACKGROUND_URLS[Config.UIBackgroundIndex]
        if url then
            applyUIBackground(url)
        else
            Config.UIBackgroundUrl = ""
            if uiBgImage then uiBgImage.Image = ""; uiBgImage.Visible = false end
            if uiBgDim then uiBgDim.BackgroundColor3 = Color3.fromRGB(0, 0, 0); uiBgDim.BackgroundTransparency = 0 end
            main.BackgroundTransparency = 0
            main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        end
        saveConfig()
    end
    mkBackgroundArrow("<", -156).MouseButton1Click:Connect(function() setBackgroundIndex(math.max(1, Config.UIBackgroundIndex - 1)) end)
    mkBackgroundArrow(">", -64).MouseButton1Click:Connect(function() setBackgroundIndex(math.min(12, Config.UIBackgroundIndex + 1)) end)
    setBackgroundIndex(Config.UIBackgroundIndex)
end

do
    local row = rowBase(settings, "UI Scale", false)
    local valLbl = Instance.new("TextLabel")
    valLbl.BackgroundTransparency = 1
    valLbl.Size = UDim2.new(0, 48, 0, 22)
    valLbl.Position = UDim2.new(1, -120, 0.5, -11)
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 13
    valLbl.TextColor3 = COLORS.White
    valLbl.Text = tostring(Config.UIScale)
    valLbl.TextXAlignment = Enum.TextXAlignment.Center
    valLbl.Parent = row
    local function mkArr(txt, x)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 28, 0, 22)
        b.Position = UDim2.new(1, x, 0.5, -11)
        b.BackgroundColor3 = COLORS.Badge
        b.BackgroundTransparency = 0.25
        b.BorderSizePixel = 0
        b.Text = txt
        b.Font = Enum.Font.GothamBlack
        b.TextSize = 14
        b.TextColor3 = COLORS.White
        b.Parent = row
        corner(b, 6)
        return b
    end
    local left = mkArr("<", -156)
    local right = mkArr(">", -64)
    left.MouseButton1Click:Connect(function()
        applyUIScale(Config.UIScale - 5)
        valLbl.Text = tostring(Config.UIScale)
        saveConfig()
    end)
    right.MouseButton1Click:Connect(function()
        applyUIScale(Config.UIScale + 5)
        valLbl.Text = tostring(Config.UIScale)
        saveConfig()
    end)
end


do
    Config.StealBarSize = math.clamp(tonumber(Config.StealBarSize) or 50, 35, 90)
    local row = rowBase(settings, "Steal Bar Size", false)
    local valLbl = Instance.new("TextLabel")
    valLbl.BackgroundTransparency = 1
    valLbl.Size = UDim2.new(0, 48, 0, 22)
    valLbl.Position = UDim2.new(1, -120, 0.5, -11)
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 13
    valLbl.TextColor3 = COLORS.White
    valLbl.Text = tostring(Config.StealBarSize or 50)
    valLbl.TextXAlignment = Enum.TextXAlignment.Center
    valLbl.Parent = row
    local function mkArr(txt, x)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 28, 0, 22)
        b.Position = UDim2.new(1, x, 0.5, -11)
        b.BackgroundColor3 = COLORS.Badge
        b.BackgroundTransparency = 0.25
        b.BorderSizePixel = 0
        b.Text = txt
        b.Font = Enum.Font.GothamBlack
        b.TextSize = 14
        b.TextColor3 = COLORS.White
        b.Parent = row
        corner(b, 6)
        return b
    end
    local left = mkArr("<", -156)
    local right = mkArr(">", -64)
    left.MouseButton1Click:Connect(function()
        Config.StealBarSize = math.clamp((Config.StealBarSize or 50) - 5, 35, 90)
        valLbl.Text = tostring(Config.StealBarSize)
        if StealSys and StealSys.applyBarSize then StealSys.applyBarSize() end
        saveConfig()
    end)
    right.MouseButton1Click:Connect(function()
        Config.StealBarSize = math.clamp((Config.StealBarSize or 50) + 5, 35, 90)
        valLbl.Text = tostring(Config.StealBarSize)
        if StealSys and StealSys.applyBarSize then StealSys.applyBarSize() end
        saveConfig()
    end)
end

toggleRow(settings, "Lock UI", Config.LockUI, function(state)
    Config.LockUI = state
    main.Draggable = not state
end)

do
    local hideRow = rowBase(settings, "Hide UI", false)
    keybindBadge(hideRow, Config.HideUIKey, -60, 34, function(key)
        Config.HideUIKey = key
        saveConfig()
    end)
end


sectionLabel(settings, "MOBILE BUTTONS")
do
    local row = rowBase(settings, "Button Size", false)
    local valLbl = Instance.new("TextLabel")
    valLbl.BackgroundTransparency = 1
    valLbl.Size = UDim2.new(0, 48, 0, 22)
    valLbl.Position = UDim2.new(1, -120, 0.5, -11)
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 13
    valLbl.TextColor3 = COLORS.White
    valLbl.Text = tostring(Config.MobileButtonSize or 50)
    valLbl.TextXAlignment = Enum.TextXAlignment.Center
    valLbl.Parent = row
    local function mkArr(txt, x)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 28, 0, 22)
        b.Position = UDim2.new(1, x, 0.5, -11)
        b.BackgroundColor3 = COLORS.Badge
        b.BackgroundTransparency = 0.25
        b.BorderSizePixel = 0
        b.Text = txt
        b.Font = Enum.Font.GothamBlack
        b.TextSize = 14
        b.TextColor3 = COLORS.White
        b.Parent = row
        corner(b, 6)
        return b
    end
    local left = mkArr("<", -156)
    local right = mkArr(">", -64)
    left.MouseButton1Click:Connect(function()
        Config.MobileButtonSize = math.clamp((Config.MobileButtonSize or 50) - 5, 10, 125)
        valLbl.Text = tostring(Config.MobileButtonSize)
        if _G.VyzeApplyMobileButtonSize then pcall(_G.VyzeApplyMobileButtonSize) end
        saveConfig()
    end)
    right.MouseButton1Click:Connect(function()
        Config.MobileButtonSize = math.clamp((Config.MobileButtonSize or 50) + 5, 10, 125)
        valLbl.Text = tostring(Config.MobileButtonSize)
        if _G.VyzeApplyMobileButtonSize then pcall(_G.VyzeApplyMobileButtonSize) end
        saveConfig()
    end)
end

toggleRow(settings, "Circle Buttons", Config.CircleButtons, function(state)
    Config.CircleButtons = state
    if _G.VyzeApplyMobileButtonShape then pcall(_G.VyzeApplyMobileButtonShape) end
end)

do
    local row = rowBase(settings, "Reset Buttons Position", false)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 72, 0, 24)
    btn.Position = UDim2.new(1, -84, 0.5, -12)
    btn.BackgroundColor3 = COLORS.Badge
    btn.BackgroundTransparency = 0.15
    btn.BorderSizePixel = 0
    btn.Text = "RESET"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = COLORS.White
    btn.Parent = row
    corner(btn, 8)
    btn.MouseButton1Click:Connect(function()
        if _G.VyzeResetMobileButtons then pcall(_G.VyzeResetMobileButtons) end
        btn.Text = "DONE"
        task.delay(1.2, function() if btn and btn.Parent then btn.Text = "RESET" end end)
    end)
end

sectionLabel(settings, "INTRO")
toggleRow(settings, "Intro", Config.IntroEnabled, function(state)
    Config.IntroEnabled = state
end)

do
    local row = rowBase(settings, "Save Settings", false)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 0, 24)
    btn.Position = UDim2.new(1, -102, 0.5, -12)
    btn.BackgroundColor3 = COLORS.Badge
    btn.BackgroundTransparency = 0.15
    btn.BorderSizePixel = 0
    btn.Text = "SAVE"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = COLORS.White
    btn.Parent = row
    corner(btn, 8)
    btn.MouseButton1Click:Connect(function()
        saveConfig()
        btn.Text = "SAVED!"
        task.delay(3, function() if btn and btn.Parent then btn.Text = "SAVE" end end)
    end)
end

do
    local row = rowBase(settings, "Reset All Settings", false)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 0, 24)
    btn.Position = UDim2.new(1, -102, 0.5, -12)
    btn.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
    btn.BackgroundTransparency = 0.1
    btn.BorderSizePixel = 0
    btn.Text = "RESET"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = COLORS.White
    btn.Parent = row
    corner(btn, 8)
    btn.MouseButton1Click:Connect(function()

        Config.NormalSpeed = 59.5
        Config.CarrySpeed = 29
        Config.TPDownHeight = 20
        Config.AutoCarrySpeed = false
        Config.LaggerSpeed = 40
        Config.LaggerCarry = 20
        Config.BatAimbot = false
        Config.AutoSwing = true
        Config.AutoSteal = false
        Config.InfiniteJump = false
        Config.AntiRagdoll = false
        Config.BatCounter = false
        Config.MedusaCounter = false
        Config.AntiDie = false
        Config.SafeMode = false
        Config.PlayerESP = false
        Config.PlayerTracers = false
        Config.RagdollCountdown = false
        Config.CustomAnim = false
        Config.AntiLag = false
        Config.StretchRes = false
        Config.FOVChange = false
        Config.FOVValue = 70
        Config.UIScale = 50
        Config.LockUI = false
        Config.HideUI = false
        Config.StealBarPosX = nil
        Config.StealBarPosY = nil
        uiMinimized = false
        miniRestoreButton.Visible = false
        Config.MobileButtonSize = 50
        Config.CircleButtons = false
        Config.IntroEnabled = true
        applyUIScale(50)
        main.Draggable = true
        main.Visible = true
        if State.autoBatToggled and stopBatAimbot then pcall(stopBatAimbot); State.autoBatToggled = false end
        if stopPlayerEsp then pcall(stopPlayerEsp) end
        if stopPlayerTracers then pcall(stopPlayerTracers) end
        if stopAntiDie then pcall(stopAntiDie) end
        if disableAntiLag then pcall(disableAntiLag) end
        if disableStretchRez then pcall(disableStretchRez) end
        if disableCustomFov then pcall(disableCustomFov) end
        if stopAutoStealSystem then pcall(stopAutoStealSystem) end
        saveConfig()
        btn.Text = "DONE"
        task.delay(1.5, function() if btn and btn.Parent then btn.Text = "RESET" end end)
    end)
end



movement.Visible = true




local _aimbotTarget = nil
local Conns = { aimbot = nil }



-- EnvyHub-style adaptive prediction, while retaining Peak Hub's bypass movement.
local BAT_PREDICTION_MIN = 0.05
local BAT_PREDICTION_MAX = 0.12
local BAT_PREDICTION_CACHE = {}

local function getEnvyPredictedPosition(target)
    local now = tick()
    local sample = BAT_PREDICTION_CACHE[target]
    local targetVelocity = Vector3.zero

    if not sample then
        BAT_PREDICTION_CACHE[target] = {
            pos = target.Position,
            time = now,
            vel = Vector3.zero
        }
    else
        local sampleDt = math.clamp(now - sample.time, 1 / 120, 0.25)
        local rawVelocity = (target.Position - sample.pos) / sampleDt
        if rawVelocity.Magnitude > 80 then
            rawVelocity = rawVelocity.Unit * 80
        end
        sample.vel = sample.vel:Lerp(rawVelocity, 0.25)
        sample.pos = target.Position
        sample.time = now
        targetVelocity = sample.vel
    end

    local predictionTime = math.clamp(targetVelocity.Magnitude / 130, BAT_PREDICTION_MIN, BAT_PREDICTION_MAX)
    return target.Position + targetVelocity * predictionTime + Vector3.new(0, 1, 0)
end

function findBat()
    local char = LP.Character
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end
        end
    end
    return nil
end

function getClosestTarget()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if tRoot and hum and hum.Health > 0 then
                local dist = (tRoot.Position - root.Position).Magnitude
                if dist < minDist then minDist = dist; closest = tRoot end
            end
        end
    end
    return closest
end

local batSwingCooldown = false

function tryBatSwing()
    if batSwingCooldown then return end
    batSwingCooldown = true
    pcall(function()
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum then return end
        local bat = char:FindFirstChildOfClass("Tool")
        if not bat or not (bat.Name:lower():find("bat",1,true) or bat.Name:lower():find("slap",1,true)) then
            bat = findBat()
            if bat then pcall(function() hum:EquipTool(bat) end) end
        end
        if bat and bat:IsA("Tool") and (bat.Name:lower():find("bat",1,true) or bat.Name:lower():find("slap",1,true)) then
            bat:Activate()
        end
    end)
    task.delay(0.3, function() batSwingCooldown = false end)
end

function getAimbotChaseSpeed()
    local laggerActive = (laggerModeEnabled == true)
        or (laggerCarryActive == true)
        or (laggerSpeedEnabled == true)
        or (laggerCarryEnabled == true)
    local keyName = type(Config.LaggerCarryKey) == "string" and Config.LaggerCarryKey or ""
    if keyName ~= "" then
        local ok, keyCode = pcall(function() return Enum.KeyCode[keyName] end)
        if ok and keyCode and UserInputService:IsKeyDown(keyCode) then laggerActive = true end
    end
    if laggerActive then return math.max(0, tonumber(Config.LaggerSpeed) or 40) end
    return math.max(0, tonumber(Config.AimbotSpeed) or 58)
end

startBatAimbot=function()
    if safeModeTryStart and not safeModeTryStart() then return end
    -- Equipaggiamento iniziale singolo; mai forzato di nuovo durante il loop.
    pcall(peakEquipBatOnce)
    if Conns.aimbot then Conns.aimbot:Disconnect(); Conns.aimbot=nil end
    mirrorTPActive=true
    table.clear(mirrorTPPreviousY)
    if syncAutoAntiDie then pcall(syncAutoAntiDie) end

    local hum0=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum0 then hum0.AutoRotate=false end

    Conns.aimbot=RunService.RenderStepped:Connect(function(dt)
        if not State.autoBatToggled then return end
        local char=LP.Character
        if not char then return end
        local root=char:FindFirstChild("HumanoidRootPart")
        local hum=char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health<=0 then return end

        hum.AutoRotate=false
        -- Non forzare l'equipaggiamento ogni frame: il player può usare
        -- un altro Tool. La mazza viene equipaggiata solo all'attivazione;
        -- Auto Swing riparte quando la mazza è equipaggiata manualmente.
        local target=getClosestTarget()
        if not target then
            _aimbotTarget=nil
            root.AssemblyAngularVelocity=Vector3.zero
            return
        end
        _aimbotTarget=target

        -- Prediction adattiva per inseguire la traiettoria del target.
        -- La logica di movimento/bypass Peak resta invariata: si aggiornano solo
        -- il punto d'inseguimento e la direzione dello sguardo.
        local actualTargetPos=target.Position
        local predictedPos=getEnvyPredictedPosition(target)

        -- Stima la direzione in cui il target si sta muovendo; se è quasi fermo,
        -- usa la direzione del suo personaggio come fallback stabile.
        local targetVelocity=target.AssemblyLinearVelocity
        local targetMoveForward=Vector3.new(targetVelocity.X,0,targetVelocity.Z)
        if targetMoveForward.Magnitude>1.5 then
            targetMoveForward=targetMoveForward.Unit
        else
            targetMoveForward=Vector3.new(target.CFrame.LookVector.X,0,target.CFrame.LookVector.Z)
            if targetMoveForward.Magnitude>0.001 then
                targetMoveForward=targetMoveForward.Unit
            else
                targetMoveForward=Vector3.zero
            end
        end

        local frontOffset=2.5
        local frontTargetPos=predictedPos+targetMoveForward*frontOffset
        local chasePos=frontTargetPos
        local actualDelta=actualTargetPos-root.Position
        local actualFlat=Vector3.new(actualDelta.X,0,actualDelta.Z)
        local predictedDelta=predictedPos-root.Position
        local predictedFlat=Vector3.new(predictedDelta.X,0,predictedDelta.Z)
        local moveDelta=chasePos-root.Position
        local moveFlat=Vector3.new(moveDelta.X,0,moveDelta.Z)
        local actualDistance=actualDelta.Magnitude

        -- Vicino al target riduce l'offset, ma continua a usare la prediction
        -- per anticiparne il movimento ed evitare cambi bruschi avanti/indietro.
        if actualFlat.Magnitude < 9 then
            local nearOffset=math.clamp(actualFlat.Magnitude/9,0.35,1) * frontOffset
            chasePos=predictedPos+targetMoveForward*nearOffset
            moveDelta=chasePos-root.Position
            moveFlat=Vector3.new(moveDelta.X,0,moveDelta.Z)
        end

        -- Guarda verso il punto previsto, cioè dove il target sta andando.
        local lookDelta=Vector3.new(chasePos.X-root.Position.X,0,chasePos.Z-root.Position.Z)
        if lookDelta.Magnitude < 0.05 then
            lookDelta=predictedFlat
        end
        if lookDelta.Magnitude > 0.05 then
            local desiredCF=CFrame.lookAt(root.Position, root.Position+lookDelta.Unit)
            local alpha=1-math.exp(-math.clamp(dt,0,0.1)*12)
            root.CFrame=root.CFrame:Lerp(desiredCF,alpha)
        end
        root.AssemblyAngularVelocity=Vector3.zero

        local chaseSpeed=getAimbotChaseSpeed()
        if moveFlat.Magnitude > 0.05 then
            local moveUnit=moveFlat.Unit
            _speedLVSet(root,moveUnit.X*chaseSpeed,moveUnit.Z*chaseSpeed)
        else
            _speedLVClear(root)
        end

        -- Vertical tracking remains separate from horizontal movement.
        local desiredHeight=chasePos.Y+3.7
        local yVel=(desiredHeight-root.Position.Y)*19.5
        if hum.FloorMaterial~=Enum.Material.Air then yVel=math.max(yVel,13) end
        yVel=math.clamp(yVel,-70,110)
        local currentY=root.AssemblyLinearVelocity.Y
        root.AssemblyLinearVelocity=Vector3.new(root.AssemblyLinearVelocity.X,currentY+(yVel-currentY)*0.8,root.AssemblyLinearVelocity.Z)

        -- Auto Swing only when Bat Aimbot is enabled and an actual bat/slap tool is equipped.
        local equippedTool=char:FindFirstChildOfClass("Tool")
        local isBatEquipped=equippedTool and (equippedTool.Name:lower():find("bat",1,true) or equippedTool.Name:lower():find("slap",1,true))
        if Config.AutoSwing and Config.BatAimbot and State.autoBatToggled and isBatEquipped and actualDistance<=8 then
            tryBatSwing()
        end
    end)
end

stopBatAimbot=function()
    if Conns.aimbot then Conns.aimbot:Disconnect();Conns.aimbot=nil end
    _aimbotTarget=nil;batSwingCooldown=false
    BAT_PREDICTION_CACHE={}
    local c=LP.Character
    local root=c and c:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity=Vector3.zero
        root.AssemblyAngularVelocity=Vector3.zero
    end
    local hum2=c and c:FindFirstChildOfClass("Humanoid")
    if hum2 then hum2.AutoRotate=true end
    State.hittingCooldown=false
    mirrorTPActive=false
    table.clear(mirrorTPPreviousY)
    if syncAutoAntiDie then pcall(syncAutoAntiDie) end
end

do
    local MIRROR_TP_DROP_THRESHOLD = 3
    local MIRROR_TP_DOWN_Y = -7
    local mirrorTPDownPreviousY = {}
    local mirrorTPLastTeleport = 0

    local function mirrorTPDownActive()
        return mirrorTPDownEnabled == true and State.autoBatToggled == true
    end

    local function mirrorTeleportLocalPlayerDown()
        local character = LP.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 then return end
        local now = tick()
        if now - mirrorTPLastTeleport < 0.08 then return end
        mirrorTPLastTeleport = now
        local _, yaw = root.CFrame:ToEulerAnglesYXZ()
        root.CFrame = CFrame.new(root.Position.X, MIRROR_TP_DOWN_Y, root.Position.Z)
            * CFrame.Angles(0, yaw, 0)
        root.Velocity = Vector3.zero
        pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
    end

    RunService.Heartbeat:Connect(function()
        if not mirrorTPDownActive() then
            table.clear(mirrorTPDownPreviousY)
            return
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP and player.Character then
                local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local currentY = targetRoot.Position.Y
                    local previousY = mirrorTPDownPreviousY[player.UserId]
                    if previousY and previousY - currentY >= MIRROR_TP_DROP_THRESHOLD then
                        pcall(mirrorTeleportLocalPlayerDown)
                        table.clear(mirrorTPDownPreviousY)
                        return
                    end
                    mirrorTPDownPreviousY[player.UserId] = currentY
                end
            end
        end
    end)
end




local antiDieHeartConn = nil
local antiDieDeathConns = {}
local antiDieCharConn = nil
local antiDieActive = false
local _isInstaResetting = false

function isRagdollState(hum)
    if not hum then return true end
    local st = hum:GetState()
    return hum.PlatformStand
        or st == Enum.HumanoidStateType.Physics
        or st == Enum.HumanoidStateType.Ragdoll
        or st == Enum.HumanoidStateType.FallingDown
end

function protectCharAntiDie(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
    if not hum then return end

    pcall(function()
        hum.BreakJointsOnDeath = false
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    end)

    local sc = hum.StateChanged:Connect(function(_, new)
        if not antiDieActive or _isInstaResetting then return end
        if new == Enum.HumanoidStateType.Dead then
            pcall(function()
                hum.Health = math.huge
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            end)
        end
    end)
    table.insert(antiDieDeathConns, sc)

    local hc = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if not antiDieActive or _isInstaResetting then return end
        if hum.Health < hum.MaxHealth then
            pcall(function() hum.Health = math.huge end)
        end
    end)
    table.insert(antiDieDeathConns, hc)

    if antiDieHeartConn then antiDieHeartConn:Disconnect() end
    antiDieHeartConn = RunService.Heartbeat:Connect(function()
        if not antiDieActive or _isInstaResetting then return end
        if hum and hum.Parent and hum.Health < hum.MaxHealth then
            pcall(function() hum.Health = math.huge end)
        end
    end)
end

startAntiDie = function()
    if antiDieActive then return end
    antiDieActive = true
    for _, c in ipairs(antiDieDeathConns) do pcall(function() c:Disconnect() end) end
    antiDieDeathConns = {}
    if antiDieHeartConn then antiDieHeartConn:Disconnect(); antiDieHeartConn = nil end
    if antiDieCharConn then antiDieCharConn:Disconnect(); antiDieCharConn = nil end
    protectCharAntiDie(LP.Character)
    antiDieCharConn = LP.CharacterAdded:Connect(function(c)
        if not antiDieActive then return end
        task.wait(0.1)
        for _, c2 in ipairs(antiDieDeathConns) do pcall(function() c2:Disconnect() end) end
        antiDieDeathConns = {}
        protectCharAntiDie(c)
    end)
end

stopAntiDie = function()
    antiDieActive = false
    for _, c in ipairs(antiDieDeathConns) do pcall(function() c:Disconnect() end) end
    antiDieDeathConns = {}
    if antiDieHeartConn then antiDieHeartConn:Disconnect(); antiDieHeartConn = nil end
    if antiDieCharConn then antiDieCharConn:Disconnect(); antiDieCharConn = nil end
    local c = LP.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if h then
        pcall(function()
            h:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            h.MaxHealth = 100
            if h.Health > 100 then h.Health = 100 end
        end)
    end
end


syncAutoAntiDie = function()
    local need = (Config.AntiDie == true)
        or (Config.BatAimbot == true)
        or (State.autoBatToggled == true)
        or (dropActive == true)
    if need then
        if startAntiDie then startAntiDie() end
    else
        if stopAntiDie then stopAntiDie() end
    end
end

function __vyzeInitMiscLogic()









local infiniteJumpGamepadHeld = false
local infiniteJumpTouchHeld = false
local infiniteJumpMobileConns = {}

local function applyInfiniteJumpVelocity()
    if not Config.InfiniteJump then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hum or not root or hum.Health <= 0 then return end

    local vx, vz = 0, 0
    pcall(function()
        local plane = VyzeSpeed.getPlane and VyzeSpeed.getPlane()
        if plane then vx, vz = plane.X, plane.Y end
    end)
    if math.abs(vx) < 0.05 and math.abs(vz) < 0.05 then
        local md = hum.MoveDirection
        if md.Magnitude > 0.05 then
            local spd = 16
            pcall(function() spd = getActiveSpeed() or 16 end)
            vx, vz = md.X * spd, md.Z * spd
        end
    end
    root.Velocity = Vector3.new(vx, 55, vz)
end


UserInputService.JumpRequest:Connect(function()
    if not Config.InfiniteJump or Config.InfJumpMode == "Hold" then return end
    if UserInputService:GetFocusedTextBox() then return end
    applyInfiniteJumpVelocity()
end)

local function isInfiniteJumpGamepad(input)
    local t = input.UserInputType
    return t == Enum.UserInputType.Gamepad1 or t == Enum.UserInputType.Gamepad2
        or t == Enum.UserInputType.Gamepad3 or t == Enum.UserInputType.Gamepad4
        or t == Enum.UserInputType.Gamepad5 or t == Enum.UserInputType.Gamepad6
        or t == Enum.UserInputType.Gamepad7 or t == Enum.UserInputType.Gamepad8
end
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode == Enum.KeyCode.ButtonA and isInfiniteJumpGamepad(input) then
        infiniteJumpGamepadHeld = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.ButtonA and isInfiniteJumpGamepad(input) then
        infiniteJumpGamepadHeld = false
    end
end)

local function bindInfiniteJumpMobileButton(button)
    for _, conn in ipairs(infiniteJumpMobileConns) do pcall(function() conn:Disconnect() end) end
    table.clear(infiniteJumpMobileConns)
    infiniteJumpTouchHeld = false
    if not button or not button:IsA("GuiButton") then return end
    table.insert(infiniteJumpMobileConns, button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then infiniteJumpTouchHeld = true end
    end))
    table.insert(infiniteJumpMobileConns, button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then infiniteJumpTouchHeld = false end
    end))
    table.insert(infiniteJumpMobileConns, button.AncestryChanged:Connect(function(_, parent)
        if not parent then infiniteJumpTouchHeld = false end
    end))
end
if UserInputService.TouchEnabled then
    local pg = LP:WaitForChild("PlayerGui")
    local function findJumpButton()
        local button = pg:FindFirstChild("JumpButton", true)
        if button and button:IsA("GuiButton") then bindInfiniteJumpMobileButton(button) end
    end
    pg.DescendantAdded:Connect(function(descendant)
        if descendant.Name == "JumpButton" and descendant:IsA("GuiButton") then
            bindInfiniteJumpMobileButton(descendant)
        end
    end)
    task.defer(findJumpButton)
end

RunService.PreSimulation:Connect(function()
    if not Config.InfiniteJump or Config.InfJumpMode ~= "Hold" then return end
    if UserInputService:GetFocusedTextBox() then return end
    local held = false
    pcall(function() held = UserInputService:IsKeyDown(Enum.KeyCode.Space) end)
    if not held then
        held = infiniteJumpGamepadHeld or infiniteJumpTouchHeld
    end
    if held then applyInfiniteJumpVelocity() end
end)


local function keyMatches(cfgKey, keyName)
    if not cfgKey or cfgKey == "" or cfgKey == "None" or cfgKey == "NONE" then return false end
    return tostring(cfgKey):upper() == tostring(keyName):upper()
end

UserInputService.InputBegan:Connect(function(input, gp)
    if keybindCaptureActive then return end
    local isKb = input.UserInputType == Enum.UserInputType.Keyboard
    local isPad = input.UserInputType == Enum.UserInputType.Gamepad1
    if not (isKb or isPad) then return end
    local keyName = input.KeyCode.Name

end)




local AntiRagdollV1 = {
    Enabled = false,
    HeartbeatThread = false,
    CharacterConnection = nil,
    CameraConnection = nil,
    CachedCharacter = nil,
    IsBoosting = false,
    LastBoostTime = 0,
    Connections = {},
}

local function cacheAntiRagdollCharacter()
    local char = LP.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return false end
    AntiRagdollV1.CachedCharacter = { character = char, humanoid = hum, root = root }
    return true
end

local function isAntiRagdollCharacterDown()
    local cached = AntiRagdollV1.CachedCharacter
    if not cached or not cached.humanoid or not cached.humanoid.Parent then return false end
    local state = cached.humanoid:GetState()
    return state == Enum.HumanoidStateType.Physics
        or state == Enum.HumanoidStateType.Ragdoll
        or state == Enum.HumanoidStateType.FallingDown
        or cached.humanoid.PlatformStand
end

local function forceAntiRagdollRecovery()
    local cached = AntiRagdollV1.CachedCharacter
    if not cached or not cached.character or not cached.humanoid or not cached.root then return end
    local char, hum, root = cached.character, cached.humanoid, cached.root
    if not char.Parent or not hum.Parent or not root.Parent or hum.Health <= 0 then return end

    pcall(function()
        LP:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow())
    end)

    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BallSocketConstraint")
            or (obj:IsA("Attachment") and string.find(obj.Name, "RagdollAttachment", 1, true)) then
            pcall(function() obj:Destroy() end)
        end
    end

    AntiRagdollV1.IsBoosting = true
    AntiRagdollV1.LastBoostTime = os.clock()
    pcall(function()
        root.Anchored = false
        hum.PlatformStand = false
        hum.Sit = false
        hum.AutoRotate = true
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end)
end

local function startAntiRagdollLH()
    if AntiRagdollV1.Enabled then return end
    AntiRagdollV1.Enabled = true
    cacheAntiRagdollCharacter()

    AntiRagdollV1.CameraConnection = RunService.RenderStepped:Connect(function()
        if not AntiRagdollV1.Enabled then return end
        local cached = AntiRagdollV1.CachedCharacter
        local cam = workspace.CurrentCamera
        if cam and cached and cached.humanoid and cached.humanoid.Parent then
            cam.CameraSubject = cached.humanoid
        end
    end)

    AntiRagdollV1.CharacterConnection = LP.CharacterAdded:Connect(function()
        task.wait(0.25)
        cacheAntiRagdollCharacter()
    end)

    task.spawn(function()
        while AntiRagdollV1.Enabled do
            task.wait(0.05)
            if not AntiRagdollV1.CachedCharacter
                or not AntiRagdollV1.CachedCharacter.humanoid
                or not AntiRagdollV1.CachedCharacter.humanoid.Parent
                or not AntiRagdollV1.CachedCharacter.root
                or not AntiRagdollV1.CachedCharacter.root.Parent then
                cacheAntiRagdollCharacter()
            end

            if isAntiRagdollCharacterDown() then
                forceAntiRagdollRecovery()
            elseif AntiRagdollV1.IsBoosting then
                if os.clock() - AntiRagdollV1.LastBoostTime > 0.35 then
                    AntiRagdollV1.IsBoosting = false
                end
            end
        end
    end)
end

local function stopAntiRagdollLH()
    AntiRagdollV1.Enabled = false
    AntiRagdollV1.IsBoosting = false
    if AntiRagdollV1.CameraConnection then
        AntiRagdollV1.CameraConnection:Disconnect()
        AntiRagdollV1.CameraConnection = nil
    end
    if AntiRagdollV1.CharacterConnection then
        AntiRagdollV1.CharacterConnection:Disconnect()
        AntiRagdollV1.CharacterConnection = nil
    end
    for _, conn in ipairs(AntiRagdollV1.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(AntiRagdollV1.Connections)
    AntiRagdollV1.CachedCharacter = nil
end

_G._VyzeStartAntiRagdoll = startAntiRagdollLH
_G._VyzeStopAntiRagdoll = stopAntiRagdollLH
if Config.AntiRagdoll then startAntiRagdollLH() end


local BAT_COUNTER_SLAP_LIST = {
    "Bat", "Slap", "Iron Slap", "Gold Slap", "Diamond Slap", "Emerald Slap",
    "Ruby Slap", "Dark Matter Slap", "Flame Slap", "Nuclear Slap", "Galaxy Slap", "Glitched Slap",
}
local batCounterConn = nil
local batCounterDebounce = false
local batCounterWasRagdoll = false


local function brieflyFaceNearestPlayer(char, duration)
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
    if not root or not root:IsA("BasePart") then return end
    local targetRoot, bestDistance = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local otherRoot = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso")
            local otherHum = player.Character:FindFirstChildOfClass("Humanoid")
            if otherRoot and otherRoot:IsA("BasePart") and otherHum and otherHum.Health > 0 then
                local distance = (otherRoot.Position - root.Position).Magnitude
                if distance < bestDistance then
                    bestDistance, targetRoot = distance, otherRoot
                end
            end
        end
    end
    if not targetRoot then return end
    local untilTime = tick() + (duration or 0.1)
    task.spawn(function()
        while tick() < untilTime and Config.BatCounter and LP.Character == char and root.Parent and targetRoot.Parent do
            local pos = root.Position
            local targetPos = targetRoot.Position
            local flatTarget = Vector3.new(targetPos.X, pos.Y, targetPos.Z)
            if (flatTarget - pos).Magnitude > 0.01 then
                root.CFrame = CFrame.lookAt(pos, flatTarget)
            end
            RunService.Heartbeat:Wait()
        end
    end)
end

function findBatForCounter()
    local c = LP.Character
    if not c then return nil end
    local bp = LP:FindFirstChild("Backpack") or LP:FindFirstChildOfClass("Backpack")
    for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do
        local t = c:FindFirstChild(name) or (bp and bp:FindFirstChild(name))
        if t then return t end
    end
    for _, ch in ipairs(c:GetChildren()) do
        if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
    end
    if bp then
        for _, ch in ipairs(bp:GetChildren()) do
            if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
        end
    end
    return nil
end

function swingBatForCounter(bat, char)
    if not bat or not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if bat.Parent ~= char then
        if hum then pcall(function() hum:EquipTool(bat) end) end
        task.wait(0.05)
    end
    local remote = bat:FindFirstChildOfClass("RemoteEvent") or bat:FindFirstChildOfClass("RemoteFunction")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer() end)
        task.wait(0.15)
        pcall(function() remote:FireServer() end)
    else
        pcall(function() bat:Activate() end)
        task.wait(0.15)
        pcall(function() bat:Activate() end)
    end
end

function counterIsRagdoll(hum)
    if not hum then return false end
    local st = hum:GetState()
    return st == Enum.HumanoidStateType.Physics
        or st == Enum.HumanoidStateType.Ragdoll
        or st == Enum.HumanoidStateType.FallingDown
        or hum.PlatformStand == true
end

startBatCounter = function()
    if batCounterConn then return end
    batCounterWasRagdoll = false
    batCounterDebounce = false
    local lastTrigger = 0

    batCounterConn = RunService.Heartbeat:Connect(function()
        if not Config.BatCounter then
            batCounterWasRagdoll = false
            return
        end
        -- Match VX7: don't counter while Bat TP / smart Bat TP is controlling movement.
        if Config.BatTP or Config._smartBatTpDriving or Config._instaResetInProgress then
            batCounterWasRagdoll = false
            return
        end

        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum then return end
        local ragdolledNow = hum:GetState() == Enum.HumanoidStateType.Physics
        if not (ragdolledNow and not batCounterWasRagdoll) then
            batCounterWasRagdoll = ragdolledNow
            return
        end
        batCounterWasRagdoll = true
        if batCounterDebounce or os.clock() - lastTrigger < 0.1 then return end
        lastTrigger = os.clock()
        batCounterDebounce = true

        task.spawn(function()
            local function release()
                batCounterDebounce = false
            end
            local ok, err = pcall(function()
                if not Config.BatCounter or Config.BatTP or Config._smartBatTpDriving then return end
                local currentChar = LP.Character
                local root = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
                local currentHum = currentChar and currentChar:FindFirstChildOfClass("Humanoid")
                if not currentChar or not root or not currentHum then return end

                -- VX7-style target selection: nearest living opponent is required.
                local targetRoot, bestDistance = nil, math.huge
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LP and player.Character then
                        local otherRoot = player.Character:FindFirstChild("HumanoidRootPart")
                        local otherHum = player.Character:FindFirstChildOfClass("Humanoid")
                        if otherRoot and otherHum and otherHum.Health > 0 then
                            local distance = (otherRoot.Position - root.Position).Magnitude
                            if distance < bestDistance then
                                bestDistance, targetRoot = distance, otherRoot
                            end
                        end
                    end
                end
                if not targetRoot then return end

                local bat = findBatForCounter()
                if not bat then return end
                if bat.Parent ~= currentChar then
                    pcall(function() currentHum:EquipTool(bat) end)
                    task.wait(0.015)
                end
                if not Config.BatCounter or Config.BatTP or Config._smartBatTpDriving or Config._instaResetInProgress then return end
                currentChar = LP.Character
                root = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
                currentHum = currentChar and currentChar:FindFirstChildOfClass("Humanoid")
                if not root or not currentHum or not targetRoot.Parent then return end

                -- Briefly face the target, then swing once using the equipped bat.
                local targetPos = targetRoot.Position
                local flatTarget = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
                if (flatTarget - root.Position).Magnitude > 0.001 then
                    currentHum.AutoRotate = false
                    root.CFrame = CFrame.lookAt(root.Position, flatTarget)
                end
                task.wait(0.02)
                if bat.Parent == currentChar then
                    pcall(function()
                        bat:Activate()
                        local remote = bat:FindFirstChildWhichIsA("RemoteEvent")
                        if remote then remote:FireServer() end
                    end)
                else
                    swingBatForCounter(bat, currentChar)
                end
                task.wait(0.2)
                if root and root.Parent then
                    pcall(function()
                        root.RotVelocity = Vector3.zero
                        root.AssemblyAngularVelocity = Vector3.zero
                    end)
                end
                if currentHum and currentHum.Parent then currentHum.AutoRotate = true end
            end)
            if not ok then warn("[Peak Hub] Bat Counter:", err) end
            release()
        end)
    end)
end

stopBatCounter = function()
    if batCounterConn then
        batCounterConn:Disconnect()
        batCounterConn = nil
    end
    batCounterDebounce = false
    batCounterWasRagdoll = false
end

local MEDUSA_COOLDOWN = 25
local medConns = {}
local medDebounce = false
local medLastUsed = 0

function findMedusa()
    local c = LP.Character
    if not c then return nil end
    for _, t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") then
            local n = t.Name:lower()
            if n:find("medusa") or n:find("head") or n:find("stone") then return t end
        end
    end
    local bp = LP:FindFirstChild("Backpack") or LP:FindFirstChildOfClass("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                local n = t.Name:lower()
                if n:find("medusa") or n:find("head") or n:find("stone") then return t end
            end
        end
    end
    return nil
end

function useMedusaCounter()
    if not Config.MedusaCounter then return end
    if medDebounce then return end
    if tick() - medLastUsed < MEDUSA_COOLDOWN then return end
    local c = LP.Character
    if not c then return end
    medDebounce = true
    local med = findMedusa()
    if not med then
        medDebounce = false
        return
    end
    if med.Parent ~= c then
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum:EquipTool(med) end) end
        task.wait(0.05)
    end
    pcall(function() med:Activate() end)
    medLastUsed = tick()
    medDebounce = false
end

function onMedusaAnchorChanged(part)
    return part:GetPropertyChangedSignal("Anchored"):Connect(function()
        if Config.MedusaCounter and part.Anchored and part.Transparency == 1 then
            useMedusaCounter()
        end
    end)
end

startMedusaCounter = function(char)
    stopMedusaCounter()
    char = char or LP.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(medConns, onMedusaAnchorChanged(part))
        end
    end
    table.insert(medConns, char.DescendantAdded:Connect(function(part)
        if part:IsA("BasePart") then
            table.insert(medConns, onMedusaAnchorChanged(part))
        end
    end))
end

stopMedusaCounter = function()
    for _, c in pairs(medConns) do
        pcall(function() c:Disconnect() end)
    end
    medConns = {}
    medDebounce = false
end

LP.CharacterAdded:Connect(function(c)
    if Config.MedusaCounter then
        task.wait(0.2)
        startMedusaCounter(c)
    end
end)


end
__vyzeInitMiscLogic()




local MIRROR_TP_DROP_THRESHOLD = 3
local MIRROR_TP_DOWN_Y = -7.00
local mirrorTPLastTeleport = 0

function mirrorTPTeleportDown()
    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return end

    local now = tick()
    if now - (mirrorTPLastTeleport or 0) < 0.08 then return end
    mirrorTPLastTeleport = now

    local _, yaw = root.CFrame:ToEulerAnglesYXZ()
    local y = (MIRROR_TP_DOWN_Y or -7) + (math.random() * 0.6 - 0.3)
    root.CFrame = CFrame.new(root.Position.X, y, root.Position.Z) * CFrame.Angles(0, yaw, 0)
    root.AssemblyLinearVelocity = Vector3.new((math.random() - 0.5) * 0.4, 0, (math.random() - 0.5) * 0.4)
end

RunService.Heartbeat:Connect(function()
    if not mirrorTPActive or not State.autoBatToggled then
        if next(mirrorTPPreviousY) then
            table.clear(mirrorTPPreviousY)
        end
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local currentY = root.Position.Y
                local previousY = mirrorTPPreviousY[plr.UserId]
                if previousY and previousY - currentY >= (MIRROR_TP_DROP_THRESHOLD or 3) then
                    pcall(mirrorTPTeleportDown)
                    table.clear(mirrorTPPreviousY)
                    return
                end
                mirrorTPPreviousY[plr.UserId] = currentY
            end
        end
    end
end)






local noCamCollisionOriginal = setmetatable({}, {__mode = "k"})
local noCamCollisionConns = {}

function setCharacterNoCamCollision(char, enabled)
    if not char then return end

    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") then
            if enabled then
                if noCamCollisionOriginal[obj] == nil then
                    noCamCollisionOriginal[obj] = obj.CanCollide
                end
                obj.CanCollide = false
            else
                local old = noCamCollisionOriginal[obj]
                if old ~= nil then
                    pcall(function() obj.CanCollide = old end)
                    noCamCollisionOriginal[obj] = nil
                end
            end
        end
    end
end

setNoCamCollision = function(enabled)
    Config.NoCamCollision = enabled == true

    for _, c in ipairs(noCamCollisionConns) do
        pcall(function() c:Disconnect() end)
    end
    noCamCollisionConns = {}

    if not Config.NoCamCollision then
        setCharacterNoCamCollision(LP.Character, false)
        return
    end

    setCharacterNoCamCollision(LP.Character, true)

    local char = LP.Character
    if char then
        table.insert(noCamCollisionConns, char.DescendantAdded:Connect(function(obj)
            if Config.NoCamCollision and obj:IsA("BasePart") then
                if noCamCollisionOriginal[obj] == nil then
                    noCamCollisionOriginal[obj] = obj.CanCollide
                end
                obj.CanCollide = false
            end
        end))
    end
end


Config.NoCamCollision = true
pcall(setNoCamCollision, true)

LP.CharacterAdded:Connect(function(char)
    if Config.NoCamCollision then
        task.wait(0.15)
        pcall(setNoCamCollision, true)
    end
end)




local ACE_ANTI_FLING_ENABLED = true
local ACE_ANTI_FLING_MAX_SPEED = 200
local ACE_ANTI_FLING_MAX_Y = 120
local ACE_ANTI_FLING_MAX_ANG = 40

function disableCanCollideForCharacter(character)
    if not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function() part.CanCollide = false end)
        end
    end
end

function applyAceAntiFling()
    if not ACE_ANTI_FLING_ENABLED or dropActive then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            disableCanCollideForCharacter(plr.Character)
        end
    end

    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    pcall(function()
        local v = root.AssemblyLinearVelocity
        if v.Magnitude > ACE_ANTI_FLING_MAX_SPEED or math.abs(v.Y) > ACE_ANTI_FLING_MAX_Y then
            root.AssemblyLinearVelocity = Vector3.new(
                math.clamp(v.X, -ACE_ANTI_FLING_MAX_SPEED, ACE_ANTI_FLING_MAX_SPEED),
                math.clamp(v.Y, -ACE_ANTI_FLING_MAX_Y, ACE_ANTI_FLING_MAX_Y),
                math.clamp(v.Z, -ACE_ANTI_FLING_MAX_SPEED, ACE_ANTI_FLING_MAX_SPEED)
            )
        end

        local av = root.AssemblyAngularVelocity
        if av.Magnitude > ACE_ANTI_FLING_MAX_ANG then
            root.AssemblyAngularVelocity = av.Unit * ACE_ANTI_FLING_MAX_ANG
        end
    end)
end

RunService.PreSimulation:Connect(function()
    pcall(applyAceAntiFling)
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        if ACE_ANTI_FLING_ENABLED then
            pcall(disableCanCollideForCharacter, char)
        end
    end)
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LP then
        plr.CharacterAdded:Connect(function(char)
            task.wait(0.3)
            if ACE_ANTI_FLING_ENABLED then
                pcall(disableCanCollideForCharacter, char)
            end
        end)
    end
end







StealSys = {
    conn = nil,
    isStealing = false,
    stealStart = 0,
    totalDuration = 1.4,
    progressManual = false,
    data = {},
    animalCache = {},
    promptCache = {},
    scanLast = 0,
    progressFill = nil,
    progressLabel = nil,
    progressFrame = nil,
    modeLabel = nil,
    radiusLabel = nil,
}





do
    local old = playerGui:FindFirstChild("VyzeStealProgress")
    if old then old:Destroy() end

    local spGui = Instance.new("ScreenGui")
    spGui.Name = "VyzeStealProgress"
    spGui.ResetOnSpawn = false
    spGui.DisplayOrder = 200
    spGui.IgnoreGuiInset = true
    spGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    spGui.Parent = playerGui

    local function stealBarWidth()
        local s = math.clamp(tonumber(Config.StealBarSize) or 50, 35, 90)
        return math.floor(s * 6)
    end
    local barW = stealBarWidth()

    local card = Instance.new("Frame")
    card.Name = "StealBar"
    card.Size = UDim2.new(0, barW, 0, 52)
    local savedBarX = tonumber(Config.StealBarPosX)
    local savedBarY = tonumber(Config.StealBarPosY)
    if savedBarX and savedBarY then
        card.Position = UDim2.fromOffset(savedBarX, savedBarY)
    else
        card.Position = UDim2.new(0.5, -math.floor(barW / 2), 1, -100)
    end
    card.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    card.BackgroundTransparency = 0.1
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.Active = true
    card.Parent = spGui
    corner(card, 12)
    stroke(card, 1.2, COLORS.Stroke, 0.35)
    StealSys.progressGui = spGui
    -- Keep every accent in the Steal progress bar synchronized with the selected UI background.
    local function applyStealBarTheme()
        local accent = _G.PeakHubThemeAccent or COLORS.Accent or Color3.fromRGB(255, 120, 0)
        local soft = _G.PeakHubThemeSoft or accent
        local cardStroke = card:FindFirstChildOfClass("UIStroke")
        if cardStroke then cardStroke.Color = accent end
        if StealSys.progressFill then StealSys.progressFill.BackgroundColor3 = accent end
        if StealSys.modeLabel then StealSys.modeLabel.TextColor3 = accent end
        if StealSys.radiusLabel then StealSys.radiusLabel.TextColor3 = accent end
        if StealSys.discordLabel then StealSys.discordLabel.TextColor3 = Color3.fromRGB(255, 255, 255) end
    end
    StealSys.applyTheme = applyStealBarTheme
    applyStealBarTheme()

    do
        local dragging, dragStart, startPos
        card.InputBegan:Connect(function(input)
            if Config.LockUI then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = card.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not dragging or Config.LockUI then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                local d = input.Position - dragStart
                card.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    if StealSys.saveBarPosition then
                        StealSys.saveBarPosition()
                    else
                        Config.StealBarPosX = card.AbsolutePosition.X
                        Config.StealBarPosY = card.AbsolutePosition.Y
                        saveConfig()
                    end
                end
                dragging = false
            end
        end)
    end

    function StealSys.applyBarSize()
        local s = math.clamp(tonumber(Config.StealBarSize) or 50, 35, 90)
        local scale = s / 50
        local w = math.floor(s * 6)
        local h = math.floor(52 * scale)
        local trackH = math.max(10, math.floor(16 * scale))
        local topH = math.max(14, math.floor(18 * scale))
        local textSize = math.clamp(math.floor(11 * scale + 0.5), 8, 18)
        local pctSize = math.clamp(math.floor(11 * scale + 0.5), 8, 18)

        if StealSys.progressFrame then
            local p = StealSys.progressFrame.Position
            StealSys.progressFrame.Size = UDim2.new(0, w, 0, h)
            StealSys.progressFrame.Position = UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset)
        end
        if StealSys.modeLabel then
            StealSys.modeLabel.TextSize = textSize
            StealSys.modeLabel.Size = UDim2.new(0.38, 0, 0, topH)
            StealSys.modeLabel.Position = UDim2.new(0, math.floor(10 * scale), 0, math.floor(4 * scale))
        end
        if StealSys.discordLabel then
            StealSys.discordLabel.TextSize = textSize
            StealSys.discordLabel.Size = UDim2.new(0.34, 0, 0, topH)
            StealSys.discordLabel.Position = UDim2.new(0.33, 0, 0, math.floor(4 * scale))
        end
        if StealSys.radiusLabel then
            StealSys.radiusLabel.TextSize = textSize
            StealSys.radiusLabel.Size = UDim2.new(0.32, -10, 0, topH)
            StealSys.radiusLabel.Position = UDim2.new(0.68, 0, 0, math.floor(4 * scale))
        end
        local track = StealSys.progressFrame and StealSys.progressFrame:FindFirstChild("ProgressTrack")
        if track then
            track.Size = UDim2.new(1, -math.floor(16 * scale), 0, trackH)
            track.Position = UDim2.new(0, math.floor(8 * scale), 0, math.floor(28 * scale))
        end
        if StealSys.progressLabel then
            StealSys.progressLabel.TextSize = pctSize
        end

        saveConfig()
    end

    function StealSys.saveBarPosition()
        local cardRef = StealSys.progressFrame
        if not cardRef then return end
        Config.StealBarPosX = cardRef.AbsolutePosition.X
        Config.StealBarPosY = cardRef.AbsolutePosition.Y
        saveConfig()
    end

    function StealSys.resetBarPosition()
        local cardRef = StealSys.progressFrame
        if not cardRef then return end
        local cam = workspace.CurrentCamera
        local viewport = cam and cam.ViewportSize or Vector2.new(1920, 1080)
        local w = cardRef.AbsoluteSize.X
        local h = cardRef.AbsoluteSize.Y
        local x = math.max(0, math.floor((viewport.X - w) / 2))
        local y = math.max(0, math.floor(viewport.Y - h - 100))
        cardRef.Position = UDim2.fromOffset(x, y)
        Config.StealBarPosX = x
        Config.StealBarPosY = y
        saveConfig()
    end


    local modeLbl = Instance.new("TextLabel")
    modeLbl.Name = "ModeLabel"
    modeLbl.Size = UDim2.new(0.38, 0, 0, 18)
    modeLbl.Position = UDim2.new(0, 10, 0, 4)
    modeLbl.BackgroundTransparency = 1
    modeLbl.Text = "Normal • V1"
    modeLbl.TextColor3 = Color3.fromRGB(255, 180, 80)
    modeLbl.Font = Enum.Font.GothamBold
    modeLbl.TextSize = 11
    modeLbl.TextXAlignment = Enum.TextXAlignment.Left
    modeLbl.ZIndex = 6
    modeLbl.Parent = card


    local discLbl = Instance.new("TextLabel")
    discLbl.Name = "DiscordLabel"
    discLbl.Size = UDim2.new(0.34, 0, 0, 18)
    discLbl.Position = UDim2.new(0.33, 0, 0, 4)
    discLbl.BackgroundTransparency = 1
    discLbl.Text = "discord.gg/YamGmyG3G9"
    discLbl.TextColor3 = Color3.fromRGB(255, 180, 80)
    discLbl.Font = Enum.Font.GothamBold
    discLbl.TextSize = 11
    discLbl.TextXAlignment = Enum.TextXAlignment.Center
    discLbl.ZIndex = 6
    discLbl.Parent = card


    local radLbl = Instance.new("TextLabel")
    radLbl.Name = "RadiusLabel"
    radLbl.Size = UDim2.new(0.32, -10, 0, 18)
    radLbl.Position = UDim2.new(0.68, 0, 0, 4)
    radLbl.BackgroundTransparency = 1
    radLbl.Text = "Radius: 61"
    radLbl.TextColor3 = _G.PeakHubThemeAccent or COLORS.Accent or Color3.fromRGB(255, 180, 80)
    radLbl.Font = Enum.Font.GothamBold
    radLbl.TextSize = 11
    radLbl.TextXAlignment = Enum.TextXAlignment.Right
    radLbl.ZIndex = 6
    radLbl.Parent = card


    local track = Instance.new("Frame")
    track.Name = "ProgressTrack"
    track.Size = UDim2.new(1, -16, 0, 16)
    track.Position = UDim2.new(0, 8, 0, 28)
    track.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    track.BackgroundTransparency = 0.28
    track.BorderSizePixel = 0
    track.ClipsDescendants = true
    track.ZIndex = 4
    track.Parent = card
    corner(track, 8)

    local fill = Instance.new("Frame")
    fill.Name = "ProgressFill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = _G.PeakHubThemeAccent or COLORS.Accent or Color3.fromRGB(255, 120, 0)
    fill.BorderSizePixel = 0
    fill.ZIndex = 5
    fill.Parent = track
    corner(fill, 8)


    local pct = Instance.new("TextLabel")
    pct.Name = "Status"
    pct.Size = UDim2.new(1, 0, 1, 0)
    pct.BackgroundTransparency = 1
    pct.Text = "0%"
    pct.TextColor3 = Color3.fromRGB(255, 255, 255)
    pct.Font = Enum.Font.GothamBlack
    pct.TextSize = 11
    pct.TextStrokeTransparency = 1
    pct.ZIndex = 7
    pct.Parent = track

    StealSys.progressFill = fill
    StealSys.progressLabel = pct
    StealSys.progressFrame = card
    StealSys.modeLabel = modeLbl
    StealSys.discordLabel = discLbl
    StealSys.radiusLabel = radLbl


    task.defer(function()
        if StealSys.applyBarSize then StealSys.applyBarSize() end
    end)
end

function StealSys.refreshMeta()
    if StealSys.modeLabel then
        if Config.AutoStealMode == "Semi" then
            StealSys.modeLabel.Text = "Semi"
        else
            local ver = Config.AutoStealVersion or "V1"
            if ver == "V3" then ver = "V2" end
            StealSys.modeLabel.Text = "Normal • " .. tostring(ver)
        end
    end
    if StealSys.radiusLabel then
        StealSys.radiusLabel.Text = string.format("Radius: %s", tostring(Config.AutoStealRadius or 61))
    end
end

refreshStealBarMeta = function()
    StealSys.refreshMeta()
    if StealSys.applyTheme then pcall(StealSys.applyTheme) end
end

function updateStealProgress(progress, label)
    local f = math.clamp(tonumber(progress) or 0, 0, 1)
    if StealSys.progressFill then
        StealSys.progressFill.BackgroundColor3 = _G.PeakHubThemeAccent or COLORS.Accent or StealSys.progressFill.BackgroundColor3
        TweenService:Create(StealSys.progressFill, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(f, 0, 1, 0)
        }):Play()
    end
    if StealSys.progressLabel then
        if label and label ~= "" then
            StealSys.progressLabel.Text = label
        elseif f >= 0.99 then
            StealSys.progressLabel.Text = "READY"
            StealSys.progressLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        elseif f > 0 then
            StealSys.progressLabel.Text = string.format("%d%%", math.floor(f * 100 + 0.5))
            StealSys.progressLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            StealSys.progressLabel.Text = Config.AutoSteal and "0%" or "OFF"
            StealSys.progressLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
    refreshStealBarMeta()
end

function resetStealProgress()
    updateStealProgress(0, Config.AutoSteal and "0%" or "OFF")
    refreshStealBarMeta()
end


task.defer(refreshStealBarMeta)


RunService.RenderStepped:Connect(function()
    if not StealSys.progressFrame then return end
    if StealSys.progressManual then return end
    if StealSys.isStealing and StealSys.stealStart > 0 then
        local dur = StealSys.totalDuration > 0 and StealSys.totalDuration or 1.3
        local f = math.clamp((tick() - StealSys.stealStart) / dur, 0, 1)
        updateStealProgress(f)
    end
end)

function stealIsMyPlot(plotName)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then return yb.Enabled == true end
    end
    return false
end

function stealFindNearestPrompt(radius)
    local char = LP.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local nearest, dist = nil, math.huge
    for _, plot in ipairs(plots:GetChildren()) do
        if not stealIsMyPlot(plot.Name) then
            local pods = plot:FindFirstChild("AnimalPodiums")
            if pods then
                for _, pod in ipairs(pods:GetChildren()) do
                    local base = pod:FindFirstChild("Base")
                    local sp = base and base:FindFirstChild("Spawn")
                    if sp then
                        local d = (sp.Position - root.Position).Magnitude
                        if d <= radius and d < dist then
                            local found = nil
                            local att = sp:FindFirstChild("PromptAttachment")
                            if att then
                                for _, pr in ipairs(att:GetChildren()) do
                                    if pr:IsA("ProximityPrompt") and pr.ActionText and pr.ActionText:find("Steal") then
                                        found = pr
                                    end
                                end
                            end
                            if not found then
                                for _, pr in ipairs(sp:GetDescendants()) do
                                    if pr:IsA("ProximityPrompt") and pr.ActionText and pr.ActionText:find("Steal") then
                                        found = pr
                                    end
                                end
                            end
                            if found then nearest, dist = found, d end
                        end
                    end
                end
            end
        end
    end
    return nearest, dist
end

function stealPromptDist(prompt)
    local char = LP.Character
    if not char then return math.huge end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return math.huge end
    local part = prompt.Parent
    if part and part:IsA("Attachment") then part = part.Parent end
    if part and part:IsA("BasePart") then
        return (part.Position - root.Position).Magnitude
    end
    return math.huge
end

function stealBuildCallbacks(prompt)
    if StealSys.data[prompt] then return StealSys.data[prompt] end
    local data = { hold = {}, trigger = {}, ready = true }
    if getconnections then
        pcall(function()
            for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                if c.Function then table.insert(data.hold, c.Function) end
            end
            for _, c in ipairs(getconnections(prompt.Triggered)) do
                if c.Function then table.insert(data.trigger, c.Function) end
            end
        end)
    end
    StealSys.data[prompt] = data
    return data
end

function stealScanAnimals()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return end
    local newCache = {}
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:IsA("Model") and not stealIsMyPlot(plot.Name) then
            local pods = plot:FindFirstChild("AnimalPodiums")
            if pods then
                for _, pod in ipairs(pods:GetChildren()) do
                    if pod:IsA("Model") and pod:FindFirstChild("Base") then
                        local uid = plot.Name .. "_" .. pod.Name
                        table.insert(newCache, {
                            name = pod.Name,
                            plot = plot.Name,
                            slot = pod.Name,
                            worldPosition = pod:GetPivot().Position,
                            uid = uid,
                        })
                    end
                end
            end
        end
    end
    StealSys.animalCache = newCache
end

function stealFindPromptForAnimal(ad)
    if not ad then return nil end
    local cp = StealSys.promptCache[ad.uid]
    if cp and cp.Parent then return cp end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local plot = plots:FindFirstChild(ad.plot)
    if not plot then return nil end
    local pods = plot:FindFirstChild("AnimalPodiums")
    if not pods then return nil end
    local pod = pods:FindFirstChild(ad.slot)
    if not pod then return nil end
    local base = pod:FindFirstChild("Base")
    local spawn = base and base:FindFirstChild("Spawn")
    if not spawn then return nil end
    local prompt = nil
    local att = spawn:FindFirstChild("PromptAttachment")
    if att then
        for _, p in ipairs(att:GetChildren()) do
            if p:IsA("ProximityPrompt") then prompt = p; break end
        end
    end
    if not prompt then
        for _, obj in ipairs(spawn:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then prompt = obj; break end
        end
    end
    if prompt then StealSys.promptCache[ad.uid] = prompt end
    return prompt
end

function stealNearestAnimal(radius)
    local char = LP.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local best, bestD = nil, math.huge
    for _, ad in ipairs(StealSys.animalCache) do
        if ad.worldPosition then
            local d = (hrp.Position - ad.worldPosition).Magnitude
            if d <= radius and d < bestD then
                bestD = d
                best = ad
            end
        end
    end
    return best, bestD
end


function executeStealV1(prompt)
    if StealSys.isStealing then return end
    local data = stealBuildCallbacks(prompt)
    if not data.ready then return end
    data.ready = false
    StealSys.isStealing = true
    StealSys.stealStart = tick()
    StealSys.totalDuration = 1.3
    updateStealProgress(0, "STEALING")
    task.spawn(function()
        for _, fn in ipairs(data.hold) do task.spawn(fn) end
        task.wait(StealSys.totalDuration)
        for _, fn in ipairs(data.trigger) do task.spawn(fn) end
        data.ready = true
        StealSys.isStealing = false
        StealSys.stealStart = 0
        updateStealProgress(1, "READY")
        task.wait(0.15)
        resetStealProgress()
    end)
end


function stealGetPromptPosition(prompt)
    if not prompt then return nil end
    local p = prompt.Parent
    while p and p ~= workspace do
        if p:IsA("BasePart") then return p.Position end
        p = p.Parent
    end
    return nil
end

function executeStealV2(prompt, animalData)
    local podName = animalData and (animalData.name or animalData.slot) or nil
    if StealSys.isStealing then return end
    if not Config.AutoSteal then return end
    local data = stealBuildCallbacks(prompt)
    if not data.ready then return end
    data.ready = false
    StealSys.isStealing = true
    StealSys.progressManual = true
    StealSys.stealStart = tick()


    local duration = 1.35
    local stopAtPercent = tonumber(Config.AutoStealStopAt) or 75
    local threshold = math.clamp(stopAtPercent, 75, 95) / 100
    local nearDist = threshold >= 0.80 and 7 or 9.3
    local timeToThreshold = math.max(0.05, duration * threshold)
    local timeAfterThreshold = math.max(0.05, duration - timeToThreshold)
    local waitNearMax = 1.6

    StealSys.totalDuration = duration
    updateStealProgress(0, "0%")

    task.spawn(function()

        for _, fn in ipairs(data.hold) do
            pcall(function() task.spawn(fn) end)
        end

        local startTime = tick()


        while tick() - startTime < timeToThreshold do
            if not Config.AutoSteal or not StealSys.isStealing then
                data.ready = true
                StealSys.isStealing = false
                StealSys.progressManual = false
                StealSys.stealStart = 0
                resetStealProgress()
                return
            end
            local p = math.clamp((tick() - startTime) / duration, 0, threshold)
            updateStealProgress(p, string.format("%d%%", math.floor(p * 100 + 0.5)))
            task.wait()
        end
        updateStealProgress(threshold, string.format("%d%%", math.floor(threshold * 100 + 0.5)))


        local function isNear()
            local char = LP.Character
            local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso"))
            if not hrp then return false end
            -- Measure distance from the actual brainrot/podium, not the prompt attachment.
            if animalData and animalData.plot and animalData.slot then
                local plots = workspace:FindFirstChild("Plots")
                local plot = plots and plots:FindFirstChild(animalData.plot)
                local pods = plot and plot:FindFirstChild("AnimalPodiums")
                local pod = pods and pods:FindFirstChild(animalData.slot)
                if pod then
                    local ok, pos = pcall(function() return pod:GetPivot().Position end)
                    if ok and pos then return (pos - hrp.Position).Magnitude <= nearDist end
                end
            end
            local pos = stealGetPromptPosition(prompt)
            if not pos then return false end
            return (pos - hrp.Position).Magnitude <= nearDist
        end

        local stillNear = isNear()
        if not stillNear then
            local holdStart = tick()
            while tick() - holdStart < waitNearMax do
                if not Config.AutoSteal or not StealSys.isStealing then
                    data.ready = true
                    StealSys.isStealing = false
                    StealSys.progressManual = false
                    StealSys.stealStart = 0
                    resetStealProgress()
                    return
                end
                updateStealProgress(threshold, string.format("%d%%", math.floor(threshold * 100 + 0.5)))
                if isNear() then
                    stillNear = true
                    break
                end
                task.wait()
            end
            if not stillNear then
                data.ready = true
                StealSys.isStealing = false
                StealSys.progressManual = false
                StealSys.stealStart = 0
                resetStealProgress()
                return
            end
        end


        local resumeTime = tick()
        while tick() - resumeTime < timeAfterThreshold do
            if not Config.AutoSteal or not StealSys.isStealing then
                data.ready = true
                StealSys.isStealing = false
                StealSys.progressManual = false
                StealSys.stealStart = 0
                resetStealProgress()
                return
            end
            local fin = (tick() - resumeTime) / math.max(timeAfterThreshold, 0.01)
            local overall = threshold + fin * (1 - threshold)
            updateStealProgress(overall, string.format("%d%%", math.floor(overall * 100 + 0.5)))
            task.wait()
        end
        updateStealProgress(1, "100%")

        for _, fn in ipairs(data.trigger) do
            pcall(function() task.spawn(fn) end)
        end
        pcall(function()
            local remote = game:GetService("ReplicatedStorage"):FindFirstChild("StealAnimal")
            if remote and podName then
                remote:FireServer(podName)
            end
            if prompt and prompt.Fire then
                pcall(function() prompt:Fire() end)
            end
        end)

        task.wait(0.05)
        data.ready = true
        StealSys.isStealing = false
        StealSys.progressManual = false
        StealSys.stealStart = 0
        updateStealProgress(1, "READY")
        task.wait(0.12)
        resetStealProgress()
    end)
end


function executeStealSemi(prompt, animalData)
    if StealSys.isStealing then return end
    local data = stealBuildCallbacks(prompt)
    if not data.ready then return end
    data.ready = false
    StealSys.isStealing = true
    StealSys.stealStart = tick()
    local HOLD_MIN = 1.3
    local HOLD_MAX = 2.6
    local STEAL_RANGE = 8
    local ENTRY_DELAY = 0.3
    StealSys.totalDuration = HOLD_MAX
    updateStealProgress(0, "STEALING")
    task.spawn(function()
        for _, fn in ipairs(data.hold) do task.spawn(fn) end
        task.wait(HOLD_MIN)
        local alreadyInRange = false
        if animalData and animalData.worldPosition then
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                alreadyInRange = (hrp.Position - animalData.worldPosition).Magnitude <= STEAL_RANGE
            end
        else
            alreadyInRange = stealPromptDist(prompt) <= STEAL_RANGE
        end
        while true do
            local el = tick() - StealSys.stealStart
            if el > HOLD_MAX or not prompt.Parent then break end
            local d = stealPromptDist(prompt)
            if animalData and animalData.worldPosition then
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    d = (hrp.Position - animalData.worldPosition).Magnitude
                end
            end
            if d <= STEAL_RANGE then
                if not alreadyInRange then task.wait(ENTRY_DELAY) end
                for _, fn in ipairs(data.trigger) do task.spawn(fn) end
                break
            end
            task.wait()
        end
        task.wait(0.05)
        data.ready = true
        StealSys.isStealing = false
        StealSys.stealStart = 0
        updateStealProgress(1, "READY")
        task.wait(0.15)
        resetStealProgress()
    end)
end

startAutoStealSystem = function()
    if StealSys.conn then return end
    stealScanAnimals()
    resetStealProgress()
    StealSys.conn = RunService.Heartbeat:Connect(function()
        if not Config.AutoSteal then return end
        if os.clock() < (Config._AutoStealHitPauseUntil or 0) then return end
        if StealSys.isStealing then return end


        if tick() - StealSys.scanLast > 5 then
            StealSys.scanLast = tick()
            stealScanAnimals()
        end

        local radius = tonumber(Config.AutoStealRadius) or 9
        local mode = Config.AutoStealMode

        if mode == "Semi" then
            radius = math.min(radius, 9)
            local target = nil
            local bestD = math.huge
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, ad in ipairs(StealSys.animalCache) do
                    if ad.worldPosition then
                        local d = (hrp.Position - ad.worldPosition).Magnitude
                        if d <= math.max(radius, 70) and d < bestD then
                            bestD = d
                            target = ad
                        end
                    end
                end
            end
            if not target then return end
            local prompt = stealFindPromptForAnimal(target)
            if prompt then executeStealSemi(prompt, target) end
            return
        end


        local ver = Config.AutoStealVersion or "V1"
        if ver == "V3" then ver = "V2" end

        if ver == "V2" then
            local target, dist = stealNearestAnimal(radius)
            if not target then return end
            if dist and dist > radius then return end
            local prompt = stealFindPromptForAnimal(target)
            if prompt then executeStealV2(prompt, target) end
        else

            local prompt = stealFindNearestPrompt(radius)
            if prompt then executeStealV1(prompt) end
        end
    end)
end

stopAutoStealSystem = function()
    if StealSys.conn then
        StealSys.conn:Disconnect()
        StealSys.conn = nil
    end
    StealSys.isStealing = false
    StealSys.progressManual = false
    StealSys.stealStart = 0
    resetStealProgress()
end

-- VX7-style Ragdoll Steal: pause Auto Steal when a hit, ragdoll, or knockdown is detected.
Config._AutoStealHitPauseUntil = Config._AutoStealHitPauseUntil or 0
Config._AutoStealHitToken = Config._AutoStealHitToken or 0
Config._AutoStealLastRagdoll = false
Config._AutoStealLastHealth = nil

local function isAutoStealCharacterRagdolled()
    local character = LP.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    local now = workspace:GetServerTimeNow()
    local ragdollEnd = LP:GetAttribute("RagdollEndTime") or character:GetAttribute("RagdollEndTime") or humanoid:GetAttribute("RagdollEndTime")
    if type(ragdollEnd) == "number" and ragdollEnd > now then return true end
    if LP:GetAttribute("Ragdolled") == true or LP:GetAttribute("Ragdoll") == true
        or character:GetAttribute("Ragdolled") == true or character:GetAttribute("Ragdoll") == true
        or humanoid:GetAttribute("Ragdolled") == true or humanoid:GetAttribute("Ragdoll") == true then
        return true
    end
    local state = humanoid:GetState()
    return humanoid.PlatformStand or state == Enum.HumanoidStateType.Physics
        or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown
end

local function triggerAutoStealHitPause()
    if not Config.AutoStealStopWhenHit or not Config.AutoSteal then return end
    if os.clock() < (Config._AutoStealHitPauseUntil or 0) then return end
    local pause = math.clamp(tonumber(Config.AutoStealHitPauseSeconds) or 1.3, 0.1, 30)
    Config._AutoStealHitPauseUntil = os.clock() + pause
    Config._AutoStealHitToken = Config._AutoStealHitToken + 1
    local token = Config._AutoStealHitToken
    stopAutoStealSystem()
    task.delay(pause, function()
        if token ~= Config._AutoStealHitToken then return end
        Config._AutoStealHitPauseUntil = 0
        if Config.AutoSteal and Config.AutoStealStopWhenHit then startAutoStealSystem() end
    end)
end

local function bindAutoStealHitSignals(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    Config._AutoStealLastHealth = humanoid.Health
    humanoid.HealthChanged:Connect(function(health)
        local previous = Config._AutoStealLastHealth
        Config._AutoStealLastHealth = health
        if previous and health < previous then triggerAutoStealHitPause() end
    end)
    humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Physics or newState == Enum.HumanoidStateType.Ragdoll
            or newState == Enum.HumanoidStateType.FallingDown then
            triggerAutoStealHitPause()
        end
    end)
    humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
        if humanoid.PlatformStand then triggerAutoStealHitPause() end
    end)
    for _, object in ipairs({LP, character, humanoid}) do
        for _, attribute in ipairs({"RagdollEndTime", "Ragdolled", "Ragdoll"}) do
            object:GetAttributeChangedSignal(attribute):Connect(function()
                if isAutoStealCharacterRagdolled() then triggerAutoStealHitPause() end
            end)
        end
    end
end

if not Config._AutoStealHitMonitorStarted then
    Config._AutoStealHitMonitorStarted = true
    RunService.Heartbeat:Connect(function()
        if not Config.AutoStealStopWhenHit or not Config.AutoSteal then
            Config._AutoStealLastRagdoll = false
            return
        end
        local ragdolled = isAutoStealCharacterRagdolled()
        if ragdolled and not Config._AutoStealLastRagdoll then triggerAutoStealHitPause() end
        Config._AutoStealLastRagdoll = ragdolled
    end)
    LP.CharacterAdded:Connect(function(character)
        Config._AutoStealLastRagdoll = false
        task.delay(0.1, function() bindAutoStealHitSignals(character) end)
    end)
    task.defer(function()
        if LP.Character then bindAutoStealHitSignals(LP.Character) end
    end)
end

if Config.AutoSteal then
    task.defer(function()
        task.wait(0.5)
        pcall(startAutoStealSystem)
    end)
end




local AP_L1 = Vector3.new(-476.47, -6.28, 92.73)
local AP_L2 = Vector3.new(-483.12, -4.95, 94.81)
local AP_R1 = Vector3.new(-476.16, -6.52, 25.62)
local AP_R2 = Vector3.new(-483.06, -5.03, 25.48)
local alConn, arConn = nil, nil
local alPhase, arPhase = 1, 1


local pathMoveDir = Vector3.zero


function pathApplySpeed(hrp, hum, dir, spd)
    if not hrp or not hum then return end
    if dir.Magnitude < 0.01 then
        _speedLVClear(hrp)
        hum:Move(Vector3.zero, false)
        hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
        return
    end
    local unit = dir.Unit


    _speedLVSet(hrp, unit.X * spd, unit.Z * spd)
end

function pathDirTo(hrp, target)
    local d = target - hrp.Position
    local mv = Vector3.new(d.X, 0, d.Z)
    if mv.Magnitude > 0.01 then return mv.Unit end
    return Vector3.zero
end



stopAutoLeft = function()
    if alConn then alConn:Disconnect(); alConn = nil end
    alPhase = 1
    Config.AutoLeft = false
    pathMoveDir = Vector3.zero
    if mobBtnRefs and mobBtnRefs.autoLeft then pcall(mobBtnRefs.autoLeft, false) end
    local char = LP.Character
    if char then
        local h = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if h then h:Move(Vector3.zero, false) end
        if hrp then
            _speedLVClear(hrp)
            hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
        end
    end
    saveConfig()
end

stopAutoRight = function()
    if arConn then arConn:Disconnect(); arConn = nil end
    arPhase = 1
    Config.AutoRight = false
    pathMoveDir = Vector3.zero
    if mobBtnRefs and mobBtnRefs.autoRight then pcall(mobBtnRefs.autoRight, false) end
    local char = LP.Character
    if char then
        local h = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if h then h:Move(Vector3.zero, false) end
        if hrp then
            _speedLVClear(hrp)
            hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
        end
    end
    saveConfig()
end

startAutoLeft = function()
    if safeModeTryStart and not safeModeTryStart() then return end
    if arConn then stopAutoRight() end
    if alConn then alConn:Disconnect(); alConn = nil end
    Config.AutoLeft = true
    alPhase = 1
    pathMoveDir = Vector3.zero
    alConn = RunService.Heartbeat:Connect(function()
        if not Config.AutoLeft then return end
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end
        if isRagdollState(hum) then
            pathMoveDir = Vector3.zero
            hum:Move(Vector3.zero, false)
            return
        end

        local spd = getPathSpeed()
        if alPhase == 1 then
            local tgt = Vector3.new(AP_L1.X, hrp.Position.Y, AP_L1.Z)
            if (tgt - hrp.Position).Magnitude < 1.25 then
                alPhase = 2
            end
            pathMoveDir = pathDirTo(hrp, AP_L1)
            if alPhase == 2 then
                pathMoveDir = pathDirTo(hrp, AP_L2)
            end
            pathApplySpeed(hrp, hum, pathMoveDir, spd)
        elseif alPhase == 2 then
            local tgt = Vector3.new(AP_L2.X, hrp.Position.Y, AP_L2.Z)
            if (tgt - hrp.Position).Magnitude < 1.25 then
                pathMoveDir = Vector3.zero
                stopAutoLeft()
                return
            end
            pathMoveDir = pathDirTo(hrp, AP_L2)
            pathApplySpeed(hrp, hum, pathMoveDir, spd)
        end
    end)
end

startAutoRight = function()
    if safeModeTryStart and not safeModeTryStart() then return end
    if alConn then stopAutoLeft() end
    if arConn then arConn:Disconnect(); arConn = nil end
    Config.AutoRight = true
    arPhase = 1
    pathMoveDir = Vector3.zero
    arConn = RunService.Heartbeat:Connect(function()
        if not Config.AutoRight then return end
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end
        if isRagdollState(hum) then
            pathMoveDir = Vector3.zero
            hum:Move(Vector3.zero, false)
            return
        end

        local spd = getPathSpeed()
        if arPhase == 1 then
            local tgt = Vector3.new(AP_R1.X, hrp.Position.Y, AP_R1.Z)
            if (tgt - hrp.Position).Magnitude < 1.25 then
                arPhase = 2
            end
            pathMoveDir = pathDirTo(hrp, AP_R1)
            if arPhase == 2 then
                pathMoveDir = pathDirTo(hrp, AP_R2)
            end
            pathApplySpeed(hrp, hum, pathMoveDir, spd)
        elseif arPhase == 2 then
            local tgt = Vector3.new(AP_R2.X, hrp.Position.Y, AP_R2.Z)
            if (tgt - hrp.Position).Magnitude < 1.25 then
                pathMoveDir = Vector3.zero
                stopAutoRight()
                return
            end
            pathMoveDir = pathDirTo(hrp, AP_R2)
            pathApplySpeed(hrp, hum, pathMoveDir, spd)
        end
    end)
end




LP:GetAttributeChangedSignal("Stealing"):Connect(function()

    if not Config.AutoCarrySpeed then
        autoCarryBoost = false
        return
    end
    local isStealing = LP:GetAttribute("Stealing") == true
    autoCarryBoost = isStealing == true
end)

RunService.PreSimulation:Connect(function()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")


    if char and Config.AutoSwing and State.autoBatToggled and Config.BatAimbot then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then
            tool:Activate()
        end
    end



    if Config.AutoLeft or Config.AutoRight then
        if pathMoveDir and pathMoveDir.Magnitude > 0.01 then
            local char2 = LP.Character
            local hrp2 = char2 and char2:FindFirstChild("HumanoidRootPart")
            local hum2 = char2 and char2:FindFirstChildOfClass("Humanoid")
            if hrp2 and hum2 then
                pathApplySpeed(hrp2, hum2, pathMoveDir, getPathSpeed())
            end
        end
    else
        applyVelocitySpeed(getActiveSpeed())
    end

end)

local lastCarryKeyTime = 0
UserInputService.InputBegan:Connect(function(input, processed)
    local isKb = input.UserInputType == Enum.UserInputType.Keyboard
    local isPad = input.UserInputType == Enum.UserInputType.Gamepad1
    if not (isKb or isPad) then return end
    if keybindCaptureActive then return end
    local key = input.KeyCode.Name

    local function is(k)
        if k == nil then return false end
        local value = tostring(k)
        return value ~= "" and key:upper() == value:upper()
    end
    local function canStart(action)
        return safeModeAllowsAction(action)
    end

    if is(Config.DropKey) then
        if canStart("drop") and type(runDrop) == "function" then
            pcall(runDrop)
        end
        return
    elseif is(Config.TPDownKey) then
        if processed then return end
        if canStart("tpDown") then performTPDown() end
    elseif is(Config.InstaResetKey) then
        if canStart("reset") and type(cursedInstaReset) == "function" then
            pcall(cursedInstaReset)
        end
        return
    elseif processed then
        return
    elseif is(Config.CarrySpeedKey) then
        local now = tick()
        if now - lastCarryKeyTime < 0.35 then
            carrySpeedEnabled = false
            laggerCarryEnabled = false
            laggerSpeedEnabled = false
            lastCarryKeyTime = 0
        else
            carrySpeedEnabled = not carrySpeedEnabled
            if carrySpeedEnabled then
                laggerSpeedEnabled = false
                laggerCarryEnabled = false
                laggerModeEnabled = false
            end
            lastCarryKeyTime = now
        end
        if mobBtnRefs then
            if mobBtnRefs.carrySpeed then pcall(mobBtnRefs.carrySpeed, carrySpeedEnabled) end
            if not carrySpeedEnabled then
                if mobBtnRefs.lagger then pcall(mobBtnRefs.lagger, laggerModeEnabled) end
                if mobBtnRefs.laggerCarry then pcall(mobBtnRefs.laggerCarry, laggerCarryEnabled) end
            else
                if mobBtnRefs.lagger then pcall(mobBtnRefs.lagger, false) end
                if mobBtnRefs.laggerCarry then pcall(mobBtnRefs.laggerCarry, false) end
            end
        end

    elseif is(Config.LaggerCarryKey) then
        laggerCarryEnabled = not laggerCarryEnabled
        if laggerCarryEnabled then
            laggerSpeedEnabled = false
            carrySpeedEnabled = false
        end

    elseif is(Config.AutoLeftKey) then
        if canStart() then
            Config.AutoLeft = not Config.AutoLeft
            if Config.AutoLeft then if Config.AutoRight then stopAutoRight() end; startAutoLeft() else stopAutoLeft() end
            saveConfig()
        end
    elseif is(Config.AutoRightKey) then
        if canStart() then
            Config.AutoRight = not Config.AutoRight
            if Config.AutoRight then if Config.AutoLeft then stopAutoLeft() end; startAutoRight() else stopAutoRight() end
            saveConfig()
        end
    elseif is(Config.BatAimbotKey) then
        if canStart() then
            Config.BatAimbot = not Config.BatAimbot
            State.autoBatToggled = Config.BatAimbot
            if Config.BatAimbot then startBatAimbot() else stopBatAimbot() end
            if mobBtnRefs and mobBtnRefs.autoBat then pcall(mobBtnRefs.autoBat, Config.BatAimbot) end
            if _G.PeakHubSetBatAimbotUI then pcall(_G.PeakHubSetBatAimbotUI, Config.BatAimbot) end
            saveConfig()
        end

    end
end)



pcall(function()
    if _G.__VyzeActionKeyConnection then
        _G.__VyzeActionKeyConnection:Disconnect()
    end
end)
_G.__VyzeActionKeyConnection = UserInputService.InputBegan:Connect(function(input, processed)
    if keybindCaptureActive then return end
    local isKeyboard = input.UserInputType == Enum.UserInputType.Keyboard
    local isGamepad = input.UserInputType == Enum.UserInputType.Gamepad1
    if not (isKeyboard or isGamepad) then return end

    local keyName = input.KeyCode.Name:upper()
    local dropKey = tostring(Config.DropKey or ""):upper()
    local resetKey = tostring(Config.InstaResetKey or ""):upper()
    local tpDownKey = tostring(Config.TPDownKey or ""):upper()


    if dropKey ~= "" and keyName == dropKey then
        if safeModeAllowsAction("drop") then pcall(runDrop) end
        return
    end
    if resetKey ~= "" and keyName == resetKey then
        if safeModeAllowsAction("reset") then pcall(cursedInstaReset) end
        return
    end
    if tpDownKey ~= "" and keyName == tpDownKey then
        if (isGamepad or not processed) and safeModeAllowsAction("tpDown") then performTPDown() end
        return
    end
end)

local tabNames = { "Movement", "Combat", "Misc", "Visual", "Settings" }
local tabButtons = {}
local currentTab = "Movement"

local TAB_ACCENTS = {
    Movement = COLORS.Accent,
    Combat = COLORS.Accent,
    Misc = COLORS.Accent,
    Visual = COLORS.Accent,
    Settings = COLORS.Accent,
}

function selectTab(name)
    currentTab = name
    _G.PeakHubSelectedTab = name
    local liveAccent = _G.PeakHubThemeAccent or COLORS.Accent or Color3.fromRGB(255, 120, 0)
    local liveSoft = _G.PeakHubThemeSoft or COLORS.AccentSoft or Color3.fromRGB(100, 35, 0)

    for tabName, data in pairs(tabButtons) do
        local active = tabName == name
        local accent = TAB_ACCENTS[tabName] or COLORS.Stroke
        local info = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        TweenService:Create(data.button, info, {

            BackgroundColor3 = active and liveSoft or Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = active and 0 or 0.12,
        }):Play()
        TweenService:Create(data.stroke, info, {
            Transparency = active and 0 or 0.48,
            Color = active and liveAccent or liveSoft,
            Thickness = active and 2 or 1,
        }):Play()
        TweenService:Create(data.underline, info, {
            BackgroundTransparency = active and 0 or 1,
            Size = active and UDim2.new(0.72, 0, 0, 2) or UDim2.new(0, 0, 0, 2),
            BackgroundColor3 = liveAccent,
        }):Play()
        TweenService:Create(data.label, info, {
            TextColor3 = active and COLORS.White or COLORS.TextDim,
            TextTransparency = active and 0 or 0.18,
        }):Play()
        if data.glow then
            TweenService:Create(data.glow, info, {
                BackgroundTransparency = active and 0.75 or 1,
            BackgroundColor3 = liveAccent,
            }):Play()
        end
        pages[tabName].Visible = active
    end
    content.CanvasPosition = Vector2.new(0, 0)
end

for i, name in ipairs(tabNames) do
    local active0 = (name == currentTab)
    local accent = _G.PeakHubThemeAccent or TAB_ACCENTS[name] or COLORS.Stroke
    local themeSoft = _G.PeakHubThemeSoft or COLORS.AccentSoft or Color3.fromRGB(100, 35, 0)

    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Size = UDim2.new(1 / #tabNames, -4, 1, -4)
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = active0 and 0.08 or 0.18
    btn.BorderSizePixel = 0
    btn.LayoutOrder = i
    btn.Parent = tabBar
    corner(btn, 11)

    local tabStroke = stroke(btn, active0 and 2 or 1, active0 and accent or themeSoft, active0 and 0 or 0.48)


    local glow = Instance.new("Frame")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1, -8, 0, 10)
    glow.Position = UDim2.new(0, 4, 0, 2)
    glow.BackgroundColor3 = accent
    glow.BackgroundTransparency = 1
    glow.BorderSizePixel = 0
    glow.ZIndex = 1
    glow.Parent = btn
    corner(glow, 6)
    local glowGrad = Instance.new("UIGradient")
    glowGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 1),
    })
    glowGrad.Rotation = 90
    glowGrad.Parent = glow

    local lbl = Instance.new("TextLabel")
    lbl.Name = "Label"
    lbl.Text = name
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextColor3 = COLORS.White
    lbl.TextTransparency = active0 and 0 or 0.18
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -4, 0, 16)
    lbl.Position = UDim2.new(0, 2, 0.5, -10)
    lbl.ZIndex = 3
    lbl.Parent = btn

    local underline = Instance.new("Frame")
    underline.Name = "Underline"
    underline.AnchorPoint = Vector2.new(0.5, 0)
    underline.Position = UDim2.new(0.5, 0, 1, -7)
    underline.Size = active0 and UDim2.new(0.72, 0, 0, 2) or UDim2.new(0, 0, 0, 2)
    underline.BackgroundColor3 = accent
    underline.BackgroundTransparency = active0 and 0 or 1
    underline.BorderSizePixel = 0
    underline.ZIndex = 3
    underline.Parent = btn
    corner(underline, 2)

    tabButtons[name] = { button = btn, label = lbl, underline = underline, stroke = tabStroke, glow = glow }

    btn.MouseEnter:Connect(function()
        if currentTab == name then return end
        TweenService:Create(btn, TweenInfo.new(0.12), {
            BackgroundTransparency = 0.08,
        }):Play()
        TweenService:Create(tabStroke, TweenInfo.new(0.12), {
            Transparency = 0.18,
            Color = _G.PeakHubThemeAccent or COLORS.Accent,
            Thickness = 1.4,
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        if currentTab == name then return end
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundTransparency = 0.12,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        }):Play()
        TweenService:Create(tabStroke, TweenInfo.new(0.15), {
            Transparency = 0.48,
            Color = _G.PeakHubThemeSoft or COLORS.AccentSoft,
            Thickness = 1.25,
        }):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        selectTab(name)
    end)
end
-- Apply the selected background palette to the initially selected tab immediately.
-- Defer one extra refresh so the first rendered frame cannot keep stale tab colors.
selectTab(currentTab)
task.defer(function()
    task.wait()
    pcall(function()
        selectTab(currentTab)
    end)
end)


function __vyzeInitVisualLogic()





local _dropConn = nil
local DROP_ASCEND_DURATION = 0.2
local DROP_ASCEND_SPEED = 150

function stopDropBrainrot()
    dropActive = false
    if dropActionRow then setRowGlow(dropActionRow, false) end
    if _dropConn then pcall(function() _dropConn:Disconnect() end); _dropConn = nil end
    local c = LP.Character
    if c then
        local root = c:FindFirstChild("HumanoidRootPart")
        if root then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end
end

local DROP_ASCEND_DURATION=.22
local DROP_ASCEND_SPEED=160
function runDrop() if dropActive then return end;local c=LP.Character;if not c then return end;local r=c:FindFirstChild("HumanoidRootPart");if not r then return end;dropActive=true;if dropActionRow then setRowGlow(dropActionRow, true) end;if syncAutoAntiDie then pcall(syncAutoAntiDie) end;local t0=tick();if _dropConn then _dropConn:Disconnect() end;_dropConn=RunService.Heartbeat:Connect(function() local cc=LP.Character;local rr=cc and cc:FindFirstChild("HumanoidRootPart");if not rr then if _dropConn then _dropConn:Disconnect();_dropConn=nil end;dropActive=false;if dropActionRow then setRowGlow(dropActionRow, false) end;if syncAutoAntiDie then pcall(syncAutoAntiDie) end;return end;if not dropActive then if _dropConn then _dropConn:Disconnect();_dropConn=nil end;return end;if tick()-t0>=DROP_ASCEND_DURATION then if _dropConn then _dropConn:Disconnect();_dropConn=nil end;pcall(function() local rp=RaycastParams.new();rp.FilterDescendantsInstances={cc};rp.FilterType=Enum.RaycastFilterType.Exclude;local hit=workspace:Raycast(rr.Position,Vector3.new(0,-3000,0),rp);if hit then local hum=cc:FindFirstChildOfClass("Humanoid");local off=((hum and hum.HipHeight) or 2)+(rr.Size.Y/2);rr.CFrame=CFrame.new(rr.Position.X,hit.Position.Y+off,rr.Position.Z);rr.AssemblyLinearVelocity=Vector3.zero end end);dropActive=false;if dropActionRow then setRowGlow(dropActionRow, false) end;if syncAutoAntiDie then pcall(syncAutoAntiDie) end;return end;local lv=rr.AssemblyLinearVelocity;rr.AssemblyLinearVelocity=Vector3.new(lv.X,DROP_ASCEND_SPEED,lv.Z) end) end


local resetting = false

function cursedInstaReset()
    if resetting then return end
    local character = LP.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end

    resetting = true
    _isInstaResetting = true
    Config._instaResetInProgress = true
    local prevAntiDie = antiDieActive
    antiDieActive = false

    local camera = workspace.CurrentCamera
    local savedCameraType = camera and camera.CameraType
    local savedCameraCFrame = camera and camera.CFrame
    pcall(function()
        if camera then
            camera.CameraType = Enum.CameraType.Scriptable
            if savedCameraCFrame then camera.CFrame = savedCameraCFrame end
        end
    end)

    local respawnConn
    local finished = false
    local function finishReset(newChar)
        if finished then return end
        finished = true
        pcall(function()
            local cam = workspace.CurrentCamera
            if cam then
                cam.CameraType = Enum.CameraType.Custom
                local newHum = newChar and newChar:FindFirstChildOfClass("Humanoid")
                if newHum then cam.CameraSubject = newHum end
            end
        end)
        antiDieActive = prevAntiDie
        _isInstaResetting = false
        Config._instaResetInProgress = false
        resetting = false
        if respawnConn then
            pcall(function() respawnConn:Disconnect() end)
            respawnConn = nil
        end
    end

    respawnConn = LP.CharacterAdded:Connect(function(newChar)
        task.spawn(function()
            local deadline = os.clock() + 8
            local newHum
            repeat
                newHum = newChar:FindFirstChildOfClass("Humanoid")
                if newHum then break end
                task.wait(0.05)
            until os.clock() >= deadline
            finishReset(newChar)
        end)
    end)

    -- Instant Reset V2: fisica / stato Physics, con tentativi ripetuti
    -- un frame alla volta finché il personaggio muore o scade la finestra.
    task.spawn(function()
        local savedPlatformStand = humanoid.PlatformStand
        local savedBreakJoints = humanoid.BreakJointsOnDeath
        local deadline = os.clock() + 0.3

        local function applyV2(hum, root)
            hum.BreakJointsOnDeath = true
            hum.PlatformStand = true
            hum:ChangeState(Enum.HumanoidStateType.Physics)
            root.AssemblyAngularVelocity = Vector3.zero
            root.AssemblyLinearVelocity = Vector3.new(0, 1e6, 0)
        end

        -- Burst limitato e poi un tentativo per frame: evita un ciclo
        -- enorme nello stesso frame e lascia avanzare la fisica.
        for _ = 1, 8 do
            local ch = LP.Character
            if ch ~= character or not character.Parent or humanoid.Health <= 0 then
                finishReset(LP.Character)
                return
            end
            local root = ch:FindFirstChild("HumanoidRootPart")
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if root and hum then pcall(applyV2, hum, root) end
        end

        while os.clock() < deadline do
            RunService.Heartbeat:Wait()
            local ch = LP.Character
            if ch ~= character or not character.Parent or humanoid.Health <= 0 then
                return -- CharacterAdded si occupa del ripristino camera/stato
            end
            local root = ch:FindFirstChild("HumanoidRootPart")
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if root and hum then pcall(applyV2, hum, root) end
        end

        -- Se V2 non ha causato il reset, ripristina lo stato originale.
        if LP.Character == character and character.Parent and humanoid.Health > 0 then
            pcall(function()
                humanoid.PlatformStand = savedPlatformStand
                humanoid.BreakJointsOnDeath = savedBreakJoints
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                local root = character:FindFirstChild("HumanoidRootPart")
                if root then root.AssemblyLinearVelocity = Vector3.zero end
            end)
            finishReset(character)
        end
    end)

    task.delay(8, function()
        if resetting then finishReset(LP.Character) end
    end)
end

local MOB_POS_FILE = "VyzeCC2_MobPos.json"
local mobGuiRef = nil

local mobBtnFrames = {}
function loadMobPos()
    local out = {}
    pcall(function()
        if isfile and isfile(MOB_POS_FILE) then
            local data = HttpService:JSONDecode(readfile(MOB_POS_FILE))
            if type(data) == "table" then out = data end
        end
    end)
    return out
end

function saveMobPos()
    local out = {}
    for key, fr in pairs(mobBtnFrames) do
        if fr and fr.Parent then
            out[key] = {
                sx = fr.Position.X.Scale, sy = fr.Position.Y.Scale,
                ox = fr.Position.X.Offset, oy = fr.Position.Y.Offset,
            }
        end
    end
    pcall(function()
        if writefile then writefile(MOB_POS_FILE, HttpService:JSONEncode(out)) end
    end)
end

function destroyMobileButtons()
    if mobGuiRef then pcall(function() mobGuiRef:Destroy() end); mobGuiRef = nil end
    mobBtnRefs = {}
    mobBtnFrames = {}
end

function buildMobileButtons()
    destroyMobileButtons()


    local OFF_BG = Color3.fromRGB(18, 18, 20)
    local OFF_TXT = Color3.fromRGB(255, 255, 255)
    local ON_BG = _G.PeakHubThemeAccent or COLORS.Accent or Color3.fromRGB(255, 120, 0)
    local ON_TXT = Color3.fromRGB(255, 255, 255)
    local OUTLINE = _G.PeakHubThemeAccent or Color3.fromRGB(255, 145, 25)
    local ACCENT = _G.PeakHubThemeAccent or Color3.fromRGB(255, 177, 76)

    local scale = math.clamp((tonumber(Config.MobileButtonSize) or 50) / 50, 0.2, 2.5)
    local BTN_W = math.floor(64 * scale)
    local BTN_H = math.floor(64 * scale)
    local GAP = math.floor(10 * scale)
    local isCircle = Config.CircleButtons == true
    local cornerR = isCircle and math.floor(BTN_W / 2) or math.floor(16 * scale)

    local gui = Instance.new("ScreenGui")
    gui.Name = "VyzeMobileButtons"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 100
    gui.IgnoreGuiInset = true
    gui.Parent = playerGui
    mobGuiRef = gui

    local saved = loadMobPos()






    local defs = {
        {key="reset",        label="INSTA\nRESET",   toggle=false, col=0, row=0},
        {key="drop",         label="DROP\nBR",        toggle=false, col=1, row=0},
        {key="autoLeft",     label="AUTO\nLEFT",     toggle=true,  col=2, row=0},
        {key="autoBat",      label="BAT\nAIMBOT",    toggle=true,  col=0, row=1},
        {key="autoRight",    label="AUTO\nRIGHT",    toggle=true,  col=1, row=1},
        {key="tpDown",       label="TP\nDOWN",        toggle=false, col=1, row=2},
        {key="carrySpeed",   label="CARRY\nSPEED",   toggle=true,  col=2, row=2},
        {key="laggerCarry",  label="LAGGER\nCARRY",  toggle=true,  col=1, row=3},
        {key="lagger",       label="LAGGER\nMODE",   toggle=true,  col=2, row=3},
    }

    local function defaultPos(def)
        local cols = 3
        local rows = 4
        local gridW = cols * (BTN_W + GAP) - GAP
        local gridH = rows * (BTN_H + GAP) - GAP
        local margin = 16
        return UDim2.new(
            1, -(gridW + margin) + (def.col or 0) * (BTN_W + GAP),
            0.5, -gridH / 2 + (def.row or 0) * (BTN_H + GAP)
        )
    end

    local function setBtnVisual(btn, on)
        local st = btn:FindFirstChildOfClass("UIStroke")
        local grad = btn:FindFirstChildOfClass("UIGradient")
        if on then
            btn:SetAttribute("PeakHubActive", true)
            btn.BackgroundColor3 = _G.PeakHubThemeAccent or OUTLINE
            btn.TextColor3 = ON_TXT
            btn.TextStrokeColor3 = Color3.fromRGB(255, 218, 160)
            btn.TextStrokeTransparency = 0.18
            if grad then
                grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, _G.PeakHubThemeSoft or (_G.PeakHubThemeAccent or OUTLINE)), ColorSequenceKeypoint.new(1, _G.PeakHubThemeAccent or OUTLINE)})
            end
            if st then
                st.Color = _G.PeakHubThemeAccent or OUTLINE
                st.Thickness = 3
                st.Transparency = 0
            end
        else
            btn:SetAttribute("PeakHubActive", false)
            btn.BackgroundColor3 = OFF_BG
            btn.TextColor3 = OFF_TXT
            btn.TextTransparency = 0
            btn.TextStrokeTransparency = 1
            if grad then
                grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, OFF_BG)})
            end
            if st then
                st.Color = _G.PeakHubThemeAccent or OUTLINE
                st.Thickness = 1.8
                st.Transparency = 0.05
            end
        end
    end

    local function makeDrag(btn)
        local dragging, dragStart, startPos
        btn.InputBegan:Connect(function(input)
            if Config.LockUI then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = btn.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not dragging or Config.LockUI then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                local d = input.Position - dragStart
                btn.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then dragging = false; saveMobPos() end
            end
        end)
    end

    for _, def in ipairs(defs) do
        local btn = Instance.new("TextButton")
        btn.Name = def.key
        btn.Size = UDim2.new(0, BTN_W, 0, BTN_H)
        local pos = defaultPos(def)
        local s = saved[def.key]
        if s and type(s.ox) == "number" then
            pos = UDim2.new(s.sx or 0, s.ox, s.sy or 0, s.oy)
        end
        btn.Position = pos
        btn.BackgroundColor3 = OFF_BG
        btn.TextColor3 = OFF_TXT
        btn.TextTransparency = 0
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = math.max(10, math.floor(12 * scale))
        btn.TextStrokeTransparency = 1
        btn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        btn.TextScaled = false
        btn.TextWrapped = true
        btn.Text = def.label
        btn.TextXAlignment = Enum.TextXAlignment.Center
        btn.TextYAlignment = Enum.TextYAlignment.Center
        btn.AutoButtonColor = false
        btn.BorderSizePixel = 0
        btn.Parent = gui
        corner(btn, cornerR)

        local gradient = Instance.new("UIGradient")
        gradient.Rotation = 90
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, OFF_BG),
        })
        gradient.Parent = btn

        local topAccent = Instance.new("Frame")
        topAccent.Name = "OrangeAccent"
        topAccent.Size = UDim2.new(0.52, 0, 0, math.max(3, math.floor(4 * scale)))
        topAccent.Position = UDim2.new(0, math.floor(9 * scale), 0, math.floor(7 * scale))
        topAccent.BackgroundColor3 = _G.PeakHubThemeAccent or OUTLINE
        topAccent.BorderSizePixel = 0
        topAccent.ZIndex = btn.ZIndex + 1
        topAccent.Parent = btn
        corner(topAccent, math.max(2, math.floor(2 * scale)))

        local st = Instance.new("UIStroke")
        st.Color = OUTLINE
        st.Thickness = 1.6
        st.Transparency = 0.2
        st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        st.Parent = btn
        makeDrag(btn)
        mobBtnFrames[def.key] = btn

        local active = false
        local function setVisual(on)
            active = on == true
            setBtnVisual(btn, active)
        end
        mobBtnRefs[def.key] = setVisual

        btn.MouseButton1Click:Connect(function()
            if def.key == "drop" then
                if not safeModeAllowsAction("drop") then setVisual(false); return end
                setVisual(true)
                runDrop()
                task.spawn(function()
                    while dropActive do task.wait() end
                    setVisual(false)
                end)
            elseif def.key == "reset" then
                if not safeModeAllowsAction("reset") then setVisual(false); return end
                setVisual(true)
                cursedInstaReset()
                task.delay(0.6, function() setVisual(false) end)
            elseif def.key == "tpDown" then
                if not safeModeAllowsAction("tpDown") then setVisual(false); return end
                setVisual(true)
                if performTPDown then performTPDown(Config.TPDownDistance or 10) end
                task.delay(0.25, function() setVisual(false) end)
            elseif def.key == "autoLeft" then
                if Config.SafeMode and safeModeIsLocked() then
                    setVisual(false)
                    return
                end
                if Config.AutoLeft then
                    Config.AutoLeft = false
                    if stopAutoLeft then stopAutoLeft() end
                    setVisual(false)
                else
                    Config.AutoLeft = true
                    if startAutoLeft then startAutoLeft() end
                    setVisual(true)
                end
                saveConfig()
            elseif def.key == "autoRight" then
                if Config.SafeMode and safeModeIsLocked() then
                    setVisual(false)
                    return
                end
                if Config.AutoRight then
                    Config.AutoRight = false
                    if stopAutoRight then stopAutoRight() end
                    setVisual(false)
                else
                    Config.AutoRight = true
                    if startAutoRight then startAutoRight() end
                    setVisual(true)
                end
                saveConfig()
            elseif def.key == "autoBat" then
                if Config.SafeMode and safeModeIsLocked() then setVisual(false); return end
                if State.autoBatToggled then
                    State.autoBatToggled = false
                    Config.BatAimbot = false
                    if stopBatAimbot then stopBatAimbot() end
                    setVisual(false)
                    if syncAutoAntiDie then pcall(syncAutoAntiDie) end
                else
                    State.autoBatToggled = true
                    Config.BatAimbot = true
                    if startBatAimbot then startBatAimbot() end
                    setVisual(true)
                    if syncAutoAntiDie then pcall(syncAutoAntiDie) end
                end
                saveConfig()
            elseif def.key == "carrySpeed" then
                if not safeModeAllowsAction("carrySpeed") then setVisual(false); return end
                carrySpeedEnabled = not carrySpeedEnabled
                if carrySpeedEnabled then
                    laggerModeEnabled = false
                    laggerCarryEnabled = false
                    if mobBtnRefs.lagger then mobBtnRefs.lagger(false) end
                    if mobBtnRefs.laggerCarry then mobBtnRefs.laggerCarry(false) end
                else

                    carrySpeedEnabled = false
                end
                setVisual(carrySpeedEnabled == true)
            elseif def.key == "lagger" then
                if not safeModeAllowsAction("lagger") then setVisual(false); return end
                laggerModeEnabled = not laggerModeEnabled
                if laggerModeEnabled then
                    carrySpeedEnabled = false
                    laggerCarryEnabled = false
                    if mobBtnRefs.carrySpeed then mobBtnRefs.carrySpeed(false) end
                    if mobBtnRefs.laggerCarry then mobBtnRefs.laggerCarry(false) end
                end
                setVisual(laggerModeEnabled)
            elseif def.key == "laggerCarry" then
                if not safeModeAllowsAction("laggerCarry") then setVisual(false); return end
                laggerCarryEnabled = not laggerCarryEnabled
                if laggerCarryEnabled then
                    carrySpeedEnabled = false
                    laggerModeEnabled = false
                    if mobBtnRefs.carrySpeed then mobBtnRefs.carrySpeed(false) end
                    if mobBtnRefs.lagger then mobBtnRefs.lagger(false) end
                end
                setVisual(laggerCarryEnabled)
            end
        end)
    end


    if Config.AutoLeft and mobBtnRefs.autoLeft then mobBtnRefs.autoLeft(true) end
    if Config.AutoRight and mobBtnRefs.autoRight then mobBtnRefs.autoRight(true) end
    if Config.BatAimbot and mobBtnRefs.autoBat then mobBtnRefs.autoBat(true) end

    -- Keep active side buttons orange even if another UI refresh reapplies the selected palette.
    task.spawn(function()
        while gui and gui.Parent do
            for _, btn in ipairs(gui:GetChildren()) do
                if btn:IsA("TextButton") then
                    local st = btn:FindFirstChildOfClass("UIStroke")
                    local grad = btn:FindFirstChildOfClass("UIGradient")
                    local topAccent = btn:FindFirstChild("OrangeAccent")
                    if btn:GetAttribute("PeakHubActive") == true then
                        btn.BackgroundColor3 = _G.PeakHubThemeAccent or OUTLINE
                        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        if grad then
                            grad.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, _G.PeakHubThemeSoft or (_G.PeakHubThemeAccent or OUTLINE)),
                                ColorSequenceKeypoint.new(1, _G.PeakHubThemeAccent or OUTLINE)
                            })
                        end
                        if st then
                            st.Color = _G.PeakHubThemeAccent or OUTLINE
                            st.Thickness = 3
                            st.Transparency = 0
                        end
                    else
                        if st then st.Color = _G.PeakHubThemeAccent or OUTLINE end
                        if topAccent then topAccent.BackgroundColor3 = _G.PeakHubThemeAccent or OUTLINE end
                    end
                end
            end
            task.wait(0.15)
        end
    end)

    _G.__VyzeRefreshSafeModeMobileVisuals = function()
        local locked = Config.SafeMode and safeModeIsLocked()
        if not locked then return end
        for _, key in ipairs({"autoLeft", "autoRight", "autoBat"}) do
            if mobBtnRefs[key] then pcall(mobBtnRefs[key], false) end
        end
    end

    pcall(_G.__VyzeRefreshSafeModeMobileVisuals)
end

_G.VyzeApplyMobileButtonSize = function()
    buildMobileButtons()
end
_G.VyzeApplyMobileButtonShape = function()
    buildMobileButtons()
end
_G.VyzeResetMobileButtons = function()
    pcall(function()
        if writefile then writefile(MOB_POS_FILE, "{}") end
    end)
    buildMobileButtons()
end

buildMobileButtons()






local playerEspEnabled = false
local playerTracersEnabled = false
local _espConn = nil
local _espObjects = {}
local TRACER_COLOR = Color3.fromRGB(255, 120, 0)
local TRACER_THICKNESS = 1
local _tracerGui = nil

local function ensureTracerGui()
    if _tracerGui and _tracerGui.Parent then return _tracerGui end
    local sg = Instance.new("ScreenGui")
    sg.Name = "VyzeTracers"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 50
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function()
        if gethui then
            sg.Parent = gethui()
        else
            sg.Parent = game:GetService("CoreGui")
        end
    end)
    if not sg.Parent then
        sg.Parent = LP:WaitForChild("PlayerGui")
    end
    _tracerGui = sg
    return sg
end

local function destroyTracerLine(line)
    if not line then return end
    pcall(function()
        if typeof(line) == "Instance" then
            line:Destroy()
        elseif line.Remove then
            line.Visible = false
            line:Remove()
        end
    end)
end

local function makeGuiTracerLine()
    local parent = ensureTracerGui()
    local fr = Instance.new("Frame")
    fr.Name = "TracerLine"
    fr.AnchorPoint = Vector2.new(0.5, 0.5)
    fr.BorderSizePixel = 0
    fr.BackgroundColor3 = TRACER_COLOR
    fr.BackgroundTransparency = 0
    fr.Size = UDim2.fromOffset(0, TRACER_THICKNESS)
    fr.Visible = false
    fr.ZIndex = 10
    fr.Parent = parent
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = fr
    return fr
end

local function updateGuiTracerLine(fr, from, to)
    local dx = to.X - from.X
    local dy = to.Y - from.Y
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist < 1 then
        fr.Visible = false
        return
    end
    local midX = (from.X + to.X) * 0.5
    local midY = (from.Y + to.Y) * 0.5
    fr.Size = UDim2.fromOffset(dist, TRACER_THICKNESS)
    fr.Position = UDim2.fromOffset(midX, midY)
    fr.Rotation = math.deg(math.atan2(dy, dx))
    fr.BackgroundColor3 = TRACER_COLOR
    fr.Visible = true
end

function clearEspFor(plr)
    local o = _espObjects[plr]
    if not o then return end
    if o.highlight then pcall(function() o.highlight:Destroy() end) end
    if o.line then destroyTracerLine(o.line) end
    _espObjects[plr] = nil
end

function clearAllEsp()
    for plr in pairs(_espObjects) do clearEspFor(plr) end
    _espObjects = {}
    if _tracerGui then
        pcall(function() _tracerGui:Destroy() end)
        _tracerGui = nil
    end
end

function updatePlayerEsp(plr)
    if not plr or plr == LP then return end
    local char = plr.Character
    local myChar = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local cam = workspace.CurrentCamera
    if not hrp or not myHrp or not cam then clearEspFor(plr); return end

    local o = _espObjects[plr]
    if not o then o = {}; _espObjects[plr] = o end


    if playerEspEnabled then
        if not o.highlight or not o.highlight.Parent then
            local hl = Instance.new("Highlight")
            hl.Name = "VyzeHL"
            hl.FillColor = TRACER_COLOR
            hl.OutlineColor = TRACER_COLOR
            hl.FillTransparency = 0.45
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Adornee = char
            hl.Parent = char
            o.highlight = hl
        else
            o.highlight.Adornee = char
        end
    elseif o.highlight then
        pcall(function() o.highlight:Destroy() end)
        o.highlight = nil
    end

    if not playerTracersEnabled then
        if o.line then destroyTracerLine(o.line); o.line = nil end
        return
    end


    if not o.line or (typeof(o.line) == "Instance" and not o.line.Parent) then
        if o.line then destroyTracerLine(o.line) end
        o.line = makeGuiTracerLine()
    end
    if not o.line then return end

    local p1, on1 = cam:WorldToViewportPoint(myHrp.Position)
    local p2, on2 = cam:WorldToViewportPoint(hrp.Position)

    if p1.Z > 0 and p2.Z > 0 then
        local vsize = cam.ViewportSize
        local from = Vector2.new(p1.X, p1.Y)
        local to = Vector2.new(p2.X, p2.Y)

        from = Vector2.new(
            math.clamp(from.X, -50, vsize.X + 50),
            math.clamp(from.Y, -50, vsize.Y + 50)
        )
        to = Vector2.new(
            math.clamp(to.X, -50, vsize.X + 50),
            math.clamp(to.Y, -50, vsize.Y + 50)
        )
        updateGuiTracerLine(o.line, from, to)
    else
        if typeof(o.line) == "Instance" then
            o.line.Visible = false
        else
            pcall(function() o.line.Visible = false end)
        end
    end
end

function refreshAllEsp()
    if not playerEspEnabled and not playerTracersEnabled then
        clearAllEsp()
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then pcall(updatePlayerEsp, plr) end
    end
    for plr in pairs(_espObjects) do
        if not plr.Parent then clearEspFor(plr) end
    end
end

startPlayerEsp = function()
    playerEspEnabled = true
    Config.PlayerESP = true
    refreshAllEsp()
    if not _espConn then
        _espConn = RunService.RenderStepped:Connect(function()
            if playerEspEnabled or playerTracersEnabled then refreshAllEsp() end
        end)
    end
end

stopPlayerEsp = function()
    playerEspEnabled = false
    Config.PlayerESP = false
    if not playerTracersEnabled then
        if _espConn then _espConn:Disconnect(); _espConn = nil end
        clearAllEsp()
    else
        refreshAllEsp()
    end
end

startPlayerTracers = function()
    playerTracersEnabled = true
    Config.PlayerTracers = true
    refreshAllEsp()
    if not _espConn then
        _espConn = RunService.RenderStepped:Connect(function()
            if playerEspEnabled or playerTracersEnabled then refreshAllEsp() end
        end)
    end
end

stopPlayerTracers = function()
    playerTracersEnabled = false
    Config.PlayerTracers = false
    if not playerEspEnabled then
        if _espConn then _espConn:Disconnect(); _espConn = nil end
        clearAllEsp()
    else
        refreshAllEsp()
    end
end

Players.PlayerRemoving:Connect(function(plr) clearEspFor(plr) end)


local ragdollCountdownConn, ragdollCountdownCharConn = nil, nil
local ragdollCountdownEndTime = 0
local RAGDOLL_COUNTDOWN_SECONDS = 2.6
local ragdollCountdownGui, ragdollCountdownLabel = nil, nil

local function getRagdollCountdownAnchor(char)
    if not char then return nil end
    local preferred = {"HumanoidRootPart", "UpperTorso", "Torso", "LowerTorso", "Head", "RightUpperArm", "LeftUpperArm", "Right Arm", "Left Arm", "RightUpperLeg", "LeftUpperLeg", "Right Leg", "Left Leg"}
    for _, name in ipairs(preferred) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then return part end
    end
    for _, item in ipairs(char:GetDescendants()) do
        if item:IsA("BasePart") and item.Name ~= "Handle" then return item end
    end
    return nil
end

function ensureRagdollCdGui()
    if ragdollCountdownLabel and ragdollCountdownLabel.Parent then
        local anchor = getRagdollCountdownAnchor(LP.Character)
        if ragdollCountdownGui and anchor then ragdollCountdownGui.Adornee = anchor end
        return
    end
    local bb = Instance.new("BillboardGui")
    bb.Name = "VyzeRagdollCD"
    bb.Size = UDim2.new(0, 220, 0, 30)
    bb.StudsOffset = Vector3.new(0, 5.0, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 200
    bb.Adornee = getRagdollCountdownAnchor(LP.Character)
    pcall(function()
        if gethui then bb.Parent = gethui() else bb.Parent = game:GetService("CoreGui") end
    end)
    if not bb.Parent then bb.Parent = LP:WaitForChild("PlayerGui") end
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = ""

    lbl.Visible = false
    lbl.TextColor3 = Color3.fromRGB(255, 180, 80)
    lbl.TextStrokeTransparency = 0.1
    lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 18
    lbl.Parent = bb
    ragdollCountdownGui = bb
    ragdollCountdownLabel = lbl
end

stopRagdollCountdown = function()
    if ragdollCountdownConn then ragdollCountdownConn:Disconnect(); ragdollCountdownConn = nil end
    if ragdollCountdownCharConn then ragdollCountdownCharConn:Disconnect(); ragdollCountdownCharConn = nil end
    if ragdollCountdownLabel then
        ragdollCountdownLabel.Visible = false
        ragdollCountdownLabel.Text = ""
    end
end

hookRagdollCountdown = function(char)
    stopRagdollCountdown()
    if not Config.RagdollCountdown then return end
    ensureRagdollCdGui()
    char = char or LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 4)
    if not hum then return end
    local countdownWasRag = false
    local function beginCountdown()
        countdownWasRag = true
        ragdollCountdownEndTime = tick() + RAGDOLL_COUNTDOWN_SECONDS
        if ragdollCountdownLabel then

            ragdollCountdownLabel.Visible = false
            ragdollCountdownLabel.Text = ""
        end
    end
    local function isRag()
        local st = hum:GetState()
        return hum.PlatformStand
            or st == Enum.HumanoidStateType.Physics
            or st == Enum.HumanoidStateType.Ragdoll
            or st == Enum.HumanoidStateType.FallingDown
    end
    ragdollCountdownCharConn = hum.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Physics
            or newState == Enum.HumanoidStateType.Ragdoll
            or newState == Enum.HumanoidStateType.FallingDown then
            beginCountdown()
        end
    end)
    ragdollCountdownConn = RunService.RenderStepped:Connect(function()
        if not Config.RagdollCountdown then stopRagdollCountdown(); return end
        local anchor = getRagdollCountdownAnchor(LP.Character)
        if ragdollCountdownGui and anchor and ragdollCountdownGui.Adornee ~= anchor then
            ragdollCountdownGui.Adornee = anchor
        end
        if not ragdollCountdownLabel then return end
        local ragNow = isRag()
        if ragNow and not countdownWasRag then beginCountdown() end
        if not ragNow then countdownWasRag = false end
        local left = math.max(0, ragdollCountdownEndTime - tick())


        ragdollCountdownLabel.Visible = false
        ragdollCountdownLabel.Text = ""
    end)
end

LP.CharacterAdded:Connect(function(char)
    if Config.RagdollCountdown then
        task.wait(0.4)
        hookRagdollCountdown(char)
    end
end)


local SKY_TAG = "_VyzeSky"
local SKY_PRESETS = {
    ["Off"] = { kind = "off" },
    ["Night"] = { clock = 22, brightness = 2, ambient = {110,100,130}, outAmb = {120,110,140}, sky = {stars=4000,moon=18,sun=0,moonTex=true}, atm = {dens=0.45,color={120,60,180},decay={60,20,100},glare=0.5,haze=1.2} },
    ["Aurora"] = { clock = 14, brightness = 3, ambient = {150,120,150}, outAmb = {160,130,150}, atm = {dens=0.55,color={255,80,200},decay={255,20,150},glare=2.5,haze=3}, clouds = {cover=0.7,dens=0.7,color={255,240,250}} },
    ["Sunset"] = { clock = 17.2, brightness = 2.5, ambient = {170,120,100}, outAmb = {180,130,110}, sky = {stars=0,sun=25,moon=0}, atm = {dens=0.5,color={255,130,60},decay={255,80,30},glare=2,haze=2.5}, clouds = {cover=0.55,dens=0.55,color={255,200,140}} },
    ["Galaxy"] = { clock = 0, brightness = 1.5, ambient = {70,60,100}, outAmb = {80,70,110}, sky = {stars=10000,moon=30,sun=0}, atm = {dens=0.15,color={40,20,80},decay={20,10,50},glare=0.3,haze=0.5} },
    ["Cyber"] = { clock = 21, brightness = 2.2, ambient = {90,130,170}, outAmb = {100,140,180}, sky = {stars=2000,moon=12}, atm = {dens=0.4,color={0,200,255},decay={150,0,255},glare=2,haze=2}, clouds = {cover=0.4,dens=0.6,color={100,200,255}} },
    ["Sakura"] = { clock = 11, brightness = 3.5, ambient = {170,150,160}, outAmb = {180,160,170}, sky = {sun=8}, atm = {dens=0.3,color={255,200,220},decay={255,170,200},glare=1,haze=1.5}, clouds = {cover=0.6,dens=0.4,color={255,250,252}} },
    ["Pink Night"] = { clock = 23, brightness = 2.2, ambient = {120,60,110}, outAmb = {140,70,120}, sky = {stars=5000,moon=22,sun=0,moonTex=true}, atm = {dens=0.5,color={255,80,180},decay={140,30,100},glare=0.7,haze=1.4}, clouds = {cover=0.3,dens=0.5,color={180,90,150}} },
    ["Blood Moon"] = { clock = 22.5, brightness = 1.6, ambient = {130,40,40}, outAmb = {150,50,50}, sky = {stars=1500,moon=28,sun=0,moonTex=true}, atm = {dens=0.6,color={220,30,30},decay={120,10,10},glare=1.4,haze=2}, clouds = {cover=0.5,dens=0.7,color={120,30,30}} },
    ["Emerald Dawn"] = { clock = 6.5, brightness = 2.8, ambient = {130,170,140}, outAmb = {140,180,150}, sky = {sun=18,moon=0,stars=0}, atm = {dens=0.4,color={80,200,140},decay={40,150,90},glare=1.8,haze=2.2}, clouds = {cover=0.5,dens=0.5,color={200,255,220}} },
    ["Volcanic"] = { clock = 19, brightness = 2, ambient = {180,80,40}, outAmb = {200,90,50}, sky = {stars=200,sun=12,moon=0}, atm = {dens=0.75,color={255,60,0},decay={180,20,0},glare=3,haze=3.5}, clouds = {cover=0.8,dens=0.9,color={120,40,20}} },
    ["Arctic"] = { clock = 9, brightness = 3.2, ambient = {200,220,235}, outAmb = {210,230,245}, sky = {sun=10,stars=0,moon=0}, atm = {dens=0.3,color={180,220,255},decay={140,200,240},glare=1.5,haze=1.8}, clouds = {cover=0.7,dens=0.6,color={250,253,255}} },
    ["Vaporwave"] = { clock = 19.5, brightness = 2.4, ambient = {180,120,200}, outAmb = {190,130,210}, sky = {stars=1000,moon=14}, atm = {dens=0.45,color={255,100,220},decay={120,60,255},glare=2.2,haze=2.4}, clouds = {cover=0.55,dens=0.55,color={200,150,255}} },
    ["Toxic"] = { clock = 13, brightness = 2.5, ambient = {140,180,80}, outAmb = {150,190,90}, atm = {dens=0.55,color={100,220,40},decay={60,150,20},glare=1.8,haze=2.6}, clouds = {cover=0.65,dens=0.7,color={180,255,120}} },
    ["Heaven"] = { clock = 12, brightness = 4, ambient = {240,235,210}, outAmb = {250,245,220}, sky = {sun=16,moon=0,stars=0}, atm = {dens=0.25,color={255,250,220},decay={255,240,200},glare=3,haze=1.5}, clouds = {cover=0.85,dens=0.5,color={255,255,255}} },
    ["Storm"] = { clock = 15, brightness = 1.4, ambient = {90,90,110}, outAmb = {100,100,120}, sky = {stars=0,sun=6,moon=0}, atm = {dens=0.65,color={80,90,120},decay={40,50,80},glare=0.5,haze=3}, clouds = {cover=0.95,dens=0.95,color={60,65,80}} },
    ["Sunrise"] = { clock = 6.2, brightness = 2.8, ambient = {220,180,130}, outAmb = {230,190,140}, sky = {sun=22,stars=0,moon=0}, atm = {dens=0.45,color={255,180,100},decay={255,140,80},glare=2.4,haze=2.2}, clouds = {cover=0.4,dens=0.4,color={255,220,180}} },
    ["Deep Space"] = { clock = 0, brightness = 1, ambient = {30,25,50}, outAmb = {40,35,60}, sky = {stars=15000,moon=0,sun=0}, atm = {dens=0.08,color={15,5,40},decay={5,0,20},glare=0.2,haze=0.3} },
    ["Mint Sky"] = { clock = 10, brightness = 3.2, ambient = {180,230,210}, outAmb = {190,240,220}, sky = {sun=10}, atm = {dens=0.32,color={150,255,210},decay={100,220,180},glare=1.6,haze=1.6}, clouds = {cover=0.55,dens=0.45,color={240,255,250}} },
}
function _vC3(rgb) return Color3.fromRGB(rgb[1], rgb[2], rgb[3]) end
function clearVyzeSky()
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:GetAttribute(SKY_TAG) then pcall(function() child:Destroy() end) end
    end
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        for _, child in ipairs(terrain:GetChildren()) do
            if child:GetAttribute(SKY_TAG) then pcall(function() child:Destroy() end) end
        end
    end
end

applyCustomSky = function(mode)
    clearVyzeSky()
    local preset = SKY_PRESETS[mode]
    if not preset or preset.kind == "off" then
        Lighting.ClockTime = 14
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(100, 35, 0)
        Lighting.Ambient = Color3.fromRGB(100, 35, 0)
        Lighting.FogEnd = 100000
        Lighting.FogColor = Color3.fromRGB(100, 35, 0)
        Lighting.GlobalShadows = true
        return
    end
    Lighting.FogStart = 0
    Lighting.FogEnd = 100000
    Lighting.FogColor = Color3.fromRGB(100, 35, 0)
    Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
    Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
    Lighting.GlobalShadows = true
    Lighting.ClockTime = preset.clock or 14
    Lighting.Brightness = preset.brightness or 2
    if preset.outAmb then Lighting.OutdoorAmbient = _vC3(preset.outAmb) end
    if preset.ambient then Lighting.Ambient = _vC3(preset.ambient) end
    if preset.sky then
        local skyInst = Instance.new("Sky")
        skyInst:SetAttribute(SKY_TAG, true)
        if preset.sky.stars then skyInst.StarCount = preset.sky.stars end
        if preset.sky.moon then skyInst.MoonAngularSize = preset.sky.moon end
        if preset.sky.sun then skyInst.SunAngularSize = preset.sky.sun end
        if preset.sky.moonTex then skyInst.MoonTextureId = "rbxasset://sky/moon.jpg" end
        skyInst.Parent = Lighting
    end
    if preset.atm then
        local atm = Instance.new("Atmosphere")
        atm:SetAttribute(SKY_TAG, true)
        atm.Density = preset.atm.dens or 0.3
        atm.Color = _vC3(preset.atm.color)
        atm.Decay = _vC3(preset.atm.decay)
        atm.Glare = preset.atm.glare or 1
        atm.Haze = preset.atm.haze or 1
        atm.Parent = Lighting
    end
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if preset.clouds and terrain then
        local clouds = Instance.new("Clouds")
        clouds:SetAttribute(SKY_TAG, true)
        clouds.Cover = preset.clouds.cover or 0.5
        clouds.Density = preset.clouds.dens or 0.5
        clouds.Color = _vC3(preset.clouds.color)
        clouds.Parent = terrain
    end
end


local customAnimSnapshots = setmetatable({}, {__mode = "k"})

function snapshotCharacterAnimations(char)
    if not char or customAnimSnapshots[char] then return end
    local animate = char:FindFirstChild("Animate")
    if not animate then return end

    local snap = {
        animateDisabled = animate.Disabled,
        objects = {},
    }

    for _, obj in ipairs(animate:GetDescendants()) do
        if obj:IsA("Animation") then
            snap.objects[obj] = {
                parent = obj.Parent,
                name = obj.Name,
                id = obj.AnimationId,
            }
        end
    end

    customAnimSnapshots[char] = snap
end

function restoreCharacterAnimations(char)
    local snap = char and customAnimSnapshots[char]
    local animate = char and char:FindFirstChild("Animate")
    if not animate then return end

    if snap then
        for obj, info in pairs(snap.objects) do
            if obj and obj.Parent then
                pcall(function()
                    obj.AnimationId = info.id
                    obj.Name = info.name
                end)
            elseif info.parent and info.parent.Parent then
                local restored = Instance.new("Animation")
                restored.Name = info.name
                restored.AnimationId = info.id
                restored.Parent = info.parent
            end
        end

        for _, obj in ipairs(animate:GetDescendants()) do
            if obj:IsA("Animation") and not snap.objects[obj] then
                pcall(function() obj:Destroy() end)
            end
        end

        customAnimSnapshots[char] = nil
    end

    animate.Disabled = false

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
            pcall(function() track:Stop(0) end)
        end
    end

    task.defer(function()
        if animate and animate.Parent then
            animate.Disabled = true
            task.wait(0.03)
            if animate.Parent then animate.Disabled = false end
        end
    end)
end


local ANIM_PACKS = {
    ["Adidas Sports"] = {WalkAnim=18537392113, RunAnim=18537384940, JumpAnim=18537380791, FallAnim=18537367238, SwimIdle=18537387180, Swim=18537389531, Animation1=18537376492, Animation2=18537371272, ClimbAnim=18537363391},
    ["Adidas Community"] = {WalkAnim=122150855457006, RunAnim=82598234841035, JumpAnim=75290611992385, FallAnim=98600215928904, SwimIdle=109346520324160, Swim=133308483266208, Animation1=122257458498464, Animation2=102357151005774, ClimbAnim=88763136693023},
    ["Adidas Aura"] = {WalkAnim=83842218823011, RunAnim=118320322718866, JumpAnim=109996626521204, FallAnim=95603166884636, SwimIdle=94922130551805, Swim=134530128383903, Animation1=110211186840347, Animation2=114191137265065, ClimbAnim=97824616490448},
    ["Wicked Popular"] = {WalkAnim=92072849924640, RunAnim=72301599441680, JumpAnim=104325245285198, FallAnim=121152442762481, Animation1=118832222982049, ClimbAnim=131326830509784, SwimIdle=113199415118199, Swim=99384245425157, Animation2=76049494037641},
    Elder = {WalkAnim=10921111375, RunAnim=10921104374, JumpAnim=10921107367, FallAnim=10921105765, SwimIdle=10921110146, Swim=10921108971, ClimbAnim=10921100400, Animation1=10921101664, Animation2=10921102574},
    Zombie = {WalkAnim=10921355261, RunAnim=616163682, JumpAnim=10921351278, FallAnim=10921350320, SwimIdle=10921353442, Swim=10921352344, Animation1=10921344533, Animation2=10921345304, ClimbAnim=10921343576},
    Mage = {WalkAnim=10921152678, RunAnim=10921148209, JumpAnim=10921149743, FallAnim=10921148939, SwimIdle=10921151661, Swim=10921150788, ClimbAnim=10921143404, Animation1=10921144709, Animation2=10921145797},
    ["Catwalk Glam"] = {WalkAnim=109168724482748, RunAnim=81024476153754, JumpAnim=116936326516985, FallAnim=92294537340807, SwimIdle=98854111361360, Swim=134591743181628, ClimbAnim=119377220967554, Animation1=133806214992291, Animation2=94970088341563},
    Astronaut = {WalkAnim=10921046031, RunAnim=10921039308, JumpAnim=10921042494, FallAnim=10921040576, SwimIdle=10921045006, Swim=10921044000, ClimbAnim=10921032124, Animation1=10921034824, Animation2=10921036806},
    ["Wicked Dancing Through Life"] = {WalkAnim=73718308412641, RunAnim=135515454877967, JumpAnim=78508480717326, FallAnim=78147885297412, SwimIdle=129183123083281, Swim=110657013921774, ClimbAnim=129447497744818, Animation1=92849173543269, Animation2=132238900951109},
    Werewolf = {WalkAnim=10921342074, RunAnim=10921336997, FallAnim=10921337907, SwimIdle=10921341319, Swim=10921340419, ClimbAnim=10921329322, Animation1=10921330408, Animation2=10921333667},
    Superhero = {WalkAnim=10921298616, RunAnim=10921291831, JumpAnim=10921294559, FallAnim=10921293373, SwimIdle=10921297391, Swim=10921295495, ClimbAnim=10921286911, Animation1=10921288909, Animation2=10921290167},
    Toy = {WalkAnim=10921312010, RunAnim=10921306285, JumpAnim=10921308158, FallAnim=10921307241, SwimIdle=10921310341, Swim=10921309319, ClimbAnim=10921300839, Animation1=10921301576},
    ["No Boundaries"] = {WalkAnim=18747074203, RunAnim=18747070484, JumpAnim=18747069148, FallAnim=18747062535, SwimIdle=18747071682, Swim=18747073181, ClimbAnim=18747060903, Animation1=18747067405, Animation2=18747063918},
    NFL = {WalkAnim=110358958299415, RunAnim=117333533048078, JumpAnim=119846112151352, FallAnim=129773241321032, SwimIdle=79090109939093, Swim=132697394189921, ClimbAnim=134630013742019, Animation1=92080889861410, Animation2=74451233229259},
    ["Amazon Unboxed"] = {WalkAnim=90478085024465, RunAnim=134824450619865, JumpAnim=121454505477205, FallAnim=94788218468396, SwimIdle=129126268464847, Swim=105962919001086, ClimbAnim=121145883950231, Animation1=98281136301627},
    Vampire = {WalkAnim=10921326949, RunAnim=10921320299, JumpAnim=10921322186, FallAnim=10921321317, SwimIdle=10921325443, Swim=10921324408, ClimbAnim=10921314188, Animation1=10921315373},
    Ninja = {RunAnim=656118852, WalkAnim=656121766, JumpAnim=656117878, FallAnim=656115606, Swim=656119721, SwimIdle=656121397, ClimbAnim=656114359, Idle={656117400,656118341}},
    Robot = {RunAnim=616091570, WalkAnim=616095330, JumpAnim=616090535, FallAnim=616087089, Swim=616092998, SwimIdle=616094091, ClimbAnim=616086039, Idle={616088211,616089559}},
    Levitation = {RunAnim=616010382, WalkAnim=616013216, JumpAnim=616008936, FallAnim=616005863, Swim=616011509, SwimIdle=616012453, ClimbAnim=616003713, Idle={616006778,616008087}},
    Stylish = {RunAnim=616140816, WalkAnim=616146177, JumpAnim=616139451, FallAnim=616134815, Swim=616143378, SwimIdle=616144772, ClimbAnim=616133594, Idle={616136790,616138447}},
    Bubbly = {RunAnim=910025107, WalkAnim=910034870, JumpAnim=910016857, FallAnim=910001910, Swim=910028158, SwimIdle=910030921, ClimbAnim=909997997, Idle={910004836,910009958}},
    Cartoon = {RunAnim=742638842, WalkAnim=742640026, JumpAnim=742637942, FallAnim=742637151, Swim=742639220, SwimIdle=742639812, ClimbAnim=742636889, Idle={742637544,742638445}},
}

function _pick(pack, ...)
    for i = 1, select("#", ...) do
        local v = pack[select(i, ...)]
        if v ~= nil then return v end
    end
    return nil
end

local _unwalkConn = nil

local function _setAnim(animObj, id)
    if not animObj or not id then return end
    pcall(function()
        animObj.AnimationId = "rbxassetid://" .. tostring(id)
    end)
end

local function _ensureAnim(folder, name)
    if not folder then return nil end
    local a = folder:FindFirstChild(name)
    if not a then
        a = Instance.new("Animation")
        a.Name = name
        a.Parent = folder
    end
    return a
end

local function _ensureFolder(animate, folderName)
    local f = animate:FindFirstChild(folderName)
    if not f then
        f = Instance.new("Folder")
        f.Name = folderName
        f.Parent = animate
    end
    return f
end

local function waitForAnimate(char)
    if not char then return nil end
    for _ = 1, 40 do
        local a = char:FindFirstChild("Animate")
        if a and a:FindFirstChild("walk") and a:FindFirstChild("run") then
            return a
        end
        task.wait(0.1)
    end
    return char:FindFirstChild("Animate")
end

applyAnimPack = function(packName)
    if not Config.CustomAnim then return end
    Config.Unwalk = false
    if type(stopUnwalk) == "function" then

        if _unwalkConn then pcall(function() _unwalkConn:Disconnect() end); _unwalkConn = nil end
    end
    packName = packName or Config.AnimPack
    local pack = ANIM_PACKS[packName]
    if not pack then

        for k, v in pairs(ANIM_PACKS) do
            if string.lower(k) == string.lower(tostring(packName)) then
                pack = v
                packName = k
                break
            end
        end
    end
    if not pack then return end
    Config.AnimPack = packName

    local char = LP.Character
    if not char then return end
    local animate = waitForAnimate(char)
    if not animate then return end

    snapshotCharacterAnimations(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
            pcall(function() t:Stop(0) end)
        end
    end

    local runObj = _ensureAnim(_ensureFolder(animate, "run"), "RunAnim")
    local walkObj = _ensureAnim(_ensureFolder(animate, "walk"), "WalkAnim")
    local jumpObj = _ensureAnim(_ensureFolder(animate, "jump"), "JumpAnim")
    local fallObj = _ensureAnim(_ensureFolder(animate, "fall"), "FallAnim")
    local climbObj = _ensureAnim(_ensureFolder(animate, "climb"), "ClimbAnim")
    local swimObj = _ensureAnim(_ensureFolder(animate, "swim"), "Swim")
    local swimIdleObj = _ensureAnim(_ensureFolder(animate, "swimidle"), "SwimIdle")
    local idleFolder = _ensureFolder(animate, "idle")

    _setAnim(walkObj, _pick(pack, "WalkAnim", "Walk"))
    _setAnim(runObj, _pick(pack, "RunAnim", "Run"))
    _setAnim(jumpObj, _pick(pack, "JumpAnim", "Jump"))
    _setAnim(fallObj, _pick(pack, "FallAnim", "Fall"))
    _setAnim(climbObj, _pick(pack, "ClimbAnim", "Climb"))
    _setAnim(swimObj, _pick(pack, "Swim"))
    _setAnim(swimIdleObj, _pick(pack, "SwimIdle") or _pick(pack, "Swim"))

    if idleFolder then
        local a1 = _pick(pack, "Animation1")
        local a2 = _pick(pack, "Animation2")
        if a1 or a2 then
            _setAnim(_ensureAnim(idleFolder, "Animation1"), a1 or a2)
            _setAnim(_ensureAnim(idleFolder, "Animation2"), a2 or a1)
        elseif pack.Idle then
            _setAnim(_ensureAnim(idleFolder, "Animation1"), pack.Idle[1])
            _setAnim(_ensureAnim(idleFolder, "Animation2"), pack.Idle[2] or pack.Idle[1])
        end
    end

    animate.Disabled = true
    task.wait(0.06)
    animate.Disabled = false

    if hum then
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.Landed)
            task.wait(0.03)
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end
end

function startUnwalk()
    Config.Unwalk = true
    Config.CustomAnim = false
    if _unwalkConn then pcall(function() _unwalkConn:Disconnect() end); _unwalkConn = nil end
    local function stopTracks(char)
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
                pcall(function() t:Stop(0) end)
            end
        end
        local animate = char:FindFirstChild("Animate")
        if animate then
            pcall(function() animate.Disabled = true end)
        end
    end
    local char = LP.Character
    if char then
        pcall(function() snapshotCharacterAnimations(char) end)
        stopTracks(char)
    end

    _unwalkConn = RunService.Heartbeat:Connect(function()
        if not Config.Unwalk then return end
        local c = LP.Character
        if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
            pcall(function() t:Stop(0) end)
        end
        local animate = c:FindFirstChild("Animate")
        if animate and not animate.Disabled then
            pcall(function() animate.Disabled = true end)
        end
    end)
end

function stopUnwalk()
    Config.Unwalk = false
    if _unwalkConn then pcall(function() _unwalkConn:Disconnect() end); _unwalkConn = nil end
    local char = LP.Character
    if not char then return end
    local animate = char:FindFirstChild("Animate")
    if animate then pcall(function() animate.Disabled = false end) end
    if Config.CustomAnim then
        pcall(function() applyAnimPack(Config.AnimPack) end)
    else
        pcall(function() restoreCharacterAnimations(char) end)
    end
end

LP.CharacterAdded:Connect(function(char)
    if Config.Unwalk then
        task.wait(0.5)
        pcall(startUnwalk)
    elseif Config.CustomAnim then
        task.wait(0.6)
        applyAnimPack(Config.AnimPack)
    else
        task.wait(0.15)
        pcall(function()
            local animate = char and char:FindFirstChild("Animate")
            if animate then animate.Disabled = false end
        end)
    end
end)


-- Anti Lag: processing in batches to avoid a single long frame; original settings are cached and restored.
local antiLagState = { conn = nil, active = false, cache = {}, lighting = nil, effects = {} }

local function peakCacheProperty(instance, property)
    local entry = antiLagState.cache[instance]
    if not entry then entry = {}; antiLagState.cache[instance] = entry end
    if entry[property] == nil then
        local ok, value = pcall(function() return instance[property] end)
        if ok then entry[property] = value end
    end
end

function _applyAntiLagObj(instance)
    if not antiLagState.active then return end
    pcall(function()
        if instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") or instance:IsA("Fire") or instance:IsA("Smoke") or instance:IsA("Sparkles") then
            peakCacheProperty(instance, "Enabled")
            instance.Enabled = false
        elseif instance:IsA("Decal") or instance:IsA("Texture") then
            peakCacheProperty(instance, "Transparency")
            instance.Transparency = 1
        elseif instance:IsA("BasePart") then
            peakCacheProperty(instance, "Material")
            peakCacheProperty(instance, "Reflectance")
            peakCacheProperty(instance, "CastShadow")
            instance.Material = Enum.Material.Plastic
            instance.Reflectance = 0
            instance.CastShadow = false
        elseif instance:IsA("PostEffect") then
            peakCacheProperty(instance, "Enabled")
            instance.Enabled = false
        end
    end)
end

enableAntiLag = function()
    if antiLagState.active then return end
    antiLagState.active = true
    antiLagState.cache = {}
    antiLagState.lighting = {
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        Brightness = Lighting.Brightness,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
    }
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("PostEffect") then
            antiLagState.effects[child] = child.Enabled
            pcall(function() child.Enabled = false end)
        end
    end
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    if antiLagState.conn then antiLagState.conn:Disconnect() end
    antiLagState.conn = workspace.DescendantAdded:Connect(function(descendant)
        if antiLagState.active then _applyAntiLagObj(descendant) end
    end)
    task.spawn(function()
        local descendants = workspace:GetDescendants()
        for i = 1, #descendants do
            if not antiLagState.active then break end
            _applyAntiLagObj(descendants[i])
            if i % 180 == 0 then task.wait() end
        end
    end)
end

disableAntiLag = function()
    antiLagState.active = false
    if antiLagState.conn then antiLagState.conn:Disconnect(); antiLagState.conn = nil end
    for instance, properties in pairs(antiLagState.cache) do
        if instance and instance.Parent then
            for property, value in pairs(properties) do pcall(function() instance[property] = value end) end
        end
    end
    table.clear(antiLagState.cache)
    for effect, enabled in pairs(antiLagState.effects) do
        if effect and effect.Parent then pcall(function() effect.Enabled = enabled end) end
    end
    table.clear(antiLagState.effects)
    if antiLagState.lighting then
        for property, value in pairs(antiLagState.lighting) do pcall(function() Lighting[property] = value end) end
        antiLagState.lighting = nil
    end
end


local stretchRezConn = nil
local stretchValue = 0.70
enableStretchRez = function()
    if stretchRezConn then stretchRezConn:Disconnect() end
    stretchRezConn = RunService.RenderStepped:Connect(function()
        if not Config.StretchRes then
            if stretchRezConn then stretchRezConn:Disconnect(); stretchRezConn = nil end
            return
        end
        local cam = workspace.CurrentCamera
        if cam then
            cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, stretchValue, 0, 0, 0, 1)
        end
    end)
end
disableStretchRez = function()
    if stretchRezConn then stretchRezConn:Disconnect(); stretchRezConn = nil end
end


local customFovConn = nil
enableCustomFov = function()
    if customFovConn then customFovConn:Disconnect() end
    pcall(function() workspace.CurrentCamera.FieldOfView = Config.FOVValue end)
    customFovConn = RunService.RenderStepped:Connect(function()
        if not Config.FOVChange then
            if customFovConn then customFovConn:Disconnect(); customFovConn = nil end
            return
        end
        pcall(function() workspace.CurrentCamera.FieldOfView = Config.FOVValue end)
    end)
end
disableCustomFov = function()
    if customFovConn then customFovConn:Disconnect(); customFovConn = nil end
    pcall(function() workspace.CurrentCamera.FieldOfView = 70 end)
end






local overheadGui = nil
local overheadDiscord = nil
local overheadSpeed = nil
local overheadRagdoll = nil
local overheadConn = nil
local overheadRagEnd = 0
local OVERHEAD_PURPLE = Color3.fromRGB(255, 180, 80)



local function getOverheadBodyAnchor(char)
    if not char then return nil end
    local preferred = {
        "HumanoidRootPart", "UpperTorso", "Torso", "LowerTorso",
        "Head", "UpperTorso", "RightUpperTorso", "LeftUpperTorso",
        "RightUpperArm", "LeftUpperArm", "Right Arm", "Left Arm",
        "RightUpperLeg", "LeftUpperLeg", "Right Leg", "Left Leg",
    }
    for _, partName in ipairs(preferred) do
        local part = char:FindFirstChild(partName)
        if part and part:IsA("BasePart") and part:IsDescendantOf(char) then
            return part
        end
    end

    for _, item in ipairs(char:GetDescendants()) do
        if item:IsA("BasePart") and item.Name ~= "Handle" then
            return item
        end
    end
    return nil
end

function ensureOverheadLabels(char)
    char = char or LP.Character
    if not char then return end
    local anchor = getOverheadBodyAnchor(char)
    if not anchor then return end

    if overheadGui and overheadGui.Parent then
        if overheadGui.Adornee ~= anchor then
            overheadGui.Adornee = anchor
        end
        return
    end

    pcall(function()
        if overheadGui then overheadGui:Destroy() end
    end)

    local bb = Instance.new("BillboardGui")
    bb.Name = "VyzeOverhead"
    bb.Size = UDim2.new(0, 200, 0, 70)
    bb.StudsOffset = Vector3.new(0, 3.4, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 200
    bb.Adornee = anchor
    local parented = false
    pcall(function()
        if gethui then bb.Parent = gethui(); parented = bb.Parent ~= nil end
    end)
    if not parented then
        pcall(function() bb.Parent = game:GetService("CoreGui") end)
    end
    if not bb.Parent then
        bb.Parent = LP:WaitForChild("PlayerGui")
    end
    overheadGui = bb

    bb.Size = UDim2.new(0, 240, 0, 90)
    bb.StudsOffset = Vector3.new(0, 3.8, 0)

    local function makeLbl(y, size, text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, size)
        lbl.Position = UDim2.new(0, 0, 0, y)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = _G.PeakHubThemeAccent or OVERHEAD_PURPLE
        lbl.Font = Enum.Font.GothamBlack
        lbl.TextSize = size
        lbl.TextStrokeTransparency = 0.25
        lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
        lbl.Parent = bb
        return lbl
    end


    overheadRagdoll = makeLbl(0, 18, "")
    overheadRagdoll.TextSize = 15
    overheadRagdoll.Visible = false

    overheadDiscord = makeLbl(20, 26, "discord.gg/peakhub")
    overheadDiscord.TextSize = 20

    local div = Instance.new("Frame")
    div.Name = "Divider"
    div.Size = UDim2.new(0, 120, 0, 1)
    div.Position = UDim2.new(0.5, -60, 0, 48)
    div.BackgroundColor3 = _G.PeakHubThemeAccent or Color3.fromRGB(255, 180, 80)
    div.BackgroundTransparency = 0.25
    div.BorderSizePixel = 0
    div.Parent = bb

    overheadSpeed = makeLbl(52, 20, "Speed: " .. formatSpeedNum(Config.NormalSpeed or 59.5))
    overheadSpeed.TextSize = 15
end

function updateOverheadSpeedText()
    if overheadSpeed then
        overheadSpeed.Text = "Speed: " .. formatSpeedNum(getActiveSpeed())
        overheadSpeed.TextColor3 = _G.PeakHubThemeAccent or OVERHEAD_PURPLE
    end
end



local overheadWasInRag = false
local OVERHEAD_RAGDOLL_SECONDS = 2.6

RunService.RenderStepped:Connect(function()
    ensureOverheadLabels(LP.Character)
    updateOverheadSpeedText()
    if overheadDiscord then overheadDiscord.TextColor3 = _G.PeakHubThemeAccent or OVERHEAD_PURPLE end
    if overheadSpeed then overheadSpeed.TextColor3 = _G.PeakHubThemeAccent or OVERHEAD_PURPLE end
    if overheadDiscord and overheadDiscord.Parent then
        local dividerObj = overheadDiscord.Parent:FindFirstChild("Divider")
        if dividerObj then dividerObj.BackgroundColor3 = _G.PeakHubThemeAccent or OVERHEAD_PURPLE end
    end

    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local inRag = false
    if hum then
        local st = hum:GetState()
        inRag = hum.PlatformStand
            or st == Enum.HumanoidStateType.Physics
            or st == Enum.HumanoidStateType.Ragdoll
            or st == Enum.HumanoidStateType.FallingDown
    end


    local endAttr = LP:GetAttribute("RagdollEndTime")
    if type(endAttr) == "number" and endAttr > workspace:GetServerTimeNow() then
        inRag = true
    end



    if inRag and not overheadWasInRag then
        overheadRagEnd = tick() + OVERHEAD_RAGDOLL_SECONDS
    end
    overheadWasInRag = inRag

    if overheadRagdoll then
        local left = math.max(0, overheadRagEnd - tick())
        if Config.RagdollCountdown and overheadRagEnd > 0 and left > 0 then

            overheadRagdoll.Visible = true
            overheadRagdoll.Text = string.format("%.1f", left)
            overheadRagdoll.TextColor3 = _G.PeakHubThemeAccent or OVERHEAD_PURPLE
        else

            overheadRagdoll.Visible = false
            overheadRagdoll.Text = ""
            overheadRagEnd = 0
        end
    end
end)

LP.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    ensureOverheadLabels(char)
end)
if LP.Character then ensureOverheadLabels(LP.Character) end




task.defer(function()
    task.wait(0.25)
    if Config.AntiRagdoll and _G._VyzeStartAntiRagdoll then
        pcall(_G._VyzeStartAntiRagdoll)
    end
    if syncAutoAntiDie then pcall(syncAutoAntiDie) end
    if Config.BatCounter and startBatCounter then pcall(startBatCounter) end
    if Config.MedusaCounter and startMedusaCounter then pcall(startMedusaCounter) end
    if Config.PlayerESP and startPlayerEsp then pcall(startPlayerEsp) end
    if Config.PlayerTracers and startPlayerTracers then pcall(startPlayerTracers) end
    if Config.RagdollCountdown and LP.Character and hookRagdollCountdown then
        pcall(hookRagdollCountdown, LP.Character)
    end
    if Config.Unwalk and startUnwalk then pcall(startUnwalk) elseif Config.CustomAnim and applyAnimPack then pcall(applyAnimPack, Config.AnimPack) end
    if Config.NoCamCollision and setNoCamCollision then pcall(setNoCamCollision, true) end
    if Config.AutoTPDown then pcall(startAutoTPDown) end
    if Config.AntiLag and enableAntiLag then pcall(enableAntiLag) end
    if Config.StretchRes and enableStretchRez then pcall(enableStretchRez) end
    if Config.FOVChange and enableCustomFov then pcall(enableCustomFov) end
    if Config.AutoSteal and startAutoStealSystem then pcall(startAutoStealSystem) end
    if Config.BatAimbot and startBatAimbot then
        State.autoBatToggled = true
        pcall(startBatAimbot)
    end
end)



end
__vyzeInitVisualLogic()





function playVyzeIntro()
    if Config.IntroEnabled == false then return end
    local Tw = TweenService
    local Sg = game:GetService("StarterGui")
    local pg = LP:WaitForChild("PlayerGui")
    local D = 3.2
    local introAccent = _G.PeakHubThemeAccent or COLORS.Accent or Color3.fromRGB(255, 120, 0)
    local introSoft = _G.PeakHubThemeSoft or COLORS.AccentSoft or Color3.fromRGB(100, 35, 0)
    local Silver1 = introAccent
    local Silver2 = introAccent
    local Silver3 = introAccent
    local Silver4 = introSoft
    local Purple = introAccent

    local introBlur
    local function tn(i, t, st, dr, pr2)
        return Tw:Create(i, TweenInfo.new(t, st, dr), pr2)
    end
    pcall(function() Sg:SetCore("TopbarEnabled", false) end)
    local function uf() pcall(function() Sg:SetCore("TopbarEnabled", true) end) end

    local ex = pg:FindFirstChild("VyzeIntro")
    if ex then ex:Destroy() end
    local gui = Instance.new("ScreenGui")
    gui.Name = "VyzeIntro"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 1000
    gui.Parent = pg
    local introActive = true


    local INTRO_SONG_URL = "https://files.catbox.moe/siru6c.mp3"
    local INTRO_SONG_FILE = "VyzeIntro_Song.mp3"
    local snd = Instance.new("Sound")
    snd.Name = "PeakHubIntroMusic"
    snd.SoundId = INTRO_SONG_URL
    snd.Volume = 1
    snd.Looped = false
    snd.Parent = gui
    pcall(function() snd:Play() end)
    task.spawn(function()
        pcall(function()
            local alreadyReady = isfile and isfile(INTRO_SONG_FILE)
            if not alreadyReady and writefile then
                local data = game:HttpGet(INTRO_SONG_URL)
                if data and #data > 100 then writefile(INTRO_SONG_FILE, data) end
            end
            local localId
            if isfile and isfile(INTRO_SONG_FILE) then
                if getcustomasset then localId = getcustomasset(INTRO_SONG_FILE)
                elseif getsynasset then localId = getsynasset(INTRO_SONG_FILE) end
            end

            if localId and not snd.IsPlaying then
                snd.SoundId = tostring(localId)
                snd:Play()
            end
        end)
    end)
    gui.Destroying:Connect(function()
        pcall(function() snd:Stop(); snd:Destroy() end)
    end)


    local skipBtn = Instance.new("TextButton", gui)
    skipBtn.Size = UDim2.new(0, 130, 0, 38)
    skipBtn.Position = UDim2.new(1, -160, 0, 20)
    skipBtn.BackgroundColor3 = introAccent
    skipBtn.BackgroundTransparency = 0.85
    skipBtn.BorderSizePixel = 0
    skipBtn.Text = "SKIP INTRO"
    skipBtn.TextColor3 = introAccent
    skipBtn.TextTransparency = 1
    skipBtn.Font = Enum.Font.GothamBold
    skipBtn.TextSize = 13
    skipBtn.ZIndex = 50
    skipBtn.AutoButtonColor = false
    Instance.new("UICorner", skipBtn).CornerRadius = UDim.new(1, 0)
    local skipStroke = Instance.new("UIStroke", skipBtn)
    skipStroke.Color = introAccent
    skipStroke.Thickness = 1
    skipStroke.Transparency = 1
    task.delay(0.4, function()
        tn(skipBtn, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
            Position = UDim2.new(1, -145, 0, 20), TextTransparency = 0, BackgroundTransparency = 0.75
        }):Play()
        tn(skipStroke, 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Transparency = 0.4}):Play()
    end)
    skipBtn.MouseButton1Click:Connect(function()
        if not introActive then return end
        introActive = false
        pcall(function() if introBlur then introBlur:Destroy() end end)
        pcall(function() gui:Destroy() end)
        uf()
    end)


    pcall(function()
        local old = Lighting:FindFirstChild("VyzeIntroBlur")
        if old then old:Destroy() end
    end)
    introBlur = Instance.new("BlurEffect")
    introBlur.Name = "VyzeIntroBlur"
    introBlur.Size = 0
    introBlur.Parent = Lighting
    tn(introBlur, 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Size = 22}):Play()

    local bgGrad = Instance.new("Frame", gui)
    bgGrad.Size = UDim2.new(1, 0, 1, 0)
    bgGrad.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bgGrad.BackgroundTransparency = 1
    bgGrad.BorderSizePixel = 0
    bgGrad.Active = false
    bgGrad.ZIndex = 1
    tn(bgGrad, 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundTransparency = 0.55}):Play()


    local ringContainer = Instance.new("Frame", gui)
    ringContainer.Size = UDim2.new(0, 160, 0, 160)
    ringContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    ringContainer.Position = UDim2.new(0.5, 0, 0.28, 0)
    ringContainer.BackgroundTransparency = 1
    ringContainer.Visible = false
    ringContainer.ZIndex = 5

    local ring = Instance.new("Frame", ringContainer)
    ring.Size = UDim2.new(1, 0, 1, 0)
    ring.BackgroundTransparency = 1
    local ringStroke = Instance.new("UIStroke", ring)
    ringStroke.Thickness = 2
    ringStroke.Color = Purple
    ringStroke.Transparency = 0.5
    task.spawn(function()
        while gui.Parent and introActive do
            task.wait()
            ring.Rotation = (ring.Rotation + 1.5) % 360
        end
    end)

    local letterFrame = Instance.new("Frame", ringContainer)
    letterFrame.Size = UDim2.new(0, 90, 0, 90)
    letterFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    letterFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    letterFrame.BackgroundTransparency = 1
    letterFrame.ZIndex = 6

    local function makeLetter(ch, ax, ay)
        local lb = Instance.new("TextLabel", letterFrame)
        lb.Size = UDim2.new(0.5, -4, 0.5, -4)
        lb.Position = UDim2.new(ax, 2, ay, 2)
        lb.BackgroundTransparency = 1
        lb.Text = ch
        lb.TextColor3 = Purple
        lb.Font = Enum.Font.GothamBlack
        lb.TextScaled = true
        lb.TextTransparency = 1
        lb.ZIndex = 7
        local g = Instance.new("UIGradient", lb)
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 180, 80)),
            ColorSequenceKeypoint.new(0.5, Purple),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 180, 80)),
        })
        return lb
    end

    local L_V = makeLetter("V", 0, 0)
    local L_Y = makeLetter("Y", 0.5, 0)
    local L_Z = makeLetter("Z", 0, 0.5)
    local L_E = makeLetter("E", 0.5, 0.5)


    local peakTitle = Instance.new("TextLabel", gui)
    peakTitle.Name = "PeakHubIntroTitle"
    peakTitle.Size = UDim2.new(1, -40, 0, 110)
    peakTitle.AnchorPoint = Vector2.new(0.5, 0.5)
    peakTitle.Position = UDim2.new(0.5, 0, 0.5, 0)
    peakTitle.BackgroundTransparency = 1
    peakTitle.Text = "PEAK HUB"
    peakTitle.TextColor3 = introAccent
    peakTitle.Font = Enum.Font.GothamBlack
    peakTitle.TextScaled = true
    peakTitle.TextTransparency = 1
    peakTitle.ZIndex = 15
    peakTitle.TextStrokeTransparency = 0.45
    peakTitle.TextStrokeColor3 = introSoft
    local peakTitleConstraint = Instance.new("UITextSizeConstraint", peakTitle)
    peakTitleConstraint.MaxTextSize = 76
    peakTitleConstraint.MinTextSize = 24
    local peakTitleGradient = Instance.new("UIGradient", peakTitle)
    peakTitleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, introAccent:Lerp(Color3.fromRGB(255, 255, 255), 0.28)),
        ColorSequenceKeypoint.new(0.5, introAccent),
        ColorSequenceKeypoint.new(1, introAccent:Lerp(Color3.fromRGB(255, 255, 255), 0.28)),
    })


    local function bw(word, yp, tc, sz, sp)
        local co = Instance.new("Frame", gui)
        co.Size = UDim2.new(1, 0, 0, sz + 10)
        co.Position = UDim2.new(0, 0, yp, 0)
        co.BackgroundTransparency = 1
        co.ZIndex = 5
        local lo = Instance.new("UIListLayout", co)
        lo.FillDirection = Enum.FillDirection.Horizontal
        lo.HorizontalAlignment = Enum.HorizontalAlignment.Center
        lo.VerticalAlignment = Enum.VerticalAlignment.Center
        lo.Padding = UDim.new(0, sp or 2)
        local le = {}
        for i = 1, #word do
            local lb = Instance.new("TextLabel", co)
            lb.LayoutOrder = i
            lb.Size = UDim2.new(0, sz * 0.55, 0, sz)
            lb.BackgroundTransparency = 1
            lb.Text = word:sub(i, i)
            lb.TextColor3 = tc
            lb.Font = Enum.Font.GothamBlack
            lb.TextScaled = true
            lb.TextTransparency = 1
            lb.ZIndex = 5
            local grad = Instance.new("UIGradient", lb)
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 180, 80)),
                ColorSequenceKeypoint.new(0.45, Purple),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 180, 80)),
            })
            grad.Offset = Vector2.new(-0.8, 0)
            le[i] = lb
        end
        return le
    end
    local titleLetters = {}


    local giant2 = Instance.new("TextLabel", gui)
    giant2.Size = UDim2.new(1, 0, 0, 220)
    giant2.Position = UDim2.new(0, 0, 0.35, 0)
    giant2.BackgroundTransparency = 1
    giant2.Text = ""
    giant2.TextColor3 = Purple
    giant2.Font = Enum.Font.GothamBlack
    giant2.TextSize = 20
    giant2.TextTransparency = 1
    giant2.ZIndex = 20
    giant2.TextStrokeTransparency = 0.4
    giant2.TextStrokeColor3 = Color3.new(0,0,0)


    local particleContainer = Instance.new("Frame", gui)
    particleContainer.Size = UDim2.new(1, 0, 1, 0)
    particleContainer.BackgroundTransparency = 1
    particleContainer.ZIndex = 4
    for i = 1, 30 do
        local dot = Instance.new("Frame", particleContainer)
        local size = math.random(2, 5)
        dot.Size = UDim2.new(0, size, 0, size)
        dot.Position = UDim2.new(math.random(), 0, math.random(), 0)
        dot.BackgroundColor3 = Purple
        dot.BackgroundTransparency = 0.3 + math.random() * 0.5
        dot.BorderSizePixel = 0
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    end


    task.delay(0.05, function()
        if introActive then
            tn(peakTitle, 0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {TextTransparency = 0}):Play()
        end
    end)

    task.delay(0.25, function()
        for i, lt in ipairs(titleLetters) do
            task.delay((i - 1) * 0.03, function()
                tn(lt, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {TextTransparency = 0}):Play()
            end)
        end
    end)


    task.delay(2.0, function()
        if not introActive then return end
        for _, lt in ipairs(titleLetters) do
            tn(lt, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {TextTransparency = 1}):Play()
        end
        tn(peakTitle, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {TextTransparency = 1}):Play()
    end)
    task.delay(2.35, function()
        if not introActive then return end

        giant2.TextSize = 20
        giant2.TextTransparency = 1
        tn(giant2, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextTransparency = 0}):Play()
        tn(giant2, 0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {TextSize = 180}):Play()
        task.delay(0.55, function()
            if not introActive then return end
            tn(giant2, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, {TextSize = 160}):Play()
        end)
    end)


    task.delay(3.1, function()
        if not introActive then return end
        tn(giant2, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {TextTransparency = 1, TextSize = 220}):Play()
        tn(bgGrad, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {BackgroundTransparency = 1}):Play()
        tn(skipBtn, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {TextTransparency = 1, BackgroundTransparency = 1}):Play()
        if introBlur then tn(introBlur, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {Size = 0}):Play() end
    end)
    task.delay(D + 0.5, function()
        if not introActive then return end
        introActive = false
        uf()
        pcall(function() if introBlur then introBlur:Destroy() end end)
        pcall(function() gui:Destroy() end)
    end)
end

task.spawn(function()
    task.wait(0.4)
    pcall(playVyzeIntro)
end)


UserInputService.InputBegan:Connect(function(input, gp)
    if keybindCaptureActive then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if tostring(Config.HideUIKey or "") ~= "" and input.KeyCode.Name:upper() == tostring(Config.HideUIKey):upper() then
        if Config.HideUI or uiMinimized then
            restoreFromMini()
        else
            showMiniOnly()
            saveConfig()
        end
    end
end)

if Config.BatAimbot and not Config.SafeMode then
    startBatAimbot()
end


-- Keep interactive controls tappable on touch devices; decorative layers never intercept input.
local function peakMakeGuiClickable(obj)
    if not obj or not obj:IsA("GuiObject") then return end
    if obj:IsA("GuiButton") then
        obj.Active = true
        obj.Selectable = true
    elseif obj:IsA("TextBox") then
        obj.Active = true
        obj.Selectable = true
    elseif obj.Name == "UIBackground" or obj.Name == "UIBackgroundDim" then
        obj.Active = false
        obj.Selectable = false
    end
end
for _, guiObject in ipairs(screenGui:GetDescendants()) do peakMakeGuiClickable(guiObject) end
screenGui.DescendantAdded:Connect(function(guiObject)
    task.defer(function() pcall(peakMakeGuiClickable, guiObject) end)
end)
