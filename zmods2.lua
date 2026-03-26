--[[
    zmods - 2D Box ESP Script
    Mobile-compatible (Delta Executor)
    FinTech-style UI | Luau
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local ScreenGui

local espEnabled = false
local espColor = Color3.fromHSV(0.55, 1, 1)
local currentHue = 0.55

local espBoxes = {}

local function safeDestroy(obj)
    if obj and obj.Parent then
        obj:Destroy()
    end
end

--[[
    Attempt to parent to CoreGui, fallback to PlayerGui
]]
local function getGui()
    local success, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)
    if success and coreGui then
        return coreGui
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local GuiParent = getGui()

ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZModsGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = GuiParent

--[[
    ============================================================
    DRAWING LAYER - 2D ESP Boxes drawn via Frame objects
    ============================================================
]]
local espCanvas = Instance.new("Frame")
espCanvas.Name = "ESPCanvas"
espCanvas.Size = UDim2.new(1, 0, 1, 0)
espCanvas.Position = UDim2.new(0, 0, 0, 0)
espCanvas.BackgroundTransparency = 1
espCanvas.ZIndex = 1
espCanvas.Parent = ScreenGui

--[[
    ============================================================
    THEME CONSTANTS
    ============================================================
]]
local BG_COLOR = Color3.fromRGB(20, 20, 20)
local BG_TRANS = 0.12
local BORDER_COLOR = Color3.fromRGB(60, 60, 60)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local ACCENT_COLOR = Color3.fromRGB(80, 80, 80)
local CLOSE_RED = Color3.fromRGB(200, 50, 50)

--[[
    ============================================================
    UTILITY: Make a frame draggable by a handle
    ============================================================
]]
local function makeDraggable(frame, handle)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

--[[
    ============================================================
    LAUNCH ICON (Circular Button)
    ============================================================
]]
local launchIcon = Instance.new("Frame")
launchIcon.Name = "LaunchIcon"
launchIcon.Size = UDim2.new(0, 72, 0, 72)
launchIcon.Position = UDim2.new(0, 24, 0.5, -36)
launchIcon.BackgroundColor3 = BG_COLOR
launchIcon.BackgroundTransparency = BG_TRANS
launchIcon.BorderSizePixel = 0
launchIcon.ZIndex = 10
launchIcon.Parent = ScreenGui

local launchCorner = Instance.new("UICorner")
launchCorner.CornerRadius = UDim.new(1, 0)
launchCorner.Parent = launchIcon

local launchStroke = Instance.new("UIStroke")
launchStroke.Color = BORDER_COLOR
launchStroke.Thickness = 1.5
launchStroke.Parent = launchIcon

local launchLabel = Instance.new("TextLabel")
launchLabel.Size = UDim2.new(1, 0, 1, 0)
launchLabel.Position = UDim2.new(0, 0, 0, 0)
launchLabel.BackgroundTransparency = 1
launchLabel.Text = "zmods"
launchLabel.TextColor3 = TEXT_COLOR
launchLabel.TextScaled = true
launchLabel.Font = Enum.Font.SourceSansBold
launchLabel.ZIndex = 11
launchLabel.Parent = launchIcon

local launchButton = Instance.new("TextButton")
launchButton.Size = UDim2.new(1, 0, 1, 0)
launchButton.Position = UDim2.new(0, 0, 0, 0)
launchButton.BackgroundTransparency = 1
launchButton.Text = ""
launchButton.ZIndex = 12
launchButton.Parent = launchIcon

makeDraggable(launchIcon, launchButton)

--[[
    ============================================================
    MAIN MENU FRAME
    ============================================================
]]
local mainMenu = Instance.new("Frame")
mainMenu.Name = "MainMenu"
mainMenu.Size = UDim2.new(0, 280, 0, 360)
mainMenu.Position = UDim2.new(0.5, -140, 0.5, -180)
mainMenu.BackgroundColor3 = BG_COLOR
mainMenu.BackgroundTransparency = BG_TRANS
mainMenu.BorderSizePixel = 0
mainMenu.Visible = false
mainMenu.ZIndex = 20
mainMenu.Parent = ScreenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 10)
menuCorner.Parent = mainMenu

