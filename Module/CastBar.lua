local _,Ether=...
local GetNetStats=GetNetStats
local GetTime=GetTime
local UnitCast=UnitCastingInfo
local UnitChannel=UnitChannelInfo
local timeStr="%.1f|cffff0000-%.1f|r"
local tStr="%.1f"

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
            self:Hide()
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
            self:Hide()
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
    else
        self.casting=nil
        self.channeling=nil
        self:Hide()
    end
end
local castBar=Ether.castBar
local RegisterEvent,UnregisterEvent,RegisterUpdate,UnregisterUpdate,UpdateInfo
do
    local Events,count,frame={},0
    function RegisterEvent(cast,func)
        frame=CreateFrame("Frame")
        frame:SetScript("OnEvent",function(self,event,unit,...)
            local bar=castBar[Ether:UnitNumber(unit)]
            if not bar then return end
            Events[event](bar,event,unit,...)
        end)
        if not Events[cast] and not frame:IsEventRegistered(cast) then
            frame:RegisterEvent(cast)
            Events[cast]=func
        end
    end

    function UnregisterEvent(event)
        if Events[event] and frame:IsEventRegistered(event) then
            frame:UnregisterEvent(event)
            Events[event]=nil
        end
    end
    function RegisterUpdate(index)
        if not castBar[index]:GetScript("OnUpdate") then
            castBar[index]:SetScript("OnUpdate",OnUpdate)
            count=count+1
        end
    end
    function UnregisterUpdate(index)
        if castBar[index]:GetScript("OnUpdate") then
            castBar[index]:SetScript("OnUpdate",nil)
            count=count-1
        end
    end
    function UpdateInfo()
        return count>0
    end
end

local function CastStart(self,event,unit)
    if self.unit~=unit then return end
    if event=="UNIT_SPELLCAST_START" then
        local name,text,texture,startTimeMS,endTimeMS,_,castID,notInterruptible,spellID=UnitCast(unit)
        if not name then return end
        endTimeMS=endTimeMS/1e3
        startTimeMS=startTimeMS/1e3
        local max=endTimeMS-startTimeMS
        self.castID=castID
        self.duration=GetTime()-startTimeMS
        self.max=max
        self.casting=true
        self.delay=0
        self.notInterruptible=notInterruptible
        self.holdTime=0
        self.spellID=spellID
        self:SetMinMaxValues(0,max)
        self:SetValue(0)
        self:SetStatusBarColor(0.2,0.6,1.0,0.8)
        if (self.icon) then
            self.icon:SetTexture(texture or "Interface\\Icons\\INV_Misc_QuestionMark")
        end
        if (self.text) then
            self.spellName=name
            self.text:SetText(text)
        end
        if (self.safeZone) then
            self.safeZone:ClearAllPoints()
            self.safeZone:SetPoint(self:GetReverseFill() and "LEFT" or "RIGHT")
            self.safeZone:SetPoint("TOP")
            self.safeZone:SetPoint("BOTTOM")
            updateSafeZone(self)
        end
        self:Show()
    end
end

local function CastFailed(self,event,unit,castID)
    if self.unit~=unit then return end
    if event=="UNIT_SPELLCAST_FAILED" then
        if self.castID~=castID then return end
        self:SetStatusBarColor(1.0,0.1,0.1,0.8)
        if self.text then
            self.text:SetText("Cast - "..(self.spellName or "Failed"))
        end
        self.casting=nil
        self.notInterruptible=nil
        self.holdTime=self.timeToHold or 0.1
    end
end

local function CastInterrupted(self,event,unit,castID)
    if self.unit~=unit then return end
    if event=="UNIT_SPELLCAST_INTERRUPTED" then
        if self.castID~=castID then return end
        self:SetStatusBarColor(0.50,0.00,0.50,0.8)
        if self.text then
            self.text:SetText("Cast - "..(self.spellName or "Interrupted"))
        end
        self.casting=nil
        self.channeling=nil
        self.holdTime=self.timeToHold or 0.1
    end
end

local function CastDelayed(self,event,unit)
    if self.unit~=unit then return end
    if event=="UNIT_SPELLCAST_DELAYED" then
        local _,_,_,startTime=UnitCast(unit)
        if not startTime or not self:IsShown() then return end
        local duration=GetTime()-(startTime/1000)
        if duration<0 then duration=0 end
        self.delay=self.delay+self.duration-duration
        self.duration=duration
        self:SetValue(duration)
    end
