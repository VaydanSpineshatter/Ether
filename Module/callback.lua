local _,F,_,C,_=unpack(select(2,...))
local tinsert,tremove,twipe=table.insert,table.remove,table.wipe
local type=type
local cb={}
function F:RegisterCallback(func)
    if not func then return end
    tinsert(cb,func)
end
function F:ClearCallbacks()
    twipe(cb)
end
function F:Fire(index,...)
    if not index then return end
    for i=1,#cb do
        cb[i](...)
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