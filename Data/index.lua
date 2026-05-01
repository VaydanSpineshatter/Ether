local D,_,_,C=unpack(select(2,...))
local type,next,tostring,unpack=type,next,tostring,unpack
local tconcat,UIParent,pairs,ipairs=table.concat,UIParent,pairs,ipairs
D.MenuKey,D.menuStrings={"Module","Blizzard","Tooltip","Aura","Indicators","Layout","Header","Profile"},{}
local P={"TOPLEFT","TOP","TOPRIGHT","LEFT","CENTER","RIGHT","BOTTOMLEFT","BOTTOM","BOTTOMRIGHT","UIParent"}
D.Slash={"Slash","/ether user","/ether rl","/ether help","or use","Addon Version ","Prefix Registered ","Latest version ","Addon calls ","Commands","Config","Reload UI","Helper","key binding",C_AddOns.GetAddOnMetadata("Ether","Version") or "0.8.1","-",tostring(_G["ETHER_DATABASE"]["LAST"] or 0),tostring(0)}
local Units={"player","target","targettarget","pet","pettarget","focus"}
D.iEvent={"UNIT_CONNECTION","INCOMING_RESURRECT_CHANGED","PLAYER_FLAGS_CHANGED","UNIT_FLAGS","UNIT_FACTION","RAID_TARGET_UPDATE","PARTY_LEADER_CHANGED","PARTY_LOOT_METHOD_CHANGED","PLAYER_ROLES_ASSIGNED","READY_CHECK","READY_CHECK_CONFIRM","READY_CHECK_FINISHED"}
D.msgEvent={"CHAT_MSG_ADDON","CHAT_MSG_WHISPER_INFORM","CHAT_MSG_WHISPER","CHAT_MSG_BN_WHISPER"}
D.castEvent={"UNIT_SPELLCAST_START","UNIT_SPELLCAST_STOP","UNIT_SPELLCAST_FAILED","UNIT_SPELLCAST_INTERRUPTED","UNIT_SPELLCAST_DELAYED","UNIT_SPELLCAST_CHANNEL_START",
             "UNIT_SPELLCAST_CHANNEL_UPDATE","UNIT_SPELLCAST_CHANNEL_STOP","UNIT_SPELLCAST_FAILED_QUIET","UNIT_SPELLCAST_NOT_INTERRUPTIBLE","UNIT_SPELLCAST_INTERRUPTIBLE"}
D.iIconPath={"Interface\\CharacterFrame\\Disconnect-Icon","Interface\\RaidFrame\\Raid-Icon-Rez","Interface\\FriendsFrame\\StatusIcon-Away","Interface\\FriendsFrame\\StatusIcon-DnD",
             "Interface\\Icons\\Spell_Holy_GuardianSpirit","Interface\\Icons\\Spell_Shadow_Charm","Interface\\TargetingFrame\\UI-RaidTargetingIcons","Interface\\GroupFrame\\UI-Group-LeaderIcon",
             "Interface\\GroupFrame\\UI-Group-MasterLooter","Interface\\GroupFrame\\UI-Group-MainTankIcon","Interface\\GroupFrame\\UI-Group-MainAssistIcon","Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES",
             "Interface\\RaidFrame\\ReadyCheck-Ready","Interface\\RaidFrame\\ReadyCheck-NotReady","Interface\\RaidFrame\\ReadyCheck-Waiting"}
