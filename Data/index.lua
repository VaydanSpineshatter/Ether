--[[
player,target,targettarget,pet,pettarget,focus,custom1,custom2,custom3,raidBtn,raidpetBtn,playerCastBar,targetCastBar,playerModel,targetModel,Info,Tooltip,Icon,Config
Module,Blizzard,Tooltip,Indicators,Header,Layout
]]
local D,F,S,C=unpack(select(2,...))
local type,unpack,UIParent,ipairs=type,unpack,UIParent,ipairs
D.MenuKey,D.menuStrings={"Module","Blizzard","Tooltip","Indicators","Header","Layout","Aura","Profile"},{}
local P={"TOPLEFT","TOP","TOPRIGHT","LEFT","CENTER","RIGHT","BOTTOMLEFT","BOTTOM","BOTTOMRIGHT","UIParent"}
D.Slash={"Slash","/ether user","/ether rl","/ether help","or use","Version ","ether msg ","Profile ","Commands","Config","Reload UI","Helper","key binding",0,"-","-"}
local Units={"player","target","targettarget","pet","pettarget","focus"}
D.iEvent={"UNIT_CONNECTION","INCOMING_RESURRECT_CHANGED","PLAYER_FLAGS_CHANGED","UNIT_FLAGS","UNIT_FACTION","RAID_TARGET_UPDATE","PARTY_LEADER_CHANGED","PARTY_LOOT_METHOD_CHANGED","PLAYER_ROLES_ASSIGNED","READY_CHECK","READY_CHECK_CONFIRM","READY_CHECK_FINISHED"}
D.msgEvent={"CHAT_MSG_ADDON","CHAT_MSG_WHISPER_INFORM","CHAT_MSG_WHISPER","CHAT_MSG_BN_WHISPER"}
D.castEvent={"UNIT_SPELLCAST_START","UNIT_SPELLCAST_STOP","UNIT_SPELLCAST_FAILED","UNIT_SPELLCAST_INTERRUPTED","UNIT_SPELLCAST_DELAYED","UNIT_SPELLCAST_CHANNEL_START","UNIT_SPELLCAST_CHANNEL_UPDATE","UNIT_SPELLCAST_CHANNEL_STOP","UNIT_SPELLCAST_FAILED_QUIET","UNIT_SPELLCAST_NOT_INTERRUPTIBLE","UNIT_SPELLCAST_INTERRUPTIBLE"}
D.iIconPath={"Interface\\CharacterFrame\\Disconnect-Icon","Interface\\RaidFrame\\Raid-Icon-Rez","Interface\\FriendsFrame\\StatusIcon-Away","Interface\\FriendsFrame\\StatusIcon-DnD",
             "Interface\\Icons\\Spell_Holy_GuardianSpirit","Interface\\Icons\\Spell_Shadow_Charm","Interface\\TargetingFrame\\UI-RaidTargetingIcons","Interface\\GroupFrame\\UI-Group-LeaderIcon",
             "Interface\\GroupFrame\\UI-Group-MasterLooter","Interface\\GroupFrame\\UI-Group-MainTankIcon","Interface\\GroupFrame\\UI-Group-MainAssistIcon","Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES",
             "Interface\\RaidFrame\\ReadyCheck-Ready","Interface\\RaidFrame\\ReadyCheck-NotReady","Interface\\RaidFrame\\ReadyCheck-Waiting"}
D.iIconTable={"Connection","Resurrection","PlayerFlags","UnitFlags","UnitFaction","RaidTarget","GroupLeader","MasterLoot","MainTank","GroupRole","ReadyCheck"}
D.threadEvent={"UNIT_THREAT_SITUATION_UPDATE","UNIT_PORTRAIT_UPDATE","UNIT_MODEL_CHANGED"}
D.rosterEvent={"PLAYER_TARGET_CHANGED","GROUP_ROSTER_UPDATE","GROUP_JOINED"}
D.header5={"GROUP","CLASS","ASSIGNEDROLE","LEFT, TOP","TOP, LEFT"}
local PosMap,UnitMap,IndiMap={},{},{}
for i,v in ipairs(P) do
    PosMap[v]=i -- "TOPLEFT" -> 1
    PosMap[i]=v -- 1 -> "TOPLEFT"
end
for i,v in ipairs(Units) do
    UnitMap[v]=i -- "player" -> 1
    UnitMap[i]=v -- 1 -> "player"
end
for i,v in ipairs(D.iIconTable) do
    IndiMap[v]=i -- "ICON" -> 1
    IndiMap[i]=v -- 1 -> "ICON"
end
function D:PosNumber(input)
    return PosMap[input]
end
function D:PosUnit(input)
    return UnitMap[input]
end
function D:PosIndicator(input)
    return IndiMap[input]
end
function D:GetRelativePoint(p)
    p=p:upper()
    if p==P[2] then
        return P[8],0,-1
    elseif p==P[8] then
        return P[2],0,1
    elseif p==P[4] then
        return P[6],1,0
    elseif p==P[6] then
        return P[4],-1,0
    elseif p==P[1] then
        return P[9],1,-1
    elseif p==P[3] then
        return P[7],-1,-1
    elseif p==P[7] then
        return P[3],1,1
    elseif p==P[9] then
        return P[1],-1,1
    else
        return P[5],0,0
    end
