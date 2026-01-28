local _, Ether = ...
local comm = {}
Ether.comm = comm
--[[
--local prefix_Ether = "EtherCom"
        --C_ChatInfo.RegisterAddonMessagePrefix(prefix_Ether)
local arena1, arena2, arena3, arena4, arena5 = "", "", "", "", ""
local validUser
local playerName = UnitName("player")
local teamData = {}
local prefix_Ether = "EtherCom"
local receivedData = {}
Ether.communication = true
local function ping(message)
    if Ether.DB[1101] ~= 1 then
        return
    end

    Ether.DebugOutput("Ping: " .. (message or "no message"))
end

local function dataProcessing(message)
    if Ether.DB[1101] ~= 1 then
        return
    end

end

local function MSG(self, event, ...)
    if Ether.DB[1101] ~= 1 then
        return
    end
    if Ether.communication == false then
        return
    end
    if event ~= "CHAT_MSG_ADDON" then
        return
    end
    local prefix, message, _, sender = ...
    if prefix ~= prefix_Ether then
        return
    end
    local senderName = select(1, string.split("-", sender))

    Ether.DebugOutput("Ping: " .. (message or "no message"))
    ping("Ping von " .. sender)
    if receivedData[senderName] == message then
        return
    end
    receivedData[senderName] = message

    local data = {strsplit(":", message)}

    if data[1] == "PING" then

        ping("Ping von " .. senderName)

        C_ChatInfo.SendAddonMessage(prefix_Ether, "PONG", "ARENA", sender)

    elseif data[1] == "Stop Cast" then
        Ether.Fire("StopCast", data)
    else
        Ether.Fire("CastData", data)
    end
end

function comm:SendPing(target)
    if Ether.DB[1101] ~= 1 then
        return
    end
    C_ChatInfo.SendAddonMessage(prefix_Ether, "PING", "ARENA", target)

end

function comm:SendStopCast(target)
    if Ether.DB[1101] ~= 1 then
        return
    end
    C_ChatInfo.SendAddonMessage(prefix_Ether, "Stop Cast", "ARENA", target)
end

function comm:SendArenaData(arenaNumber, data, target)
    if Ether.DB and Ether.DB[8771] ~= 1 then
        return
    end
    local msg = "ARENA:" .. arenaNumber .. ":" .. data
    C_ChatInfo.SendAddonMessage(prefix_Ether, msg, "ARENA", target)
end

function comm:ProcessData(dataTable, source)

    if dataTable[1] == "PING" then
        Ether.DebugOutput("Ping received from " .. (source or "unknown"))
    end
end

local function alignMSG()
end
Ether.DebugOutput()
 C_ChatInfo.SendAddonMessage(prefix_Ether, "", "WHISPER")
end



local commEnable, commDisable
do
    local msgEvent
    function commEnable()
        msgEvent = CreateFrame("Frame")
        if not msgEvent:IsEventRegistered("CHAT_MSG_ADDON") then
            msgEvent:RegisterEvent("CHAT_MSG_ADDON")
            msgEvent:SetScript("OnEvent", MSG)
        end
    end
    function commDisable()
        msgEvent:UnregisterAllEvents()
        msgEvent:SetScript("OnEvent",nil)
    end
end

function comm:Enable()
    commEnable()
end
function comm:Disable()
    commDisable()
end
]]