D.iIconTable={"Connection","Resurrection","PlayerFlags","UnitFlags","UnitFaction","RaidTarget","GroupLeader","MasterLoot","MainTank","GroupRole","ReadyCheck"}
D.threadEvent={"UNIT_THREAT_SITUATION_UPDATE","UNIT_PORTRAIT_UPDATE","UNIT_MODEL_CHANGED"}
D.rosterEvent={"PLAYER_TARGET_CHANGED","GROUP_ROSTER_UPDATE","GROUP_JOINED"}
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
--Module,Blizzard,Indicators,Tooltip,Header,Layout
--player,target,targettarget,pet,pettarget,focus,custom1,custom2,custom3,raid,raidpet,playerCastBar,targetCastBar,playerModel,targetModel,Info,Tooltip,Icon,Config
D.Default={[1]={1,1,1,0,1,1,1,1,1,1,1,1},[2]={1,1,1,1,1,1,1,1,1,1,1},[3]={1,1,1,1,1,1,1,1,1,1,1},[4]={1,1,1,1,1,1,1,1,1,1,1,1,1},[5]={1,1,1,1},[6]={1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
           [20]={[1]={P[1],0,0,18},[2]={P[8],0,0,9},[3]={P[3],0,0,9},[4]={P[2],0,0,9},[5]={P[8],0,0,9},[6]={P[9],0,0,9},[7]={P[7],0,0,9},[8]={P[1],0,-9,9},[9]={P[3],0,0,9},[10]={P[6],0,0,9},[11]={P[2],0,0,9}},
           [21]={[1]={P[8],P[10],P[8],-254,244,110,40,1,1},[2]={P[8],P[10],P[8],254,244,110,40,1,1},[3]={P[8],P[10],P[8],388,244,110,40,1,1},[4]={P[5],P[10],P[5],-350,-100,110,40,1,1},
                 [5]={P[5],P[10],P[5],-270,-20,110,40,1,1},[6]={P[5],P[10],P[5],500,100,110,40,1,1},[7]={P[5],P[10],P[5],0,90,110,40,1,1},[8]={P[5],P[10],P[5],0,0,110,40,1,1},
                 [9]={P[5],P[10],P[5],0,-90,110,40,1,1},[10]={P[8],P[10],P[8],0,400,55,55,1,1},[11]={P[7],P[10],P[7],520,40,50,50,1,1},[12]={P[8],P[10],P[8],-380,200,360,15,1,1},
                 [13]={P[8],P[10],P[8],380,200,360,15,1,1},[14]={P[8],P[10],P[8],-125,240,45,45,1,1},[15]={P[8],P[10],P[8],125,240,45,45,1,1},[16]={P[7],P[10],P[7],30,210,320,180,1,1},
                 [17]={P[4],P[10],P[4],60,-50,280,80,1,1},[18]={P[6],P[10],P[6],-380,-70,28,28,1,1},[19]={P[1],P[10],P[1],50,-100,540,280,1,1}},["CUSTOM"]={},["USER"]={},["CONFIG"]={1,1,0,1,4,1,0,0,0,0,3,4,"NONE",0,0,0}}
local frame=CreateFrame("Frame",nil,UIParent)
C.InfoFrame=frame
frame:Hide()
frame.index=16
local bg=frame:CreateTexture(nil,"BACKGROUND")
bg:SetAllPoints()
bg:SetColorTexture(0.1,0.1,0.1)
local right=frame:CreateFontString(nil,"OVERLAY")
right:SetFontObject(C.EtherFont)
right:SetPoint("TOPRIGHT",-10,-10)
C.InfoRight=right
local scroll=CreateFrame("ScrollFrame",nil,frame,"ScrollFrameTemplate")
scroll:SetPoint("TOPLEFT",10,-30)
scroll:SetPoint("BOTTOMRIGHT",-30,10)
local cF=CreateFrame("Frame",nil,scroll)
cF:SetSize(390,111)
scroll:SetScrollChild(cF)
local txt=cF:CreateFontString(nil,"OVERLAY")
C.InfoText=txt
txt:SetFontObject(C.EtherFont)
txt:SetPoint("TOPLEFT")
txt:SetWidth(290)
txt:SetJustifyH("LEFT")
scroll:EnableMouseWheel(true)
scroll:SetScript("OnMouseWheel",function(self,delta)
    if delta>0 then
        self:SetVerticalScroll(-50)
    else
        self:SetVerticalScroll(50)
    end
end)
if scroll.ScrollBar then
    scroll.ScrollBar:Hide()
end
function D:DataEnableAll(t)
    for i=1,#t do
        t[i]=1
    end
end
function D:DataDisableAll(t)
    for i=1,#t do
        t[i]=0
    end
end
function D:DataSnapShot(t)
    local copy={}
    for i=1,#t do
        copy[i]=t[i]
    end
    return copy
end
function D:DataRestore(t,snapshot)
    for i=1,#snapshot do
        t[i]=snapshot[i]
    end
end
function D:DataMigrate(old,newSize,default)
    local t={}
    for i=1,newSize do
        t[i]=old[i]~=nil and old[i] or default
    end
    return t
end
function D:ProfileMigrate(tbl,key,number)
    if tbl[key] and type(tbl[key])=="table" then
        if #tbl[key] ~= number then
            tbl[key]=D:DataMigrate(tbl[key],number,0)
        end
    end
    if type(tbl[key][13])~="string" then
         tbl[key][13] = "NONE"
    end
end
function D:CopyTable(orig,seen)
    if type(orig)~="table" then
        return orig
    end
    seen=seen or {}
    if seen[orig] then
        return seen[orig]
    end
    local copy={}
    seen[orig]=copy
    for k,v in pairs(orig) do
        copy[D:CopyTable(k,seen)]=D:CopyTable(v,seen)
    end
    local mt=getmetatable(orig)
    if mt then
        setmetatable(copy,D:CopyTable(mt,seen))
    end
    return copy
end
local count=0
function D:TableSize(t)
    count=0
    for _ in pairs(t) do
        count=count+1
    end
    return count
end
function D:FrameChecked(index)
    local b=C.MainButtons
    if b[index] then
        for i=1,#D.DB[index] do
            local check=b[index][i]
            if check then
                check:SetChecked(D.DB[index][i]==1)
            end
        end
    end
end
function D:EtherFrameSetClick(number,number2)
    local check=C.MainButtons[number][number2]
    check:SetChecked(not check:GetChecked())
    check:GetScript("OnClick")(check)
end
function D:RefreshAllSettings()
    for i=1,6 do
        D:FrameChecked(i)
    end
end
function D:RefreshAllFrames()
    D:ApplyFramePosition(C.InfoFrame)
    D:ApplyFramePosition(C.ToolFrame)
    D:ApplyFramePosition(C.MainFrame)
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
local mC,pC,mR={},{},{}
function D:MergeToLeft(ORIG,NEW)
    if type(D.GetProfileName)~="function" then return end
    mC[ORIG]=NEW
    pC[ORIG]=" path"
    local LEFT=ORIG
    while LEFT~=nil do
        local RIGHT=mC[LEFT]
        local CURRENT_PATH=pC[LEFT]
        mR[#mR+1]=D:GetProfileName()..": "..CURRENT_PATH
        for NEW_KEY,NEW_VAL in pairs(RIGHT) do
            local OLD_VAL=LEFT[NEW_KEY]
            if OLD_VAL==nil then
                mR[#mR+1]="  Missing Key '"..tostring(NEW_KEY).."' in "..CURRENT_PATH
                LEFT[NEW_KEY]=NEW_VAL
            elseif type(OLD_VAL)=="table" and type(NEW_VAL)=="table" then
                mC[OLD_VAL]=NEW_VAL
                pC[OLD_VAL]=CURRENT_PATH.."."..tostring(NEW_KEY)
            end
        end
        mC[LEFT]=nil
        pC[LEFT]=nil
        LEFT=next(mC)
    end
end
function D:MergeAnalyse()
    if not C.InfoFrame then return end
    if C.InfoTimer then return end
    C:EtherInfo(tconcat(mR,'\n'))
    table.wipe(mR)
    table.wipe(pC)
    table.wipe(mC)
end
