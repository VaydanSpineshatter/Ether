local D,F,_,C,L=unpack(select(2,...))
local type,sformat,pairs,ipairs=type,string.format,pairs,ipairs
local CompressString,DecompressString=C_EncodingUtil.CompressString,C_EncodingUtil.DecompressString
local function ProfileRefresh()
    if C.ProfileRefresh then return end
    C.MainFrame:Hide()
    for _,v in ipairs(C.ChildFrames) do
        v:Hide()
    end
    F:Fire(22)
    for index=1,11 do
        F:SaveIndicatorPosition(index)
    end
    F:UpdateAuraList()
    F.UpdateEditor(C.ChildFrames[7])
    D:RefreshAllSettings()
    D:RefreshAllFrames()
    if C.ChildFrames[6] and C.ChildFrames[6].roleDropdown and C.ChildFrames[6].roleDropdown.v then
        C.ChildFrames[6].roleDropdown.v:SetText(D.DB["CONFIG"][13] or "DAMAGER")
    end
    if C.ChildFrames[5] and C.ChildFrames[5].direction then
        C.ChildFrames[5].direction:SetText(L.DIRECTION_BY_H..D.header5[D.DB["CONFIG"][12]])
    end
    if C.ChildFrames[5] and C.ChildFrames[5].sort then
        C.ChildFrames[5].sort:SetText(L.SORT_BY_H..D.header5[D.DB["CONFIG"][11]])
    end
    if C.ChildFrames[6] and C.ChildFrames[6].repair then
        F.UpdateStatus(C.ChildFrames[6].repair,17)
    end
    if C.ChildFrames[6] and C.ChildFrames[6].guild then
        F.UpdateStatus(C.ChildFrames[6].guild,18)
    end
    F.UpdateIcon(C.Indi)
    if C.RemoveDropdown then
        C.RemoveDropdown:SetOptions(D.DB["USER"])
    end
    D.menuStrings[8]:SetText(sformat("%s %s","Profile ",D:GetProfileName()))
    C.MainFrame:Show()
end
D.ProfileRefresh=ProfileRefresh
function D:ExportAddonMsg()
    local compressed=CompressString(C.EtherVersion,1)
    local encoded=C:Base64Encode(compressed)
    return encoded
end
function D:ImportAddonMsg(msg)
    if not msg then return end
    local decoded=C:Base64Decode(msg)
    local import=DecompressString(decoded,1)
    return import
