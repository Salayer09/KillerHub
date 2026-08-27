-- ============================================================================
-- 👻 KILLER HUB - MM2 ADVANCED VISUAL SUITE (ENGLISH ULTRA-OPTIMIZED V4.0)
-- ============================================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local fileName = "KillerHubMM2VisualConfig.json"
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Fast Local Cache
local pairs = pairs
local ipairs = ipairs
local type = type
local pcall = pcall
local tonumber = tonumber
local tostring = tostring
local math_floor = math.floor
local math_abs = math.abs
local Vector3_new = Vector3.new
local Vector2_new = Vector2.new
local Color3_fromRGB = Color3.fromRGB
local ColorSequence_new = ColorSequence.new
local ColorSequenceKeypoint_new = ColorSequenceKeypoint.new
local Instance_new = Instance.new
local UDim2_new = UDim2.new
local CFrame_new = CFrame.new
local playersGetPlayers = Players.GetPlayers

-- Default Game Roles Colors
local DefaultColors = {
    Murderer = Color3_fromRGB(180, 55, 55),
    Sheriff  = Color3_fromRGB(35, 102, 204),
    Hero     = Color3_fromRGB(230, 188, 62),
    Innocent = Color3_fromRGB(26, 171, 81),
    Dead     = Color3_fromRGB(115, 115, 115),
    GunDrop  = Color3_fromRGB(255, 0, 0)
}

local BlackColor = Color3_fromRGB(0, 0, 0)

-- [1] CONFIGURATION TABLE
local Config = { 
    Highlight = false, 
    HighlightTrans = 50,
    HighlightRoles = {["Murderer"] = false, ["Sheriff"] = false, ["Hero"] = false, ["Innocent"] = false, ["Dead/None"] = false},
    
    Box = false, 
    BoxRoles = {["Murderer"] = false, ["Sheriff"] = false, ["Hero"] = false, ["Innocent"] = false, ["Dead/None"] = false},
    
    Name = false, 
    NameRoles = {["Murderer"] = false, ["Sheriff"] = false, ["Hero"] = false, ["Innocent"] = false, ["Dead/None"] = false},
    
    Tracer = false,
    TracerPosition = "Bottom Center", -- English Options: "Bottom Center", "Top Center", "Middle Left", "Middle Right", "Center Screen"
    TracerRoles = {["Murderer"] = false, ["Sheriff"] = false, ["Hero"] = false, ["Innocent"] = false, ["Dead/None"] = false},

    LimbChams = false,
    LimbChamsTrans = 50,
    LimbChamsRoles = {["Murderer"] = false, ["Sheriff"] = false, ["Hero"] = false, ["Innocent"] = false, ["Dead/None"] = false},

    -- MY ESP INDIVIDUAL CONFIGURATION
    MyESP = {
        Highlight = false,
        HighlightTrans = 50,
        HighlightColorActive = false,
        HighlightColorRGB = {255, 255, 255},

        LimbChams = false,
        LimbChamsTrans = 50,
        LimbChamsColorActive = false,
        LimbChamsColorRGB = {255, 255, 255},

        Box = false,
        BoxColorActive = false,
        BoxColorRGB = {255, 255, 255},

        Name = false,
        NameColorActive = false,
        NameColorRGB = {255, 255, 255},

        Skeleton = false,
        SkeletonColorActive = false,
        SkeletonColorRGB = {255, 255, 255},

        CameraFOV = false,
        CameraFOVValue = 70,

        StretchedCam = false,
        StretchedCamValue = 0.67
    },

    GunCham = false,    
    GunName = false,    
    GunTracer = false, 
    NameSize = 13,      
    GunNameSize = 14,
    MaxDistance = 400,
    
    CustomColorsActive = {["Murderer"] = false, ["Sheriff"] = false, ["Hero"] = false, ["Innocent"] = false, ["Dead/None"] = false, ["GunDrop"] = false},
    CustomColorsRGB = {
        ["Murderer"] = {180, 55, 55},
        ["Sheriff"]  = {35, 102, 204},
        ["Hero"]     = {230, 188, 62},
        ["Innocent"] = {26, 171, 81},
        ["Dead/None"]= {115, 115, 115},
        ["GunDrop"]  = {255, 0, 0}
    }
}

-- [2] LOCAL STORAGE SYSTEM
local function saveConfig()
    if writefile then
        pcall(function()
            writefile(fileName, HttpService:JSONEncode(Config))
        end)
    end
end

if isfile and isfile(fileName) and readfile then
    pcall(function()
        local loaded = HttpService:JSONDecode(readfile(fileName))
        if type(loaded) == "table" then
            for k, v in pairs(loaded) do
                if k == "MyESP" and type(v) == "table" then
                    for subK, subVal in pairs(v) do
                        Config.MyESP[subK] = subVal
                    end
                elseif type(v) == "table" then
                    for subKey, subVal in pairs(v) do
                        if Config[k] then Config[k][subKey] = subVal end
                    end
                else
                    Config[k] = v
                end
            end
        end
    end)
end

-- [3] GRAPHICAL INTERFACE (ENGLISH)
local KillerHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/zpxlo0ev/LuXpaO/refs/heads/main/007900118.lua"))()

