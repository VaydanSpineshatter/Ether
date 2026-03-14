local _,Ether=...
local pairs,ipairs=pairs,ipairs
local type,next=type,next
local tinsert,tconcat=table.insert,table.concat
local D={"TOPLEFT","TOP","TOPRIGHT","LEFT","CENTER","RIGHT","BOTTOMLEFT","BOTTOM","BOTTOMRIGHT","UIParent","Module"}
local A={8,11,6,4,10,3,13,1,3,2}
local PosMap={}
for i,v in ipairs(D) do
    PosMap[v]=i -- "TOPLEFT" -> 1
    PosMap[i]=v -- 1 -> "TOPLEFT"
end
function Ether:PosNumber(input)
    return PosMap[input]
end
function Ether:RefreshAllSettings()
    for i=1,10 do
        Ether:FrameChecked(i)
    end
end
local Default={
    [1]={1,1,1,1,1,1,0,0},--Module
    [2]={1,1,1,1,1,1,1,1,1,1,1},--Blizzard
    [3]={1,1,1,1,1,1},--Create Units
    [4]={0,0,0,0},--Update
    [5]={1,1,1,1,1,1,1,1,1,1},--Indicators
    [6]={1,1,1},--Aura
    [7]={1,1,1,1,1,1,1,1,1,1,1,1,1},--Tooltip
    [8]={1},--Header
    [9]={1,1,1},--Layout
    [10]={1,1},--CastBar
    [1002]={
        [1]={D[1],0,0,24},
        [2]={D[1],0,0,12},
        [3]={D[1],0,0,16},
        [4]={D[2],0,0,12},
        [5]={D[8],0,0,14},
        [6]={D[9],0,0,12},
        [7]={D[2],0,0,12},
        [8]={D[4],0,0,12},
        [9]={D[1],0,0,12},
        [10]={D[1],0,0,12}
    },
    [21]={
        [1]={D[2],D[10],D[2],0,-100,120,280,1,1},
        [2]={D[9],D[10],D[9],-350,200,320,200,1.0,1},
        [3]={D[5],D[10],D[5],-250,-200,110,50,1,1},
        [4]={D[5],D[10],D[5],250,-200,110,50,1,1},
        [5]={D[5],D[10],D[5],0,-220,110,50,1,1},
        [6]={D[5],D[10],D[5],-350,-100,110,50,1,1},
        [7]={D[5],D[10],D[5],-270,-20,110,50,1,1},
        [8]={D[5],D[10],D[5],500,100,110,50,1,1},
        [9]={D[8],D[10],D[8],0,200,1,1,1,1},
        [10]={D[4],D[10],D[4],200,0,1,1,1,1},
        [11]={D[5],D[10],D[5],0,-180,340,15,1,1},
        [12]={D[5],D[10],D[5],360,-270,240,15,1,1},
        [13]={D[3],D[10],D[1],-5,0,31,31,1,1},
        [14]={D[1],D[10],D[1],50,-100,640,480,1,1}
    },
    [1003]={},
    [1401]={
        [1]={D[5],D[10],D[5],0,90},
        [2]={D[5],D[10],D[5],0,0},
        [3]={D[5],D[10],D[5],0,-90},
    },
    ["USER"]={},
    [100]={D[11],1,false,unpack(Ether.media.venite),unpack(Ether.media.elvUIBar),unpack(Ether.media.etherBg),12,"OUTLINE"}
}
Ether.DataDefault=Default

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
    if Ether.UIPanel.Buttons[number] then
        for i=1,#Ether.DB[number] do
            local checkbox=Ether.UIPanel.Buttons[number][i]
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

function Ether:RefreshFramePositions()
    local frame={
        [1]=Ether.infoFrame,
        [2]=Ether.toolFrame,
        [3]=Ether.soloButtons["player"],
        [4]=Ether.soloButtons["target"],
        [5]=Ether.soloButtons["targettarget"],
        [6]=Ether.soloButtons["pet"],
        [7]=Ether.soloButtons["pettarget"],
        [8]=Ether.soloButtons["focus"],
        [9]=Ether.Anchor.raid,
        [10]=Ether.Anchor.pet,
        [11]=Ether.soloButtons["player"].castBar,
        [12]=Ether.soloButtons["target"].castBar,
        [13]=Ether.EtherIcon,
        [14]=Ether.UIPanel.Frames["MAIN"]
    }

    for frameID in pairs(Ether.DB[21]) do
        if frameID then
            Ether:ApplyFramePosition(frame[frameID],frameID)
        end
    end
end

function Ether:ApplyFramePosition(frame,index)
    if type(index)~="number" then
        return
    end
    local pos=Ether.DB[21][index]
    for i,default in ipairs({"CENTER","UIParent","CENTER",0,0,100,100,1,1}) do
        pos[i]=pos[i] or default
    end
    if frame and pos then
        local relTo=(pos[2]=="UIParent") and UIParent or frame[pos[2]]
        frame:ClearAllPoints()
        frame:SetPoint(pos[1],relTo,pos[3],pos[4],pos[5])
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
    Ether:EtherDebug(concat)
    concat=nil
    wipe(mergeCache)
    wipe(mergeResult)
    wipe(pathCache)
end
