local Ether = select(2, ...)
local C = Ether
local Castbar = C.Castbar

local GetTime = GetTime
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local min = math.min


local function Castbar_OnUpdate(self, elapsed)
    if self.casting then
        self.duration = self.duration + elapsed
        if (self.duration >= self.max) then
            self.casting = nil
            self:Hide()
            return
        end

        self:SetValue(self.duration)

        if self.timeText then
            local timeLeft = self.max - self.duration
            self.timeText:SetFormattedText("%.1f", timeLeft)
        end

        if self.spark then
            local sparkPosition = (self.duration / self.max) * self:GetWidth()
            self.spark:SetPoint("CENTER", self, "LEFT", sparkPosition, 0)
        end
    elseif self.channeling then
        self.duration = self.duration - elapsed
        if (self.duration <= 0) then
            self.channeling = nil
            self:Hide()
            return
        end

        self:SetValue(self.duration)

        if self.timeText then
            self.timeText:SetFormattedText("%.1f", self.duration)
        end

        if self.spark then
            local sparkPosition = (self.duration / self.max) * self:GetWidth()
            self.spark:SetPoint("CENTER", self, "LEFT", sparkPosition, 0)
        end
    else
        self:Hide()
    end
end

local function OnEvent(self, event, unit)
    if unit ~= self.unit then return end

    if event == "UNIT_SPELLCAST_START" then
        local name, _, texture, startTime, endTime = UnitCastingInfo(unit)
        if not name then return end

        self:SetStatusBarColor(0.2, 0.6, 1.0, 0.8)
        self.spellName:SetText(name)
        self.icon:SetTexture(texture)

        self.duration = 0
        self.max = (endTime - startTime) / 1000
        self:SetMinMaxValues(0, self.max)
        self:SetValue(0)

        self.casting = true
        self.channeling = nil
        self:SetAlpha(1)
        self:Show()
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        local name, _, texture, startTime, endTime = UnitChannelInfo(unit)
        if not name then return end

        self:SetStatusBarColor(0.9, 0.8, 0.1, 0.8)
        self.spellName:SetText(name)
        self.icon:SetTexture(texture)

        self.max = (endTime - startTime) / 1000
        self.duration = self.max

        self:SetMinMaxValues(0, self.max)
        self:SetValue(self.max)

        self.casting = nil
        self.channeling = true
        self:SetAlpha(1)
        self:Show()
    elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        if self.casting or self.channeling then
            self.casting = nil
            self.channeling = nil
            self:Hide()
        end
    elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
        if self.casting then
            self:SetStatusBarColor(1.0, 0.1, 0.1, 0.8)

            local text = (event == "UNIT_SPELLCAST_FAILED") and "Failed" or "Interrupted"
            self.spellName:SetText(self.spellName:GetText() .. " - " .. text)

            self.casting = nil
            self.channeling = nil

            C_Timer.After(1.0, function()
                if not self.casting and not self.channeling then
                    self:Hide()
                end
            end)
        end
    elseif event == "UNIT_SPELLCAST_DELAYED" then
        if self.casting then
            local name, _, _, startTime, endTime = UnitCastingInfo(unit)
            if name then
                self.max = (endTime - startTime) / 1000
            end
        end
    end
end


function Castbar:CreateCastbar(unit)
    local bar = CreateFrame("StatusBar", nil, UIParent)
    bar:SetSize(260, 20)
    bar.unit = unit

    bar:SetStatusBarTexture(unpack(Ether.Data.Forming.StatusBar))
    bar:SetStatusBarColor(0.2, 0.6, 1.0, 0.8)

    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture(unpack(Ether.Data.Forming.StatusBar))
    bg:SetVertexColor(0.1, 0.1, 0.1, 0.5)
    bar.bg = bg

    local spark = bar:CreateTexture(nil, "OVERLAY")
    spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    spark:SetBlendMode("ADD")
    spark:SetSize(20, 50)
    bar.spark = spark

    local text = bar:CreateFontString(nil, "OVERLAY")
    text:SetFont(unpack(C.Data.Forming.Font), 12, 'OUTLINE')
    text:SetPoint("LEFT", 5, 0)
    text:SetJustifyH("LEFT")
    bar.spellName = text

    local time = bar:CreateFontString(nil, "OVERLAY")
    time:SetFont(unpack(C.Data.Forming.Font), 12, 'OUTLINE')
    time:SetPoint("RIGHT", -5, 0)
    time:SetJustifyH("RIGHT")
    bar.timeText = time

    local icon = bar:CreateTexture(nil, "OVERLAY")
    icon:SetSize(16, 16)
    icon:SetPoint("RIGHT", bar, "LEFT", -1, 0)
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    bar.icon = icon

    bar:SetScript("OnUpdate", Castbar_OnUpdate)
    bar:SetScript("OnEvent", OnEvent)

    bar:RegisterUnitEvent("UNIT_SPELLCAST_START", bar.unit)
    bar:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", bar.unit)
    bar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", bar.unit)
    bar:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", bar.unit)
    bar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", bar.unit)
    bar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", bar.unit)
    bar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", bar.unit)
    bar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", bar.unit)

    bar:Hide()

    return bar
end
