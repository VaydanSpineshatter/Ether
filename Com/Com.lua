local _,Ether=...
local Received={}
local function OnVersion(message)
    local theirVersion=tonumber(message)
    local myVersion=Ether.metaData[3]
    local lastCheck=ETHER_DATABASE_DX_AA["LAST"] or 0
    if (time()-lastCheck>=9000) and theirVersion and myVersion and myVersion<theirVersion then
        ETHER_DATABASE_DX_AA["LAST"]=time()
        local msg=string.format("New version found (%d). Please visit %s to get the latest version.",theirVersion,"|cFF00CCFFhttps://www.curseforge.com/wow/addons/ether|r")
        Ether:EtherInfo(msg)
    end
end
local NotValid=Ether.ValidMessage
local string_split,string_format=string.split,string.format
local function OnMsg(_,event,...)
    if event=="CHAT_MSG_ADDON" then
        local prefix,message,_,sender=...
        if prefix~=Ether.metaData[1] then return end
        if sender==Ether.metaData[2] then return end
        if Received[message]==message then
            return
        end
        Received[message]=message
        OnVersion(message)
    elseif event=="CHAT_MSG_BN_WHISPER" or event=="CHAT_MSG_WHISPER" then
        local message,sender=...
        if NotValid(sender) then return end
        local senderName=string_split('-',sender)
        Ether:EtherInfo(string_format("|cffcc66ffFrom %s:|r %s",senderName,message))
    end
end
local frame
if not frame then
    frame=CreateFrame("Frame")
    frame:SetScript("OnEvent",OnMsg)
    frame:RegisterEvent("CHAT_MSG_ADDON")
end
function Ether:EnableMsgEvents()
    for _,v in ipairs({"CHAT_MSG_WHISPER","CHAT_MSG_BN_WHISPER"}) do
        if frame:IsEventRegistered(v) then
            frame:UnregisterEvent(v)
            Ether.DB[1][2]=0
        else
            frame:RegisterEvent(v)
            Ether.DB[1][2]=1
        end
    end
end

