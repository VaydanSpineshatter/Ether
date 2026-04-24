local D,F,_,C,_=unpack(select(2,...))
local tinsert,tsort,tconcat=table.insert,table.sort,table.concat
local pairs,ipairs=pairs,ipairs
local tostring=tostring
local sformat=string.format
local type=type
local string_char=string.char
local string_rep=string.rep
local CompressString=C_EncodingUtil.CompressString
local DecompressString=C_EncodingUtil.DecompressString
local math_floor=math.floor
local function StringToTbl(str)
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
                tinsert(items,sformat("%q",value))
            elseif type(value)=="number" then
                tinsert(items,tostring(value))
            elseif type(value)=="boolean" then
                tinsert(items,value and "true" or "false")
            elseif value==nil then
                tinsert(items,"nil")
            else
                tinsert(items,sformat("%q",tostring(value)))
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
                keyStr="["..sformat("%q",tostring(key)).."]"
            end
            local valueStr=Value(value,indent+2)
            if indent>0 and type(value)=="table" and not isArray(value) and D:TableSize(value)>2 then
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
end
local function TblToString(tbl)
    return "return "..Tbl(tbl)
end
local function ProfileRefresh()
    F:UpdateAuraList()
    F:UpdateEditor(C.EditorFrame)
    F:AuraDisable()
    for index=1,11 do
        F:SavePosition(index)
    end
    F:IndicatorsDisable()
    F:MenuStringsAlpha(0)
    D:RefreshAllSettings()
    D:RefreshAllFrames()
    F:IndicatorsEnable()
    F:AuraEnable()
    F:IndicatorsFullUpdateBtn()
end
function D:ExportProfileToClipboard()
    local encoded,err=D:ExportCurrentProfile()
    if not encoded then
        C:EtherInfo("|cffff0000Export failed:|r "..err)
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
    C:EtherInfo("|cff00ff00Profile copied to clipboard!|r")
    C:EtherInfo("|cff888888You can now paste it anywhere|r")
    return encoded
end
function D:ExportCurrentProfile()
    ProfileRefresh()
    local userData=D:GetProfile()
    if not userData then
        return nil,"Current profile not found"
    end
    local exportData={
        name=D:GetProfileName(),
        data=userData
    }
    local serialized=TblToString(exportData)
    local compressed=CompressString(serialized,1)
    local encoded=Base64Encode(compressed)
    C:EtherInfo("|cff00ff00Export ready:|r "..D:GetProfileName())
    C:EtherInfo("|cff888888Size (compressed):|r "..#encoded.." characters")
    return encoded
end
function D:ImportProfile(encodedString)
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
    while _G["ETHER_DATABASE"]["PROFILES"][name] do
        counter=counter+1
        name=baseName.."_"..counter
    end
    _G["ETHER_DATABASE"]["PROFILES"][name]=D:CopyTable(import.data)
    D:MergeToLeft(_G["ETHER_DATABASE"]["PROFILES"][name],D.Default)
    _G["ETHER_DATABASE"]["CURRENT"]=name
    D.DB=D:CopyTable(_G["ETHER_DATABASE"]["PROFILES"][name])
    ProfileRefresh()
    D:MergeAnalyse()
    return true,"Successfully imported as: "..name
end
function D:CopyProfile(sourceName,targetName)
    if not sourceName or not targetName then return end
    if not _G["ETHER_DATABASE"]["PROFILES"][sourceName] then
        return false,"Profile "..sourceName.." not found"
    end
    if _G["ETHER_DATABASE"]["PROFILES"][targetName] then
        return false,"Profile "..sourceName.." already exists"
    end
    _G["ETHER_DATABASE"]["PROFILES"][targetName]=D:CopyTable(_G["ETHER_DATABASE"]["PROFILES"][sourceName])
    return true,"Profile "..sourceName.."  copied"
end
function D:SwitchProfile(name)
    if not _G["ETHER_DATABASE"]["PROFILES"][name] then
        return false,"Profile "..name.." not found"
    end
    _G["ETHER_DATABASE"]["PROFILES"][D:GetProfileName()]=D:CopyTable(D.DB)
    C.MainFrame:Hide()
    D.DB=D:CopyTable(_G["ETHER_DATABASE"]["PROFILES"][name])
    C.MainFrame:Show()
    C.ChildFrames[8]:Show()
    if C.PopupBox and C.PopupBox.font then
        C.PopupBox.font:SetText(D:GetProfileName())
    end
    _G["ETHER_DATABASE"]["CURRENT"]=name
    ProfileRefresh()
    return true,"Switched to "..name
end
function D:DeleteProfile(name)
    if not _G["ETHER_DATABASE"]["PROFILES"][name] then
        return false,"Profile not found"
    end
    local profileCount=0
    for _ in pairs(_G["ETHER_DATABASE"]["PROFILES"]) do
        profileCount=profileCount+1
    end
    if profileCount<=1 then
        return false,"Cannot delete the only profile"
    end
    if name==D:GetProfileName() then
        local otherProfile
        for profileName in pairs(_G["ETHER_DATABASE"]["PROFILES"]) do
            if profileName~=name then
                otherProfile=profileName
                _G["ETHER_DATABASE"]["CURRENT"]=profileName
                break
            end
        end
        if not otherProfile then
            return false,"No other profile available"
        end
        local success,msg=D:SwitchProfile(otherProfile)
        if not success then
            return false,"Failed to switch profile: "..msg
        end
    end
    _G["ETHER_DATABASE"]["PROFILES"][name]=nil
    return true,"Profile "..name.."  deleted"
end
function D:GetProfile()
    return _G["ETHER_DATABASE"]["PROFILES"][D:GetProfileName()]
end
function D:ResetProfile()
    local name=D:GetProfileName()
    _G["ETHER_DATABASE"]["PROFILES"][name]=D:CopyTable(D.Default)
    D.DB=D:CopyTable(D.Default)
    _G["ETHER_DATABASE"]["CURRENT"]=name
    ProfileRefresh()
    return true,"Profile "..name.." reset to default"
end
function D:CreateProfile(name)
    if _G["ETHER_DATABASE"]["PROFILES"][name] then
        return false,"Profile "..name.." already exists"
    end
    _G["ETHER_DATABASE"]["PROFILES"][name]=D:CopyTable(D.Default)
    _G["ETHER_DATABASE"]["CURRENT"]="DEFAULT"
    ProfileRefresh()
    return true,"Profile "..name.." created"
end
function D:RenameProfile(oldName,newName)
    if not _G["ETHER_DATABASE"]["PROFILES"][oldName] then
        return false,"Profile not found"
    end
    if _G["ETHER_DATABASE"]["PROFILES"][newName] then
        return false,"Name already taken"
    end
    _G["ETHER_DATABASE"]["PROFILES"][newName]=oldName
    _G["ETHER_DATABASE"]["CURRENT"]=newName
    _G["ETHER_DATABASE"]["PROFILES"][oldName]=nil
    return true,"Profile "..oldName.." renamed to "..newName
end
function D:GetProfileName()
    local name=_G["ETHER_DATABASE"]["CURRENT"]
    if not name or name=="" then return "DEFAULT" end
    return name
end

function D:GetProfileList(data)
    for name in pairs(_G["ETHER_DATABASE"]["PROFILES"]) do
        data[#data+1]=name
    end
    return data
end
