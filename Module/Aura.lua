local _, Ether = ...
local Aura = {}
Ether.Aura = Aura
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

local function GetRaidAuraTexture(unit, spellId)
    local button = Ether.unitButtons.raid[unit]
    if not button then
        return
    end
    if not button.raidAuras then
        button.raidAuras = {}
    end
    if not button.raidAuras[spellId] then
        local tex = button.healthBar:CreateTexture(nil, "OVERLAY")
        button.raidAuras[spellId] = tex
    end
    return button.raidAuras[spellId]
end

local function UpdateIconUI(unit, spellId, config, active)
    local tex = GetRaidAuraTexture(unit, spellId)
    if not tex then
        return
    end
    if active then
        tex:Show()
        tex:SetColorTexture(unpack(config.color))
        tex:SetSize(config.size, config.size)
        tex:SetPoint(config.position, Ether.unitButtons.raid[unit], config.position, config.offsetX, config.offsetY)
    else
        tex:Hide()
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

function Aura.UpdateUnitAuras(unit)
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

function Aura.RaidAuraClearUp(unit)
    local button = Ether.unitButtons.raid[unit]
    if not button then
        return
    end
    if auraCache[unit] then
        auraCache[unit] = nil
    end

    local config = Ether.DB[1003]
    for spellId, auraConfig in pairs(config) do
        if button.raidAuras[spellId] then
            button.raidAuras[spellId]:Hide()
        end
    end
    button.top:SetColorTexture(0, 0, 0, .6)
    button.right:SetColorTexture(0, 0, 0, .6)
    button.left:SetColorTexture(0, 0, 0, .6)
    button.bottom:SetColorTexture(0, 0, 0, .6)
end

function Aura.DispelAuraScan(unit)
    if not UnitExists(unit) then
        return
    end

    local button = Ether.unitButtons.raid[unit]
    if not button then
        return
    end

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
        button.top:SetColorTexture(0, 0, 0, .6)
        button.right:SetColorTexture(0, 0, 0, .6)
        button.left:SetColorTexture(0, 0, 0, .6)
        button.bottom:SetColorTexture(0, 0, 0, .6)
    end
end

function Aura.UpdateRaidAuras(unit)
    if not UnitExists(unit) then
        return
    end

    local config = Ether.DB[1003]
    if not config or not next(config) then
        return
    end

    local currentAuras = {}
    local index = 1

    while true do
        local aura = GetBuffDataByIndex(unit, index)
        if not aura then
            break
        end

        if aura.spellId and config[aura.spellId] then
            currentAuras[aura.spellId] = true
            UpdateIconUI(unit, aura.spellId, config[aura.spellId], true)
        end
        index = index + 1
    end

    if auraCache[unit] then
        for spellId, _ in pairs(auraCache[unit]) do
            if not currentAuras[spellId] then
                UpdateIconUI(unit, spellId, config[spellId], false)
            end
        end
    end

    auraCache[unit] = currentAuras
end

local function raidAuraUpdate(unit, info)
    if not UnitExists(unit) then
        return
    end
    local config = Ether.DB[1003]
    if not Ether.unitButtons.raid[unit] then
        return
    end
    if info.isFullUpdate then
        Aura.DispelAuraScan(unit)
        Aura.UpdateRaidAuras(unit)
        return
    end

    local auraAdded, auraDispel
    if info.addedAuras then
        for _, aura in ipairs(info.addedAuras) do
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
    if info.removedAuraInstanceIDs then
        for _, auraInstanceID in ipairs(info.removedAuraInstanceIDs) do
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
    if auraDispel then
        Aura.DispelAuraScan(unit)
    end
    if auraAdded then
        Aura.UpdateRaidAuras(unit)
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

local function CleanUp(self)
    self:Hide()
    if self.icon then
        self.icon:Hide()
    end
    if self.border then
        self.border:Hide()
    end
    if self.count then
        self.count:Hide()
    end
    if self.timer then
        self.timer:Hide()
    end
end

Aura.SingleAuraUpdateBuff = function(button)
    if (not button or not button.unit or not button.Aura) then
        return
    end

    local visibleBuffCount = 0
    for index = 1, 24 do
        local name, icon, count, _, duration, expirationTime = UnitAura(button.unit, index, "HELPFUL")

        local last = button.Aura.LastBuffs[index]
        local now = button.Aura.Buffs[index]

        if now and name and icon then
            if not last or last.name ~= name or last.icon ~= icon then

                now.icon:SetTexture(icon)
                now.icon:Show()

                last = last or {}
                last.name = name
                last.icon = icon
                button.Aura.LastBuffs[index] = last
            end
            now:Show()

            CheckCount(now, count)
            CheckDuration(now, duration, expirationTime)
            visibleBuffCount = visibleBuffCount + 1
        elseif now then
            CleanUp(now)
            button.Aura.LastBuffs[index] = nil
        end
    end
    button.Aura.visibleBuffCount = visibleBuffCount
