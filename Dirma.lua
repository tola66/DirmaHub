local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local fenv = getfenv()

-- CONFIGURATION SYSTEM VARIABLES
local LibrarySettings = {} 
local ConfigurableItems = {} 
local ConfigFolder = "DirmaConfigs"
local AutoloadFile = "DirmaAutoload.txt"

-- Ensure Config Folder Exists
if makefolder then
    if not isfolder(ConfigFolder) then
        makefolder(ConfigFolder)
    end
end

----------------------------------------------------------------
-- ANIMATION UTILITIES (NEW SMOOTH SYSTEM)
----------------------------------------------------------------
local function AddHoverScale(object, scaleAmount)
    local scale = Instance.new("UIScale")
    scale.Parent = object
    
    object.MouseEnter:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = scaleAmount or 1.02}):Play()
        local stroke = object:FindFirstChildOfClass("UIStroke")
        if stroke then
            TweenService:Create(stroke, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Transparency = 0.2, Color = Color3.fromRGB(130, 110, 210)}):Play()
        end
    end)
    
    object.MouseLeave:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = 1}):Play()
        local stroke = object:FindFirstChildOfClass("UIStroke")
        if stroke then
            TweenService:Create(stroke, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Transparency = 0.5, Color = Color3.fromRGB(60, 60, 80)}):Play()
        end
    end)
    return scale
end

local function AnimateClick(scaleInstance)
    local down = TweenService:Create(scaleInstance, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.96})
    local up = TweenService:Create(scaleInstance, TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Scale = 1.02})
    local settle = TweenService:Create(scaleInstance, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Scale = 1})
    
    down:Play()
    down.Completed:Connect(function()
        up:Play()
        up.Completed:Connect(function()
            settle:Play()
        end)
    end)
end

----------------------------------------------------------------
-- UI SETUP (Main Hub)
----------------------------------------------------------------

-- Clean up old instances
local OldUI = CoreGui:FindFirstChild("DirmaHubUI")
local OldDesync = CoreGui:FindFirstChild("DirmaDesync")
local OldKolyaska = CoreGui:FindFirstChild("DirmaKolyaskaUI")
local OldESPBox = CoreGui:FindFirstChild("DirmaESP_Boxes")
local OldBestPet = CoreGui:FindFirstChild("BestPetESP")
local OldBaseESP = Workspace:FindFirstChild("DirmaBaseTarget")
local OldBooster = CoreGui:FindFirstChild("DirmaBooster")
local OldBoogie = CoreGui:FindFirstChild("DirmaBoogieGui")

-- Cleanup logic for Highlight inside workspace parts
for _, v in pairs(Workspace:GetDescendants()) do
    if v.Name == "BestPetHighlight" and v:IsA("Highlight") then
        v:Destroy()
    end
    if v:IsA("BasePart") and v:GetAttribute("DirmaOgTrans") then
        v.Transparency = v:GetAttribute("DirmaOgTrans")
        v.CastShadow = v:GetAttribute("DirmaOgShadow")
        v:SetAttribute("DirmaOgTrans", nil)
        v:SetAttribute("DirmaOgShadow", nil)
    end
end

if OldUI then OldUI:Destroy() end
if OldDesync then OldDesync:Destroy() end
if OldKolyaska then OldKolyaska:Destroy() end
if OldESPBox then OldESPBox:Destroy() end
if OldBestPet then OldBestPet:Destroy() end
if OldBaseESP then OldBaseESP:Destroy() end
if OldBooster then OldBooster:Destroy() end
if OldBoogie then OldBoogie:Destroy() end

local DirmaUI = Instance.new("ScreenGui")
DirmaUI.Name = "DirmaHubUI"
DirmaUI.ResetOnSpawn = false
DirmaUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if pcall(function() DirmaUI.Parent = CoreGui end) then
else
    DirmaUI.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 720, 0, 460) -- Slightly larger for better spacing
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5) 
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = DirmaUI
MainFrame.ClipsDescendants = true
MainFrame.Visible = true

local MainCorner = Instance.new("UICorner")
MainCorner.Parent = MainFrame
MainCorner.CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = MainFrame
MainStroke.Color = Color3.fromRGB(255, 255, 255) -- White base for gradient
MainStroke.Thickness = 2
MainStroke.Transparency = 0

-- Animated Stroke Gradient
local StrokeGradient = Instance.new("UIGradient")
StrokeGradient.Parent = MainStroke
StrokeGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 80)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(110, 90, 190)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 80))
})
StrokeGradient.Rotation = 45
task.spawn(function()
    while MainFrame.Parent do
        local t = TweenService:Create(StrokeGradient, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {Rotation = 225})
        t:Play()
        t.Completed:Wait()
    end
end)

-- TOP BAR
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.Parent = TopBar
TopBarCorner.CornerRadius = UDim.new(0, 12)

local TopBarFix = Instance.new("Frame")
TopBarFix.Size = UDim2.new(1, 0, 0.5, 0)
TopBarFix.Position = UDim2.new(0, 0, 0.5, 0)
TopBarFix.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
TopBarFix.BorderSizePixel = 0
TopBarFix.Parent = TopBar

local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, 0, 0, 1)
AccentLine.Position = UDim2.new(0, 0, 1, -1)
AccentLine.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
AccentLine.BorderSizePixel = 0
AccentLine.Transparency = 0.5
AccentLine.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Dirma Hub"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 15
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.Parent = TopBar

-- DRAG LOGIC
do
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X, 
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

-- CONTENT
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -24, 1, -48)
ContentFrame.Position = UDim2.new(0, 12, 0, 42)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 18)
StatusLabel.Position = UDim2.new(0, 0, 0, -5)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Press [LCTRL] to Toggle UI"
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextColor3 = Color3.fromRGB(100, 100, 110)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = ContentFrame

----------------------------------------------------------------
-- LAYOUT SPLIT: Left (Tabs+User) & Right (Pages)
----------------------------------------------------------------

local LeftContainer = Instance.new("Frame")
LeftContainer.Parent = ContentFrame
LeftContainer.BackgroundTransparency = 1
LeftContainer.Position = UDim2.new(0, 0, 0, 25)
LeftContainer.Size = UDim2.new(0, 150, 1, -25)

-- 1. Tabs List
local TabsFrame = Instance.new("Frame")
TabsFrame.Parent = LeftContainer
TabsFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
TabsFrame.BorderSizePixel = 0
TabsFrame.Position = UDim2.new(0, 0, 0, 0)
TabsFrame.Size = UDim2.new(1, 0, 1, -65) -- Space for profile

local TabsCorner = Instance.new("UICorner")
TabsCorner.Parent = TabsFrame
TabsCorner.CornerRadius = UDim.new(0, 10)

local TabsStroke = Instance.new("UIStroke")
TabsStroke.Parent = TabsFrame
TabsStroke.Color = Color3.fromRGB(60, 60, 80)
TabsStroke.Thickness = 1
TabsStroke.Transparency = 0.7

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.Parent = TabsFrame
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabsLayout.Padding = UDim.new(0, 6)

local TabsPadding = Instance.new("UIPadding")
TabsPadding.Parent = TabsFrame
TabsPadding.PaddingTop = UDim.new(0, 10)
TabsPadding.PaddingBottom = UDim.new(0, 10)
TabsPadding.PaddingLeft = UDim.new(0, 10)
TabsPadding.PaddingRight = UDim.new(0, 10)

-- 2. User Profile (Bottom)
local UserFrame = Instance.new("Frame")
UserFrame.Name = "UserProfile"
UserFrame.Parent = LeftContainer
UserFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
UserFrame.Position = UDim2.new(0, 0, 1, -55)
UserFrame.Size = UDim2.new(1, 0, 0, 55)

local UserCorner = Instance.new("UICorner")
UserCorner.CornerRadius = UDim.new(0, 10)
UserCorner.Parent = UserFrame

local UserStroke = Instance.new("UIStroke")
UserStroke.Color = Color3.fromRGB(60, 60, 80)
UserStroke.Thickness = 1
UserStroke.Transparency = 0.5
UserStroke.Parent = UserFrame

-- Profile Picture
local UserImage = Instance.new("ImageLabel")
UserImage.Parent = UserFrame
UserImage.Size = UDim2.new(0, 36, 0, 36)
UserImage.Position = UDim2.new(0, 10, 0.5, -18)
UserImage.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
UserImage.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
local UserImageCorner = Instance.new("UICorner"); UserImageCorner.CornerRadius = UDim.new(1, 0); UserImageCorner.Parent = UserImage
local UserImageStroke = Instance.new("UIStroke"); UserImageStroke.Color = Color3.fromRGB(100, 80, 180); UserImageStroke.Thickness = 1; UserImageStroke.Parent = UserImage

-- User Text
local DisplayNameLabel = Instance.new("TextLabel")
DisplayNameLabel.Parent = UserFrame
DisplayNameLabel.Size = UDim2.new(1, -55, 0, 16)
DisplayNameLabel.Position = UDim2.new(0, 55, 0.5, -10)
DisplayNameLabel.BackgroundTransparency = 1
DisplayNameLabel.Text = LocalPlayer.DisplayName
DisplayNameLabel.Font = Enum.Font.GothamBold
DisplayNameLabel.TextSize = 12
DisplayNameLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
DisplayNameLabel.TextTruncate = Enum.TextTruncate.AtEnd

local UserNameLabel = Instance.new("TextLabel")
UserNameLabel.Parent = UserFrame
UserNameLabel.Size = UDim2.new(1, -55, 0, 14)
UserNameLabel.Position = UDim2.new(0, 55, 0.5, 4)
UserNameLabel.BackgroundTransparency = 1
UserNameLabel.Text = "@" .. LocalPlayer.Name
UserNameLabel.Font = Enum.Font.Gotham
UserNameLabel.TextSize = 10
UserNameLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
UserNameLabel.TextXAlignment = Enum.TextXAlignment.Left
UserNameLabel.TextTruncate = Enum.TextTruncate.AtEnd

AddHoverScale(UserFrame, 1.02)

-- TAB BUTTON CREATOR
local function CreateTabButton(name)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Tab"
    btn.Parent = TabsFrame
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.AutoButtonColor = false
    btn.Text = name
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(170, 170, 180)
    btn.BorderSizePixel = 0
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn
    
    local s = Instance.new("UIStroke")
    s.Parent = btn
    s.Color = Color3.fromRGB(60, 60, 80)
    s.Thickness = 1
    s.Transparency = 0.8
    
    -- Animation Hook
    local scale = AddHoverScale(btn, 1.03)
    
    btn.MouseButton1Down:Connect(function()
        AnimateClick(scale)
    end)
    
    return btn
end

local PlayerTabButton = CreateTabButton("Player")
local ExtraTabButton  = CreateTabButton("Extra")
local VisualTabButton = CreateTabButton("Visual")
local ServerTabButton = CreateTabButton("Server")
local InvalidTabButton = CreateTabButton("For Invalids")
local ConfigTabButton = CreateTabButton("Configs")

-- PAGES PANEL (RIGHT SIDE)
local PagesBackground = Instance.new("Frame")
PagesBackground.Parent = ContentFrame
PagesBackground.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
PagesBackground.BorderSizePixel = 0
PagesBackground.Position = UDim2.new(0, 160, 0, 25)
PagesBackground.Size = UDim2.new(1, -160, 1, -25)
PagesBackground.ClipsDescendants = true -- Important for slide animation

local PagesCorner = Instance.new("UICorner")
PagesCorner.Parent = PagesBackground
PagesCorner.CornerRadius = UDim.new(0, 10)

local PagesStroke = Instance.new("UIStroke")
PagesStroke.Parent = PagesBackground
PagesStroke.Color = Color3.fromRGB(60, 60, 80)
PagesStroke.Thickness = 1
PagesStroke.Transparency = 0.7

local PagesFrame = Instance.new("Frame")
PagesFrame.Parent = PagesBackground
PagesFrame.BackgroundTransparency = 1
PagesFrame.Size = UDim2.new(1, -12, 1, -12)
PagesFrame.Position = UDim2.new(0, 6, 0, 6)
-- We do NOT clip descendants here so scroll bar renders nicely, PagesBackground does the clipping
PagesFrame.ClipsDescendants = false 

local function CreatePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Parent = PagesFrame
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Visible = false
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(100, 80, 160)
    
    -- Hidden position state for animation
    page.Position = UDim2.new(0, 0, 0, 20) 
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = page
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    
    local pad = Instance.new("UIPadding")
    pad.Parent = page
    pad.PaddingTop = UDim.new(0, 2)
    pad.PaddingLeft = UDim.new(0, 2)
    pad.PaddingRight = UDim.new(0, 8) -- Space for scrollbar
    
    return page
