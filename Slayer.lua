-- ============================================================================
-- 👁️ KILLER HUB - MM2 ADVANCED VISUALS (UNIVERSAL GUN TRACKER & AUTO-SAVE)
-- ============================================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local fileName = "KillerHubMM2Config.json"
local LocalPlayer = Players.LocalPlayer

-- [1] TABLA DE CONFIGURACIÓN (Valores Predeterminados)
local Config = { 
    Chams = false, 
    Outline = false, 
    Highlight = false, 
    Box = false, 
    Name = false,
    GunCham = false,    
    GunName = false,    
    NameSize = 13,      
    GunNameSize = 14    
}

-- [2] SISTEMA DE ALMACENAMIENTO LOCAL (Autoguardado)
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
                Config[k] = v
            end
        end
    end)
end

-- [3] INTERFAZ GRÁFICA INSTANTÁNEA
local KillerHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paolo0109/KillerHUB/refs/heads/main/InterfazBase.lua"))()
local VisualsTab = KillerHub:CreateTab("Visuales", "rbxassetid://10747372517")

VisualsTab:CreateSection("Murder Mystery 2 - Opciones ESP Jugadores")

local ToggleCham = VisualsTab:CreateToggle("EspCham", "Habilitar ESP Cham (Relleno Completo)", function(val) Config.Chams = val; saveConfig() end)
local ToggleOutline = VisualsTab:CreateToggle("EspOutline", "Habilitar ESP Outline (Contorno)", function(val) Config.Outline = val; saveConfig() end)
local ToggleHighlight = VisualsTab:CreateToggle("EspHighlight", "Habilitar ESP Highlight (Completo)", function(val) Config.Highlight = val; saveConfig() end)
local ToggleBox = VisualsTab:CreateToggle("EspBox", "Habilitar ESP Box (Marco 2D Delgado)", function(val) Config.Box = val; saveConfig() end)
local ToggleName = VisualsTab:CreateToggle("EspName", "Habilitar ESP Name (Solo Nombre)", function(val) Config.Name = val; saveConfig() end)

VisualsTab:CreateSection("Murder Mystery 2 - Opciones ESP Pistola")

local ToggleGunCham = VisualsTab:CreateToggle("EspGunCham", "Habilitar ESP Gun (Pistola en Suelo)", function(val) Config.GunCham = val; saveConfig() end)
local ToggleGunName = VisualsTab:CreateToggle("EspGunName", "Habilitar ESP Gun Name (Texto Pistola)", function(val) Config.GunName = val; saveConfig() end)

VisualsTab:CreateSection("Ajustes de Tamaño (Texto)")

local NameSizeSlider = VisualsTab:CreateSlider("EspNameSize", "Tamaño del ESP Name (Jugadores)", 10, 30, function(val)
    Config.NameSize = math.floor(val)
    saveConfig()
end)

local GunNameSizeSlider = VisualsTab:CreateSlider("EspGunNameSize", "Tamaño del ESP Gun Name", 10, 30, function(val)
    Config.GunNameSize = math.floor(val)
    saveConfig()
end)

-- [4] APLICAR ESTADOS GUARDADOS A LA INTERFAZ
ToggleCham:Set(Config.Chams)
ToggleOutline:Set(Config.Outline)
ToggleHighlight:Set(Config.Highlight)
ToggleBox:Set(Config.Box)
ToggleName:Set(Config.Name)
ToggleGunCham:Set(Config.GunCham)
ToggleGunName:Set(Config.GunName)
NameSizeSlider:Set(Config.NameSize)
GunNameSizeSlider:Set(Config.GunNameSize)

-- ============================================================================
-- 🧠 MOTOR ULTRA-OPTIMIZADO EVENT-DRIVEN (Zero Lag)
-- ============================================================================

local playerRoles = {} 
local playerDeadStatus = {} 
local currentGunDrop = nil 

-- 🎨 PALETA DE COLORES CALIBRADA
local ColorMurderer = Color3.fromRGB(180, 55, 55)   
local ColorSheriff  = Color3.fromRGB(35, 102, 204)   
local ColorHero     = Color3.fromRGB(230, 188, 62)  
local ColorInnocent = Color3.fromRGB(26, 171, 81)   
local ColorDead     = Color3.fromRGB(90, 90, 90)    
local ColorGunDrop  = Color3.fromRGB(255, 0, 0)     

