local _, Ether = ...
local CastBar = {}
Ether.CastBar = CastBar

local GetNetStats = GetNetStats
local GetTime = GetTime
local UnitCast = UnitCastingInfo
local UnitChannel = UnitChannelInfo
local timeStr = "%.1f|cffff0000-%.1f|r"
local tStr = "%.1f"

local Config = {
    showIcon = true,
    showTime = true,
    showName = true,
    showSafeZone = true,
    texture = {"Interface\\Icons\\INV_Misc_QuestionMark"},
    colors = {
        casting = {0.2, 0.6, 1.0, 0.8},
        channeling = {0.18, 0.54, 0.34, 0.8},
        fail = {1.0, 0.1, 0.1, 0.8},
        interrupted = {0.50, 0.00, 0.50, 0.8},
        trading = {1.00, 0.84, 0.00, 1}
    }
}
Ether.CastBar.Config = Config

local function OnUpdate(self, elapsed)
    if (self.casting) then
        local duration = self.duration + elapsed
        if (duration >= self.max) then
            self.casting = nil
            self:Hide()
            return
        end
        if (self.time) then
            if (self.delay ~= 0) then
                self.time:SetFormattedText(timeStr, duration, self.delay)
            else
                self.time:SetFormattedText(tStr, duration)
            end
        end
        self.duration = duration
        self:SetValue(duration)
    elseif (self.channeling) then
        local duration = self.duration - elapsed
        if (duration <= 0) then
            self.channeling = nil
            self:Hide()
            return
        end
        if (self.time) then
            if (self.delay ~= 0) then
                self.time:SetFormattedText(timeStr, duration, self.delay)
            else
                self.time:SetFormattedText(tStr, duration)
            end
        end
        self.duration = duration
        self:SetValue(duration)
    else
        self.casting = nil
        self.channeling = nil
        self:Hide()
    end
end

local RegisterUpdateFrame, UnregisterUpdateFrame
local RegisterCastBarEvent, UnregisterCastBarEvent
do
    local IsEventValid = C_EventUtils.IsEventValid
    local eventFrame
    local Events, Updates = {}, {}
    function RegisterCastBarEvent(castEvent, func)
        if not eventFrame then
            eventFrame = CreateFrame("Frame")
            eventFrame:SetScript("OnEvent", function(self, event, unit, ...)
                Events[event](self, event, unit, ...)
            end)
        end
        if not Events[castEvent] then
            if IsEventValid(castEvent) and not eventFrame:IsEventRegistered(castEvent) then
                eventFrame:RegisterEvent(castEvent)
            end
        end
        Events[castEvent] = func
    end
    function UnregisterCastBarEvent(...)
        if eventFrame then
            for i = select("#", ...), 1, -1 do
                local event = select(i, ...)
                if IsEventValid(event) then
                    if Events[event] and eventFrame:IsEventRegistered(event) then
                        eventFrame:UnregisterEvent(event)
                    end
                end
                Events[event] = nil
            end
        end
    end

    function RegisterUpdateFrame(onUpdate)
        if not Updates[onUpdate] then
            Updates[onUpdate] = onUpdate
            Updates[onUpdate]:SetScript("OnUpdate", OnUpdate)
        end
    end
    function UnregisterUpdateFrame(onUpdate)
        if Updates[onUpdate] then
            Updates[onUpdate]:SetScript("OnUpdate", nil)
            Updates[onUpdate] = nil
        end
    end
end

local function updateSafeZone(self)
    local safeZone = self.safeZone
    local width = self:GetWidth()
    local _, _, _, ms = GetNetStats()
    local safeZoneRatio = (ms / 1e3) / self.max
    if (safeZoneRatio > 1) then
        safeZoneRatio = 1
    end
    safeZone:SetWidth(width * safeZoneRatio)
end

local function isTrade(self, data)
    local trade = Config.colors.trading
    local cast = Config.colors.casting
    data = data and trade or cast
    return self:SetStatusBarColor(unpack(data))
end

