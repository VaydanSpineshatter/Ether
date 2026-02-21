local _, Ether = ...
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local math_max = math.max
local math_min = math.min
local UnitGetIncomingHeals = UnitGetIncomingHeals
local string_format = string.format
local math_floor = math.floor
local fm = "%.1f"
local f2m = "%s%d%%|r"

local FACTION_COLORS = {
    [0] = {r = 1.0, g = 0, b = 0}, -- 255/255=1.0
    [1] = {r = 1.0, g = 0.506, b = 0}, -- 129/255=0.506
    [2] = {r = 1.0, g = 1.0, b = 0},
    [3] = {r = 0, g = 1.0, b = 0},
    [4] = {r = 0, g = 0, b = 1.0},
    [5] = {r = 0.376, g = 0.376, b = 1.0}, -- 96/255=0.376
    [6] = {r = 0.667, g = 0.667, b = 1.0}, -- 170/255=0.667
    [7] = {r = 0.667, g = 1.0, b = 0.667},
    [8] = {r = 0.325, g = 0.788, b = 1.0}, -- 83/255=0.325, 201/255=0.788
    [9] = {r = 0.502, g = 0.502, b = 0.502}, -- 128/255=0.502
    [13] = {r = 1.0, g = 1.0, b = 0.545},
    [14] = {r = 0, g = 0.6, b = 0},
}

Ether.FACTION_COLORS = FACTION_COLORS

local RAID_COLORS = {
    ["HUNTER"] = {
        r = 0.67,
        g = 0.83,
        b = 0.45
    },
    ["WARLOCK"] = {
        r = 0.58,
        g = 0.51,
        b = 0.79
    },
    ["PRIEST"] = {
        r = 1.0,
        g = 1.0,
        b = 1.0
    },
    ["PALADIN"] = {
        r = 0.96,
        g = 0.55,
        b = 0.73
    },
    ["MAGE"] = {
        r = 0.41,
        g = 0.8,
        b = 0.94
    },
    ["ROGUE"] = {
        r = 1.0,
        g = 0.96,
        b = 0.41
    },
    ["DRUID"] = {
        r = 1.0,
        g = 0.49,
        b = 0.04
    },
    ["SHAMAN"] = {
        r = 0.0,
        g = 0.44,
        b = 0.87
    },
    ["WARRIOR"] = {
        r = 0.78,
        g = 0.61,
        b = 0.43
    },
    ["UNKNOWN"] = {
        r = 0.18,
        g = 0.54,
        b = 0.34
    }
}
Ether.RAID_COLORS = RAID_COLORS

local RegisterHEvent, UnregisterHEvent
do
    local IsEventValid = C_EventUtils.IsEventValid
    local frame
    local Events = {}
    function RegisterHEvent(castEvent, func)
        frame = CreateFrame("Frame")
        frame:SetScript("OnEvent", function(_, event, unit)
            local button = Ether.unitButtons.raid[unit]
            if not button then return end
            if not UnitExists(unit) then return end
            if button:IsVisible() then
                Events[event](button, event, unit)
            end
        end)
        if not Events[castEvent] then
            if IsEventValid(castEvent) and not frame:IsEventRegistered(castEvent) then
                frame:RegisterEvent(castEvent)
            end
        end
        Events[castEvent] = func
    end
    function UnregisterHEvent(...)
        for i = select("#", ...), 1, -1 do
            local event = select(i, ...)
            if IsEventValid(event) then
                if Events[event] then
                    frame:UnregisterEvent(event)
                end
            end
            Events[event] = nil
        end
    end
end

function Ether:GetClassColor(button)
    if not button or not button.unit then
        return
    end
    if not UnitIsPlayer(button.unit) then
        return 0.18, 0.54, 0.34
    else
        local _, classFilename = UnitClass(button.unit)
        local c = RAID_COLORS[classFilename]
        if c then
            return c.r, c.g, c.b
        else
            return 1, 1, 1
        end
    end
end

local function ReturnHealth(self)
    return UnitHealth(self)
end

local function ReturnMaxHealth(self)
    return UnitHealthMax(self)
end

function Ether:InitialHealth(button)
    if not button or not button.unit or not button.healthBar then
        return
    end
    button.healthBar:SetValue(ReturnHealth(button.unit))
    button.healthBar:SetMinMaxValues(0, ReturnMaxHealth(button.unit))
end

