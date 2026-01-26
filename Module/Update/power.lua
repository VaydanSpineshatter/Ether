local _, Ether = ...

local UnitPowerType = UnitPowerType
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local string_format = string.format
local fm = "%.1f"

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
Ether.ReturnPower = ReturnPower

local function ReturnMaxPower(self)
    return UnitPowerMax(self)
end

local function InitialPower(button)
    if not button or not button.unit or not button.powerBar then
        return
    end
    button.powerBar:SetValue(ReturnPower(button.unit))
    button.powerBar:SetMinMaxValues(0, ReturnMaxPower(button.unit))
end
Ether.InitialPower = InitialPower

local function UpdatePowerText(button)
    if not button or not button.unit or not button.power then
        return
    end
    local p = UnitPower(button.unit)
    if p <= 0 then
        return
    end
    if p >= 1000 then
       button.power:SetText(string_format(fm, p / 1000))
    else
       button.power:SetText(p)
    end
end
Ether.UpdatePowerText = UpdatePowerText

local function GetPowerColor(self)
    local powerTypeID = UnitPowerType(self)
    local c = Power_Colors[powerTypeID] or Power_Colors[1]
    return c.r, c.g, c.b or false
end
Ether.GetPowerColor = GetPowerColor

local function UpdatePowerAndMax(button)
    if not button or not button.unit or not button.powerBar then
        return
    end
    local p = UnitPower(button.unit)
    local mp = UnitPowerMax(button.unit)

    button.powerBar:SetValue(p)
    button.powerBar:SetMinMaxValues(0, mp)
    local r, g, b = GetPowerColor(button.unit)
    button.powerBar:SetStatusBarColor(r, g, b)
    button.powerDrop:SetColorTexture(r * 0.3, g * 0.3, b * 0.3, 0.4)
end
Ether.UpdatePowerAndMax = UpdatePowerAndMax

local function UpdateSmoothPowerAndMax(button)
    if not button or not button.unit or not button.powerBar then
        return
    end
    local p = UnitPower(button.unit)
    local mp = UnitPowerMax(button.unit)
    button.powerBar:SetMinMaxSmoothedValue(0, mp)
    button.powerBar:SetSmoothedValue(p)
    local r, g, b = GetPowerColor(button.unit)
    button.powerBar:SetStatusBarColor(r, g, b)
    button.powerDrop:SetColorTexture(r * 0.3, g * 0.3, b * 0.3, 0.4)
end
Ether.UpdateSmoothPowerAndMa = UpdateSmoothPowerAndMax

local function PowerChanged(_, event, unit)
    if (not unit) then
        return
    end
    if event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" then
        if Ether.DB[901][unit] then
            local s = Ether.unitButtons.solo[unit]
            if s then
                if Ether.DB[801][4] == 1 then
                    UpdateSmoothPowerAndMax(s)
                else
                    UpdatePowerAndMax(s)
                end
                if Ether.DB[701][2] == 1 then
                    UpdatePowerText(s)
                end
            end
        end
        if Ether.DB[901]["raid"] and Ether.DB[701][4] == 1 then
            local r = Ether.unitButtons.raid[unit]
            if r then
                UpdatePowerText(r)
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
end
