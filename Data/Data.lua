local _,Ether=...
local tinsert,tsort,tconcat=table.insert,table.sort,table.concat
local pairs,ipairs=pairs,ipairs
local tostring=tostring
local string_format=string.format
local type,next=type,next
local math_floor=math.floor
local string_char=string.char
local string_rep=string.rep

local STR={
    [1]="UIParent",
    [2]="TOPLEFT",
    [3]="TOP",
    [4]="TOPRIGHT",
    [5]="LEFT",
    [6]="CENTER",
    [7]="RIGHT",
    [8]="BOTTOMLEFT",
    [9]="BOTTOM",
    [10]="BOTTOMRIGHT"
}

local Default={
    [1]=0,
    [101]={1,1,1,1,1,0,0,0,0,0,0},
    [111]={0,1,"Module",331},
    [201]={1,1,1,1,1,1},
    [301]={1,1,1,1,1,1,1,1,1,1,1,1,1},
    [401]={1,1,1,1,0,1,1},
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
        [1]={"RIGHT","UIParent","RIGHT",-340,-340,120,280,1,1},
        [2]={"CENTER","UIParent","CENTER",-250,-200,120,50,1,1},
        [3]={"CENTER","UIParent","CENTER",250,-200,120,50,1,1},
        [4]={"CENTER","UIParent","CENTER",0,-220,120,50,1,1},
        [5]={"CENTER","UIParent","CENTER",-350,-100,120,50,1,1},
        [6]={"CENTER","UIParent","CENTER",-270,-20,120,50,1,1},
        [7]={"LEFT","UIParent","LEFT",500,100,120,50,1,1},
        [8]={"LEFT","UIParent","LEFT",200,-200,1,1,1,1},
        [9]={"TOP","UIParent","TOP",80,-80,320,200,1.0,1},
        [10]={"TOPLEFT","UIParent","TOPLEFT",50,-100,640,480,1,1},
        [11]={"CENTER","UIParent","CENTER",0,-180,340,15,1,1},
        [12]={"CENTER","UIParent","CENTER",360,-270,240,15,1,1}
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
        [101]=11,[201]=6,[301]=13,[401]=7,
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
    local solo=Ether.unitButtons.solo
    local frame={
        [1]=Ether.toolFrame,
        [2]=solo["player"],
        [3]=solo["target"],
        [4]=solo["targettarget"],
        [5]=solo["pet"],
        [6]=solo["pettarget"],
        [7]=solo["focus"],
        [8]=Ether.Anchor.raid,
        [9]=Ether.infoFrame,
        [10]=Ether.UIPanel.Frames["MAIN"],
        [11]=solo["player"].castBar,
        [12]=solo["target"].castBar
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

function Ether:StringToTbl(str)
    if not str or str=="" then
        return false,"Empty string"
    end
    if not str:match("^%s*return") then
        str="return "..str
    end
    local env={
        string={
            sub=string.sub,
            find=string.find,
            match=string.match,
            gsub=string.gsub,
            byte=string.byte,
            char=string.char,
            len=string.len,
            lower=string.lower,
            upper=string.upper,
            rep=string.rep,
            format=string.format,
        },
        table={
            insert=table.insert,
            remove=table.remove,
            concat=table.concat,
            sort=table.sort,
        },
        math={
            floor=math.floor,
            ceil=math.ceil,
            abs=math.abs,
            max=math.max,
            min=math.min,
            random=math.random,
            sqrt=math.sqrt,
        },
        tonumber=tonumber,
        tostring=tostring,
        type=type,
        pairs=pairs,
        ipairs=ipairs,
        next=next,
        select=select,
        unpack=unpack,
        error=error,
        pcall=pcall,
        assert=assert,
        _VERSION=_VERSION,
    }
    setmetatable(env,{
        __index=function(t,k)
            error("Access to forbidden global: "..tostring(k),2)
        end,
        __newindex=function(t,k,v)
            error("Modification of environment forbidden",2)
        end
    })
    local func,err=loadstring(str)
    if not func then
        return false,"Compile error: "..err
    end
    setfenv(func,env)
    local success,result=pcall(func)
    if not success then
        return false,"Execution error: "..result
    end
    return true,result
end

local function isArray(tbl)
    if type(tbl)~="table" then
        return false
    end
    local count=0
    local maxIndex=0
    for k,v in pairs(tbl) do
        if type(k)~="number" or k<1 or k~=math_floor(k) then
            return false
        end
        count=count+1
        if k>maxIndex then
            maxIndex=k
        end
    end
    if count==0 or count~=maxIndex then
        return false
    end
    return true
end

local function serializeValue(value,indent)
    if type(value)=="table" then
        if isArray(value) then
            return Ether:SerializeArray(value)
        else
            return Ether:SerializeTbl(value,indent)
        end
    elseif type(value)=="string" then
        return string_format("%q",value)
    elseif type(value)=="number" then
        return tostring(value)
    elseif type(value)=="boolean" then
        return value and "true" or "false"
    elseif value==nil then
        return "nil"
    else
        return string_format("%q",tostring(value))
    end
end

function Ether:SerializeArray(tbl)
    local items={}
    for i=1,#tbl do
        local value=tbl[i]
        if type(value)=="table" then
            if isArray(value) then
                tinsert(items,Ether:SerializeArray(value))
            else
                tinsert(items,Ether:SerializeTbl(value,0))
            end
        elseif type(value)=="string" then
            tinsert(items,string_format("%q",value))
        elseif type(value)=="number" then
            tinsert(items,tostring(value))
        elseif type(value)=="boolean" then
            tinsert(items,value and "true" or "false")
        elseif value==nil then
            tinsert(items,"nil")
        else
            tinsert(items,string_format("%q",tostring(value)))
        end
    end
    return "{"..tconcat(items,",").."}"
end

function Ether:SerializeTbl(tbl,indent)
    indent=indent or 0

    local isEmpty=true
    for _ in pairs(tbl) do
        isEmpty=false
        break
    end
    if isEmpty then
        return "{}"
    end

    if isArray(tbl) then
        return Ether:SerializeArray(tbl)
    end

    local result={}
    tinsert(result,"{")

    local keys={}
    for k in pairs(tbl) do
        tinsert(keys,k)
    end
    tsort(keys,function(a,b)
        if type(a)==type(b) then
            return a<b
        else
            return type(a)=="number"
        end
    end)
    for i,key in ipairs(keys) do
        local value=tbl[key]
        local comma=i<#keys and "," or ""

        local keyStr
        if type(key)=="number" then
            keyStr="["..key.."]"
        elseif type(key)=="string" and key:match("^[a-zA-Z_][a-zA-Z0-9_]*$") then
            keyStr=key
        else
            keyStr="["..string_format("%q",tostring(key)).."]"
        end

        local valueStr=serializeValue(value,indent+2)

        if indent>0 and type(value)=="table" and not isArray(value) and Ether:TableSize(value)>2 then
            tinsert(result,"\n"..string_rep("",indent)..keyStr.."="..valueStr..comma)
        else
            tinsert(result,keyStr.."="..valueStr..comma.."")
        end
    end

    tinsert(result,"}")
    return tconcat(result)
end

function Ether:TblToString(tbl)
    return "return "..Ether:SerializeTbl(tbl)
end

local P,B='=','ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

function Ether:Base64Encode(data)
    local res={}
    for i=1,#data,3 do
        local a,b,c=data:byte(i,i+2)
        local index1=math_floor(a/4)+1
        tinsert(res,B:sub(index1,index1))
        if b then
            local index2=((a%4)*16)+math_floor(b/16)+1
            tinsert(res,B:sub(index2,index2))
            if c then
                local index3=((b%16)*4)+math_floor(c/64)+1
                tinsert(res,B:sub(index3,index3))
                local index4=(c%64)+1
                tinsert(res,B:sub(index4,index4))
            else
                local index3=((b%16)*4)+1
                tinsert(res,B:sub(index3,index3))
                tinsert(res,'=')
            end
        else
            local index2=((a%4)*16)+1
            tinsert(res,B:sub(index2,index2))
            tinsert(res,'==')
        end
    end
    return tconcat(res)
end

function Ether:Base64Decode(data)
    data=data:gsub('[^'..B..P..']','')
    local res={}
    for i=1,#data,4 do
        local chunk=data:sub(i,i+3)
        if #chunk<4 then
            break
        end
        local values={}
        for j=1,4 do
            local char=chunk:sub(j,j)
            if char=='=' then
                values[j]=0
            else
                values[j]=B:find(char,1,true)-1
            end
        end
        local byte1=(values[1]*4)+math_floor(values[2]/16)
        tinsert(res,string_char(byte1))
        if values[3]~=0 or chunk:sub(3,3)~='=' then
            local byte2=((values[2]%16)*16)+math_floor(values[3]/4)
            tinsert(res,string_char(byte2))
        end
        if values[4]~=0 or chunk:sub(4,4)~='=' then
            local byte3=((values[3]%4)*64)+values[4]
            tinsert(res,string_char(byte3))
        end
    end
    return tconcat(res)
end
