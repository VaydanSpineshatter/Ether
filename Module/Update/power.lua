local _,Ether = ...

local UnitPowerType = UnitPowerType
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local string_format = string.format
local math_floor = math.floor
local fm = "%.1f"
local f2m = "%s%d%%|r"
local RegisterPEvent,UnregisterPEvent
do
    local IsEventValid = C_EventUtils.IsEventValid
    local frame
    local Events = {}
    function RegisterPEvent(castEvent,func)
        frame = CreateFrame("Frame")
        frame:SetScript("OnEvent",function(_,event,unit)
            if not unit then
                return
            end
            local button = Ether.unitButtons.raid[unit]
            if not button then
                return
            end
            if button:IsVisible() then
                Events[event](button,event,unit)
            end
        end)
        if not Events[castEvent] then
            if IsEventValid(castEvent) and not frame:IsEventRegistered(castEvent) then
                frame:RegisterEvent(castEvent)
            end
        end
        Events[castEvent] = func
    end
    function UnregisterPEvent(...)
        for i = select("#",...),1,-1 do
            local event = select(i,...)
            if IsEventValid(event) then
                if Events[event] then
                    frame:UnregisterEvent(event)
                end
            end
            Events[event] = nil
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
    button.powerBar:SetMinMaxValues(0,ReturnMaxPower(button.unit))
end

function Ether:GetPowerColor(unit)
    if not unit then
        return
    end
    local powerType,powerToken,altR,altG,altB = UnitPowerType(unit)
    local info = PowerBarColor[powerToken]
    local r,g,b
    if (info) then
        r,g,b = info.r,info.g,info.b
    elseif (not altR) then
        info = PowerBarColor[powerType] or PowerBarColor["MANA"]
        r,g,b = info.r,info.g,info.b
    else
        r,g,b = altR,altG,altB;
    end
    return r,g,b
end
--[[
local PowerColors = {
    {0.0, 'e0f7ff'},
    {0.2, '99ddff'},
    {0.4, '66bbff'},
    {0.6, '3399ff'},
    {1.0, '1a75ff'},
}

local PowerGradient = Ether:BuildGradientTable(PowerColors)
local lastPower = {}

function Ether:UpdatePowerTextRounded(button)
    if not button or not button.unit or not button.power then return end

    local unit = button.unit
    local pw, maxPw = UnitPower(unit), UnitPowerMax(unit)
    local pct = maxPw > 0 and pw / maxPw or 0
    local roundedPct = math_floor(pct * 100 + 0.5)

    if lastPower[unit] == roundedPct then
        return
    end
    lastPower[unit] = roundedPct

    local colorCode = PowerGradient[roundedPct]
    button.power:SetText(string_format(f2m, colorCode, roundedPct))
end
]]
function Ether:UpdatePowerTextRounded(button)
    if not button or not button.unit or not button.power then
        return
    end
    local p = UnitPower(button.unit)
    if p <= 0 then
        return
    end
    if p >= 1000 then
        button.power:SetText(string_format(fm,p / 1000))
    else
        button.power:SetText(p)
    end
end

function Ether:UpdatePower(button,smooth)
    if not button or not button.unit or not button.powerBar then
        return
    end
    local p = UnitPower(button.unit)
    local mp = UnitPowerMax(button.unit)

    if smooth then
        button.powerBar:SetMinMaxSmoothedValue(0,mp)
        button.powerBar:SetSmoothedValue(p)
    else
        button.powerBar:SetValue(p)
        button.powerBar:SetMinMaxValues(0,mp)
    end
    local r,g,b = Ether:GetPowerColor(button.unit)
    button.powerBar:SetStatusBarColor(r,g,b)
    button.powerDrop:SetColorTexture(r * 0.3,g * 0.3,b * 0.3)
end

local function PowerChanged(self,event,unit)
    if event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" then
        if Ether.DB[701][4] == 1 then
            Ether:UpdatePowerTextRounded(self.unit)
        end
    end
end

function Ether:PowerEnable()
    RegisterPEvent("UNIT_POWER_UPDATE",PowerChanged)
    RegisterPEvent("UNIT_MAXPOWER",PowerChanged)
    RegisterPEvent("UNIT_DISPLAYPOWER",PowerChanged)
end

function Ether:PowerDisable()
    UnregisterPEvent("UNIT_POWER_UPDATE")
    UnregisterPEvent("UNIT_MAXPOWER")
    UnregisterPEvent("UNIT_DISPLAYPOWER")
end