end

local PlayerPage = CreatePage("Player")
local ExtraPage  = CreatePage("Extra")
local VisualPage = CreatePage("Visual")
local ServerPage = CreatePage("Server")
local InvalidPage = CreatePage("For Invalids")
local ConfigPage = CreatePage("Configs")

local function SetActiveTab(tabName)
    local pages = {PlayerPage, ExtraPage, VisualPage, ServerPage, InvalidPage, ConfigPage}
    local targetPage = nil
    
    if tabName == "Player" then targetPage = PlayerPage end
    if tabName == "Extra" then targetPage = ExtraPage end
    if tabName == "Visual" then targetPage = VisualPage end
    if tabName == "Server" then targetPage = ServerPage end
    if tabName == "For Invalids" then targetPage = InvalidPage end
    if tabName == "Configs" then targetPage = ConfigPage end
    
    -- Hide other pages
    for _, p in ipairs(pages) do
        if p ~= targetPage then
            p.Visible = false
            p.Position = UDim2.new(0, 0, 0, 40) -- Reset pos
        end
    end
    
    -- Animate target page
    if targetPage then
        targetPage.Visible = true
        targetPage.CanvasPosition = Vector2.new(0,0)
        targetPage.Position = UDim2.new(0, 0, 0, 40)
        
        -- Smooth Slide Up
        TweenService:Create(targetPage, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    end
    
    -- Button Styling
    for _, btn in ipairs({PlayerTabButton, ExtraTabButton, VisualTabButton, ServerTabButton, InvalidTabButton, ConfigTabButton}) do
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(25, 25, 35), TextColor3 = Color3.fromRGB(170, 170, 180)}):Play()
        local s = btn:FindFirstChildOfClass("UIStroke")
        if s then TweenService:Create(s, TweenInfo.new(0.3), {Color = Color3.fromRGB(60, 60, 80)}):Play() end
    end
    
    local activeBtn = (tabName == "Player" and PlayerTabButton) or 
                      (tabName == "Extra" and ExtraTabButton) or 
                      (tabName == "Visual" and VisualTabButton) or 
                      (tabName == "Server" and ServerTabButton) or
                      (tabName == "For Invalids" and InvalidTabButton) or
                      ConfigTabButton
                      
    TweenService:Create(activeBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(60, 50, 90), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    local s = activeBtn:FindFirstChildOfClass("UIStroke")
    if s then TweenService:Create(s, TweenInfo.new(0.3), {Color = Color3.fromRGB(120, 100, 200)}):Play() end
end

PlayerTabButton.MouseButton1Click:Connect(function() SetActiveTab("Player") end)
ExtraTabButton.MouseButton1Click:Connect(function() SetActiveTab("Extra") end)
VisualTabButton.MouseButton1Click:Connect(function() SetActiveTab("Visual") end)
ServerTabButton.MouseButton1Click:Connect(function() SetActiveTab("Server") end)
InvalidTabButton.MouseButton1Click:Connect(function() SetActiveTab("For Invalids") end)
ConfigTabButton.MouseButton1Click:Connect(function() SetActiveTab("Configs") end)
task.delay(0.1, function() SetActiveTab("Player") end)

----------------------------------------------------------------
-- COMPONENT SYSTEM (Improved Animations)
----------------------------------------------------------------

local function CreateSection(parent, text)
    local container = Instance.new("Frame")
    container.Parent = parent
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 25)
    
    local lbl = Instance.new("TextLabel")
    lbl.Parent = container
    lbl.Size = UDim2.new(1, -5, 1, 0)
    lbl.Position = UDim2.new(0, 5, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    lbl.TextTransparency = 1
    TweenService:Create(lbl, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
    
    return container
end

local function CreateToggle(parent, text, callback)
    local container = Instance.new("Frame")
    container.Parent = parent
    container.Size = UDim2.new(1, -5, 0, 38)
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    
    AddHoverScale(container, 1.015)
    
    local cc = Instance.new("UICorner"); cc.CornerRadius=UDim.new(0,6); cc.Parent=container
    local s = Instance.new("UIStroke"); s.Parent=container; s.Color=Color3.fromRGB(50,50,65); s.Thickness=1

    local lbl = Instance.new("TextLabel")
    lbl.Parent = container
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(220, 220, 230)
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton")
    btn.Parent = container
    btn.Size = UDim2.new(0, 42, 0, 22)
    btn.AnchorPoint = Vector2.new(1, 0.5)
    btn.Position = UDim2.new(1, -10, 0.5, 0)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.Text = ""
    local bc = Instance.new("UICorner"); bc.CornerRadius=UDim.new(1,0); bc.Parent=btn

    local knob = Instance.new("Frame")
    knob.Parent = btn
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    local kc = Instance.new("UICorner"); kc.CornerRadius=UDim.new(1,0); kc.Parent=knob

    local toggled = false
    
    local function SetState(state)
        toggled = state
        LibrarySettings[text] = state
        
        -- Smooth Toggle Animation
        if state then
            TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(100, 80, 180)}):Play()
            -- Elastic Knob movement
            TweenService:Create(knob, TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        end
        task.spawn(function() callback(toggled) end)
    end
    
    ConfigurableItems[text] = SetState

    btn.MouseButton1Click:Connect(function()
        SetState(not toggled)
    end)
    return container
end

local function CreateSlider(parent, text, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Parent = parent
    container.Size = UDim2.new(1, -5, 0, 55)
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    
    AddHoverScale(container, 1.015)
    
    local cc = Instance.new("UICorner"); cc.CornerRadius=UDim.new(0,6); cc.Parent=container
    local s = Instance.new("UIStroke"); s.Parent=container; s.Color=Color3.fromRGB(50,50,65); s.Thickness=1
    local lbl = Instance.new("TextLabel"); lbl.Parent = container; lbl.Size = UDim2.new(1, -20, 0, 20); lbl.Position = UDim2.new(0, 10, 0, 5); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 13; lbl.TextColor3 = Color3.fromRGB(220, 220, 230); lbl.TextXAlignment = Enum.TextXAlignment.Left
    local valLbl = Instance.new("TextLabel"); valLbl.Parent = container; valLbl.Size = UDim2.new(0, 50, 0, 20); valLbl.AnchorPoint = Vector2.new(1, 0); valLbl.Position = UDim2.new(1, -10, 0, 5); valLbl.BackgroundTransparency = 1; valLbl.Text = tostring(default); valLbl.Font = Enum.Font.Gotham; valLbl.TextSize = 12; valLbl.TextColor3 = Color3.fromRGB(150, 150, 160); valLbl.TextXAlignment = Enum.TextXAlignment.Right
    local sliderBg = Instance.new("TextButton"); sliderBg.Parent = container; sliderBg.Size = UDim2.new(1, -20, 0, 6); sliderBg.Position = UDim2.new(0, 10, 0, 38); sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60); sliderBg.Text = ""; sliderBg.AutoButtonColor = false; local sc = Instance.new("UICorner"); sc.CornerRadius=UDim.new(1,0); sc.Parent=sliderBg
    local sliderFill = Instance.new("Frame"); sliderFill.Parent = sliderBg; sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0); sliderFill.BackgroundColor3 = Color3.fromRGB(100, 80, 180); local sfc = Instance.new("UICorner"); sfc.CornerRadius=UDim.new(1,0); sfc.Parent=sliderFill
    
    local dragging = false
    
    local function SetValue(val)
        val = math.clamp(val, min, max)
        local pos = (val - min) / (max - min)
        -- Exponential smoothness
        TweenService:Create(sliderFill, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
        valLbl.Text = tostring(val)
        LibrarySettings[text] = val
        callback(val)
    end
    
    ConfigurableItems[text] = SetValue

    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + ((max - min) * pos))
        SetValue(val)
        TweenService:Create(valLbl, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(200, 180, 255)}):Play()
    end
    
    sliderBg.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = true; update(input) 
            TweenService:Create(sliderFill, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(120, 100, 200)}):Play()
        end 
    end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
    UserInputService.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = false 
            TweenService:Create(valLbl, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 160)}):Play()
            TweenService:Create(sliderFill, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 80, 180)}):Play()
        end 
    end)
    
    SetValue(default)
end

local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(1, -5, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(220, 220, 230)
    btn.TextSize = 13
    local c = Instance.new("UICorner"); c.CornerRadius=UDim.new(0,6); c.Parent=btn
    local s = Instance.new("UIStroke"); s.Parent=btn; s.Color=Color3.fromRGB(60,60,75); s.Thickness=1
    
    local scale = AddHoverScale(btn, 1.02)
    
    btn.MouseButton1Click:Connect(function() 
        AnimateClick(scale)
        -- Flash effect
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(70,70,90)}):Play(); 
        task.wait(0.1); 
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3=Color3.fromRGB(40,40,50)}):Play(); 
        callback() 
    end)
    return btn 
end

local function CreateInput(parent, placeholder, callback)
    local container = Instance.new("Frame")
    container.Parent = parent
    container.Size = UDim2.new(1, -5, 0, 38)
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    
    AddHoverScale(container, 1.015)
    
    local cc = Instance.new("UICorner"); cc.CornerRadius=UDim.new(0,6); cc.Parent=container
    local s = Instance.new("UIStroke"); s.Parent=container; s.Color=Color3.fromRGB(50,50,65); s.Thickness=1

    local box = Instance.new("TextBox")
    box.Parent = container
    box.Size = UDim2.new(1, -20, 1, 0)
    box.Position = UDim2.new(0, 10, 0, 0)
    box.BackgroundTransparency = 1
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.TextColor3 = Color3.fromRGB(220, 220, 230)
    box.PlaceholderText = placeholder or "Input..."
    box.PlaceholderColor3 = Color3.fromRGB(150, 150, 160)
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.Text = ""

    box.Focused:Connect(function()
        TweenService:Create(s, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(100, 80, 180)}):Play()
    end)

    box.FocusLost:Connect(function()
        TweenService:Create(s, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(50, 50, 65)}):Play()
        callback(box.Text)
    end)
    return container
end

----------------------------------------------------------------
-- FEATURE LOGIC (Logic preserved exactly as requested)
----------------------------------------------------------------

-- ======================
-- FOV MANAGER
-- ======================
local FOV_MANAGER = {
    activeCount = 0,
    conn = nil,
    forcedFOV = 70,
}

function FOV_MANAGER:Start()
    if self.conn then return end
    self.conn = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        if cam and cam.FieldOfView ~= self.forcedFOV then cam.FieldOfView = self.forcedFOV end
    end)
end

function FOV_MANAGER:Stop()
    if self.conn then self.conn:Disconnect(); self.conn = nil end
end

function FOV_MANAGER:Push()
    self.activeCount = self.activeCount + 1
    self:Start()
end

function FOV_MANAGER:Pop()
    if self.activeCount > 0 then self.activeCount = self.activeCount - 1 end
    if self.activeCount == 0 then self:Stop() end
end

-- ======================
-- ANTI BEE & DISCO
-- ======================
local ANTI_BEE_DISCO = {}
local antiBeeDiscoRunning = false
local antiBeeDiscoConnections = {}
local originalMoveFunction = nil
local controlsProtected = false

local BAD_LIGHTING_NAMES = {Blue=true, DiscoEffect=true, BeeBlur=true, ColorCorrection=true}

local function antiBeeDiscoNuke(obj)
    if not obj or not obj.Parent then return end
    if BAD_LIGHTING_NAMES[obj.Name] then pcall(function() obj:Destroy() end) end
end

local function protectControls()
    if controlsProtected then return end
    pcall(function()
        local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts", 10)
        if not PlayerScripts then return end
        local PlayerModule = PlayerScripts:FindFirstChild("PlayerModule")
        if not PlayerModule then return end
        local Controls = require(PlayerModule):GetControls()
        if not Controls then return end
        if not originalMoveFunction then originalMoveFunction = Controls.moveFunction end
        local function protectedMoveFunction(self, moveVector, relativeToCamera)
            if originalMoveFunction then originalMoveFunction(self, moveVector, relativeToCamera) end
        end
        local controlCheckConn = RunService.Heartbeat:Connect(function()
            if not antiBeeDiscoRunning then return end
            if Controls.moveFunction ~= protectedMoveFunction then Controls.moveFunction = protectedMoveFunction end
        end)
        table.insert(antiBeeDiscoConnections, controlCheckConn)
        Controls.moveFunction = protectedMoveFunction
        controlsProtected = true
    end)
end

