local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local Config = {
    Enabled = true,
    Acceleration = 6, -- 1 to 10
    Deceleration = 4  -- 1 to 10
}

-- Fixed & Responsive Vehicle Core Loop
RunService.Stepped:Connect(function(t, dt)
    if not Config.Enabled then return end
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local seat = hum and hum.SeatPart

    if seat and seat:IsA("VehicleSeat") then
        pcall(function()
            seat.MaxSpeed = 99999
        end)
        
        local accelRate = Config.Acceleration * 25
        local decelRate = Config.Deceleration * 0.15
        
        local throttle = seat.Throttle
        if throttle == 0 and seat.ThrottleFloat then
            throttle = seat.ThrottleFloat
        end

        if throttle > 0 then
            seat.AssemblyLinearVelocity += (seat.CFrame.LookVector * (accelRate * dt))
        elseif throttle < 0 then
            seat.AssemblyLinearVelocity = seat.AssemblyLinearVelocity:Lerp(Vector3.zero, math.clamp(decelRate * dt * 10, 0, 1))
        end
    end
end)

-- Main Interface
local Gui = Instance.new("ScreenGui")
Gui.Name = "GlossyVehicleUI"
Gui.ResetOnSpawn = false
pcall(function() Gui.Parent = CoreGui end)
if not Gui.Parent then Gui.Parent = player:WaitForChild("PlayerGui") end

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 240, 0, 195)
Main.Position = UDim2.new(0.5, -120, 0.4, -97)
Main.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Active = true
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Transparency = 0.85
MainStroke.Thickness = 1.2
MainStroke.Parent = Main

-- Glossy Subtle Gradient
local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 48, 62)),
    ColorSequenceKeypoint.new(0.35, Color3.fromRGB(24, 26, 34)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 15, 20))
})
MainGradient.Rotation = 60
MainGradient.Parent = Main

-- Header Frame
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.Text = "Vehicle Modifier"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextColor3 = Color3.fromRGB(240, 240, 250)
Title.TextStrokeTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -30, 0.5, -12)
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.BackgroundTransparency = 0.94
MinBtn.BorderSizePixel = 0
MinBtn.Text = ""
MinBtn.AutoButtonColor = false
MinBtn.Parent = Header

Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local MinusLine = Instance.new("Frame")
MinusLine.Size = UDim2.new(0, 10, 0, 2)
MinusLine.Position = UDim2.new(0.5, -5, 0.5, -1)
MinusLine.BackgroundColor3 = Color3.fromRGB(220, 225, 235)
MinusLine.BorderSizePixel = 0
MinusLine.Parent = MinBtn
Instance.new("UICorner", MinusLine).CornerRadius = UDim.new(1, 0)

local PlusLine = Instance.new("Frame")
PlusLine.Size = UDim2.new(0, 2, 0, 10)
PlusLine.Position = UDim2.new(0.5, -1, 0.5, -5)
PlusLine.BackgroundColor3 = Color3.fromRGB(220, 225, 235)
PlusLine.BorderSizePixel = 0
PlusLine.Visible = false
PlusLine.Parent = MinBtn
Instance.new("UICorner", PlusLine).CornerRadius = UDim.new(1, 0)

-- Dragging Logic
local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Layout Container
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -42)
Content.Position = UDim2.new(0, 10, 0, 36)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 8)
Layout.Parent = Content

-- Minimize Toggle Logic
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    PlusLine.Visible = minimized
    local targetSize = minimized and UDim2.new(0, 240, 0, 36) or UDim2.new(0, 240, 0, 195)
    Content.Visible = not minimized
    TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

-- Toggle Generator
local function createToggle(name, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 36)
    Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Frame.BackgroundTransparency = 0.96
    Frame.BorderSizePixel = 0
    Frame.Parent = Content

    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Text = name
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextColor3 = Color3.fromRGB(210, 210, 220)
    Label.TextStrokeTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 40, 0, 18)
    Btn.Position = UDim2.new(1, -48, 0.5, -9)
    Btn.BackgroundColor3 = default and Color3.fromRGB(0, 220, 130) or Color3.fromRGB(55, 58, 70)
    Btn.BorderSizePixel = 0
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.Parent = Frame

    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Dot.BorderSizePixel = 0
    Dot.Parent = Btn

    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0, 220, 130) or Color3.fromRGB(55, 58, 70)}):Play()
        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
        callback(state)
    end)
end

-- Slider Generator (1 to 10)
local function createSlider(name, minVal, maxVal, defaultVal, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 48)
    Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Frame.BackgroundTransparency = 0.96
    Frame.BorderSizePixel = 0
    Frame.Parent = Content

    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 4)
    Label.Text = name
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextColor3 = Color3.fromRGB(210, 210, 220)
    Label.TextStrokeTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, 0, 0, 20)
    ValueLabel.Position = UDim2.new(1, -40, 0, 4)
    ValueLabel.Text = tostring(defaultVal)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 12
    ValueLabel.TextColor3 = Color3.fromRGB(0, 220, 130)
    ValueLabel.TextStrokeTransparency = 1
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Parent = Frame

    local Track = Instance.new("TextButton")
    Track.Size = UDim2.new(1, -20, 0, 8)
    Track.Position = UDim2.new(0, 10, 0, 30)
    Track.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
    Track.BorderSizePixel = 0
    Track.Text = ""
    Track.AutoButtonColor = false
    Track.Parent = Frame

    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    local startRatio = (defaultVal - minVal) / (maxVal - minVal)
    Fill.Size = UDim2.new(startRatio, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 220, 130)
    Fill.BorderSizePixel = 0
    Fill.Parent = Track

    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local SliderGradient = Instance.new("UIGradient")
    SliderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 220, 130)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 170, 255))
    })
    SliderGradient.Parent = Fill

    local isDragging = false
    local function update(input)
        local pos = input.Position.X - Track.AbsolutePosition.X
        local ratio = math.clamp(pos / Track.AbsoluteSize.X, 0, 1)
        local val = math.round(minVal + ratio * (maxVal - minVal))
        
        Fill.Size = UDim2.new((val - minVal) / (maxVal - minVal), 0, 1, 0)
        ValueLabel.Text = tostring(val)
        callback(val)
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            update(input)
        end
    end)

    Track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

createToggle("Enabled", Config.Enabled, function(v) Config.Enabled = v end)
createSlider("Acceleration", 1, 10, Config.Acceleration, function(v) Config.Acceleration = v end)
createSlider("Deceleration", 1, 10, Config.Deceleration, function(v) Config.Deceleration = v end)
