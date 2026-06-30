-- ============================================================================
-- 👁️ KILLER HUB - MM2 ADVANCED VISUALS (UNIVERSAL GUN TRACKER & AUTO-SAVE V2.6)
-- ============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- [1] CARGA DEL CORE ORIGINAL Y PERSISTENCIA NATIVA
local KillerHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paolo0109/KillerHUB/refs/heads/main/InterfazBase.lua"))()
KillerHub:EnableAutosave("MurderMystery2_Config.json")
KillerHub:SetTheme("Blood")

-- [2] CREACIÓN DE PESTAÑA VISUALES
local VisualsTab = KillerHub:CreateTab("Visuales", "rbxassetid://10747372517")

VisualsTab:CreateSection("Murder Mystery 2 - Opciones ESP Jugadores")

-- 1. CHAMS ESP
VisualsTab:CreateToggle("EspCham", "Habilitar ESP Cham (Relleno Completo)", false, function(_) end)
VisualsTab:CreateMultiDropdown("ChamFilters", "└─ Aplicar Cham a (Múltiple):", {"Murderer", "Sheriff", "Hero", "Innocent", "Dead/None"}, function(_) end)

-- 2. OUTLINE ESP
VisualsTab:CreateToggle("EspOutline", "Habilitar ESP Outline (Contorno)", false, function(_) end)
VisualsTab:CreateMultiDropdown("OutlineFilters", "└─ Aplicar Outline a (Múltiple):", {"Murderer", "Sheriff", "Hero", "Innocent", "Dead/None"}, function(_) end)

-- 3. HIGHLIGHT ESP
VisualsTab:CreateToggle("EspHighlight", "Habilitar ESP Highlight (Completo)", false, function(_) end)
VisualsTab:CreateMultiDropdown("HighlightFilters", "└─ Aplicar Highlight a (Múltiple):", {"Murderer", "Sheriff", "Hero", "Innocent", "Dead/None"}, function(_) end)

-- 4. BOX ESP
VisualsTab:CreateToggle("EspBox", "Habilitar ESP Box (Marco 2D Delgado)", false, function(_) end)
VisualsTab:CreateMultiDropdown("BoxFilters", "└─ Aplicar Box a (Múltiple):", {"Murderer", "Sheriff", "Hero", "Innocent", "Dead/None"}, function(_) end)

-- 5. NAME ESP
VisualsTab:CreateToggle("EspName", "Habilitar ESP Name (Solo Nombre)", false, function(_) end)
VisualsTab:CreateMultiDropdown("NameFilters", "└─ Aplicar Name a (Múltiple):", {"Murderer", "Sheriff", "Hero", "Innocent", "Dead/None"}, function(_) end)


VisualsTab:CreateSection("Murder Mystery 2 - Opciones ESP Pistola")

VisualsTab:CreateToggle("EspGunCham", "Habilitar ESP Gun (Pistola en Suelo)", false, function(_) end)
VisualsTab:CreateToggle("EspGunName", "Habilitar ESP Gun Name (Texto Pistola)", false, function(_) end)


VisualsTab:CreateSection("Ajustes de Tamaño (Texto)")

VisualsTab:CreateSlider("EspNameSize", "Tamaño del ESP Name (Jugadores)", 10, 30, 13, function(_) end)
VisualsTab:CreateSlider("EspGunNameSize", "Tamaño del ESP Gun Name", 10, 30, 14, function(_) end)


-- ============================================================================
-- 🧠 MOTOR ULTRA-OPTIMIZADO CON EXTRACCIÓN SEGURA DE BANDERAS (V2.6)
-- ============================================================================

local playerRoles = {} 
local playerDeadStatus = {} 
local currentGunDrop = nil 

local ColorMurderer = Color3.fromRGB(180, 55, 55)   
local ColorSheriff  = Color3.fromRGB(35, 102, 204)   
local ColorHero     = Color3.fromRGB(230, 188, 62)  
local ColorInnocent = Color3.fromRGB(26, 171, 81)   
local ColorDead     = Color3.fromRGB(115, 115, 115)   
local ColorGunDrop  = Color3.fromRGB(255, 0, 0)     

-- Función utilitaria para leer de manera segura las Flags de KillerHub
local function getFlagValue(flagName, subKey)
    if KillerHub.Flags and KillerHub.Flags[flagName] then
        local flag = KillerHub.Flags[flagName]
        if subKey then
            -- Para MultiDropdowns / tablas
            return flag.CurrentValue and flag.CurrentValue[subKey] or false
        else
            -- Para Toggles y Sliders
            return flag.CurrentValue
        end
    end
    return false
end

