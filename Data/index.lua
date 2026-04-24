local D,F,_,C,_=unpack(select(2,...))
local _G=_G
local pairs,ipairs=pairs,ipairs
local type,next,tostring,unpack=type,next,tostring,unpack
local UIParent=UIParent
local tconcat=table.concat
D.menuStrings={}
local Point={
    "TOPLEFT",
    "TOP",
    "TOPRIGHT",
    "LEFT",
    "CENTER",
    "RIGHT",
    "BOTTOMLEFT",
    "BOTTOM",
    "BOTTOMRIGHT",
    "UIParent",
}
local Units={
    "player",
    "target",
    "targettarget",
    "pet",
    "pettarget",
    "focus"
}
D.iEvent={
    "UNIT_CONNECTION",
    "INCOMING_RESURRECT_CHANGED",
    "PLAYER_FLAGS_CHANGED",
    "UNIT_FLAGS",
    "UNIT_FACTION",
    "RAID_TARGET_UPDATE",
    "PARTY_LEADER_CHANGED",
    "PARTY_LOOT_METHOD_CHANGED",
    "PLAYER_ROLES_ASSIGNED",
    "READY_CHECK",
    "READY_CHECK_CONFIRM",
    "READY_CHECK_FINISHED"
}
D.msgEvent={
    "CHAT_MSG_ADDON",
    "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_WHISPER",
    "CHAT_MSG_BN_WHISPER"
}
D.castEvent={
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_DELAYED",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_UPDATE",
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_FAILED_QUIET",
    "UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
    "UNIT_SPELLCAST_INTERRUPTIBLE"
}
D.iIconPath={"Interface\\CharacterFrame\\Disconnect-Icon","Interface\\RaidFrame\\Raid-Icon-Rez","Interface\\FriendsFrame\\StatusIcon-Away","Interface\\FriendsFrame\\StatusIcon-DnD",
             "Interface\\Icons\\Spell_Holy_GuardianSpirit","Interface\\Icons\\Spell_Shadow_Charm","Interface\\TargetingFrame\\UI-RaidTargetingIcons","Interface\\GroupFrame\\UI-Group-LeaderIcon",--8
             "Interface\\GroupFrame\\UI-Group-MasterLooter","Interface\\GroupFrame\\UI-Group-MainTankIcon","Interface\\GroupFrame\\UI-Group-MainAssistIcon","Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES",
             "Interface\\RaidFrame\\ReadyCheck-Ready","Interface\\RaidFrame\\ReadyCheck-NotReady","Interface\\RaidFrame\\ReadyCheck-Waiting"
}
D.iIconTable={"Connection","Resurrection","PlayerFlags","UnitFlags","UnitFaction","RaidTarget","GroupLeader",
              "MasterLoot","MainTank","GroupRole","ReadyCheck"}
D.threadEvent={"UNIT_THREAT_SITUATION_UPDATE","UNIT_PORTRAIT_UPDATE","UNIT_MODEL_CHANGED"}
D.rosterEvent={"PLAYER_TARGET_CHANGED","PLAYER_UNGHOST","GROUP_ROSTER_UPDATE","PLAYER_REGEN_DISABLED","PLAYER_REGEN_ENABLED","GROUP_JOINED"}
local PosMap,UnitMap,IndiMap={},{},{}
for i,v in ipairs(Point) do
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
    if p=="TOP" then
        return "BOTTOM",0,-1
    elseif p=="BOTTOM" then
        return "TOP",0,1
    elseif p=="LEFT" then
        return "RIGHT",1,0
    elseif p=="RIGHT" then
        return "LEFT",-1,0
    elseif p=="TOPLEFT" then
        return "BOTTOMRIGHT",1,-1
    elseif p=="TOPRIGHT" then
        return "BOTTOMLEFT",-1,-1
    elseif p=="BOTTOMLEFT" then
        return "TOPRIGHT",1,1
    elseif p=="BOTTOMRIGHT" then
        return "TOPLEFT",-1,1
    else
        return "CENTER",0,0
    end