local function restoreControls()
    if not controlsProtected then return end
    pcall(function()
        local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts", 10)
        if not PlayerScripts then return end
        local PlayerModule = PlayerScripts:FindFirstChild("PlayerModule")
        if not PlayerModule then return end
        local Controls = require(PlayerModule):GetControls()
        if not Controls or not originalMoveFunction then return end
        Controls.moveFunction = originalMoveFunction
        controlsProtected = false
    end)
end

local function blockBuzzingSound()
    pcall(function()
        local PlayerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
        if not PlayerScripts then return end
        local beeScript = PlayerScripts:FindFirstChild("Bee", true)
        if beeScript then
            local buzzing = beeScript:FindFirstChild("Buzzing")
            if buzzing and buzzing:IsA("Sound") then buzzing:Stop(); buzzing.Volume = 0 end
        end
    end)
end

function ANTI_BEE_DISCO.Enable()
    if antiBeeDiscoRunning then return end
    antiBeeDiscoRunning = true
    for _, inst in ipairs(Lighting:GetDescendants()) do antiBeeDiscoNuke(inst) end
    Lighting.FogEnd = 9e9; Lighting.GlobalShadows = false; Lighting.Brightness = 2
    table.insert(antiBeeDiscoConnections, Lighting.DescendantAdded:Connect(function(obj)
        if not antiBeeDiscoRunning then return end
        antiBeeDiscoNuke(obj)
    end))
    protectControls()
    table.insert(antiBeeDiscoConnections, RunService.Heartbeat:Connect(function()
        if not antiBeeDiscoRunning then return end
        blockBuzzingSound()
    end))
    FOV_MANAGER:Push()
end

function ANTI_BEE_DISCO.Disable()
    if not antiBeeDiscoRunning then return end
    antiBeeDiscoRunning = false
    restoreControls()
    for _, conn in ipairs(antiBeeDiscoConnections) do if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end end
    antiBeeDiscoConnections = {}
    FOV_MANAGER:Pop()
end


-- ================= PLAYER TAB ================= --
local Spin = {Enabled = false, Speed = 30, Connection = nil}
CreateSection(PlayerPage, "Movement Modifiers")
CreateToggle(PlayerPage, "SpinBot", function(state)
    Spin.Enabled = state
    if state then
        Spin.Connection = RunService.Heartbeat:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.RotVelocity = Vector3.new(0, Spin.Speed, 0)
            end
        end)
    else
        if Spin.Connection then Spin.Connection:Disconnect() end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
end)
CreateSlider(PlayerPage, "Spin Speed", 0, 100, 30, function(val) Spin.Speed = val end)

-- ==========================================
-- DIRMA BOOSTER
-- ==========================================
local BoosterGUI = nil
local Booster = {
    Enabled = false,
    NormalSpeed = 50,
    HeavySpeed = 30,
    IsHeavy = false,
    Connection = nil
}

local function UpdateBoosterVisuals()
    if not BoosterGUI then return end
    local main = BoosterGUI:FindFirstChild("MainFrame")
    if not main then return end
    local status = main:FindFirstChild("Content"):FindFirstChild("StatusLabel")
    local btn = main:FindFirstChild("Content"):FindFirstChild("ToggleBtn")
    
    if Booster.Enabled then
        if btn then 
            btn.Text = "ENABLED"
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 80, 180), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end
        if status then
            if Booster.IsHeavy then
                status.Text = "Mode: HEAVY (Speed: " .. Booster.HeavySpeed .. ")"
                status.TextColor3 = Color3.fromRGB(255, 150, 50)
            else
                status.Text = "Mode: NORMAL (Speed: " .. Booster.NormalSpeed .. ")"
                status.TextColor3 = Color3.fromRGB(100, 255, 100)
            end
        end
    else
        if btn then 
            btn.Text = "ENABLE"
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 60), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        end
        if status then
            status.Text = "Status: Disabled"
            status.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
end

local function SetBoosterState(state)
    Booster.Enabled = state
    if state then
        if not Booster.Connection then
            Booster.Connection = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                
                if hum and hrp and hum.Health > 0 then
                    local isHeavy = hum.WalkSpeed < 25
                    Booster.IsHeavy = isHeavy
                    local targetSpeed = isHeavy and Booster.HeavySpeed or Booster.NormalSpeed

                    if hum.MoveDirection.Magnitude > 0 then
                        hrp.Velocity = Vector3.new(hum.MoveDirection.X * targetSpeed, hrp.Velocity.Y, hum.MoveDirection.Z * targetSpeed)
                    else
                        hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
                    end
                end
            end)
        end
    else
        if Booster.Connection then Booster.Connection:Disconnect(); Booster.Connection = nil end
    end
    UpdateBoosterVisuals()
end

local function ToggleBoosterGUI(show)
    if show then
        if BoosterGUI then return end
        local sg = Instance.new("ScreenGui")
        sg.Name = "DirmaBooster"
        sg.Parent = CoreGui
        
        local mf = Instance.new("Frame")
        mf.Name = "MainFrame"
        mf.Size = UDim2.new(0, 0, 0, 0) -- Start small for animation
        mf.Position = UDim2.new(0.2, 0, 0.5, 0)
        mf.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
        mf.BorderSizePixel = 0
        mf.Active = true
        mf.Draggable = true
        mf.Parent = sg
        mf.ClipsDescendants = true
        
        -- Animation
        TweenService:Create(mf, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 240, 0, 130)}):Play()

        Instance.new("UICorner", mf).CornerRadius = UDim.new(0, 10)
        local ms = Instance.new("UIStroke", mf)
        ms.Color = Color3.fromRGB(60, 60, 80); ms.Thickness = 2; ms.Transparency = 0.5
        
        local tb = Instance.new("Frame", mf)
        tb.Size = UDim2.new(1,0,0,30); tb.BackgroundColor3 = Color3.fromRGB(18,18,25); Instance.new("UICorner", tb).CornerRadius = UDim.new(0,10)
        local tl = Instance.new("TextLabel", tb); tl.Size = UDim2.new(1,-10,1,0); tl.Position = UDim2.new(0,10,0,0); tl.BackgroundTransparency = 1; tl.Text = "Dirma Booster"; tl.Font = Enum.Font.GothamBold; tl.TextColor3 = Color3.fromRGB(220,220,230); tl.TextXAlignment = Enum.TextXAlignment.Left; tl.TextSize = 14
        
        local cnt = Instance.new("Frame", mf); cnt.Name = "Content"; cnt.Size = UDim2.new(1,-20,1,-40); cnt.Position = UDim2.new(0,10,0,35); cnt.BackgroundTransparency = 1
        
        local btn = Instance.new("TextButton", cnt); btn.Name = "ToggleBtn"; btn.Size = UDim2.new(1,0,0,40); btn.BackgroundColor3 = Color3.fromRGB(50,50,60); btn.Text = "ENABLE"; btn.Font = Enum.Font.GothamBold; btn.TextColor3 = Color3.fromRGB(200,200,200); btn.TextSize = 16; Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
        
        local st = Instance.new("TextLabel", cnt); st.Name = "StatusLabel"; st.Size = UDim2.new(1,0,0,20); st.Position = UDim2.new(0,0,0,55); st.BackgroundTransparency = 1; st.Text = "Status: Disabled"; st.Font = Enum.Font.Gotham; st.TextSize = 12; st.TextColor3 = Color3.fromRGB(150,150,150)
        
        task.spawn(function()
            while sg.Parent do
                UpdateBoosterVisuals()
                task.wait(0.1)
            end
        end)
        
        btn.MouseButton1Click:Connect(function()
            SetBoosterState(not Booster.Enabled)
        end)
        
        BoosterGUI = sg
        UpdateBoosterVisuals()
    else
        if BoosterGUI then BoosterGUI:Destroy(); BoosterGUI = nil end
        SetBoosterState(false)
    end
end

CreateToggle(PlayerPage, "Open Booster Menu", function(state)
    ToggleBoosterGUI(state)
end)


-- ==========================================
-- BOOGIE SPAMER
-- ==========================================
CreateSection(PlayerPage, "Combat & Tools")
local BoogieGUI = nil
local Boogie = {
    Active = false,
    BombName = "Boogie Bomb",
    Bind = Enum.KeyCode.R,
    IsSettingBind = false
}

local function makePetGhost()
    local char = LocalPlayer.Character
    if not char then return end
    for _, obj in pairs(char:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" and obj.Name ~= "Handle" then
            obj.CanCollide = false; obj.CanTouch = false; obj.CanQuery = false
        end
    end
end

local function throwLoop()
    while Boogie.Active do
        local char = LocalPlayer.Character; local bp = LocalPlayer.Backpack; local hum = char and char:FindFirstChild("Humanoid")
        if not char or not hum or not bp then task.wait(0.1) continue end
        local bomb = bp:FindFirstChild(Boogie.BombName) or char:FindFirstChild(Boogie.BombName)
        if bomb then
            local fh = RunService.RenderStepped:Connect(function() if Boogie.Active then if bomb.Parent ~= char then hum:EquipTool(bomb) end makePetGhost() end end)
            hum:EquipTool(bomb)
            local t = tick(); while tick()-t < 0.25 do if not Boogie.Active then fh:Disconnect() return end task.wait() end
            if Boogie.Active and bomb.Parent == char then
                local s = workspace.CurrentCamera.ViewportSize
                VirtualInputManager:SendMouseButtonEvent(s.X/2, s.Y/2, 0, true, game, 1)
                task.wait(0.15)
                VirtualInputManager:SendMouseButtonEvent(s.X/2, s.Y/2, 0, false, game, 1)
                t = tick(); while tick()-t < 0.5 do if not Boogie.Active then fh:Disconnect() return end task.wait() end
            end
            fh:Disconnect(); if bomb.Parent == char then bomb.Parent = bp end; task.wait(0.6)
        else task.wait(0.1) end
    end
end

local function ActivateBurst()
    if Boogie.Active then return end
    Boogie.Active = true
    if BoogieGUI then
        local st = BoogieGUI.MainFrame:FindFirstChild("Status")
        if st then st.Text = "ACTIVE"; st.TextColor3 = Color3.fromRGB(255,100,100) end
    end
    task.spawn(throwLoop)
    task.spawn(function() while Boogie.Active do VirtualUser:CaptureController(); VirtualUser:ClickButton1(Vector2.new()); RunService.RenderStepped:Wait() end end)
    task.delay(3, function()
        Boogie.Active = false
        local c = LocalPlayer.Character; local b = c and c:FindFirstChild(Boogie.BombName)
        if b then b.Parent = LocalPlayer.Backpack end
        if BoogieGUI then
            local st = BoogieGUI.MainFrame:FindFirstChild("Status")
            if st then st.Text = "READY"; st.TextColor3 = Color3.fromRGB(100,255,100) end
        end
    end)
end

local function ToggleBoogieGUI(show)
    if show then
        if BoogieGUI then return end
        local sg = Instance.new("ScreenGui")
        sg.Name = "DirmaBoogieGui"
        sg.Parent = CoreGui
        
        local mf = Instance.new("Frame")
        mf.Name = "MainFrame"
        mf.Size = UDim2.new(0, 0, 0, 0) -- Animation start
        mf.Position = UDim2.new(0.5, -120, 0.5, -65)
        mf.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        mf.BorderSizePixel = 0; mf.Active = true; mf.Draggable = true; mf.Parent = sg
        mf.ClipsDescendants = true
        
        TweenService:Create(mf, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 240, 0, 140)}):Play()
        
        Instance.new("UICorner", mf).CornerRadius = UDim.new(0, 10)
        local ms = Instance.new("UIStroke", mf); ms.Color = Color3.fromRGB(50,50,60); ms.Thickness = 2; ms.Transparency = 0.5
        
        local tl = Instance.new("TextLabel", mf); tl.Size = UDim2.new(1,-20,0,30); tl.Position = UDim2.new(0,10,0,5); tl.BackgroundTransparency = 1; tl.Text = "Dirma Boogie"; tl.Font = Enum.Font.GothamBold; tl.TextColor3 = Color3.fromRGB(220,220,230); tl.TextXAlignment = Enum.TextXAlignment.Left; tl.TextSize = 14
        
        local btn = Instance.new("TextButton", mf); btn.Size = UDim2.new(1,-20,0,40); btn.Position = UDim2.new(0,10,0,40); btn.BackgroundColor3 = Color3.fromRGB(60,40,80); btn.Text = "Activate"; btn.Font = Enum.Font.GothamBold; btn.TextColor3 = Color3.fromRGB(255,255,255); btn.TextSize = 16; Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
        
        local st = Instance.new("TextLabel", mf); st.Name = "Status"; st.Size = UDim2.new(1,-20,0,20); st.Position = UDim2.new(0,10,1,-25); st.BackgroundTransparency = 1; st.Text = "READY"; st.Font = Enum.Font.Gotham; st.TextColor3 = Color3.fromRGB(100,255,100); st.TextSize = 12
        
        local bindBtn = Instance.new("TextButton", mf); bindBtn.Size = UDim2.new(1,-20,0,25); bindBtn.Position = UDim2.new(0,10,1,-55); bindBtn.BackgroundColor3 = Color3.fromRGB(25,25,30); bindBtn.Text = "Bind: " .. Boogie.Bind.Name; bindBtn.Font = Enum.Font.GothamMedium; bindBtn.TextColor3 = Color3.fromRGB(150,150,160); bindBtn.TextSize = 11; Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0,6)
        
        btn.MouseButton1Click:Connect(ActivateBurst)
        bindBtn.MouseButton1Click:Connect(function() Boogie.IsSettingBind = true; bindBtn.Text = "Press Key..." end)
        
        BoogieGUI = sg
    else
        if BoogieGUI then BoogieGUI:Destroy(); BoogieGUI = nil end
        Boogie.Active = false
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if Boogie.IsSettingBind then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            Boogie.Bind = input.KeyCode
            Boogie.IsSettingBind = false
            if BoogieGUI then
                for _,v in pairs(BoogieGUI.MainFrame:GetChildren()) do if v:IsA("TextButton") and v.Text:find("Press") then v.Text = "Bind: " .. Boogie.Bind.Name end end
            end
        end
        return
    end
    if input.KeyCode == Boogie.Bind then ActivateBurst() end
