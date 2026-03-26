-- zmods v2.1 -- 2D Box ESP

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Camera           = workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer

-- State
local espEnabled          = false
local espHue              = 0
local espColor            = Color3.fromHSV(0, 1, 1)
local espBoxes            = {}
local heartbeatConn       = nil

-- Saved drag positions
local iconPos = UDim2.new(1, -84, 1, -84)
local menuPos = UDim2.new(1, -354, 1, -299)

local MENU_W = 280
local MENU_H = 240

-- Root GUI
local Gui = Instance.new("ScreenGui")
Gui.Name           = "zmodsESP"
Gui.ResetOnSpawn   = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent         = CoreGui

-- Helper: round corners
local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 8)
    c.Parent = parent
end

-- Helper: make a Frame
local function newFrame(parent, name, size, pos, bg, alpha, zi)
    local f = Instance.new("Frame")
    f.Name                   = name or "Frame"
    f.Size                   = size
    f.Position               = pos or UDim2.new(0, 0, 0, 0)
    f.BackgroundColor3       = bg or Color3.fromRGB(20, 20, 20)
    f.BackgroundTransparency = alpha or 0
    f.BorderSizePixel        = 0
    f.ZIndex                 = zi or 1
    f.Parent                 = parent
    return f
end

-- Helper: make a TextLabel
local function newLabel(parent, text, size, pos, zi)
    local l = Instance.new("TextLabel")
    l.Size                   = size
    l.Position               = pos or UDim2.new(0, 0, 0, 0)
    l.BackgroundTransparency = 1
    l.Text                   = text
    l.TextColor3             = Color3.fromRGB(255, 255, 255)
    l.Font                   = Enum.Font.GothamBold
    l.TextSize               = 14
    l.ZIndex                 = zi or 1
    l.Parent                 = parent
    return l
end

-- Helper: make a TextButton
local function newButton(parent, text, size, pos, bg, alpha, zi)
    local b = Instance.new("TextButton")
    b.Size                   = size
    b.Position               = pos or UDim2.new(0, 0, 0, 0)
    b.BackgroundColor3       = bg or Color3.fromRGB(40, 40, 40)
    b.BackgroundTransparency = alpha or 0
    b.BorderSizePixel        = 0
    b.Text                   = text
    b.TextColor3             = Color3.fromRGB(255, 255, 255)
    b.Font                   = Enum.Font.GothamBold
    b.TextSize               = 14
    b.ZIndex                 = zi or 1
    b.Parent                 = parent
    return b
end

-- Drag logic via UserInputService
local function makeDraggable(handle, target, onEnd)
    local down      = false
    local origin    = Vector2.new()
    local startUDim = UDim2.new()

    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            down      = true
            origin    = Vector2.new(inp.Position.X, inp.Position.Y)
            startUDim = target.Position
        end
    end)

    handle.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            down = false
            if onEnd then onEnd(target.Position) end
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if not down then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement
        and inp.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = Vector2.new(inp.Position.X, inp.Position.Y) - origin
        target.Position = UDim2.new(
            startUDim.X.Scale, startUDim.X.Offset + d.X,
            startUDim.Y.Scale, startUDim.Y.Offset + d.Y
        )
    end)
end

-- Launch Icon
local Icon = newFrame(Gui, "Icon",
    UDim2.new(0, 64, 0, 64), iconPos,
    Color3.fromRGB(26, 26, 26), 0.25, 10)
addCorner(Icon, UDim.new(1, 0))

newLabel(Icon, "zmods",
    UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 11)

local IconBtn = newButton(Icon, "",
    UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0),
    Color3.fromRGB(0, 0, 0), 1, 12)

makeDraggable(Icon, Icon, function(p) iconPos = p end)

-- Main Menu
local Menu = newFrame(Gui, "Menu",
    UDim2.new(0, MENU_W, 0, MENU_H), menuPos,
    Color3.fromRGB(20, 20, 20), 0.1, 20)
Menu.Visible = false
addCorner(Menu, UDim.new(0, 12))
do
    local s = Instance.new("UIStroke")
    s.Color     = Color3.fromRGB(65, 65, 65)
    s.Thickness = 1
    s.Parent    = Menu
end

-- Header
local Header = newFrame(Menu, "Header",
    UDim2.new(1, 0, 0, 42), UDim2.new(0, 0, 0, 0),
    Color3.fromRGB(36, 36, 36), 0.05, 21)
addCorner(Header, UDim.new(0, 12))

newFrame(Header, "Fill",
    UDim2.new(1, 0, 0, 12), UDim2.new(0, 0, 1, -12),
    Color3.fromRGB(36, 36, 36), 0.05, 21)

local TitleBtn = newButton(Header, "zmods",
    UDim2.new(1, -70, 1, 0), UDim2.new(0, 14, 0, 0),
    Color3.fromRGB(0, 0, 0), 1, 23)
TitleBtn.TextXAlignment = Enum.TextXAlignment.Left
TitleBtn.TextSize       = 18 -- Увеличен шрифт заголовка

