local _, Ether = ...

local math_floor = math.floor
local math_ceil = math.ceil
local G_Time = GetTime
local pairs, ipairs = pairs, ipairs
local GetBuffDataByIndex = C_UnitAuras.GetBuffDataByIndex
local GetDebuffDataByIndex = C_UnitAuras.GetDebuffDataByIndex
local dispelClass = {
    MAGE = {["Curse"] = true},
    PRIEST = {["Magic"] = true, ["Disease"] = true},
    PALADIN = {["Magic"] = true, ["Disease"] = true, ["Poison"] = true},
    DRUID = {["Curse"] = true, ["Poison"] = true},
    SHAMAN = {["Disease"] = true, ["Poison"] = true},
    WARRIOR = true,
    ROGUE = true,
    HUNTER = true,
    WARLOCK = true
}
local dispelPriority = {
    Magic = 4,
    Disease = 3,
    Curse = 2,
    Poison = 1
}
local dispelColors = {
    ["Magic"] = {0.2, 0.6, 1.0, 1},
    ["Curse"] = {0.6, 0.2, 1.0, 1},
    ["Disease"] = {0.6, 0.4, 0.0, 1},
    ["Poison"] = {0.1, 0.9, 0.1, 1}
}

local _, classFilename = UnitClass("player")
local dispelByPlayer = {}
dispelByPlayer = dispelClass[classFilename]

local raidIcons = {}

local function UpdateIconUI(unit, spellId, config, active)
    local button = Ether.unitButtons.raid[unit]
    local frame = CreateFrame("Frame", nil, UIParent)
    if active then
        if not raidIcons[spellId] then
            raidIcons[spellId] = frame:CreateTexture(nil, "OVERLAY")
            raidIcons[spellId]:SetParent(button.healthBar)
            raidIcons[spellId]:SetColorTexture(unpack(config.color))
            raidIcons[spellId]:SetSize(config.size, config.size)
            raidIcons[spellId]:SetPoint(config.position, config.offsetX, config.offsetY)
            raidIcons[spellId]:Show()
        end
    else
        if raidIcons[spellId] then
            raidIcons[spellId]:Hide()
            raidIcons[spellId]:ClearAllPoints()
            raidIcons[spellId] = nil
        end
    end
end

local auraCache = {}
local function UpdateSingleAura(unit, spellId, config)
    local aura = C_UnitAuras.GetUnitAuraBySpellID(unit, spellId, "HELPFUL|HARMFUL")
    local unitCache = auraCache[unit]
    if not unitCache then
        unitCache = {};
        auraCache[unit] = unitCache
    end

    local wasActive = unitCache[spellId] and unitCache[spellId].active
    local nowActive = aura and aura.expirationTime and aura.expirationTime > G_Time()

    unitCache[spellId] = {
        active = nowActive,
        expTime = aura and aura.expirationTime or 0
    }

    if wasActive ~= nowActive then
        UpdateIconUI(unit, spellId, config, nowActive)
    end
end

function Ether:UpdateUnitAuras(unit)
    if not UnitExists(unit) then
        return
    end

    local config = Ether.DB[1003]
    if not next(config) then
        return
    end

    for spellId, auraConfig in pairs(config) do
        if auraConfig.enabled then
            UpdateSingleAura(unit, spellId, auraConfig)
        end
    end
end

local raidAurasAdded = {}
local raidDispel = {}
local raidDebuffAdded = {}

function Ether:RaidAuraCleanUp(unit)
        if not UnitExists(unit) then return end
    local button = Ether.unitButtons.raid[unit]
    if not button then
        return
    end
    if auraCache[unit] then
        auraCache[unit] = nil
    end
    local config = Ether.DB[1003]
    for spellId in pairs(config) do
        if raidIcons[spellId] then
            raidIcons[spellId]:Hide()
            raidIcons[spellId]:ClearAllPoints()
            raidIcons[spellId] = nil
        end
    end

    if button.top then
        button.top:SetColorTexture(0, 0, 0, .6)
        button.right:SetColorTexture(0, 0, 0, .6)
        button.left:SetColorTexture(0, 0, 0, .6)
        button.bottom:SetColorTexture(0, 0, 0, .6)
    end
end

function Ether:DispelAuraScan(unit)
    if not Ether.unitButtons.raid[unit] or not UnitExists(unit) then return end


    local dispel, priority = nil, 0
    local index = 1
    local hasDispelDebuff = false

    while true do
        local aura = GetDebuffDataByIndex(unit, index)
        if not aura then
            break
        end
        if dispelByPlayer[aura.dispelName] then
            local sort = dispelPriority[aura.dispelName] or 0
            if sort > priority then
                priority = sort
                dispel = aura.dispelName
            end
            if dispelColors[aura.dispelName] then
                local button = Ether.unitButtons.raid[unit]
                hasDispelDebuff = true
                local c = dispelColors[aura.dispelName]
                button.top:SetColorTexture(unpack(c))
                button.right:SetColorTexture(unpack(c))
                button.left:SetColorTexture(unpack(c))
                button.bottom:SetColorTexture(unpack(c))
            end
        end
        index = index + 1
    end
    if not hasDispelDebuff then
        local button = Ether.unitButtons.raid[unit]
        button.top:SetColorTexture(0, 0, 0, .6)
        button.right:SetColorTexture(0, 0, 0, .6)
        button.left:SetColorTexture(0, 0, 0, .6)
        button.bottom:SetColorTexture(0, 0, 0, .6)
    end
