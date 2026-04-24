local _,F,_,S=unpack(select(2,...))
local data,status,flash={},true,true
local updater,timer
updater,timer=nil,nil
local pairs,wipe,next=pairs,wipe,next
local C_Timer,C_Ticker=C_Timer.After,C_Timer.NewTicker
local function Blink()
    status=not status
    for tex in pairs(data) do
        if status then
            tex:Show()
        else
            tex:Hide()
        end
    end
end
function F:StartBlink(tex,duration,interval)
    if type(tex)=="nil" then
        print("The element does not exist")
        return
    end
    interval=interval or 0.5
    F:StopBlink(tex)
    data[tex]=true
    if status then
        tex:SetShown(true)
    end
    if not updater then
        updater=C_Ticker(interval,Blink)
    end
    C_Timer(duration or 4,function()
        F:StopBlink(tex)
    end)
end

function F:StopBlink(tex)
    if data[tex] then
        data[tex]=nil
        tex:Hide()
        if not next(data) and updater then
            updater:Cancel()
            if updater:IsCancelled() then
                updater=nil
                assert(updater==nil)
            end
        end
    end
end

function F:StopAllBlinks()
    for tex in pairs(data) do
        tex:Hide()
    end
    wipe(data)
    if updater then
        updater:Cancel()
        updater=nil
    end
end
local function ToggleFlash()
    flash=not flash
    if flash then
        S.FlashLeft:Show()
        S.FlashRight:Show()
    else
        S.FlashLeft:Hide()
        S.FlashRight:Hide()
    end
end
local function StopFlash()
    S.FlashLeft:Hide()
    S.FlashRight:Hide()
    if timer then
        timer:Cancel()
       timer=nil
    end
end
function F:StartFlash()
    if not S.FlashLeft or not S.FlashRight then return end
    StopFlash()
    flash=true
    if not timer then
        timer=C_Ticker(0.5,ToggleFlash)
    end
    C_Timer(4,function()
        StopFlash()
    end)
end