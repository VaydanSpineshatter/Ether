local _,Ether=...
local tinsert,tremove,tsort,tconcat=table.insert,table.remove,table.sort,table.concat
local pairs,ipairs=pairs,ipairs
local tostring,tonumber=tostring,tonumber
local string_format=string.format
local type,next=type,next
local string_char=string.char
local string_rep=string.rep
local string_gsub=string.gsub
local string_byte=string.byte
local string_sub=string.sub
local string_find=string.find
local string_match=string.match
local string_len=string.len
local string_lower=string.lower
local string_upper=string.upper
local unpack,select=unpack,select
local CompressString=C_EncodingUtil.CompressString
local DecompressString=C_EncodingUtil.DecompressString
local math_floor=math.floor
local math_ceil=math.ceil
local math_abs=math.abs
local math_max=math.max
local math_min=math.min
local math_random=math.random
local math_sqrt=math.sqrt

local function StringToTbl(str)
    if not str or str=="" then
        return false,"Empty string"
    end
    if not str:match("^%s*return") then
        str="return "..str
    end
    local env={
        string={
            sub=string_sub,
            find=string_find,
            match=string_match,
            gsub=string_gsub,
            byte=string_byte,
            char=string_char,
            len=string_len,
            lower=string_lower,
            upper=string_upper,
            rep=string_rep,
            format=string_format,
        },
        table={
            insert=tinsert,
            remove=tremove,
            concat=tconcat,
            sort=tsort,
        },
        math={
            floor=math_floor,
            ceil=math_ceil,
            abs=math_abs,
            max=math_max,
            min=math_min,
            random=math_random,
            sqrt=math_sqrt,
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

local Base64Encode,Base64Decode
do
    local P_,_B='=','ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    function Base64Encode(data)
        local res={}
        for i=1,#data,3 do
            local a,b,c=data:byte(i,i+2)
            local index1=math_floor(a/4)+1
            tinsert(res,_B:sub(index1,index1))
            if b then
                local index2=((a%4)*16)+math_floor(b/16)+1
                tinsert(res,_B:sub(index2,index2))
                if c then
                    local index3=((b%16)*4)+math_floor(c/64)+1
                    tinsert(res,_B:sub(index3,index3))
                    local index4=(c%64)+1
                    tinsert(res,_B:sub(index4,index4))
                else
                    local index3=((b%16)*4)+1
                    tinsert(res,_B:sub(index3,index3))
                    tinsert(res,'=')
                end
            else
                local index2=((a%4)*16)+1
                tinsert(res,_B:sub(index2,index2))
                tinsert(res,'==')
            end
        end
        return tconcat(res)
    end
    function Base64Decode(data)
        data=data:gsub('[^'.._B..P_..']','')
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
                    values[j]=_B:find(char,1,true)-1
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
end

local Array,Tbl,Value,isArray
do
    function isArray(tbl)
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
    function Array(tbl)
        local items={}
        for i=1,#tbl do
            local value=tbl[i]
            if type(value)=="table" then
                if isArray(value) then
                    tinsert(items,Array(value))
                else
                    tinsert(items,Tbl(value,0))
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
            local valueStr=Value(value,indent+2)
            if indent>0 and type(value)=="table" and not isArray(value) and Ether:TableSize(value)>2 then
                tinsert(result,"\n"..string_rep("",indent)..keyStr.."="..valueStr..comma)
            else
                tinsert(result,keyStr.."="..valueStr..comma.."")
            end
        end
        tinsert(result,"}")
        return tconcat(result)
    end
    function Value(value,indent)
        if type(value)=="table" then
            if isArray(value) then
                return Array(value)
            else
                return Tbl(value,indent)
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
end

local function TblToString(tbl)
    return "return "..Tbl(tbl)
end

local function ProfileRefresh()
    Ether:UpdateAuraList()
    Ether:UpdateEditor(Ether.UIPanel.Frames["EDITOR"])
    Ether:AuraDisable()
    Ether:AuraEnable()
    Ether:RefreshLayout(Ether.raidButtons)
    Ether:RefreshLayout(Ether.soloButtons)
    Ether.UIPanel.SpellId=nil
    Ether:InitialIndicatorsPosition()
    Ether:RefreshAllSettings()
    Ether:RefreshFramePositions()
    Ether:IndicatorsFullUpdate()
    Ether.UpdateSliders()
end

function Ether:ExportProfileToClipboard()
    local encoded,err=Ether:ExportCurrentProfile()
    if not encoded then
        Ether:EtherInfo("|cffff0000Export failed:|r "..err)
        return
    end
    local editBox=CreateFrame("EditBox",nil,UIParent)
    editBox:SetText(encoded)
    editBox:SetFocus()
    editBox:HighlightText()
    editBox:SetScript("OnEscapePressed",function(self)
        self:ClearFocus()
        self:Hide()
    end)
    editBox:SetScript("OnEditFocusLost",function(self)
        self:Hide()
    end)
    Ether:EtherInfo("|cff00ff00Profile copied to clipboard!|r")
    Ether:EtherInfo("|cff888888You can now paste it anywhere|r")
    return encoded
end

function Ether:ShowExportPopup(encoded)
    if not Ether.ExportPopup then
        Ether:CreateExportPopup()
    end
    Ether.ExportPopup.EditBox:SetText(encoded)
    Ether.ExportPopup:Show()
end

function Ether:UpdateButtonFont(data)
    if not data then return end
    for _,button in pairs(data) do
        if not button then return end
        if button.name then
            button.name:SetFontHeight(Ether.DB[100][7] or 12)
        end
    end
end

function Ether:SetupFontFlags(update)
    if update=="NONE" then
        update=""
    end
    local size=Ether.DB[100][7] or 12
    local font=Ether.DB[100][4] or unpack(Ether.media.venite)
    local flag=update or "OUTLINE"
    Ether.DB[100][8]=flag
    for _,button in pairs(Ether.raidButtons) do
        if not button then return end
        if button.name then
            button.name:SetFont(font,size,flag)
        end
    end
    for _,button in pairs(Ether.soloButtons) do
        if not button then return end
        if button.name then
            button.name:SetFont(font,size,flag)
        end
    end
end

function Ether:RefreshLayout(data)
    if not data then return end
    for _,button in pairs(data) do
        if not button then return end
        if button.name then
            button.name:SetFont(Ether.DB[100][4] or unpack(Ether.media.expressway),Ether.DB[100][7] or 12,"OUTLINE")
        end
        if button.healthBar then
            button.healthBar:SetStatusBarTexture((Ether.DB[100][5] or unpack(Ether.media.blankBar)))
        end
        if button.background then
            button.background:SetTexture(Ether.DB[100][6])
        end
    end
end

function Ether:ExportCurrentProfile()
    ProfileRefresh()
    local userData=Ether:GetProfile()
    if not userData then
        return nil,"Current profile not found"
    end
    local exportData={
        name=Ether:GetProfileName(),
        version=Ether.metaData[3] or 0,
        data=userData
    }
    local serialized=TblToString(exportData)
    local compressed=CompressString(serialized,1)
    local encoded=Base64Encode(compressed)
    Ether:EtherInfo("|cff00ff00Export ready:|r "..Ether:GetProfileName())
    Ether:EtherInfo("|cff888888Size (compressed):|r "..#encoded.." characters")
    return encoded
end

function Ether:ImportProfile(encodedString)
    if not encodedString or encodedString=="" then
        return false,"Empty import string"
    end
    local decodedBinary=Base64Decode(encodedString)
    if not decodedBinary then
        return false,"Invalid Base64 encoding"
    end
    local decompressed=DecompressString(decodedBinary,1)
    if not decompressed then
        return false,"Decompression failed (possibly corrupt data)"
    end
    local success,import=StringToTbl(decompressed)
    if not success then
        return false,"Invalid data format (Compile error)"
    end
    if type(import)~="table" then
        return false,"Invalid data: No profile data found"
    end
    local name=import.name or "Imported"
    local baseName=name
    local counter=1
    while ETHER_DATABASE_DX_AA["PROFILES"][name] do
        counter=counter+1
        name=baseName.."_"..counter
    end
    ETHER_DATABASE_DX_AA["PROFILES"][name]=Ether:CopyTable(import.data)
    Ether:NilCheck(ETHER_DATABASE_DX_AA["PROFILES"][name])
    Ether:ArrayMigrate(ETHER_DATABASE_DX_AA["PROFILES"][name])
    ETHER_DATABASE_DX_AA["CURRENT"]=name
    Ether.DB=Ether:CopyTable(ETHER_DATABASE_DX_AA["PROFILES"][name])
    ProfileRefresh()
    return true,"Successfully imported as: "..name
end

function Ether:CopyProfile(sourceName,targetName)
    if not sourceName or not targetName then return end
    if not ETHER_DATABASE_DX_AA["PROFILES"][sourceName] then
        return false,"Profile "..sourceName.." not found"
    end
    if ETHER_DATABASE_DX_AA["PROFILES"][targetName] then
        return false,"Profile "..sourceName.." already exists"
    end
    ETHER_DATABASE_DX_AA["PROFILES"][targetName]=Ether:CopyTable(ETHER_DATABASE_DX_AA["PROFILES"][sourceName])
    return true,"Profile "..sourceName.."  copied"
end

function Ether:SwitchProfile(name)
    if not ETHER_DATABASE_DX_AA["PROFILES"][name] then
        return false,"Profile "..name.." not found"
    end
    ETHER_DATABASE_DX_AA["PROFILES"][Ether:GetProfileName()]=Ether:CopyTable(Ether.DB)
    Ether.DB=Ether:CopyTable(ETHER_DATABASE_DX_AA["PROFILES"][name])
    ETHER_DATABASE_DX_AA["CURRENT"]=name
    ProfileRefresh()
    return true,"Switched to "..name
end

function Ether:DeleteProfile(name)
    if not ETHER_DATABASE_DX_AA["PROFILES"][name] then
        return false,"Profile not found"
    end
    local profileCount=0
    for _ in pairs(ETHER_DATABASE_DX_AA["PROFILES"]) do
        profileCount=profileCount+1
    end
    if profileCount<=1 then
        return false,"Cannot delete the only profile"
    end
    if name==Ether:GetProfileName() then
        local otherProfile
        for profileName in pairs(ETHER_DATABASE_DX_AA["PROFILES"]) do
            if profileName~=name then
                otherProfile=profileName
                break
            end
        end
        if not otherProfile then
            return false,"No other profile available"
        end
        local success,msg=Ether:SwitchProfile(otherProfile)
        if not success then
            return false,"Failed to switch profile: "..msg
        end
    end
    ETHER_DATABASE_DX_AA["PROFILES"][name]=nil
    ProfileRefresh()
    return true,"Profile "..name.."  deleted"
end

function Ether:GetProfile()
    return ETHER_DATABASE_DX_AA["PROFILES"][Ether:GetProfileName()]
end

function Ether:ResetProfile()
    local name=Ether:GetProfileName()
    wipe(ETHER_DATABASE_DX_AA["PROFILES"][name])
    ETHER_DATABASE_DX_AA["PROFILES"][name]=Ether:CopyTable(Ether.DataDefault)
    Ether.DB=Ether:CopyTable(Ether.DataDefault)
    ProfileRefresh()
    return true,"Profile "..name.." reset to default"
end

function Ether:CreateProfile(name)
    if ETHER_DATABASE_DX_AA["PROFILES"][name] then
        return false,"Profile "..name.." already exists"
    end
    ETHER_DATABASE_DX_AA["PROFILES"][name]=Ether:CopyTable(Ether.DataDefault)
    ETHER_DATABASE_DX_AA["CURRENT"]="DEFAULT"
    ProfileRefresh()
    return true,"Profile "..name.." created"
end

function Ether:RenameProfile(oldName,newName)
    if not ETHER_DATABASE_DX_AA["PROFILES"][oldName] then
        return false,"Profile not found"
    end
    if ETHER_DATABASE_DX_AA["PROFILES"][newName] then
        return false,"Name already taken"
    end
    ETHER_DATABASE_DX_AA["PROFILES"][newName]=oldName
    ETHER_DATABASE_DX_AA["PROFILES"][newName]=oldName
    ETHER_DATABASE_DX_AA["CURRENT"]=newName
    ETHER_DATABASE_DX_AA["PROFILES"][oldName]=nil
    return true,"Profile "..oldName.." renamed to "..newName
end

function Ether:VerifyDefaultData()
    if not ETHER_DATABASE_DX_AA["PROFILES"]["DEFAULT"] then
        ETHER_DATABASE_DX_AA["PROFILES"]["DEFAULT"]=Ether:CopyTable(Ether.DataDefault)
    else
        Ether:NilCheck(ETHER_DATABASE_DX_AA["PROFILES"]["DEFAULT"])
        Ether:ArrayMigrate(ETHER_DATABASE_DX_AA["PROFILES"]["DEFAULT"])
    end
end

function Ether:LoadAddon(self)
    for _,v in ipairs({"PLAYER_LOGOUT","PLAYER_LOGIN","PLAYER_ENTERING_WORLD"}) do
        if not self:IsEventRegistered(v) then
            self:RegisterEvent(v)
        end
    end
end

function Ether:GetProfileName()
    local name=ETHER_DATABASE_DX_AA["CURRENT"]
    if not name or name=="" then return "DEFAULT" end
    return name
end

local function GetProfiles(tbl)
    local data={}
    for name in pairs(tbl) do
        if name~="VERSION" then
            tinsert(data,name)
        end
    end
    tsort(data)
    return data
end

function Ether:GetProfileList()
    return GetProfiles(ETHER_DATABASE_DX_AA["PROFILES"])
end