end

Aura.SingleAuraUpdateDebuff = function(button)
    if (not button or not button.unit or not button.Aura) then
        return
    end

    local visibleBuffCount = button.Aura.visibleBuffCount or 0
    local buffRows = math_ceil(visibleBuffCount / 8)
    local startY = buffRows * (14 + 1) + 2

    for index = 1, 24 do
        local name, icon, count, dispelName, duration, expirationTime = UnitAura(button.unit, index, "HARMFUL")
        local last = button.Aura.LastDebuffs[index]
        local now = button.Aura.Debuffs[index]

        if now and name and icon then
            local row = math_floor((index - 1) / 8)
            local col = (index - 1) % 8
            local yOffset = startY + row * (14 + 1)

            now:ClearAllPoints()
            now:SetPoint('BOTTOMLEFT', button, 'TOPLEFT', col * (14 + 1) - 1, yOffset + 2)
            now:Show()

            if not last or last.name ~= name or last.icon ~= icon or last.dispelName ~= dispelName then

                now.icon:SetTexture(icon)
                now.icon:Show()

                CheckDispelType(now.border, dispelName)

                last = last or {}
                last.name = name
                last.icon = icon
                last.dispelName = dispelName
                button.Aura.LastDebuffs[index] = last
            end

            CheckCount(now, count)
            CheckDuration(now, duration, expirationTime)

        elseif now then
            CleanUp(now)
            button.Aura.LastDebuffs[index] = nil
        end
    end
end

Aura.SingleAuraFullInitial = function(self)
    Ether.Setup.SingleAuraSetup(self)
    Ether.Aura.SingleAuraUpdateBuff(self)
    Ether.Aura.SingleAuraUpdateDebuff(self)
end

local playerBuffs = {}
local playerDebuffs = {}

local function auraUpdatePlayer(unit, info)
    if not unit == "player" then
        return
    end
    local button = Ether.unitButtons.solo[unit]
    if info.addedAuras then
        for _, aura in ipairs(info.addedAuras) do
            if aura.isHelpful then
                Aura.SingleAuraUpdateBuff(button)
                playerBuffs[aura.auraInstanceID] = aura
            end
            if aura.isHarmful then
                Aura.SingleAuraUpdateDebuff(button)
                playerDebuffs[aura.auraInstanceID] = aura
            end
        end
    end
    if info.removedAuraInstanceIDs then
        for _, auraInstanceID in ipairs(info.removedAuraInstanceIDs) do
            if playerBuffs[auraInstanceID] then
                Aura.SingleAuraUpdateBuff(button)
                playerBuffs[auraInstanceID] = nil
            end
            if playerDebuffs[auraInstanceID] then
                Aura.SingleAuraUpdateDebuff(button)
                playerDebuffs[auraInstanceID] = nil
            end
        end
    end
end

local targetBuffs = {}
local targetDebuffs = {}

local function auraUpdateTarget(unit, info)
    if not UnitExists("target") then
        return
    end
    local button = Ether.unitButtons.solo["target"]
    if info.addedAuras then
        for _, aura in ipairs(info.addedAuras) do
            if aura.isHelpful then
                Aura.SingleAuraUpdateBuff(button)
                targetBuffs[aura.auraInstanceID] = aura
            end
            if aura.isHarmful then
                Aura.SingleAuraUpdateDebuff(button)
                targetDebuffs[aura.auraInstanceID] = aura
            end
        end
    end
    if info.removedAuraInstanceIDs then
        for _, auraInstanceID in ipairs(info.removedAuraInstanceIDs) do
            if targetBuffs[auraInstanceID] then
                Aura.SingleAuraUpdateBuff(button)
                targetBuffs[auraInstanceID] = nil
            end
            if targetDebuffs[auraInstanceID] then
                Aura.SingleAuraUpdateDebuff(button)
                targetDebuffs[auraInstanceID] = nil
            end
        end
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
                        auraUpdatePlayer(arg1, ...)
                    end
                    if Ether.DB[1001][2] == 1 then
                        auraUpdateTarget(arg1, ...)
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
end

function Aura:Enable()
    InitializeAuras()
end

function Aura:Disable()
    DisableAuras()
    AuraWipe()
end

