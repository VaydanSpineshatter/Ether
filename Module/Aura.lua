local Ether = select(2, ...)
local C     = Ether
local Aura  = C.Aura


local ipairs           = ipairs
local pairs            = pairs

local DISPEL_TYPE      = {
    ['DRUID'] = { ['Curse'] = true, ['Poison'] = true },
    ['MAGE'] = { ['Curse'] = true },
    ['PALADIN'] = { ['Magic'] = true, ['Disease'] = true, ['Poison'] = true },
    ['PRIEST'] = { ['Magic'] = true, ['Disease'] = true },
    ['SHAMAN'] = { ['Poison'] = true, ['Disease'] = true },
}

local _, classFilename = UnitClass('player')
local DISPEL_TABLE     = DISPEL_TYPE[classFilename] or {}

local RAID_AURA_COLORS = {
    ['pink'] = { 0.80, 0.40, 1 },
    ['cyan'] = { 0, 1, 1 },
    ['blue'] = { 0.00, 0.80, 1.00 },
    ['black'] = { 0, 0, 0 },
    ['orange'] = { 1, 0.65, 0 },
    -- ['red'] = { 1, 0, 0 },
    ['green'] = { 0.00, 1.00, 0.00, },
    ['white'] = { 1, 1, 1 },
    ['yellow'] = { 1.00, 1.00, 0.00 },
    ['magenta'] = { 1.00, 0.00, 1.00 },
    ['saddlebrown'] = { 0.55, 0.27, 0.07 }
}
local RAID_AURA_COORDS = {
    ['pink'] = { 'BOTTOMLEFT', 0, 0 },
    ['cyan'] = { 'BOTTOMLEFT', 0, 6 },
    ['blue'] = { 'BOTTOMLEFT', 0, 18 },
    ['black'] = { 'BOTTOMLEFT', 0, 12 },
    ['orange'] = { 'BOTTOMLEFT', 0, 24 },
    --  ['red'] = { 'TOP', 0, -6 },
    ['green'] = { 'TOPRIGHT', 0, 0 },
    ['white'] = { 'TOP', 0, 0 },
    ['yellow'] = { 'TOPLEFT', 0, -15 },
    ['magenta'] = { 'TOPRIGHT', 0, -6 },
    ['saddlebrown'] = { 'TOP', 0, -12 }
}

local TRACKED_AURAS    = {
    [10938] = { name = 'pink' },
    [21564] = { name = 'pink' },
    [27841] = { name = 'cyan' },
    [27681] = { name = 'cyan' },
    [10958] = { name = 'black' },
    [27683] = { name = 'black' },
    [10157] = { name = 'blue' },
    [23028] = { name = 'blue' },
    [9885]  = { name = 'orange' },
    [21850] = { name = 'orange' },
    [25315] = { name = 'green' },
    [10901] = { name = 'white' },
    [15359] = { name = 'yellow' },
    [22009] = { name = 'magenta' },
    [6346]  = { name = 'saddlebrown' },
    [6788]  = { name = 'red' }
}

local DISPEL_COLOR     = {
    ['Curse'] = { 0.00, 0.80, 1.00, 1 },
    ['Disease'] = { 1.00, 0.84, 0.00, 1 },
    ['Magic'] = { 0.70, 0.13, 0.13, 1 },
    ['Poison'] = { 0.80, 0.40, 1.00, 1 }
}

local ICON_BORDER      = {
    ['Curse'] = { 0.6, 0, 1, 1 },
    ['Disease'] = { 0.6, 0.4, 0, 1 },
    ['Magic'] = { 0.2, 0.6, 1, 1 },
    ['Poison'] = { 0, 0.6, 0, 1 }
}

local function CanDispelAura(data)
    if not data or not data.isHarmful or not data.dispelName then return end
    return DISPEL_TABLE[data] == true
end

local function IsVaildSpell(data)
    if not data or not data.spellId then return end
    if Ether.DB['HEADER']['RAID']['AuraFilter'][data.spellId] then
        return true
    end
    return false
end

