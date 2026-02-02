local _, Ether = ...
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local math_max = math.max
local math_min = math.min
local UnitGetIncomingHeals = UnitGetIncomingHeals
local string_format = string.format
local fm = "%.1f"

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
        if not frame then
            frame = CreateFrame("Frame")
            frame:SetScript("OnEvent", function(self, event, unit)
                Events[event](self, event, unit)
            end)
        end
        if not Events[castEvent] then
            if IsEventValid(castEvent) and not frame:IsEventRegistered(castEvent) then
                frame:RegisterEvent(castEvent)
            end
        end
        Events[castEvent] = func
    end
    function UnregisterHEvent(...)
        if frame then
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

function Ether:UpdateHealth(button)
    if not button or not button.unit or not button.healthBar then
        return
    end
    local h = UnitHealth(button.unit)
    local mh = UnitHealthMax(button.unit)

    if h <= 1 then
        if button.Indicators and button.Indicators.UnitFlags then
            button.Indicators.UnitFlags:Show()
            button.healthBar:SetValue(0)
        end
        return
    else
        if button.Indicators and button.Indicators.UnitFlags then
            button.Indicators.UnitFlags:Hide()
        end
    end

    button.healthBar:SetValue(h)
    button.healthBar:SetMinMaxValues(0, mh)

    local r, g, b = Ether:GetClassColor(button)
    button.healthBar:SetStatusBarColor(r, g, b)
    button.healthDrop:SetColorTexture(r * 0.3, g * 0.3, b * 0.3, 0.8)
end

function Ether:UpdateHealthText(button)
    if not button or not button.unit or not button.health then
        return
    end
    local h = UnitHealth(button.unit)
    if h <= 0 then
        return
    end
    if h >= 1000 then
        button.health:SetText(string_format(fm, h / 1000))
    else
        button.health:SetText(h)
    end
end

function Ether:UpdatePrediction(button)
    if not button or not button.unit or not button.myPrediction then return end
    local myHeal = UnitGetIncomingHeals(button.unit, "player") or 0
    local allIncomingHeal = UnitGetIncomingHeals(button.unit) or 0
    local otherHeal = 0
    if allIncomingHeal > 0 then
        otherHeal = math_max(0, allIncomingHeal - myHeal)
        myHeal = math_min(myHeal, allIncomingHeal)
    end
    if button.myPrediction then
        if myHeal > 0 then
            button.myPrediction:Show()
        else
            button.myPrediction:Hide()
        end
    end
    if not button.otherPrediction then
        return
    end
    if button.otherPrediction then
        if otherHeal > 0 then
            button.otherPrediction:Show()
        else
            button.otherPrediction:Hide()
        end
    end
end

function Ether:UpdateSmoothHealth(button)
    if not button or not button.unit or not button.healthBar then return end
    local h = UnitHealth(button.unit)
    local mh = UnitHealthMax(button.unit)
    local r, g, b = Ether:GetClassColor(button)
    button.healthBar:SetStatusBarColor(r, g, b)
    button.healthDrop:SetColorTexture(r * 0.3, g * 0.3, b * 0.3, 0.8)
    button.healthBar:SetMinMaxSmoothedValue(0, mh)
    button.healthBar:SetSmoothedValue(h)
end

local function HealthChanged(_, event, unit)
    if not unit then return end
    if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        if Ether.DB[901][unit] then
            local button = Ether.unitButtons.solo[unit]
            if button and button:IsVisible() then
                if Ether.DB[801][3] == 1 then
                    Ether:UpdateSmoothHealth(button)
                else
                    Ether:UpdateHealth(button)
                    if Ether.DB[701][1] == 1 then
                        Ether:UpdateHealthText(button)
                    end
                end
            end
        end
        if Ether.DB[901]["raid"] then
            local button = Ether.unitButtons.raid[unit]
            if button and button:IsVisible() then
                if Ether.DB[801][5] == 1 then
                    Ether:UpdateSmoothHealth(button)
                else
                    Ether:UpdateHealth(button)
                    if Ether.DB[701][3] == 1 then
                        Ether:UpdateHealthText(button)
                    end
                end
            end
        end
    end
end

local function PredictionChanged(_, event, unit)
    if not unit then return end
    if event ~= "UNIT_HEAL_PREDICTION" then return end
    if Ether.DB[901][unit] then
        local button = Ether.unitButtons.solo[unit]
        if button and button:IsVisible() then
            Ether:UpdatePrediction(button)
        end
    end
    if Ether.DB[901]["raid"] then
        local button = Ether.unitButtons.raid[unit]
        if button and button:IsVisible() then
            Ether:UpdatePrediction(button)
        end
    end
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
