-- ============================================================================
-- 👻 KILLER HUB - MM2 ADVANCED VISUAL SUITE (ULTRA-OPTIMIZED V3.3)
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

-- Localización/Cacheo para Máxima Optimización de FPS
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
local Instance_new = Instance.new
local UDim2_new = UDim2.new
local playersGetPlayers = Players.GetPlayers

-- Colores base del juego
local DefaultColors = {
    Murderer = Color3_fromRGB(180, 55, 55),
    Sheriff  = Color3_fromRGB(35, 102, 204),
    Hero     = Color3_fromRGB(230, 188, 62),
    Innocent = Color3_fromRGB(26, 171, 81),
    Dead     = Color3_fromRGB(115, 115, 115),
    GunDrop  = Color3_fromRGB(255, 0, 0)
}

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
    TracerRoles = {["Murderer"] = false, ["Sheriff"] = false, ["Hero"] = false, ["Innocent"] = false, ["Dead/None"] = false},

    LimbChams = false,
    LimbChamsTrans = 50,
    LimbChamsRoles = {["Murderer"] = false, ["Sheriff"] = false, ["Hero"] = false, ["Innocent"] = false, ["Dead/None"] = false},

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
                if type(v) == "table" then
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

-- [3] GRAPHICAL INTERFACE
local KillerHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/zpxlo0ev/LuXpaO/refs/heads/main/007900118.lua"))()

-- VISUALS TAB
local VisualsTab = KillerHub:CreateTab("Visuals", "rbxassetid://6523858394")

VisualsTab:CreateSection("Player ESP")

-- Cuerpo Completo (Highlight)
local ToggleHighlight = VisualsTab:CreateToggleSlider("EspHighlight", "EspHighlightTrans", "Highlight ESP", 0, 100, 
    function(val) Config.Highlight = val; saveConfig() end,
    function(val) Config.HighlightTrans = math_floor(val); saveConfig() end
)
VisualsTab:CreateMultiDropdown("HighlightFilters", "Highlight Filters", {"Murderer", "Sheriff", "Hero", "Innocent", "Dead/None"}, function(flags)
    for r, _ in pairs(Config.HighlightRoles) do Config.HighlightRoles[r] = flags[r] == true end; saveConfig()
end)
local DropHighlight = KillerHub.Elements["HighlightFilters"]

-- Cham ESP
local ToggleLimbChams = VisualsTab:CreateToggleSlider("EspLimbChams", "EspLimbChamsTrans", "Cham ESP", 0, 100, 
    function(val) Config.LimbChams = val; saveConfig() end,
    function(val) Config.LimbChamsTrans = math_floor(val); saveConfig() end
)
VisualsTab:CreateMultiDropdown("LimbChamsFilters", "Cham ESP Filters", {"Murderer", "Sheriff", "Hero", "Innocent", "Dead/None"}, function(flags)
    for r, _ in pairs(Config.LimbChamsRoles) do Config.LimbChamsRoles[r] = flags[r] == true end; saveConfig()
end)
local DropLimbChams = KillerHub.Elements["LimbChamsFilters"]

-- Box 2D
local ToggleBox = VisualsTab:CreateToggle("EspBox", "ESP Box 2D", function(val) Config.Box = val; saveConfig() end)
VisualsTab:CreateMultiDropdown("BoxFilters", "Box Filters", {"Murderer", "Sheriff", "Hero", "Innocent", "Dead/None"}, function(flags)
    for r, _ in pairs(Config.BoxRoles) do Config.BoxRoles[r] = flags[r] == true end; saveConfig()
end)
local DropBox = KillerHub.Elements["BoxFilters"]

-- Nombres
local ToggleName = VisualsTab:CreateToggle("EspName", "ESP Name", function(val) Config.Name = val; saveConfig() end)
VisualsTab:CreateMultiDropdown("NameFilters", "Name Filters", {"Murderer", "Sheriff", "Hero", "Innocent", "Dead/None"}, function(flags)
    for r, _ in pairs(Config.NameRoles) do Config.NameRoles[r] = flags[r] == true end; saveConfig()
end)
local DropName = KillerHub.Elements["NameFilters"]

-- Tracers (Líneas)
local ToggleTracer = VisualsTab:CreateToggle("EspTracer", "ESP Tracer", function(val) Config.Tracer = val; saveConfig() end)
VisualsTab:CreateMultiDropdown("TracerFilters", "Tracer Filters", {"Murderer", "Sheriff", "Hero", "Innocent", "Dead/None"}, function(flags)
    for r, _ in pairs(Config.TracerRoles) do Config.TracerRoles[r] = flags[r] == true end; saveConfig()
end)
local DropTracer = KillerHub.Elements["TracerFilters"]

