local _, Ether = ...
local comm = {}
Ether.comm = comm
local function ping(message)
    if Ether.DB[8771] ~= 1 then
        return
    end
end
local function cast(message)
    if Ether.DB[8771] ~= 1 then
        return
    end
end
local function data(message)
    if Ether.DB[8771] ~= 1 then
        return
    end
end
local arena1, arena2, arena3, arena4, arena5 = "", "", "", "", ""
local validUser
local teamData = {}
local prefix_Ether
local function ReceivedCast(_, event, prefix, message, _, sender, ...)
    if Ether.DB[8771] ~= 1 then
        return
    end
    if (Ether.communication == false) then
        return
    end
    if event ~= "CHAT_MSG_ADDON" then
        return
    end
    if prefix ~= prefix_Ether then
        return
    end
    local senderName = select(1, string.split("-", sender))
    if senderName == Ether.prefix then
        return
    end
    if data[senderName] == message then
        return
    end
    data[senderName] = message

    if message == sender then
        Ether.DebugOutput(string.format("Valid Version %s from %s received ", message, sender))
        if validUser then
            --  local validate = "arena" .. i
            return
        end
        for i, v in ipairs({strsplit(":", message)}) do
            data[i] = v
        end
        if data and data[1] then
            if data[1] == "Stop Cast" then
                Ether.Fire("", data)
            else
                Ether.Fire("", data)
            end
        end
    end
end

local function unitCast(_, event, unit)
    if (event == "UNIT_SPELLCAST_START") then
        return
    end
    if (unit ~= "player") then
        return
    end
    local name = UnitCastingInfo(unit)
    if not name then
        return
    end
    if (event ~= 'UNIT_SPELLCAST_STOP') then
        return
    end
end
local castEvent = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP"
}
local info, msg
if not info and msg then
    info, msg = CreateFrame("Frame"), CreateFrame("Frame")
    function comm:ProcessData(T)
    end
end
function comm:Enable()
    if not unitCast:GetScript("OnEvent") then
        unitCast:SetScript("OnEvent", unitCast)
        for _, event in ipairs(castEvent) do
            if not unitCast:IsEventRegistered(event) then
                unitCast:RegisterUnitEvent(event, "player")
            end
        end
    end
end
function comm:Disable()
    unitCast:SetScript("OnEvent", nil)
    unitCast:UnregisterAllEvents()
end
--[[
  function Ether.RegisterCallback:ReceivedData(DataIn)
        comm:ProcessData(DataIn,"")
    end
    function Ether.RegisterCallback:OutgoingData(DataOut)
        comm:ProcessData(DataOut, "")
    end
]]