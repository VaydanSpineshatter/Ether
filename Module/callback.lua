local _,F,_,C=unpack(select(2,...))
local data,type={},type
function F:RegisterCallback(func)
    if type(func)~="function" then return end
    table.insert(data,func)
end
function F:RegisterCallbackByIndex(func,index)
    if type(func)~="function" then return end
    table.insert(data,index,func)
end
function F:ModifyIndexCallback(old,new)
    if type(old)~="number" or type(new)~="number" or old==new then return end
    for i,v in pairs(data) do
        if i==old then
            if type(v)=="function" then
                table.insert(data,new,v)
                data[old]=nil
            end
            break
        else
            C:EtherInfo("select("..old..") == nil")
        end
    end
end
function F:UnregisterCallback(index)
    if type(index)~="number" then return end
    for i in pairs(data) do
        if i==index then
            table.remove(data,i)
            break
        end
    end
end
function F:WipeCallbacks()
    table.wipe(data)
end
function F:Fire(index,...)
    if type(index)~="number" then return end
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