end

local function CastStop(self,event,unit,castID)
    if self.unit~=unit then return end
    if event=="UNIT_SPELLCAST_STOP" then
        if self.castID~=castID then return end
        self.casting=nil
        self.notInterruptible=nil
    end
end

local function ChannelStart(self,event,unit,_,spellID)
    if self.unit~=unit then return end
    if event=="UNIT_SPELLCAST_CHANNEL_START" then
        local name,text,textureID,startTimeMS,endTimeMS,_,notInterruptible=UnitChannel(unit)
        if not name then return end
        endTimeMS=endTimeMS/1e3
        startTimeMS=startTimeMS/1e3
        local max=endTimeMS-startTimeMS
        local duration=endTimeMS-GetTime()
        self.duration=duration
        self.max=max
        self.delay=0
        self.channeling=true
        self.notInterruptible=notInterruptible
        self.holdTime=0
        self.spellID=spellID
        self.casting=nil
        self.castID=nil
        self:SetMinMaxValues(0,max)
        self:SetValue(duration)
        self:SetStatusBarColor(0.18,0.54,0.34,0.8)
        if self.icon then
            self.icon:SetTexture(textureID or "Interface\\Icons\\INV_Misc_QuestionMark")
        end
        if self.text then
            self.text:SetText(text)
        end
        if self.safeZone then
            self.safeZone:ClearAllPoints()
            self.safeZone:SetPoint(self:GetReverseFill() and "LEFT" or "RIGHT")
            self.safeZone:SetPoint("TOP")
            self.safeZone:SetPoint("BOTTOM")
            updateSafeZone(self)
        end
        self:Show()
    end
end

local function ChannelUpdate(self,event,unit)
    if self.unit~=unit then return end
    if event=="UNIT_SPELLCAST_CHANNEL_UPDATE" then
        local name,_,_,startTimeMS,endTimeMS=UnitChannel(unit)
        if not name then return end
        local duration=(endTimeMS/1000)-GetTime()
        self.delay=self.delay+self.duration-duration
        self.duration=duration
        self.max=(endTimeMS-startTimeMS)/1000
        self:SetMinMaxValues(0,self.max)
        self:SetValue(duration)
    end
end

local function ChannelStop(self,event,unit)
    if self.unit~=unit then return end
    if event=="UNIT_SPELLCAST_CHANNEL_STOP" then
        if self:IsShown() then
            self.channeling=nil
            self.notInterruptible=nil
        end
    end
end

local event={
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_DELAYED",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_UPDATE",
    "UNIT_SPELLCAST_CHANNEL_STOP"
}
local handler={CastStart,CastStop,CastFailed,CastInterrupted,CastDelayed,ChannelStart,ChannelUpdate,ChannelStop}
local function castBarEvents(status)
    local state=status and RegisterEvent or UnregisterEvent
    for index,info in ipairs(event) do
        state(info,handler[index])
    end
end

function Ether:HideCastBar(index,bool)
    if bool and UpdateInfo() then
        UnregisterUpdate(index)
        castBar[index].text:SetText("Move CastBar")
        castBar[index]:SetShown(bool)
    else
        RegisterUpdate(index)
    end
end

function Ether:CastBarEnable(index)
    if not index or type(index)~="number" then return end
    castBar[index]=Ether:SetupCastBar(index)
    Ether:ApplyFramePosition(index+11)
    Ether:SetupDrag(index+11)
    RegisterUpdate(index)
    if UpdateInfo() then
        castBarEvents(true)
    end
end

function Ether:CastBarReset(index)
    if not castBar[index]:GetScript("OnUpdate") then return end
    Ether:CastBarDisable(index)
    Ether:TimerCallBack(2,"After",function()
        Ether:ApplyFramePosition(index+11)
        Ether:CastBarEnable(index)
    end,0)
end

function Ether:CastBarDisable(index)
    if not index or type(index)~="number" then return end
    if not castBar[index]:GetScript("OnUpdate") then return end
    UnregisterUpdate(index)
    castBar[index]:Hide()
    castBar[index]:ClearAllPoints()
    castBar[index]:SetScript("OnDragStart",nil)
    castBar[index]:SetScript("OnDragStop",nil)
    if not UpdateInfo() then
        castBarEvents(false)
    end
end
