local _, Ether = ...
local hStatus = {}
Ether.hStatus = hStatus

local U_H = UnitHealth
local U_MH = UnitHealthMax
local U_IP = UnitIsPlayer
local U_C = UnitClass
local math_max = math.max
local math_min = math.min
local U_GIH = UnitGetIncomingHeals
local string_format = string.format
local fm = "%.1f"

local FACTION_COLORS = {
    [0] = { r = 255, g = 0, b = 0 }, -- HOSTILE
    [1] = { r = 255, g = 129, b = 0 }, -- UNFRIENDLY
    [2] = { r = 255, g = 255, b = 0 }, -- NEUTRAL
    [3] = { r = 0, g = 255, b = 0 }, -- FRIENDLY
    [4] = { r = 0, g = 0, b = 255 }, -- PLAYER_SIMPLE
    [5] = { r = 96, g = 96, b = 255 }, -- PLAYER_EXTENDED
    [6] = { r = 170, g = 170, b = 255 }, -- PARTY
    [7] = { r = 170, g = 255, b = 170 }, -- PARTY_PVP
    [8] = { r = 83, g = 201, b = 255 }, -- FRIEND
    [9] = { r = 128, g = 128, b = 128 }, -- DEAD
    [10] = {}, -- COMMENTATOR_TEAM_1
    [11] = {}, -- COMMENTATOR_TEAM_2
    [13] = { r = 255, g = 255, b = 139 }, -- SELF
    [14] = { r = 0, g = 153, b = 0 }, -- BATTLEGROUND_FRIENDLY_PVP
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
            frame:SetScript("OnEvent", function(self, event, unit, ...)
                Events[event](self, event, unit, ...)
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

local function GetClassColor(unit)
    if not unit then
        return
    end

    if (not U_IP(unit)) then
        return 0.18, 0.54, 0.34
    else
        local _, classFilename = U_C(unit)
        local c = RAID_COLORS[classFilename]
        if c then
            return c.r, c.g, c.b
        else
            return 1, 1, 1
        end
    end
end
Ether.GetClassColor = GetClassColor

local function ReturnHealth(self)
    return U_H(self)
end
Ether.ReturnHealth = ReturnHealth

local function ReturnMaxHealth(self)
    return U_MH(self)
end

local function InitialHealth(self)
    if not (self.unit) then
        return
    end
    self.healthBar:SetValue(ReturnHealth(self.unit))
    self.healthBar:SetMinMaxValues(0, ReturnMaxHealth(self.unit))
end
Ether.InitialHealth = InitialHealth

local function UpdateHealthText(self)
    if not self.unit or not self.health then
        return
    end
    local h = U_H(self.unit)
    if h <= 0 then
        return
    end
    if h >= 1000 then
        self.health:SetText(string_format(fm, h / 1000))
    else
        self.health:SetText(h)
    end
end
Ether.UpdateHealthText = UpdateHealthText

local function UpdatePrediction(button)
    if not button or not button.unit then
        return
    end

    local myIncomingHeal = U_GIH(button.unit, "player") or 0
    local allIncomingHeal = U_GIH(button.unit) or 0

    local otherIncomingHeal = 0

    if allIncomingHeal > 0 then
        otherIncomingHeal = math_max(0, allIncomingHeal - myIncomingHeal)
        myIncomingHeal = math_min(myIncomingHeal, allIncomingHeal)
    end

    if button.playerPrediction then
        if myIncomingHeal > 0 then
            button.playerPrediction:Show()
        else
            button.playerPrediction:Hide()
        end
    end

    if button.otherPrediction then
        if otherIncomingHeal > 0 then
            button.otherPrediction:Show()
        else
            button.otherPrediction:Hide()
        end
    end
end
Ether.UpdatePrediction = UpdatePrediction

local function UpdateHealthAndMax(button)
    if not button or not button.unit then
        return
    end

    local h = U_H(button.unit)
    local mh = U_MH(button.unit)

    button.healthBar:SetValue(h)
    button.healthBar:SetMinMaxValues(0, mh)

    local r, g, b = GetClassColor(button.unit)
    button.healthBar:SetStatusBarColor(r, g, b)
    button.healthDrop:SetColorTexture(r * 0.3, g * 0.3, b * 0.3, 0.8)

end
Ether.UpdateHealthAndMax = UpdateHealthAndMax

local function UpdateSmoothHealthAndMax(button)
    if not button or not button.unit then
        return
    end
    local h = U_H(button.unit)
    local mh = U_MH(button.unit)
    local r, g, b = GetClassColor(button.unit)
    button.healthBar:SetStatusBarColor(r, g, b)
    button.healthDrop:SetColorTexture(r * 0.3, g * 0.3, b * 0.3, 0.8)
    button.healthBar:SetMinMaxSmoothedValue(0, mh)
    button.healthBar:SetSmoothedValue(h)
end
Ether.UpdateSmoothHealth = UpdateSmoothHealthAndMax

local function HealthChanged(_, event, unit)
    if (not unit) then
        return
    end
    if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        if Ether.DB[901]["party"] and Ether.DB[201][7] == 1 and unit:match("^party") then
            local p = Ether.Buttons.party[unit]
            if p then
                UpdateHealthAndMax(p)
                if Ether.DB[701][3] == 1 then
                    UpdateHealthText(p)
                end
            end
        end
        if Ether.DB[901][unit] then
            local s = Ether.unitButtons[unit]
            if s then
                if Ether.DB[2001]["SMOOTH_HEALTH_SINGLE"] then
                    UpdateSmoothHealthAndMax(s)
                else
                    UpdateHealthAndMax(s)
                    if Ether.DB[701][1] == 1 then
                       UpdateHealthText(s)
                    end
                end
            end
        end
        if Ether.DB[901]["maintank"] then
            local mt = Ether.Buttons.maintank[unit]
            if mt then
                UpdateHealthAndMax(mt)
            end
        end
        if not Ether.DB[901]["raid"] or Ether.DB[201][8] ~= 1 or not unit:match("^raid") then
            return
        end
        local button = Ether.Buttons.raid[unit]
        if not button then return end
        if Ether.DB[2001]["SMOOTH_HEALTH_RAID"] then
            UpdateSmoothHealthAndMax(button)
        else
            UpdateHealthAndMax(button)
            if Ether.DB[701][5] == 1 then
                UpdateHealthText(button)
            end
        end
    end
end

local function PredictionChanged(_, event, unit)
    if (not unit) then
        return
    end
    if event ~= "UNIT_HEAL_PREDICTION" then return end
    if Ether.DB[901]["party"] and Ether.DB[201][7]== 1 and unit:match("^party") then
        local p = Ether.Buttons.party[unit]
        if p and unit then
            UpdatePrediction(p)
        end
    end
    if Ether.DB[901][unit] then
        local s = Ether.unitButtons[unit]
        if s then
            UpdatePrediction(s)
        end
    end
    if Ether.DB[901]["maintank"] then
        local mt = Ether.Buttons.maintank[unit]
        if mt then
            UpdatePrediction(mt)
        end
    end
    if not Ether.DB[901]["raid"] or Ether.DB[201][8] ~= 1 or not unit:match("^raid") then
        return
    end
    local button = Ether.Buttons.raid[unit]
    if button then
        UpdatePrediction(button)
    end
end

function hStatus:Enable()
    RegisterHEvent("UNIT_HEALTH", HealthChanged)
    RegisterHEvent("UNIT_MAXHEALTH", HealthChanged)
    RegisterHEvent("UNIT_HEAL_PREDICTION", PredictionChanged)
end

function hStatus:Disable()
    UnregisterHEvent("UNIT_HEAL_PREDICTION")
    UnregisterHEvent("UNIT_HEALTH")
    UnregisterHEvent("UNIT_MAXHEALTH")
end
