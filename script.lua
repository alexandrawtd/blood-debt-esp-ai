local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local highlightFolder = Instance.new("Folder")
highlightFolder.Name = "PlayerHighlights"
highlightFolder.Parent = game:GetService("CoreGui")

-- ===== SETTINGS =====
local settings = {
    enabled = true,
    updateInterval = 1,  -- Update every 1 second
    
    -- Weapon categories (all variants included)
    weapons = {
        murderer = {
            "skorpion", "k1911", "rosen-obrez", "sawn-off", "rr-lcp", "js-22",
            "js-2 derringy", "js-2 bonds derringy", "charcoal steel js-22",
            "kamatov", "clothed sawn-off", "clothed rosen-obrez",
            "silver steel k1911", "zz-90", "m-10", "dark steel k1911",
            "glided", "js1 competitor", "pretty pink rr-lcp",
            "chromeslide turqoise rr-lcp", "door'bler",
            "sound maker", "slow sound maker", "smoke maker", "ngo",
            "throwing dagger", "throwing tomahawk", "throwing kunai", "throwing shuriken"
        },
        
        sheriff = {
            "beagle", "gg-17", "gg-17 tan", "pretty pink gg-17", "I-412",
            "rr-snubby", "silver steel rr-snubby", "j9-m"
        },
        
        terrorist = {"VK's ANKM", "RY's GG-17", "AT's KAR15"},
        police = {"RR-40", "IZVEKH-412"},
        civilian = {"Lead Pipe", "KitchenKnife", "Pen"}
    },
    
    colors = {
        murderer = Color3.fromRGB(255, 50, 50),     -- Red
        sheriff = Color3.fromRGB(50, 50, 255),      -- Blue
        terrorist = Color3.fromRGB(255, 165, 0),    -- Orange
        police = Color3.fromRGB(100, 200, 255)      -- Light Blue
    }
}

-- ===== UI SETUP =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BloodDebtHighlighter"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 150)
mainFrame.Position = UDim2.new(0.5, -110, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -40, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.Text = "Blood Debt Highlighter"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.BackgroundTransparency = 1
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.BackgroundTransparency = 1
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.Parent = titleBar

-- Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.9, 0, 0, 40)
toggleButton.Position = UDim2.new(0.05, 0, 0.25, 0)
toggleButton.Text = "DISABLE"
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.Gotham
toggleButton.TextSize = 14
toggleButton.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleButton

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 20)
statusLabel.Position = UDim2.new(0.05, 0, 0.6, 0)
statusLabel.Text = "Status: ACTIVE"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

-- Credit Label
local creditLabel = Instance.new("TextLabel")
creditLabel.Size = UDim2.new(1, 0, 0, 20)
creditLabel.Position = UDim2.new(0, 0, 1, -20)
creditLabel.Text = "Made by alexandrawtd"
creditLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
creditLabel.BackgroundTransparency = 1
creditLabel.Font = Enum.Font.Gotham
creditLabel.TextSize = 10
creditLabel.Parent = mainFrame

-- ===== DRAGGABLE UI =====
local dragging = false
local dragStartPos, frameStartPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStartPos = input.Position
        frameStartPos = mainFrame.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    dragging = false
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartPos
        mainFrame.Position = UDim2.new(
            frameStartPos.X.Scale,
            frameStartPos.X.Offset + delta.X,
            frameStartPos.Y.Scale,
            frameStartPos.Y.Offset + delta.Y
        )
    end
end)

-- ===== ROLE DETECTION =====
local function getPlayerRole(player)
    local character = player.Character
    if not character then return nil end
    
    -- Check equipped tool
    local equippedTool = character:FindFirstChildOfClass("Tool")
    if equippedTool then
        for category, weapons in pairs(settings.weapons) do
            for _, weapon in ipairs(weapons) do
                if equippedTool.Name:lower():find(weapon:lower()) then
                    return category
                end
            end
        end
    end
    
    -- Check backpack
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                for category, weapons in pairs(settings.weapons) do
                    for _, weapon in ipairs(weapons) do
                        if tool.Name:lower():find(weapon:lower()) then
                            return category
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

-- ===== HIGHLIGHT SYSTEM =====
local function updateHighlights()
    if not settings.enabled then
        for _, highlight in pairs(highlightFolder:GetChildren()) do
            highlight:Destroy()
        end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local character = player.Character
            if not character then continue end

            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid then continue end

            local role = getPlayerRole(player)
            local highlight = highlightFolder:FindFirstChild(player.Name) or Instance.new("Highlight")
            highlight.Name = player.Name
            highlight.Parent = highlightFolder

            -- Clear highlight if civilian or no role
            if not role or role == "civilian" then
                highlight.FillColor = Color3.new(0, 0, 0)
                highlight.OutlineColor = Color3.new(0, 0, 0)
                highlight.Adornee = character
                continue
            end

            -- Apply role highlight
            highlight.FillColor = settings.colors[role]
            highlight.OutlineColor = settings.colors[role]
            highlight.Adornee = character
        end
    end
end

-- ===== CONTROLS =====
toggleButton.MouseButton1Click:Connect(function()
    settings.enabled = not settings.enabled
    if settings.enabled then
        toggleButton.Text = "DISABLE"
        statusLabel.Text = "Status: ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        toggleButton.Text = "ENABLE"
        statusLabel.Text = "Status: INACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
    updateHighlights()
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    highlightFolder:Destroy()
    script:Destroy()
end)

-- ===== INITIAL SETUP =====
Players.PlayerAdded:Connect(updateHighlights)
Players.PlayerRemoving:Connect(function(player)
    local highlight = highlightFolder:FindFirstChild(player.Name)
    if highlight then highlight:Destroy() end
end)

-- ===== MAIN LOOP =====
while true do
    updateHighlights()
    task.wait(settings.updateInterval)
end