-- 🔍 DETECTOR AVANZADO DE ROLES Y RESPALDO POR ARMAS
local function getPlayerColor(player)
    local char = player.Character
    local name = player.Name
    
    local isDeadInNetwork = playerDeadStatus[name] == true
    local isDeadInGame = char and char:FindFirstChild("Humanoid") and char.Humanoid.Health <= 0

    if isDeadInNetwork or isDeadInGame then
        return ColorDead
    end

    -- Escaneo rápido de inventario por si los remotos fallan o tardan en actualizar
    local backpack = player:FindFirstChild("Backpack")
    local hasKnife = (char and char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife"))
    local hasGun = (char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver"))) or 
                   (backpack and (backpack:FindFirstChild("Gun") or backpack:FindFirstChild("Revolver")))

    if hasKnife then playerRoles[name] = "Murderer" end

    local role = playerRoles[name]
    if role == "Murderer" then 
        return ColorMurderer 
    elseif role == "Sheriff" then 
        return ColorSheriff
    elseif hasGun or role == "Hero" then 
        return ColorHero 
    else 
        return ColorInnocent 
    end
end

-- 📡 CONTROLADOR DE ACTUALIZACIÓN INDIVIDUAL DE ESP
local function updatePlayerESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local color = getPlayerColor(player)

    -- 🟥 CONTROL BOX 2D
    local box = root:FindFirstChild("KH_2DBox")
    if Config.Box then
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
    if Config.Name then
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
        nameTag.Display.TextSize = Config.NameSize
    else
        if nameTag then nameTag:Destroy() end
    end

    -- 🌟 CONTROL HIGHLIGHT / CHAM JUGADORES
    local hl = char:FindFirstChild("KH_Highlight")
    if Config.Chams or Config.Outline or Config.Highlight then
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = "KH_Highlight"
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = char
        end
        
        hl.Adornee = char
        
        if Config.Highlight then
            hl.FillColor = color
            hl.FillTransparency = 0.4
            hl.OutlineColor = color
            hl.OutlineTransparency = 0
        elseif Config.Chams then
            hl.FillColor = color
            hl.FillTransparency = 0.18
            hl.OutlineTransparency = 1
        elseif Config.Outline then
            hl.FillTransparency = 1
            hl.OutlineColor = color
            hl.OutlineTransparency = 0
        end
    else
        if hl then hl:Destroy() end
    end
end

-- 📡 ESCÁNER EFICIENTE DE PISTOLA TIRADA
local function processGunDrop(part)
    if part and part.Name == "GunDrop" and part:IsA("BasePart") then
        currentGunDrop = part
    end
end

local function updateGunESP()
    if currentGunDrop and currentGunDrop:IsDescendantOf(workspace) then
        -- 🔴 ESP Cham Pistola
        local hl = currentGunDrop:FindFirstChild("KH_GunHighlight")
        if Config.GunCham then
            if not hl then
                hl = Instance.new("Highlight")
                hl.Name = "KH_GunHighlight"
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Adornee = currentGunDrop
                hl.Parent = currentGunDrop
            end
            hl.FillColor = ColorGunDrop
            hl.FillTransparency = 0         
            hl.OutlineTransparency = 1      
        else
            if hl then hl:Destroy() end
        end

        -- 🩸 ESP Name Pistola
        local nameTag = currentGunDrop:FindFirstChild("KH_GunName")
        if Config.GunName then
            if not nameTag then
                nameTag = Instance.new("BillboardGui")
                nameTag.Name = "KH_GunName"
                nameTag.Size = UDim2.new(0, 180, 0, 40)
                nameTag.StudsOffset = Vector3.new(0, 2.5, 0) 
                nameTag.AlwaysOnTop = true
                
                local label = Instance.new("TextLabel")
                label.Name = "Display"
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.SourceSansBold
                label.TextStrokeTransparency = 0.1
                label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                label.TextColor3 = ColorGunDrop
                label.Text = "GUN HERE 🩸"
                label.Parent = nameTag
                
                nameTag.Adornee = currentGunDrop
                nameTag.Parent = currentGunDrop
            end
            nameTag.Display.TextSize = Config.GunNameSize
        else
            if nameTag then nameTag:Destroy() end
        end
    else
        currentGunDrop = nil
    end
end

-- 📡 CAPTURADOR DE RED (Remotes)
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

if PlayerDataChanged and PlayerDataChanged:IsA("RemoteEvent") then
    PlayerDataChanged.OnClientEvent:Connect(parsePlayerData)
end

if RoundStart and RoundStart:IsA("RemoteEvent") then
    RoundStart.OnClientEvent:Connect(function(arg1, arg2)
        table.clear(playerRoles)
        table.clear(playerDeadStatus)
        currentGunDrop = nil 
        parsePlayerData(arg2)
        parsePlayerData(arg1)
    end)
end

-- 🧹 RECOLECTOR DE BASURA (Evita Memory Leaks)
Players.PlayerRemoving:Connect(function(player)
    playerRoles[player.Name] = nil
    playerDeadStatus[player.Name] = nil
end)

-- 👁️ ESCUCHA INTELIGENTE DE INSTANCIAS DE PISTOLA
workspace.ChildAdded:Connect(processGunDrop)
for _, v in pairs(workspace:GetDescendants()) do processGunDrop(v) end

-- 🕒 LOOP UNIFICADO BASADO EN TIEMPO (Estable y sin micro-stuttering)
task.spawn(function()
    while true do
        for _, p in pairs(Players:GetPlayers()) do
            pcall(updatePlayerESP, p)
        end
        pcall(updateGunESP)
        task.wait(0.15) -- Frecuencia óptima para balancear respuesta visual y rendimiento
    end
end)

return KillerHub