local function CastStart(_, event, unit)
    if not unit or (unit ~= "player" and unit ~= "target") then
        return
    end
    if event == "UNIT_SPELLCAST_START" then
        local bar = Ether.unitButtons.solo[unit].castBar
        local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellID = UnitCast(unit)
        if (not name or not bar) then
            return
        end
        endTimeMS = endTimeMS / 1e3
        startTimeMS = startTimeMS / 1e3
        local max = endTimeMS - startTimeMS
        bar.castID = castID
        bar.duration = GetTime() - startTimeMS
        bar.max = max
        bar.casting = true
        bar.delay = 0
        bar.notInterruptible = notInterruptible
        bar.holdTime = 0
        bar.spellID = spellID
        bar:SetMinMaxValues(0, max)
        bar:SetValue(0)
        bar:SetStatusBarColor(unpack(Config.colors.casting))
        if (bar.icon) then
            bar.icon:SetTexture(texture or unpack(Config.texture))
        end
        if (bar.text) then
            bar.spellName = name
            bar.text:SetText(text)
        end
        isTrade(bar, isTradeSkill)
        if (bar.safeZone) then
            bar.safeZone:ClearAllPoints()
            bar.safeZone:SetPoint(bar:GetReverseFill() and "LEFT" or "RIGHT")
            bar.safeZone:SetPoint("TOP")
            bar.safeZone:SetPoint("BOTTOM")
            updateSafeZone(bar)
        end
        bar:Show()
    end
end

local function CastFailed(_, event, unit, castID)
    if unit ~= "player" and unit ~= "target" then
        return
    end
    if event == "UNIT_SPELLCAST_FAILED" then
        local bar = Ether.unitButtons.solo[unit].castBar
        if (bar.castID ~= castID) then
            return
        end
        bar:SetStatusBarColor(unpack(Config.colors.fail))
        if (bar.text) then
            bar.text:SetText("Cast - " .. (bar.spellName or "Failed"))
        end
        bar.casting = nil
        bar.notInterruptible = nil
        bar.holdTime = bar.timeToHold or 0
    end
end

local function CastInterrupted(_, event, unit, castID)
    if unit ~= "player" and unit ~= "target" then
        return
    end
    if event == "UNIT_SPELLCAST_INTERRUPTED" then
        local bar = Ether.unitButtons.solo[unit].castBar
        if (not bar or bar.castID ~= castID) then
            return
        end
        bar:SetStatusBarColor(unpack(Config.colors.interrupted))
        if (bar.text) then
            bar.text:SetText("Cast - " .. (bar.spellName or "Interrupted"))
        end
        bar.casting = nil
        bar.channeling = nil
        bar.holdTime = bar.timeToHold or 0
    end
end

local function CastDelayed(_, event, unit)
    if unit ~= "player" and unit ~= "target" then
        return
    end
    if event == "UNIT_SPELLCAST_DELAYED" then
        local bar = Ether.unitButtons.solo[unit].castBar
        local _, _, _, startTime = UnitCast(unit)
        if (not startTime or not bar:IsShown()) then
            return
        end
        local duration = GetTime() - (startTime / 1000)
        if (duration < 0) then
            duration = 0
        end
        bar.delay = bar.delay + bar.duration - duration
        bar.duration = duration
        bar:SetValue(duration)
    end
end

local function CastStop(_, event, unit, castID)
    if unit ~= "player" and unit ~= "target" then
        return
    end
    if event == "UNIT_SPELLCAST_STOP" then
        local bar = Ether.unitButtons.solo[unit].castBar
        if (not bar or bar.castID ~= castID) then
            return
        end
        bar.casting = nil
        bar.notInterruptible = nil
    end
end

local function ChannelStart(_, event, unit, _, spellID)
    if unit ~= "player" and unit ~= "target" then
        return
    end
    if event == "UNIT_SPELLCAST_CHANNEL_START" then
        local bar = Ether.unitButtons.solo[unit].castBar
        local name, text, textureID, startTimeMS, endTimeMS, _, notInterruptible = UnitChannel(unit)
        if (not name or not bar) then
            return
        end
        endTimeMS = endTimeMS / 1e3
        startTimeMS = startTimeMS / 1e3
        local max = endTimeMS - startTimeMS
        local duration = endTimeMS - GetTime()
        bar.duration = duration
        bar.max = max
        bar.delay = 0
        bar.channeling = true
        bar.notInterruptible = notInterruptible
        bar.holdTime = 0
        bar.spellID = spellID
        bar.casting = nil
        bar.castID = nil

        bar:SetMinMaxValues(0, max)
        bar:SetValue(duration)
        bar:SetStatusBarColor(unpack(Config.colors.channeling))
        if (bar.icon) then
            bar.icon:SetTexture(textureID or unpack(Config.texture))
        end
        if (bar.text) then
            bar.text:SetText(text)
        end
        if (bar.safeZone) then
            bar.safeZone:ClearAllPoints()
            bar.safeZone:SetPoint(bar:GetReverseFill() and "LEFT" or "RIGHT")
            bar.safeZone:SetPoint("TOP")
            bar.safeZone:SetPoint("BOTTOM")
            updateSafeZone(bar)
        end
        bar:Show()
    end
