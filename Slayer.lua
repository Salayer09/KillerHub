-- ============================================================================
-- 👻 KILLER HUB - MM2 ADVANCED VISUAL SUITE (ULTRA-OPTIMIZED V5.2)
-- ============================================================================
-- OPTIMIZATIONS & FEATURES:
--   + Ultra-low latency engine: cached role/color lookups (0 backpack scans in RenderStepped)[span_1](start_span)[span_1](end_span)
--   + Zero-lag tracer pipeline with cached viewport anchors and fast distance clipping[span_2](start_span)[span_2](end_span)
--   + Smart event-driven dropped gun tracking (no recursive Workspace scans)[span_3](start_span)[span_3](end_span)
--   + Debounced configuration save system to eliminate disk I/O micro-stutters[span_4](start_span)[span_4](end_span)
--   + Fully integrated "Edit Shaders" suite with real-time controls[span_5](start_span)[span_5](end_span)
--   + Custom Shaders mutual exclusion with all atmospheric presets[span_6](start_span)[span_6](end_span)
--   + MM2 Neon & Fire Glow Booster (Bloom-powered radiance for Chroma/Neon skins)[span_7](start_span)[span_7](end_span)
--   + 13 Curated High-Definition Skyboxes (Midnight, Blood Moon, Horror, Galaxy, etc.)[span_8](start_span)[span_8](end_span)
--   + Clean, direct English user interface with zero bloat[span_9](start_span)[span_9](end_span)
--   + Complete cleanup on KillerHub unload (restores lighting, skies, and drawings)[span_10](start_span)[span_10](end_span)
--   + NEW: Reset, Random Shaders, and Custom Shader Saving / Loading System[span_11](start_span)[span_11](end_span)
-- ============================================================================

local HttpService        = game:GetService("HttpService")
local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Workspace          = game:GetService("Workspace")
local RunService         = game:GetService("RunService")
local CoreGui            = game:GetService("CoreGui")
local TweenService       = game:GetService("TweenService")
local Lighting           = game:GetService("Lighting")

local fileName    = "KillerHubMM2VisualConfig.json"
local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

-- Fast Local Cache
local pairs              = pairs
local ipairs             = ipairs
local type               = type
local pcall              = pcall
local tonumber           = tonumber
local tostring           = tostring
local math_floor         = math.floor
local math_abs           = math.abs
local math_clamp         = math.clamp
local math_random        = math.random
local Vector3_new        = Vector3.new
local Vector2_new        = Vector2.new
local Color3_new         = Color3.new
local Color3_fromRGB    = Color3.fromRGB
local Instance_new      = Instance.new
local UDim2_new         = UDim2.new
local playersGetPlayers = Players.GetPlayers

-- Default Game Roles Colors
local DefaultColors = {
    Murderer  = Color3_fromRGB(180, 55, 55),
    Sheriff   = Color3_fromRGB(35, 102, 204),
    Hero      = Color3_fromRGB(230, 188, 62),
    Innocent  = Color3_fromRGB(26, 171, 81),
    Dead      = Color3_fromRGB(115, 115, 115),
    GunDrop   = Color3_fromRGB(255, 0, 0),
    DuelEnemy = Color3_fromRGB(255, 40, 40),
    DuelTeam  = Color3_fromRGB(40, 140, 255)
}

-- [1] CONFIGURATION TABLE
local Config = {
    -- NORMAL ESP
    Highlight = false,
    HighlightTrans = 50,
    HighlightRoles = {["Murderer"] = false, ["Sheriff"] = false, ["Hero"] = false, ["Innocent"] = false, ["Dead/None"] = false},

    Box = false,
    BoxRoles = {["Murderer"] = false, ["Sheriff"] = false, ["Hero"] = false, ["Innocent"] = false, ["Dead/None"] = false},

    Name = false,
    NameRoles = {["Murderer"] = false, ["Sheriff"] = false, ["Hero"] = false, ["Innocent"] = false, ["Dead/None"] = false},

    Tracer = false,
    TracerPosition = "Bottom Center",
    TracerRoles = {["Murderer"] = false, ["Sheriff"] = false, ["Hero"] = false, ["Innocent"] = false, ["Dead/None"] = false},

    LimbChams = false,
    LimbChamsTrans = 50,
    LimbChamsRoles = {["Murderer"] = false, ["Sheriff"] = false, ["Hero"] = false, ["Innocent"] = false, ["Dead/None"] = false},

    -- DUELS ESP CONFIG
    DuelHighlight = false,
    DuelHighlightTrans = 50,
    DuelHighlightRoles = {["Enemy"] = true, ["Team"] = false},

    DuelLimbChams = false,
    DuelLimbChamsTrans = 50,
    DuelLimbChamsRoles = {["Enemy"] = true, ["Team"] = false},

    DuelBox = false,
    DuelBoxRoles = {["Enemy"] = true, ["Team"] = false},

    DuelName = false,
    DuelNameRoles = {["Enemy"] = true, ["Team"] = false},

    DuelTracer = false,
    DuelTracerRoles = {["Enemy"] = true, ["Team"] = false},

    -- GENERAL & DROPPED GUN
    GunCham = false,
    GunName = false,
    GunTracer = false,
    NameSize = 13,
    GunNameSize = 14,
    MaxDistance = 400,

    CustomColorsActive = {
        ["Murderer"] = false, ["Sheriff"] = false, ["Hero"] = false, ["Innocent"] = false,
        ["Dead/None"] = false, ["GunDrop"] = false, ["DuelEnemy"] = false, ["DuelTeam"] = false
    },
    CustomColorsRGB = {
        ["Murderer"]  = {180, 55, 55},
        ["Sheriff"]   = {35, 102, 204},
        ["Hero"]      = {230, 188, 62},
        ["Innocent"]  = {26, 171, 81},
        ["Dead/None"] = {115, 115, 115},
        ["GunDrop"]   = {255, 0, 0},
        ["DuelEnemy"] = {255, 40, 40},
        ["DuelTeam"]  = {40, 140, 255}
    },

    -- CUSTOM SHADERS SUITE
    CustomShaders = false,
    CustomBlur = 0,
    CustomBrightness = 0,
    CustomExposure = 0,
    CustomClockTime = 14,
    CustomSaturation = 0,
    CustomContrast = 0,
    CustomTintColor = {255, 255, 255},
    CustomOutdoorAmbient = {128, 128, 128},
    CustomNeonBoost = false,
    CustomBloomIntensity = 20,
    CustomBloomSize = 24,
    CustomBloomThreshold = 8,
    CustomSunRays = 0,
    CustomSky = "Default (Game Sky)",

    -- SAVED CUSTOM SHADERS REPOSITORY
    SavedCustomShaders = {}
}

-- [2] DEBOUNCED LOCAL STORAGE SYSTEM (ZERO DISK-I/O STUTTER)
local savePending = false
local function saveConfig(immediate)
    if not writefile then return end
    if immediate then
        savePending = false
        pcall(function()
            writefile(fileName, HttpService:JSONEncode(Config))
        end)
        return
    end
    if savePending then return end
    savePending = true
    task.delay(0.5, function()
        savePending = false
        pcall(function()
            writefile(fileName, HttpService:JSONEncode(Config))
        end)
    end)
end

-- Migration helper: converts legacy "Teammate" keys -> "Team"
local function migrateOldKeys()
    local duelRoleTables = {
        Config.DuelHighlightRoles,
        Config.DuelLimbChamsRoles,
        Config.DuelBoxRoles,
        Config.DuelNameRoles,
        Config.DuelTracerRoles
    }
    for _, t in ipairs(duelRoleTables) do
        if t["Teammate"] ~= nil then
            t["Team"] = t["Teammate"]
            t["Teammate"] = nil
        end
    end
    if Config.CustomColorsActive["DuelTeammate"] ~= nil then
        Config.CustomColorsActive["DuelTeam"] = Config.CustomColorsActive["DuelTeammate"]
        Config.CustomColorsActive["DuelTeammate"] = nil
    end
    if Config.CustomColorsRGB["DuelTeammate"] ~= nil then
        Config.CustomColorsRGB["DuelTeam"] = Config.CustomColorsRGB["DuelTeammate"]
        Config.CustomColorsRGB["DuelTeammate"] = nil
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
migrateOldKeys()

-- [3] GRAPHICAL INTERFACE
local KillerHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/zpxlo0ev/LuXpaO/refs/heads/main/007900118.lua"))()

local VisualsTab  = KillerHub:CreateTab("Visuals", "rbxassetid://6523858394")
local PagePlayers = VisualsTab:CreatePage("Players ESP", "Eye")
local PageDuels   = VisualsTab:CreatePage("Duels ESP", "Sword")
local PageShaders = VisualsTab:CreatePage("Shaders", "rbxassetid://8509432937")

-- ============================================================================
-- PAGE 1: PLAYERS ESP (STANDARD MODE)
-- ============================================================================
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
    Config.TracerPosition = sel; saveConfig()
end, Config.TracerPosition or "Bottom Center")
PagePlayers:CreateMultiDropdown("TracerFilters", "Roles", {"Murderer", "Sheriff", "Hero", "Innocent", "Dead/None"}, function(flags)
    for r, _ in pairs(Config.TracerRoles) do Config.TracerRoles[r] = flags[r] == true end; saveConfig()
end)