local function GetDispelBorder(data, unit)
    if not unit or not data or not data.dispelName then return end
    local color = DISPEL_COLOR[data.dispelName]
    unit.left:SetColorTexture(color[1], color[2], color[3], color[4])
    unit.right:SetColorTexture(color[1], color[2], color[3], color[4])
    unit.top:SetColorTexture(color[1], color[2], color[3], color[4])
    unit.bottom:SetColorTexture(color[1], color[2], color[3], color[4])
end

local P = { 0, 0, 0 }
local activeAuras = {}
local harmfulAuras = {}
local function OnAuraEvent(_, event, unit, info)
    if event ~= "UNIT_AURA" then return end
    if not unit or not C.Units.Data.Update.Cache[unit] then return end
    if not info or not (info.addedAuras or info.removedAuraInstanceIDs) then return end

    local unitId = C.Units.Data.Update.Cache[unit]
    if not unitId then return end

    if info.isFullUpdate then
        activeAuras[unit] = {}
        harmfulAuras[unit] = {}
    end

    if info.addedAuras then
        for _, data in ipairs(info.addedAuras) do
            activeAuras[unit] = activeAuras[unit] or {}
            harmfulAuras[unit] = harmfulAuras[unit] or {}
            if data and data.isHelpful then
                if not IsVaildSpell(data) then return end
                if TRACKED_AURAS[data.spellId] then
                    activeAuras[unit][data.auraInstanceID] = data.spellId
                    local config = TRACKED_AURAS[data.spellId]
                    unitId.RaidAura[config.name]:Show()
                end
            elseif data.isHarmful and data.spellId == 6788 then
                harmfulAuras[unit][data.auraInstanceID] = data.spellId
                C.Effects.StartBlink(unitId.RaidAura.red)
            elseif data.isHarmful and data.icon then
                harmfulAuras[unit][data.auraInstanceID] = 'icon'
                unitId.RaidAura.Icon:SetTexture(data.icon)
                unitId.RaidAura.Icon:Show()
                unitId.RaidAura.Border:Show()
                if data.dispelName then
                    if data.dispelName == 'Curse' then
                        unitId.RaidAura.Border:SetColorTexture(0.6, 0, 1, 1)
                    elseif data.dispelName == 'Magic' then
                        unitId.RaidAura.Border:SetColorTexture(0.2, 0.6, 1, 1)
                    elseif data.dispelName == 'Disease' then
                        unitId.RaidAura.Border:SetColorTexture(0.6, 0.4, 0, 1)
                    elseif data.dispelName == 'Poison' then
                        unitId.RaidAura.Border:SetColorTexture(0, 0.6, 0, 1)
                    else
                        unitId.RaidAura.Border:Hide()
                    end
                end
            elseif DISPEL_TABLE[data.dispelName] then
                harmfulAuras[unit][data.auraInstanceID] = 'dispelAura'
                local color = DISPEL_COLOR[data.dispelName]
                unitId.Border.Left:SetColorTexture(color[1], color[2], color[3], color[4])
                unitId.Border.Right:SetColorTexture(color[1], color[2], color[3], color[4])
                unitId.Border.Top:SetColorTexture(color[1], color[2], color[3], color[4])
                unitId.Border.Bottom:SetColorTexture(color[1], color[2], color[3], color[4])
            end
        end
    end


    if info.removedAuraInstanceIDs then
        for _, auraInstanceID in ipairs(info.removedAuraInstanceIDs) do
            local spellId = activeAuras[unit] and activeAuras[unit][auraInstanceID]

            if spellId then
                if TRACKED_AURAS[spellId] then
                    local config = TRACKED_AURAS[spellId]
                    unitId.RaidAura[config.name]:Hide()
                    activeAuras[unit][auraInstanceID] = nil
                end
            end
            local spell = harmfulAuras[unit] and harmfulAuras[unit][auraInstanceID]
            if spell == 6788 then
                Ether.Effects.StopBlink(unitId.RaidAura.red)
                harmfulAuras[unit][auraInstanceID] = nil
            else
                unitId.RaidAura.Icon:Hide()
                unitId.RaidAura.Border:Hide()
                unitId.Border.Left:SetColorTexture(0, 0, 0, 1)
                unitId.Border.Right:SetColorTexture(0, 0, 0, 1)
                unitId.Border.Top:SetColorTexture(0, 0, 0, 1)
                unitId.Border.Bottom:SetColorTexture(0, 0, 0, 1)
            end
        end
    end