end
D.MenuKey={"Module","Blizzard","Tooltip","Aura","Indicators","Layout","Header","Profile"}
D.Slash={"Slash","/ether user","/ether rl","/ether help","Commands","Config","Reload UI","Helper",}
D.Default={
    [1]={1,1,1,0,1,1,1,1,1,1,1,1},--Module - Name/Health/Power
    [2]={1,1,1,1,1,1,1,1,1,1,1},--Blizzard
    [3]={1,1,1,1,1,1,1,1,1,1,1},--Indicators
    [4]={1,1,1,1,1,1,1,1,1,1,1,1,1},--Tooltip
    [5]={1,1,1,1},--Header
    [6]={1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},--Layout
    [20]={
        [1]={Point[1],0,0,9},
        [2]={Point[8],0,0,9},
        [3]={Point[3],0,0,9},
        [4]={Point[2],0,0,9},
        [5]={Point[8],0,0,9},
        [6]={Point[9],0,0,9},
        [7]={Point[7],0,0,9},
        [8]={Point[1],0,-9,9},
        [9]={Point[3],0,0,9},
        [10]={Point[6],0,0,9},
        [11]={Point[2],0,0,9}
    },
    [21]={
        [1]={Point[8],Point[10],Point[8],-254,244,110,40,1,1},--player
        [2]={Point[8],Point[10],Point[8],254,244,110,40,1,1},--target
        [3]={Point[8],Point[10],Point[8],388,244,110,40,1,1},--targettarget
        [4]={Point[5],Point[10],Point[5],-350,-100,110,40,1,1},--pet
        [5]={Point[5],Point[10],Point[5],-270,-20,110,40,1,1},--pettarget
        [6]={Point[5],Point[10],Point[5],500,100,110,40,1,1},--focus
        [7]={Point[5],Point[10],Point[5],0,90,110,40,1,1},--custom 1
        [8]={Point[5],Point[10],Point[5],0,0,110,40,1,1},--custom 2
        [9]={Point[5],Point[10],Point[5],0,-90,110,40,1,1},--custom 3
        [10]={Point[8],Point[10],Point[8],0,400,55,55,1,1},--raidAnchor
        [11]={Point[7],Point[10],Point[7],520,40,50,50,1,1},--petAnchor
        [12]={Point[8],Point[10],Point[8],-380,200,360,15,1,1},--player CastBar
        [13]={Point[8],Point[10],Point[8],380,200,360,15,1,1},--target CastBar
        [14]={Point[8],Point[10],Point[8],-125,240,45,45,1,1},--player Model
        [15]={Point[8],Point[10],Point[8],125,240,45,45,1,1},--target Model
        [16]={Point[7],Point[10],Point[7],30,210,320,180,1,1},--Info Frame
        [17]={Point[8],Point[10],Point[8],390,50,280,80,1,1},--Tooltip
        [18]={Point[6],Point[10],Point[6],-380,-70,28,28,1,1},--Ether Icon
        [19]={Point[1],Point[10],Point[1],50,-100,540,280,1,1}--SettingsFrame
    },
    ["CUSTOM"]={},
    ["USER"]={},
    ["CONFIG"]={1,1,0,1,4,1,0,0,0,0,3,4}
}
C.InfoFrame=CreateFrame("Frame",nil,UIParent)
C.InfoFrame.index=16
local bg=C.InfoFrame:CreateTexture(nil,"BACKGROUND")
bg:SetAllPoints()
bg:SetColorTexture(0.1,0.1,0.1)
local right=C.InfoFrame:CreateFontString(nil,"OVERLAY")
right:SetFontObject(C.EtherFont)
right:SetPoint("TOPRIGHT",-10,-10)
C.InfoRight=right
local scroll=CreateFrame("ScrollFrame",nil,C.InfoFrame,"ScrollFrameTemplate")
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
C.InfoFrame:Hide()
function D:RefreshAllSettings()
    for i=1,6 do
        D:FrameChecked(i)
    end
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
function D:FrameChecked(number)
    local buttons=C.MainButtons
    if buttons[number] then
        for i=1,#D.DB[number] do
            local checkbox=buttons[number][i]
            if checkbox then
                checkbox:SetChecked(D.DB[number][i]==1)
            end
        end
    end
end
function D:EtherFrameSetClick(number,number2)
    local check=C.MainButtons[number][number2]
    check:SetChecked(not check:GetChecked())
    check:GetScript("OnClick")(check)
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
function D:TableSize(t)
    local count=0
    for _ in pairs(t) do
        count=count+1
    end
    return count
end
function D:RefreshAllFrames()
    D:ApplyFramePosition(C.InfoFrame)
    D:ApplyFramePosition(C.ToolFrame)
    D:ApplyFramePosition(C.MainFrame)
    D:ApplyFramePosition(C.EtherIcon)
    for index=1,6 do
        D:ApplyFramePosition(D.soloBtn[index])
    end
    for index=1,2 do
        D:ApplyFramePosition(D.castBar[index])
        D:ApplyFramePosition(D.modelBtn[index])
    end
    D:ApplyFramePosition(D.A.raid)
    D:ApplyFramePosition(D.A.pet)
    for index=1,3 do
        D:ApplyFramePosition(D.customBtn[index])
    end
end

function D:ApplyFramePosition(frame)
    if not frame or type(frame)=="nil" or not frame.index then return end
    local pos=D.DB[21][frame.index]
    local point,relToName,relPoint,x,y,w,h,scale,alpha=unpack(pos)
    local anchor=(relToName=="UIParent") and UIParent or _G[relToName] or UIParent
    frame:ClearAllPoints()
    frame:SetPoint(point,anchor,relPoint,x,y)
    frame:SetSize(w,h)
    frame:SetScale(scale)
    frame:SetAlpha(alpha)
end
local mC,pC,mR
if F.GetTbl and type(F.GetTbl)=="function" then
    mC,pC,mR=F.GetTbl(),F.GetTbl(),F.GetTbl()
end
function D:MergeToLeft(ORIG,NEW)
    if type(mC)~="table" then return end
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
    F.RelTbl(mR)
    F.RelTbl(pC)
    F.RelTbl(mC)
end