end)

CreateToggle(PlayerPage, "Open Boogie Menu", function(state)
    ToggleBoogieGUI(state)
end)


CreateSection(PlayerPage, "Abilities")
local infJumpEnabled = false
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z) end
    end
end)
CreateToggle(PlayerPage, "Infinite Jump", function(state) infJumpEnabled = state end)

-- ============================================================
-- ANTI-RAGDOLL SYSTEM (IMPROVED)
-- ============================================================

local ANTI_RAGDOLL = {}
local antiRagdollMode = nil
local ragdollConnections = {}
local cachedCharData = {}

local function cacheCharacterData()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return false end
    cachedCharData = {character = char, humanoid = hum, root = root}
    return true
end

local function disconnectAll()
    for _, conn in ipairs(ragdollConnections) do
        if typeof(conn) == "RBXScriptConnection" then pcall(function() conn:Disconnect() end) end
    end
    ragdollConnections = {}
end

function ANTI_RAGDOLL.Enable(mode)
    if mode ~= "v1" and mode ~= "v2" then warn("[Anti-Ragdoll] Invalid mode:", mode) return end
    if antiRagdollMode == mode then return end
    ANTI_RAGDOLL.Disable()
    if not cacheCharacterData() then warn("[Anti-Ragdoll] Failed to cache character data") return end
    antiRagdollMode = mode
    
    print("[Anti-Ragdoll] Enabled mode:", mode)
    
    if mode == "v1" then
        -- V1: Event Based (Standard)
        local conn = cachedCharData.humanoid.StateChanged:Connect(function(old, new)
            local ragdollStates = {
                [Enum.HumanoidStateType.Physics] = true,
                [Enum.HumanoidStateType.Ragdoll] = true,
                [Enum.HumanoidStateType.FallingDown] = true
            }
            if ragdollStates[new] then
                cachedCharData.humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
                if cachedCharData.root then
                    cachedCharData.root.AssemblyLinearVelocity = Vector3.zero
                    cachedCharData.root.Anchored = false
                end
            end
        end)
        table.insert(ragdollConnections, conn)
        
    elseif mode == "v2" then
        -- V2: Loop Based (Aggressive)
        local conn = RunService.RenderStepped:Connect(function()
            if not cachedCharData.humanoid then return end
            cachedCharData.humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            cachedCharData.humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            cachedCharData.humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
            if cachedCharData.humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
                cachedCharData.humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
            end
        end)
        table.insert(ragdollConnections, conn)
    end
end

function ANTI_RAGDOLL.Disable()
    if not antiRagdollMode then return end
    antiRagdollMode = nil
    disconnectAll()
    cachedCharData = {}
    print("[Anti-Ragdoll] Disabled")
end

-- Re-enable on respawn if active
LocalPlayer.CharacterAdded:Connect(function()
    if antiRagdollMode then
        local savedMode = antiRagdollMode
        task.wait(1)
        ANTI_RAGDOLL.Enable(savedMode)
    end
end)

CreateToggle(PlayerPage, "No Velocity", function(state)
    if state then
        ANTI_RAGDOLL.Enable("v1")
    else
        ANTI_RAGDOLL.Disable()
    end
end)


-- ============================================================

local noAnimEnabled = false
local noAnimConn
CreateToggle(PlayerPage, "No Animation", function(state)
    noAnimEnabled = state
    if state then
        local function stopAnims()
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                local anim = hum and hum:FindFirstChild("Animator")
                if anim then for _, t in pairs(anim:GetPlayingAnimationTracks()) do t:Stop(); t:AdjustSpeed(0) end end
            end
        end
        stopAnims()
        noAnimConn = RunService.Heartbeat:Connect(stopAnims)
    else
        if noAnimConn then noAnimConn:Disconnect(); noAnimConn = nil end
    end
end)

-- ================= EXTRA TAB ================= --
CreateSection(ExtraPage, "Combat")
local isAutoLaser = false
local laserRange = 50
local laserThread = nil
local UseItemEvent
local packages = ReplicatedStorage:WaitForChild("Packages", 2)
if packages then UseItemEvent = packages:FindFirstChild("Net") and packages.Net:FindFirstChild("RE/UseItem") end
local function startAutoLaserCape()
    if laserThread then task.cancel(laserThread) end
    laserThread = task.spawn(function()
        while isAutoLaser do
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local cape = char:FindFirstChild("Laser Cape") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Laser Cape"))
                if cape then
                    local myRoot = char:FindFirstChild("HumanoidRootPart")
                    local targetRoot = nil
                    local minDist = laserRange
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (p.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
                            if dist < minDist then minDist = dist; targetRoot = p.Character.HumanoidRootPart end
                        end
                    end
                    if targetRoot and UseItemEvent then
                        if cape.Parent ~= char then cape.Parent = char end
                        pcall(function() UseItemEvent:FireServer(targetRoot.Position, targetRoot) end)
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end
CreateToggle(ExtraPage, "Auto Laser Cape", function(state) isAutoLaser = state; if state then startAutoLaserCape() else if laserThread then task.cancel(laserThread) end end end)
CreateSlider(ExtraPage, "Laser Range", 10, 100, 50, function(val) laserRange = val end)

-- [ADDED] Auto Silent Bat Logic
local SilentBatRange = 12
local SilentBatCooldown = 0.5
local lastSilentBat = 0
local batConnection = nil

CreateToggle(ExtraPage, "Auto Silent Bat", function(state)
    if state then
        if batConnection then batConnection:Disconnect() end
        batConnection = RunService.RenderStepped:Connect(function()
            if tick() - lastSilentBat >= SilentBatCooldown then
                local c = LocalPlayer.Character
                if not c then return end
                local r = c:FindFirstChild("HumanoidRootPart")
                if not r then return end

                for _, tool in ipairs(c:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name:lower():find("bat") then
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Character then
                                local hr = p.Character:FindFirstChild("HumanoidRootPart")
                                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                                if hr and hum and hum.Health > 0 then
                                    if (hr.Position - r.Position).Magnitude <= SilentBatRange then
                                        pcall(function() tool:Activate() end)
                                        lastSilentBat = tick()
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        if batConnection then batConnection:Disconnect(); batConnection = nil end
    end
end)

-- [ADDED] AUTO CLONER INTEGRATION
CreateSection(ExtraPage, "Tools")
local AutoCloner = {
    Enabled = false,
    Conn = nil,
    X = 963,
    Y = 826,
    Tool = "Quantum Cloner",
    Delay = 0.15
}

local function activateCloner()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local backpack = LocalPlayer.Backpack
    local tool = char:FindFirstChild(AutoCloner.Tool) or backpack:FindFirstChild(AutoCloner.Tool)
    
    if tool then
        if tool.Parent == backpack then hum:EquipTool(tool) end
        tool:Activate()
        task.wait(AutoCloner.Delay)
        -- Send click event
        VirtualInputManager:SendMouseButtonEvent(AutoCloner.X, AutoCloner.Y, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(AutoCloner.X, AutoCloner.Y, 0, false, game, 1)
    else
        StatusLabel.Text = "Cloner not found!"
    end
end

CreateToggle(ExtraPage, "Auto Cloner (Key: V)", function(state)
    AutoCloner.Enabled = state
    if state then
        AutoCloner.Conn = UserInputService.InputBegan:Connect(function(input, gp)
            if not gp and input.KeyCode == Enum.KeyCode.V then
                activateCloner()
            end
        end)
    else
        if AutoCloner.Conn then AutoCloner.Conn:Disconnect(); AutoCloner.Conn = nil end
    end
end)


CreateSection(ExtraPage, "Network")

-------------------------------------------------------------------------------------
--DESYNC V2 INTEGRATION (UPDATED WITH YOUR UI)
-------------------------------------------------------------------------------------
local desyncGUI = nil
local desyncEnabled = false
local desyncKillThread = nil

local flags = {
	["GameNetPVHeaderRotationalVelocityZeroCutoffExponent"] = "-5000",
	["LargeReplicatorWrite5"] = "true",
	["LargeReplicatorEnabled9"] = "true",
	["AngularVelociryLimit"] = "360",
	["TimestepArbiterVelocityCriteriaThresholdTwoDt"] = "2147483646",
	["S2PhysicsSenderRate"] = "15000",
	["DisableDPIScale"] = "true",
	["MaxDataPacketPerSend"] = "2147483647",
	["ServerMaxBandwith"] = "52",
	["PhysicsSenderMaxBandwidthBps"] = "20000",
	["MaxTimestepMultiplierBuoyancy"] = "2147483647",
	["SimOwnedNOUCountThresholdMillionth"] = "2147483647",
	["MaxMissedWorldStepsRemembered"] = "-2147483648",
	["CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth"] = "1",
	["StreamJobNOUVolumeLengthCap"] = "2147483647",
	["DebugSendDistInSteps"] = "-2147483648",
	["MaxTimestepMultiplierAcceleration"] = "2147483647",
	["LargeReplicatorRead5"] = "true",
	["SimExplicitlyCappedTimestepMultiplier"] = "2147483646",
	["GameNetDontSendRedundantNumTimes"] = "1",
	["CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent"] = "1",
	["CheckPVCachedRotVelThresholdPercent"] = "10",
	["LargeReplicatorSerializeRead3"] = "true",
	["ReplicationFocusNouExtentsSizeCutoffForPauseStuds"] = "2147483647",
	["NextGenReplicatorEnabledWrite4"] = "true",
	["CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth"] = "1",
	["GameNetDontSendRedundantDeltaPositionMillionth"] = "1",
	["InterpolationFrameVelocityThresholdMillionth"] = "5",
	["StreamJobNOUVolumeCap"] = "2147483647",
	["InterpolationFrameRotVelocityThresholdMillionth"] = "5",
	["WorldStepMax"] = "30",
	["TimestepArbiterHumanoidLinearVelThreshold"] = "1",
	["InterpolationFramePositionThresholdMillionth"] = "5",
	["TimestepArbiterHumanoidTurningVelThreshold"] = "1",
	["MaxTimestepMultiplierContstraint"] = "2147483647",
	["GameNetPVHeaderLinearVelocityZeroCutoffExponent"] = "-5000",
	["CheckPVCachedVelThresholdPercent"] = "10",
	["TimestepArbiterOmegaThou"] = "1073741823",
	["MaxAcceptableUpdateDelay"] = "1",
	["LargeReplicatorSerializeWrite4"] = "true",
}

local defaultFlags = {
	["GameNetPVHeaderRotationalVelocityZeroCutoffExponent"] = "0",
	["LargeReplicatorWrite5"] = "false",
	["LargeReplicatorEnabled9"] = "false",
	["AngularVelociryLimit"] = "360",
	["TimestepArbiterVelocityCriteriaThresholdTwoDt"] = "0",
	["S2PhysicsSenderRate"] = "20",
	["DisableDPIScale"] = "false",
	["MaxDataPacketPerSend"] = "750",
	["ServerMaxBandwith"] = "10",
	["PhysicsSenderMaxBandwidthBps"] = "20000",
	["MaxTimestepMultiplierBuoyancy"] = "8",
	["SimOwnedNOUCountThresholdMillionth"] = "1000000",
	["MaxMissedWorldStepsRemembered"] = "5",
	["CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth"] = "0",
	["StreamJobNOUVolumeLengthCap"] = "0",
	["DebugSendDistInSteps"] = "0",
	["MaxTimestepMultiplierAcceleration"] = "8",
	["LargeReplicatorRead5"] = "false",
	["SimExplicitlyCappedTimestepMultiplier"] = "8",
	["GameNetDontSendRedundantNumTimes"] = "0",
	["CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent"] = "0",
	["CheckPVCachedRotVelThresholdPercent"] = "0",
	["LargeReplicatorSerializeRead3"] = "false",
	["ReplicationFocusNouExtentsSizeCutoffForPauseStuds"] = "0",
	["NextGenReplicatorEnabledWrite4"] = "false",
	["CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth"] = "0",
	["GameNetDontSendRedundantDeltaPositionMillionth"] = "0",
	["InterpolationFrameVelocityThresholdMillionth"] = "0",
	["StreamJobNOUVolumeCap"] = "0",
	["InterpolationFrameRotVelocityThresholdMillionth"] = "0",
	["WorldStepMax"] = "16",
	["TimestepArbiterHumanoidLinearVelThreshold"] = "0",
	["InterpolationFramePositionThresholdMillionth"] = "0",
	["TimestepArbiterHumanoidTurningVelThreshold"] = "0",
	["MaxTimestepMultiplierContstraint"] = "8",
	["GameNetPVHeaderLinearVelocityZeroCutoffExponent"] = "0",
	["CheckPVCachedVelThresholdPercent"] = "0",
	["TimestepArbiterOmegaThou"] = "0",
	["MaxAcceptableUpdateDelay"] = "0",
	["LargeReplicatorSerializeWrite4"] = "false",
}

local function applyFlags(tbl)
	for name, value in pairs(tbl) do
		pcall(function()
			fenv.setfflag(name, value)
		end)
	end
end

-- Internal Logic Functions
local function EnableDesyncInternal()
    applyFlags(flags)
    pcall(function() fenv.gethidden(workspace, "RejectCharacterDeletions") end)
    pcall(function() fenv.replicatesignal(LocalPlayer.ConnectDiedSignalBackend) end)
    
    desyncKillThread = task.spawn(function()
        task.wait(0.1)
        if desyncEnabled then
            pcall(function() fenv.replicatesignal(LocalPlayer.Kill) end)
        end
    end)
end

local function DisableDesyncInternal()
    if desyncKillThread then task.cancel(desyncKillThread) end
    applyFlags(defaultFlags)
end

-- Bridge function for Config System and Visual Updates
local function SetDesyncState(state)
    desyncEnabled = state
    LibrarySettings["DesyncActive"] = state -- Update Config Setting

    -- Update Logic
    if state then
        EnableDesyncInternal()
    else
        DisableDesyncInternal()
    end

    -- Update Visuals if the specific GUI exists
    if desyncGUI then
        local main = desyncGUI:FindFirstChild("MainFrame")
        if main then
            local status = main:FindFirstChild("TextLabel", true) -- Lazy find for StatusLabel based on text, or direct name if available
            -- Specific elements from your provided code
            local toggleContainer = main:FindFirstChild("ToggleContainer")
            local statusLabel = nil
            -- Find the status label by iteration or name if we assigned one, checking text color logic
            for _, v in pairs(main:GetChildren()) do
                 if v:IsA("TextLabel") and v.Text:find("Status:") then
                     statusLabel = v
                     break
                 end
            end

            if toggleContainer then
                local track = toggleContainer:FindFirstChild("Track")
                local knob = track and track:FindFirstChild("Knob")
                
                if state then
                    if statusLabel then 
                        statusLabel.Text = "Status: ON"
                        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                    end
                    if track then TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 80, 180)}):Play() end
                    if knob then TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(1, -23, 0.5, 0)}):Play() end
                else
                    if statusLabel then 
                        statusLabel.Text = "Status: OFF"
                        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                    end
                    if track then TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play() end
                    if knob then TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, 0)}):Play() end
                end
            end
        end
    end