local VisualsTab = KillerHub:CreateTab("Visuals", "rbxassetid://6523858394")
local PagePlayers = VisualsTab:CreatePage("Players ESP", "Eye")
local PageMyESP   = VisualsTab:CreatePage("My ESP", "Player")

-- ==========================================
-- PAGE 1: PLAYERS ESP
-- ==========================================
PagePlayers:CreateSection("Player ESP")

local ToggleHighlight = PagePlayers:CreateToggleSlider("EspHighlight", "EspHighlightTrans", "Highlight ESP", 0, 100, 
    function(val) Config.Highlight = val; saveConfig() end,
    function(val) Config.HighlightTrans = math_floor(val); saveConfig() end
)
PagePlayers:CreateMultiDropdown("HighlightFilters", "Roles", {"Murderer", "Sheriff", "Hero", "Innocent", "Dead/None"}, function(flags)
    for r, _ in pairs(Config.HighlightRoles) do Config.HighlightRoles[r] = flags[r] == true end; saveConfig()
end)

local ToggleLimbChams = PagePlayers:CreateToggleSlider("EspLimbChams", "EspLimbChamsTrans", "Cham ESP", 0, 100, 
    function(val) Config.LimbChams = val; saveConfig() end,
    function(val) Config.LimbChamsTrans = math_floor(val); saveConfig() end
)
PagePlayers:CreateMultiDropdown("LimbChamsFilters", "Roles", {"Murderer", "Sheriff", "Hero", "Innocent", "Dead/None"}, function(flags)
    for r, _ in pairs(Config.LimbChamsRoles) do Config.LimbChamsRoles[r] = flags[r] == true end; saveConfig()
end)

local ToggleBox = PagePlayers:CreateToggle("EspBox", "Box ESP", function(val) Config.Box = val; saveConfig() end)
PagePlayers:CreateMultiDropdown("BoxFilters", "Roles", {"Murderer", "Sheriff", "Hero", "Innocent", "Dead/None"}, function(flags)
    for r, _ in pairs(Config.BoxRoles) do Config.BoxRoles[r] = flags[r] == true end; saveConfig()
end)

local ToggleName = PagePlayers:CreateToggle("EspName", "Name ESP", function(val) Config.Name = val; saveConfig() end)
PagePlayers:CreateMultiDropdown("NameFilters", "Roles", {"Murderer", "Sheriff", "Hero", "Innocent", "Dead/None"}, function(flags)
    for r, _ in pairs(Config.NameRoles) do Config.NameRoles[r] = flags[r] == true end; saveConfig()
end)

local ToggleTracer = PagePlayers:CreateToggle("EspTracer", "Tracer ESP", function(val) Config.Tracer = val; saveConfig() end)
PagePlayers:CreateDropdown("EspTracerPos", "Tracer Position", {"Bottom Center", "Top Center", "Middle Left", "Middle Right", "Center Screen"}, function(sel)
    Config.TracerPosition = sel
    saveConfig()
end, Config.TracerPosition or "Bottom Center")

PagePlayers:CreateMultiDropdown("TracerFilters", "Roles", {"Murderer", "Sheriff", "Hero", "Innocent", "Dead/None"}, function(flags)
    for r, _ in pairs(Config.TracerRoles) do Config.TracerRoles[r] = flags[r] == true end; saveConfig()
end)

local DropHighlight = KillerHub.Elements["HighlightFilters"]
local DropLimbChams = KillerHub.Elements["LimbChamsFilters"]
local DropBox       = KillerHub.Elements["BoxFilters"]
local DropName      = KillerHub.Elements["NameFilters"]
local DropTracer    = KillerHub.Elements["TracerFilters"]

PagePlayers:CreateSection("Dropped Gun ESP")
local ToggleGunCham = PagePlayers:CreateToggle("EspGunCham", "Gun Cham", function(val) Config.GunCham = val; saveConfig() end)
local ToggleGunName = PagePlayers:CreateToggle("EspGunName", "Gun Name", function(val) Config.GunName = val; saveConfig() end)
local ToggleGunTracer = PagePlayers:CreateToggle("EspGunTracer", "Gun Tracer", function(val) Config.GunTracer = val; saveConfig() end)

PagePlayers:CreateSection("Role Colors Customization")
local function createRoleColorPicker(roleKey, visualName)
    local defaultRGB = Config.CustomColorsRGB[roleKey]
    local defaultColor3 = Color3_fromRGB(defaultRGB[1], defaultRGB[2], defaultRGB[3])
    
    PagePlayers:CreateToggleColorPicker(
        "CP_Active_" .. roleKey, "CP_Color_" .. roleKey, visualName, defaultColor3,
        function(estado) Config.CustomColorsActive[roleKey] = estado; saveConfig() end,
        function(colorSeleccionado)
            Config.CustomColorsRGB[roleKey] = {math_floor(colorSeleccionado.R * 255), math_floor(colorSeleccionado.G * 255), math_floor(colorSeleccionado.B * 255)}
            saveConfig()
        end
    )
