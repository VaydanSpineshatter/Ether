local _,Ether=...
local Blinks={}
local BlinkState,FlashState=true,true
local BlinkTimer,FlashTimer
local pairs,wipe,next=pairs,wipe,next
local C_Timer,C_Ticker=C_Timer.After,C_Timer.NewTicker
local function ToggleAllBlinks()
    BlinkState=not BlinkState
    for tex in pairs(Blinks) do
        if BlinkState then
            tex:Show()
        else
            tex:Hide()
        end
    end
end

Ether.StartBlink=function(tex,duration,interval)
    if type(tex)=="nil" then
        error("The element does not exist")
        return
    end
    interval=interval or 0.5
    Ether.StopBlink(tex)
    Blinks[tex]=true
    if BlinkState then
        tex:SetShown(true)
    end
    if not BlinkTimer then
        BlinkTimer=C_Ticker(interval,ToggleAllBlinks)
    end
    C_Timer(duration or 4,function()
        Ether.StopBlink(tex)
    end)
end

Ether.StopBlink=function(tex)
    if Blinks[tex] then
        Blinks[tex]=nil
        tex:Hide()
        if not next(Blinks) and BlinkTimer then
            BlinkTimer:Cancel()
            BlinkTimer=nil
        end
    end
end

Ether.StopAllBlinks=function()
    for tex in pairs(Blinks) do
        tex:Hide()
    end
    wipe(Blinks)
    if BlinkTimer then
        BlinkTimer:Cancel()
        BlinkTimer=nil
    end
end

local frame,left,right
if not frame then
    frame=CreateFrame("Frame",nil,UIParent)
    frame:SetAllPoints()
    left=frame:CreateTexture(nil,"BACKGROUND")
    left:SetPoint("TOPLEFT")
    left:SetPoint("BOTTOMLEFT")
    right=frame:CreateTexture(nil,"BACKGROUND")
    right:SetPoint("TOPRIGHT")
    right:SetPoint("BOTTOMRIGHT")
    left:SetColorTexture(1,0,0,.5)
    right:SetColorTexture(1,0,0,.5)
    left:Hide()
    right:Hide()
    left:SetWidth(80)
    right:SetWidth(80)
end

local function ToggleFlash()
    FlashState=not FlashState
    if FlashState then
        left:Show()
        right:Show()
    else
        left:Hide()
        right:Hide()
    end
end

Ether.StopFlash=function()
    if left and left:IsShown() then left:Hide() end
    if right and right:IsShown() then right:Hide() end
    if FlashTimer then
        FlashTimer:Cancel()
        FlashTimer=nil
    end
end

Ether.StartFlash=function(duration,interval)
    interval=interval or 0.5
    Ether.StopFlash()
    if FlashState then
        right:SetShown(true)
        left:SetShown(true)
    end
    if not FlashTimer then
        FlashTimer=C_Ticker(interval,ToggleFlash)
    end
    C_Timer(duration or 4,function()
        Ether.StopFlash()
    end)
end