PagePlayers:CreateSection("Dropped Gun ESP")
local ToggleGunCham   = PagePlayers:CreateToggle("EspGunCham", "Gun Cham", function(val) Config.GunCham = val; saveConfig() end)
local ToggleGunName   = PagePlayers:CreateToggle("EspGunName", "Gun Name", function(val) Config.GunName = val; saveConfig() end)
local ToggleGunTracer = PagePlayers:CreateToggle("EspGunTracer", "Gun Tracer", function(val) Config.GunTracer = val; saveConfig() end)

PagePlayers:CreateSection("Role Colors Customization")
local function createRoleColorPicker(page, roleKey, visualName)
    local defaultRGB    = Config.CustomColorsRGB[roleKey]
    local defaultColor3 = Color3_fromRGB(defaultRGB[1], defaultRGB[2], defaultRGB[3])
    page:CreateToggleColorPicker(
        "CP_Active_" .. roleKey, "CP_Color_" .. roleKey, visualName, defaultColor3,
        function(estado) Config.CustomColorsActive[roleKey] = estado; saveConfig() end,
        function(c)
            Config.CustomColorsRGB[roleKey] = {math_floor(c.R*255), math_floor(c.G*255), math_floor(c.B*255)}
            saveConfig()
        end
    )
end

createRoleColorPicker(PagePlayers, "Murderer",  "Murderer")
createRoleColorPicker(PagePlayers, "Sheriff",   "Sheriff")
createRoleColorPicker(PagePlayers, "Hero",      "Hero")
createRoleColorPicker(PagePlayers, "Innocent",  "Innocent")
createRoleColorPicker(PagePlayers, "Dead/None", "Dead / Spectators")
createRoleColorPicker(PagePlayers, "GunDrop",   "Dropped Gun")

PagePlayers:CreateSection("Settings & Performance")
PagePlayers:CreateInput("EspMaxDistance", "Max Render Distance (Studs)", tostring(Config.MaxDistance or 400), function(val)
    local num = tonumber(val)
    if num then Config.MaxDistance = math_abs(num); saveConfig()
    else KillerHub:NotifyWarn("Invalid Input", "Please enter numbers only.", 3) end
end)
local NameSizeSlider    = PagePlayers:CreateSlider("EspNameSize",    "Name Size",     10, 30, function(val) Config.NameSize    = math_floor(val); saveConfig() end)
local GunNameSizeSlider = PagePlayers:CreateSlider("EspGunNameSize", "Gun Name Size", 10, 30, function(val) Config.GunNameSize = math_floor(val); saveConfig() end)

-- ============================================================================
-- PAGE 2: DUELS ESP (DUELS MODE)
-- ============================================================================
PageDuels:CreateSection("Duels ESP Options")

local ToggleDuelHighlight = PageDuels:CreateToggleSlider("DuelEspHighlight", "DuelEspHighlightTrans", "Highlight ESP", 0, 100,
    function(val) Config.DuelHighlight = val; saveConfig() end,
    function(val) Config.DuelHighlightTrans = math_floor(val); saveConfig() end
)
PageDuels:CreateMultiDropdown("DuelHighlightFilters", "Teams Filter", {"Enemy", "Team"}, function(flags)
    for r, _ in pairs(Config.DuelHighlightRoles) do Config.DuelHighlightRoles[r] = flags[r] == true end; saveConfig()
end)

local ToggleDuelLimbChams = PageDuels:CreateToggleSlider("DuelEspLimbChams", "DuelEspLimbChamsTrans", "Cham ESP", 0, 100,
    function(val) Config.DuelLimbChams = val; saveConfig() end,
    function(val) Config.DuelLimbChamsTrans = math_floor(val); saveConfig() end
)
PageDuels:CreateMultiDropdown("DuelLimbChamsFilters", "Teams Filter", {"Enemy", "Team"}, function(flags)
    for r, _ in pairs(Config.DuelLimbChamsRoles) do Config.DuelLimbChamsRoles[r] = flags[r] == true end; saveConfig()
end)

local ToggleDuelBox = PageDuels:CreateToggle("DuelEspBox", "Box ESP", function(val) Config.DuelBox = val; saveConfig() end)
PageDuels:CreateMultiDropdown("DuelBoxFilters", "Teams Filter", {"Enemy", "Team"}, function(flags)
    for r, _ in pairs(Config.DuelBoxRoles) do Config.DuelBoxRoles[r] = flags[r] == true end; saveConfig()
end)

local ToggleDuelName = PageDuels:CreateToggle("DuelEspName", "Name ESP", function(val) Config.DuelName = val; saveConfig() end)
PageDuels:CreateMultiDropdown("DuelNameFilters", "Teams Filter", {"Enemy", "Team"}, function(flags)
    for r, _ in pairs(Config.DuelNameRoles) do Config.DuelNameRoles[r] = flags[r] == true end; saveConfig()
end)

local ToggleDuelTracer = PageDuels:CreateToggle("DuelEspTracer", "Tracer ESP", function(val) Config.DuelTracer = val; saveConfig() end)
PageDuels:CreateMultiDropdown("DuelTracerFilters", "Teams Filter", {"Enemy", "Team"}, function(flags)
    for r, _ in pairs(Config.DuelTracerRoles) do Config.DuelTracerRoles[r] = flags[r] == true end; saveConfig()
end)

PageDuels:CreateSection("Duels Team Colors")
createRoleColorPicker(PageDuels, "DuelEnemy", "Enemy")
createRoleColorPicker(PageDuels, "DuelTeam",  "Team")

-- ============================================================================
-- 🌤️ SHADERS ENGINE & CUSTOM SKYBOXES
-- ============================================================================

local KH_BLUR_NAME  = "KillerHub_ShaderBlur"
local KH_COLOR_NAME = "KillerHub_ShaderColor"
local KH_SUN_NAME   = "KillerHub_ShaderSun"
local KH_BLOOM_NAME = "KillerHub_ShaderBloom"
local KH_SKY_NAME   = "KillerHub_ShaderSky"

