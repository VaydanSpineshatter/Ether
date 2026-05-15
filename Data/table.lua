local D,_,_,C=unpack(select(2,...))
local type,next,tostring,srep,schar=type,next,tostring,string.rep,string.char
local tconcat,twipe,pairs,mfloor=table.concat,table.wipe,pairs,math.floor
local tsort,loadstring,P_,_B=table.sort,loadstring,'=','ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local sformat,ipairs=string.format,ipairs
local pC,mR={},{}
function C:Base64Encode(data)
    local res={}
    for i=1,#data,3 do
        local a,b,c=data:byte(i,i+2)
        local index1=mfloor(a/4)+1
        res[#res+1]=_B:sub(index1,index1)
        if b then
            local index2=((a%4)*16)+mfloor(b/16)+1
            res[#res+1]=_B:sub(index2,index2)
            if c then
                local index3=((b%16)*4)+mfloor(c/64)+1
                res[#res+1]=_B:sub(index3,index3)
                local index4=(c%64)+1
                res[#res+1]=_B:sub(index4,index4)
            else
                local index3=((b%16)*4)+1
                res[#res+1]=_B:sub(index3,index3)
                res[#res+1]='='
            end
        else
            local index2=((a%4)*16)+1
            res[#res+1]=_B:sub(index2,index2)
            res[#res+1]='=='
        end
    end
    return tconcat(res)
end
function C:Base64Decode(encode)
    encode=encode:gsub('[^'.._B..P_..']','')
    local res={}
    for i=1,#encode,4 do
        local chunk=encode:sub(i,i+3)
        if #chunk<4 then
            break
        end
        local decode={}
        for j=1,4 do
            local char=chunk:sub(j,j)
            if char=='=' then
                decode[j]=0
            else
                decode[j]=_B:find(char,1,true)-1
            end
        end
        local byte1=(decode[1]*4)+mfloor(decode[2]/16)
        res[#res+1]=schar(byte1)
        if decode[3]~=0 or chunk:sub(3,3)~='=' then
            local byte2=((decode[2]%16)*16)+mfloor(decode[3]/4)
            res[#res+1]=schar(byte2)
        end
        if decode[4]~=0 or chunk:sub(4,4)~='=' then
            local byte3=((decode[3]%4)*64)+decode[4]
            res[#res+1]=schar(byte3)
        end
    end
    return tconcat(res)
end
local Tbl,TypeCheck
do
    local function isArray(tbl)
        if type(tbl)~="table" then
            return false
        end
        local count=0
        local maxIndex=0
        for k in pairs(tbl) do
            if type(k)~="number" or k<1 or k~=mfloor(k) then
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
    local function Array(tbl)
        local items={}
        for i=1,#tbl do
            local value=tbl[i]
            if type(value)=="table" then
                if isArray(value) then
                    items[#items+1]=Array(value)
                else
                    items[#items+1]=Tbl(value,0)
                end
            elseif type(value)=="string" then
                items[#items+1]=sformat("%q",value)
            elseif type(value)=="number" then
                items[#items+1]=tostring(value)
            elseif type(value)=="boolean" then
                items[#items+1]=value and "true" or "false"
            elseif value==nil then
                items[#items+1]="nil"
            else
                items[#items+1]=sformat("%q",tostring(value))
            end
        end
        return "{"..tconcat(items,",").."}"
    end
    function TypeCheck(value,indent)
        if type(value)=="table" then
            if isArray(value) then
                return Array(value)
            else
                return Tbl(value,indent)
            end
        elseif type(value)=="string" then
            return sformat("%q",value)
        elseif type(value)=="number" then
            return tostring(value)
        elseif type(value)=="boolean" then
            return value and "true" or "false"
        elseif value==nil then
            return "nil"
        else
            return sformat("%q",tostring(value))
        end
    end
    function Tbl(tbl,indent)
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
            return Array(tbl)
        end
        local result={}
        result[#result+1]="{"
        local keys={}
        for k in pairs(tbl) do
            keys[#keys+1]=k
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
                keyStr="["..sformat("%q",tostring(key)).."]"
            end
            local valueStr=TypeCheck(value,indent+2)
            if indent>0 and type(value)=="table" and not isArray(value) and D:TableSize(value)>2 then
                result[#result+1]="\n"..srep("",indent)..keyStr.."="..valueStr..comma
            else
                result[#result+1]=keyStr.."="..valueStr..comma..""
            end
        end
        result[#result+1]="}"
        return tconcat(result)
    end
end
function C:Serialize(tbl)
    return "return "..Tbl(tbl)
end
function C:Deserialize(str)
    if not str or str=="" then
        return false,"Empty string"
    end
    if not str:match("^%s*return") then
        str="return "..str
    end
    local func,err=loadstring(str)
    if not func then
        return false,"Compile error: "..err
    end
    local success,result=pcall(func)
    if not success then
        return false,"Execution error: "..result
    end
    return true,result
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
function D:MergeToLeft(ORIG,NEW)
    if type(D.GetProfileName)~="function" then return end
    local mC={}
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
                LEFT[NEW_KEY]=D:CopyTable(NEW_VAL)
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
    if C.InfoTimer then return end
    C:EtherInfo(tconcat(mR,'\n'))
    twipe(mR)
    twipe(pC)
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