end

-- Register to Config System
ConfigurableItems["DesyncActive"] = SetDesyncState

local function ToggleDesyncGUI(guiState)
    if guiState then
        if CoreGui:FindFirstChild("DirmaDesync") then return end

        -- 2. UI CREATION (Your Specific Code)
        local DirmaDesync = Instance.new("ScreenGui")
        DirmaDesync.Name = "DirmaDesync"
        DirmaDesync.Parent = CoreGui
        DirmaDesync.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainFrame"
        MainFrame.Size = UDim2.new(0, 0, 0, 0) -- Animation start
        MainFrame.Position = UDim2.new(0.8, 0, 0.4, 0) -- Positioned to the right
        MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
        MainFrame.BorderSizePixel = 0
        MainFrame.Active = true
        MainFrame.Draggable = true -- Draggable
        MainFrame.Parent = DirmaDesync
        MainFrame.ClipsDescendants = true

        -- Animation
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 220, 0, 130)}):Play()

        local MainCorner = Instance.new("UICorner")
        MainCorner.CornerRadius = UDim.new(0, 10)
        MainCorner.Parent = MainFrame

        local MainStroke = Instance.new("UIStroke")
        MainStroke.Color = Color3.fromRGB(60, 60, 80)
        MainStroke.Thickness = 2
        MainStroke.Transparency = 0.5
        MainStroke.Parent = MainFrame

        -- Title Bar
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size = UDim2.new(1, 0, 0, 30)
        TitleLabel.Position = UDim2.new(0, 0, 0, 5)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = "Desync V2"
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextSize = 16
        TitleLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
        TitleLabel.Parent = MainFrame

        -- Status Text
        local StatusLabel = Instance.new("TextLabel")
        StatusLabel.Size = UDim2.new(1, 0, 0, 20)
        StatusLabel.Position = UDim2.new(0, 0, 0, 28)
        StatusLabel.BackgroundTransparency = 1
        StatusLabel.Text = "Status: OFF"
        StatusLabel.Font = Enum.Font.GothamMedium
        StatusLabel.TextSize = 12
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80) -- Red initially
        StatusLabel.Parent = MainFrame

        -- Toggle Container (The "Slider" Background)
        local ToggleContainer = Instance.new("Frame")
        ToggleContainer.Name = "ToggleContainer"
        ToggleContainer.Size = UDim2.new(0, 180, 0, 45)
        ToggleContainer.Position = UDim2.new(0.5, -90, 0, 60)
        ToggleContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        ToggleContainer.BorderSizePixel = 0
        ToggleContainer.Parent = MainFrame

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 8)
        ToggleCorner.Parent = ToggleContainer

        local ToggleStroke = Instance.new("UIStroke")
        ToggleStroke.Color = Color3.fromRGB(50, 50, 65)
        ToggleStroke.Thickness = 1
        ToggleStroke.Parent = ToggleContainer

        -- Actual Button (Invisible overlay for clicking)
        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
        ToggleBtn.BackgroundTransparency = 1
        ToggleBtn.Text = ""
        ToggleBtn.Parent = ToggleContainer

        -- The "Slider" Visuals
        local SliderTrack = Instance.new("Frame")
        SliderTrack.Name = "Track"
        SliderTrack.Size = UDim2.new(0, 60, 0, 26)
        SliderTrack.AnchorPoint = Vector2.new(1, 0.5)
        SliderTrack.Position = UDim2.new(0.95, 0, 0.5, 0)
        SliderTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        SliderTrack.Parent = ToggleContainer

        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = SliderTrack

        local SliderKnob = Instance.new("Frame")
        SliderKnob.Name = "Knob"
        SliderKnob.Size = UDim2.new(0, 20, 0, 20)
        SliderKnob.AnchorPoint = Vector2.new(0, 0.5)
        SliderKnob.Position = UDim2.new(0, 3, 0.5, 0)
        SliderKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        SliderKnob.Parent = SliderTrack

        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(1, 0)
        KnobCorner.Parent = SliderKnob

        -- Label inside the button area
        local BtnLabel = Instance.new("TextLabel")
        BtnLabel.Size = UDim2.new(0.5, 0, 1, 0)
        BtnLabel.Position = UDim2.new(0, 15, 0, 0)
        BtnLabel.BackgroundTransparency = 1
        BtnLabel.Text = "Activate"
        BtnLabel.Font = Enum.Font.GothamBold
        BtnLabel.TextSize = 14
        BtnLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
        BtnLabel.TextXAlignment = Enum.TextXAlignment.Left
        BtnLabel.Parent = ToggleContainer

        -- Assign global reference
        desyncGUI = DirmaDesync

        -- Set initial visual state based on logic variable
        SetDesyncState(desyncEnabled)

        -- Interaction logic
        ToggleBtn.MouseButton1Click:Connect(function()
            -- Toggle State
            SetDesyncState(not desyncEnabled)
        end)

    else
        if desyncGUI then desyncGUI:Destroy(); desyncGUI = nil end
        if CoreGui:FindFirstChild("DirmaDesync") then CoreGui.DirmaDesync:Destroy() end
    end
end

-- Main Toggle in Dirma Hub
CreateToggle(ExtraPage, "Desync (Patched)", function(state)
    ToggleDesyncGUI(state)
end)


-- ================= VISUAL TAB ================= --
CreateSection(VisualPage, "Environment")

-- Anti Bee & Disco (Toggle with Logic from EZZY HUB)
CreateToggle(VisualPage, "Anti Bee & Disco (Fix)", function(state)
    if state then
        ANTI_BEE_DISCO.Enable()
        StatusLabel.Text = "Anti Bee: ON"
    else
        ANTI_BEE_DISCO.Disable()
        StatusLabel.Text = "Anti Bee: OFF"
    end
end)

-- [FIXED] X-Ray Bases Logic (With Attribute Restore + Auto-Add)
local XRayConnection = nil
CreateToggle(VisualPage, "X-Ray Bases", function(state)
    if state then
        -- Function to apply XRay to a single part
        local function applyXRay(part)
            if part:IsA("BasePart") and part.Name:lower():find("base") then
                -- Save Original State if not saved yet
                if part:GetAttribute("DirmaOgTrans") == nil then
                    part:SetAttribute("DirmaOgTrans", part.Transparency)
                    part:SetAttribute("DirmaOgShadow", part.CastShadow)
                end
                -- Apply Effect
                part.Transparency = 0.7
                part.CastShadow = false
            end
        end

        -- Apply to existing
        for _, v in pairs(Workspace:GetDescendants()) do
            applyXRay(v)
        end

        -- Listen for new parts (Tycoon upgrades)
        XRayConnection = Workspace.DescendantAdded:Connect(applyXRay)
    else
        -- Disable Connection
        if XRayConnection then XRayConnection:Disconnect() XRayConnection = nil end

        -- Restore
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part:GetAttribute("DirmaOgTrans") then
                part.Transparency = part:GetAttribute("DirmaOgTrans")
                part.CastShadow = part:GetAttribute("DirmaOgShadow")
                -- Clean up attributes so we can re-save next time
                part:SetAttribute("DirmaOgTrans", nil)
                part:SetAttribute("DirmaOgShadow", nil)
            end
        end
    end
end)

-- Remove Accessories -> Toggle for Config Saving
local loopRemoveAccs = false
local removeAccsThread = nil
CreateToggle(VisualPage, "Auto Remove Accessories", function(state)
    loopRemoveAccs = state
    if state then
        -- Immediate Clean
        local function clean()
            if LocalPlayer.Character then
                for _, v in pairs(LocalPlayer.Character:GetChildren()) do
                    if v:IsA("Accessory") then v:Destroy() end
                end
            end
        end
        clean()
        
        -- Start loop for persistence
        if removeAccsThread then task.cancel(removeAccsThread) end
        removeAccsThread = task.spawn(function()
            while loopRemoveAccs do
                clean()
                task.wait(1)
            end
        end)
    else
        if removeAccsThread then task.cancel(removeAccsThread); removeAccsThread = nil end
    end
end)

CreateSection(VisualPage, "ESP")

-- Player ESP
local playerEspEnabled = false
local espBoxFolder = Instance.new("Folder", CoreGui)
espBoxFolder.Name = "DirmaESP_Boxes"
local function UpdatePlayerESP()
    espBoxFolder:ClearAllChildren()
    if not playerEspEnabled then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hl = Instance.new("Highlight")
            hl.Adornee = plr.Character
            hl.FillColor = Color3.fromRGB(128, 0, 128)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.Parent = espBoxFolder
            local bb = Instance.new("BillboardGui")
            bb.Adornee = plr.Character.Head
            bb.Size = UDim2.new(0, 100, 0, 30)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.AlwaysOnTop = true
            bb.Parent = espBoxFolder
            local txt = Instance.new("TextLabel")
            txt.Parent = bb
            txt.Size = UDim2.new(1,0,1,0)
            txt.BackgroundTransparency = 1
            txt.Text = plr.DisplayName
            txt.TextColor3 = Color3.fromRGB(255, 0, 255)
            txt.TextStrokeTransparency = 0
        end
    end