end
--[[


unitId.RaidAura.Icon:Hide()
unitId.RaidAura.Border:Hide()

unitId.left:SetColorTexture(0, 0, 0, 1)
unitId.right:SetColorTexture(0, 0, 0, 1)
unitId.top:SetColorTexture(0, 0, 0, 1)
unitId.bottom:SetColorTexture(0, 0, 0, 1)
]]
function Aura:Initialize()
    if not self.AuraUpdater then
        self.AuraUpdater = CreateFrame('frame')
    end
    self.AuraUpdater:RegisterEvent("UNIT_AURA")
    self.AuraUpdater:SetScript("OnEvent", OnAuraEvent)
end

function Aura:UpdateRaidByUnitDebuff(frame)
    if not frame.unit then return end
    local Valid = Ether.DB['HEADER']['RAID']['AuraFilter']

    Ether.Effects.StopBlink(frame.RaidAura.red)

    local i = 1
    while true do
        local name, _, _, _, _, _, _, _, _, spellId = UnitAura(frame.unit, i, "HARMFUL")
        if not name then break end
        if Valid[spellId] then
            if spellId == 6788 then
                frame.RaidAura.red:SetPoint('TOP', frame.healthBar, 'TOP', 0, -6)
                C.Effects.StartBlink(frame.RaidAura.red)
                break
            end
        end
        i = i + 1
    end
end

function Aura:UpdateDebuffIcon(frame)
    if (not frame.unit) then return end

    frame.RaidAura.Icon:Hide()
    frame.RaidAura.Border:Hide()

    local i = 1
    while (true) do
        local name, icon, _, dispelType = UnitAura(frame.unit, i, "HARMFUL")
        if (not name) then break end
        if icon and dispelType then
            frame.RaidAura.Icon:SetTexture(icon)
            frame.RaidAura.Icon:Show()

            frame.RaidAura.Border:Show()
            if dispelType == 'Curse' then
                frame.RaidAura.Border:SetColorTexture(0.6, 0, 1, 1)
            elseif dispelType == 'Magic' then
                frame.RaidAura.Border:SetColorTexture(0.2, 0.6, 1, 1)
            elseif dispelType == 'Disease' then
                frame.RaidAura.Border:SetColorTexture(0.6, 0.4, 0, 1)
            elseif dispelType == 'Poison' then
                frame.RaidAura.Border:SetColorTexture(0, 0.6, 0, 1)
            else
                frame.RaidAura.Border:Hide()
            end
            break
        end
        i = i + 1
    end
end

function Aura:UpdateRaidDispel(frame)
    if (not frame.unit) then return end

    frame.left:SetColorTexture(0, 0, 0, 1)
    frame.right:SetColorTexture(0, 0, 0, 1)
    frame.top:SetColorTexture(0, 0, 0, 1)
    frame.bottom:SetColorTexture(0, 0, 0, 1)

    local i = 1
    while (true) do
        local name, _, _, dispelType = UnitAura(frame.unit, i, "HARMFUL")
        if (not name) then break end
        if DISPEL_TABLE[dispelType] then
            local color = DISPEL_COLOR[dispelType]
            frame.left:SetColorTexture(color[1], color[2], color[3], color[4])
            frame.right:SetColorTexture(color[1], color[2], color[3], color[4])
            frame.top:SetColorTexture(color[1], color[2], color[3], color[4])
            frame.bottom:SetColorTexture(color[1], color[2], color[3], color[4])
            break
        end
        i = i + 1
    end
end

