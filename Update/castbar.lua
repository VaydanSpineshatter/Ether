local D,F,S=unpack(select(2,...))
local UnitCastingInfo,UnitChannelInfo,GetNetStats=UnitCastingInfo,UnitChannelInfo,GetNetStats
local timeStr,tStr,GetTime="%.1f|cffff0000-%.1f|r","%.1f",GetTime
local castBar,event=D.castBar,S.EventFrame
local function GetCastBar(unit)
    return castBar[D:PosUnit(unit)]
end
local function updateSafeZone(self)
    local safeZone=self.safeZone
    local width=self:GetWidth()
    local _,_,_,ms=GetNetStats()
    local safeZoneRatio=(ms/1e3)/self.max
    if (safeZoneRatio>1) then
        safeZoneRatio=1
    end
    safeZone:SetWidth(width*safeZoneRatio)
end
local function OnUpdate(self,elapsed)
    if (self.casting) then
        local duration=self.duration+elapsed
        if (duration>=self.max) then
            self.casting=nil
            self.holdTime=0.5
            return
        end
        if (self.time) then
            if (self.delay~=0) then
                self.time:SetFormattedText(timeStr,duration,self.delay)
            else
                self.time:SetFormattedText(tStr,duration)
            end
        end
        self.duration=duration
        self:SetValue(duration)
    elseif (self.channeling) then
        local duration=self.duration-elapsed
        if (duration<=0) then
            self.channeling=nil
            self.holdTime=0.5
            return
        end
        if (self.time) then
            if (self.delay~=0) then
                self.time:SetFormattedText(timeStr,duration,self.delay)
            else
                self.time:SetFormattedText(tStr,duration)
            end
        end
        self.duration=duration
        self:SetValue(duration)
    elseif (self.holdTime and self.holdTime>0) then
        self.holdTime=self.holdTime-elapsed
        if (self.holdTime<=0) then
            self.holdTime=nil
            self:Hide()
        end
    else
        self:Hide()
    end
end
function event:UNIT_SPELLCAST_START(unitTarget,castGUID,spellID)
    local bar=GetCastBar(unitTarget)
    if not bar then return end
    local name,text,texture,startTimeMS,endTimeMS,_,_,notInterruptible=UnitCastingInfo(unitTarget)
    if not name then return end
    endTimeMS=endTimeMS/1e3
    startTimeMS=startTimeMS/1e3
    local max=endTimeMS-startTimeMS
    bar.castID=castGUID
    bar.duration=GetTime()-startTimeMS
    bar.max=max
    bar.casting=true
    bar.delay=0
    bar.notInterruptible=notInterruptible
    bar.holdTime=0
    bar.spellID=spellID
    bar:SetMinMaxValues(0,max)
    bar:SetValue(0)
    bar:SetStatusBarColor(0.2,0.6,1.0,0.8)
    if bar.icon then
        bar.icon:SetTexture(texture or "Interface\\Icons\\INV_Misc_QuestionMark")
    end
    if bar.text then
        bar.spellName=name
        bar.text:SetText(text)
    end
    if notInterruptible then
        bar.shield:Show()
        bar:SetStatusBarColor(0.7,0.7,0.7,0.8)
    else
        bar.shield:Hide()
    end
    if bar.safeZone then
        bar.safeZone:ClearAllPoints()
        bar.safeZone:SetPoint(bar:GetReverseFill() and "LEFT" or "RIGHT")
        bar.safeZone:SetPoint("TOP")
        bar.safeZone:SetPoint("BOTTOM")
        updateSafeZone(bar)
    end
    bar:Show()
end

function event:UNIT_SPELLCAST_STOP(unitTarget)
    local bar=GetCastBar(unitTarget)
    if not bar or not (bar.casting or bar.channeling) then return end
    bar.casting=nil
    bar.channeling=nil
    bar.holdTime=0.5
    bar:SetStatusBarColor(0,1,0,0.8)
end

function event:UNIT_SPELLCAST_FAILED(unitTarget,castGUID)
    local bar=GetCastBar(unitTarget)
    if not bar then return end
    if bar.castID~=castGUID then return end
    bar:SetStatusBarColor(0.50,0.00,0.50,0.8)
    if bar.text then
        bar.text:SetText("Cast - "..(bar.spellName or "Interrupted"))
    end
    bar.casting=nil
    bar.channeling=nil
    bar.holdTime=bar.timeToHold or 0.1
end

function event:UNIT_SPELLCAST_INTERRUPTED(unitTarget,castGUID)
    local bar=GetCastBar(unitTarget)
    if not bar then return end
    if bar.castID~=castGUID then return end
    bar.casting=nil
    bar.notInterruptible=nil
    bar:Hide()
end
function event:UNIT_SPELLCAST_DELAYED(unitTarget)
    local bar=GetCastBar(unitTarget)
    if not bar then return end
    local _,_,_,startTime=UnitCastingInfo(unitTarget)
    if not startTime or not bar:IsShown() then return end
    local duration=GetTime()-(startTime/1000)
    if duration<0 then duration=0 end
    bar.delay=bar.delay+bar.duration-duration
    bar.duration=duration
    bar:SetValue(duration)
