local _,Ether=...
local tinsert,tremove=table.insert,table.remove
local pairs,ipairs=pairs,ipairs
local string_format=string.format
local UnitGUID=UnitGUID
local UnitExists=UnitExists
local GUIDIsPlayer=C_PlayerInfo.GUIDIsPlayer
local UnitFullName,GetRealmName=UnitFullName,GetRealmName

local function Human(unit)
    if not unit or not UnitExists(unit) then return end
    local GUID=UnitGUID(unit)
    if not GUID then return end
    local human=GUIDIsPlayer(GUID)
    if human then
        return true
    end
    return false
end

local function Scanner(unit)
    local USER=Ether.DB["USER"]
    local name,realm,found=UnitFullName(unit),GetRealmName(),false
    if not name then return end
    local fullName=name.."-"..realm
    for i,entry in ipairs(USER) do
        if i and entry and entry==fullName then
            found=true
            break
        end
    end
    if found then
        return fullName
    end
    return false
end

function Ether:IgnoreByUnit(unit)
    if not Human(unit) then return end
    local name=Scanner(unit)
    if not name then return end
    Ether:EtherInfo(string_format("Found %s",name))
    Ether.StartFlash()
end

function Ether:IgnoreScanByTarget(result)
    if result and result:IsShown() then
        result:Hide()
    end
    if not Human("target") then return end
    local name,realm,found,number=UnitFullName("target"),GetRealmName(),false
    if not name then return end
    local info=name.."-"..realm
    for i,v in ipairs(Ether.DB["USER"]) do
        if i and v==info then
            found,number=true,i
            break
        end
    end
    if found then
        tremove(Ether.DB["USER"],number)
        Ether:EtherInfo(string_format("%s",info))
    else
        tinsert(Ether.DB["USER"],info)
    end
end

function Ether:IgnoreRemoveByIndex(index, result)
    if not index or type(index)~="number" then return end
    if result and result:IsShown() then
        result:Hide()
    end
    local found,name,number=false
    for i,v in ipairs(Ether.DB["USER"]) do
        if i and i==index then
            found,number,name=true,i,v
            break
        end
    end
    if found then
        Ether:EtherInfo(string_format("%s %s has been removed",number,name))
        tremove(Ether.DB["USER"],number)
    else
        tinsert(Ether.DB["USER"],name)
    end
end

function Ether:IgnoreScanInput(result)
    if result and result:IsShown() then
        result:Hide()
    end
    for i,v in ipairs(Ether.DB["USER"]) do
        Ether:EtherInfo(string_format("%s %s",i,v))
    end
end

function Ether:IgnoreScanData(name,result)
    if not name or type(name)~="string" then return end
    name=name:trim()
    if result:IsShown() then
        result:Hide()
    end
    if name=="" then
        result:SetText("Enter Name\nExample: 'Unknown-Unknown'")
        result:SetTextColor(1,0,0)
        result:Show()
        return
    elseif Ether.DB["USER"][name] then
        result:SetText("Name already ignored")
        result:SetTextColor(1,0,0)
        result:Show()
        return
    else
        for index,entry in ipairs(Ether.DB["USER"]) do
            if index and entry==name then
                tremove(Ether.DB["USER"],index)
                Ether:EtherInfo(string_format("%s",entry))
                break
            end
        end
        tinsert(Ether.DB["USER"],name)
    end
end

function Ether:GroupScanner()
    if Ether.DB[7][2]~=1 then return end
    if not IsInRaid() then return end
    local raidButtons,index = Ether.raidButtons,0
    for _,button in pairs(raidButtons) do
        index = index + 1
        if not button then return end
        if not Human(button.unit) then return end
        local name=Scanner(button.unit)
        if not name then return end
        local _, _, subgroup = GetRaidRosterInfo(index)
        Ether:EtherInfo(string_format("Found in Group: %s - %s",subgroup or "Unknown", name))
        Ether.StartFlash()
    end
end