function Aura:UpdateRaidByUnitBuff(frame)
    if (not frame.unit) then return end
    local Valid = Ether.DB['HEADER']['RAID']['AuraFilter']
    frame.RaidAura.pink:Hide()
    frame.RaidAura.cyan:Hide()
    frame.RaidAura.black:Hide()
    frame.RaidAura.blue:Hide()
    frame.RaidAura.orange:Hide()
    frame.RaidAura.green:Hide()
    frame.RaidAura.white:Hide()
    frame.RaidAura.yellow:Hide()
    frame.RaidAura.magenta:Hide()
    frame.RaidAura.saddlebrown:Hide()

    local i = 1
    while (true) do
        local name, _, _, _, _, _, _, _, _, spellId = UnitAura(frame.unit, i, 'HELPFUL')
        if (not name) then break end
        if Valid[spellId] then
            if spellId == 10901 then
                frame.RaidAura.white:SetPoint('TOP', frame.healthBar, 'TOP')
                frame.RaidAura.white:Show()
            elseif spellId == 25315 then
                frame.RaidAura.green:SetPoint('TOPRIGHT', frame.healthBar, 'TOPRIGHT')
                frame.RaidAura.green:Show()
            elseif spellId == 15359 then
                frame.RaidAura.yellow:SetPoint('TOPLEFT', frame.healthBar, 'TOPLEFT', 0, -15)
                frame.RaidAura.yellow:Show()
            elseif spellId == 22009 then
                frame.RaidAura.magenta:SetPoint('TOPRIGHT', frame.healthBar, 'TOPRIGHT', 0, -6)
                frame.RaidAura.magenta:Show()
            elseif spellId == 10938 or spellId == 21564 then
                frame.RaidAura.pink:SetPoint('BOTTOMLEFT', frame.healthBar, 'BOTTOMLEFT', 0, 0)
                frame.RaidAura.pink:Show()
            elseif spellId == 27681 or spellId == 27841 then
                frame.RaidAura.cyan:SetPoint('BOTTOMLEFT', frame.healthBar, 'BOTTOMLEFT', 0, 6)
                frame.RaidAura.cyan:Show()
            elseif spellId == 10958 or spellId == 27683 then
                frame.RaidAura.black:SetPoint('BOTTOMLEFT', frame.healthBar, 'BOTTOMLEFT', 0, 12)
                frame.RaidAura.black:Show()
            elseif spellId == 10157 or spellId == 23028 then
                frame.RaidAura.blue:SetPoint('BOTTOMLEFT', frame.healthBar, 'BOTTOMLEFT', 0, 18)
                frame.RaidAura.blue:Show()
            elseif spellId == 9885 or spellId == 21850 then
                frame.RaidAura.orange:SetPoint('BOTTOMLEFT', frame.healthBar, 'BOTTOMLEFT', 0, 18)
                frame.RaidAura.orange:Show()
            elseif spellId == 6346 then
                frame.RaidAura.saddlebrown:SetPoint('TOP', frame.healthBar, 'TOP', 0, -12)
                frame.RaidAura.saddlebrown:Show()
            end
        end
        i = i + 1
    end
end

function Aura:UpdateRaidAuraByUtil(frame, name)
    if (not frame.unit) then return end
    if name then
        local auraData = AuraUtil.FindAuraByName(name, frame.unit, 'HELPFUL')
        if auraData then
        end
    end
end

function Aura:SingleAuraUpdateBuff(frame, unit)
    if (not unit or not frame.SingleAura) then return end

    local visibleBuffCount = 0

    for i = 1, 16 do
        local name, icon, count, _, duration, expirationTime = UnitAura(unit, i, 'HELPFUL')
        local last                                           = frame.SingleAura.LastBuffs[i]
        local now                                            = frame.SingleAura.Buffs[i]

        if now and name and icon then
            if not last or last.name ~= name or last.icon ~= icon then
                now.icon:SetTexture(icon)
                now.icon:Show()

                last = last or {}
                last.name = name
                last.icon = icon
                frame.SingleAura.LastBuffs[i] = last
            end
            now:Show()

            if count and count > 1 then
                now.countStack:SetText(count)
                now.countStack:Show()
            else
                now.countStack:Hide()
            end

            if duration and duration > 0 and expirationTime and expirationTime > 0 then
                local startTime = expirationTime - duration
                now.cdTimer:SetCooldown(startTime, duration)
                now.cdTimer:Show()
            else
                now.cdTimer:Hide()
            end
            visibleBuffCount = visibleBuffCount + 1
        elseif now then
            now:Hide()
            now.icon:Hide()
            if now.countStack then now.countStack:Hide() end
            if now.cdTimer then now.cdTimer:Hide() end
            frame.SingleAura.LastBuffs[i] = nil
        end
    end

    frame.SingleAura.visibleBuffCount = visibleBuffCount