end

local function raidAuraUpdate(unit, updateInfo)
    if not Ether.unitButtons.raid[unit] or not UnitExists(unit) then return end
    local config = Ether.DB[1003]
    local auraAdded, auraDispel
    if updateInfo.addedAuras then
        for _, aura in next, updateInfo.addedAuras do
            if aura.isHelpful and config[aura.spellId] then
                auraAdded = true
                raidAurasAdded[aura.auraInstanceID] = aura
            end
            if aura.isHarmful and dispelByPlayer[aura.dispelName] then
                auraDispel = true
                raidDispel[aura.auraInstanceID] = aura
            end
        end
    end
    if updateInfo.removedAuraInstanceIDs then
        for _, auraInstanceID in next, updateInfo.removedAuraInstanceIDs do
            if raidDispel[auraInstanceID] then
                auraDispel = true
                raidDispel[auraInstanceID] = nil
            end
            if raidAurasAdded[auraInstanceID] then
                auraAdded = true
                raidAurasAdded[auraInstanceID] = nil
            end
        end
    end
    if auraAdded then
        Ether:UpdateUnitAuras(unit)
    end
    if auraDispel then
        Ether:DispelAuraScan(unit)
    end
end

local function CheckCount(self, count)
    if count and count > 1 then
        self.count:SetText(count)
        self.count:Show()
    else
        self.count:Hide()
    end
end

local function CheckDuration(self, duration, expirationTime)
    if duration and duration > 0 and expirationTime and expirationTime > 0 then
        local startTime = expirationTime - duration
        self.timer:SetCooldown(startTime, duration)
        self.timer:Show()
    else
        self.timer:Hide()
    end
end

local function CheckDispelType(self, dispelName)
    local color = dispelColors[dispelName]
    if color then
        self:SetColorTexture(unpack(color))
        self:Show()
    else
        self:Hide()
    end
end

local function AuraPosition(i)
    local row = math_floor((i - 1) / 8)
    local col = (i - 1) % 8
    local xOffset = col * (14 + 1)
    local yOffset = 1 + row * (14 + 1)

    return xOffset, yOffset
end

local GetUnitAuras = C_UnitAuras.GetUnitAuras

function Ether:SingleAuraUpdateBuff(button)
    if not button or not button.unit or not button.Aura then
        return
    end

    local unit = button.unit
    local auras = button.Aura

    local visibleBuffCount = 0

    local allAuras = GetUnitAuras(unit, "HELPFUL")

    if allAuras and #allAuras > 0 then
        local buffIndex = 1

        for i, aura in ipairs(allAuras) do
            if buffIndex > 16 then
                break
            end

            local now = auras.Buffs[buffIndex]
            if now then
                local last = auras.LastBuffs[buffIndex] or {}

                if last.auraInstanceID ~= aura.auraInstanceID or
                        last.name ~= aura.name or
                        last.icon ~= aura.icon then

                    now.icon:SetTexture(aura.icon)
                    now.icon:Show()

                    last.auraInstanceID = aura.auraInstanceID
                    last.name = aura.name
                    last.icon = aura.icon
                    last.spellId = aura.spellId
                    auras.LastBuffs[buffIndex] = last
                end

                if CheckCount then
                    CheckCount(now, aura.applications or 0)
                end

                if CheckDuration then
                    CheckDuration(now, aura.duration or 0, aura.expirationTime or 0)
                end

                local xOffset, yOffset = AuraPosition(buffIndex)
                now:ClearAllPoints()
                now:SetPoint("BOTTOMLEFT", button, "TOPLEFT", xOffset - 1, yOffset + 2)

                now:Show()
                visibleBuffCount = visibleBuffCount + 1
                buffIndex = buffIndex + 1
            end
        end
    end

    for i = visibleBuffCount + 1, 16 do
        local now = auras.Buffs[i]
        if now then
            now:Hide()
        end
        auras.LastBuffs[i] = nil
    end

    auras.visibleBuffCount = visibleBuffCount
end