end
CreateToggle(VisualPage, "Player ESP", function(state)
    playerEspEnabled = state
    if state then UpdatePlayerESP(); task.spawn(function() while playerEspEnabled do UpdatePlayerESP(); task.wait(5) end espBoxFolder:ClearAllChildren() end) else espBoxFolder:ClearAllChildren() end
end)

-- ==========================================================
-- BASE / SPAWN ESP (RESPAWN + FREEZE LOGIC)
-- ==========================================================
local baseEspEnabled = false
local baseEspTargetPart = nil
local currentBasePos = nil 
local charAddedConnection = nil

local function UpdateBaseVisuals()
    if not currentBasePos then return end

    -- Create Visual Target Part if it doesn't exist
    if not baseEspTargetPart then
        baseEspTargetPart = Instance.new("Part")
        baseEspTargetPart.Name = "DirmaBaseTarget"
        baseEspTargetPart.Size = Vector3.new(1,1,1)
        baseEspTargetPart.Anchored = true
        baseEspTargetPart.CanCollide = false
        baseEspTargetPart.Transparency = 1
        baseEspTargetPart.Parent = Workspace
        
        local att1 = Instance.new("Attachment", baseEspTargetPart)
        local beam = Instance.new("Beam", baseEspTargetPart)
        beam.Attachment1 = att1
        beam.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 100)), -- Green at Player
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 50, 50))  -- Red at Base
        })
        beam.Width0 = 0.3
        beam.Width1 = 0.3
        beam.FaceCamera = true
        beam.TextureSpeed = 1
        beam.TextureLength = 5
        
        -- Visual marker at captured point
        local marker = Instance.new("Part")
        marker.Name = "SpawnMarker"
        marker.Size = Vector3.new(2, 2, 2)
        marker.Shape = Enum.PartType.Ball
        marker.BrickColor = BrickColor.new("Bright green")
        marker.Material = Enum.Material.Neon
        marker.Anchored = true
        marker.CanCollide = false
        marker.Transparency = 0.5
        marker.Parent = baseEspTargetPart
        
        local markerTween = TweenService:Create(marker, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.8})
        markerTween:Play()
    end
    
    -- Set the visual marker to the captured position
    baseEspTargetPart.Position = currentBasePos

    -- Link beam to player's current HumanoidRootPart
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local beam = baseEspTargetPart and baseEspTargetPart:FindFirstChild("Beam")
    
    if hrp and beam then
        local att0 = hrp:FindFirstChild("DirmaBeamAtt")
        if not att0 then
            att0 = Instance.new("Attachment", hrp)
            att0.Name = "DirmaBeamAtt"
        end
        beam.Attachment0 = att0
        beam.Enabled = true
    elseif beam then
        beam.Enabled = false
    end
end

-- Function to handle spawn logic: Freeze -> Wait -> Capture -> Unfreeze
local function HandleSpawn(char)
    if not baseEspEnabled then return end
    
    -- Wait for RootPart
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if not hrp then return end

    -- 1. FREEZE PLAYER
    hrp.Anchored = true
    
    -- 2. WAIT 1 SECOND
    task.wait(1)
    
    -- Check if still enabled (user might have toggled off during wait)
    if not baseEspEnabled then 
        hrp.Anchored = false 
        return 
    end
    
    -- 3. CAPTURE POSITION & UNFREEZE
    if char and char:FindFirstChild("HumanoidRootPart") then
        currentBasePos = char.HumanoidRootPart.Position
        char.HumanoidRootPart.Anchored = false -- Unfreeze
        UpdateBaseVisuals()
    end
end

local function ToggleBaseESP(state)
    baseEspEnabled = state
    
    if state then
        -- 1. KILL PLAYER TO FORCE RESPAWN
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.Health = 0 end
        end
        
        -- 2. LISTEN FOR SPAWN
        charAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
            HandleSpawn(newChar)
        end)
        
        -- Loop to keep the beam attached if you reset character manually later
        task.spawn(function()
            while baseEspEnabled do
                UpdateBaseVisuals()
                task.wait(1)
            end
        end)
    else
        -- Cleanup
        if charAddedConnection then charAddedConnection:Disconnect() end
        if baseEspTargetPart then baseEspTargetPart:Destroy(); baseEspTargetPart = nil end
        currentBasePos = nil
    end
end

CreateToggle(VisualPage, "Base ESP (Respawn + 1s Freeze)", function(state) ToggleBaseESP(state) end)

----------------------------------------------------------------
-- BRAINROT / BEST PET ESP (INTEGRATED & UPDATED)
----------------------------------------------------------------
local brainrotActive = false
local brainrotLoop = nil
local currentBrainrotESP = nil
local currentBrainrotHL = nil -- New variable for highlight

-- Logic from your provided script (Parse Value)
local function parseValue(text)
    text = tostring(text or ""):gsub("%s", "")
    local num, suffix = text:match("([%d%.]+)([KkMmBbTt]?)")
    if not num then return 0 end
    num = tonumber(num) or 0
    local multipliers = {K=1e3, M=1e6, B=1e9, T=1e12}
    local mult = multipliers[(suffix or ""):upper()] or 1
    return num * mult
end

-- Logic to create the visual (Adapted from your script)
-- [UPDATED] Added Outline (Highlight) to the MODEL/PART
local function createBrainrotVisual(part, displayText, valueText)
    -- Cleanup old highlight if adornee changed or just refresh
    if currentBrainrotESP then pcall(function() currentBrainrotESP:Destroy() end) end
    
    -- If we have a highlight, check if it's still valid/parented to correct part
    if currentBrainrotHL then 
        if currentBrainrotHL.Parent ~= part then
             pcall(function() currentBrainrotHL:Destroy() end)
             currentBrainrotHL = nil
        end
    end

    if not part then return end

    -- Create Outline (Highlight) inside the part
    if not currentBrainrotHL then
        local hl = Instance.new("Highlight")
        hl.Name = "BestPetHighlight"
        hl.FillColor = Color3.fromRGB(0, 255, 0) -- Green fill
        hl.FillTransparency = 0.8 -- Less intrusive fill
        hl.OutlineColor = Color3.fromRGB(0, 0, 0) -- Black outline
        hl.OutlineTransparency = 0
        hl.Parent = part -- Parent DIRECTLY to the part/model
        currentBrainrotHL = hl
    end

    -- Create Text (Billboard)
    local bb = Instance.new("BillboardGui")
    bb.Name = "BestPetESP"
    bb.Size = UDim2.new(0, 200, 0, 50)
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.Adornee = part
    bb.Parent = CoreGui

    local name = Instance.new("TextLabel", bb)
    name.Size = UDim2.new(1, 0, 0, 25)
    name.BackgroundTransparency = 1
    name.TextScaled = true
    name.Font = Enum.Font.GothamBold
    name.Text = displayText
    name.TextColor3 = Color3.fromRGB(255, 255, 0)
    name.TextStrokeTransparency = 0
    name.TextStrokeColor3 = Color3.new(0,0,0)

    local value = Instance.new("TextLabel", bb)
    value.Size = UDim2.new(1, 0, 0, 25)
    value.Position = UDim2.new(0, 0, 0, 25)
    value.BackgroundTransparency = 1
    value.TextScaled = true
    value.Font = Enum.Font.GothamBold
    value.Text = valueText
    value.TextColor3 = Color3.fromRGB(0, 255, 100)
    value.TextStrokeTransparency = 0
    value.TextStrokeColor3 = Color3.new(0,0,0)

    currentBrainrotESP = bb
end

-- Main Loop (Adapted from your script)
local function startBrainrotESP()
    if brainrotLoop then task.cancel(brainrotLoop) end
    brainrotLoop = task.spawn(function()
        while brainrotActive do
            local debris = Workspace:FindFirstChild("Debris")
            if not debris then task.wait(0.5) continue end
            
            local bestPet = {value = -1, part = nil, text = "", display = "", template = nil}
            
            -- Search all FastOverheadTemplate in Debris
            for _, template in ipairs(debris:GetChildren()) do
                if template.Name == "FastOverheadTemplate" then
                    local surfaceGui = template:FindFirstChildOfClass("SurfaceGui")
                    if surfaceGui then
                        local genLabel = surfaceGui:FindFirstChild("Generation", true)
                        if genLabel and genLabel:IsA("TextLabel") then
                            local text = genLabel.Text or ""
                            if text ~= "" and (text:find("/s") or text:find("K") or text:find("M") or text:find("B")) then
                                local val = parseValue(text)
                                if val > bestPet.value then
                                    local targetPart = surfaceGui.Adornee
                                    if targetPart and targetPart:IsA("BasePart") then
                                        local displayName = surfaceGui:FindFirstChild("DisplayName", true)
                                        bestPet = {
                                            part = targetPart,
                                            value = val,
                                            text = text,
                                            display = displayName and displayName.Text or "Pet",
                                            template = template
                                        }
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            -- Update Visuals
            if bestPet.part and bestPet.part.Parent then
                createBrainrotVisual(bestPet.part, bestPet.display, bestPet.text)
            else
                if currentBrainrotESP then currentBrainrotESP:Destroy() currentBrainrotESP = nil end
                if currentBrainrotHL then currentBrainrotHL:Destroy() currentBrainrotHL = nil end
            end
            
            task.wait(0.5)
        end
        
        -- Cleanup when loop stops
        if currentBrainrotESP then pcall(function() currentBrainrotESP:Destroy() end) currentBrainrotESP = nil end
        if currentBrainrotHL then pcall(function() currentBrainrotHL:Destroy() end) currentBrainrotHL = nil end
    end)
end

CreateToggle(VisualPage, "Best Pet ESP (Outline + Text)", function(state)
    brainrotActive = state
    if state then
        startBrainrotESP()
    else
        if brainrotLoop then task.cancel(brainrotLoop) end
        if currentBrainrotESP then currentBrainrotESP:Destroy() end
        if currentBrainrotHL then currentBrainrotHL:Destroy() end
    end
end)

-- ================= SERVER TAB ================= --
CreateSection(ServerPage, "Current Server")
CreateButton(ServerPage, "Copy Server Job ID", function()
    if setclipboard then
        setclipboard(game.JobId)
        StatusLabel.Text = "Job ID Copied to Clipboard!"
        task.wait(2)
        StatusLabel.Text = "Press [LCTRL] to Toggle UI"
    else
        StatusLabel.Text = "Your executor does not support clipboard."
    end
end)

