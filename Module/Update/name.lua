local _, Ether = ...
local nStatus = {}
Ether.nStatus = nStatus
local UnitName = UnitName
local string_byte = string.byte
local UnitIsUnit = UnitIsUnit
local SELF = "|cffffd700ME|r"

local function utf8sub(str, start, numChars)
    if not str then
        return
    end
    local currentIndex = start
    while numChars > 0 and currentIndex <= #str do
        local char = string_byte(str, currentIndex)
        if char >= 240 then
            currentIndex = currentIndex + 4
        elseif char >= 225 then
            currentIndex = currentIndex + 3
        elseif char >= 192 then
            currentIndex = currentIndex + 2
        else
            currentIndex = currentIndex + 1
        end
        numChars = numChars - 1
    end
    return str:sub(start, currentIndex - 1)
end

function Ether.UpdateSoloName(self)
    if not self.unit then
        return
    end
    local name = UnitName(self.unit)
    if UnitIsUnit(self.unit, "player") then
        self.name:SetText(SELF)
    else
        self.name:SetText(name)
    end
end

function Ether.UpdateRaidName(self)
    if not self.unit then
        return
    end
    local name = UnitName(self.unit)
    if UnitIsUnit(self.unit, "player") then
        self.name:SetText(SELF)
    else
        self.name:SetText(utf8sub(name, 1, 3))
    end
end

local Name, Event
if not Name then
    Name = CreateFrame("Frame")
    function Event(_, event, unit)
        if (not unit) then
            return
        end
        if event == "UNIT_NAME_UPDATE" then
            if Ether.DB[901]["raid"] and Ether.DB[201][7] == 1 then
                local r = Ether.unitButtons.raid[unit]
                if r then
                   Ether.UpdateRaidName(r)
                end
            end
            if Ether.DB[901][unit] then
                local s = Ether.unitButtons.solo[unit]
                if s then
                    Ether.UpdateSoloName(s)
                end
            end
        end
    end
end

function nStatus:Enable()
    if not Name:GetScript("OnEvent") then
        Name:RegisterEvent("UNIT_NAME_UPDATE")
        Name:SetScript("OnEvent", Event)
    end
end

function nStatus:Disable()
    Name:UnregisterEvent("UNIT_NAME_UPDATE")
    Name:SetScript("OnEvent", nil)
end
