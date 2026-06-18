-- ============================================================================
-- 👁️ KILLER HUB - MM2 ADVANCED VISUALS (UNIVERSAL GUN TRACKER & SIZE ENGINE)
-- ============================================================================

-- [1] INTERFAZ GRÁFICA INSTANTÁNEA
local KillerHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paolo0109/KillerHUB/refs/heads/main/InterfazBase.lua"))()
local VisualsTab = KillerHub:CreateTab("Visuales", "rbxassetid://10747372517")

VisualsTab:CreateSection("Murder Mystery 2 - Opciones ESP Jugadores")

local Config = { 
    Chams = false, 
    Outline = false, 
    Highlight = false, 
    Box = false, 
    Name = false,
    GunCham = false,    -- Interruptor para el ESP de la pistola
    GunName = false,    -- Interruptor para el texto de la pistola
    NameSize = 13,      
    GunNameSize = 14    
}

VisualsTab:CreateToggle("EspCham", "Habilitar ESP Cham (Relleno Completo)", function(val) Config.Chams = val end)
VisualsTab:CreateToggle("EspOutline", "Habilitar ESP Outline (Contorno)", function(val) Config.Outline = val end)
VisualsTab:CreateToggle("EspHighlight", "Habilitar ESP Highlight (Completo)", function(val) Config.Highlight = val end)
VisualsTab:CreateToggle("EspBox", "Habilitar ESP Box (Marco 2D Delgado)", function(val) Config.Box = val end)
VisualsTab:CreateToggle("EspName", "Habilitar ESP Name (Solo Nombre)", function(val) Config.Name = val end)

VisualsTab:CreateSection("Murder Mystery 2 - Opciones ESP Pistola")

-- [NUEVOS BOTONES DE ACTIVACIÓN PARA LA PISTOLA]
VisualsTab:CreateToggle("EspGunCham", "Habilitar ESP Gun (Pistola en Suelo)", function(val) Config.GunCham = val end)
VisualsTab:CreateToggle("EspGunName", "Habilitar ESP Gun Name (Texto Pistola)", function(val) Config.GunName = val end)

VisualsTab:CreateSection("Ajustes de Tamaño (Texto)")

local NameSizeSlider = VisualsTab:CreateSlider("EspNameSize", "Tamaño del ESP Name (Jugadores)", 10, 30, function(val)
    Config.NameSize = math.floor(val)
end)
NameSizeSlider:Set(13)

local GunNameSizeSlider = VisualsTab:CreateSlider("EspGunNameSize", "Tamaño del ESP Gun Name", 10, 30, function(val)
    Config.GunNameSize = math.floor(val)
end)
GunNameSizeSlider:Set(14)

-- ============================================================================
-- 🧠 MOTOR ULTRA-OPTIMIZADO (Zero Lag, Multi-Map Gun Drop Scraper)
-- ============================================================================
task.spawn(function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer
    
    local playerRoles = {} 
    local playerDeadStatus = {} 
    local currentGunDrop = nil 

    -- 🎨 PALETA DE COLORES CALIBRADA
    local ColorMurderer = Color3.fromRGB(185, 25, 25)   
    local ColorSheriff  = Color3.fromRGB(25, 85, 195)   
    local ColorHero     = Color3.fromRGB(210, 160, 10)  
    local ColorInnocent = Color3.fromRGB(25, 150, 25)   
    local ColorDead     = Color3.fromRGB(90, 90, 90)    
    local ColorGunDrop  = Color3.fromRGB(255, 0, 0)     -- Rojo Intenso Absoluto

    -- 🔍 DETECTOR AVANZADO DE ROLES Y RESPALDO POR ARMAS
    local function getPlayerColor(player)
        local char = player.Character
        local name = player.Name
        
        local backpack = player:FindFirstChild("Backpack")
        local hasKnife = (char and char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife"))
        local hasGun = (char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver"))) or 
                       (backpack and (backpack:FindFirstChild("Gun") or backpack:FindFirstChild("Revolver")))

        if hasKnife then playerRoles[name] = "Murderer" end

        local isDeadInNetwork = playerDeadStatus[name] == true
        local isDeadInGame = char and char:FindFirstChild("Humanoid") and char.Humanoid.Health <= 0
        local hasNoRole = playerRoles[name] == nil or playerRoles[name] == "" or playerRoles[name] == "Spectator"

        if isDeadInNetwork or isDeadInGame or hasNoRole then
            return ColorDead
        end

        local role = playerRoles[name]
        if role == "Murderer" then 
            return ColorMurderer 
        elseif role == "Sheriff" then 
            return ColorSheriff
        elseif hasGun then 
            return ColorHero 
        else 
            return ColorInnocent 
        end
    end

    -- 📡 ESCÁNER UNIVERSAL DE PISTOLA EN EL SUELO (Lógica de Botones Integrada)
    local function updateGunESP()
        if not currentGunDrop or not currentGunDrop:IsDescendantOf(workspace) then
            currentGunDrop = workspace:FindFirstChild("GunDrop", true)
        end

        if currentGunDrop and currentGunDrop:IsA("BasePart") then
            -- 🔴 1. ESP Cham (Highlight) para la Pistola Tirada
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
                hl.FillTransparency = 0         -- 100% Opaco (Rojo Sólido)
                hl.OutlineTransparency = 1      -- Quitar bordes blancos por completo
            else
                if hl then hl:Destroy() end
            end

            -- 🩸 2. ESP Name para la Pistola Tirada
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
        end
    end

    -- 📡 CAPTURADOR DE RED (PlayerDataChanged)
    local PlayerDataChanged = ReplicatedStorage:FindFirstChild("PlayerDataChanged", true)
    
    local function parsePlayerData(tabla)
        if type(tabla) == "table" then
            for name, data in pairs(tabla) do
                if type(data) == "table" then
                    if data.Role then
                        playerRoles[name] = data.Role
                    end
                    if data.Dead ~= nil then
                        playerDeadStatus[name] = data.Dead
                    end
                end
            end
        end
    end

    if PlayerDataChanged and PlayerDataChanged:IsA("RemoteEvent") then
        PlayerDataChanged.OnClientEvent:Connect(parsePlayerData)
    end

    local RoundStart = ReplicatedStorage:FindFirstChild("RoundStart", true)
    if RoundStart and RoundStart:IsA("RemoteEvent") then
        RoundStart.OnClientEvent:Connect(function(arg1, arg2)
            table.clear(playerRoles)
            table.clear(playerDeadStatus)
            currentGunDrop = nil 
            parsePlayerData(arg2)
            parsePlayerData(arg1)
        end)
    end

    -- 🛠️ RENDERIZADOR INTEGRADO DE JUGADORES
    local function updateESP(player)
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

    -- Bucle maestro unificado
    while true do
        for _, p in pairs(Players:GetPlayers()) do
            updateESP(p)
        end
        updateGunESP() 
        task.wait(0.2)
    end
end)

return KillerHub
