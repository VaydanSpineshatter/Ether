local _,F,_,C=unpack(select(2,...))
local cb,tinsert,twipe,type={},table.insert,table.wipe,type
function F:RegisterCallback(func)
    if not func then return end
    tinsert(cb,func)
end
function F:ClearCallbacks()
    twipe(cb)
end
function F:Fire(index,...)
    if not index or type(index)~="number" then return end
    if cb[index] then
        cb[index](...)
    end
end
local Status,Updater=false,nil
local function reset()
    if Updater and Status then
        Updater:Cancel()
        if Updater:IsCancelled() then
            Updater=nil
        else
            C:EtherInfo("Updater is not cancelled. Reload UI")
        end
    end
end
function F:TimerCallBack(func,after,callback,ticker)
    if not callback or type(callback)~="function" then return end
    if not Status then
        Status=true
        if not Updater then
            Updater=func(after or 2,function()
                if callback then
                    callback()
                end
                reset()
            end,ticker or 0)
        end
    end
end
function F:BinaryCondition(val)
    return val==1
end
function F:ToggleBinary(val)
    return 1-(val or 0)
end
