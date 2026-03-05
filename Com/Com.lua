local _,Ether=...

local Received={}
local updatedChannel=false
local sendChannel

local function UpdateSendChannel()
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        sendChannel="INSTANCE_CHAT"
    elseif IsInRaid() then
        sendChannel="RAID"
    else
        sendChannel="PARTY"
    end
end
local function HandleVersion(message)
    local theirVersion=tonumber(message)
    local myVersion=Ether:GetDataVersion()
    local lastCheck=ETHER_DATABASE_DX_AA["Last"] or 0
    if (time()-lastCheck>=9000) and theirVersion and myVersion and myVersion<theirVersion then
        ETHER_DATABASE_DX_AA["Last"]=time()
        local msg=string.format("New version found (%d). Please visit %s to get the latest version.",theirVersion,"|cFF00CCFFhttps://www.curseforge.com/wow/addons/ether|r")
        Ether:EtherInfo(msg)
    end
end

local playerName=UnitName("player")
local function Message(self,event,prefix,message,channel,sender,...)
    if event=="CHAT_MSG_ADDON" then
        if prefix~=Ether.metaData[1] then return end
        if sender==playerName then return end
        if Received[message]==message then
            return
        end
        Received[message]=message
        HandleVersion(message)
    elseif event=="GROUP_ROSTER_UPDATE" then
        self:UnregisterEvent("GROUP_ROSTER_UPDATE")
        if IsInGroup() and updatedChannel==false then
            updatedChannel=true
            UpdateSendChannel()
            C_ChatInfo.SendAddonMessage(Ether.metaData[1],Ether:GetDataVersion(),sendChannel)
        end
    end
end

local msgFrame
if not msgFrame then
    msgFrame=CreateFrame("Frame")
    msgFrame:RegisterEvent("CHAT_MSG_ADDON")
    msgFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    msgFrame:SetScript("OnEvent",Message)
end
