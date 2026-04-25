local D,F,S,C=unpack(select(2,...))
local event,GetPlayerInfoByGUID,CombatLogGetCurrentEventInfo,snapshot,status=S.EventFrame,GetPlayerInfoByGUID,CombatLogGetCurrentEventInfo,nil,0
local UnitGUID,ipairs,sformat,UnitExists,GUIDIsPlayer,Received=UnitGUID,ipairs,string.format,UnitExists,C_PlayerInfo.GUIDIsPlayer,{}
local eFaction={
    ["Human"]=true,
    ["Dwarf"]=true,
    ["NightElf"]=true,
    ["Gnome"]=true,
    ["Draenei"]=true
}
local A,H="Enemy","not Enemy"
A=H and eFaction[UnitRace("player")] or A
local E="|cffff0000is "..A.."|r"
local NE="|cff00ff00is "..H.."|r"
local P=[[Found: |cff%02x%02x%02x%s %s|r %s %s]]
local function ValidGUID(guid)
    for index,v in ipairs(D.DB["USER"]) do
        if v==guid then
            return true,index
        end
    end
    return false
end
local function GuidClassColor(guid)
    local _,class,_,race,_,name=GetPlayerInfoByGUID(guid)
    local color=RAID_CLASS_COLORS[class] or RAID_CLASS_COLORS["PRIEST"]
    local enemy=eFaction[race] and E or NE
    return color,class or "UNKNOWN",race or "UNKNOWN",name or "UNKNOWN",enemy or "UNKNOWN"
end
local function OnVersion(message)
    local theirVersion=tonumber(message)
    local myVersion=tonumber(C.EtherVersion)
    local lastCheck=_G["ETHER_DATABASE"]["LAST"] or 0
    if (time()-lastCheck>=7000) and theirVersion and myVersion and myVersion<theirVersion then
        _G["ETHER_DATABASE"]["LAST"]=time()
        local msg=sformat("New version found (%d). Get the latest version from %s",theirVersion,"|cFF00CCFFhttps://www.curseforge.com/wow/addons/ether|r")
        C:EtherInfo(msg)
    end
end
function F:ScanTargetGUID()
    if not UnitExists("target") then return end
    local guid=UnitGUID("target")
    if not guid then return end
    if guid==C.PlayerGUID then return end
    local c,class,race,name,enemy=GuidClassColor(guid)
    if ValidGUID(guid) then
        F:StartFlash()
        C:EtherInfo(sformat(P,c.r*255,c.g*255,c.b*255,name,class,race,enemy))
    end