local SHADER_TWEEN  = TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SHADER_FAST   = TweenInfo.new(0.40, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local shBlur        = nil
local shColor       = nil
local shSun         = nil
local shBloom       = nil
local shSky         = nil
local originalSky   = nil

local origLighting = {
    Brightness           = Lighting.Brightness,
    ClockTime            = Lighting.ClockTime,
    ExposureCompensation = Lighting.ExposureCompensation,
    OutdoorAmbient       = Lighting.OutdoorAmbient,
    Ambient              = Lighting.Ambient
}

local shaderActivePreset = nil

local ShaderPresets = {
    ["Cloudy"] = {
        blur  = { Size = 4 },
        color = {
            Brightness = -0.04,
            Contrast   =  0.06,
            Saturation = -0.35,
            TintColor  = Color3_fromRGB(210, 220, 235),
        },
        sunrays = nil,
        sky = {
            SkyboxBk = "rbxassetid://92464172",
            SkyboxDn = "rbxassetid://92464250",
            SkyboxFt = "rbxassetid://92464217",
            SkyboxLf = "rbxassetid://92464234",
            SkyboxRt = "rbxassetid://92464189",
            SkyboxUp = "rbxassetid://92464157",
            CelestialBodiesShown = true,
        },
    },

    ["Rainy Style"] = {
        blur  = { Size = 5 },
        color = {
            Brightness = -0.10,
            Contrast   =  0.12,
            Saturation = -0.50,
            TintColor  = Color3_fromRGB(175, 195, 225),
        },
        sunrays = nil,
        sky = {
            SkyboxBk = "rbxassetid://10258337305",
            SkyboxDn = "rbxassetid://10258337305",
            SkyboxFt = "rbxassetid://10258337305",
            SkyboxLf = "rbxassetid://10258337305",
            SkyboxRt = "rbxassetid://10258337305",
            SkyboxUp = "rbxassetid://10258337305",
            CelestialBodiesShown = false,
        },
    },

    ["Dawn"] = {
        blur  = { Size = 3 },
        color = {
            Brightness =  0.06,
            Contrast   = -0.03,
            Saturation =  0.22,
            TintColor  = Color3_fromRGB(255, 230, 195),
        },
        sunrays = { Intensity = 0.14, Spread = 0.40 },
        sky = {
            SkyboxBk = "rbxassetid://6444884337",
            SkyboxDn = "rbxassetid://6444884785",
            SkyboxFt = "rbxassetid://6444884337",
            SkyboxLf = "rbxassetid://6444884337",
            SkyboxRt = "rbxassetid://6444884337",
            SkyboxUp = "rbxassetid://6412503613",
            CelestialBodiesShown = true,
        },
    },

    ["Dusk"] = {
        blur  = { Size = 4 },
        color = {
            Brightness = -0.04,
            Contrast   =  0.15,
            Saturation =  0.32,
            TintColor  = Color3_fromRGB(255, 198, 140),
        },
        sunrays = { Intensity = 0.20, Spread = 0.50 },
        sky = {
            SkyboxBk = "rbxassetid://16136021536",
            SkyboxDn = "rbxassetid://16136025360",
            SkyboxFt = "rbxassetid://16136021536",
            SkyboxLf = "rbxassetid://16136021536",
            SkyboxRt = "rbxassetid://16136021536",
            SkyboxUp = "rbxassetid://16136023362",
            CelestialBodiesShown = true,
        },
    },

    ["Cloudy Midday"] = {
        blur  = { Size = 3 },
        color = {
            Brightness =  0.08,
            Contrast   = -0.05,
            Saturation = -0.12,
            TintColor  = Color3_fromRGB(235, 240, 252),
        },
        sunrays = { Intensity = 0.06, Spread = 0.65 },
        sky = {
            SkyboxBk = "rbxassetid://225469345",
            SkyboxDn = "rbxassetid://225469349",
            SkyboxFt = "rbxassetid://225469359",
            SkyboxLf = "rbxassetid://225469364",
            SkyboxRt = "rbxassetid://225469372",
            SkyboxUp = "rbxassetid://225469380",
            CelestialBodiesShown = true,
        },
    },

    ["Midnight"] = {
        blur  = { Size = 3 },
        color = {
            Brightness = -0.18,
            Contrast   =  0.22,
            Saturation = -0.20,
            TintColor  = Color3_fromRGB(160, 180, 215),
        },
        sunrays = nil,
        sky = {
            SkyboxBk = "rbxassetid://2570432999",
            SkyboxDn = "rbxassetid://2570433005",
            SkyboxFt = "rbxassetid://2570432998",
            SkyboxLf = "rbxassetid://2570433000",
            SkyboxRt = "rbxassetid://2570432997",
            SkyboxUp = "rbxassetid://2570432996",
            StarCount = 5000,
            CelestialBodiesShown = true,
        },
    },

    ["Blood Moon"] = {
        blur  = { Size = 4 },
        color = {
            Brightness = -0.08,
            Contrast   =  0.25,
            Saturation =  0.40,
            TintColor  = Color3_fromRGB(255, 140, 140),
        },
        sunrays = { Intensity = 0.12, Spread = 0.35 },
        sky = {
            SkyboxBk = "rbxassetid://1012890",
            SkyboxDn = "rbxassetid://1012891",
            SkyboxFt = "rbxassetid://1012887",
            SkyboxLf = "rbxassetid://1012889",
            SkyboxRt = "rbxassetid://1012888",
            SkyboxUp = "rbxassetid://1014449",
            CelestialBodiesShown = true,
        },
    },

    ["Cyberpunk Neon"] = {
        blur  = { Size = 4 },
        color = {
            Brightness =  0.02,
            Contrast   =  0.18,
            Saturation =  0.55,
            TintColor  = Color3_fromRGB(230, 180, 255),
        },
        sunrays = { Intensity = 0.15, Spread = 0.55 },
        sky = {
            SkyboxBk = "rbxassetid://159454299",
            SkyboxDn = "rbxassetid://159454296",
            SkyboxFt = "rbxassetid://159454293",
            SkyboxLf = "rbxassetid://159454286",
            SkyboxRt = "rbxassetid://159454300",
            SkyboxUp = "rbxassetid://159454288",
            CelestialBodiesShown = true,
        },
    },

    ["Twilight Aesthetic"] = {
        blur  = { Size = 4 },
        color = {
            Brightness =  0.04,
            Contrast   =  0.08,
            Saturation =  0.30,
            TintColor  = Color3_fromRGB(245, 205, 235),
        },
        sunrays = { Intensity = 0.10, Spread = 0.45 },
        sky = {
            SkyboxBk = "rbxassetid://264908339",
            SkyboxDn = "rbxassetid://264907909",
            SkyboxFt = "rbxassetid://264909420",
            SkyboxLf = "rbxassetid://264909758",
            SkyboxRt = "rbxassetid://264908886",
            SkyboxUp = "rbxassetid://264907379",
            CelestialBodiesShown = true,
        },
    },
}

local CustomSkyPresets = {
    ["Midnight Stars"] = {
        Bk = "rbxassetid://2570432999", Dn = "rbxassetid://2570433005", Ft = "rbxassetid://2570432998",
        Lf = "rbxassetid://2570433000", Rt = "rbxassetid://2570432997", Up = "rbxassetid://2570432996",
        StarCount = 5000, CelestialBodiesShown = true
    },
    ["Blood Moon"] = {
        Bk = "rbxassetid://1012890", Dn = "rbxassetid://1012891", Ft = "rbxassetid://1012887",
        Lf = "rbxassetid://1012889", Rt = "rbxassetid://1012888", Up = "rbxassetid://1014449",
        CelestialBodiesShown = true
    },
    ["Red Eclipse"] = {
        Bk = "rbxassetid://401664839", Dn = "rbxassetid://401664862", Ft = "rbxassetid://401664960",
        Lf = "rbxassetid://401664881", Rt = "rbxassetid://401664901", Up = "rbxassetid://401664936",
        CelestialBodiesShown = true
    },
    ["Spooky Night"] = {
        Bk = "rbxassetid://201140995", Dn = "rbxassetid://201141018", Ft = "rbxassetid://201141029",
        Lf = "rbxassetid://201141054", Rt = "rbxassetid://201141077", Up = "rbxassetid://201141098",
        CelestialBodiesShown = false
    },
    ["Purple Galaxy"] = {
        Bk = "rbxassetid://60551991", Dn = "rbxassetid://60552080", Ft = "rbxassetid://60552173",
        Lf = "rbxassetid://60552234", Rt = "rbxassetid://60552295", Up = "rbxassetid://60552367",
        CelestialBodiesShown = true
    },
    ["Cyberpunk Neon"] = {
        Bk = "rbxassetid://159454299", Dn = "rbxassetid://159454296", Ft = "rbxassetid://159454293",
        Lf = "rbxassetid://159454286", Rt = "rbxassetid://159454300", Up = "rbxassetid://159454288",
        CelestialBodiesShown = true
    },
    ["Golden Sunset"] = {
        Bk = "rbxassetid://16136021536", Dn = "rbxassetid://16136025360", Ft = "rbxassetid://16136021536",
        Lf = "rbxassetid://16136021536", Rt = "rbxassetid://16136021536", Up = "rbxassetid://16136023362",
        CelestialBodiesShown = true
    },
    ["Twilight Aesthetic"] = {
        Bk = "rbxassetid://264908339", Dn = "rbxassetid://264907909", Ft = "rbxassetid://264909420",
        Lf = "rbxassetid://264909758", Rt = "rbxassetid://264908886", Up = "rbxassetid://264907379",
        CelestialBodiesShown = true
    },
    ["Dawn Morning"] = {
        Bk = "rbxassetid://6444884337", Dn = "rbxassetid://6444884785", Ft = "rbxassetid://6444884337",
        Lf = "rbxassetid://6444884337", Rt = "rbxassetid://6444884337", Up = "rbxassetid://6412503613",
        CelestialBodiesShown = true
    },
    ["Stormy Rain"] = {
        Bk = "rbxassetid://10258337305", Dn = "rbxassetid://10258337305", Ft = "rbxassetid://10258337305",
        Lf = "rbxassetid://10258337305", Rt = "rbxassetid://10258337305", Up = "rbxassetid://10258337305",
        CelestialBodiesShown = false
    },
    ["Cloudy Overcast"] = {
        Bk = "rbxassetid://92464172", Dn = "rbxassetid://92464250", Ft = "rbxassetid://92464217",
        Lf = "rbxassetid://92464234", Rt = "rbxassetid://92464189", Up = "rbxassetid://92464157",
        CelestialBodiesShown = true
    },
    ["Bright Midday"] = {
        Bk = "rbxassetid://225469345", Dn = "rbxassetid://225469349", Ft = "rbxassetid://225469359",
        Lf = "rbxassetid://225469364", Rt = "rbxassetid://225469372", Up = "rbxassetid://225469380",
        CelestialBodiesShown = true
    }
}

local CustomSkyNames = {
    "Default (Game Sky)",
    "Midnight Stars",
    "Blood Moon",
    "Red Eclipse",
    "Spooky Night",
    "Purple Galaxy",
    "Cyberpunk Neon",
    "Golden Sunset",
    "Twilight Aesthetic",
    "Dawn Morning",
    "Stormy Rain",
    "Cloudy Overcast",
    "Bright Midday"
}

local function ensureEffects()
    if not shBlur or not shBlur.Parent then
        shBlur = Lighting:FindFirstChild(KH_BLUR_NAME)
        if not shBlur then
            shBlur         = Instance_new("BlurEffect")
            shBlur.Name    = KH_BLUR_NAME
            shBlur.Size    = 0
            shBlur.Enabled = false
            shBlur.Parent  = Lighting
        end
    end

    if not shColor or not shColor.Parent then
        shColor = Lighting:FindFirstChild(KH_COLOR_NAME)
        if not shColor then
            shColor            = Instance_new("ColorCorrectionEffect")
            shColor.Name       = KH_COLOR_NAME
            shColor.Brightness = 0
            shColor.Contrast   = 0
            shColor.Saturation = 0
            shColor.TintColor  = Color3_new(1, 1, 1)
            shColor.Enabled    = false
            shColor.Parent     = Lighting
        end
    end

    if not shSun or not shSun.Parent then
        shSun = Lighting:FindFirstChild(KH_SUN_NAME)
        if not shSun then
            shSun           = Instance_new("SunRaysEffect")
            shSun.Name      = KH_SUN_NAME
            shSun.Intensity = 0
            shSun.Spread    = 0
            shSun.Enabled   = false
            shSun.Parent    = Lighting
        end
    end

    if not shBloom or not shBloom.Parent then
        shBloom = Lighting:FindFirstChild(KH_BLOOM_NAME)
        if not shBloom then
            shBloom           = Instance_new("BloomEffect")
            shBloom.Name      = KH_BLOOM_NAME
            shBloom.Intensity = 0
            shBloom.Size      = 24
            shBloom.Threshold = 0.8
            shBloom.Enabled   = false
            shBloom.Parent    = Lighting
        end
    end
end

local function ensureSky()
    if not shSky or not shSky.Parent then
        shSky = Lighting:FindFirstChild(KH_SKY_NAME)
        if not shSky then
            shSky      = Instance_new("Sky")
            shSky.Name = KH_SKY_NAME
        end
    end

    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Sky") and child ~= shSky then
            if not originalSky then originalSky = child end
            pcall(function() child.Parent = nil end)
        end
    end

    shSky.Parent = Lighting
    return shSky
end

local function applySkyboxByName(skyName)
    if skyName == "Default (Game Sky)" or not skyName then
        if shSky then
            pcall(function() shSky:Destroy() end)
            shSky = nil
        end
        if originalSky then
            pcall(function() originalSky.Parent = Lighting end)
            originalSky = nil
        end
        return
    end

    local skyData = CustomSkyPresets[skyName]
    if skyData then
        local skyObj = ensureSky()
        skyObj.SkyboxBk = skyData.Bk
        skyObj.SkyboxDn = skyData.Dn
        skyObj.SkyboxFt = skyData.Ft
        skyObj.SkyboxLf = skyData.Lf
        skyObj.SkyboxRt = skyData.Rt
        skyObj.SkyboxUp = skyData.Up
        skyObj.CelestialBodiesShown = skyData.CelestialBodiesShown ~= false
        if skyData.StarCount then
            skyObj.StarCount = skyData.StarCount
        end
    end
end

local function updateCustomShaderLive()
    if shaderActivePreset ~= "Custom" then return end
    ensureEffects()

    if Config.CustomBlur > 0 then
        shBlur.Size = Config.CustomBlur
        shBlur.Enabled = true
    else
        shBlur.Size = 0
        shBlur.Enabled = false
    end

    shColor.Brightness = Config.CustomBrightness / 100
    shColor.Contrast   = Config.CustomContrast / 100
    shColor.Saturation = Config.CustomSaturation / 100
    local tc = Config.CustomTintColor or {255, 255, 255}
    shColor.TintColor  = Color3_fromRGB(tc[1], tc[2], tc[3])
    shColor.Enabled    = true

    Lighting.ClockTime            = Config.CustomClockTime or 14
    Lighting.ExposureCompensation = (Config.CustomExposure or 0) / 10
    local amb = Config.CustomOutdoorAmbient or {128, 128, 128}
    Lighting.OutdoorAmbient       = Color3_fromRGB(amb[1], amb[2], amb[3])

    if Config.CustomNeonBoost or (Config.CustomBloomIntensity or 0) > 0 then
        shBloom.Enabled = true
        if Config.CustomNeonBoost then
            shBloom.Intensity = ((Config.CustomBloomIntensity or 20) / 18) * 1.6 + 0.6
            shBloom.Size      = Config.CustomBloomSize or 24
            shBloom.Threshold = math_clamp((Config.CustomBloomThreshold or 8) / 14, 0.05, 1.8)
        else
            shBloom.Intensity = (Config.CustomBloomIntensity or 20) / 20
            shBloom.Size      = Config.CustomBloomSize or 24
            shBloom.Threshold = (Config.CustomBloomThreshold or 8) / 10
        end
    else
        shBloom.Intensity = 0
        shBloom.Enabled   = false
    end

    if (Config.CustomSunRays or 0) > 0 then
        shSun.Intensity = Config.CustomSunRays / 100
        shSun.Spread    = 0.50
        shSun.Enabled   = true
    else
        shSun.Intensity = 0
        shSun.Enabled   = false
    end

    applySkyboxByName(Config.CustomSky)
end

local function applyCustomShaders()
    ensureEffects()
    shaderActivePreset = "Custom"
    updateCustomShaderLive()
end

local function applyShaderPreset(name)
    local preset = ShaderPresets[name]
    if not preset then return end
    ensureEffects()

    shBlur.Enabled = true
    TweenService:Create(shBlur, SHADER_TWEEN, { Size = preset.blur.Size }):Play()

    shColor.Enabled = true
    TweenService:Create(shColor, SHADER_TWEEN, preset.color):Play()

    if preset.sunrays then
        shSun.Enabled = true
        TweenService:Create(shSun, SHADER_TWEEN, preset.sunrays):Play()
    else
        local t = TweenService:Create(shSun, SHADER_FAST, { Intensity = 0, Spread = 0 })
        t:Play()
        t.Completed:Once(function()
            if shSun then shSun.Enabled = false end
        end)
    end

    local bOut = TweenService:Create(shBloom, SHADER_FAST, { Intensity = 0 })
    bOut:Play()
    bOut.Completed:Once(function()
        if shBloom then shBloom.Enabled = false end
    end)

    if preset.sky then
        local skyObj = ensureSky()
        skyObj.SkyboxBk = preset.sky.SkyboxBk
        skyObj.SkyboxDn = preset.sky.SkyboxDn
        skyObj.SkyboxFt = preset.sky.SkyboxFt
        skyObj.SkyboxLf = preset.sky.SkyboxLf
        skyObj.SkyboxRt = preset.sky.SkyboxRt
        skyObj.SkyboxUp = preset.sky.SkyboxUp
        skyObj.CelestialBodiesShown = preset.sky.CelestialBodiesShown ~= false
        if preset.sky.StarCount then skyObj.StarCount = preset.sky.StarCount end
    end

    shaderActivePreset = name
end

local function removeShaders()
    ensureEffects()

    local blurOut  = TweenService:Create(shBlur,  SHADER_FAST, { Size = 0 })
    local colorOut = TweenService:Create(shColor, SHADER_FAST, {
        Brightness = 0, Contrast = 0, Saturation = 0,
        TintColor  = Color3_new(1, 1, 1)
    })
    local sunOut   = TweenService:Create(shSun,   SHADER_FAST, { Intensity = 0, Spread = 0 })
    local bloomOut = TweenService:Create(shBloom, SHADER_FAST, { Intensity = 0 })

    blurOut:Play()
    colorOut:Play()
    sunOut:Play()
    bloomOut:Play()

    blurOut.Completed:Once(function()  if shBlur  then shBlur.Enabled  = false end end)
    colorOut.Completed:Once(function() if shColor then shColor.Enabled = false end end)
    sunOut.Completed:Once(function()   if shSun   then shSun.Enabled   = false end end)
    bloomOut.Completed:Once(function() if shBloom then shBloom.Enabled = false end end)

    pcall(function()
        Lighting.ClockTime            = origLighting.ClockTime
        Lighting.ExposureCompensation = origLighting.ExposureCompensation
        Lighting.OutdoorAmbient       = origLighting.OutdoorAmbient
        Lighting.Brightness           = origLighting.Brightness
    end)

    if shSky then
        pcall(function() shSky:Destroy() end)
        shSky = nil
    end
    if originalSky then
        pcall(function() originalSky.Parent = Lighting end)
        originalSky = nil
    end

    shaderActivePreset = nil
end

local function destroyShaderEffects()
    pcall(function()
        if shBlur  and shBlur.Parent  then shBlur:Destroy()  end
        if shColor and shColor.Parent then shColor:Destroy() end
        if shSun   and shSun.Parent   then shSun:Destroy()   end
        if shBloom and shBloom.Parent then shBloom:Destroy() end
        if shSky   and shSky.Parent   then shSky:Destroy()   end
        if originalSky then originalSky.Parent = Lighting end
        Lighting.ClockTime            = origLighting.ClockTime
        Lighting.ExposureCompensation = origLighting.ExposureCompensation
        Lighting.OutdoorAmbient       = origLighting.OutdoorAmbient
        Lighting.Brightness           = origLighting.Brightness
    end)
    shBlur      = nil
    shColor     = nil
    shSun       = nil
    shBloom     = nil
    shSky       = nil
    originalSky = nil
    shaderActivePreset = nil
end

-- ============================================================================
-- PAGE 3: SHADERS (PRESETS + EDIT SHADERS)
-- ============================================================================
PageShaders:CreateSection("Atmospheric Presets")

local shaderToggles       = {}
local ToggleCustomShaders = nil

local shaderOrder = {
    "Cloudy",
    "Rainy Style",
    "Dawn",
    "Dusk",
    "Cloudy Midday",
    "Midnight",
    "Blood Moon",
    "Cyberpunk Neon",
    "Twilight Aesthetic",
}

for _, presetName in ipairs(shaderOrder) do
    local toggleId = "Shader_" .. presetName:gsub("%s+", "_")
    local togRef

    togRef = PageShaders:CreateToggle(toggleId, presetName, function(enabled)
        if enabled then
            if ToggleCustomShaders then
                pcall(function() ToggleCustomShaders:Set(false) end)
            end
            applyShaderPreset(presetName)
            for otherName, otherRef in pairs(shaderToggles) do
                if otherName ~= presetName and otherRef then
                    pcall(function() otherRef:Set(false) end)
                end
            end
        else
            if shaderActivePreset == presetName then
                removeShaders()
            end
        end
    end)

    shaderToggles[presetName] = togRef
end

PageShaders:CreateSection("Edit Shaders")

ToggleCustomShaders = PageShaders:CreateToggle("Shader_Custom", "Custom Shaders", function(enabled)
    Config.CustomShaders = enabled
    saveConfig()
    if enabled then
        for _, togRef in pairs(shaderToggles) do
            if togRef then
                pcall(function() togRef:Set(false) end)
            end
        end
        applyCustomShaders()
    else
        if shaderActivePreset == "Custom" then
            removeShaders()
        end
    end
end, Config.CustomShaders or false)

PageShaders:CreateSlider("CustomBlur", "Blur Intensity", 0, 30, function(val)
    Config.CustomBlur = math_floor(val)
    saveConfig()
    updateCustomShaderLive()
end, Config.CustomBlur or 0)

PageShaders:CreateSlider("CustomBrightness", "Brightness", -100, 100, function(val)
    Config.CustomBrightness = math_floor(val)
    saveConfig()
    updateCustomShaderLive()
end, Config.CustomBrightness or 0)

PageShaders:CreateSlider("CustomExposure", "Exposure", -30, 30, function(val)
    Config.CustomExposure = math_floor(val)
    saveConfig()
    updateCustomShaderLive()
end, Config.CustomExposure or 0)

PageShaders:CreateSlider("CustomClockTime", "Clock Time (Hours)", 0, 24, function(val)
    Config.CustomClockTime = math_floor(val)
    saveConfig()
    updateCustomShaderLive()
end, Config.CustomClockTime or 14)

PageShaders:CreateSlider("CustomSaturation", "Saturation", -100, 100, function(val)
    Config.CustomSaturation = math_floor(val)
    saveConfig()
    updateCustomShaderLive()
end, Config.CustomSaturation or 0)

PageShaders:CreateSlider("CustomContrast", "Contrast", -100, 100, function(val)
    Config.CustomContrast = math_floor(val)
    saveConfig()
    updateCustomShaderLive()
end, Config.CustomContrast or 0)

local defTint = Config.CustomTintColor or {255, 255, 255}
PageShaders:CreateColorPicker("CustomTintColor", "Environment Tint", Color3_fromRGB(defTint[1], defTint[2], defTint[3]), function(c)
    Config.CustomTintColor = {math_floor(c.R * 255), math_floor(c.G * 255), math_floor(c.B * 255)}
    saveConfig()
    updateCustomShaderLive()
end)

local defAmb = Config.CustomOutdoorAmbient or {128, 128, 128}
PageShaders:CreateColorPicker("CustomOutdoorAmbient", "Ambient Color", Color3_fromRGB(defAmb[1], defAmb[2], defAmb[3]), function(c)
    Config.CustomOutdoorAmbient = {math_floor(c.R * 255), math_floor(c.G * 255), math_floor(c.B * 255)}
    saveConfig()
    updateCustomShaderLive()
end)

PageShaders:CreateToggle("CustomNeonBoost", "Neon & Fire Glow Boost", function(val)
    Config.CustomNeonBoost = val
    saveConfig()
    updateCustomShaderLive()
end, Config.CustomNeonBoost or false)

PageShaders:CreateSlider("CustomBloomIntensity", "Glow Intensity", 0, 100, function(val)
    Config.CustomBloomIntensity = math_floor(val)
    saveConfig()
    updateCustomShaderLive()
end, Config.CustomBloomIntensity or 20)

PageShaders:CreateSlider("CustomBloomSize", "Glow Spread", 0, 56, function(val)
    Config.CustomBloomSize = math_floor(val)
    saveConfig()
    updateCustomShaderLive()
end, Config.CustomBloomSize or 24)

PageShaders:CreateSlider("CustomBloomThreshold", "Glow Sensitivity", 1, 20, function(val)
    Config.CustomBloomThreshold = math_floor(val)
    saveConfig()
    updateCustomShaderLive()
end, Config.CustomBloomThreshold or 8)

PageShaders:CreateSlider("CustomSunRays", "Sun Rays Intensity", 0, 100, function(val)
    Config.CustomSunRays = math_floor(val)
    saveConfig()
    updateCustomShaderLive()
end, Config.CustomSunRays or 0)

PageShaders:CreateDropdown("CustomSky", "Skybox", CustomSkyNames, function(sel)
    Config.CustomSky = sel
    saveConfig()
    updateCustomShaderLive()
end, Config.CustomSky or "Default (Game Sky)")

-- ============================================================================
-- 🌟 SHADER CONTROLS (RESET & RANDOM)
-- ============================================================================
PageShaders:CreateSection("Shader Controls & Randomizer")

PageShaders:CreateButton("Reset Custom Shaders", function()
    Config.CustomBlur = 0
    Config.CustomBrightness = 0
    Config.CustomExposure = 0
    Config.CustomClockTime = 14
    Config.CustomSaturation = 0
    Config.CustomContrast = 0
    Config.CustomTintColor = {255, 255, 255}
    Config.CustomOutdoorAmbient = {128, 128, 128}
    Config.CustomNeonBoost = false
    Config.CustomBloomIntensity = 20
    Config.CustomBloomSize = 24
    Config.CustomBloomThreshold = 8
    Config.CustomSunRays = 0
    Config.CustomSky = "Default (Game Sky)"
    saveConfig(true)

    pcall(function()
        if KillerHub.Elements["CustomBlur"] then KillerHub.Elements["CustomBlur"]:Set(0) end
        if KillerHub.Elements["CustomBrightness"] then KillerHub.Elements["CustomBrightness"]:Set(0) end
        if KillerHub.Elements["CustomExposure"] then KillerHub.Elements["CustomExposure"]:Set(0) end
        if KillerHub.Elements["CustomClockTime"] then KillerHub.Elements["CustomClockTime"]:Set(14) end
        if KillerHub.Elements["CustomSaturation"] then KillerHub.Elements["CustomSaturation"]:Set(0) end
        if KillerHub.Elements["CustomContrast"] then KillerHub.Elements["CustomContrast"]:Set(0) end
        if KillerHub.Elements["CustomTintColor"] then KillerHub.Elements["CustomTintColor"]:Set(Color3.fromRGB(255, 255, 255)) end
        if KillerHub.Elements["CustomOutdoorAmbient"] then KillerHub.Elements["CustomOutdoorAmbient"]:Set(Color3.fromRGB(128, 128, 128)) end
        if KillerHub.Elements["CustomNeonBoost"] then KillerHub.Elements["CustomNeonBoost"]:Set(false) end
        if KillerHub.Elements["CustomBloomIntensity"] then KillerHub.Elements["CustomBloomIntensity"]:Set(20) end
        if KillerHub.Elements["CustomBloomSize"] then KillerHub.Elements["CustomBloomSize"]:Set(24) end
        if KillerHub.Elements["CustomBloomThreshold"] then KillerHub.Elements["CustomBloomThreshold"]:Set(8) end
        if KillerHub.Elements["CustomSunRays"] then KillerHub.Elements["CustomSunRays"]:Set(0) end
    end)

    if shaderActivePreset == "Custom" then
        updateCustomShaderLive()
    end

    KillerHub:NotifySuccess("Shaders", "¡Shaders personalizados restaurados!", 3)
end)

PageShaders:CreateButton("Random Shaders", function()
    local mode = math_random(1, 2)
    if mode == 1 then
        local keys = {}
        for k, _ in pairs(ShaderPresets) do table.insert(keys, k) end
        local randomPreset = keys[math_random(1, #keys)]

        if ToggleCustomShaders then
            pcall(function() ToggleCustomShaders:Set(false) end)
        end
        for otherName, otherRef in pairs(shaderToggles) do
            if otherRef then
                pcall(function() otherRef:Set(otherName == randomPreset) end)
            end
        end
        applyShaderPreset(randomPreset)
        KillerHub:NotifyInfo("Random Shaders", "Preset aplicado: " .. randomPreset, 3)
    else
        if ToggleCustomShaders then
            pcall(function() ToggleCustomShaders:Set(true) end)
        end
        for _, otherRef in pairs(shaderToggles) do
            if otherRef then pcall(function() otherRef:Set(false) end) end
        end

        Config.CustomShaders = true
        Config.CustomBlur = math_random(2, 6)
        Config.CustomBrightness = math_random(-10, 10)
        Config.CustomExposure = math_random(-5, 10)
        Config.CustomClockTime = math_random(1, 23)
        Config.CustomSaturation = math_random(-20, 40)
        Config.CustomContrast = math_random(5, 25)
        
        local niceTints = {
            {255, 220, 240}, {200, 230, 255}, {255, 200, 160}, {180, 255, 210}, {240, 200, 255}
        }
        Config.CustomTintColor = niceTints[math_random(1, #niceTints)]
        Config.CustomOutdoorAmbient = {math_random(100, 150), math_random(100, 150), math_random(120, 170)}
        Config.CustomNeonBoost = (math_random(1, 2) == 1)
        Config.CustomBloomIntensity = math_random(15, 45)
        Config.CustomBloomSize = math_random(20, 40)
        Config.CustomSunRays = math_random(0, 30)
        Config.CustomSky = CustomSkyNames[math_random(2, #CustomSkyNames)]
        saveConfig(true)

        pcall(function()
            if KillerHub.Elements["CustomBlur"] then KillerHub.Elements["CustomBlur"]:Set(Config.CustomBlur) end
            if KillerHub.Elements["CustomBrightness"] then KillerHub.Elements["CustomBrightness"]:Set(Config.CustomBrightness) end
            if KillerHub.Elements["CustomExposure"] then KillerHub.Elements["CustomExposure"]:Set(Config.CustomExposure) end
            if KillerHub.Elements["CustomClockTime"] then KillerHub.Elements["CustomClockTime"]:Set(Config.CustomClockTime) end
            if KillerHub.Elements["CustomSaturation"] then KillerHub.Elements["CustomSaturation"]:Set(Config.CustomSaturation) end
            if KillerHub.Elements["CustomContrast"] then KillerHub.Elements["CustomContrast"]:Set(Config.CustomContrast) end
            if KillerHub.Elements["CustomNeonBoost"] then KillerHub.Elements["CustomNeonBoost"]:Set(Config.CustomNeonBoost) end
            if KillerHub.Elements["CustomBloomIntensity"] then KillerHub.Elements["CustomBloomIntensity"]:Set(Config.CustomBloomIntensity) end
            if KillerHub.Elements["CustomBloomSize"] then KillerHub.Elements["CustomBloomSize"]:Set(Config.CustomBloomSize) end
            if KillerHub.Elements["CustomSunRays"] then KillerHub.Elements["CustomSunRays"]:Set(Config.CustomSunRays) end
        end)

        applyCustomShaders()
        KillerHub:NotifySuccess("Random Shaders", "¡Combinación aleatoria aplicada!", 3)
    end
end)

-- ============================================================================
-- 💾 SAVE CUSTOM SHADERS (SECTION)
-- ============================================================================
PageShaders:CreateSection("Save Custom Shaders")

local typedShaderName = ""
PageShaders:CreateInput("CustomShaderNamingInput", "Shader Name", "My Custom Shader", function(text)
    typedShaderName = text
end)

local loadShaderDropdown
local function getSavedShaderList()
    local list = {"None"}
    if Config.SavedCustomShaders then
        for name, _ in pairs(Config.SavedCustomShaders) do
            table.insert(list, name)
        end
    end
    return list
end

PageShaders:CreateButton("Save Current Custom Shader", function()
    if typedShaderName == "" or typedShaderName == "None" then
        KillerHub:NotifyWarn("Save Shaders", "Please write a valid name in the input field first!", 3)
        return
    end

    Config.SavedCustomShaders[typedShaderName] = {
        CustomBlur = Config.CustomBlur,
        CustomBrightness = Config.CustomBrightness,
        CustomExposure = Config.CustomExposure,
        CustomClockTime = Config.CustomClockTime,
        CustomSaturation = Config.CustomSaturation,
        CustomContrast = Config.CustomContrast,
        CustomTintColor = Config.CustomTintColor,
        CustomOutdoorAmbient = Config.CustomOutdoorAmbient,
        CustomNeonBoost = Config.CustomNeonBoost,
        CustomBloomIntensity = Config.CustomBloomIntensity,
        CustomBloomSize = Config.CustomBloomSize,
        CustomBloomThreshold = Config.CustomBloomThreshold,
        CustomSunRays = Config.CustomSunRays,
        CustomSky = Config.CustomSky
    }
    saveConfig(true)

    if loadShaderDropdown then
        loadShaderDropdown:Refresh(getSavedShaderList())
    end

    KillerHub:NotifySuccess("Save Shaders", "Shader '" .. typedShaderName .. "' saved successfully!", 3)
end)

loadShaderDropdown = PageShaders:CreateDropdown("LoadSavedShaderDropdown", "Load Saved Shader", getSavedShaderList(), function(sel)
    if sel == "None" or not sel then return end
    local data = Config.SavedCustomShaders[sel]
    if data then
        Config.CustomBlur = data.CustomBlur or 0
        Config.CustomBrightness = data.CustomBrightness or 0
        Config.CustomExposure = data.CustomExposure or 0
        Config.CustomClockTime = data.CustomClockTime or 14
        Config.CustomSaturation = data.CustomSaturation or 0
        Config.CustomContrast = data.CustomContrast or 0
        Config.CustomTintColor = data.CustomTintColor or {255, 255, 255}
        Config.CustomOutdoorAmbient = data.CustomOutdoorAmbient or {128, 128, 128}
        Config.CustomNeonBoost = data.CustomNeonBoost or false
        Config.CustomBloomIntensity = data.CustomBloomIntensity or 20
        Config.CustomBloomSize = data.CustomBloomSize or 24
        Config.CustomBloomThreshold = data.CustomBloomThreshold or 8
        Config.CustomSunRays = data.CustomSunRays or 0
        Config.CustomSky = data.CustomSky or "Default (Game Sky)"
        saveConfig(true)

        if ToggleCustomShaders then
            pcall(function() ToggleCustomShaders:Set(true) end)
        end
        Config.CustomShaders = true

        pcall(function()
            if KillerHub.Elements["CustomBlur"] then KillerHub.Elements["CustomBlur"]:Set(Config.CustomBlur) end
            if KillerHub.Elements["CustomBrightness"] then KillerHub.Elements["CustomBrightness"]:Set(Config.CustomBrightness) end
            if KillerHub.Elements["CustomExposure"] then KillerHub.Elements["CustomExposure"]:Set(Config.CustomExposure) end
            if KillerHub.Elements["CustomClockTime"] then KillerHub.Elements["CustomClockTime"]:Set(Config.CustomClockTime) end
            if KillerHub.Elements["CustomSaturation"] then KillerHub.Elements["CustomSaturation"]:Set(Config.CustomSaturation) end
            if KillerHub.Elements["CustomContrast"] then KillerHub.Elements["CustomContrast"]:Set(Config.CustomContrast) end
            if KillerHub.Elements["CustomNeonBoost"] then KillerHub.Elements["CustomNeonBoost"]:Set(Config.CustomNeonBoost) end
            if KillerHub.Elements["CustomBloomIntensity"] then KillerHub.Elements["CustomBloomIntensity"]:Set(Config.CustomBloomIntensity) end
            if KillerHub.Elements["CustomBloomSize"] then KillerHub.Elements["CustomBloomSize"]:Set(Config.CustomBloomSize) end
            if KillerHub.Elements["CustomSunRays"] then KillerHub.Elements["CustomSunRays"]:Set(Config.CustomSunRays) end
        end)

        updateCustomShaderLive()
        KillerHub:NotifySuccess("Load Shaders", "Loaded shader: " .. sel, 3)
    end
end, "None")

PageShaders:CreateButton("Delete Typed Shader Name", function()
    if typedShaderName == "" or typedShaderName == "None" then
        KillerHub:NotifyWarn("Delete Shader", "Type the exact name of the saved shader in the input box above.", 3)
        return
    end

    if Config.SavedCustomShaders and Config.SavedCustomShaders[typedShaderName] then
        Config.SavedCustomShaders[typedShaderName] = nil
        saveConfig(true)
        if loadShaderDropdown then
            loadShaderDropdown:Refresh(getSavedShaderList())
        end
        KillerHub:NotifySuccess("Delete Shader", "Deleted shader: " .. typedShaderName, 3)
    else
        KillerHub:NotifyWarn("Delete Shader", "Shader '" .. typedShaderName .. "' not found.", 3)
    end
end)

-- ============================================================================
-- [4] APPLY SAVED CONFIGURATIONS SAFELY
-- ============================================================================
ToggleName:Set(Config.Name)
ToggleTracer:Set(Config.Tracer)
ToggleGunCham:Set(Config.GunCham)
ToggleGunName:Set(Config.GunName)
ToggleGunTracer:Set(Config.GunTracer)
NameSizeSlider:Set(Config.NameSize)
GunNameSizeSlider:Set(Config.GunNameSize)
ToggleBox:Set(Config.Box)

if ToggleHighlight     then ToggleHighlight:SetToggle(Config.Highlight); ToggleHighlight:SetSlider(Config.HighlightTrans) end
if ToggleLimbChams     then ToggleLimbChams:SetToggle(Config.LimbChams); ToggleLimbChams:SetSlider(Config.LimbChamsTrans) end

if ToggleDuelHighlight then ToggleDuelHighlight:SetToggle(Config.DuelHighlight); ToggleDuelHighlight:SetSlider(Config.DuelHighlightTrans) end
if ToggleDuelLimbChams then ToggleDuelLimbChams:SetToggle(Config.DuelLimbChams); ToggleDuelLimbChams:SetSlider(Config.DuelLimbChamsTrans) end
if ToggleDuelBox       then ToggleDuelBox:Set(Config.DuelBox) end
if ToggleDuelName      then ToggleDuelName:Set(Config.DuelName) end
if ToggleDuelTracer    then ToggleDuelTracer:Set(Config.DuelTracer) end

if Config.CustomShaders and ToggleCustomShaders then
    ToggleCustomShaders:Set(true)
end

-- ============================================================================
-- 🧠 ULTRA-OPTIMIZED CORE ENGINE (ZERO-LAG ARCHITECTURE)
-- ============================================================================

local playerRoles      = {}
local playerDeadStatus = {}
local currentGunDrop   = nil

local isDuelActive     = false
local duelRivals       = {}
local duelTeam         = {}

local cachedPlayerState = {}

local GunDrawingLine = Drawing.new("Line")
GunDrawingLine.Thickness    = 1
GunDrawingLine.Transparency = 1
GunDrawingLine.Visible      = false

local playerTracers = {}

local function getTracerLine(player)
    local line = playerTracers[player]
    if not line then
        line = Drawing.new("Line")
        line.Thickness    = 1
        line.Transparency = 1
        line.Visible      = false
        playerTracers[player] = line
    end
    return line
end

local function removeTracerLine(player)
    local line = playerTracers[player]
    if line then
        pcall(function()
            line.Visible = false
            line:Remove()
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
    local char     = player.Character
    local name     = player.Name
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local isDeadInGame    = not char or not humanoid or humanoid.Health <= 0
    local isDeadInNetwork = playerDeadStatus[name] == true

    if isDeadInGame or isDeadInNetwork then
        return getRoleColor("Dead/None", DefaultColors.Dead), "Dead/None"
    end

    if isDuelActive then
        local root   = char and char:FindFirstChild("HumanoidRootPart")
        local isTeam = duelTeam[name] or (root and root:FindFirstChild("TeamMate") ~= nil)
        if isTeam then
            return getRoleColor("DuelTeam", DefaultColors.DuelTeam), "DuelTeam"
        else
            return getRoleColor("DuelEnemy", DefaultColors.DuelEnemy), "DuelEnemy"
        end
    end

    local backpack = player:FindFirstChild("Backpack")
    local hasKnife = (char and char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife"))
    local hasGun   = (char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver"))) or
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

local function isEspEnabledForRole(espType, status)
    if status == "DuelEnemy" then
        return Config.DuelHighlightRoles and (
            (espType == "Highlight" and Config.DuelHighlight  and Config.DuelHighlightRoles["Enemy"])  or
            (espType == "LimbChams" and Config.DuelLimbChams  and Config.DuelLimbChamsRoles["Enemy"])  or
            (espType == "Box"       and Config.DuelBox        and Config.DuelBoxRoles["Enemy"])        or
            (espType == "Name"      and Config.DuelName       and Config.DuelNameRoles["Enemy"])       or
            (espType == "Tracer"    and Config.DuelTracer     and Config.DuelTracerRoles["Enemy"])
        )
    elseif status == "DuelTeam" then
        return Config.DuelHighlightRoles and (
            (espType == "Highlight" and Config.DuelHighlight  and Config.DuelHighlightRoles["Team"])   or
            (espType == "LimbChams" and Config.DuelLimbChams  and Config.DuelLimbChamsRoles["Team"])   or
            (espType == "Box"       and Config.DuelBox        and Config.DuelBoxRoles["Team"])         or
            (espType == "Name"      and Config.DuelName       and Config.DuelNameRoles["Team"])        or
            (espType == "Tracer"    and Config.DuelTracer     and Config.DuelTracerRoles["Team"])
        )
    else
        if espType == "Highlight" then return Config.Highlight  and Config.HighlightRoles[status]  == true end
        if espType == "LimbChams" then return Config.LimbChams  and Config.LimbChamsRoles[status]  == true end
        if espType == "Box"       then return Config.Box        and Config.BoxRoles[status]        == true end
        if espType == "Name"      then return Config.Name       and Config.NameRoles[status]       == true end
        if espType == "Tracer"    then return Config.Tracer     and Config.TracerRoles[status]     == true end
    end
    return false
end

local function clearPlayerESP(char)
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        local box     = root:FindFirstChild("KH_2DBox")
        local nameTag = root:FindFirstChild("KH_Name")
        if box     then box:Destroy()     end
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
    if not char then
        cachedPlayerState[player] = nil
        return
    end

    local root   = char:FindFirstChild("HumanoidRootPart")
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not root or not myRoot then
        cachedPlayerState[player] = nil
        return
    end

    local distance = (myRoot.Position - root.Position).Magnitude
    if distance > Config.MaxDistance then
        cachedPlayerState[player] = nil
        clearPlayerESP(char)
        return
    end

    local color, currentStatus = getPlayerColorAndStatus(player)

    cachedPlayerState[player] = {
        color    = color,
        status   = currentStatus,
        distance = distance,
        root     = root,
        char     = char
    }

    local limbFolder = char:FindFirstChild("KH_LimbChams")
    if isEspEnabledForRole("LimbChams", currentStatus) then
        if not limbFolder then
            limbFolder        = Instance_new("Folder")
            limbFolder.Name   = "KH_LimbChams"
            limbFolder.Parent = char
        end
        local currentTrans = (isDuelActive and Config.DuelLimbChamsTrans or Config.LimbChamsTrans) / 100
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                local adornName = part.Name .. "_Adorn"
                local adorn     = limbFolder:FindFirstChild(adornName)
                if not adorn then
                    adorn             = Instance_new("BoxHandleAdornment")
                    adorn.Name        = adornName
                    adorn.AlwaysOnTop = true
                    adorn.ZIndex      = 5
                    adorn.Adornee     = part
                    adorn.Size        = part.Size + Vector3_new(0.02, 0.02, 0.02)
                    adorn.Parent      = limbFolder
                end
                if adorn.Color3 ~= color then adorn.Color3 = color end
                if adorn.Transparency ~= currentTrans then adorn.Transparency = currentTrans end
            end
        end
    else
        if limbFolder then limbFolder:Destroy() end
    end

    local box = root:FindFirstChild("KH_2DBox")
    if isEspEnabledForRole("Box", currentStatus) then
        if not box then
            box = Instance_new("BillboardGui")
            box.Name        = "KH_2DBox"
            box.Size        = UDim2_new(4.4, 0, 5.9, 0)
            box.AlwaysOnTop = true
            local frame  = Instance_new("Frame")
            frame.Size   = UDim2_new(1, 0, 1, 0)
            frame.BackgroundTransparency = 1
            frame.Parent = box
            local stroke = Instance_new("UIStroke")
            stroke.Thickness = 1.2
            stroke.Name      = "Outline"
            stroke.Parent    = frame
            box.Adornee = root
            box.Parent  = root
        end
        local outline = box.Frame.Outline
        if outline.Color ~= color then outline.Color = color end
    else
        if box then box:Destroy() end
    end

    local nameTag = root:FindFirstChild("KH_Name")
    if isEspEnabledForRole("Name", currentStatus) then
        if not nameTag then
            nameTag = Instance_new("BillboardGui")
            nameTag.Name        = "KH_Name"
            nameTag.Size        = UDim2_new(0, 160, 0, 40)
            nameTag.StudsOffset = Vector3_new(0, 4.0, 0)
            nameTag.AlwaysOnTop = true
            local label = Instance_new("TextLabel")
            label.Name  = "Display"
            label.Size  = UDim2_new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Font  = Enum.Font.SourceSansBold
            label.TextStrokeTransparency = 0.3
            label.Parent = nameTag
            nameTag.Adornee = root
            nameTag.Parent  = root
        end
        local display = nameTag.Display
        if display.Text ~= player.Name then display.Text = player.Name end
        if display.TextColor3 ~= color then display.TextColor3 = color end
        if display.TextSize ~= Config.NameSize then display.TextSize = Config.NameSize end
    else
        if nameTag then nameTag:Destroy() end
    end

    local hl             = char:FindFirstChild("KH_Highlight")
    local allowHighlight = isEspEnabledForRole("Highlight", currentStatus)
    if allowHighlight then
        if not hl then
            hl = Instance_new("Highlight")
            hl.Name               = "KH_Highlight"
            hl.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop
            hl.OutlineTransparency = 0
            hl.Adornee            = char
            hl.Parent             = char
        end
        if hl.FillColor ~= color then hl.FillColor = color end
        local targetTrans = (isDuelActive and Config.DuelHighlightTrans or Config.HighlightTrans) / 100
        if hl.FillTransparency ~= targetTrans then hl.FillTransparency = targetTrans end
        if hl.OutlineColor ~= color then hl.OutlineColor = color end
    else
        if hl then hl:Destroy() end
    end
end

local function checkGunInstance(part)
    if part and part.Name == "GunDrop" and part:IsA("BasePart") then
        currentGunDrop = part
    end
end
Workspace.ChildAdded:Connect(checkGunInstance)
Workspace.DescendantAdded:Connect(function(desc)
    if desc.Name == "GunDrop" and desc:IsA("BasePart") then
        currentGunDrop = desc
    end
end)

local function updateGunESP()
    if not currentGunDrop or not currentGunDrop:IsDescendantOf(Workspace) or not currentGunDrop:IsA("BasePart") then
        currentGunDrop = nil
        local direct = Workspace:FindFirstChild("GunDrop")
        if direct and direct:IsA("BasePart") then currentGunDrop = direct end
    end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if currentGunDrop and myRoot then
        local distance = (myRoot.Position - currentGunDrop.Position).Magnitude
        if distance > Config.MaxDistance then
            local hl      = currentGunDrop:FindFirstChild("KH_GunHighlight")
            local nameTag = currentGunDrop:FindFirstChild("KH_GunName")
            if hl      then hl:Destroy()      end
            if nameTag then nameTag:Destroy() end
            return
        end

        local gunColor = getRoleColor("GunDrop", DefaultColors.GunDrop)

        local hl = currentGunDrop:FindFirstChild("KH_GunHighlight")
        if Config.GunCham then
            if not hl then
                hl = Instance_new("Highlight")
                hl.Name                = "KH_GunHighlight"
                hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillTransparency   = 0
                hl.OutlineTransparency = 1
                hl.Adornee             = currentGunDrop
                hl.Parent              = currentGunDrop
            end
            if hl.FillColor ~= gunColor then hl.FillColor = gunColor end
        elseif hl then
            hl:Destroy()
        end

        local nameTag = currentGunDrop:FindFirstChild("KH_GunName")
        if Config.GunName then
            if not nameTag then
                nameTag = Instance_new("BillboardGui")
                nameTag.Name        = "KH_GunName"
                nameTag.Size        = UDim2_new(0, 180, 0, 40)
                nameTag.StudsOffset = Vector3_new(0, 2.5, 0)
                nameTag.AlwaysOnTop = true
                local label = Instance_new("TextLabel")
                label.Name  = "Display"
                label.Size  = UDim2_new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Font  = Enum.Font.SourceSansBold
                label.TextStrokeTransparency = 0.1
                label.TextStrokeColor3       = Color3_fromRGB(0, 0, 0)
                label.Text                   = "GUN HERE"
                label.Parent                 = nameTag
                nameTag.Adornee = currentGunDrop
                nameTag.Parent  = currentGunDrop
            end
            local display = nameTag.Display
            if display.TextColor3 ~= gunColor then display.TextColor3 = gunColor end
            if display.TextSize ~= Config.GunNameSize then display.TextSize = Config.GunNameSize end
        elseif nameTag then
            nameTag:Destroy()
        end
    end
end

-- ============================================================================
-- 📡 EVENTS & REMOTES LISTENERS (MM2 STANDARD + DUELS)
-- ============================================================================
local Remotes           = ReplicatedStorage:FindFirstChild("Remotes")
local PlayerDataChanged = ReplicatedStorage:FindFirstChild("PlayerDataChanged", true)
local RoundStart        = ReplicatedStorage:FindFirstChild("RoundStart", true)

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
        table.clear(cachedPlayerState)
        currentGunDrop = nil
        parsePlayerData(arg2)
        parsePlayerData(arg1)
    end)
end

local RoundOver = ReplicatedStorage:FindFirstChild("RoundOver", true)
               or ReplicatedStorage:FindFirstChild("SnowballRoundOver", true)
if RoundOver and RoundOver:IsA("RemoteEvent") then
    RoundOver.OnClientEvent:Connect(function()
        isDuelActive = false
        table.clear(playerRoles)
        table.clear(playerDeadStatus)
        table.clear(duelRivals)
        table.clear(duelTeam)
        table.clear(cachedPlayerState)
        currentGunDrop = nil
        local allPlayers = playersGetPlayers(Players)
        for i = 1, #allPlayers do
            local plr = allPlayers[i]
            if plr and plr.Character then clearPlayerESP(plr.Character) end
        end
    end)
end

if Remotes then
    local CustomGames = Remotes:FindFirstChild("CustomGames")
    local Gameplay    = Remotes:FindFirstChild("Gameplay")

    if CustomGames and CustomGames:FindFirstChild("DuelStarted") then
        CustomGames.DuelStarted.OnClientEvent:Connect(function(duelData)
            table.clear(duelRivals)
            table.clear(duelTeam)
            isDuelActive = true
            if type(duelData) == "table" then
                local myName     = LocalPlayer.Name
                local myTeamKey  = (duelData.Team1 and duelData.Team1[myName]) and "Team1"
                                or  ((duelData.Team2 and duelData.Team2[myName]) and "Team2" or nil)
                if myTeamKey then
                    local rivalTeamKey = (myTeamKey == "Team1") and "Team2" or "Team1"
                    if duelData[myTeamKey] then
                        for name, _ in pairs(duelData[myTeamKey]) do
                            if name ~= myName then duelTeam[name] = true end
                        end
                    end
                    if duelData[rivalTeamKey] then
                        for name, _ in pairs(duelData[rivalTeamKey]) do
                            duelRivals[name] = true
                        end
                    end
                end
            end
        end)
    end

    if Gameplay and Gameplay:FindFirstChild("RoundEndFade") then
        Gameplay.RoundEndFade.OnClientEvent:Connect(function()
            isDuelActive = false
            table.clear(duelRivals)
            table.clear(duelTeam)
        end)
    end
end

Players.PlayerRemoving:Connect(function(player)
    playerRoles[player.Name]      = nil
    playerDeadStatus[player.Name] = nil
    duelRivals[player.Name]       = nil
    duelTeam[player.Name]         = nil
    cachedPlayerState[player]     = nil
    removeTracerLine(player)
end)

task.spawn(function()
    while true do
        local allPlayers = playersGetPlayers(Players)
        for i = 1, #allPlayers do
            local plr = allPlayers[i]
            if plr and plr.Character then updatePlayerESP(plr) end
        end
        updateGunESP()
        task.wait(0.15)
    end
end)

local cachedViewportSize = Vector2_new(0, 0)
local cachedTracerMode   = ""
local cachedTracerOrigin = Vector2_new(0, 0)

local function getTracerOriginPoint(viewportSize, mode)
    if viewportSize == cachedViewportSize and mode == cachedTracerMode then
        return cachedTracerOrigin
    end
    cachedViewportSize = viewportSize
    cachedTracerMode   = mode
    if mode == "Top Center"    then cachedTracerOrigin = Vector2_new(viewportSize.X * 0.5, 0)
    elseif mode == "Middle Left"   then cachedTracerOrigin = Vector2_new(0, viewportSize.Y * 0.5)
    elseif mode == "Middle Right"  then cachedTracerOrigin = Vector2_new(viewportSize.X, viewportSize.Y * 0.5)
    elseif mode == "Center Screen" then cachedTracerOrigin = Vector2_new(viewportSize.X * 0.5, viewportSize.Y * 0.5)
    else cachedTracerOrigin = Vector2_new(viewportSize.X * 0.5, viewportSize.Y)
    end
    return cachedTracerOrigin
end

RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    if myRoot then
        local viewportSize = Camera.ViewportSize
        local tracerOrigin = getTracerOriginPoint(viewportSize, Config.TracerPosition)
        local allPlayers   = playersGetPlayers(Players)

        for i = 1, #allPlayers do
            local player = allPlayers[i]
            if player ~= LocalPlayer then
                local state = cachedPlayerState[player]
                local line  = playerTracers[player]

                if state and state.root and state.distance <= Config.MaxDistance then
                    if isEspEnabledForRole("Tracer", state.status) then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(state.root.Position)
                        if onScreen then
                            if not line then line = getTracerLine(player) end
                            line.From    = tracerOrigin
                            line.To      = Vector2_new(screenPos.X, screenPos.Y)
                            line.Color   = state.color
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
            end
        end

        if Config.GunTracer and currentGunDrop and currentGunDrop:IsDescendantOf(Workspace) and currentGunDrop:IsA("BasePart") then
            local distance = (myRoot.Position - currentGunDrop.Position).Magnitude
            if distance <= Config.MaxDistance then
                local screenPos, onScreen = Camera:WorldToViewportPoint(currentGunDrop.Position)
                if onScreen then
                    local gunColor = getRoleColor("GunDrop", DefaultColors.GunDrop)
                    GunDrawingLine.From    = tracerOrigin
                    GunDrawingLine.To      = Vector2_new(screenPos.X, screenPos.Y)
                    GunDrawingLine.Color   = gunColor
                    GunDrawingLine.Visible = true
                else
                    GunDrawingLine.Visible = false
                end
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

-- ============================================================================
-- 🧹 CLEANUP (Drawings + Lighting + Custom Sky on KillerHub unload)
-- ============================================================================
CoreGui.ChildRemoved:Connect(function(child)
    if child.Name == "KillerHub" then
        GunDrawingLine:Remove()
        for _, line in pairs(playerTracers) do
            pcall(function() line:Remove() end)
        end
        table.clear(playerTracers)
        table.clear(cachedPlayerState)
        destroyShaderEffects()
    end
end)

return KillerHub
