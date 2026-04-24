local D,F,S=unpack(select(2,...))
local UnitIsUnit,UnitFullName=UnitIsUnit,UnitFullName
local sbyte,ME=string.byte,[[|cffffd700ME|r]]
local event,raidBtn,petBtn,soloBtn=S.EventFrame,D.raidBtn,D.petBtn,D.soloBtn
local function GetSoloBtn(unit)
    return soloBtn[D:PosUnit(unit)]
end
local function GetRaidBtn(unit)
    local b=raidBtn[unit]
    if b and b.unit==unit then
        return b
    end
end
local function GetPetBtn(unit)
    local b=petBtn[unit]
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
    local byteIndex=start
    local charCount=0
    while charCount<numChars and byteIndex<=#name do
        local char=sbyte(name,byteIndex)
        if char>=240 then
            byteIndex=byteIndex+4
        elseif char>=224 then
            byteIndex=byteIndex+3
        elseif char>=192 then
            byteIndex=byteIndex+2
        else
            byteIndex=byteIndex+1
        end
        charCount=charCount+1
    end
    local endIndex=byteIndex-1
    return name:sub(start,endIndex)
end
function F:UpdateName(button,number)
    if not button or not button.name then
        return
    end
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
    local p=GetPetBtn(unit)
    if p then
        F:UpdateName(p,3)
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