CreateButton(ServerPage, "Rejoin Server", function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

CreateButton(ServerPage, "Server Hop", function()
    StatusLabel.Text = "Searching for a server..."
    local servers = {}
    local req = request or http_request or (syn and syn.request)
    local body = nil
    
    if req then
        pcall(function()
            local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
            local response = req({Url = url, Method = "GET"})
            body = HttpService:JSONDecode(response.Body)
        end)
    end

    if body and body.data then
        for _, s in ipairs(body.data) do
            if type(s) == "table" and s.maxPlayers > s.playing and s.id ~= game.JobId then
                servers[#servers+1] = s.id
            end
        end
    end

    if #servers > 0 then
        StatusLabel.Text = "Hopping..."
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
    else
        StatusLabel.Text = "Couldn't find a server."
    end
end)

-- [ADDED] ANTI ERROR LOGIC
local antiErrorLoop = nil
CreateToggle(ServerPage, "Anti Error", function(state)
    if state then
        antiErrorLoop = task.spawn(function()
            while true do
                GuiService:ClearError()
                task.wait(0.01)
            end
        end)
        StatusLabel.Text = "Anti Error: ON"
    else
        if antiErrorLoop then task.cancel(antiErrorLoop); antiErrorLoop = nil end
        StatusLabel.Text = "Anti Error: OFF"
    end
end)

CreateSection(ServerPage, "Join Specific Server")
local targetJobId = ""
CreateInput(ServerPage, "Paste Job ID here...", function(text)
    targetJobId = text
end)

CreateButton(ServerPage, "Join to Job ID", function()
    if targetJobId and targetJobId ~= "" then
        StatusLabel.Text = "Attempting to join..."
        TeleportService:TeleportToPlaceInstance(game.PlaceId, targetJobId, LocalPlayer)
    else
        StatusLabel.Text = "Please enter a valid Job ID."
    end
end)


-- ================= INVALID TAB (KOLYASKA) ================= --
-- Encapsulated Logic for "Invalidnaya Kolyaska"

CreateSection(InvalidPage, "Invalidnaya Kolyaska")

-- Variables for Kolyaska
local kolyaska_gui = nil
local savedPositions = { [1]=nil,[2]=nil,[3]=nil,[4]=nil }
local walkingCoroutine = nil
local isWalking = false
local stopWalkingFlag = false
local walkSpeed = 16
local wheelchairModel = nil
local poseConnection = nil
local animStopConnection = nil
local originalC0s = {}
local ConfigName = "DirmaKolyaska.json"
local keybindConn = nil
local charAddConn = nil

-- Helpers
local function getChar() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end

local function SaveConfig()
    local data = { Positions = {}, WalkSpeed = walkSpeed }
    for i,pos in pairs(savedPositions) do
        if pos then data.Positions[tostring(i)] = {X=pos.X,Y=pos.Y,Z=pos.Z} end
    end
    if writefile then pcall(function() writefile(ConfigName, HttpService:JSONEncode(data)) end) end
end

local function LoadConfig()
    if isfile and isfile(ConfigName) then
        local ok,content = pcall(readfile, ConfigName)
        if ok then
            local ok2,decoded = pcall(HttpService.JSONDecode, HttpService, content)
            if ok2 and decoded then
                if decoded.Positions then
                    for i,data in pairs(decoded.Positions) do savedPositions[tonumber(i)] = Vector3.new(data.X,data.Y,data.Z) end
                end
                if decoded.WalkSpeed then walkSpeed = decoded.WalkSpeed end
            end
        end
    end
end

local function restoreOriginalPose()
    if not originalC0s then return end
    for motor, c0 in pairs(originalC0s) do
        if motor and motor.Parent then motor.C0 = c0 end
    end
    originalC0s = {}
end

local function cleanOldVisuals()
    if poseConnection then poseConnection:Disconnect() poseConnection = nil end
    if animStopConnection then animStopConnection:Disconnect() animStopConnection = nil end
    restoreOriginalPose()
    if wheelchairModel then wheelchairModel:Destroy() wheelchairModel = nil end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = 16
        char.Humanoid.PlatformStand = false
        char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

local function applyPoseLogic(char)
    local hum = char:FindFirstChild("Humanoid")
    local function getMotor(partName, motorName)
        local part = char:FindFirstChild(partName)
        if part then return part:FindFirstChild(motorName) end
        return nil
    end

    local motors = {
        Waist = getMotor("UpperTorso", "Waist") or getMotor("Torso", "Waist"),
        Neck = getMotor("Head", "Neck"),
        RHip = getMotor("RightUpperLeg", "RightHip") or getMotor("Right Leg", "Right Hip"),
        LHip = getMotor("LeftUpperLeg", "LeftHip") or getMotor("Left Leg", "Left Hip"),
        RKnee = getMotor("RightLowerLeg", "RightKnee"),
        LKnee = getMotor("LeftLowerLeg", "LeftKnee"),
        RShou = getMotor("RightUpperArm", "RightShoulder") or getMotor("Right Arm", "Right Shoulder"),
        LShou = getMotor("LeftUpperArm", "LeftShoulder") or getMotor("Left Arm", "Left Shoulder"),
    }

    originalC0s = {}
    for _, motor in pairs(motors) do if motor then originalC0s[motor] = motor.C0 end end

    animStopConnection = RunService.Stepped:Connect(function()
        if not wheelchairModel or not hum then return end
        for _, track in pairs(hum:GetPlayingAnimationTracks()) do
            if track.Priority == Enum.AnimationPriority.Core or track.Priority == Enum.AnimationPriority.Movement then
                track:AdjustWeight(0.001)
            end
        end
    end)

    poseConnection = RunService.Stepped:Connect(function()
        if not wheelchairModel then return end
        if motors.Waist then motors.Waist.C0 = originalC0s[motors.Waist] * CFrame.Angles(math.rad(-15), 0, 0) end
        if motors.Neck then motors.Neck.C0 = originalC0s[motors.Neck] * CFrame.Angles(math.rad(10), 0, 0) end
        if motors.RHip then motors.RHip.C0 = originalC0s[motors.RHip] * CFrame.Angles(math.rad(90), math.rad(-5), 0) end
        if motors.LHip then motors.LHip.C0 = originalC0s[motors.LHip] * CFrame.Angles(math.rad(90), math.rad(5), 0) end
        if motors.RKnee then motors.RKnee.C0 = originalC0s[motors.RKnee] * CFrame.Angles(math.rad(-90), 0, 0) end
        if motors.LKnee then motors.LKnee.C0 = originalC0s[motors.LKnee] * CFrame.Angles(math.rad(-90), 0, 0) end
        if motors.RShou then motors.RShou.C0 = originalC0s[motors.RShou] * CFrame.new(0, -0.2, -0.4) * CFrame.Angles(math.rad(20), 0, math.rad(-15)) end
        if motors.LShou then motors.LShou.C0 = originalC0s[motors.LShou] * CFrame.new(0, -0.2, -0.4) * CFrame.Angles(math.rad(20), 0, math.rad(15)) end
    end)
end

local function createWheelchairVisual()
    cleanOldVisuals()
    local char = getChar()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    wheelchairModel = Instance.new("Model")
    wheelchairModel.Name = "DirmaWheelchair_Visual"

    local function makePart(size, color, cfOffset, shape, material)
        local p = Instance.new("Part")
        p.Size = size; p.Color = color; p.Material = material or Enum.Material.Metal
        p.Anchored = false; p.CanCollide = false; p.CanQuery = false; p.Massless = true
        if shape then p.Shape = shape end
        p.Parent = wheelchairModel
        local w = Instance.new("WeldConstraint"); w.Part0 = root; w.Part1 = p; w.Parent = p
        p.CFrame = root.CFrame * cfOffset
        return p
    end

    local black = Color3.fromRGB(20,20,20)
    local seatColor = Color3.fromRGB(40,40,45)
    local silver = Color3.fromRGB(170,170,170)
    local heightOffset = -1.2 

    makePart(Vector3.new(2.2, 0.2, 2.2), seatColor, CFrame.new(0, heightOffset - 1.2, 0), Enum.PartType.Block, Enum.Material.Fabric)
    makePart(Vector3.new(2.2, 2.5, 0.2), seatColor, CFrame.new(0, heightOffset, 1.1), Enum.PartType.Block, Enum.Material.Fabric)
    makePart(Vector3.new(0.4, 3.2, 3.2), black, CFrame.new(-1.6, heightOffset - 1.0, 0.2), Enum.PartType.Cylinder)
    makePart(Vector3.new(0.4, 3.2, 3.2), black, CFrame.new( 1.6, heightOffset - 1.0, 0.2), Enum.PartType.Cylinder)
    makePart(Vector3.new(0.42, 2.5, 2.5), silver, CFrame.new(-1.6, heightOffset - 1.0, 0.2), Enum.PartType.Cylinder)
    makePart(Vector3.new(0.42, 2.5, 2.5), silver, CFrame.new( 1.6, heightOffset - 1.0, 0.2), Enum.PartType.Cylinder)
    makePart(Vector3.new(0.2, 0.2, 2.0), black, CFrame.new(-1.2, heightOffset - 0.4, 0))
    makePart(Vector3.new(0.2, 0.2, 2.0), black, CFrame.new( 1.2, heightOffset - 0.4, 0))
    makePart(Vector3.new(0.15, 1.2, 0.15), silver, CFrame.new(-1.2, heightOffset - 1.0, 0.8))
    makePart(Vector3.new(0.15, 1.2, 0.15), silver, CFrame.new( 1.2, heightOffset - 1.0, 0.8))
    makePart(Vector3.new(0.3, 1.0, 1.0), black, CFrame.new(-1.0, heightOffset - 2.1, -1.4), Enum.PartType.Cylinder)
    makePart(Vector3.new(0.3, 1.0, 1.0), black, CFrame.new( 1.0, heightOffset - 2.1, -1.4), Enum.PartType.Cylinder)
    makePart(Vector3.new(0.1, 1.2, 0.1), silver, CFrame.new(-1.0, heightOffset - 1.6, -1.4))
    makePart(Vector3.new(0.1, 1.2, 0.1), silver, CFrame.new( 1.0, heightOffset - 1.6, -1.4))

    wheelchairModel.Parent = workspace
    applyPoseLogic(char)
end

local function stopWalking(statusLabel, reason)
    stopWalkingFlag = true
    isWalking = false
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then char.Humanoid:MoveTo(char.HumanoidRootPart.Position) end
    cleanOldVisuals()
    if statusLabel then
        statusLabel.Text = reason or "ОСТАНОВЛЕНО"
        statusLabel.TextColor3 = reason and Color3.fromRGB(255,100,100) or Color3.fromRGB(200,200,200)
    end
end

local function walkToSinglePosition(index, statusLabel)
    if not savedPositions[index] then return end
    if walkingCoroutine then stopWalkingFlag = true task.wait(0.1) end

    walkingCoroutine = task.spawn(function()
        stopWalkingFlag = false; isWalking = true
        local char = getChar(); local hum = char:FindFirstChildOfClass("Humanoid")
        hum.WalkSpeed = walkSpeed; hum.AutoRotate = true
        createWheelchairVisual()
        local target = savedPositions[index]
        statusLabel.Text = "ИДЁМ К ПОЗИЦИИ "..index; statusLabel.TextColor3 = Color3.fromRGB(100,150,255)
        hum:MoveTo(target)
        while not stopWalkingFlag do
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then break end
            if (hum.WalkToPoint - target).Magnitude > 2 then hum:MoveTo(target) end
            if (hrp.Position - target).Magnitude < 3 then break end
            task.wait(0.1)
        end
        if not stopWalkingFlag then statusLabel.Text = "ПРИБЫЛИ НА "..index; statusLabel.TextColor3 = Color3.fromRGB(150,220,150) end
        cleanOldVisuals(); isWalking = false
    end)
end

local function walkThroughAllPositions(statusLabel)
    if walkingCoroutine then stopWalkingFlag = true task.wait(0.1) end
    walkingCoroutine = task.spawn(function()
        stopWalkingFlag = false; isWalking = true
        local char = getChar(); local hum = char:FindFirstChildOfClass("Humanoid")
        hum.WalkSpeed = walkSpeed; createWheelchairVisual()
        for i=1,4 do
            if stopWalkingFlag then break end
            if savedPositions[i] then
                local target = savedPositions[i]
                statusLabel.Text = "♿ ПУТЬ К ТОЧКЕ "..i; statusLabel.TextColor3 = Color3.fromRGB(180,80,180)
                hum:MoveTo(target)
                local stuckT = 0
                while not stopWalkingFlag do
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if not hrp then break end
                    if (hrp.Position - target).Magnitude < 3 then break end
                    if hrp.Velocity.Magnitude < 0.2 then stuckT = stuckT + 0.1; if stuckT > 2 then hum:MoveTo(target) stuckT = 0 end end
                    task.wait(0.1)
                end
                if stopWalkingFlag then break end
                statusLabel.Text = "ТОЧКА "..i.." ПРОЙДЕНА"; task.wait(0.2)
            end
        end
        cleanOldVisuals(); isWalking = false
        if not stopWalkingFlag then statusLabel.Text = "МАРШРУТ ОКОНЧЕН"; statusLabel.TextColor3 = Color3.fromRGB(255,200,100) end
    end)
end

local function ToggleKolyaska(state)
    if state then
        -- Load
        LoadConfig()
        if kolyaska_gui then kolyaska_gui:Destroy() end
        
        -- Create UI
        local kgui = Instance.new("ScreenGui")
        kgui.Name = "DirmaKolyaskaUI"; kgui.ResetOnSpawn = false; kgui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        pcall(function() kgui.Parent = CoreGui end)
        
        local KFrame = Instance.new("Frame", kgui); KFrame.Size = UDim2.new(0, 0, 0, 0); KFrame.Position = UDim2.new(0.5, -140, 0.5, -210); KFrame.BackgroundColor3 = Color3.fromRGB(18,18,24); KFrame.Active = true; KFrame.Draggable = true
        KFrame.ClipsDescendants = true
        
        TweenService:Create(KFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 280, 0, 420)}):Play()
        
        local KCorner = Instance.new("UICorner", KFrame); KCorner.CornerRadius = UDim.new(0,10)
        local KStroke = Instance.new("UIStroke", KFrame); KStroke.Color = Color3.fromRGB(40,40,50); KStroke.Thickness = 1; KStroke.Transparency = 0.5
        local KTop = Instance.new("Frame", KFrame); KTop.Size = UDim2.new(1,0,0,40); KTop.BackgroundColor3 = Color3.fromRGB(22,22,30); Instance.new("UICorner", KTop).CornerRadius = UDim.new(0,10)
        local KTitle = Instance.new("TextLabel", KTop); KTitle.Size = UDim2.new(0.8,0,1,0); KTitle.Position = UDim2.new(0.05,0,0,0); KTitle.BackgroundTransparency = 1; KTitle.Text = "♿ INVALIDNAYA KOLYASKA"; KTitle.Font = Enum.Font.GothamBold; KTitle.TextColor3 = Color3.fromRGB(200,200,210); KTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        local KContent = Instance.new("Frame", KFrame); KContent.Size = UDim2.new(1,-20,1,-50); KContent.Position = UDim2.new(0,10,0,46); KContent.BackgroundTransparency = 1
        local KStatus = Instance.new("TextLabel", KContent); KStatus.Size = UDim2.new(1,0,0,25); KStatus.BackgroundTransparency = 1; KStatus.Text = "STATUS: READY"; KStatus.Font = Enum.Font.Gotham; KStatus.TextSize = 12; KStatus.TextColor3 = Color3.fromRGB(140,140,150)
        
        local PosSection = Instance.new("Frame", KContent); PosSection.Size = UDim2.new(1,0,0,200); PosSection.Position = UDim2.new(0,0,0,30); PosSection.BackgroundColor3 = Color3.fromRGB(25,25,32); PosSection.BackgroundTransparency = 0.2; Instance.new("UICorner", PosSection).CornerRadius = UDim.new(0,8)
        
        local positionLabels = {}
        for i = 1,4 do
            local y = 30 + (i-1)*42
            local setBtn = Instance.new("TextButton", PosSection); setBtn.Size = UDim2.new(0,60,0,35); setBtn.Position = UDim2.new(0,10,0,y); setBtn.BackgroundColor3 = Color3.fromRGB(40,60,40); setBtn.Text = "SET "..i; setBtn.TextColor3 = Color3.fromRGB(150,220,150); setBtn.Font = Enum.Font.GothamBold; setBtn.TextSize = 11; Instance.new("UICorner", setBtn).CornerRadius = UDim.new(0,6)
            local goBtn = Instance.new("TextButton", PosSection); goBtn.Size = UDim2.new(0,50,0,35); goBtn.Position = UDim2.new(0,75,0,y); goBtn.BackgroundColor3 = Color3.fromRGB(40,40,60); goBtn.Text = "GO"; goBtn.TextColor3 = Color3.fromRGB(150,150,220); goBtn.Font = Enum.Font.GothamBold; goBtn.TextSize = 11; Instance.new("UICorner", goBtn).CornerRadius = UDim.new(0,6)
            local label = Instance.new("TextLabel", PosSection); label.Size = UDim2.new(0,110,0,35); label.Position = UDim2.new(0,130,0,y); label.BackgroundColor3 = Color3.fromRGB(30,30,38); label.Text = "НЕ ЗАДАНО"; label.TextColor3 = Color3.fromRGB(120,120,130); label.Font = Enum.Font.Gotham; label.TextSize = 9; Instance.new("UICorner", label).CornerRadius = UDim.new(0,6)
            positionLabels[i] = label
            setBtn.MouseButton1Click:Connect(function()
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then savedPositions[i] = hrp.Position; label.Text = string.format("%.0f, %.0f, %.0f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z); label.TextColor3 = Color3.fromRGB(150,220,150); SaveConfig() end
            end)
            goBtn.MouseButton1Click:Connect(function() walkToSinglePosition(i, KStatus) end)
            if savedPositions[i] then local p = savedPositions[i]; label.Text = string.format("%.0f, %.0f, %.0f", p.X,p.Y,p.Z); label.TextColor3 = Color3.fromRGB(150,220,150) end
        end
        
        local ControlSection = Instance.new("Frame", KContent); ControlSection.Size = UDim2.new(1,0,0,120); ControlSection.Position = UDim2.new(0,0,0,240); ControlSection.BackgroundColor3 = Color3.fromRGB(25,25,32); ControlSection.BackgroundTransparency = 0.2; Instance.new("UICorner", ControlSection).CornerRadius = UDim.new(0,8)
        local NextPosBtn = Instance.new("TextButton", ControlSection); NextPosBtn.Size = UDim2.new(0.9,0,0,35); NextPosBtn.Position = UDim2.new(0.05,0,0,30); NextPosBtn.BackgroundColor3 = Color3.fromRGB(60,40,60); NextPosBtn.Text = "➡️ ПРОЙТИ ПО 1–4 (G)"; NextPosBtn.Font = Enum.Font.GothamBold; NextPosBtn.TextColor3 = Color3.fromRGB(220,150,220); Instance.new("UICorner", NextPosBtn).CornerRadius = UDim.new(0,6)
        local ClearBtn = Instance.new("TextButton", ControlSection); ClearBtn.Size = UDim2.new(0.9,0,0,30); ClearBtn.Position = UDim2.new(0.05,0,0,75); ClearBtn.BackgroundColor3 = Color3.fromRGB(60,35,35); ClearBtn.Text = "🗑️ СБРОСИТЬ ВСЕ"; ClearBtn.Font = Enum.Font.GothamMedium; ClearBtn.TextColor3 = Color3.fromRGB(220,120,120); Instance.new("UICorner", ClearBtn).CornerRadius = UDim.new(0,6)
        
        NextPosBtn.MouseButton1Click:Connect(function() walkThroughAllPositions(KStatus) end)
        ClearBtn.MouseButton1Click:Connect(function() for i=1,4 do savedPositions[i] = nil; positionLabels[i].Text = "НЕ ЗАДАНО"; positionLabels[i].TextColor3 = Color3.fromRGB(120,120,130) end; SaveConfig() end)
        
        keybindConn = UserInputService.InputBegan:Connect(function(input,gpe)
            if gpe then return end
            if input.KeyCode == Enum.KeyCode.G then walkThroughAllPositions(KStatus) end
            if input.KeyCode == Enum.KeyCode.H then stopWalking(KStatus, "СТОП КНОПКОЙ") end
        end)
        
        charAddConn = LocalPlayer.CharacterAdded:Connect(function() cleanOldVisuals(); isWalking = false; stopWalkingFlag = true end)
        
        kolyaska_gui = kgui
    else
        -- Unload
        if kolyaska_gui then kolyaska_gui:Destroy(); kolyaska_gui = nil end
        if keybindConn then keybindConn:Disconnect(); keybindConn = nil end
        if charAddConn then charAddConn:Disconnect(); charAddConn = nil end
        stopWalking(nil, nil)
    end
end

CreateToggle(InvalidPage, "Open Kolyaska Menu", function(state)
    ToggleKolyaska(state)
end)


-- ================= CONFIGS TAB ================= --
-- Logic for Save/Load
local currentConfigName = ""
local selectedConfigFile = nil

CreateSection(ConfigPage, "Manage Configs")
CreateInput(ConfigPage, "Config Name", function(text)
    currentConfigName = text
end)

local function SaveConfig(name)
    if not name or name == "" then StatusLabel.Text = "Enter a config name!"; return end
    if not writefile then StatusLabel.Text = "Exploit missing file support!"; return end
    
    -- Strip extension if user added it
    if name:lower():sub(-5) == ".json" then
        name = name:sub(1, -6)
    end

    local json = HttpService:JSONEncode(LibrarySettings)
    writefile(ConfigFolder .. "/" .. name .. ".json", json)
    StatusLabel.Text = "Saved config: " .. name
end

local function LoadConfig(name)
    if not name or name == "" then return end
    if not isfile then return end
    local path = ConfigFolder .. "/" .. name .. ".json"
    
    print("Attempting to load:", path) 
    
    if isfile(path) then
        local content = readfile(path)
        local data = HttpService:JSONDecode(content)
        
        -- Update Settings table
        LibrarySettings = data
        
        -- Apply to UI
        for key, value in pairs(data) do
            if ConfigurableItems[key] then
                -- Call the function stored in CreateToggle/Slider
                ConfigurableItems[key](value)
            end
        end
        StatusLabel.Text = "Loaded config: " .. name
    else
        print("Failed to find file at path:", path)
        StatusLabel.Text = "Config Not Found (Check Console F9)"
    end
end

local function DeleteConfig(name)
    if not name then return end
    if not delfile then return end
    local path = ConfigFolder .. "/" .. name .. ".json"
    if isfile(path) then
        delfile(path)
        StatusLabel.Text = "Deleted config: " .. name
    end
end

-- Refresh Config List Logic
local ConfigListFrame = Instance.new("ScrollingFrame")
ConfigListFrame.Name = "ConfigList"
ConfigListFrame.Parent = ConfigPage
ConfigListFrame.Size = UDim2.new(1, -10, 0, 150)
ConfigListFrame.Position = UDim2.new(0, 5, 0, 0) -- Adjusted by list layout
ConfigListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ConfigListFrame.BorderSizePixel = 0
ConfigListFrame.ScrollBarThickness = 2

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = ConfigListFrame
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 2)

