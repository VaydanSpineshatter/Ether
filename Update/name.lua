local D,F,S=unpack(select(2,...))
local sbyte,ME,UnitIsUnit,UnitName=string.byte,[[|cffffd700ME|r]],UnitIsUnit,UnitName
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
function F:UpdateName(b,number)
    if not b or not b.unit or not b.name then return end
    local unit=b.unit
    local name=UnitName(unit) or "UNKNOWN"
    local user=UnitIsUnit(unit,"player") and ME or UTF8SUB(name,1,number or 10)
    b.name:SetText(user)
end
function F:UpdateNameByTarget(b)
    if not b or not b.unit or not b.name then return end
    local name=UnitName(b.unit) or "UNKNOWN"
    local user=UnitIsUnit(b.unit,"player") and ME or UTF8SUB(name,1,6)
    b.name:SetText(user)
end
function event:UNIT_NAME_UPDATE(unit)
    if not UnitExists(unit) then return end
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
    F:FuncEnable("UNIT_NAME_UPDATE")
end
function F:NameDisable()
    F:FuncDisable("UNIT_NAME_UPDATE")
end
F:RegisterCallbackByIndex(F.NameEnable,10)
F:RegisterCallbackByIndex(F.NameDisable,10+30)