end

local function ChannelUpdate(_, event, unit)
    if unit ~= "player" and unit ~= "target" then
        return
    end
    if event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
        local bar = Ether.unitButtons.solo[unit].castBar
        local name, _, _, startTimeMS, endTimeMS = UnitChannel(unit)
        if (not name or not bar:IsShown()) then
            return
        end
        local duration = (endTimeMS / 1000) - GetTime()
        bar.delay = bar.delay + bar.duration - duration
        bar.duration = duration
        bar.max = (endTimeMS - startTimeMS) / 1000
        bar:SetMinMaxValues(0, bar.max)
        bar:SetValue(duration)
    end
end

local function ChannelStop(_, event, unit)
    if unit ~= "player" and unit ~= "target" then
        return
    end
    if event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        local bar = Ether.unitButtons.solo[unit].castBar
        if (bar:IsShown()) then
            bar.channeling = nil
            bar.notInterruptible = nil
        end
    end
end

local function EnableCastEvents()
    if Ether.DB[2001][1] or Ether.DB[2001][2] == 1 then
        RegisterCastBarEvent("UNIT_SPELLCAST_START", CastStart)
        RegisterCastBarEvent("UNIT_SPELLCAST_STOP", CastStop)
        RegisterCastBarEvent("UNIT_SPELLCAST_FAILED", CastFailed)
        RegisterCastBarEvent("UNIT_SPELLCAST_INTERRUPTED", CastInterrupted)
        RegisterCastBarEvent("UNIT_SPELLCAST_DELAYED", CastDelayed)
        RegisterCastBarEvent("UNIT_SPELLCAST_CHANNEL_START", ChannelStart)
        RegisterCastBarEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", ChannelUpdate)
        RegisterCastBarEvent("UNIT_SPELLCAST_CHANNEL_STOP", ChannelStop)
    end
end

local function Enable(unit)
    if not Ether.unitButtons.solo[unit] then
        return
    end
    if not Ether.unitButtons.solo[unit].castBar then
        Ether.Setup.CreateCastBar(Ether.unitButtons.solo[unit])
        RegisterUpdateFrame(Ether.unitButtons.solo[unit].castBar)
    end
    EnableCastEvents()
end

local function Disable(unit)
    if not Ether.unitButtons.solo[unit] then
        return
    end
    if Ether.unitButtons.solo[unit].castBar then
        UnregisterUpdateFrame(Ether.unitButtons.solo[unit].castBar)
    end
    if (Ether.unitButtons.solo[unit].castBar) then
        Ether.unitButtons.solo[unit].castBar:Hide()
        Ether.unitButtons.solo[unit].castBar:ClearAllPoints()
        Ether.unitButtons.solo[unit].castBar:SetParent(nil)
        Ether.unitButtons.solo[unit].castBar = nil
    end
end

local function DisableCastEvents()
    UnregisterCastBarEvent("UNIT_SPELLCAST_START")
    UnregisterCastBarEvent("UNIT_SPELLCAST_STOP")
    UnregisterCastBarEvent("UNIT_SPELLCAST_FAILED")
    UnregisterCastBarEvent("UNIT_SPELLCAST_INTERRUPTED")
    UnregisterCastBarEvent("UNIT_SPELLCAST_DELAYED")
    UnregisterCastBarEvent("UNIT_SPELLCAST_CHANNEL_START")
    UnregisterCastBarEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
    UnregisterCastBarEvent("UNIT_SPELLCAST_CHANNEL_STOP")
end

Ether.CastBar.Enable = Enable
Ether.CastBar.Disable = Disable
Ether.CastBar.EnableCastEvents = EnableCastEvents
Ether.CastBar.DisableCastEvents = DisableCastEvents
Ether.CastBar.DisableCastEvents = DisableCastEvents
Ether.CastBar.RegisterUpdateFrame = RegisterUpdateFrame
Ether.CastBar.UnregisterUpdateFrame = UnregisterUpdateFrame
