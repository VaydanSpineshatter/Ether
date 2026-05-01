local D,F,S=unpack(select(2,...))
local sbyte,ME,UnitIsUnit,UnitFullName=string.byte,[[|cffffd700ME|r]],UnitIsUnit,UnitFullName
local event,raidBtn,soloBtn=S.EventFrame,D.raidBtn,D.soloBtn
local function GetSoloBtn(unit)
    return soloBtn[D:PosUnit(unit)]
end
local function GetRaidBtn(unit)
    local b=raidBtn[unit]
    if b and b.unit==unit then
        return b
    end
end
function F:ShortenName(name,maxLength)
    if not name then return end
    if (#name>maxLength) then
        return name:sub(1,maxLength)
    else
        return name
    end
end
local function UTF8SUB(name,start,numChars)
    if not name then return end
    start=start or 1
    numChars=numChars or 0
    if start<1 then
        start=1
    end
    if numChars<=0 then
        return ""
    end
    local index=start
    local count=0
    while count<numChars and index<=#name do
        local char=sbyte(name,index)
        if char>=240 then
            index=index+4
        elseif char>=224 then
            index=index+3
        elseif char>=192 then
            index=index+2
        else
            index=index+1
        end
        count=count+1
    end
    local last=index-1
    return name:sub(start,last)
end
function F:UpdateName(button,number)
    if not button or not button.name then return end
    local unit=button.unit or "player"
    local name=UnitFullName(unit) or "UNKNOWN"
    local user=UnitIsUnit(unit,"player") and ME or UTF8SUB(name,1,number or 10)
    button.name:SetText(user)
end
function F:UpdateNameByTarget(button)
    if not button or not button.name then return end
    local unit="targettarget" or "target"
    local name=UnitFullName(unit) or "UNKNOWN"
    local user=UnitIsUnit(unit,"player") and ME or UTF8SUB(name,1,6)
    button.name:SetText(user)
end
function event:UNIT_NAME_UPDATE(unit)
    local s=GetSoloBtn(unit)
    if s then
        F:UpdateName(s,6)
    end
    local b=GetRaidBtn(unit)
    if b then
        F:UpdateName(b,3)
    end
end
function F:NameEnable()
    if not event:IsEventRegistered("UNIT_NAME_UPDATE") then
        event:RegisterEvent("UNIT_NAME_UPDATE")
    end
end
function F:NameDisable()
    if event:IsEventRegistered("UNIT_NAME_UPDATE") then
        event:UnregisterEvent("UNIT_NAME_UPDATE")
    end
end