end
D.Default={[1]={1,1,1,0,1,1,1,1,1,1,1,1},[2]={1,1,1,1,1,1,1,1,1,1,1},[3]={1,1,1,1,1,1,1,1,1,1,1,1,1},[4]={1,1,1,1,1,1,1,1,1,1,1},[5]={1,1,1,1},[6]={1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
           [20]={[1]={P[1],0,0,18},[2]={P[8],0,0,8},[3]={P[3],0,0,9},[4]={P[2],0,0,8},[5]={P[5],0,5,8},[6]={P[3],0,-6,8},[7]={P[7],0,8,9},[8]={P[8],0,8,8},[9]={P[3],0,0,9},[10]={P[1],0,-8,8},[11]={P[2],0,0,14}},
           [21]={[1]={P[8],P[10],P[8],-254,244,110,40,1,1},[2]={P[8],P[10],P[8],254,244,110,40,1,1},[3]={P[8],P[10],P[8],388,244,110,40,1,1},[4]={P[5],P[10],P[5],-350,-100,110,40,1,1},
                 [5]={P[5],P[10],P[5],-270,-20,110,40,1,1},[6]={P[5],P[10],P[5],500,100,110,40,1,1},[7]={P[5],P[10],P[5],0,90,110,40,1,1},[8]={P[5],P[10],P[5],0,0,110,40,1,1},
                 [9]={P[5],P[10],P[5],0,-90,110,40,1,1},[10]={P[8],P[10],P[8],0,400,55,55,1,1},[11]={P[7],P[10],P[7],520,40,45,45,1,1},[12]={P[8],P[10],P[8],-380,200,360,15,1,1},
                 [13]={P[8],P[10],P[8],380,200,360,15,1,1},[14]={P[8],P[10],P[8],-125,240,45,45,1,1},[15]={P[8],P[10],P[8],125,240,45,45,1,1},[16]={P[7],P[10],P[7],30,210,320,180,1,1},
                 [17]={P[4],P[10],P[4],60,-50,280,80,1,1},[18]={P[6],P[10],P[6],-380,-70,28,28,1,1},[19]={P[1],P[10],P[1],50,-100,540,280,1,1}},["CUSTOM"]={},["USER"]={},["CONFIG"]={1,1,0,1,4,1,22825,32067,27666,22521,3,4,"DAMAGER",0,0,0,0,0}}
function D:InitializeAddon(status)
    if type(status)~="boolean" then return end
    assert(status==true)
    _G["ETHER_DATABASE"]["VERSION"]=C.EtherVersion
    D.DB=D:CopyTable(_G["ETHER_DATABASE"]["PROFILES"][D:GetProfileName()])
    C_ChatInfo.RegisterAddonMessagePrefix(C.EtherPrefix)
    _G["ETHER_DATABASE"]["VERSION"]=C.EtherVersion
    if C.InfoFrame then
        F:MainBorder(C.InfoFrame,12,13,14,15)
        D:ApplyFramePosition(C.InfoFrame)
        F:SetupDrag(C.InfoFrame)
    end
    S.EventFrame:RegisterEvent("PLAYER_LOGIN")
end
function D:SetToDefault(status,msg)
    if type(status)~="boolean" then return end
    assert(status==false,msg)
    table.wipe(_G["ETHER_DATABASE"]["PROFILES"])
    _G["ETHER_DATABASE"]["PROFILES"]["DEFAULT"]=D:CopyTable(D.Default)
    D:CurrentProfile("DEFAULT")
    _G["ETHER_DATABASE"]["VERSION"]=C.EtherVersion
end
function D:FrameChecked(index)
    local b=C.MainButtons
    if b[index] then
        for i=1,6 do
            local check=b[index][i]
            if check then
                check:SetChecked(D.DB[index][i]==1)
            end
        end
    end
end
function D:EtherFrameSetClick(number,number2)
    if C.MainButtons[number] and C.MainButtons[number][number2] then
        local check=C.MainButtons[number][number2]
        check:SetChecked(not check:GetChecked())
        check:GetScript("OnClick")(check)
    end
end
function D:RefreshAllSettings()
    for i=1,6 do
        D:FrameChecked(i)
    end
end
function D:RefreshAllFrames()
    D:ApplyFramePosition(C.InfoFrame)
    D:ApplyFramePosition(C.ToolFrame)
    D:ApplyFramePosition(C.ConfigFrame)
    D:ApplyFramePosition(C.EtherIcon)
    for i=1,6 do
        D:ApplyFramePosition(D.soloBtn[i])
    end
    for i=1,2 do
        D:ApplyFramePosition(D.castBar[i])
        D:ApplyFramePosition(D.modelBtn[i])
    end
    D:ApplyFramePosition(D.A.raid)
    D:ApplyFramePosition(D.A.pet)
    for i=1,3 do
        D:ApplyFramePosition(D.customBtn[i])
    end
end
function D:ApplyFramePosition(f)
    if not f or type(f)=="nil" or not f.index then return end
    local pos=D.DB[21][f.index]
    if not pos then return end
    local point,relToName,relPoint,x,y,w,h,scale,alpha=unpack(pos)
    local anchor=(relToName=="UIParent") and UIParent or _G[relToName] or UIParent
    f:ClearAllPoints()
    f:SetPoint(point,anchor,relPoint,x,y)
    f:SetSize(w,h)
    f:SetScale(scale)
    f:SetAlpha(alpha)
end