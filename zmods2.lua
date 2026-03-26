-- zmods v2.1 -- 2D Box ESP
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Camera           = workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer

local espEnabled          = false
local espHue              = 0
local espColor            = Color3.fromHSV(0, 1, 1)
local espBoxes            = {}
local heartbeatConn       = nil
local iconPos = UDim2.new(1, -84, 1, -84)
local menuPos = UDim2.new(1, -354, 1, -299)
local MENU_W, MENU_H = 280, 240

local Gui = Instance.new("ScreenGui")
Gui.Name, Gui.ResetOnSpawn, Gui.IgnoreGuiInset = "zmodsESP", false, true
Gui.Parent = CoreGui

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 8)
    c.Parent = parent
end

local function newFrame(parent, name, size, pos, bg, alpha, zi)
    local f = Instance.new("Frame")
    f.Name, f.Size, f.Position = name or "Frame", size, pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3, f.BackgroundTransparency, f.BorderSizePixel, f.ZIndex = bg or Color3.fromRGB(20,20,20), alpha or 0, 0, zi or 1
    f.Parent = parent
    return f
end

local function newLabel(parent, text, size, pos, zi)
    local l = Instance.new("TextLabel")
    l.Size, l.Position, l.BackgroundTransparency, l.ZIndex = size, pos or UDim2.new(0,0,0,0), 1, zi or 1
    l.Text, l.TextColor3, l.Font, l.TextSize = text, Color3.fromRGB(255,255,255), Enum.Font.GothamBold, 14
    l.Parent = parent
    return l
end

local function newButton(parent, text, size, pos, bg, alpha, zi)
    local b = Instance.new("TextButton")
    b.Size, b.Position, b.BackgroundColor3, b.BackgroundTransparency = size, pos or UDim2.new(0,0,0,0), bg or Color3.fromRGB(40,40,40), alpha or 0
    b.BorderSizePixel, b.Text, b.TextColor3, b.Font, b.TextSize, b.ZIndex = 0, text, Color3.fromRGB(255,255,255), Enum.Font.GothamBold, 14, zi or 1
    b.Parent = parent
    return b
end

local function makeDraggable(handle, target, onEnd)
    local down, origin, startUDim = false, Vector2.new(), UDim2.new()
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            down, origin, startUDim = true, Vector2.new(inp.Position.X, inp.Position.Y), target.Position
        end
    end)
    handle.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            down = false
            if onEnd then onEnd(target.Position) end
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not down then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement and inp.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = Vector2.new(inp.Position.X, inp.Position.Y) - origin
        target.Position = UDim2.new(startUDim.X.Scale, startUDim.X.Offset + d.X, startUDim.Y.Scale, startUDim.Y.Offset + d.Y)
    end)
end

local Icon = newFrame(Gui, "Icon", UDim2.new(0, 64, 0, 64), iconPos, Color3.fromRGB(26,26,26), 0.25, 10)
addCorner(Icon, UDim.new(1, 0))
newLabel(Icon, "zmods", UDim2.new(1, 0, 1, 0), UDim2.new(0,0,0,0), 11)
local IconBtn = newButton(Icon, "", UDim2.new(1, 0, 1, 0), UDim2.new(0,0,0,0), Color3.fromRGB(0,0,0), 1, 12)
makeDraggable(Icon, Icon, function(p) iconPos = p end)

local Menu = newFrame(Gui, "Menu", UDim2.new(0, MENU_W, 0, MENU_H), menuPos, Color3.fromRGB(20,20,20), 0.1, 20)
Menu.Visible = false
addCorner(Menu, UDim.new(0, 12))
local Header = newFrame(Menu, "Header", UDim2.new(1, 0, 0, 42), UDim2.new(0,0,0,0), Color3.fromRGB(36,36,36), 0.05, 21)
addCorner(Header, UDim.new(0, 12))
newFrame(Header, "Fill", UDim2.new(1, 0, 0, 12), UDim2.new(0, 0, 1, -12), Color3.fromRGB(36, 36, 36), 0.05, 21)
local TitleBtn = newButton(Header, "zmods", UDim2.new(1, -70, 1, 0), UDim2.new(0, 14, 0, 0), Color3.fromRGB(0,0,0), 1, 23)
TitleBtn.TextXAlignment, TitleBtn.TextSize = Enum.TextXAlignment.Left, 18
local MinBtn = newButton(Header, "-", UDim2.new(0, 26, 0, 26), UDim2.new(1, -60, 0.5, -13), Color3.fromRGB(55,55,55), 0, 24)
addCorner(MinBtn, UDim.new(0, 6))
local CloseBtn = newButton(Header, "X", UDim2.new(0, 26, 0, 26), UDim2.new(1, -28, 0.5, -13), Color3.fromRGB(175,38,38), 0, 24)
addCorner(CloseBtn, UDim.new(0, 6))
makeDraggable(Header, Menu, function(p) menuPos = p end)local Body = newFrame(Menu, "Body", UDim2.new(1, 0, 1, -42), UDim2.new(0, 0, 0, 42), Color3.fromRGB(0,0,0), 1, 21)
local pad = Instance.new("UIPadding", Body)
pad.PaddingLeft, pad.PaddingRight, pad.PaddingTop, pad.PaddingBottom = UDim.new(0,14), UDim.new(0,14), UDim.new(0,14), UDim.new(0,14)
local layout = Instance.new("UIListLayout", Body)
layout.SortOrder, layout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 10)