end
function F:ScanGUID()
    if not UnitExists("target") then return end
    local guid=UnitGUID("target")
    if not guid then return end
    if guid==C.PlayerGUID then return end
    local human=GUIDIsPlayer(guid)
    if not human then return end
    local c,class,race,name,enemy=GuidClassColor(guid)
    if not ValidGUID(guid) then
        D.DB["USER"][#D.DB["USER"]+1]=guid
        F:StartFlash()
        C:EtherInfo(sformat([[|cff00ff00Added:|r |cff%02x%02x%02x%s %s|r %s %s]],c.r*255,c.g*255,c.b*255,name,class,race,enemy))
    else
        local _,index=ValidGUID(guid)
        table.remove(D.DB["USER"],index)
        F:StartFlash()
        C:EtherInfo(sformat([[|cffff0000Removed:|r |cff%02x%02x%02x%s %s|r %s %s]],c.r*255,c.g*255,c.b*255,name,class,race,enemy))
    end
end
function F:PrintGUID()
    if D:TableSize(D.DB["USER"])==0 then
        C:EtherInfo("No guid available to print")
        return
    end
    local data=F.GetTbl()
    for _,guid in ipairs(D.DB["USER"]) do
        local c,class,race,name,enemy=GuidClassColor(guid)
        data[#data+1]=sformat(P,c.r*255,c.g*255,c.b*255,name,class,race,enemy)
    end
    C:EtherInfo(table.concat(data,'\n'))
    F.RelTbl(data)
end
local function ScanCLEUGUID(destGUID)
    for _,guid in ipairs(D.DB["USER"]) do
        if guid==destGUID then
            local c,class,race,name,enemy=GuidClassColor(guid)
            F:StartFlash()
            C:EtherInfo(sformat(P,c.r*255,c.g*255,c.b*255,name,class,race,enemy))
            break
        end
    end
end
function F:CreateSnapshot()
    local guid=UnitGUID("target")
    if not guid or type(guid)=="nil" then return end
    snapshot=guid
    C:EtherInfo(snapshot)
    F:CreateCustomUnit(snapshot,7)
end
function event:PLAYER_REGEN_DISABLED()
    self:UnregisterEvent("PLAYER_REGEN_DISABLED")
    if not C.CombatStatus and C.MainFrame:IsShown() then
        C.CombatStatus=true
        if C.IsMovable then
            C:ToggleUnlock(0)
        end
        C.MainFrame:Hide()
    end
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
end

function event:PLAYER_REGEN_ENABLED()
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    if C.CombatStatus and not C.MainFrame:IsShown() then
        C.CombatStatus=false
        C.MainFrame:Show()
    end
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
end
function event:CHAT_MSG_ADDON(...)
    local prefix,message,_,sender=...
    if prefix~=C.EtherPrefix then return end
    if sender==C.PlayerName then return end
    if Received[message]==message then return end
    Received[message]=message
    OnVersion(message)
end
function event:CHAT_MSG_BN_WHISPER(...)
    local text,_,_,_,playerName2,_,_,_,_,_,_,guid=...
    if ValidGUID(guid) then return end
    local c=GuidClassColor(guid)
    C:EtherInfo(sformat("[|cff%02x%02x%02x%s|r] whispers: %s",c.r*255,c.g*255,c.b*255,playerName2,text))
end
function event:CHAT_MSG_WHISPER(...)
    local text,_,_,_,playerName2,_,_,_,_,_,_,guid=...
    if ValidGUID(guid) then return end
    local c=GuidClassColor(guid)
    C:EtherInfo(sformat("[|cff%02x%02x%02x%s|r] whispers: %s",c.r*255,c.g*255,c.b*255,playerName2,text))
end
function event:CHAT_MSG_WHISPER_INFORM(...)
    local text,_,_,_,playerName2,_,_,_,_,_,_,guid=...
    local c=GuidClassColor(guid)
    C:EtherInfo(sformat("To [|cff%02x%02x%02x%s|r]: %s",c.r*255,c.g*255,c.b*255,playerName2,text))
end
-- local timestamp,subevent,_,_,_,_,_,destGUID,sourceName,_,_,arg12,arg13,arg14,arg15=CombatLogGetCurrentEventInfo()
function event:COMBAT_LOG_EVENT_UNFILTERED()
    local timestamp,subevent,_,_,_,_,_,destGUID=CombatLogGetCurrentEventInfo()
    if subevent=="SPELL_AURA_APPLIED" then
        if not destGUID or not GUIDIsPlayer(destGUID) then return end
        if destGUID==C.PlayerGUID then return end
        if (timestamp-status)<40 then
            return
        end
        status=timestamp
        ScanCLEUGUID(destGUID)
    end
end
function F:MsgCLEUEnable()
    if not event:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED") then
        event:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end
function F:MsgCLEUDisable()
    if event:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED") then
        event:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end
function F:MsgEnable()
    for _,v in ipairs(D.msgEvent) do
        if not event:IsEventRegistered(v) then
            event:RegisterEvent(v)
        end
    end
end
function F:MsgDisable()
    for _,v in ipairs(D.msgEvent) do
        if event:IsEventRegistered(v) then
            event:UnregisterEvent(v)
        end
    end
end