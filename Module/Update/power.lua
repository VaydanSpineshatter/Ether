local _, Ether = ...

local UnitPowerType = UnitPowerType
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local string_format = string.format
local fm = "%.1f"

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

function Ether:UpdatePowerText(button)
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

function Ether:GetPowerColor(unit)
    local powerType, powerToken, altR, altG, altB = UnitPowerType(unit)
    local info = PowerBarColor[powerToken]
    local r, g, b
    if (info) then
        r, g, b = info.r, info.g, info.b
    elseif (not altR) then
        info = PowerBarColor[powerType] or PowerBarColor["MANA"]
        r, g, b = info.r, info.g, info.b
    else
        r, g, b = altR, altG, altB;
    end
    return r, g, b
end

function Ether:UpdatePower(button, smooth)
    if not button or not button.unit or not button.powerBar then
        return
    end
    local p = UnitPower(button.unit)
    local mp = UnitPowerMax(button.unit)

    if smooth then
        button.powerBar:SetMinMaxSmoothedValue(0, mp)
        button.powerBar:SetSmoothedValue(p)
    else
        button.powerBar:SetValue(p)
        button.powerBar:SetMinMaxValues(0, mp)
    end
    local r, g, b = Ether:GetPowerColor(button.unit)
    button.powerBar:SetStatusBarColor(r, g, b)
    button.powerDrop:SetColorTexture(r * 0.3, g * 0.3, b * 0.3)
end

local function PowerChanged(_, event, unit)
    if not unit then return end
    if event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" then
        if Ether.DB[901][unit] then
            local button = Ether.unitButtons.solo[unit]
            if button then
                if Ether.DB[801][2] == 1 then
                    Ether:UpdatePower(button, true)
                else
                    Ether:UpdatePower(button)
                end
                if Ether.DB[701][2] == 1 then
                    Ether:UpdatePowerText(button)
                end
            end
        end
        if Ether.DB[701][4] == 1 then
            local button = Ether.unitButtons.raid[unit]
            if button and button:IsVisible() then
                Ether:UpdatePowerText(button)
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