local ESPBtn = newButton(Body, "2D ESP (Wall)     OFF", UDim2.new(1, 0, 0, 48), UDim2.new(0,0,0,0), Color3.fromRGB(30,30,30), 0.15, 22)
ESPBtn.TextSize, ESPBtn.LayoutOrder = 16, 1
addCorner(ESPBtn, UDim.new(0, 8))

local SliderWrap = newFrame(Body, "SliderWrap", UDim2.new(1, 0, 0, 38), UDim2.new(0,0,0,0), Color3.fromRGB(0,0,0), 1, 22)
SliderWrap.LayoutOrder = 2
newLabel(SliderWrap, "Color", UDim2.new(1, 0, 0, 14), UDim2.new(0,0,0,0), 22).TextSize = 13
local Track = newFrame(SliderWrap, "Track", UDim2.new(1, 0, 0, 16), UDim2.new(0, 0, 0, 20), Color3.fromRGB(255,255,255), 0, 22)
addCorner(Track, UDim.new(0, 8))
local g = Instance.new("UIGradient", Track)
g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(0,1,1)), ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5,1,1)), ColorSequenceKeypoint.new(1, Color3.fromHSV(1,1,1))})
local Knob = newFrame(Track, "Knob", UDim2.new(0, 16, 0, 16), UDim2.new(0,0,0,0), Color3.fromRGB(255,255,255), 0, 24)
addCorner(Knob, UDim.new(1, 0))

local function makeBox(player)
    local root = newFrame(Gui, "Box_"..player.Name, UDim2.new(0,10,0,10), UDim2.new(0,0,0,0), Color3.fromRGB(0,0,0), 1, 5)
    local segs = {}
    for _, n in ipairs({"Top", "Bot", "Lft", "Rgt"}) do segs[n] = newFrame(root, n, UDim2.new(0,1,0,1), UDim2.new(0,0,0,0), espColor, 0, 6) end
    local nick = newLabel(Gui, player.DisplayName, UDim2.new(0,130,0,18), UDim2.new(0,0,0,0), 7)
    nick.TextSize, nick.TextColor3 = 14, espColor
    return { root = root, segs = segs, nick = nick }
end

local function removeBox(player)
    local b = espBoxes[player]
    if b then b.root:Destroy() b.nick:Destroy() espBoxes[player] = nil end
end

local function screenBounds(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local sp, on = Camera:WorldToViewportPoint(hrp.Position)
    if not on then return nil end
    local h = (Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0)).Y)
    return sp.X - math.abs(h)/4, sp.Y - math.abs(h)/2, math.abs(h)/2, math.abs(h)
end

local function drawBox(b, x, y, w, h, col)
    b.root.Position, b.root.Size, b.root.Visible = UDim2.new(0, x, 0, y), UDim2.new(0, w, 0, h), true
    for _, s in pairs(b.segs) do s.BackgroundColor3 = col end
    b.segs.Top.Size, b.segs.Top.Position = UDim2.new(1,0,0,1.5), UDim2.new(0,0,0,0)
    b.segs.Bot.Size, b.segs.Bot.Position = UDim2.new(1,0,0,1.5), UDim2.new(0,0,1,-1.5)
    b.segs.Lft.Size, b.segs.Lft.Position = UDim2.new(0,1.5,1,0), UDim2.new(0,0,0,0)
    b.segs.Rgt.Size, b.segs.Rgt.Position = UDim2.new(0,1.5,1,0), UDim2.new(1,-1.5,0,0)
    b.nick.Position, b.nick.TextColor3, b.nick.Visible = UDim2.new(0, x+w/2-65, 0, y-20), col, true
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
            if not x then if espBoxes[plr] then espBoxes[plr].root.Visible, espBoxes[plr].nick.Visible = false, false end continue end
            if not espBoxes[plr] then espBoxes[plr] = makeBox(plr) end
            drawBox(espBoxes[plr], x, y, w, h, espColor)
        end
    end)
end

IconBtn.MouseButton1Click:Connect(function() Icon.Visible, Menu.Visible = false, true end)
TitleBtn.MouseButton1Click:Connect(function() Menu.Visible, Icon.Visible = false, true end)
CloseBtn.MouseButton1Click:Connect(function() stopESP() Gui:Destroy() end)
ESPBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    ESPBtn.Text = espEnabled and "2D ESP (Wall)     ON" or "2D ESP (Wall)     OFF"
    if espEnabled then startESP() else if heartbeatConn then heartbeatConn:Disconnect() heartbeatConn = nil end for p in pairs(espBoxes) do removeBox(p) end end
end)

local sliding = false
local function applyHue(hue)
    espHue, espColor = math.clamp(hue, 0, 1), Color3.fromHSV(math.clamp(hue, 0, 1), 1, 1)
    Knob.Position = UDim2.new(0, espHue * (Track.AbsoluteSize.X - 16), 0, 0)
end
Track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = true applyHue((i.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end end)
UserInputService.InputChanged:Connect(function(i) if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then applyHue((i.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X) end end)