local menuStroke = Instance.new("UIStroke")
menuStroke.Color = BORDER_COLOR
menuStroke.Thickness = 1.5
menuStroke.Parent = mainMenu

--[[
    Header bar (draggable)
]]
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 44)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
header.BackgroundTransparency = 0.05
header.BorderSizePixel = 0
header.ZIndex = 21
header.Parent = mainMenu

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

-- bottom patch to square off header bottom corners
local headerPatch = Instance.new("Frame")
headerPatch.Size = UDim2.new(1, 0, 0, 10)
headerPatch.Position = UDim2.new(0, 0, 1, -10)
headerPatch.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
headerPatch.BackgroundTransparency = 0.05
headerPatch.BorderSizePixel = 0
headerPatch.ZIndex = 21
headerPatch.Parent = header

local headerTitle = Instance.new("TextButton")
headerTitle.Size = UDim2.new(1, -90, 1, 0)
headerTitle.Position = UDim2.new(0, 12, 0, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = "zmods"
headerTitle.TextColor3 = TEXT_COLOR
headerTitle.Font = Enum.Font.SourceSansBold
headerTitle.TextSize = 16
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.ZIndex = 25
headerTitle.Parent = header

makeDraggable(mainMenu, headerTitle)

--[[
    Minimize button "-"
]]
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 32, 0, 28)
minimizeBtn.Position = UDim2.new(1, -72, 0.5, -14)
minimizeBtn.BackgroundColor3 = ACCENT_COLOR
minimizeBtn.BackgroundTransparency = 0.5
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = TEXT_COLOR
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.TextSize = 18
minimizeBtn.BorderSizePixel = 0
minimizeBtn.ZIndex = 25
minimizeBtn.Parent = header

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimizeBtn

--[[
    Close button "X"
]]
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 28)
closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
closeBtn.BackgroundColor3 = CLOSE_RED
closeBtn.BackgroundTransparency = 0.2
closeBtn.Text = "X"
closeBtn.TextColor3 = TEXT_COLOR
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 25
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

--[[
    Menu body (hidden when minimized)
]]
local menuBody = Instance.new("Frame")
menuBody.Name = "MenuBody"
menuBody.Size = UDim2.new(1, 0, 1, -44)
menuBody.Position = UDim2.new(0, 0, 0, 44)
menuBody.BackgroundTransparency = 1
menuBody.BorderSizePixel = 0
menuBody.ZIndex = 22
menuBody.Parent = mainMenu

local bodyLayout = Instance.new("UIListLayout")
bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
bodyLayout.Padding = UDim.new(0, 12)
bodyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
bodyLayout.Parent = menuBody

local bodyPadding = Instance.new("UIPadding")
bodyPadding.PaddingTop = UDim.new(0, 16)
bodyPadding.PaddingLeft = UDim.new(0, 16)
bodyPadding.PaddingRight = UDim.new(0, 16)
bodyPadding.Parent = menuBody

--[[
    ============================================================
    ESP TOGGLE BUTTON
    ============================================================
]]
local espToggleBtn = Instance.new("TextButton")
espToggleBtn.Name = "ESPToggle"
espToggleBtn.Size = UDim2.new(1, 0, 0, 48)
espToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
espToggleBtn.BackgroundTransparency = 0.1
espToggleBtn.Text = "ESP  OFF"
espToggleBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
espToggleBtn.Font = Enum.Font.SourceSansBold
espToggleBtn.TextSize = 15
espToggleBtn.BorderSizePixel = 0
espToggleBtn.LayoutOrder = 1
espToggleBtn.ZIndex = 23
espToggleBtn.Parent = menuBody

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = espToggleBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = BORDER_COLOR
toggleStroke.Thickness = 1
toggleStroke.Parent = espToggleBtn