end

function Aura:SingleAuraUpdateDebuff(frame, unit)
    local visibleBuffCount = frame.SingleAura.visibleBuffCount or 0
    local buffRows = math.ceil(visibleBuffCount / 8)
    local startY = buffRows * (14 + 1) + 2

    for i = 1, 16 do
        local name, icon, count, dispelType, duration, expirationTime = UnitAura(unit, i, "HARMFUL")
        local last = frame.SingleAura.LastDebuffs[i]
        local now = frame.SingleAura.Debuffs[i]

        if now and name and icon then
            local row = math.floor((i - 1) / 8)
            local col = (i - 1) % 8
            local yOffset = startY + row * (14 + 1)

            now:ClearAllPoints()
            now:SetPoint('BOTTOMLEFT', frame, 'TOPLEFT', col * (14 + 1) - 1, yOffset + 2)
            now:Show()

            if not last or last.name ~= name or last.icon ~= icon or last.dispelType ~= dispelType then
                now.icon:SetTexture(icon)
                now.icon:Show()
                local border = now.border

                if dispelType == 'Curse' then
                    border:SetColorTexture(0.6, 0, 1, 1)
                    border:Show()
                elseif dispelType == 'Magic' then
                    border:SetColorTexture(0.2, 0.6, 1, 1)
                    border:Show()
                elseif dispelType == 'Disease' then
                    border:SetColorTexture(0.6, 0.4, 0, 1)
                    border:Show()
                elseif dispelType == 'Poison' then
                    border:SetColorTexture(0, 0.6, 0, 1)
                    border:Show()
                else
                    border:Hide()
                end

                last = last or {}
                last.name = name
                last.icon = icon
                last.dispelType = dispelType
                frame.SingleAura.LastDebuffs[i] = last
            end

            if count and count > 1 then
                now.countStack:SetText(count)
                now.countStack:Show()
            else
                now.countStack:Hide()
            end

            if duration and duration > 0 and expirationTime and expirationTime > 0 then
                local startTime = expirationTime - duration
                now.cdTimer:SetCooldown(startTime, duration)
                now.cdTimer:Show()
            else
                now.cdTimer:Hide()
            end
        elseif now then
            now:Hide()
            now.icon:Hide()
            now.border:Hide()
            if now.countStack then now.countStack:Hide() end
            if now.cdTimer then now.cdTimer:Hide() end
            frame.SingleAura.LastDebuffs[i] = nil
        end
    end
end

