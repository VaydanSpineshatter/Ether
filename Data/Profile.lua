local D,F,_,C=unpack(select(2,...))
local tsort,tconcat,tostring,loadstring=table.sort,table.concat,tostring,loadstring
local srep,schar,type,sformat,pairs,ipairs=string.rep,string.char,type,string.format,pairs,ipairs
local CompressString,DecompressString,mfloor=C_EncodingUtil.CompressString,C_EncodingUtil.DecompressString,math.floor
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
local P_,_B='=','ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function Base64Encode(data)
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
local function Base64Decode(data)
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
        local byte1=(values[1]*4)+mfloor(values[2]/16)
        res[#res+1]=schar(byte1)
        if values[3]~=0 or chunk:sub(3,3)~='=' then
            local byte2=((values[2]%16)*16)+mfloor(values[3]/4)
            res[#res+1]=schar(byte2)
        end
        if values[4]~=0 or chunk:sub(4,4)~='=' then
            local byte3=((values[3]%4)*64)+values[4]
            res[#res+1]=schar(byte3)
        end
    end
    return tconcat(res)
end
local Tbl
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
    local function Value(value,indent)
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
            local valueStr=Value(value,indent+2)
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
local function TblToString(tbl)
    return "return "..Tbl(tbl)
end
local btnTbl={"GROUP","CLASS","ASSIGNEDROLE","LEFT, TOP","TOP, LEFT"}
local function ProfileRefresh()
    F:UpdateAuraList()
    F:UpdateEditor(C.EditorFrame)
    F:IndicatorsDisable()
    for index=1,11 do
        F:SavePosition(index)
    end
    F:MenuStringsAlpha(0)
    D:RefreshAllSettings()
    D:RefreshAllFrames()
    F:Fire(1)
    if C.ChildFrames[6] and C.ChildFrames[6].roleDropdown and C.ChildFrames[6].roleDropdown.text then
        C.ChildFrames[6].roleDropdown.text:SetText(D.DB["CONFIG"][13])
    end
    if C.ChildFrames[6] and C.ChildFrames[6].roleDropdown and C.ChildFrames[6].roleDropdown.text then
        C.ChildFrames[6].roleDropdown.text:SetText(D.DB["CONFIG"][13])
    end
    F:IndicatorsEnable()
    F:RefreshChildText("sort",7,btnTbl[D.DB["CONFIG"][11]])
    F:RefreshChildText("direction",7,btnTbl[D.DB["CONFIG"][12]])
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
    D:MergeToLeft(import.data,D.Default)
    _G["ETHER_DATABASE"]["PROFILES"][name]=D:CopyTable(import.data)
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
    C.MainFrame:Hide()
    _G["ETHER_DATABASE"]["PROFILES"][D:GetProfileName()]=D:CopyTable(D.DB)
    D.DB=D:CopyTable(_G["ETHER_DATABASE"]["PROFILES"][name])
    if C.PopupBox and C.PopupBox.font then
        C.PopupBox.font:SetText(name)
    end
    ProfileRefresh()
    C.MainFrame:Show()
    C.ChildFrames[8]:Show()
    _G["ETHER_DATABASE"]["CURRENT"]=name
    return true,"Switched to "..name
end
local data={}
function D:DeleteProfile(name)
    if not _G["ETHER_DATABASE"]["PROFILES"][name] then
        return false,"Profile not found"
    end
    if D:TableSize(_G["ETHER_DATABASE"]["PROFILES"])<=1 then
        return false,"Cannot delete the last profile"
    end
    local success,msg=D:SwitchProfile("DEFAULT")
    if not success then
        return false,"Failed to switch profile: "..msg
    else
        _G["ETHER_DATABASE"]["PROFILES"][name]=nil
        table.wipe(data)
        for n in pairs(_G["ETHER_DATABASE"]["PROFILES"]) do
            data[#data+1]=n
        end
        C.ProfileDropdown:SetOptions(data)
        C.ProfileDropdown.text:SetText(D:GetProfileName())
        return true,"Profile "..name.."  deleted"
    end
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
    D:SwitchProfile(name)
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
function D:GetProfileList()
    table.wipe(data)
    for n in pairs(_G["ETHER_DATABASE"]["PROFILES"]) do
        data[#data+1]=n
    end
    return data
end