local function RefreshConfigs()
    if not listfiles then return end
    
    -- Clear old list
    for _, v in pairs(ConfigListFrame:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    
    local files = listfiles(ConfigFolder)
    for _, file in ipairs(files) do
        -- Extract name from path (Updated regex for slashes and backslashes)
        local name = file:match("([^/\\]+)%.json$")
        
        if name then
            local btn = Instance.new("TextButton")
            btn.Parent = ConfigListFrame
            btn.Size = UDim2.new(1, 0, 0, 25)
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            btn.Text = "  " .. name
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.BorderSizePixel = 0
            
            -- Animation for list items
            AddHoverScale(btn, 1.01)
            
            btn.MouseButton1Click:Connect(function()
                selectedConfigFile = name
                StatusLabel.Text = "Selected: " .. name
                -- Visual Feedback
                for _, b in pairs(ConfigListFrame:GetChildren()) do
                    if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(200, 200, 200) end
                end
                btn.TextColor3 = Color3.fromRGB(100, 255, 100)
                AnimateClick(btn:FindFirstChild("UIScale"))
            end)
        end
    end
end

CreateButton(ConfigPage, "Create", function()
    SaveConfig(currentConfigName)
    RefreshConfigs()
end)

CreateSection(ConfigPage, "Config List")
-- Insert the scroll frame into the layout flow
ConfigListFrame.Parent = ConfigPage 

CreateButton(ConfigPage, "Refresh List", function()
    RefreshConfigs()
end)

CreateSection(ConfigPage, "Actions")
CreateButton(ConfigPage, "Save (Overwrite Selected)", function()
    if selectedConfigFile then
        SaveConfig(selectedConfigFile)
    else
        StatusLabel.Text = "Select a config first!"
    end
end)

CreateButton(ConfigPage, "Load Selected", function()
    if selectedConfigFile then
        LoadConfig(selectedConfigFile)
    else
        StatusLabel.Text = "Select a config first!"
    end
end)

CreateButton(ConfigPage, "Delete Selected", function()
    if selectedConfigFile then
        DeleteConfig(selectedConfigFile)
        selectedConfigFile = nil
        RefreshConfigs()
    else
        StatusLabel.Text = "Select a config first!"
    end
end)

CreateButton(ConfigPage, "Set Selected to Autoload", function()
    if selectedConfigFile then
        if writefile then
            writefile(AutoloadFile, selectedConfigFile)
            StatusLabel.Text = "Autoload set to: " .. selectedConfigFile
        end
    else
        StatusLabel.Text = "Select a config first!"
    end
end)

-- Initial Load of List
RefreshConfigs()

-- Check Autoload
task.spawn(function()
    if isfile and isfile(AutoloadFile) then
        local autoName = readfile(AutoloadFile)
        if autoName and autoName ~= "" then
            task.wait(1) -- Wait for UI to settle
            LoadConfig(autoName)
            StatusLabel.Text = "Autoloaded: " .. autoName
        end
    end
end)


----------------------------------------------------------------
-- SMOOTH ANIMATED TOGGLE LOGIC (LCTRL)
----------------------------------------------------------------
local isGuiOpen = true
local function ToggleUI()
    if isGuiOpen then
        -- Close Animation
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        })
        tween:Play()
        tween.Completed:Wait()
        MainFrame.Visible = false
    else
        -- Open Animation
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.BackgroundTransparency = 0
        
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 720, 0, 460),
            BackgroundTransparency = 0
        })
        tween:Play()
    end
    isGuiOpen = not isGuiOpen
end

-- Open on start with animation
task.spawn(function()
    isGuiOpen = false
    ToggleUI()
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        ToggleUI()
    end
end)

StatusLabel.Text = "Dirma Hub Loaded (LCTRL to Toggle)"
print("Dirma Hub Loaded Successfully")