end
createRoleColorPicker("Murderer", "Murderer")
createRoleColorPicker("Sheriff", "Sheriff")
createRoleColorPicker("Hero", "Hero")
createRoleColorPicker("Innocent", "Innocent")
createRoleColorPicker("Dead/None", "Dead / Spectators")
createRoleColorPicker("GunDrop", "Dropped Gun")

PagePlayers:CreateSection("Settings & Performance")
local DistanceInput = PagePlayers:CreateInput("EspMaxDistance", "Max Render Distance (Studs)", "400", function(val)
    local num = tonumber(val)
    if num then Config.MaxDistance = math_abs(num); saveConfig()
    else KillerHub:NotifyWarn("Invalid Input", "Please enter numbers only.", 3) end
end)
local NameSizeSlider = PagePlayers:CreateSlider("EspNameSize", "Name Size", 10, 30, function(val) Config.NameSize = math_floor(val); saveConfig() end)
local GunNameSizeSlider = PagePlayers:CreateSlider("EspGunNameSize", "Gun Name Size", 10, 30, function(val) Config.GunNameSize = math_floor(val); saveConfig() end)

-- ==========================================
-- PAGE 2: MY ESP
-- ==========================================
PageMyESP:CreateSection("Self ESP Features")

local ToggleMyHighlight = PageMyESP:CreateToggleSlider("MyEspHighlight", "MyEspHighlightTrans", "Highlight ESP", 0, 100,
    function(val) Config.MyESP.Highlight = val; saveConfig() end,
    function(val) Config.MyESP.HighlightTrans = math_floor(val); saveConfig() end
)

local ToggleMyLimbChams = PageMyESP:CreateToggleSlider("MyEspLimbChams", "MyEspLimbChamsTrans", "Cham ESP", 0, 100,
    function(val) Config.MyESP.LimbChams = val; saveConfig() end,
    function(val) Config.MyESP.LimbChamsTrans = math_floor(val); saveConfig() end
)

local ToggleMyBox = PageMyESP:CreateToggle("MyEspBox", "Box ESP", function(val) Config.MyESP.Box = val; saveConfig() end)
local ToggleMyName = PageMyESP:CreateToggle("MyEspName", "Name ESP", function(val) Config.MyESP.Name = val; saveConfig() end)
local ToggleMySkeleton = PageMyESP:CreateToggle("MyEspSkeleton", "Skeleton ESP", function(val) Config.MyESP.Skeleton = val; saveConfig() end)

PageMyESP:CreateSection("Self Custom Colors")

local function createMyESPColorPicker(featureKey, featureName)
    local defaultRGB = Config.MyESP[featureKey .. "ColorRGB"]
    local defaultColor3 = Color3_fromRGB(defaultRGB[1], defaultRGB[2], defaultRGB[3])
    
    PageMyESP:CreateToggleColorPicker(
        "CP_Active_My_" .. featureKey, "CP_Color_My_" .. featureKey, featureName .. " Color", defaultColor3,
        function(estado) Config.MyESP[featureKey .. "ColorActive"] = estado; saveConfig() end,
        function(colorSeleccionado)
            Config.MyESP[featureKey .. "ColorRGB"] = {math_floor(colorSeleccionado.R * 255), math_floor(colorSeleccionado.G * 255), math_floor(colorSeleccionado.B * 255)}
            saveConfig()
        end
    )
end

createMyESPColorPicker("Highlight", "Highlight")
createMyESPColorPicker("LimbChams", "Cham")
createMyESPColorPicker("Box", "Box")
createMyESPColorPicker("Name", "Name")
createMyESPColorPicker("Skeleton", "Skeleton")

PageMyESP:CreateSection("Camera Features")

local ToggleCamFOV = PageMyESP:CreateToggleSlider("MyEspCamFOV", "MyEspCamFOVVal", "Camera FOV", 30, 120,
    function(val) 
        Config.MyESP.CameraFOV = val
        if not val then Camera.FieldOfView = 70 end
        saveConfig() 
    end,
    function(val) 
        Config.MyESP.CameraFOVValue = math_floor(val)
        saveConfig() 
    end,
    Config.MyESP.CameraFOV, Config.MyESP.CameraFOVValue
)

local ToggleStretchedCam = PageMyESP:CreateToggleSlider("MyEspStretchedCam", "MyEspStretchedCamVal", "Stretched Camera", 1, 100,
    function(val) Config.MyESP.StretchedCam = val; saveConfig() end,
    function(val) Config.MyESP.StretchedCamValue = val / 100; saveConfig() end,
    Config.MyESP.StretchedCam, math_floor((Config.MyESP.StretchedCamValue or 0.67) * 100)
)

-- [4] APPLY SAVED CONFIGURATIONS SAFELY
ToggleName:Set(Config.Name)
ToggleTracer:Set(Config.Tracer)
ToggleGunCham:Set(Config.GunCham); ToggleGunName:Set(Config.GunName); ToggleGunTracer:Set(Config.GunTracer); NameSizeSlider:Set(Config.NameSize); GunNameSizeSlider:Set(Config.GunNameSize)
ToggleBox:Set(Config.Box)

if ToggleHighlight then
    ToggleHighlight:SetToggle(Config.Highlight)
    ToggleHighlight:SetSlider(Config.HighlightTrans)
end

