local D,F,S,C=unpack(select(2,...))
local event,GetPlayerInfoByGUID,CombatLogGetCurrentEventInfo,snapshot,status,tconcat=S.EventFrame,GetPlayerInfoByGUID,CombatLogGetCurrentEventInfo,nil,0,table.concat
local UnitGUID,ipairs,sformat,UnitExists,GUIDIsPlayer,Received=UnitGUID,ipairs,string.format,UnitExists,C_PlayerInfo.GUIDIsPlayer,{}
local eFaction={["Human"]=true,["Dwarf"]=true,["NightElf"]=true,["Gnome"]=true,["Draenei"]=true}
local NE,E="|cff00ff00not Enemy|r","|cffff0000Enemy|r"
if eFaction[UnitRace("player")] then
    NE,E="|cffff0000Enemy|r","|cff00ff00not Enemy|r"
end
local P="Found: |cff%02x%02x%02x%s |r %s"
local function ValidGUID(guid)
    if guid==C.PlayerGUID then
        return true
    end
    for i,v in ipairs(D.DB["USER"]) do
        if v==guid then
            return true,i
        end
    end
    return false
end
local function GuidClassColor(guid)
    local _,class,_,race,_,name=GetPlayerInfoByGUID(guid)
    local c=RAID_CLASS_COLORS[class] or RAID_CLASS_COLORS["PRIEST"]
    local enemy=eFaction[race] and E or NE
    return c,name or "UNKNOWN",enemy
end
local count=0
local function OnVersion(message)
    local theirVersion=tonumber(message)
    local myVersion=tonumber(C.EtherVersion)
    count=count+1
    if D.menuStrings[8] and D.menuStrings[9] then
        D.menuStrings[9]:SetText(string.format("%s %s",D.Slash[9],tostring(count)))
    end
    local lastCheck=_G["ETHER_DATABASE"]["LAST"] or 0
    if (time()-lastCheck>=5000) and theirVersion and myVersion and myVersion<theirVersion then
        _G["ETHER_DATABASE"]["LAST"]=time()
        if D.menuStrings[8] and D.menuStrings[9] then
            D.menuStrings[8]:SetText(string.format("%s %s",D.Slash[8],_G["ETHER_DATABASE"]["LAST"]))
        end
        C:EtherInfo(sformat("New version found (%d). Get the latest version from %s",theirVersion,"|cFF00CCFFhttps://www.curseforge.com/wow/addons/ether|r"))
    end
end
function F:ScanTargetGUID()
    if not UnitExists("target") then return end
    local guid=UnitGUID("target")
    if not guid then return end
    if guid==C.PlayerGUID then return end
    local c,name,enemy=GuidClassColor(guid)
    if ValidGUID(guid) then
        F:StartFlash()
        C:EtherInfo(sformat(P,c.r*255,c.g*255,c.b*255,name,enemy))
    end
end
function F:ScanGUID()
    if not UnitExists("target") then return end
    local guid=UnitGUID("target")
    if not guid then return end
    if guid==C.PlayerGUID then return end
    local human=GUIDIsPlayer(guid)
    if not human then return end
    local c,name,enemy=GuidClassColor(guid)
    local valid,index=ValidGUID(guid)
    if not valid then
        D.DB["USER"][#D.DB["USER"]+1]=guid
        C:EtherInfo(sformat("|cff00ff00Added:|r |cff%02x%02x%02x%s |r %s",c.r*255,c.g*255,c.b*255,name,enemy))
    else
        table.remove(D.DB["USER"],index)
        C:EtherInfo(sformat("|cffff0000Removed:|r |cff%02x%02x%02x%s |r %s",c.r*255,c.g*255,c.b*255,name,enemy))
    end
    if C.RemoveDropdown then
        C.RemoveDropdown:SetOptions(D.DB["USER"])
    end
end
function F:RemoveByIndex(index)
    if not index or type(index)~="number" then return end
    for i,v in ipairs(D.DB["USER"]) do
        if i==index then
            local c,name,enemy=GuidClassColor(v)
            table.remove(D.DB["USER"],index)
            C:EtherInfo(sformat("|cffff0000Removed:|r |cff%02x%02x%02x%s |r %s",c.r*255,c.g*255,c.b*255,name,enemy))
            break
        end
    end
end
local data={}
function F:PrintGUID()
    if D:TableSize(D.DB["USER"])==0 then
        C:EtherInfo("No guid available to print")
        return
    end
    for index,guid in ipairs(D.DB["USER"]) do
        local c,name,enemy=GuidClassColor(guid)
        data[#data+1]=sformat("%s. |cff%02x%02x%02x%s|r %s %s",index,c.r*255,c.g*255,c.b*255,name,enemy,guid)
    end
    C:EtherInfo(tconcat(data,'\n'))
    table.wipe(data)
end
local function ScanCLEUGUID(destGUID)
    for _,guid in ipairs(D.DB["USER"]) do
        if guid==destGUID then
            local c,name,enemy=GuidClassColor(guid)
            F:StartFlash()
            C:EtherInfo(sformat(P,c.r*255,c.g*255,c.b*255,name,enemy))
            break
        end
    end
end
function F:CreateSnapshot()
    local guid=UnitGUID("target")
    if not guid or type(guid)=="nil" then return end
    snapshot=guid
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
    OnVersion(D:ImportAddonMsg(message))
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
function event:COMBAT_LOG_EVENT_UNFILTERED()
    local timestamp,subevent,_,_,_,_,_,destGUID=CombatLogGetCurrentEventInfo()
    if subevent=="SPELL_AURA_APPLIED" then
        if not destGUID or not GUIDIsPlayer(destGUID) then return end
        if destGUID==C.PlayerGUID then return end
        if (timestamp-status)<21 then
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
F:RegisterCallbackByIndex(F.MsgEnable,2)
F:RegisterCallbackByIndex(F.MsgCLEUEnable,3)
F:RegisterCallbackByIndex(F.MsgDisable,2+30)
F:RegisterCallbackByIndex(F.MsgCLEUDisable,3+30)