--[[
    ============================================================
    HSV COLOR SLIDER SECTION
    ============================================================
]]
local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(1, 0, 0, 18)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "BOX COLOR"
sliderLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
sliderLabel.Font = Enum.Font.SourceSansBold
sliderLabel.TextSize = 11
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
sliderLabel.LayoutOrder = 2
sliderLabel.ZIndex = 23
sliderLabel.Parent = menuBody

local sliderTrack = Instance.new("Frame")
sliderTrack.Name = "SliderTrack"
sliderTrack.Size = UDim2.new(1, 0, 0, 18)
sliderTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
sliderTrack.BackgroundTransparency = 0.1
sliderTrack.BorderSizePixel = 0
sliderTrack.LayoutOrder = 3
sliderTrack.ZIndex = 23
sliderTrack.Parent = menuBody

local sliderTrackCorner = Instance.new("UICorner")
sliderTrackCorner.CornerRadius = UDim.new(0, 9)
sliderTrackCorner.Parent = sliderTrack

--[[
    Rainbow gradient for hue slider
]]
local sliderGradient = Instance.new("UIGradient")
sliderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,    1, 1)),
    ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
    ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
    ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5,  1, 1)),
    ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
    ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
    ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,    1, 1)),
})
sliderGradient.Parent = sliderTrack

--[[
    Slider thumb (handle)
]]
local sliderThumb = Instance.new("Frame")
sliderThumb.Name = "Thumb"
sliderThumb.Size = UDim2.new(0, 18, 0, 18)
sliderThumb.AnchorPoint = Vector2.new(0.5, 0.5)
sliderThumb.Position = UDim2.new(currentHue, 0, 0.5, 0)
sliderThumb.BackgroundColor3 = TEXT_COLOR
sliderThumb.BorderSizePixel = 0
sliderThumb.ZIndex = 25
sliderThumb.Parent = sliderTrack

local thumbCorner = Instance.new("UICorner")
thumbCorner.CornerRadius = UDim.new(1, 0)
thumbCorner.Parent = sliderThumb

local thumbStroke = Instance.new("UIStroke")
thumbStroke.Color = Color3.fromRGB(0, 0, 0)
thumbStroke.Thickness = 2
thumbStroke.Parent = sliderThumb

--[[
    Color preview swatch
]]
local colorPreview = Instance.new("Frame")
colorPreview.Name = "ColorPreview"
colorPreview.Size = UDim2.new(1, 0, 0, 24)
colorPreview.BackgroundColor3 = espColor
colorPreview.BorderSizePixel = 0
colorPreview.LayoutOrder = 4
colorPreview.ZIndex = 23
colorPreview.Parent = menuBody

local previewCorner = Instance.new("UICorner")
previewCorner.CornerRadius = UDim.new(0, 6)
previewCorner.Parent = colorPreview

local previewStroke = Instance.new("UIStroke")
previewStroke.Color = BORDER_COLOR
previewStroke.Thickness = 1
previewStroke.Parent = colorPreview

--[[
    ============================================================
    SEPARATOR LINE
    ============================================================
]]
local separator = Instance.new("Frame")
separator.Size = UDim2.new(1, 0, 0, 1)
separator.BackgroundColor3 = BORDER_COLOR
separator.BackgroundTransparency = 0.5
separator.BorderSizePixel = 0
separator.LayoutOrder = 5
separator.ZIndex = 23
separator.Parent = menuBody

--[[
    Status label
]]
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Players detected: 0"
statusLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.LayoutOrder = 6
statusLabel.ZIndex = 23
statusLabel.Parent = menuBody

--[[
    ============================================================
    SLIDER INPUT LOGIC (Mobile + Mouse)
    ============================================================
]]
local sliderDragging = false