local function getPlayerColorAndStatus(player)
    local char = player.Character
    local name = player.Name
    
    local isDeadInNetwork = playerDeadStatus[name] == true
    local isDeadInGame = char and char:FindFirstChild("Humanoid") and char.Humanoid.Health <= 0
    local role = playerRoles[name]
    local hasNoRole = (role == nil or role == "" or role == "Spectator")

    if isDeadInNetwork or isDeadInGame or hasNoRole then
        return ColorDead, "Dead/None"
    end

    local backpack = player:FindFirstChild("Backpack")
    local hasKnife = (char and char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife"))
    local hasGun = (char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver"))) or 
                   (backpack and (backpack:FindFirstChild("Gun") or backpack:FindFirstChild("Revolver")))

    if hasKnife then 
        playerRoles[name] = "Murderer"
        return ColorMurderer, "Murderer"
    end

    if role == "Murderer" then 
        return ColorMurderer, "Murderer"
    elseif role == "Sheriff" then 
        return ColorSheriff, "Sheriff"
    elseif hasGun or role == "Hero" then 
        return ColorHero, "Hero"
    else 
        return ColorInnocent, "Innocent"
    end
end

local function updatePlayerESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local color, currentStatus = getPlayerColorAndStatus(player)

    -- 🟥 CONTROL BOX 2D
    local box = root:FindFirstChild("KH_2DBox")
    if getFlagValue("EspBox") and getFlagValue("BoxFilters", currentStatus) then
        if not box then
            box = Instance.new("BillboardGui")
            box.Name = "KH_2DBox"
            box.Size = UDim2.new(4.4, 0, 5.9, 0)
            box.AlwaysOnTop = true
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 1
            frame.Parent = box
            
            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1.2
            stroke.Name = "Outline"
            stroke.Parent = frame
           
            box.Adornee = root
            box.Parent = root
        end
        box.Frame.Outline.Color = color
    else
        if box then box:Destroy() end
    end

    -- 🏷️ CONTROL NAME JUGADORES
    local nameTag = root:FindFirstChild("KH_Name")
    if getFlagValue("EspName") and getFlagValue("NameFilters", currentStatus) then
        if not nameTag then
            nameTag = Instance.new("BillboardGui")
            nameTag.Name = "KH_Name"
            nameTag.Size = UDim2.new(0, 160, 0, 40)
            nameTag.StudsOffset = Vector3.new(0, 4.0, 0)
            nameTag.AlwaysOnTop = true
            
            local label = Instance.new("TextLabel")
            label.Name = "Display"
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.SourceSansBold
            label.TextStrokeTransparency = 0.3
            label.Parent = nameTag
            
            nameTag.Adornee = root
            nameTag.Parent = root
        end
        nameTag.Display.Text = player.Name
        nameTag.Display.TextColor3 = color
        nameTag.Display.TextSize = getFlagValue("EspNameSize") or 13
    else
        if nameTag then nameTag:Destroy() end
    end

    -- 🌟 CONTROL HIGHLIGHT / CHAM / OUTLINE
    local hl = char:FindFirstChild("KH_Highlight")
    
    local allowHighlight = getFlagValue("EspHighlight") and getFlagValue("HighlightFilters", currentStatus)
    local allowChams = getFlagValue("EspCham") and getFlagValue("ChamFilters", currentStatus)
    local allowOutline = getFlagValue("EspOutline") and getFlagValue("OutlineFilters", currentStatus)

    if allowHighlight or allowChams or allowOutline then
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = "KH_Highlight"
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = char
        end
        
        hl.Adornee = char
        
        if allowHighlight then
            hl.FillColor = color
            hl.FillTransparency = 0.4
            hl.OutlineColor = color
            hl.OutlineTransparency = 0
        elseif allowChams then
            hl.FillColor = color
            hl.FillTransparency = 0.18
            hl.OutlineTransparency = 1
        elseif allowOutline then
            hl.FillTransparency = 1
            hl.OutlineColor = color
            hl.OutlineTransparency = 0
        end
    else
        if hl then hl:Destroy() end
    end
end

-- 📡 CONTROL DE PISTOLA EN SUELO
local function checkGunInstance(part)
    if part and part.Name == "GunDrop" and part:IsA("BasePart") then currentGunDrop = part end
end
workspace.ChildAdded:Connect(checkGunInstance)

local function updateGunESP()
    if not currentGunDrop or not currentGunDrop:IsDescendantOf(workspace) then
        currentGunDrop = workspace:FindFirstChild("GunDrop", true)
    end

    if currentGunDrop and currentGunDrop:IsA("BasePart") then
        local hl = currentGunDrop:FindFirstChild("KH_GunHighlight")
        if getFlagValue("EspGunCham") then
            if not hl then
                hl = Instance.new("Highlight"); hl.Name = "KH_GunHighlight"
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Adornee = currentGunDrop; hl.Parent = currentGunDrop
            end
            hl.FillColor = ColorGunDrop; hl.FillTransparency = 0; hl.OutlineTransparency = 1      
        else 
            if hl then hl:Destroy() end 
        end

        local nameTag = currentGunDrop:FindFirstChild("KH_GunName")
        if getFlagValue("EspGunName") then
            if not nameTag then
                nameTag = Instance.new("BillboardGui"); nameTag.Name = "KH_GunName"
                nameTag.Size = UDim2.new(0, 180, 0, 40); nameTag.StudsOffset = Vector3.new(0, 2.5, 0); nameTag.AlwaysOnTop = true
                local label = Instance.new("TextLabel"); label.Name = "Display"; label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1
                label.Font = Enum.Font.SourceSansBold; label.TextStrokeTransparency = 0.1; label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                label.TextColor3 = ColorGunDrop; label.Text = "GUN HERE 🩸"; label.Parent = nameTag; nameTag.Adornee = currentGunDrop; nameTag.Parent = currentGunDrop
            end
            nameTag.Display.TextSize = getFlagValue("EspGunNameSize") or 14
        else 
            if nameTag then nameTag:Destroy() end 
        end
    end
end

-- 📡 ESCUCHAS DE RED
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

Players.PlayerRemoving:Connect(function(player)
    playerRoles[player.Name] = nil; playerDeadStatus[player.Name] = nil
end)

-- 🕒 BUCLE DE RENDERIZADO
task.spawn(function()
    while true do
        for _, p in pairs(Players:GetPlayers()) do pcall(updatePlayerESP, p) end
        pcall(updateGunESP)
        task.wait(0.2)
    end
end)

-- ============================================================================
-- 🔗 RETORNO DE API CORRECTO (V2.6)
-- ============================================================================
return KillerHub