local MinBtn = newButton(Header, "-",
    UDim2.new(0, 26, 0, 26), UDim2.new(1, -60, 0.5, -13),
    Color3.fromRGB(55, 55, 55), 0, 24)
addCorner(MinBtn, UDim.new(0, 6))

local CloseBtn = newButton(Header, "X",
    UDim2.new(0, 26, 0, 26), UDim2.new(1, -28, 0.5, -13),
    Color3.fromRGB(175, 38, 38), 0, 24)
addCorner(CloseBtn, UDim.new(0, 6))

makeDraggable(Header, Menu, function(p) menuPos = p end)

-- Body
local Body = newFrame(Menu, "Body",
    UDim2.new(1, 0, 1, -42), UDim2.new(0, 0, 0, 42),
    Color3.fromRGB(0, 0, 0), 1, 21)

do
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft   = UDim.new(0, 14)
    pad.PaddingRight  = UDim.new(0, 14)
    pad.PaddingTop    = UDim.new(0, 14)
    pad.PaddingBottom = UDim.new(0, 14)
    pad.Parent        = Body

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder     = Enum.SortOrder.LayoutOrder
    layout.Padding       = UDim.new(0, 10)
    layout.Parent        = Body
end

-- ESP toggle button
local ESPBtn = newButton(Body, "2D ESP (Wall)     OFF",
    UDim2.new(1, 0, 0, 48), UDim2.new(0, 0, 0, 0),
    Color3.fromRGB(30, 30, 30), 0.15, 22)
ESPBtn.TextSize    = 16 -- Увеличен шрифт кнопки
ESPBtn.LayoutOrder = 1
addCorner(ESPBtn, UDim.new(0, 8))

-- Hue slider
local SliderWrap = newFrame(Body, "SliderWrap",
    UDim2.new(1, 0, 0, 38), UDim2.new(0, 0, 0, 0),
    Color3.fromRGB(0, 0, 0), 1, 22)
SliderWrap.LayoutOrder = 2

newLabel(SliderWrap, "Color",
    UDim2.new(1, 0, 0, 14), UDim2.new(0, 0, 0, 0), 22).TextSize = 13

local Track = newFrame(SliderWrap, "Track",
    UDim2.new(1, 0, 0, 16), UDim2.new(0, 0, 0, 20),
    Color3.fromRGB(255, 255, 255), 0, 22)
addCorner(Track, UDim.new(0, 8))

do
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,    1, 1)),
        ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
        ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
        ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50, 1, 1)),
        ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
        ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
        ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,    1, 1)),
    })
    g.Parent = Track
end

local Knob = newFrame(Track, "Knob",
    UDim2.new(0, 16, 0, 16), UDim2.new(0, 0, 0, 0),
    Color3.fromRGB(255, 255, 255), 0, 24)
addCorner(Knob, UDim.new(1, 0))
do
    local s = Instance.new("UIStroke")
    s.Color     = Color3.fromRGB(40, 40, 40)
    s.Thickness = 1.5
    s.Parent    = Knob
end

-- ESP Logic
local LINE = 1.5

local function makeBox(player)
    local root = newFrame(Gui, "Box_" .. player.Name,
        UDim2.new(0, 10, 0, 10), UDim2.new(0, 0, 0, 0),
        Color3.fromRGB(0, 0, 0), 1, 5)

    local segs = {}
    for _, name in ipairs({"Top", "Bot", "Lft", "Rgt"}) do
        local seg = newFrame(root, name,
            UDim2.new(0, 1, 0, 1), UDim2.new(0, 0, 0, 0),
            espColor, 0, 6)
        segs[name] = seg
    end

    local nick = newLabel(Gui, player.DisplayName,
        UDim2.new(0, 130, 0, 18), UDim2.new(0, 0, 0, 0), 7)
    nick.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
    nick.TextStrokeTransparency = 0.4
    nick.TextSize               = 14 -- Читаемые никнеймы
    nick.TextColor3             = espColor

    return { root = root, segs = segs, nick = nick }
end

local function removeBox(player)
    local b = espBoxes[player]
    if not b then return end
    b.root:Destroy()
    b.nick:Destroy()
    espBoxes[player] = nil
end

local function clearBoxes()
    for p in pairs(espBoxes) do removeBox(p) end
end

