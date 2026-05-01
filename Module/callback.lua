local _,F=unpack(select(2,...))
local data,type={},type
function F:RegisterCallback(func)
    if not func then return end
    table.insert(data,func)
end
function F:WipeCallbacks()
    table.wipe(data)
end
function F:UnregisterCallback(index)
    if not index or type(index)~="number" then return end
    for i in ipairs(data) do
        if i==index then
            table.remove(data,i)
            break
        end
    end
end
function F:Fire(index,...)
    if not index or type(index)~="number" then return end
    if data[index] then
        data[index](...)
    end
end
function F:BinaryCondition(val)
    return val==1
end
function F:ToggleBinary(val)
    return 1-(val or 0)
end