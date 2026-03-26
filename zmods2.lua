-- zmods v3.0 Final
local P = game:GetService("Players")
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local Cam = workspace.CurrentCamera
local LP = P.LocalPlayer

local enabled = false
local boxes = {}
local col = Color3.new(1, 1, 1)

local Gui = Instance.new("ScreenGui", CG)
Gui.Name = "zmodsESP"
Gui.IgnoreGuiInset = true

local Icon = Instance.new("TextButton", Gui)
Icon.Size = UDim2.new(0, 50, 0, 50)
Icon.Position = UDim2.new(1, -70, 0, 20)
Icon.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Icon.Text = "z"
Icon.TextColor3 = Color3.new(1, 1, 1)
Icon.TextSize = 20
Icon.Font = Enum.Font.GothamBold
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1, 0)

local Menu = Instance.new("Frame", Gui)
Menu.Size = UDim2.new(0, 200, 0, 100)
Menu.Position = UDim2.new(1, -250, 0, 20)
Menu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Menu.Visible = false
Instance.new("UICorner", Menu).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextButton", Menu)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "zmods (Close)"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

local ESPBtn = Instance.new("TextButton", Menu)
ESPBtn.Position = UDim2.new(0, 10, 0, 40)
ESPBtn.Size = UDim2.new(1, -20, 0, 40)
ESPBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ESPBtn.Text = "ESP: OFF"
ESPBtn.TextColor3 = Color3.new(1, 1, 1)
ESPBtn.Font = Enum.Font.GothamBold
ESPBtn.TextSize = 16
Instance.new("UICorner", ESPBtn).CornerRadius = UDim.new(0, 8)

Icon.MouseButton1Click:Connect(function()
    Icon.Visible = false
    Menu.Visible = true
end)

Title.MouseButton1Click:Connect(function()
    Menu.Visible = false
    Icon.Visible = true
end)

ESPBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        ESPBtn.Text = "ESP: ON"
        ESPBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    else
        ESPBtn.Text = "ESP: OFF"
        ESPBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        for _, b in pairs(boxes) do b.f:Destroy() b.l:Destroy() end
        table.clear(boxes)
    end
end)

local function drag(obj)
    local down, origin, start = false, Vector2.new(), UDim2.new()
    obj.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            down, origin, start = true, Vector2.new(i.Position.X, i.Position.Y), obj.Position
        end
    end)
    obj.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then down = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if down and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = Vector2.new(i.Position.X, i.Position.Y) - origin
            obj.Position = UDim2.new(start.X.Scale, start.X.Offset + d.X, start.Y.Scale, start.Y.Offset + d.Y)
        end
    end)
end

drag(Icon)
drag(Menu)

local function getBounds(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local p, on = Cam:WorldToViewportPoint(hrp.Position)
    if not on then return end
    local t = Cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
    local b = Cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
    local h = math.abs(t.Y - b.Y)
    return p.X, p.Y, h * 0.5, h
end

RS.RenderStepped:Connect(function()
    if not enabled then return end
    for _, p in pairs(P:GetPlayers()) do
        if p == LP or not p.Character then continue end
        local x, y, w, h = getBounds(p.Character)
        if not x then
            if boxes[p] then boxes[p].f.Visible, boxes[p].l.Visible = false, false end
            continue
        end
        if not boxes[p] then
            local f = Instance.new("Frame", Gui)
            f.BackgroundTransparency, f.BorderSizePixel = 1, 0
            local s = Instance.new("UIStroke", f)
            s.Color, s.Thickness = col, 1.5
            local l = Instance.new("TextLabel", Gui)
            l.BackgroundTransparency, l.TextColor3, l.Font, l.TextSize = 1, col, Enum.Font.GothamBold, 14
            boxes[p] = {f = f, l = l}
        end
        boxes[p].f.Visible, boxes[p].f.Position, boxes[p].f.Size = true, UDim2.new(0, x - w * 0.5, 0, y - h * 0.5), UDim2.new(0, w, 0, h)
        boxes[p].l.Visible, boxes[p].l.Position, boxes[p].l.Size, boxes[p].l.Text = true, UDim2.new(0, x - 50, 0, y - h * 0.5 - 20), UDim2.new(0, 100, 0, 20), p.DisplayName
    end
end)