local function screenBounds(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local origin = hrp.Position
    local camCF  = Camera.CFrame
    local right  = camCF.RightVector
    local up     = camCF.UpVector
    local hw, hh = 1.2, 3.0

    local pts = {
        origin + right * hw + up * hh,
        origin + right * -hw + up * hh,
        origin + right * hw + up * -hh,
        origin + right * -hw + up * -hh,
    }

    local x0, y0 =  math.huge,  math.huge
    local x1, y1 = -math.huge, -math.huge
    local vis = false

    for _, pt in ipairs(pts) do
        local sp, on = Camera:WorldToViewportPoint(pt)
        if on then vis = true end
        if sp.X < x0 then x0 = sp.X end
        if sp.X > x1 then x1 = sp.X end
        if sp.Y < y0 then y0 = sp.Y end
        if sp.Y > y1 then y1 = sp.Y end
    end

    local _, rootVis = Camera:WorldToViewportPoint(origin)
    if not rootVis or not vis then return nil end

    local w, h = x1 - x0, y1 - y0
    if w < 2 or h < 2 then return nil end
    return x0, y0, w, h
end

local function drawBox(b, x, y, w, h, col)
    local s = b.segs
    b.root.Position = UDim2.new(0, x, 0, y)
    b.root.Size     = UDim2.new(0, w, 0, h)
    b.root.Visible  = true

    for _, seg in pairs(s) do seg.BackgroundColor3 = col end

    s.Top.Size     = UDim2.new(1, 0, 0, LINE)
    s.Top.Position = UDim2.new(0, 0, 0, 0)

    s.Bot.Size     = UDim2.new(1, 0, 0, LINE)
    s.Bot.Position = UDim2.new(0, 0, 1, -LINE)

    s.Lft.Size     = UDim2.new(0, LINE, 1, 0)
    s.Lft.Position = UDim2.new(0, 0, 0, 0)

    s.Rgt.Size     = UDim2.new(0, LINE, 1, 0)
    s.Rgt.Position = UDim2.new(1, -LINE, 0, 0)

    local nw = b.nick.Size.X.Offset
    b.nick.Position   = UDim2.new(0, x + w * 0.5 - nw * 0.5, 0, y - 20)
    b.nick.TextColor3 = col
    b.nick.Visible    = true
end

local function startESP()
    if heartbeatConn then return end
    heartbeatConn = RunService.Heartbeat:Connect(function()
        if not espEnabled then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            local char = plr.Character
            if not char then removeBox(plr) continue end
            local x, y, w, h = screenBounds(char)
            if not x then
                local b = espBoxes[plr]
                if b then
                    b.root.Visible = false
                    b.nick.Visible = false
                end
                continue
            end
            if not espBoxes[plr] then espBoxes[plr] = makeBox(plr) end
            drawBox(espBoxes[plr], x, y, w, h, espColor)
        end
        for plr in pairs(espBoxes) do
            if not plr or not plr.Parent then removeBox(plr) end
        end
    end)
end

local function stopESP()
    if heartbeatConn then
        heartbeatConn:Disconnect()
        heartbeatConn = nil
    end
    clearBoxes()
end

Players.PlayerRemoving:Connect(removeBox)

-- UI Wiring

local function showMenu()
    Icon.Visible  = false
    Menu.Position = menuPos
    Menu.Visible  = true
end

local function showIcon()
    menuPos       = Menu.Position
    Menu.Visible  = false
    Icon.Position = iconPos
    Icon.Visible  = true
end

IconBtn.MouseButton1Click:Connect(showMenu)
TitleBtn.MouseButton1Click:Connect(showIcon)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Body.Visible  = false
        Menu.Size     = UDim2.new(0, MENU_W, 0, 42)
        MinBtn.Text   = "+"
    else
        Body.Visible  = true
        Menu.Size     = UDim2.new(0, MENU_W, 0, MENU_H)
        MinBtn.Text   = "-"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    stopESP()
    Gui:Destroy()
end)

ESPBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ESPBtn.Text                   = "2D ESP (Wall)     ON"
        ESPBtn.BackgroundTransparency = 0.0
        ESPBtn.BackgroundColor3       = Color3.fromRGB(55, 55, 55)
        startESP()
    else
        ESPBtn.Text                   = "2D ESP (Wall)     OFF"
        ESPBtn.BackgroundTransparency = 0.15
        ESPBtn.BackgroundColor3       = Color3.fromRGB(30, 30, 30)
        clearBoxes()
    end
end)

-- HSV slider
local sliding = false

local function applyHue(hue)
    espHue   = math.clamp(hue, 0, 1)
    espColor = Color3.fromHSV(espHue, 1, 1)
    local tw = Track.AbsoluteSize.X
    local kw = Knob.AbsoluteSize.X
    Knob.Position = UDim2.new(0, math.clamp(espHue * (tw - kw), 0, tw - kw), 0, 0)
    for _, b in pairs(espBoxes) do
        for _, seg in pairs(b.segs) do seg.BackgroundColor3 = espColor end
        b.nick.TextColor3 = espColor
    end
end

local function hueFromX(sx)
    local tx = Track.AbsolutePosition.X
    local tw = Track.AbsoluteSize.X
    local kw = Knob.AbsoluteSize.X
    return math.clamp((sx - tx) / math.max(tw - kw, 1), 0, 1)
end

Track.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        sliding = true
        applyHue(hueFromX(inp.Position.X))
    end
end)

Knob.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        sliding = true
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        sliding = false
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if not sliding then return end
    if inp.UserInputType == Enum.UserInputType.MouseMovement
    or inp.UserInputType == Enum.UserInputType.Touch then
        applyHue(hueFromX(inp.Position.X))
    end
end)