end
function event:UNIT_SPELLCAST_CHANNEL_START(unitTarget,_,spellID)
    local bar=GetCastBar(unitTarget)
    if not bar then return end
    local name,text,textureID,startTimeMS,endTimeMS,_,notInterruptible=UnitChannelInfo(unitTarget)
    if not name then return end
    endTimeMS=endTimeMS/1e3
    startTimeMS=startTimeMS/1e3
    local max=endTimeMS-startTimeMS
    local duration=endTimeMS-GetTime()
    bar.duration=duration
    bar.max=max
    bar.delay=0
    bar.channeling=true
    bar.notInterruptible=notInterruptible
    bar.holdTime=0
    bar.spellID=spellID
    bar.casting=nil
    bar.castID=nil
    bar:SetMinMaxValues(0,max)
    bar:SetValue(duration)
    bar:SetStatusBarColor(0.18,0.54,0.34,0.8)
    if bar.icon then
        bar.icon:SetTexture(textureID or "Interface\\Icons\\INV_Misc_QuestionMark")
    end
    if bar.text then
        bar.text:SetText(text)
    end
    if notInterruptible then
        bar.shield:Show()
        bar:SetStatusBarColor(0.7,0.7,0.7,0.8)
    else
        bar.shield:Hide()
    end
    if bar.safeZone then
        bar.safeZone:ClearAllPoints()
        bar.safeZone:SetPoint(bar:GetReverseFill() and "LEFT" or "RIGHT")
        bar.safeZone:SetPoint("TOP")
        bar.safeZone:SetPoint("BOTTOM")
        updateSafeZone(bar)
    end
    bar:Show()
end
function event:UNIT_SPELLCAST_CHANNEL_UPDATE(unitTarget)
    local bar=GetCastBar(unitTarget)
    if not bar then return end
    local name,_,_,startTimeMS,endTimeMS=UnitChannelInfo(unitTarget)
    if not name then return end
    local duration=(endTimeMS/1000)-GetTime()
    bar.delay=bar.delay+bar.duration-duration
    bar.duration=duration
    bar.max=(endTimeMS-startTimeMS)/1000
    bar:SetMinMaxValues(0,bar.max)
    bar:SetValue(duration)
end
function event:UNIT_SPELLCAST_CHANNEL_STOP(unitTarget,castGUID)
    local bar=GetCastBar(unitTarget)
    if not bar or bar.castBar~=castGUID then return end
    if bar:IsShown() then
        bar.channeling=nil
        bar.notInterruptible=nil
        bar:Hide()
    end
end
function event:UNIT_SPELLCAST_FAILED_QUIET(unitTarget,castGUID)
    local bar=GetCastBar(unitTarget)
    if not bar or bar.castID~=castGUID then return end
    bar.casting=nil
    bar.channeling=nil
    bar.holdTime=nil
    bar:Hide()
end
function event:UNIT_SPELLCAST_NOT_INTERRUPTIBLE(unitTarget)
    local bar=GetCastBar(unitTarget)
    if bar then
        bar.shield:Show()
        bar:SetStatusBarColor(0.7,0.7,0.7,0.8)
    end
end
function event:UNIT_SPELLCAST_INTERRUPTIBLE(unitTarget)
    local bar=GetCastBar(unitTarget)
    if bar then
        bar.shield:Hide()
        bar:SetStatusBarColor(0.2,0.6,1.0,0.8)
    end
end
local count=0
local function RegisterUpdate(button)
    if not button:GetScript("OnUpdate") then
        button:SetScript("OnUpdate",OnUpdate)
        count=count+1
    end
end
local function UnregisterUpdate(button)
    if button:GetScript("OnUpdate") then
        button:SetScript("OnUpdate",nil)
        count=count-1
    end
end
local function UpdateInfo()
    return count>0
end
function F:CastEnable(index)
    if not index or index>2 then return end
    for _,v in ipairs(D.castEvent) do
        event:RegisterUnitEvent(v,"player","target")
    end
    F:SetupDrag(castBar[index])
    D:ApplyFramePosition(castBar[index])
    RegisterUpdate(castBar[index])
end
function F:CastDisable(index)
    if not index or index>2 then return end
    UnregisterUpdate(castBar[index])
    castBar[index]:Hide()
    castBar[index]:SetScript("OnDragStart",nil)
    castBar[index]:SetScript("OnDragStop",nil)
    if not UpdateInfo() then
        for _,v in ipairs(D.castEvent) do
            event:UnregisterEvent(v)
        end
    end
end
function F:HideCastBar(index,status)
    if status and UpdateInfo() then
        UnregisterUpdate(castBar[index])
        castBar[index].text:SetText("Move CastBar")
        castBar[index]:SetShown(status)
    else
        RegisterUpdate(castBar[index])
    end
end
function F:CastBarReset(number)
    F:CastBarDisable(number)
    C_Timer.After(1.2,function()
        D:ApplyFramePosition(castBar[number])
        F:CastBarEnable(number)
    end)
end