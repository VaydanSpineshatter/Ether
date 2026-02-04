local _, Ether = ...
local GetNetStats = GetNetStats
local GetTime = GetTime
local UnitCast = UnitCastingInfo
local UnitChannel = UnitChannelInfo
local timeStr = "%.1f|cffff0000-%.1f|r"
local tStr = "%.1f"

local Config = {
    texture = {"Interface\\Icons\\INV_Misc_QuestionMark"},
    colors = {
        casting = {0.2, 0.6, 1.0, 0.8},
        channeling = {0.18, 0.54, 0.34, 0.8},
        fail = {1.0, 0.1, 0.1, 0.8},
        interrupted = {0.50, 0.00, 0.50, 0.8},
        trading = {1.00, 0.84, 0.00, 1}
    }
}

local function OnUpdate(self, elapsed)
    if (self.casting) then
        local duration = self.duration + elapsed
        if (duration >= self.max) then
            self.casting = nil
            self:Hide()
            return
        end
        if (Ether.DB[801][8] == 1 and self.time) then
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
        if (Ether.DB[801][8] == 1 and self.time) then
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

local RegisterUpdateFrame, UnregisterUpdateFrame, UpdateFrameInfo
local RegisterCastBarEvent, UnregisterCastBarEvent
do
    local IsEventValid = C_EventUtils.IsEventValid
    local eventFrame
    local Events, Updates = {}, {}
    local bar = Ether.unitButtons.solo
    function RegisterCastBarEvent(castEvent, func)
        if not eventFrame then
            eventFrame = CreateFrame("Frame")
            eventFrame:SetScript("OnEvent", function(self, event, unit, ...)
                 if not bar[unit] then return end
                 self.unit = bar[unit]:GetAttribute("unit")
                 Events[event](bar[self.unit], event, unit, ...)
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
    function UpdateFrameInfo()
        if #Updates > 0 then
            return true
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
    if Ether.DB[801][11] ~= 1 then return end
    local trade = Config.colors.trading
    local cast = Config.colors.casting
    data = data and trade or cast
    return self:SetStatusBarColor(unpack(data))
end

local button = Ether.unitButtons.solo
local function CastStart(self, event, unit)
    if self.unit ~= unit then return end
    if event == "UNIT_SPELLCAST_START" then
        local bar = self.castBar
        local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellID = UnitCast(unit)
        if not bar or not name then return end
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
        if (Ether.DB[801][7] == 1 and bar.icon) then
            bar.icon:SetTexture(texture or unpack(Config.texture))
        end
        if (Ether.DB[801][9] == 1 and bar.text) then
            bar.spellName = name
            bar.text:SetText(text)
        end
        isTrade(bar, isTradeSkill)
        if (Ether.DB[801][10] == 1 and bar.safeZone) then
            bar.safeZone:ClearAllPoints()
            bar.safeZone:SetPoint(bar:GetReverseFill() and "LEFT" or "RIGHT")
            bar.safeZone:SetPoint("TOP")
            bar.safeZone:SetPoint("BOTTOM")
            updateSafeZone(bar)
        end
        bar:Show()
    end
end

local function CastFailed(self, event, unit, castID)
    if self.unit ~= unit then return end
    if event == "UNIT_SPELLCAST_FAILED" then
        local bar = self.castBar
        if (not bar or bar.castID ~= castID) then
            return
        end
        bar:SetStatusBarColor(unpack(Config.colors.fail))
        if (Ether.DB[801][9] == 1 and bar.text) then
            bar.text:SetText("Cast - " .. (bar.spellName or "Failed"))
        end
        bar.casting = nil
        bar.notInterruptible = nil
        bar.holdTime = bar.timeToHold or 0
    end
end

local function CastInterrupted(self, event, unit, castID)
    if self.unit ~= unit then return end
    if event == "UNIT_SPELLCAST_INTERRUPTED" then
        local bar = self.castBar
        if (not bar or bar.castID ~= castID) then
            return
        end
        bar:SetStatusBarColor(unpack(Config.colors.interrupted))
        if (Ether.DB[801][9] == 1 and bar.text) then
            bar.text:SetText("Cast - " .. (bar.spellName or "Interrupted"))
        end
        bar.casting = nil
        bar.channeling = nil
        bar.holdTime = bar.timeToHold or 0
    end
end

local function CastDelayed(self, event, unit)
    if self.unit ~= unit then return end
    if event == "UNIT_SPELLCAST_DELAYED" then
        local bar = self.castBar
        local _, _, _, startTime = UnitCast(unit)
        if (not bar or not startTime or not bar:IsShown()) then
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

local function CastStop(self, event, unit, castID)
    if self.unit ~= unit then return end
    if event == "UNIT_SPELLCAST_STOP" then
        local bar = self.castBar
        if (not bar or bar.castID ~= castID) then
            return
        end
        bar.casting = nil
        bar.notInterruptible = nil
    end
end

local function ChannelStart(self, event, unit, _, spellID)
    if self.unit ~= unit then return end
    if event == "UNIT_SPELLCAST_CHANNEL_START" then
        local bar = self.castBar
        local name, text, textureID, startTimeMS, endTimeMS, _, notInterruptible = UnitChannel(unit)
        if not bar or not name then return end
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
        if (Ether.DB[801][7] == 1 and bar.icon) then
            bar.icon:SetTexture(textureID or unpack(Config.texture))
        end
        if (Ether.DB[801][9] == 1 and bar.text) then
            bar.text:SetText(text)
        end
        if (Ether.DB[801][10] == 1 and bar.safeZone) then
            bar.safeZone:ClearAllPoints()
            bar.safeZone:SetPoint(bar:GetReverseFill() and "LEFT" or "RIGHT")
            bar.safeZone:SetPoint("TOP")
            bar.safeZone:SetPoint("BOTTOM")
            updateSafeZone(bar)
        end
        bar:Show()
    end
end

local function ChannelUpdate(self, event, unit)
    if self.unit ~= unit then return end
    if event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
        local bar = self.castBar
        local name, _, _, startTimeMS, endTimeMS = UnitChannel(unit)
        if (not bar or not name or not bar:IsShown()) then
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

local function ChannelStop(self, event, unit)
    if self.unit ~= unit then return end
    if event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        local bar = self.castBar
        if (bar:IsShown()) then
            bar.channeling = nil
            bar.notInterruptible = nil
        end
    end
end

local event = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_DELAYED",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_UPDATE",
    "UNIT_SPELLCAST_CHANNEL_STOP"
}
local handler = {CastStart, CastStop, CastFailed, CastInterrupted, CastDelayed, ChannelStart, ChannelUpdate, ChannelStop}

local function castBarEvents(status)
    if status then
        for index = 1, 7 do
            RegisterCastBarEvent(event[index], handler[index])
        end
    else
        for index = 1, 7 do
            UnregisterCastBarEvent(event[index])
        end
    end
end

function Ether:CastBarEnable(unit)
    local bar = button[unit]
    if not bar then return
    elseif not bar.castBar then
        Ether:SetupCastBar(bar)
        RegisterUpdateFrame(bar.castBar)
    end
    castBarEvents(true)
end

function Ether:CastBarDisable(unit)
    local bar = button[unit]
    if not bar then return
    elseif bar.castBar then
        bar.castBar:Hide()
        UnregisterUpdateFrame(bar.castBar)
        bar.castBar:ClearAllPoints()
        bar.castBar:SetParent(nil)
        bar.castBar = nil
    end
    if UpdateFrameInfo() then
        castBarEvents(false)
    end
end