function Ether:GetClassColors(unit)
    local _, classFilename = UnitClass(unit)
    local info = RAID_CLASS_COLORS[classFilename]
    local r, g, b
    if (info) then
        info = RAID_CLASS_COLORS[classFilename]
        r, g, b = info.r, info.g, info.b
    else
        r, g, b = 0.18, 0.54, 0.34
    end
    return r, g, b
end

function Ether:UpdateHealth(button, smooth)
    if not button or not button.unit or not button.healthBar then
        return
    end
    local h = UnitHealth(button.unit)
    local mh = UnitHealthMax(button.unit)
    if smooth and button.Smooth then
        button.healthBar:SetMinMaxSmoothedValue(0, mh)
        button.healthBar:SetSmoothedValue(h)
    else
        button.healthBar:SetValue(h)
        button.healthBar:SetMinMaxValues(0, mh)
    end
    local r, g, b = Ether:GetClassColors(button.unit)
    button.healthBar:SetStatusBarColor(r, g, b)
    button.healthDrop:SetGradient("VERTICAL", CreateColor(r, g, b, .3), CreateColor(r * 0.3, g * 0.3, b * 0.4, .3))
end

--[[

local HealthColors = {
    {0.0, 'ff0000'},
    {0.3, 'ff4500'},
    {0.5, 'ffa500'},
    {0.7, 'ffd700'},
    {0.9, 'adff2f'},
    {1.0, '00ff00'},
}
local HealthGradient = Ether:BuildGradientTable(HealthColors)
local lastHealth = {}

function Ether:UpdateHealthTextRounded(button)
    if not button or not button.unit or not button.health then return end

    local unit = button.unit
    local h, maxH = UnitHealth(unit), UnitHealthMax(unit)
    local pct = maxH > 0 and h / maxH or 0
    local roundedPct = math_floor(pct * 100 + 0.5)

    if lastHealth[unit] == roundedPct then
        return
    end
    lastHealth[unit] = roundedPct

    local colorCode = HealthGradient[roundedPct]
    button.health:SetText(string_format(f2m, colorCode, roundedPct))
end
]]
function Ether:UpdateHealthTextRounded(button)
    if not button or not button.unit or not button.health then
        return
    end
    local unit = button.unit
    local h = UnitHealth(unit)
    if h <= 0 then
        if button.myPrediction and button.otherPrediction then
            button.myPrediction:Hide()
            button.otherPrediction:Hide()
        end
        return
    end
    if h >= 1000 then
        button.health:SetText(string_format(fm, h / 1000))
    else
        button.health:SetText(h)
    end
end

function Ether:UpdatePrediction(button)
    if not button or not button.unit or not button.myPrediction or not button.otherPrediction then return end
    local myHeal = UnitGetIncomingHeals(button.unit, "player") or 0
    local otherHeal = UnitGetIncomingHeals(button.unit) or 0
    local other = 0
    if otherHeal > 0 then
        other = math_max(0, otherHeal - myHeal)
        myHeal = math_min(myHeal, otherHeal)
    end
    if button.myPrediction then
        if myHeal > 0 then
            button.myPrediction:Show()
        else
            button.myPrediction:Hide()
        end
    end
    if button.otherPrediction then
        if other > 0 then
            button.otherPrediction:Show()
        else
            button.otherPrediction:Hide()
        end
    end
end

local function HealthChanged(self, event, unit)
    if self.unit ~= unit then return end
    if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        if Ether.DB[801][3] == 1 then
            Ether:UpdateHealth(self, true)
        else
            Ether:UpdateHealth(self)
        end
        if Ether.DB[701][3] == 1 then
            Ether:UpdateHealthTextRounded(self)
        end
    end
end

local function PredictionChanged(self, event, unit)
    if self.unit ~= unit then return end
    if event ~= "UNIT_HEAL_PREDICTION" then return end
    Ether:UpdatePrediction(self)
end

function Ether:HealthEnable()
    RegisterHEvent("UNIT_HEALTH", HealthChanged)
    RegisterHEvent("UNIT_MAXHEALTH", HealthChanged)
    RegisterHEvent("UNIT_HEAL_PREDICTION", PredictionChanged)
end

function Ether:HealthDisable()
    UnregisterHEvent("UNIT_HEAL_PREDICTION")
    UnregisterHEvent("UNIT_HEALTH")
    UnregisterHEvent("UNIT_MAXHEALTH")
end
