local _,Ether=...
local pairs,ipairs=pairs,ipairs
local type,next,tostring=type,next,tostring
local tinsert,tconcat=table.insert,table.concat
local math_floor=math.floor
local D={"TOPLEFT","TOP","TOPRIGHT","LEFT","CENTER","RIGHT","BOTTOMLEFT","BOTTOM","BOTTOMRIGHT","UIParent","Module","Minimap"}
local U={"player","target","targettarget","pet","pettarget","focus"}
local PosMap,UnitMap={},{}
for i,v in ipairs(D) do
    PosMap[v]=i -- "TOPLEFT" -> 1
    PosMap[i]=v -- 1 -> "TOPLEFT"
end
for i,v in ipairs(U) do
    UnitMap[v]=i -- "player" -> 1
    UnitMap[i]=v -- 1 -> "player"
end
local Default={
    [1]={1,1,1,1,1,1,1,0,0},--Module
    [2]={1,1,1,1,1,1,1,1,1,1,1},--Blizzard
    [3]={1,1,1,1,1,1,1,1,1,1,1},--Indicators
    [4]={1,1,1,1,1,1,1,1,1,1,1,1,1},--Tooltip
    [5]={1},--Header
    [6]={1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},--Layout
    [20]={
        [1]={D[1],0,0,24},
        [2]={D[8],0,0,17},
        [3]={D[3],0,0,18},
        [4]={D[2],0,0,15},
        [5]={D[8],0,0,14},
        [6]={D[9],0,0,17},
        [7]={D[7],0,0,15},
        [8]={D[1],0,-9,13},
        [9]={D[3],0,0,14},
        [10]={D[2],0,0,24},
        [11]={D[7],0,0,12}
    },
    [21]={
        [1]={D[5],D[10],D[5],-250,-200,110,35,1,1},--player
        [2]={D[5],D[10],D[5],250,-200,110,35,1,1},--target
        [3]={D[5],D[10],D[5],0,-220,110,35,1,1},--targettarget
        [4]={D[5],D[10],D[5],-350,-100,110,35,1,1},--pet
        [5]={D[5],D[10],D[5],-270,-20,110,35,1,1},--pettarget
        [6]={D[5],D[10],D[5],500,100,110,35,1,1},--focus
        [7]={D[5],D[10],D[5],0,90,110,35,1,1},--custom 1
        [8]={D[5],D[10],D[5],0,0,110,35,1,1},--custom 2
        [9]={D[5],D[10],D[5],0,-90,110,35,1,1},--custom 3
        [10]={D[8],D[10],D[8],0,200,55,55,1,1},--raidButtons
        [11]={D[4],D[10],D[4],200,0,50,50,1,1},--petButtons
        [12]={D[5],D[10],D[5],0,-180,340,15,1,1},--Player CastBar
        [13]={D[5],D[10],D[5],360,-270,240,15,1,1},--Target CastBar
        [14]={D[2],D[10],D[2],0,-100,320,200,1,1},--Info Frame
        [15]={D[9],D[10],D[9],-350,200,280,120,1,1},--Tooltip
        [16]={D[5],D[12],D[5],-5,0,31,31,1,1},--Ether Icon
        [17]={D[1],D[10],D[1],50,-100,640,480,1,1},--SettingsFrame
    },

    [1003]={},
    ["USER"]={},
    [100]={D[11],1,false,unpack(Ether.media.venite),unpack(Ether.media.elvUIBar),unpack(Ether.media.etherBg),12,"OUTLINE",1}
}
Ether.DataDefault=Default
function Ether:PosNumber(input)
    return PosMap[input]
end
function Ether:UnitNumber(input)
    return UnitMap[input]
end
function Ether:RefreshAllSettings()
    for i=1,10 do
        Ether:FrameChecked(i)
    end
end
function Ether:DataEnableAll(t)
    for i=1,#t do
        t[i]=1
    end
end
function Ether:DataDisableAll(t)
    for i=1,#t do
        t[i]=0
    end
end
function Ether:DataSnapShot(t)
    local copy={}
    for i=1,#t do
        copy[i]=t[i]
    end
    return copy
end
function Ether:DataRestore(t,snapshot)
    for i=1,#snapshot do
        t[i]=snapshot[i]
    end
end
function Ether:DataMigrate(old,newSize,default)
    local t={}
    for i=1,newSize do
        t[i]=old[i]~=nil and old[i] or default
    end
    return t
