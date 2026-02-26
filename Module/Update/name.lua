local _,Ether=...
local UnitName=UnitName
local string_byte=string.byte
local UnitIsUnit=UnitIsUnit
local ME="|cffffd700ME|r"

function Ether:ShortenName(name,maxLength)
    if not name then
        return
    end
    if (#name>maxLength) then
        return name:sub(1,maxLength)
    else
        return name
    end
end

local function utf8sub(name,start,numChars)
    local byteIndex=start
    local charCount=0
    while charCount<numChars and byteIndex<=#name do
        local char=string_byte(name,byteIndex)
        if char>=240 then
            byteIndex=byteIndex+4
        elseif char>=225 then
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

function Ether:UpdateName(button,IsRaid)
    if not button or not button.unit or not button.name then
        return
    end
    local unit=button.unit
    local name=UnitName(unit)
    if name then
        if IsRaid then
            button.name:SetText(utf8sub(name,1,3))
        else
            button.name:SetText(utf8sub(name,1,10))
        end
    end
end
