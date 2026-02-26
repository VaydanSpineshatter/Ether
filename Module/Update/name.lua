local _,Ether=...
local UnitName=UnitName
local string_byte=string.byte

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

function Ether:UTF8SUB(name,start,numChars)
    if not name then return end
    start = start or 1
    numChars = numChars or 0
    if start < 1 then start = 1 end
    if numChars <= 0 then return "" end

    local byteIndex=start
    local charCount=0
    while charCount<numChars and byteIndex<=#name do
        local char=string_byte(name,byteIndex)
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

function Ether:UpdateName(button)
    if not button or not button.unit or not button.name then
        return
    end
    local name=UnitName(button.unit)
    if name then
       button.name:SetText(Ether:UTF8SUB(name,1,3))
    end
end