if ToggleLimbChams then
    ToggleLimbChams:SetToggle(Config.LimbChams)
    ToggleLimbChams:SetSlider(Config.LimbChamsTrans)
end

ToggleMyBox:Set(Config.MyESP.Box)
ToggleMyName:Set(Config.MyESP.Name)
ToggleMySkeleton:Set(Config.MyESP.Skeleton)
if ToggleMyHighlight then
    ToggleMyHighlight:SetToggle(Config.MyESP.Highlight)
    ToggleMyHighlight:SetSlider(Config.MyESP.HighlightTrans)
end
if ToggleMyLimbChams then
    ToggleMyLimbChams:SetToggle(Config.MyESP.LimbChams)
    ToggleMyLimbChams:SetSlider(Config.MyESP.LimbChamsTrans)
end

local myFeatures = {"Highlight", "LimbChams", "Box", "Name", "Skeleton"}
for _, fKey in ipairs(myFeatures) do
    local toggleInstance = getgenv().KillerHub and getgenv().KillerHub.Flags and getgenv().KillerHub.Flags["CP_Active_My_" .. fKey]
    if toggleInstance and toggleInstance.Set then toggleInstance:Set(Config.MyESP[fKey .. "ColorActive"]) end
end

if DistanceInput and DistanceInput.Set then DistanceInput:Set(tostring(Config.MaxDistance)) end
if DropHighlight and DropHighlight.Set then pcall(function() DropHighlight:Set(Config.HighlightRoles) end) end
if DropLimbChams and DropLimbChams.Set then pcall(function() DropLimbChams:Set(Config.LimbChamsRoles) end) end
if DropBox and DropBox.Set then pcall(function() DropBox:Set(Config.BoxRoles) end) end
if DropName and DropName.Set then pcall(function() DropName:Set(Config.NameRoles) end) end
if DropTracer and DropTracer.Set then pcall(function() DropTracer:Set(Config.TracerRoles) end) end

for roleKey, _ in pairs(Config.CustomColorsActive) do
    local toggleInstance = getgenv().KillerHub and getgenv().KillerHub.Flags and getgenv().KillerHub.Flags["CP_Active_" .. roleKey]
    if toggleInstance and toggleInstance.Set then toggleInstance:Set(Config.CustomColorsActive[roleKey]) end
end

-- ============================================================================
-- 🧠 CORE ENGINE (ULTRA-OPTIMIZED V4.0)
-- ============================================================================

local playerRoles = {} 
local playerDeadStatus = {} 
local currentGunDrop = nil 

local GunDrawingLine = Drawing.new("Line")
GunDrawingLine.Thickness = 1
GunDrawingLine.Transparency = 1
GunDrawingLine.Visible = false

local playerTracers = {}
local mySkeletonLines = {}

local R6Bones = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"}
}

local R15Bones = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightUpperLeg", "RightFoot"}
}

local function clearMySkeleton()
    for _, line in pairs(mySkeletonLines) do
        line.Visible = false
        pcall(function() line:Remove() end)
    end
    table.clear(mySkeletonLines)
end

local function getTracerLine(player)
    if not playerTracers[player] then
        local line = Drawing.new("Line")
        line.Thickness = 1
        line.Transparency = 1
        line.Visible = false
        playerTracers[player] = line
    end
    return playerTracers[player]
end

local function removeTracerLine(player)
    if playerTracers[player] then
        pcall(function()
            playerTracers[player].Visible = false
            playerTracers[player]:Remove()
        end)
        playerTracers[player] = nil
    end
end

local function getRoleColor(roleKey, fallbackColor3)
    if Config.CustomColorsActive[roleKey] == true then
        local rgb = Config.CustomColorsRGB[roleKey]
        return Color3_fromRGB(rgb[1], rgb[2], rgb[3])
    end
    return fallbackColor3
end

