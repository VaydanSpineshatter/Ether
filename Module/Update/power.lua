local _, Ether = ...

local UnitPowerType = UnitPowerType
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local string_format = string.format
local math_floor = math.floor

local Power_Colors = {
    [0] = {
        r = 0.0,
        g = 0.44,
        b = 0.87
    },
    [1] = {
        r = 1.0,
        g = 0.0,
        b = 0.0
    },
    [2] = {
        r = 1.0,
        g = 0.5,
        b = 0.25
    },
    [3] = {
        r = 1.0,
        g = 0.96,
        b = 0.41
    }
}

local PowerColors = {
    {0.0, 'ff0000'},
    {0.5, 'ffff00'},
    {1.0, '1a75ff'},
}

local RegisterPEvent, UnregisterPEvent
do
    local IsEventValid = C_EventUtils.IsEventValid
    local frame
    local Events = {}
    function RegisterPEvent(castEvent, func)
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
    function UnregisterPEvent(...)
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

local function ReturnPower(self)
    return UnitPower(self)
end

local function ReturnMaxPower(self)
    return UnitPowerMax(self)
end

function Ether:InitialPower(button)
    if not button or not button.unit or not button.powerBar then
        return
    end
    button.powerBar:SetValue(ReturnPower(button.unit))
    button.powerBar:SetMinMaxValues(0, ReturnMaxPower(button.unit))
end

function Ether:InitialPower(button)
    if not button or not button.unit or not button.powerBar then
        return
    end
    button.powerBar:SetValue(ReturnPower(button.unit))
    button.powerBar:SetMinMaxValues(0, ReturnMaxPower(button.unit))
end

local PowerGradient = Ether:BuildGradientTable(PowerColors)

local powerCache = {}
local powerCacheHeader = {}

function Ether:UpdatePowerText(button)
    if not button or not button.unit or not button.power then return end

    local pw, maxPw = UnitPower(button.unit), UnitPowerMax(button.unit)

    local roundedPct = maxPw > 0 and math_floor((pw / maxPw) * 100 + 0.5) or 0

    if powerCache[button.unit] == roundedPct then
        return
    end
    powerCache[button.unit] = roundedPct

    if maxPw > 0 and roundedPct > 0 then
        button.power:SetText(string_format("%s%d%%|r", PowerGradient[roundedPct], roundedPct))
    end
end

function Ether:UpdatePowerTextHeader(button)
    if not button or not button.unit or not button.power then return end

    local pw, maxPw = UnitPower(button.unit), UnitPowerMax(button.unit)

    local roundedPct = maxPw > 0 and math_floor((pw / maxPw) * 100 + 0.5) or 0

    if powerCacheHeader[button.unit] == roundedPct then
        return
    end
     powerCacheHeader[button.unit] = roundedPct

    if maxPw > 0 and roundedPct > 0 then
        button.power:SetText(string_format("%s%d%%|r", PowerGradient[roundedPct], roundedPct))
    end
end

function Ether:InitialPowerText(button)
    if not button or not button.unit or not button.power then return end

    local unit = button.unit
    local pw, maxPw = ReturnPower(unit), ReturnMaxPower(unit)

    local roundedPct = maxPw > 0 and math_floor((pw / maxPw) * 100 + 0.5) or 0

    if maxPw > 0 and roundedPct > 0 then
        button.power:SetText(string_format("%s%d%%|r", PowerGradient[roundedPct], roundedPct))
    end
end

function Ether:GetPowerColor(self)
    local powerTypeID = UnitPowerType(self)
    local c = Power_Colors[powerTypeID] or Power_Colors[1]
    return c.r, c.g, c.b or false
end

function Ether:UpdatePower(button)
    if not button or not button.unit or not button.powerBar then
        return
    end
    local p = UnitPower(button.unit)
    local mp = UnitPowerMax(button.unit)

    button.powerBar:SetValue(p)
    button.powerBar:SetMinMaxValues(0, mp)
    local r, g, b = Ether:GetPowerColor(button.unit)
    button.powerBar:SetStatusBarColor(r, g, b)
end

function Ether:UpdateSmoothPower(button)
    if not button or not button.unit or not button.powerBar then
        return
    end
    local p = UnitPower(button.unit)
    local mp = UnitPowerMax(button.unit)
    button.powerBar:SetMinMaxSmoothedValue(0, mp)
    button.powerBar:SetSmoothedValue(p)
    local r, g, b = Ether:GetPowerColor(button.unit)
    button.powerBar:SetStatusBarColor(r, g, b)
end

local function PowerChanged(_, event, unit)
    if (not unit) then
        return
    end
    if event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" then
        if Ether.DB[901][unit] then
            local button = Ether.unitButtons.solo[unit]
            if button and button:IsVisible() then
                if Ether.DB[801][4] == 1 then
                    Ether:UpdateSmoothPower(button)
                else
                    Ether:UpdatePower(button)
                end
                if Ether.DB[701][2] == 1 then
                    Ether:UpdatePowerText(button)
                end
            end
        end
        if Ether.DB[901]["raid"] and Ether.DB[701][4] == 1 then
            local button = Ether.unitButtons.raid[unit]
            if button and button:IsVisible() then
                 Ether:UpdatePowerTextHeader(button)
            end
        end
    end
end

function Ether:PowerEnable()
    RegisterPEvent("UNIT_POWER_UPDATE", PowerChanged)
    RegisterPEvent("UNIT_MAXPOWER", PowerChanged)
    RegisterPEvent("UNIT_DISPLAYPOWER", PowerChanged)
end

function Ether:PowerDisable()
    UnregisterPEvent("UNIT_POWER_UPDATE")
    UnregisterPEvent("UNIT_MAXPOWER")
    UnregisterPEvent("UNIT_DISPLAYPOWER")
    wipe(powerCache)
    wipe(powerCacheHeader)
end
