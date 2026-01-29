local _, Ether = ...
local math_floor = math.floor
local math_ceil = math.ceil
local pairs, ipairs = pairs, ipairs
local GetBuffDataByIndex = C_UnitAuras.GetBuffDataByIndex
local GetDebuffDataByIndex = C_UnitAuras.GetDebuffDataByIndex
local GetUnitAuras = C_UnitAuras.GetUnitAuras
local UnitGUID = UnitGUID
local UnitExists = UnitExists
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
local raidAurasAdded = {}
local raidDispel = {}
local raidDebuffAdded = {}
local foundSpells = {}

function Ether:CleanupIconsForGUID(guid)
    if not raidIcons[guid] then
        return
    end

    for spellId, texture in pairs(raidIcons[guid]) do
        texture:Hide()
        texture:ClearAllPoints()
        texture:SetParent(nil)
    end

    raidIcons[guid] = nil
    foundSpells[guid] = nil
end

function Ether:CleanupAllRaidIcons()
    for guid, _ in pairs(raidIcons) do
        Ether:CleanupIconsForGUID(guid)
    end
end

function Ether:UpdateRaidIsHelpful(unit)
    if not Ether.unitButtons.raid[unit] or not UnitExists(unit) then
        return
    end
    local guid = UnitGUID(unit)
    if not guid then
        return
    end
    local config = Ether.DB[1003]
    if not config then
        return
    end
    if not raidIcons[guid] then
        raidIcons[guid] = {}
    end
    if not foundSpells[guid] then
        foundSpells[guid] = {}
    end
    wipe(foundSpells[guid])
    local index = 1
    while true do
        local aura = GetBuffDataByIndex(unit, index)
        if not aura then
            break
        end
        if aura.spellId and config[aura.spellId] then
            local spellConfig = config[aura.spellId]
            if not raidIcons[guid][aura.spellId] then
                local texture = Ether.unitButtons.raid[unit].healthBar:CreateTexture(nil, "OVERLAY")
                texture:SetColorTexture(unpack(spellConfig.color))
                texture:SetSize(spellConfig.size, spellConfig.size)
                texture:SetPoint(spellConfig.position, spellConfig.offsetX, spellConfig.offsetY)
                raidIcons[guid][aura.spellId] = texture
            end
            raidIcons[guid][aura.spellId]:Show()
            foundSpells[guid][aura.spellId] = true
        end
        index = index + 1
    end
    for spellId, texture in pairs(raidIcons[guid]) do
        if not foundSpells[guid][spellId] then
            texture:Hide()
        end
    end
end

function Ether:DispelAuraScan(unit)
    if not Ether.unitButtons.raid[unit] or not UnitExists(unit) then
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
        button.top:SetColorTexture(0, 0, 0, 1)
        button.right:SetColorTexture(0, 0, 0, 1)
        button.left:SetColorTexture(0, 0, 0, 1)
        button.bottom:SetColorTexture(0, 0, 0, 1)
    end
end

local function raidAuraUpdate(unit, updateInfo)
    if not Ether.unitButtons.raid[unit] or Ether.DB[1001][4] ~= 1 then
        return
    end

    local guid = UnitGUID(unit)
    if not guid then
        return
    end

    local config = Ether.DB[1003]
    local auraAdded, auraDispel = false, false

    if updateInfo.addedAuras then
        for _, aura in ipairs(updateInfo.addedAuras) do
            if aura.isHelpful and config[aura.spellId] then
                auraAdded = true
                raidAurasAdded[aura.auraInstanceID] = {
                    spellId = aura.spellId,
                    guid = guid
                }
            end
            if aura.isHarmful and dispelByPlayer[aura.dispelName] then
                auraDispel = true
                raidDispel[aura.auraInstanceID] = aura
            end
        end
    end

    if updateInfo.removedAuraInstanceIDs then
        for _, auraInstanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
            if raidDispel[auraInstanceID] then
                auraDispel = true
                raidDispel[auraInstanceID] = nil
            end
            if raidAurasAdded[auraInstanceID] then
                local auraData = raidAurasAdded[auraInstanceID]
                local auraGuid = auraData.guid
                local spellId = auraData.spellId
                if raidIcons[auraGuid] and raidIcons[auraGuid][spellId] then
                    raidIcons[auraGuid][spellId]:Hide()
                end
                raidAurasAdded[auraInstanceID] = nil
            end
        end
    end

    if auraAdded then
        Ether:UpdateRaidIsHelpful(unit)
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
                now:SetPoint("BOTTOMLEFT", button, "TOPLEFT", col * (14 + 1) - 1, yOffset + 2)

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
    Ether:SingleAuraSetup(self)
    Ether:SingleAuraUpdateBuff(self)
    Ether:SingleAuraUpdateDebuff(self)
end

local soloBuffs = {}
local soloDebuffs = {}

local function soloAuraUpdate(unit, updateInfo)
    if not Ether.unitButtons.solo["player"] or not Ether.unitButtons.solo["target"] and not Ether.unitButtons.solo["pet"]:IsVisible() then
        return
    end
    local button = Ether.unitButtons.solo[unit]
    local needsBuffUpdate = false
    local needsDebuffUpdate = false
    if updateInfo.addedAuras then
        for _, aura in ipairs(updateInfo.addedAuras) do
            if aura.isHelpful then
                needsBuffUpdate = true
            end
            if aura.isHarmful then
                needsDebuffUpdate = true
            end
        end
    end
    if updateInfo.removedAuraInstanceIDs then
        needsBuffUpdate = true
        needsDebuffUpdate = true
    end
    if updateInfo.updatedAuraInstanceIDs then
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
                    if not arg1 or not UnitExists(arg1) then return end
                    local updateInfo = ...
                    if updateInfo then
                        raidAuraUpdate(arg1, updateInfo)
                        soloAuraUpdate(arg1, updateInfo)
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
    wipe(soloBuffs)
    wipe(soloDebuffs)
    wipe(raidAurasAdded)
    wipe(raidDispel)
    wipe(raidDebuffAdded)
end

function Ether:AuraEnable()
    InitializeAuras()
end

function Ether:AuraDisable()
    AuraWipe()
    DisableAuras()
end

