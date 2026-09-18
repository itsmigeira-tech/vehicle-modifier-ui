local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local Config = {
    Enabled = true,
    Acceleration = 60,
    Deceleration = 4
}

-- Vehicle Modifier Core Loop
RunService.Heartbeat:Connect(function(dt)
    if not Config.Enabled then return end
    local char = player.Character
    local seat = char and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.SeatPart
    if seat and seat:IsA("VehicleSeat") then
        if seat.Throttle > 0 then
            seat.AssemblyLinearVelocity += seat.CFrame.LookVector * (Config.Acceleration * dt)
        elseif seat.Throttle < 0 then
            seat.AssemblyLinearVelocity = seat.AssemblyLinearVelocity:Lerp(Vector3.zero, math.clamp(Config.Deceleration * dt, 0, 1))
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
Main.Size = UDim2.new(0, 230, 0, 175)
Main.Position = UDim2.new(0.5, -115, 0.4, -87)
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
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "Vehicle Modifier"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11
Title.TextColor3 = Color3.fromRGB(240, 240, 250)
Title.TextStrokeTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 22, 0, 22)
MinBtn.Position = UDim2.new(1, -28, 0.5, -11)
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.BackgroundTransparency = 0.95
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
MinBtn.TextStrokeTransparency = 1
MinBtn.AutoButtonColor = false
MinBtn.Parent = Header

Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)
local MinStroke = Instance.new("UIStroke", MinBtn)
MinStroke.Color = Color3.fromRGB(255, 255, 255)
MinStroke.Transparency = 0.9

-- Dragging Functionality
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
Content.Size = UDim2.new(1, -20, 1, -40)
Content.Position = UDim2.new(0, 10, 0, 34)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 6)
Layout.Parent = Content

-- Minimize Toggle Logic
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    MinBtn.Text = minimized and "+" or "-"
    local targetSize = minimized and UDim2.new(0, 230, 0, 34) or UDim2.new(0, 230, 0, 175)
    Content.Visible = not minimized
    TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

-- Element Generators
local function createToggle(name, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 36)
    Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Frame.BackgroundTransparency = 0.96
    Frame.Parent = Content

    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.92

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Text = name
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 11
    Label.TextColor3 = Color3.fromRGB(210, 210, 220)
    Label.TextStrokeTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 40, 0, 18)
    Btn.Position = UDim2.new(1, -48, 0.5, -9)
    Btn.BackgroundColor3 = default and Color3.fromRGB(0, 220, 130) or Color3.fromRGB(55, 58, 70)
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.Parent = Frame

    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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

local function createInput(name, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 36)
    Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Frame.BackgroundTransparency = 0.96
    Frame.Parent = Content

    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.92

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.55, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Text = name
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 11
    Label.TextColor3 = Color3.fromRGB(210, 210, 220)
    Label.TextStrokeTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(0, 54, 0, 20)
    Box.Position = UDim2.new(1, -62, 0.5, -10)
    Box.BackgroundColor3 = Color3.fromRGB(32, 35, 46)
    Box.Text = tostring(default)
    Box.Font = Enum.Font.GothamBold
    Box.TextSize = 11
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.TextStrokeTransparency = 1
    Box.Parent = Frame

    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)
    local BoxStroke = Instance.new("UIStroke", Box)
    BoxStroke.Color = Color3.fromRGB(255, 255, 255)
    BoxStroke.Transparency = 0.85

    Box.FocusLost:Connect(function()
        local val = tonumber(Box.Text)
        if val then
            callback(val)
        else
            Box.Text = tostring(default)
        end
    end)
end

createToggle("Enabled", Config.Enabled, function(v) Config.Enabled = v end)
createInput("Acceleration", Config.Acceleration, function(v) Config.Acceleration = v end)
createInput("Deceleration", Config.Deceleration, function(v) Config.Deceleration = v end)