local function updateSlider(inputPos)
    local trackAbsPos = sliderTrack.AbsolutePosition
    local trackAbsSize = sliderTrack.AbsoluteSize
    local relX = (inputPos.X - trackAbsPos.X) * (trackAbsSize.X ^ -1)
    relX = math.clamp(relX, 0, 1)
    currentHue = relX
    espColor = Color3.fromHSV(currentHue, 1, 1)
    sliderThumb.Position = UDim2.new(relX, 0, 0.5, 0)
    colorPreview.BackgroundColor3 = espColor
end

sliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = true
        updateSlider(input.Position)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement) then
        updateSlider(input.Position)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = false
    end
end)

--[[
    ============================================================
    ESP BOX DRAWING HELPERS
    ============================================================
]]
local function createBox(player)
    local data = {}

    local function makeEdge(name)
        local line = Instance.new("Frame")
        line.Name = name
        line.BackgroundColor3 = espColor
        line.BackgroundTransparency = 0
        line.BorderSizePixel = 0
        line.ZIndex = 2
        line.Parent = espCanvas
        return line
    end

    data.top    = makeEdge("Top")
    data.bottom = makeEdge("Bottom")
    data.left   = makeEdge("Left")
    data.right  = makeEdge("Right")

    local nameTag = Instance.new("TextLabel")
    nameTag.BackgroundTransparency = 1
    nameTag.TextColor3 = espColor
    nameTag.Font = Enum.Font.SourceSansBold
    nameTag.TextSize = 12
    nameTag.Text = player.DisplayName
    nameTag.ZIndex = 3
    nameTag.Parent = espCanvas
    data.nameTag = nameTag

    data.player = player
    data.visible = false

    return data
end

local function setEdge(frame, x, y, w, h)
    frame.Position = UDim2.new(0, x, 0, y)
    frame.Size     = UDim2.new(0, w, 0, h)
end

local THICKNESS = 1.5

local function updateBox(data, x, y, w, h, color, name)
    data.top.BackgroundColor3    = color
    data.bottom.BackgroundColor3 = color
    data.left.BackgroundColor3   = color
    data.right.BackgroundColor3  = color
    data.nameTag.TextColor3      = color
    data.nameTag.Text            = name

    setEdge(data.top,    x,     y,     w, THICKNESS)
    setEdge(data.bottom, x,     y + h, w, THICKNESS)
    setEdge(data.left,   x,     y,     THICKNESS, h)
    setEdge(data.right,  x + w, y,     THICKNESS, h)

    data.nameTag.Size     = UDim2.new(0, w, 0, 16)
    data.nameTag.Position = UDim2.new(0, x, 0, y - 18)
end

local function showBox(data, visible)
    data.top.Visible     = visible
    data.bottom.Visible  = visible
    data.left.Visible    = visible
    data.right.Visible   = visible
    data.nameTag.Visible = visible
    data.visible         = visible
end

local function removeBox(data)
    safeDestroy(data.top)
    safeDestroy(data.bottom)
    safeDestroy(data.left)
    safeDestroy(data.right)
    safeDestroy(data.nameTag)
end

--[[
    ============================================================
    GET PLAYER'S 2D BOUNDING BOX
    Projects all 8 corners of each body part through the camera.
    Stays consistent regardless of player rotation.
    ============================================================
]]
local HALF = 0.5