function Aura:SingleAuraSetup(frame, unit)
    if (not unit or not frame.SingleAura) then return end
    for i = 1, 16 do
        local BUFF = CreateFrame('Frame', nil, frame)
        BUFF:SetSize(14, 14)

        local row = math.floor((i - 1) / 8)
        local col = (i - 1) % 8
        local xOffset = col * (14 + 1)
        local yOffset = 1 + row * (14 + 1)

        BUFF:SetPoint('BOTTOMLEFT', frame, 'TOPLEFT', xOffset - 1, yOffset + 2)
        BUFF:Show()

        local icon = BUFF:CreateTexture(nil, 'ARTWORK')
        icon:SetAllPoints()
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        BUFF.icon = icon

        local Count = BUFF:CreateFontString(nil, 'OVERLAY')
        Count:SetFont(unpack(Ether.Data.Forming.Font), 10, 'OUTLINE')
        Count:SetPoint('LEFT')
        Count:Hide()

        local Timer = CreateFrame("Cooldown", nil, BUFF, "CooldownFrameTemplate")
        Timer:SetAllPoints(icon)
        Timer:SetHideCountdownNumbers(true)
        Timer:SetReverse(true)
        Timer:SetBlingTexture("Interface\\Cooldown\\star4_edge", 1, 1, 1, 1)

        BUFF.countStack = Count
        BUFF.cdTimer = Timer

        BUFF:SetScript('OnEnter',
            function(self)
                GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
                GameTooltip:SetUnitAura(unit, i, 'HELPFUL')
                GameTooltip:Show()
            end)
        BUFF:SetScript('OnLeave', GameTooltip_Hide)

        frame.SingleAura.Buffs[i] = BUFF
    end

    for i = 1, 16 do
        local DEBUFF = CreateFrame('Frame', nil, frame)
        DEBUFF:SetSize(14, 14)

        DEBUFF:SetPoint('BOTTOMLEFT', frame, 'TOPLEFT')
        DEBUFF:Show()

        local icon = DEBUFF:CreateTexture(nil, 'ARTWORK')
        icon:SetAllPoints()
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        DEBUFF.icon = icon

        local border = DEBUFF:CreateTexture(nil, 'BORDER')
        border:SetColorTexture(1, 0, 0, 1)
        border:SetPoint('TOPLEFT', -1, 1)
        border:SetPoint('BOTTOMRIGHT', 1, -1)
        border:Hide()
        DEBUFF.border = border

        local Count = DEBUFF:CreateFontString(nil, 'OVERLAY')
        Count:SetFont(unpack(Ether.Data.Forming.Font), 10, 'OUTLINE')
        Count:SetPoint('LEFT')
        Count:Hide()

        local Timer = CreateFrame("Cooldown", nil, DEBUFF, "CooldownFrameTemplate")
        Timer:SetAllPoints(icon)
        Timer:SetHideCountdownNumbers(true)
        Timer:SetReverse(true)
        Timer:SetBlingTexture("Interface\\Cooldown\\star4_edge", 1, 1, 1, 1)

        DEBUFF.countStack = Count
        DEBUFF.cdTimer = Timer

        DEBUFF:SetScript('OnEnter',
            ---@diagnostic disable-next-line: redefined-local
            function(self)
                GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
                GameTooltip:SetUnitAura(unit, i, 'HARMFUL')
                GameTooltip:Show()
            end)
        DEBUFF:SetScript('OnLeave', GameTooltip_Hide)

        frame.SingleAura.Debuffs[i] = DEBUFF
    end
end

function Aura:RaidAuraSetup(frame)
    if (not frame) then return end
    if not frame.RaidAura then
        frame.RaidAura = {}
    end
    for name in pairs(RAID_AURA_COLORS) do
        local point = RAID_AURA_COORDS[name]
        local tex = RAID_AURA_COLORS[name]
        frame.RaidAura[name] = frame.healthBar:CreateTexture(nil, 'OVERLAY')
        frame.RaidAura[name]:SetSize(6, 6)
        frame.RaidAura[name]:SetPoint(point[1], point[2], point[3])
        frame.RaidAura[name]:SetColorTexture(tex[1], tex[2], tex[3], tex[4])
        frame.RaidAura[name]:Hide()
    end
    frame.RaidAura.red = frame.healthBar:CreateTexture(nil, 'OVERLAY')
    frame.RaidAura.red:SetSize(6, 6)
    frame.RaidAura.red:SetPoint('TOP', 0, -6)
    frame.RaidAura.red:SetColorTexture(1, 0, 0, 1)
    frame.RaidAura.red:Hide()

    local Icon = CreateFrame('Frame', nil, frame.healthBar)
    Icon:SetSize(12, 12)
    Icon:SetPoint('CENTER', 0, 6)

    frame.RaidAura.Border = Icon:CreateTexture(nil, 'BORDER')
    frame.RaidAura.Border:SetColorTexture(1, 0, 0, 1)
    frame.RaidAura.Border:SetPoint('TOPLEFT', -1, 1)
    frame.RaidAura.Border:SetPoint('BOTTOMRIGHT', 1, -1)
    frame.RaidAura.Border:Hide()

    frame.RaidAura.Icon = Icon:CreateTexture(nil, 'ARTWORK')
    frame.RaidAura.Icon:SetAllPoints()
    frame.RaidAura.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    frame.RaidAura.Icon:Hide()
end