end
function Ether:FrameChecked(number)
    local buttons=Ether.UIPanel.Buttons
    if buttons[number] then
        for i=1,#Ether.DB[number] do
            local checkbox=buttons[number][i]
            if checkbox then
                checkbox:SetChecked(Ether.DB[number][i]==1)
            end
        end
    end
end
function Ether:EtherFrameSetClick(number,number2)
    local check=Ether.UIPanel.Buttons[number][number2]
    check:SetChecked(not check:GetChecked())
    check:GetScript("OnClick")(check)
end
function Ether:CopyTable(orig,seen)
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
        copy[Ether:CopyTable(k,seen)]=Ether:CopyTable(v,seen)
    end
    local mt=getmetatable(orig)
    if mt then
        setmetatable(copy,Ether:CopyTable(mt,seen))
    end
    return copy
end
function Ether:TableSize(t)
    local count=0
    for _ in pairs(t) do
        count=count+1
    end
    return count
end
local function ReturnFrame(index)
    local soloButtons=Ether.soloButtons
    local customButtons=Ether.customButtons
    local castBar=Ether.castBar
    local key={
        [1]=soloButtons[1],--player
        [2]=soloButtons[2],--target
        [3]=soloButtons[3],--targettarget
        [4]=soloButtons[4],--pet
        [5]=soloButtons[5],--pettarget
        [6]=soloButtons[6],--focus
        [7]=customButtons[1],--custom1
        [8]=customButtons[2],--custom2
        [9]=customButtons[3],--custom3
        [10]=Ether.Anchor.raid,
        [11]=Ether.Anchor.pet,
        [12]=castBar[1],--Player CastBar
        [13]=castBar[2],--Target CastBar
        [14]=Ether.infoFrame,
        [15]=Ether.toolFrame,
        [16]=Ether.EtherIcon,
        [17]=Ether.UIPanel.Frames["MAIN"],
    }
    return key[index]
end
Ether.ReturnFrame=ReturnFrame
function Ether:RefreshFramePositions()
    for frameID in pairs(Ether.DB[21]) do
        if frameID then
            Ether:ApplyFramePosition(frameID)
        end
    end
end

function Ether:ApplyFramePosition(index)
    if type(index)~="number" then return end
    if not Ether.DB[21][index] then return end
    local pos=Ether.DB[21][index]
    local frame=ReturnFrame(index)
    local relToName=pos[2]
    if relToName=="UIParent" then
        relToName=UIParent
    elseif relToName=="Minimap" then
        relToName=Minimap
    end
    local x=math_floor(pos[4])
    local y=math_floor(pos[5])
    if frame and pos then
        frame:ClearAllPoints()
        frame:SetPoint(pos[1],relToName,pos[3],x,y)
        frame:SetWidth(pos[6])
        frame:SetHeight(pos[7])
        frame:SetScale(pos[8])
        frame:SetAlpha(pos[9])
    end
end
local mergeCache={}
local pathCache={}
local mergeResult={}
local concat
concat=nil
function Ether:MergeToLeft(ORIG,NEW)
    local profile=Ether:GetProfileName()..": "
    mergeCache[ORIG]=NEW
    pathCache[ORIG]=" path"
    local LEFT=ORIG
    while LEFT~=nil do
        local RIGHT=mergeCache[LEFT]
        local CURRENT_PATH=pathCache[LEFT]
        tinsert(mergeResult,profile..CURRENT_PATH)
        for NEW_KEY,NEW_VAL in pairs(RIGHT) do
            local OLD_VAL=LEFT[NEW_KEY]
            if OLD_VAL==nil then
                tinsert(mergeResult,"  Missing Key '"..tostring(NEW_KEY).."' in "..CURRENT_PATH)
                LEFT[NEW_KEY]=NEW_VAL
            elseif type(OLD_VAL)=="table" and type(NEW_VAL)=="table" then
                mergeCache[OLD_VAL]=NEW_VAL
                pathCache[OLD_VAL]=CURRENT_PATH.."."..tostring(NEW_KEY)
            end
        end
        mergeCache[LEFT]=nil
        pathCache[LEFT]=nil
        LEFT=next(mergeCache)
    end
end
function Ether:MergeAnalyse()
    concat=tconcat(mergeResult,"\n")
    if type(concat)=="nil" then return end
    if Ether.EtherDebug then
        Ether:EtherDebug(concat)
    end
    concat=nil
    wipe(mergeCache)
    wipe(mergeResult)
    wipe(pathCache)
end
