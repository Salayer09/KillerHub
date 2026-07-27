-- ============================================================================
-- 👻 KILLER HUB - MM2 UNIFIED HIGHLIGHT ESP & INDEPENDENT HITBOX (V1.8)
-- ============================================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local fileName = "KillerHubMM2Config.json"
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Optimización de llamadas nativas (Local Cache)
local pairs = pairs
local ipairs = ipairs
local math_floor = math.floor
local math_abs = math.abs
local playersGetPlayers = Players.GetPlayers

-- Default game colors
local DefaultColors = {
    Murderer = Color3.fromRGB(180, 55, 55),
    Sheriff  = Color3.fromRGB(35, 102, 204),
    Hero     = Color3.fromRGB(230, 188, 62),
    Innocent = Color3.fromRGB(26, 171, 81),
    Dead     = Color3.fromRGB(115, 115, 115),
    GunDrop  = Color3.fromRGB(255, 0, 0)
}

-- [1] EXTENDED CONFIGURATION TABLE (Unified & Clean)
local Config = { 
    Highlight = false, 
    HighlightTrans = 50, -- Por defecto al 50% para bordes perfectos
    HighlightRoles = {["Murderer"] = false, ["Sheriff"] = false, ["Hero"] = false, ["Innocent"] = false, ["Dead/None"] = false},
    Box = false, BoxRoles = {["Murderer"] = false, ["Sheriff"] = false, ["Hero"] = false, ["Innocent"] = false, ["Dead/None"] = false},
    Name = false, NameRoles = {["Murderer"] = false, ["Sheriff"] = false, ["Hero"] = false, ["Innocent"] = false, ["Dead/None"] = false},
    GunCham = false,    
    GunName = false,    
    GunTracer = false, 
    NameSize = 13,      
    GunNameSize = 14,
    MaxDistance = 400,
    
    -- Hitbox Config
    Hitbox = false,
    HitboxSize = 2,
    HitboxTransparency = 40,
    HitboxMaterial = "SmoothPlastic",
    
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
local KillerHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paolo0109/KillerHUB/refs/heads/main/InterfazBase.lua"))()

-- VISUALS TAB
local VisualsTab = KillerHub:CreateTab("Visuals", "rbxassetid://6523858394")

VisualsTab:CreateSection("Player ESP")

-- 🛠️ COMPONENT UNIFICATION: Un solo Toggle+Slider arriba del todo configurado al 50%
local ToggleHighlight = VisualsTab:CreateToggleSlider("EspHighlight", "EspHighlightTrans", "Highlight ESP", 0, 100, 
    function(val) Config.Highlight = val; saveConfig() end,
    function(val) Config.HighlightTrans = math_floor(val); saveConfig() end
)
VisualsTab:CreateMultiDropdown("HighlightFilters", "Filters", {"Murderer", "Sheriff", "Hero", "Innocent", "Dead/None"}, function(flags)
    for r, _ in pairs(Config.HighlightRoles) do Config.HighlightRoles[r] = flags[r] == true end; saveConfig()
end)
local DropHighlight = KillerHub.Elements["HighlightFilters"]

local ToggleBox = VisualsTab:CreateToggle("EspBox", "ESP Box", function(val) Config.Box = val; saveConfig() end)
VisualsTab:CreateMultiDropdown("BoxFilters", "Filters", {"Murderer", "Sheriff", "Hero", "Innocent", "Dead/None"}, function(flags)
    for r, _ in pairs(Config.BoxRoles) do Config.BoxRoles[r] = flags[r] == true end; saveConfig()
end)
local DropBox = KillerHub.Elements["BoxFilters"]

local ToggleName = VisualsTab:CreateToggle("EspName", "ESP Name", function(val) Config.Name = val; saveConfig() end)
VisualsTab:CreateMultiDropdown("NameFilters", "Filters", {"Murderer", "Sheriff", "Hero", "Innocent", "Dead/None"}, function(flags)
    for r, _ in pairs(Config.NameRoles) do Config.NameRoles[r] = flags[r] == true end; saveConfig()
end)
local DropName = KillerHub.Elements["NameFilters"]

VisualsTab:CreateSection("Gun ESP")
local ToggleGunCham = VisualsTab:CreateToggle("EspGunCham", "ESP Gun", function(val) Config.GunCham = val; saveConfig() end)
local ToggleGunName = VisualsTab:CreateToggle("EspGunName", "ESP Gun Name", function(val) Config.GunName = val; saveConfig() end)
local ToggleGunTracer = VisualsTab:CreateToggle("EspGunTracer", "ESP Gun Tracer", function(val) Config.GunTracer = val; saveConfig() end)

VisualsTab:CreateSection("Role Colors")
local function createRoleColorPicker(roleKey, visualName)
    local defaultRGB = Config.CustomColorsRGB[roleKey]
    local defaultColor3 = Color3.fromRGB(defaultRGB[1], defaultRGB[2], defaultRGB[3])
    
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


-- HITBOX TAB
local HitboxTab = KillerHub:CreateTab("Hitbox", "rbxassetid://126768961562737")

HitboxTab:CreateSection("Hitbox Glow Engine")
local ToggleHitbox = HitboxTab:CreateToggle("HitboxEnabled", "Increase hitbox", function(val) Config.Hitbox = val; saveConfig() end)
local SliderSize = HitboxTab:CreateSlider("HitboxSize", "Size Scale", 2, 20, function(val) Config.HitboxSize = math_floor(val); saveConfig() end)
local SliderTrans = HitboxTab:CreateSlider("HitboxTransparency", "Center Glow Transparency", 0, 100, function(val) Config.HitboxTransparency = math_floor(val); saveConfig() end)

local MaterialDropdown = HitboxTab:CreateDropdown("HitboxMaterialSelect", "Hitbox Material", 
    {"SmoothPlastic", "Neon", "ForceField", "Glass", "Marble", "Ice", "Metal"}, 
    function(val) Config.HitboxMaterial = val; saveConfig() end
)


-- [4] APPLY SAVED CONFIGURATIONS Safely
ToggleName:Set(Config.Name)
ToggleGunCham:Set(Config.GunCham); ToggleGunName:Set(Config.GunName); ToggleGunTracer:Set(Config.GunTracer); NameSizeSlider:Set(Config.NameSize); GunNameSizeSlider:Set(Config.GunNameSize)
ToggleHitbox:Set(Config.Hitbox); SliderSize:Set(Config.HitboxSize); SliderTrans:Set(Config.HitboxTransparency)

-- Forzar la inicialización correcta del combo unificado
if ToggleHighlight then
    ToggleHighlight:SetToggle(Config.Highlight)
    ToggleHighlight:SetSlider(Config.HighlightTrans)
end

if DistanceInput and DistanceInput.Set then DistanceInput:Set(tostring(Config.MaxDistance)) end
if MaterialDropdown and MaterialDropdown.Set then MaterialDropdown:Set(Config.HitboxMaterial) end
if DropHighlight and DropHighlight.Set then pcall(function() DropHighlight:Set(Config.HighlightRoles) end) end
if DropBox and DropBox.Set then pcall(function() DropBox:Set(Config.BoxRoles) end) end
if DropName and DropName.Set then pcall(function() DropName:Set(Config.NameRoles) end) end

for roleKey, _ in pairs(Config.CustomColorsActive) do
    local toggleInstance = getgenv().KillerHub and getgenv().KillerHub.Flags and getgenv().KillerHub.Flags["CP_Active_" .. roleKey]
    if toggleInstance and toggleInstance.Set then toggleInstance:Set(Config.CustomColorsActive[roleKey]) end
end


-- ============================================================================
-- 🧠 CORE ENGINE
-- ============================================================================

local playerRoles = {} 
local playerDeadStatus = {} 
local currentGunDrop = nil 

local GunDrawingLine = Drawing.new("Line")
GunDrawingLine.Thickness = 1.5
GunDrawingLine.Transparency = 1
GunDrawingLine.Visible = false

local function getRoleColor(roleKey, fallbackColor3)
    if Config.CustomColorsActive[roleKey] == true then
        local rgb = Config.CustomColorsRGB[roleKey]
        return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
    end
    return fallbackColor3
end

local function getPlayerColorAndStatus(player)
    local char = player.Character
    local name = player.Name
    
    local isDeadInNetwork = playerDeadStatus[name] == true
    local isDeadInGame = char and char:FindFirstChild("Humanoid") and char.Humanoid.Health <= 0
    local role = playerRoles[name]
    local hasNoRole = (role == nil or role == "" or role == "Spectator")

    if isDeadInNetwork or isDeadInGame or hasNoRole then
        return getRoleColor("Dead/None", DefaultColors.Dead), "Dead/None"
    end

    local backpack = player:FindFirstChild("Backpack")
    local hasKnife = (char and char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife"))
    local hasGun = (char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver"))) or 
                   (backpack and (backpack:FindFirstChild("Gun") or backpack:FindFirstChild("Revolver")))

    if hasKnife or role == "Murderer" then 
        playerRoles[name] = "Murderer"
        return getRoleColor("Murderer", DefaultColors.Murderer), "Murderer"
    end

    if hasGun then
        if role == "Sheriff" then return getRoleColor("Sheriff", DefaultColors.Sheriff), "Sheriff"
        else return getRoleColor("Hero", DefaultColors.Hero), "Hero" end
    end

    if role == "Sheriff" then return getRoleColor("Sheriff", DefaultColors.Sheriff), "Sheriff"
    elseif role == "Hero" then return getRoleColor("Hero", DefaultColors.Hero), "Hero"
    else return getRoleColor("Innocent", DefaultColors.Innocent), "Innocent" end
end

local function clearPlayerESP(char)
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        local box = root:FindFirstChild("KH_2DBox")
        local nameTag = root:FindFirstChild("KH_Name")
        if box then box:Destroy() end
        if nameTag then nameTag:Destroy() end
        
        pcall(function()
            root.Size = Vector3.new(2, 2, 1)
            root.Transparency = 1
        end)
    end
    
    local visualHitboxModel = char:FindFirstChild("KH_GlowHitboxModel")
    if visualHitboxModel then visualHitboxModel:Destroy() end
    
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

    -- 🎯 HITBOX GLOW ENGINE (Completamente independiente del ESP)
    local visualHitboxModel = char:FindFirstChild("KH_GlowHitboxModel")
    if Config.Hitbox then
        pcall(function()
            root.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
            root.Transparency = 1
            root.CanCollide = false
            
            if not visualHitboxModel then
                visualHitboxModel = Instance.new("Model")
                visualHitboxModel.Name = "KH_GlowHitboxModel"
                
                local visualPart = Instance.new("Part")
                visualPart.Name = "HitboxCube"
                visualPart.CanCollide = false
                visualPart.Massless = true
                visualPart.CastShadow = false
                visualPart.Anchored = false
                visualPart.Transparency = 0.99 
                visualPart.Material = Enum.Material[Config.HitboxMaterial]
                visualPart.CFrame = root.CFrame
                visualPart.Parent = visualHitboxModel
                
                local weld = Instance.new("WeldConstraint")
                weld.Name = "KH_Weld"
                weld.Part0 = root
                weld.Part1 = visualPart
                weld.Parent = visualPart
                
                local glow = Instance.new("Highlight")
                glow.Name = "KH_GlowEffect"
                glow.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                glow.OutlineTransparency = 0 
                glow.Parent = visualHitboxModel
                
                visualHitboxModel.Parent = char
            end
            
            local cube = visualHitboxModel:FindFirstChild("HitboxCube")
            local glow = visualHitboxModel:FindFirstChild("KH_GlowEffect")
            
            if cube and glow then
                cube.Size = root.Size
                cube.Material = Enum.Material[Config.HitboxMaterial] 
                
                glow.FillColor = color
                glow.OutlineColor = color
                -- 🛠️ CORRECCIÓN: El slider de la Hitbox solo cambia a la Hitbox
                glow.FillTransparency = Config.HitboxTransparency / 100 
                glow.Enabled = (Config.HitboxTransparency < 100)
            end
        end)
    else
        if visualHitboxModel then visualHitboxModel:Destroy() end
        pcall(function()
            root.Size = Vector3.new(2, 2, 1)
            root.Transparency = 1
        end)
    end

    -- 🟥 BOX 2D
    local box = root:FindFirstChild("KH_2DBox")
    if Config.Box and Config.BoxRoles[currentStatus] == true then
        if not box then
            box = Instance.new("BillboardGui"); box.Name = "KH_2DBox"; box.Size = UDim2.new(4.4, 0, 5.9, 0); box.AlwaysOnTop = true
            local frame = Instance.new("Frame"); frame.Size = UDim2.new(1, 0, 1, 0); frame.BackgroundTransparency = 1; frame.Parent = box
            local stroke = Instance.new("UIStroke"); stroke.Thickness = 1.2; stroke.Name = "Outline"; stroke.Parent = frame
            box.Adornee = root; box.Parent = root
        end
        box.Frame.Outline.Color = color
    else
        if box then box:Destroy() end
    end

    -- 🏷️ NAME ESP
    local nameTag = root:FindFirstChild("KH_Name")
    if Config.Name and Config.NameRoles[currentStatus] == true then
        if not nameTag then
            nameTag = Instance.new("BillboardGui"); nameTag.Name = "KH_Name"; nameTag.Size = UDim2.new(0, 160, 0, 40); nameTag.StudsOffset = Vector3.new(0, 4.0, 0); nameTag.AlwaysOnTop = true
            local label = Instance.new("TextLabel"); label.Name = "Display"; label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1
            label.Font = Enum.Font.SourceSansBold; label.TextStrokeTransparency = 0.3; label.Parent = nameTag
            nameTag.Adornee = root; nameTag.Parent = root
        end
        nameTag.Display.Text = player.Name
        nameTag.Display.TextColor3 = color
        nameTag.Display.TextSize = Config.NameSize
    else
        if nameTag then nameTag:Destroy() end
    end

    -- 🌟 UNIFIED HIGHLIGHT ENGINE (Outline dinámico e independiente)
    local hl = char:FindFirstChild("KH_Highlight")
    local allowHighlight = Config.Highlight and Config.HighlightRoles[currentStatus] == true

    if allowHighlight then
        if not hl then
            hl = Instance.new("Highlight"); hl.Name = "KH_Highlight"; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = char
        end
        hl.Adornee = char
        hl.FillColor = color
        -- 🛠️ CORRECCIÓN: Su propio slider exclusivo controla la opacidad del centro del jugador
        hl.FillTransparency = Config.HighlightTrans / 100 
        hl.OutlineColor = color
        hl.OutlineTransparency = 0 -- Bordes siempre definidos y limpios
    else
        if hl then hl:Destroy() end
    end
end

-- 📡 GROUND GUN ESP
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
                hl = Instance.new("Highlight"); hl.Name = "KH_GunHighlight"; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Adornee = currentGunDrop; hl.Parent = currentGunDrop
            end
            hl.FillColor = gunColor; hl.FillTransparency = 0; hl.OutlineTransparency = 1      
        elseif hl then hl:Destroy() end

        local nameTag = currentGunDrop:FindFirstChild("KH_GunName")
        if Config.GunName then
            if not nameTag then
                nameTag = Instance.new("BillboardGui"); nameTag.Name = "KH_GunName"; nameTag.Size = UDim2.new(0, 180, 0, 40); nameTag.StudsOffset = Vector3.new(0, 2.5, 0); nameTag.AlwaysOnTop = true
                local label = Instance.new("TextLabel"); label.Name = "Display"; label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1
                label.Font = Enum.Font.SourceSansBold; label.TextStrokeTransparency = 0.1; label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); label.Text = "GUN HERE 🩸"; label.Parent = nameTag
                nameTag.Adornee = currentGunDrop; nameTag.Parent = currentGunDrop
            end
            nameTag.Display.TextColor3 = gunColor
            nameTag.Display.TextSize = Config.GunNameSize
        elseif nameTag then nameTag:Destroy() end
    end
end

-- 📡 REMOTE RETRIEVING
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
end)

-- 🕒 REFRESH LOOP (Performance Cached)
task.spawn(function()
    while true do
        local allPlayers = playersGetPlayers(Players)
        for i = 1, #allPlayers do
            pcall(updatePlayerESP, allPlayers[i])
        end
        pcall(updateGunESP)
        task.wait(0.2)
    end
end)

-- 🚀 HIGH-PRECISION TRACER ENGINE
RunService.RenderStepped:Connect(function()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if Config.GunTracer and currentGunDrop and currentGunDrop:IsDescendantOf(Workspace) and currentGunDrop:IsA("BasePart") and myRoot then
        
        local distance = (myRoot.Position - currentGunDrop.Position).Magnitude
        local screenPos, onScreen = Camera:WorldToViewportPoint(currentGunDrop.Position)
        
        if onScreen and distance <= Config.MaxDistance then
            local viewportSize = Camera.ViewportSize
            local gunColor = getRoleColor("GunDrop", DefaultColors.GunDrop)
            
            GunDrawingLine.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
            GunDrawingLine.To = Vector2.new(screenPos.X, screenPos.Y)
            GunDrawingLine.Color = gunColor
            GunDrawingLine.Visible = true
        else
            GunDrawingLine.Visible = false
        end
    else
        GunDrawingLine.Visible = false
    end
end)

game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "KillerHub" then GunDrawingLine:Remove() end
end)

return KillerHub
