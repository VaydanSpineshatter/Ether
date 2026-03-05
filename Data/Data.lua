local _,Ether=...
local tinsert,tsort=table.insert,table.sort
local pairs,ipairs=pairs,ipairs
local type,next=type,next

local Default={
    [101]={1,1,1,1,1,1,1,1,1,1,1},
    [111]={"Module",331,0},
    [201]={1,1,1,1,1,1},
    [301]={1,1,1,1,1,1,1,1,1,1,1,1,1},
    [401]={1,1,1,1,0,1,1,0},
    [501]={1,1,1,1,1,1,1,1,1},
    [701]={0,0,0,0},
    [801]={0,0,0},
    [811]={"Fonts\\FRIZQT__.TTF","Interface\\RaidFrame\\Raid-Bar-Hp-Fill","Interface\\FrameGeneral\\UI-Background-Rock","Interface\\DialogFrame\\UI-DialogBox-Border"},
    [1001]={1,1,1},
    [1002]={
        [1]={12,"TOP",0,0},
        [2]={24,"TOPLEFT",0,0},
        [3]={12,"BOTTOM",0,0},
        [4]={17,"CENTER",0,6},
        [5]={12,"RIGHT",0,0},
        [6]={12,"BOTTOMRIGHT",0,12},
        [7]={12,"TOP",0,0},
        [8]={12,"LEFT",0,0},
        [9]={34,"TOPLEFT",0,0},
    },
    [1003]={},
    [1101]={1,1,1},
    [1201]={1,1},
    [1301]={
        [11]={16,12,12},
        [12]={16,12,12}
    },
    [1401]={
        [1]={"CENTER","UIParent","CENTER",0,90},
        [2]={"CENTER","UIParent","CENTER",0,0},
        [3]={"CENTER","UIParent","CENTER",0,-90},
    },
    [1501]={1},
    [21]={
        [1]={"TOP","UIParent","TOP",0,-100,120,280,1,1},
        [2]={"BOTTOMRIGHT","UIParent","BOTTOMRIGHT",-350,200,320,200,1.0,1},
        [3]={"CENTER","UIParent","CENTER",-250,-200,120,50,1,1},
        [4]={"CENTER","UIParent","CENTER",250,-200,120,50,1,1},
        [5]={"CENTER","UIParent","CENTER",0,-220,120,50,1,1},
        [6]={"CENTER","UIParent","CENTER",-350,-100,120,50,1,1},
        [7]={"CENTER","UIParent","CENTER",-270,-20,120,50,1,1},
        [8]={"LEFT","UIParent","LEFT",500,100,120,50,1,1},
        [9]={"BOTTOM","UIParent","BOTTOM",0,200,1,1,1,1},
        [10]={"LEFT","UIParent","LEFT",200,0,1,1,1,1},
        [11]={"CENTER","UIParent","CENTER",0,-180,340,15,1,1},
        [12]={"CENTER","UIParent","CENTER",360,-270,240,15,1,1},
        [13]={"TOPRIGHT","Minimap","TOPLEFT",-5,0,31,31,1,1},
        [14]={"TOPLEFT","UIParent","TOPLEFT",50,-100,640,480,1,1}
    }
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

function Ether:GetTableData(tbl)
    local data={}
    for name in pairs(tbl) do
        tinsert(data,name)
    end
    tsort(data)
    return data
end

function Ether:TableSize(t)
    local count=0
    for _ in pairs(t) do
        count=count+1
    end
    return count
end

function Ether:NilCheckData(data,number)
    if data[number] then
        for subkey in pairs(Ether.DataDefault[number]) do
            if data[number][subkey]==nil then
                data[number]=Ether:CopyTable(Ether.DataDefault[number])
                break
            end
        end
    end
end

function Ether:ArrayMigrateData(data)
    local arraysLength={
        [101]=11,[201]=6,[301]=13,[401]=8,
        [501]=9,[701]=4,[801]=3,
        [1001]=3,[1101]=3,[1201]=2,[1501]=5
    }
    for arrayID,expectedLength in pairs(arraysLength) do
        if data[arrayID] and type(data[arrayID])=="table" then
            if #data[arrayID]~=expectedLength then
                data[arrayID]=Ether:DataMigrate(data[arrayID],expectedLength,1)
            end
        end
    end
end

function Ether:RefreshAllSettings()
    Ether:FrameChecked(1,401)
    Ether:FrameChecked(2,101)
    Ether:FrameChecked(3,201)
    Ether:FrameChecked(4,701)
    Ether:FrameChecked(5,1001)
    Ether:FrameChecked(6,501)
    Ether:FrameChecked(7,301)
    Ether:FrameChecked(8,801)
    Ether:FrameChecked(9,1201)
    Ether:FrameChecked(11,1501)
end

local mergeCache={}
function Ether:MergeToLeft(ORIG,NEW)
    mergeCache[ORIG]=NEW
    local LEFT=ORIG
    while LEFT~=nil do
        local RIGHT=mergeCache[LEFT]
        for NEW_KEY,NEW_VAL in pairs(RIGHT) do
            local OLD_VAL=LEFT[NEW_KEY]
            if OLD_VAL==nil then
                LEFT[NEW_KEY]=NEW_VAL
            else
                local OLD_TYPE=type(OLD_VAL)
                local NEW_TYPE=type(NEW_VAL)
                if OLD_TYPE=="table" and NEW_TYPE=="table" then
                    mergeCache[OLD_VAL]=NEW_VAL
                else
                    LEFT[NEW_KEY]=NEW_VAL
                end
            end
        end
        mergeCache[LEFT]=nil
        LEFT=next(mergeCache)
    end
end

function Ether:FrameChecked(number,data)
    if Ether.UIPanel.Buttons[number] then
        for i=1,#Ether.DB[data] do
            local checkbox=Ether.UIPanel.Buttons[number][i]
            if checkbox then
                checkbox:SetChecked(Ether.DB[data][i]==1)
            end
        end
    end
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

function Ether:EtherFrameSetClick(number,number2,number3)
    local check=Ether.UIPanel.Buttons[number][number2][number3] or Ether.UIPanel.Buttons[number][number2]
    check:SetChecked(not check:GetChecked())
    check:GetScript("OnClick")(check)
end