local function getPlayerColorAndStatus(player)
    local char = player.Character
    local name = player.Name
    
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local isDeadInGame = not char or not humanoid or humanoid.Health <= 0
    local isDeadInNetwork = playerDeadStatus[name] == true

    if isDeadInGame or isDeadInNetwork then
        return getRoleColor("Dead/None", DefaultColors.Dead), "Dead/None"
    end

    local backpack = player:FindFirstChild("Backpack")
    local hasKnife = (char and char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife"))
    local hasGun = (char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver"))) or 
                   (backpack and (backpack:FindFirstChild("Gun") or backpack:FindFirstChild("Revolver")))

    if hasKnife or playerRoles[name] == "Murderer" then 
        playerRoles[name] = "Murderer"
        return getRoleColor("Murderer", DefaultColors.Murderer), "Murderer"
    end

    if hasGun then
        if playerRoles[name] == "Sheriff" then 
            return getRoleColor("Sheriff", DefaultColors.Sheriff), "Sheriff"
        else 
            return getRoleColor("Hero", DefaultColors.Hero), "Hero" 
        end
    end

    if playerRoles[name] == "Sheriff" then 
        return getRoleColor("Sheriff", DefaultColors.Sheriff), "Sheriff"
    elseif playerRoles[name] == "Hero" then 
        return getRoleColor("Hero", DefaultColors.Hero), "Hero"
    end

    return getRoleColor("Innocent", DefaultColors.Innocent), "Innocent"
end

local function getMyFeatureColor(featureKey)
    local activeKey = featureKey .. "ColorActive"
    local rgbKey = featureKey .. "ColorRGB"
    if Config.MyESP[activeKey] == true then
        local rgb = Config.MyESP[rgbKey]
        return Color3_fromRGB(rgb[1], rgb[2], rgb[3])
    end
    local defaultColor, _ = getPlayerColorAndStatus(LocalPlayer)
    return defaultColor
end

local function clearPlayerESP(char)
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        local box = root:FindFirstChild("KH_2DBox")
        local nameTag = root:FindFirstChild("KH_Name")
        local myBox = root:FindFirstChild("KH_My2DBox")
        local myNameTag = root:FindFirstChild("KH_MyName")
        if box then box:Destroy() end
        if nameTag then nameTag:Destroy() end
        if myBox then myBox:Destroy() end
        if myNameTag then myNameTag:Destroy() end
    end
    
    local limbFolder = char:FindFirstChild("KH_LimbChams")
    if limbFolder then limbFolder:Destroy() end
    local myLimbFolder = char:FindFirstChild("KH_MyLimbChams")
    if myLimbFolder then myLimbFolder:Destroy() end
    
    local hl = char:FindFirstChild("KH_Highlight")
    if hl then hl:Destroy() end
    local myHl = char:FindFirstChild("KH_MyHighlight")
    if myHl then myHl:Destroy() end
end

local function updatePlayerESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not root or not myRoot then return end
    
    local distance = (myRoot.Position - root.Position).Magnitude
    if distance > Config.MaxDistance then
        clearPlayerESP(char) 
        return
    end
    
    local color, currentStatus = getPlayerColorAndStatus(player)

    -- Cham ESP
    local limbFolder = char:FindFirstChild("KH_LimbChams")
    if Config.LimbChams and Config.LimbChamsRoles[currentStatus] == true then
        if not limbFolder then
            limbFolder = Instance_new("Folder")
            limbFolder.Name = "KH_LimbChams"
            limbFolder.Parent = char
        end
        
        local currentTrans = Config.LimbChamsTrans / 100
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                local adornName = part.Name .. "_Adorn"
                local adorn = limbFolder:FindFirstChild(adornName)
                if not adorn then
                    adorn = Instance_new("BoxHandleAdornment")
                    adorn.Name = adornName
                    adorn.AlwaysOnTop = true
                    adorn.ZIndex = 5
                    adorn.Parent = limbFolder
                end
                adorn.Adornee = part
                adorn.Size = part.Size + Vector3_new(0.02, 0.02, 0.02)
                adorn.Color3 = color
                adorn.Transparency = currentTrans
            end
        end
    else
        if limbFolder then limbFolder:Destroy() end
    end

    -- BOX 2D ESP
    local box = root:FindFirstChild("KH_2DBox")
    if Config.Box and Config.BoxRoles[currentStatus] == true then
        if not box then
            box = Instance_new("BillboardGui"); box.Name = "KH_2DBox"; box.Size = UDim2_new(4.4, 0, 5.9, 0); box.AlwaysOnTop = true
            local frame = Instance_new("Frame"); frame.Size = UDim2_new(1, 0, 1, 0); frame.BackgroundTransparency = 1; frame.Parent = box
            local stroke = Instance_new("UIStroke"); stroke.Thickness = 1.2; stroke.Name = "Outline"; stroke.Parent = frame
            box.Adornee = root; box.Parent = root
        end
        box.Frame.Outline.Color = color
    else
        if box then box:Destroy() end
    end

    -- NAME ESP
    local nameTag = root:FindFirstChild("KH_Name")
    if Config.Name and Config.NameRoles[currentStatus] == true then
        if not nameTag then
            nameTag = Instance_new("BillboardGui"); nameTag.Name = "KH_Name"; nameTag.Size = UDim2_new(0, 160, 0, 40); nameTag.StudsOffset = Vector3_new(0, 4.0, 0); nameTag.AlwaysOnTop = true
            local label = Instance_new("TextLabel"); label.Name = "Display"; label.Size = UDim2_new(1, 0, 1, 0); label.BackgroundTransparency = 1
            label.Font = Enum.Font.SourceSansBold; label.TextStrokeTransparency = 0.3; label.Parent = nameTag
            nameTag.Adornee = root; nameTag.Parent = root
        end
        nameTag.Display.Text = player.Name
        nameTag.Display.TextColor3 = color
        nameTag.Display.TextSize = Config.NameSize
    else
        if nameTag then nameTag:Destroy() end
    end

    -- HIGHLIGHT ENGINE
    local hl = char:FindFirstChild("KH_Highlight")
    local allowHighlight = Config.Highlight and Config.HighlightRoles[currentStatus] == true

    if allowHighlight then
        if not hl then
            hl = Instance_new("Highlight"); hl.Name = "KH_Highlight"; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = char
        end
        hl.Adornee = char
        hl.FillColor = color
        hl.FillTransparency = Config.HighlightTrans / 100 
        hl.OutlineColor = color
        hl.OutlineTransparency = 0 
    else
        if hl then hl:Destroy() end
    end
end

local function updateMyESP()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local limbFolder = char:FindFirstChild("KH_MyLimbChams")
    if Config.MyESP.LimbChams then
        local chamColor = getMyFeatureColor("LimbChams")
        if not limbFolder then
            limbFolder = Instance_new("Folder")
            limbFolder.Name = "KH_MyLimbChams"
            limbFolder.Parent = char
        end
        local currentTrans = Config.MyESP.LimbChamsTrans / 100
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                local adornName = part.Name .. "_MyAdorn"
                local adorn = limbFolder:FindFirstChild(adornName)
                if not adorn then
                    adorn = Instance_new("BoxHandleAdornment")
                    adorn.Name = adornName
                    adorn.AlwaysOnTop = true
                    adorn.ZIndex = 5
                    adorn.Parent = limbFolder
                end
                adorn.Adornee = part
                adorn.Size = part.Size + Vector3_new(0.02, 0.02, 0.02)
                adorn.Color3 = chamColor
                adorn.Transparency = currentTrans
            end
        end
    else
        if limbFolder then limbFolder:Destroy() end
    end

    local box = root:FindFirstChild("KH_My2DBox")
    if Config.MyESP.Box then
        local boxColor = getMyFeatureColor("Box")
        if not box then
            box = Instance_new("BillboardGui")
            box.Name = "KH_My2DBox"
            box.Size = UDim2_new(4.4, 0, 5.9, 0)
            box.AlwaysOnTop = true
            
            local mainFrame = Instance_new("Frame")
            mainFrame.Name = "MainFrame"
            mainFrame.Size = UDim2_new(1, 0, 1, 0)
            mainFrame.BackgroundTransparency = 1
            mainFrame.Parent = box

            local thickOffset = 2
            local cSize = 0.22

            local function addCornerSegment(name, pos, size, gradRotation)
                local frame = Instance_new("Frame")
                frame.Name = name
                frame.Position = pos
                frame.Size = size
                frame.BorderSizePixel = 0
                frame.Parent = mainFrame
                
                local grad = Instance_new("UIGradient")
                grad.Name = "Grad"
                grad.Rotation = gradRotation
                grad.Parent = frame
                return frame
            end

            addCornerSegment("TL_H", UDim2_new(0, 0, 0, 0), UDim2_new(cSize, 0, 0, thickOffset), 0)
            addCornerSegment("TL_V", UDim2_new(0, 0, 0, 0), UDim2_new(0, thickOffset, cSize, 0), 90)
            addCornerSegment("TR_H", UDim2_new(1 - cSize, 0, 0, 0), UDim2_new(cSize, 0, 0, thickOffset), 180)
            addCornerSegment("TR_V", UDim2_new(1, -thickOffset, 0, 0), UDim2_new(0, thickOffset, cSize, 0), 90)
            addCornerSegment("BL_H", UDim2_new(0, 0, 1, -thickOffset), UDim2_new(cSize, 0, 0, thickOffset), 0)
            addCornerSegment("BL_V", UDim2_new(0, 0, 1 - cSize, 0), UDim2_new(0, thickOffset, cSize, 0), 270)
            addCornerSegment("BR_H", UDim2_new(1 - cSize, 0, 1, -thickOffset), UDim2_new(cSize, 0, 0, thickOffset), 180)
            addCornerSegment("BR_V", UDim2_new(1, -thickOffset, 1 - cSize, 0), UDim2_new(0, thickOffset, cSize, 0), 270)

            box.Adornee = root
            box.Parent = root
        end

        local main = box:FindFirstChild("MainFrame")
        if main then
            local gradColorSeq = ColorSequence_new({
                ColorSequenceKeypoint_new(0, boxColor),
                ColorSequenceKeypoint_new(0.7, boxColor),
                ColorSequenceKeypoint_new(1, BlackColor)
            })
            for _, child in ipairs(main:GetChildren()) do
                local grad = child:FindFirstChild("Grad")
                if grad then
                    grad.Color = gradColorSeq
                end
            end
        end
    else
        if box then box:Destroy() end
    end

    local nameTag = root:FindFirstChild("KH_MyName")
    if Config.MyESP.Name then
        local nameColor = getMyFeatureColor("Name")
        if not nameTag then
            nameTag = Instance_new("BillboardGui"); nameTag.Name = "KH_MyName"; nameTag.Size = UDim2_new(0, 160, 0, 40); nameTag.StudsOffset = Vector3_new(0, 4.0, 0); nameTag.AlwaysOnTop = true
            local label = Instance_new("TextLabel"); label.Name = "Display"; label.Size = UDim2_new(1, 0, 1, 0); label.BackgroundTransparency = 1
            label.Font = Enum.Font.SourceSansBold; label.TextStrokeTransparency = 0.3; label.Parent = nameTag
            nameTag.Adornee = root; nameTag.Parent = root
        end
        nameTag.Display.Text = LocalPlayer.Name
        nameTag.Display.TextColor3 = nameColor
        nameTag.Display.TextSize = Config.NameSize
    else
        if nameTag then nameTag:Destroy() end
    end

    local hl = char:FindFirstChild("KH_MyHighlight")
    if Config.MyESP.Highlight then
        local hlColor = getMyFeatureColor("Highlight")
        if not hl then
            hl = Instance_new("Highlight"); hl.Name = "KH_MyHighlight"; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = char
        end
        hl.Adornee = char
        hl.FillColor = hlColor
        hl.FillTransparency = Config.MyESP.HighlightTrans / 100
        hl.OutlineColor = hlColor
        hl.OutlineTransparency = 0
    else
        if hl then hl:Destroy() end
    end
end

local function checkGunInstance(part)
    if part and part.Name == "GunDrop" and part:IsA("BasePart") then currentGunDrop = part end
end
Workspace.ChildAdded:Connect(checkGunInstance)

local function updateGunESP()
    if not currentGunDrop or not currentGunDrop:IsDescendantOf(Workspace) then
        currentGunDrop = Workspace:FindFirstChild("GunDrop", true)
    end

    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if currentGunDrop and currentGunDrop:IsA("BasePart") and myRoot then
        local distance = (myRoot.Position - currentGunDrop.Position).Magnitude
        if distance > Config.MaxDistance then
            local hl = currentGunDrop:FindFirstChild("KH_GunHighlight")
            local nameTag = currentGunDrop:FindFirstChild("KH_GunName")
            if hl then hl:Destroy() end
            if nameTag then nameTag:Destroy() end
            return
        end

        local gunColor = getRoleColor("GunDrop", DefaultColors.GunDrop)

        local hl = currentGunDrop:FindFirstChild("KH_GunHighlight")
        if Config.GunCham then
            if not hl then
                hl = Instance_new("Highlight"); hl.Name = "KH_GunHighlight"; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Adornee = currentGunDrop; hl.Parent = currentGunDrop
            end
            hl.FillColor = gunColor; hl.FillTransparency = 0; hl.OutlineTransparency = 1      
        elseif hl then hl:Destroy() end

        local nameTag = currentGunDrop:FindFirstChild("KH_GunName")
        if Config.GunName then
            if not nameTag then
                nameTag = Instance_new("BillboardGui"); nameTag.Name = "KH_GunName"; nameTag.Size = UDim2_new(0, 180, 0, 40); nameTag.StudsOffset = Vector3_new(0, 2.5, 0); nameTag.AlwaysOnTop = true
                local label = Instance_new("TextLabel"); label.Name = "Display"; label.Size = UDim2_new(1, 0, 1, 0); label.BackgroundTransparency = 1
                label.Font = Enum.Font.SourceSansBold; label.TextStrokeTransparency = 0.1; label.TextStrokeColor3 = Color3_fromRGB(0, 0, 0); label.Text = "GUN HERE"; label.Parent = nameTag
                nameTag.Adornee = currentGunDrop; nameTag.Parent = currentGunDrop
            end
            nameTag.Display.TextColor3 = gunColor
            nameTag.Display.TextSize = Config.GunNameSize
        elseif nameTag then nameTag:Destroy() end
    end
end

local PlayerDataChanged = ReplicatedStorage:FindFirstChild("PlayerDataChanged", true)
local RoundStart = ReplicatedStorage:FindFirstChild("RoundStart", true)

local function parsePlayerData(tabla)
    if type(tabla) == "table" then
        for name, data in pairs(tabla) do
            if type(data) == "table" then
                if data.Role then playerRoles[name] = data.Role end
                if data.Dead ~= nil then playerDeadStatus[name] = data.Dead end
            end
        end
    end
end

if PlayerDataChanged and PlayerDataChanged:IsA("RemoteEvent") then PlayerDataChanged.OnClientEvent:Connect(parsePlayerData) end
if RoundStart and RoundStart:IsA("RemoteEvent") then
    RoundStart.OnClientEvent:Connect(function(arg1, arg2)
        table.clear(playerRoles); table.clear(playerDeadStatus); currentGunDrop = nil 
        parsePlayerData(arg2); parsePlayerData(arg1)
    end)
end

local RoundOver = ReplicatedStorage:FindFirstChild("RoundOver", true) or ReplicatedStorage:FindFirstChild("SnowballRoundOver", true)
if RoundOver and RoundOver:IsA("RemoteEvent") then
    RoundOver.OnClientEvent:Connect(function()
        table.clear(playerRoles); table.clear(playerDeadStatus); currentGunDrop = nil
        local allPlayers = playersGetPlayers(Players)
        for i = 1, #allPlayers do 
            local plr = allPlayers[i]
            if plr and plr.Character then clearPlayerESP(plr.Character) end 
        end
    end)
end

Players.PlayerRemoving:Connect(function(player)
    playerRoles[player.Name] = nil; playerDeadStatus[player.Name] = nil
    removeTracerLine(player)
end)

-- OPTIMIZED REFRESH LOOP
task.spawn(function()
    while true do
        local allPlayers = playersGetPlayers(Players)
        for i = 1, #allPlayers do
            local plr = allPlayers[i]
            if plr and plr.Character then
                updatePlayerESP(plr)
            end
        end
        updateMyESP()
        updateGunESP()
        task.wait(0.15)
    end
end)

-- DYNAMIC TRACER ORIGIN RESOLVER (CENTER-LEFT, CENTER-RIGHT & TOP-CENTER ADDED)
local function getTracerOriginPoint(viewportSize, mode)
    if mode == "Top Center" then
        return Vector2_new(viewportSize.X / 2, 0)
    elseif mode == "Middle Left" then
        return Vector2_new(0, viewportSize.Y / 2)
    elseif mode == "Middle Right" then
        return Vector2_new(viewportSize.X, viewportSize.Y / 2)
    elseif mode == "Center Screen" then
        return Vector2_new(viewportSize.X / 2, viewportSize.Y / 2)
    end
    -- Default: Bottom Center
    return Vector2_new(viewportSize.X / 2, viewportSize.Y)
end

-- RENDER STEPPED (SKELETON, TRACERS & CAMERA ENGINE)
RunService.RenderStepped:Connect(function()
    if Config.MyESP.CameraFOV then
        local targetFOV = Config.MyESP.CameraFOVValue or 70
        if Camera.FieldOfView ~= targetFOV then
            Camera.FieldOfView = targetFOV
        end
    end

    if Config.MyESP.StretchedCam then
        local stretchFactor = Config.MyESP.StretchedCamValue or 0.67
        Camera.CFrame = Camera.CFrame * CFrame_new(0, 0, 0, 1, 0, 0, 0, stretchFactor, 0, 0, 0, 1)
    end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    -- 1. RENDER MY SKELETON ESP
    if Config.MyESP.Skeleton and myChar then
        local humanoid = myChar:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15
            local boneList = isR15 and R15Bones or R6Bones
            local skelColor = getMyFeatureColor("Skeleton")

            for i = 1, #boneList do
                if not mySkeletonLines[i] then
                    local line = Drawing.new("Line")
                    line.Thickness = 1.5
                    line.Transparency = 1
                    line.Visible = false
                    mySkeletonLines[i] = line
                end
            end

            for i = #boneList + 1, #mySkeletonLines do
                mySkeletonLines[i].Visible = false
            end

            for i, bonePair in ipairs(boneList) do
                local partA = myChar:FindFirstChild(bonePair[1])
                local partB = myChar:FindFirstChild(bonePair[2])
                local line = mySkeletonLines[i]

                if partA and partB then
                    local posA, visA = Camera:WorldToViewportPoint(partA.Position)
                    local posB, visB = Camera:WorldToViewportPoint(partB.Position)

                    if visA or visB then
                        line.From = Vector2_new(posA.X, posA.Y)
                        line.To = Vector2_new(posB.X, posB.Y)
                        line.Color = skelColor
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            end
        else
            for _, line in pairs(mySkeletonLines) do line.Visible = false end
        end
    else
        for _, line in pairs(mySkeletonLines) do line.Visible = false end
    end

    -- 2. TRACERS FOR OTHER PLAYERS & GUN
    if myRoot then
        local viewportSize = Camera.ViewportSize
        local tracerOrigin = getTracerOriginPoint(viewportSize, Config.TracerPosition)
        
        local allPlayers = playersGetPlayers(Players)
        for i = 1, #allPlayers do
            local player = allPlayers[i]
            if player ~= LocalPlayer then
                local line = playerTracers[player]
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                if Config.Tracer and root then
                    local distance = (myRoot.Position - root.Position).Magnitude
                    if distance <= Config.MaxDistance then
                        local color, currentStatus = getPlayerColorAndStatus(player)
                        if Config.TracerRoles[currentStatus] == true then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                            if onScreen then
                                if not line then line = getTracerLine(player) end
                                line.From = tracerOrigin
                                line.To = Vector2_new(screenPos.X, screenPos.Y)
                                line.Color = color
                                line.Visible = true
                            elseif line then
                                line.Visible = false
                            end
                        elseif line then
                            line.Visible = false
                        end
                    elseif line then
                        line.Visible = false
                    end
                elseif line then
                    line.Visible = false
                end
            end
        end

        if Config.GunTracer and currentGunDrop and currentGunDrop:IsDescendantOf(Workspace) and currentGunDrop:IsA("BasePart") then
            local distance = (myRoot.Position - currentGunDrop.Position).Magnitude
            local screenPos, onScreen = Camera:WorldToViewportPoint(currentGunDrop.Position)
            
            if onScreen and distance <= Config.MaxDistance then
                local gunColor = getRoleColor("GunDrop", DefaultColors.GunDrop)
                GunDrawingLine.From = tracerOrigin
                GunDrawingLine.To = Vector2_new(screenPos.X, screenPos.Y)
                GunDrawingLine.Color = gunColor
                GunDrawingLine.Visible = true
            else
                GunDrawingLine.Visible = false
            end
        else
            GunDrawingLine.Visible = false
        end
    else
        for _, line in pairs(playerTracers) do line.Visible = false end
        GunDrawingLine.Visible = false
    end
end)

CoreGui.ChildRemoved:Connect(function(child)
    if child.Name == "KillerHub" then 
        GunDrawingLine:Remove()
        for _, line in pairs(playerTracers) do
            pcall(function() line:Remove() end)
        end
        table.clear(playerTracers)
        clearMySkeleton()
    end
end)

return KillerHub