local function getScreenBoundingBox(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then
        return nil
    end

    local parts = {}
    for _, v in ipairs(character:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            parts[#parts + 1] = v
        end
    end
    if rootPart then
        parts[#parts + 1] = rootPart
    end

    if #parts == 0 then return nil end

    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local anyOnScreen = false

    for _, part in ipairs(parts) do
        local sx = part.Size.X * HALF
        local sy = part.Size.Y * HALF
        local sz = part.Size.Z * HALF
        local cf = part.CFrame

        local corners = {
            cf * CFrame.new( sx,  sy,  sz),
            cf * CFrame.new(-sx,  sy,  sz),
            cf * CFrame.new( sx, -sy,  sz),
            cf * CFrame.new(-sx, -sy,  sz),
            cf * CFrame.new( sx,  sy, -sz),
            cf * CFrame.new(-sx,  sy, -sz),
            cf * CFrame.new( sx, -sy, -sz),
            cf * CFrame.new(-sx, -sy, -sz),
        }

        for _, cornerCF in ipairs(corners) do
            local screenPos, onScreen = Camera:WorldToViewportPoint(cornerCF.Position)
            if onScreen then
                anyOnScreen = true
                if screenPos.X < minX then minX = screenPos.X end
                if screenPos.X > maxX then maxX = screenPos.X end
                if screenPos.Y < minY then minY = screenPos.Y end
                if screenPos.Y > maxY then maxY = screenPos.Y end
            end
        end
    end

    if not anyOnScreen then return nil end

    return minX, minY, maxX - minX, maxY - minY
end

--[[
    ============================================================
    PLAYER MANAGEMENT
    ============================================================
]]
local function onPlayerAdded(player)
    if player == LocalPlayer then return end

    local data = createBox(player)
    espBoxes[player] = data
    showBox(data, false)

    player.CharacterRemoving:Connect(function()
        showBox(data, false)
    end)

    player.AncestryChanged:Connect(function(_, parent)
        if not parent then
            removeBox(data)
            espBoxes[player] = nil
        end
    end)
end

local function onPlayerRemoving(player)
    local data = espBoxes[player]
    if data then
        removeBox(data)
        espBoxes[player] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        onPlayerAdded(player)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

--[[
    ============================================================
    ESP RENDER LOOP
    ============================================================
]]
local espConnection = nil

local function startESP()
    if espConnection then return end
    espConnection = RunService.Heartbeat:Connect(function()
        local count = 0
        for player, data in pairs(espBoxes) do
            local character = player.Character
            if character and espEnabled then
                local x, y, w, h = getScreenBoundingBox(character)
                if x then
                    updateBox(data, x, y, w, h, espColor, player.DisplayName)
                    showBox(data, true)
                    count = count + 1
                else
                    showBox(data, false)
                end
            else
                showBox(data, false)
            end
        end
        if statusLabel and statusLabel.Parent then
            statusLabel.Text = "Players detected: " .. count
        end
    end)
end

local function stopESP()
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
    for _, data in pairs(espBoxes) do
        showBox(data, false)
    end
end

startESP()

--[[
    ============================================================
    TOGGLE BUTTON LOGIC
    ============================================================
]]
espToggleBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        espToggleBtn.Text = "ESP  ON"
        espToggleBtn.TextColor3 = Color3.fromRGB(100, 220, 140)
        espToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 50, 30)
    else
        espToggleBtn.Text = "ESP  OFF"
        espToggleBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        espToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        for _, data in pairs(espBoxes) do
            showBox(data, false)
        end
    end
end)

--[[
    ============================================================
    LAUNCH ICON -> MAIN MENU TOGGLE
    ============================================================
]]
launchButton.MouseButton1Click:Connect(function()
    launchIcon.Visible = false
    mainMenu.Visible   = true
end)

--[[
    ============================================================
    HEADER TITLE -> BACK TO ICON
    ============================================================
]]
headerTitle.MouseButton1Click:Connect(function()
    mainMenu.Visible   = false
    launchIcon.Visible = true
end)

--[[
    ============================================================
    MINIMIZE BUTTON
    ============================================================
]]
local minimized = false

minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    menuBody.Visible = not minimized
    if minimized then
        mainMenu.Size = UDim2.new(0, 280, 0, 44)
        minimizeBtn.Text = "+"
    else
        mainMenu.Size = UDim2.new(0, 280, 0, 360)
        minimizeBtn.Text = "-"
    end
end)

--[[
    ============================================================
    CLOSE BUTTON - Destroys all GUI and stops loops
    ============================================================
]]
closeBtn.MouseButton1Click:Connect(function()
    stopESP()

    for _, data in pairs(espBoxes) do
        removeBox(data)
    end
    espBoxes = {}

    if ScreenGui and ScreenGui.Parent then
        ScreenGui:Destroy()
    end
end)