function Ether:SingleAuraUpdateDebuff(button)
    if not button or not button.unit or not button.Aura then
        return
    end

    local unit = button.unit
    local auras = button.Aura

    local visibleBuffCount = auras.visibleBuffCount or 0
    local visibleDebuffCount = 0

    local buffRows = math_ceil(visibleBuffCount / 8)
    local startY = buffRows * (14 + 1) + 2

    local allAuras = GetUnitAuras(unit, "HARMFUL")

    if allAuras and #allAuras > 0 then
        local debuffIndex = 1

        for i, aura in ipairs(allAuras) do
            if debuffIndex > 16 then
                break
            end

            local now = auras.Debuffs[debuffIndex]
            if now then

                local row = math_floor((debuffIndex - 1) / 8)
                local col = (debuffIndex - 1) % 8
                local yOffset = startY + row * (14 + 1)

                now:ClearAllPoints()
                now:SetPoint('BOTTOMLEFT', button, 'TOPLEFT', col * (14 + 1) - 1, yOffset + 2)

                local last = auras.LastDebuffs[debuffIndex] or {}

                if last.auraInstanceID ~= aura.auraInstanceID then
                    now.icon:SetTexture(aura.icon)
                    now.icon:Show()

                    if CheckDispelType and now.border then
                        CheckDispelType(now.border, aura.dispelName)
                    elseif now.border then
                        now.border:Show()
                    end

                    last.auraInstanceID = aura.auraInstanceID
                    last.name = aura.name
                    last.icon = aura.icon
                    last.dispelName = aura.dispelName
                    auras.LastDebuffs[debuffIndex] = last
                end

                if CheckCount then
                    CheckCount(now, aura.applications or 0)
                end
                if CheckDuration then
                    CheckDuration(now, aura.duration or 0, aura.expirationTime or 0)
                end

                now:Show()
                visibleDebuffCount = visibleDebuffCount + 1
                debuffIndex = debuffIndex + 1
            end
        end

    end

    for i = visibleDebuffCount + 1, 16 do
        local now = auras.Debuffs[i]
        if now then
            now:Hide()
        end
        auras.LastDebuffs[i] = nil
    end
end

function Ether:SingleAuraFullInitial(self)
    Ether.Setup.SingleAuraSetup(self)
    Ether:SingleAuraUpdateBuff(self)
    Ether:SingleAuraUpdateDebuff(self)
end

local playerBuffs = {}
local playerDebuffs = {}

local function auraUpdatePlayer(unit, info)
    local button = Ether.unitButtons.solo[unit]
    if not button or not button.unit or not button.Aura then
        return
    end

    local needsBuffUpdate = false
    local needsDebuffUpdate = false
    if info.addedAuras then
        for _, aura in ipairs(info.addedAuras) do
            if aura.isHelpful then
                needsBuffUpdate = true
            end
            if aura.isHarmful then
                needsDebuffUpdate = true
            end
        end
    end
    if info.removedAuraInstanceIDs then
        needsBuffUpdate = true
        needsDebuffUpdate = true
    end
    if info.updatedAuraInstanceIDs then
        needsBuffUpdate = true
        needsDebuffUpdate = true
    end
    if needsBuffUpdate then
        Ether:SingleAuraUpdateBuff(button)
    end
    if needsDebuffUpdate then
        Ether:SingleAuraUpdateDebuff(button)
    end
end

local targetBuffs = {}
local targetDebuffs = {}

local function auraUpdateTarget(unit, info)
    local button = Ether.unitButtons.solo[unit]
    if not button or not button.unit or not button.Aura then
        return
    end

    local needsBuffUpdate = false
    local needsDebuffUpdate = false
    if info.addedAuras then
        for _, aura in ipairs(info.addedAuras) do
            if aura.isHelpful then
                needsBuffUpdate = true
            end
            if aura.isHarmful then
                needsDebuffUpdate = true
            end
        end
    end
    if info.removedAuraInstanceIDs then
        needsBuffUpdate = true
        needsDebuffUpdate = true
    end
    if info.updatedAuraInstanceIDs then
        needsBuffUpdate = true
        needsDebuffUpdate = true
    end
    if needsBuffUpdate then
        Ether:SingleAuraUpdateBuff(button)
    end
    if needsDebuffUpdate then
        Ether:SingleAuraUpdateDebuff(button)
    end
end

local InitializeAuras, DisableAuras
do
    local frame
    function InitializeAuras()
        if not frame then
            frame = CreateFrame("Frame")
            frame:SetScript("OnEvent", function(_, event, arg1, ...)
                if event == "UNIT_AURA" then
                    if Ether.DB[1001][3] == 1 then
                        raidAuraUpdate(arg1, ...)
                    end
                    if Ether.DB[1001][1] == 1 then
                        if arg1 == "player" then
                            auraUpdatePlayer(arg1, ...)
                        end
                    end
                    if Ether.DB[1001][2] == 1 then
                        if arg1 == "target" then
                            auraUpdateTarget(arg1, ...)
                        end
                    end
                end
            end)
        end
        if not frame:IsEventRegistered("UNIT_AURA") then
            frame:RegisterEvent("UNIT_AURA")
        end
    end
    function DisableAuras()
        if frame then
            frame:UnregisterAllEvents()
        end
    end
end

local function AuraWipe()
    wipe(playerBuffs)
    wipe(playerDebuffs)
    wipe(targetBuffs)
    wipe(targetDebuffs)
    wipe(raidAurasAdded)
    wipe(raidDispel)
    wipe(raidDebuffAdded)
    wipe(auraCache)
end

function Ether:AuraEnable()
    InitializeAuras()
end

function Ether:AuraDisable()
    DisableAuras()
end