end
function D:ExportProfile()
    local userData=D:GetProfile()
    if not userData then
        return nil,"Current profile not found"
    end
    local exportData={
        name=D:GetProfileName(),
        data=userData
    }
    local export=C:Serialize(exportData)
    local compressed=CompressString(export,1)
    local encoded=C:Base64Encode(compressed)
    C:EtherInfo("|cff00ff00Export ready:|r "..D:GetProfileName())
    C:EtherInfo("|cff888888Size (compressed):|r "..#encoded.." characters")
    return encoded
end
function D:ImportProfile(encodedString)
    if not encodedString or encodedString=="" then
        return false,"Empty import string"
    end
    local decoded=C:Base64Decode(encodedString)
    if not decoded then
        return false,"Invalid Base64 encoding"
    end
    local decompressed=DecompressString(decoded,1)
    if not decompressed then
        return false,"Decompression failed (possibly corrupt data)"
    end
    local success,import=C:Deserialize(decompressed)
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
function D:CopyProfile(sourceName)
    if not sourceName then return end
    local roll=math.random(1,1000)
    local targetName=sformat("Copy_%s_%s",roll,sourceName)
    if not _G["ETHER_DATABASE"]["PROFILES"][sourceName] then
        return false,"Profile "..sourceName.." not found"
    end
    if _G["ETHER_DATABASE"]["PROFILES"][targetName] then
        return false,"Profile "..sourceName.." already exists"
    end
    _G["ETHER_DATABASE"]["PROFILES"][targetName]=D:CopyTable(_G["ETHER_DATABASE"]["PROFILES"][sourceName])
    return true,"Profile "..sourceName.." has been copied"
end
function D:SwitchProfile(name)
    if not _G["ETHER_DATABASE"]["PROFILES"][name] then
        return false,"Profile "..name.." not found"
    end
    _G["ETHER_DATABASE"]["PROFILES"][D:GetProfileName()]=D:CopyTable(D.DB)
    D.DB=D:CopyTable(_G["ETHER_DATABASE"]["PROFILES"][name])
    if C.PopupBox and C.PopupBox.font then
        C.PopupBox.font:SetText(name)
    end
    ProfileRefresh()
    _G["ETHER_DATABASE"]["CURRENT"]=name
    return true,"Switched to "..name
end
local function ProfileChange(name)
    _G["ETHER_DATABASE"]["PROFILES"][D:GetProfileName()]=D:CopyTable(D.DB)
    D.DB=D:CopyTable(_G["ETHER_DATABASE"]["PROFILES"][name])
    _G["ETHER_DATABASE"]["CURRENT"]=name
    return true,"Switched to "..name
end
function D:DeleteProfile(name)
    if name=="DEFAULT" then
        return false,"|cffcc66ffEther|r Cannot delete Default profile"
    end
    if not _G["ETHER_DATABASE"]["PROFILES"][name] then
        return false,"|cffcc66ffEther|r Profile not found"
    end
    if D:TableSize(_G["ETHER_DATABASE"]["PROFILES"])<=1 then
        return false,"|cffcc66ffEther|r Cannot delete the last profile"
    end
    local success,msg=ProfileChange("DEFAULT")
    if not success then
        return false,"Failed to switch profile: "..msg
    else
        local data={}
        _G["ETHER_DATABASE"]["PROFILES"][name]=nil
        for n in pairs(_G["ETHER_DATABASE"]["PROFILES"]) do
            data[#data+1]=n
        end
        C.ProfileDropdown:SetOptions(data)
        C.ProfileDropdown.v:SetText(D:GetProfileName())
        return true,"Profile "..name.."  deleted"
    end
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
    if not name then return end
    local input=name:match("^(%S*)%s*(.-)$")
    input=string.lower(input)
    if input=="default" then
        return false,"You cannot use “default” as a name"
    end
    if _G["ETHER_DATABASE"]["PROFILES"][name] then
        return false,"Profile "..name.." already exists"
    end
    _G["ETHER_DATABASE"]["PROFILES"][name]=D:CopyTable(D.Default)
    D:SwitchProfile(name)
    return true,"Profile "..name.." created"
end
function D:RenameProfile(oldName,newName)
    if not oldName or not newName then return end
    if oldName=="DEFAULT" then
        return false,"You cannot change “default"
    end
    local input=newName:match("^(%S*)%s*(.-)$")
    input=string.lower(input)
    if input=="default" then
        return false,"You cannot use “default” as a name"
    end
    if not _G["ETHER_DATABASE"]["PROFILES"][oldName] then
        return false,"Profile not found"
    end
    if _G["ETHER_DATABASE"]["PROFILES"][newName] then
        return false,"Name already taken"
    end
    _G["ETHER_DATABASE"]["PROFILES"][newName]=oldName
    _G["ETHER_DATABASE"]["CURRENT"]=newName
    _G["ETHER_DATABASE"]["PROFILES"][oldName]=nil
    D.menuStrings[8]:SetText(string.format("%s %s","Profile ",newName))
    return true,"Profile "..oldName.." renamed to "..newName
end
function D:GetProfileName()
    local name=_G["ETHER_DATABASE"]["CURRENT"]
    if not name or name=="" then return "DEFAULT" end
    return name
end
function D:GetProfileList()
    local data={}
    for n in pairs(_G["ETHER_DATABASE"]["PROFILES"]) do
        data[#data+1]=n
    end
    return data
end
function D:GetProfile()
    return _G["ETHER_DATABASE"]["PROFILES"][D:GetProfileName()]
end
function D:CurrentProfile(name)
    if not name then return end
    _G["ETHER_DATABASE"]["CURRENT"]=name
end