VisualsTab:CreateSection("Gun ESP")
local ToggleGunCham = VisualsTab:CreateToggle("EspGunCham", "ESP Gun", function(val) Config.GunCham = val; saveConfig() end)
local ToggleGunName = VisualsTab:CreateToggle("EspGunName", "ESP Gun Name", function(val) Config.GunName = val; saveConfig() end)
local ToggleGunTracer = VisualsTab:CreateToggle("EspGunTracer", "ESP Gun Tracer", function(val) Config.GunTracer = val; saveConfig() end)

VisualsTab:CreateSection("Modify Role Colors")
local function createRoleColorPicker(roleKey, visualName)
    local defaultRGB = Config.CustomColorsRGB[roleKey]
    local defaultColor3 = Color3_fromRGB(defaultRGB[1], defaultRGB[2], defaultRGB[3])
    
    VisualsTab:CreateToggleColorPicker(
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

VisualsTab:CreateSection("Settings & Performance")
local DistanceInput = VisualsTab:CreateInput("EspMaxDistance", "Max Render Distance (Studs)", "400", function(val)
    local num = tonumber(val)
    if num then Config.MaxDistance = math_abs(num); saveConfig()
    else KillerHub:NotifyWarn("Valor Inválido", "Ingresa únicamente números para la distancia.", 3) end
end)
local NameSizeSlider = VisualsTab:CreateSlider("EspNameSize", "Name Size", 10, 30, function(val) Config.NameSize = math_floor(val); saveConfig() end)
local GunNameSizeSlider = VisualsTab:CreateSlider("EspGunNameSize", "Gun Name Size", 10, 30, function(val) Config.GunNameSize = math_floor(val); saveConfig() end)


-- [4] APPLY SAVED CONFIGURATIONS Safely
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
-- 🧠 CORE ENGINE (HYPER-OPTIMIZED WITH TRACERS)
-- ============================================================================

local playerRoles = {} 
local playerDeadStatus = {} 
local currentGunDrop = nil 

-- TRACER ENGINE (CACHE & RECYCLED DRAWINGS)
local GunDrawingLine = Drawing.new("Line")
GunDrawingLine.Thickness = 1
GunDrawingLine.Transparency = 1
GunDrawingLine.Visible = false

local playerTracers = {}

local function getTracerLine(player)
    if not playerTracers[player] then
        local line = Drawing.new("Line")
        line.Thickness = 1 -- Delgado para máximo FPS
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
    
    local humanoid = char and char:FindFirstChild("Humanoid")
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

local function clearPlayerESP(char)
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        local box = root:FindFirstChild("KH_2DBox")
        local nameTag = root:FindFirstChild("KH_Name")
        if box then box:Destroy() end
        if nameTag then nameTag:Destroy() end
    end
    
    local limbFolder = char:FindFirstChild("KH_LimbChams")
    if limbFolder then limbFolder:Destroy() end
    
    local hl = char:FindFirstChild("KH_Highlight")
    if hl then hl:Destroy() end
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

-- GROUND GUN ESP
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

-- REMOTE RETRIEVING (MM2 Logic Sync)
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
        for i = 1, #allPlayers do pcall(function() clearPlayerESP(allPlayers[i].Character) end) end
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
            pcall(updatePlayerESP, allPlayers[i])
        end
        pcall(updateGunESP)
        task.wait(0.1)
    end
end)

-- RENDER STEPPED (ULTRA-FAST 2D TRACERS ENGINE)
RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    if myRoot then
        local viewportSize = Camera.ViewportSize
        local screenBottom = Vector2_new(viewportSize.X / 2, viewportSize.Y)
        
        -- 1. JUGADORES TRACERS
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
                                line.From = screenBottom
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

        -- 2. ARMA TRACER
        if Config.GunTracer and currentGunDrop and currentGunDrop:IsDescendantOf(Workspace) and currentGunDrop:IsA("BasePart") then
            local distance = (myRoot.Position - currentGunDrop.Position).Magnitude
            local screenPos, onScreen = Camera:WorldToViewportPoint(currentGunDrop.Position)
            
            if onScreen and distance <= Config.MaxDistance then
                local gunColor = getRoleColor("GunDrop", DefaultColors.GunDrop)
                GunDrawingLine.From = screenBottom
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
        for _, line in pairs(playerTracers) do
            line.Visible = false
        end
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
    end
end)

return KillerHub
