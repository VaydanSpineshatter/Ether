local _, Ether = ...
local nStatus = {}
Ether.nStatus = nStatus
local U_N = UnitName

local function utf8sub(str, start, numChars)
    if not str then
        return
    end
    local currentIndex = start
    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
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

local function UpdateName(self, bool)
    if not self.unit then
        return
    end
    local name = U_N(self.unit)
    if (name) then
        self.name:SetTextColor(1, 1, 1)
        if bool then
            self.name:SetText(utf8sub(name, 1, 3))
        else
            self.name:SetText(name)
        end
    end
end
Ether.UpdateName = UpdateName

local Name, Event
if not Name then
    Name = CreateFrame("Frame")
    function Event(_, event, unit)
        if (not unit) then
            return
        end
        if event == "UNIT_NAME_UPDATE" then
            if Ether.DB[901]["party"] then
                local p = Ether.Buttons.party[unit]
                if p then
                    UpdateName(p)
                end
            end
            if Ether.DB[901][unit] then
                local s = Ether.unitButtons[unit]
                if s then
                    UpdateName(s)
                end
            end
            if Ether.DB[901]["maintank"] then
                local mt = Ether.Buttons.maintank[unit]
                if mt then
                    UpdateName(mt)
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
