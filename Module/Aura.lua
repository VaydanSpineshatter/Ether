local _, Ether = ...
local math_floor = math.floor
local math_ceil = math.ceil
local pairs, ipairs = pairs, ipairs
local GetBuffDataByIndex = C_UnitAuras.GetBuffDataByIndex
local GetDebuffDataByIndex = C_UnitAuras.GetDebuffDataByIndex
local GetUnitAuras = C_UnitAuras.GetUnitAuras
local UnitGUID = UnitGUID
local UnitExists = UnitExists
local GetTime = GetTime
local unpack = unpack

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

local _, classFilename = UnitClass("player")
local dispelByPlayer = {}
dispelByPlayer = dispelClass[classFilename]

local raidIcons = {}
local raidAurasAdded = {}
local raidDispel = {}
local raidDebuffAdded = {}
local foundSpells = {}
local dispelCache = {}

local function CleanupTimerCache()
    local currentTime = GetTime()
    for guid, data in pairs(dispelCache) do
        if (currentTime - data.timestamp) > 5 then
            dispelCache[guid] = nil
        end
    end
end

--local cleanupTimer = C_Timer.NewTicker(10, function()
--    CleanupTimerCache()
--end)


function Ether.SaveAuraPos(spellId)
    local spellConfig = Ether.DB[1003][spellId]
    if not spellConfig then return end
    for guid, _ in pairs(raidIcons) do
        if raidIcons[guid] and raidIcons[guid][spellId] then
            raidIcons[guid][spellId].IsActive = raidIcons[guid][spellId]:IsShown()
            raidIcons[guid][spellId]:Hide()
            raidIcons[guid][spellId]:ClearAllPoints()
            raidIcons[guid][spellId]:SetColorTexture(unpack(spellConfig.color))
            raidIcons[guid][spellId]:SetSize(spellConfig.size, spellConfig.size)
            raidIcons[guid][spellId]:SetPoint(spellConfig.position, spellConfig.offsetX, spellConfig.offsetY)
            if raidIcons[guid][spellId].IsActive then
                raidIcons[guid][spellId]:Show()
                raidIcons[guid][spellId].IsActive = nil
            end
        end
    end
end

--[[
local function AuraScanDispel(unit)
    if not Ether.unitButtons.raid[unit] or not UnitExists(unit) then
        return
    end
    local dispel, priority = nil, 0
    local index = 1
    local hasDispelDebuff = false
    local guid = UnitGUID(unit)
    if not guid then
        return
    end

    while true do
        local auraData = GetDebuffDataByIndex(unit, index)
        if not auraData then break end
        if dispelByPlayer[auraData.dispelName] then
            local sort = dispelPriority[auraData.dispelName] or 0
            if sort > priority then
                priority = sort
                dispel = auraData.dispelName
            end
            if dispelColors[auraData.dispelName] then
                local button = Ether.unitButtons.raid[unit]
                hasDispelDebuff = true
                local c = dispelColors[auraData.dispelName]
                button.top:SetColorTexture(unpack(c))
                button.right:SetColorTexture(unpack(c))
                button.left:SetColorTexture(unpack(c))
                button.bottom:SetColorTexture(unpack(c))
                if not auraData.icon then return end
                button.dispelIcon:SetTexture(auraData.icon)
                button.dispelBorder:SetColorTexture(unpack(c))
                Ether.StartBlink(button.iconFrame, auraData.duration, 0.3)
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
        Ether.StopBlink(button.iconFrame)
    end
end
]]
local function ScanUnitAuras(unit)
    if not UnitExists(unit) then
        return nil, {}
    end
    local dispel
    if dispel then
        dispel = nil
    end
    local priority = 0
    local index = 1
    while true do
        local auraData = GetDebuffDataByIndex(unit, index, "RAID")
        if not auraData then break end
        if auraData.dispelName and dispelByPlayer[auraData.dispelName] then
            local order = dispelPriority[auraData.dispelName] or 0
            if order > priority then
                priority = order
                dispel = {
                    name = auraData.name,
                    icon = auraData.icon,
                    dispelName = auraData.dispelName,
                    duration = auraData.duration,
                    spellId = auraData.spellId,
                    index = index
                }
            end
        end
        index = index + 1
    end
    return dispel
end

local function GetCachedDispel(unit)
    local guid = UnitGUID(unit)
    if not guid then return nil end

    local cached = dispelCache[guid]
    if cached and (GetTime() - cached.timestamp) < 3 then
        return cached.dispel
    end

    local dispel = ScanUnitAuras(unit)
    dispelCache[guid] = {
        dispel = dispel,
        timestamp = GetTime()
    }

    return dispel
end

local function borderColor(button, color)
    button.top:SetColorTexture(color[1], color[2], color[3], 1)
    button.right:SetColorTexture(color[1], color[2], color[3], 1)
    button.left:SetColorTexture(color[1], color[2], color[3], 1)
    button.bottom:SetColorTexture(color[1], color[2], color[3], 1)
end

local function FindUnitButton(unit)
    local button = Ether.unitButtons.raid[unit]
    if button and button.unit == unit then
        return button
    end
    return nil
end

function Ether:CleanupAuras(guid, unit)
    if not raidIcons[guid] then
        return
    end

    for _, texture in pairs(raidIcons[guid]) do
        texture:Hide()
        texture:ClearAllPoints()
        texture:SetParent(nil)
    end

    raidIcons[guid] = nil
    foundSpells[guid] = nil

    local button = FindUnitButton(unit)
    if not button then return end
    if button.top then
        local color = {0, 0, 0}
        borderColor(button, color)
    end
    if button.iconFrame then
        Ether.StopBlink(button.iconFrame)
    end
end

function Ether:CleanupAllRaidIcons()
    for guid, _ in pairs(raidIcons) do
        Ether:CleanupAuras(guid)
    end
    CleanupTimerCache()
end

local function UpdateButtonDispel(button)
    if not button or not button.unit then return end

    local dispel = GetCachedDispel(button.unit)

    if dispel and button.dispelIcon then
        if button.top then
            local colors = {
                ["Magic"] = {0.2, 0.6, 1.0},
                ["Disease"] = {0.6, 0.4, 0.0},
                ["Curse"] = {0.6, 0.2, 1.0},
                ["Poison"] = {0.2, 1.0, 0.2}
            }
            local color = colors[dispel.dispelName] or {0, 0, 0}
            borderColor(button, color)
            button.dispelIcon:SetTexture(dispel.icon)
            button.dispelBorder:SetColorTexture(color[1], color[2], color[3], 1)
            Ether.StartBlink(button.iconFrame, dispel.duration, 0.3)
        end
        button.dispellableDebuff = dispel
    else
        if button.iconFrame then
            Ether.StopBlink(button.iconFrame)
        end
        if button.top then
            local color = {0, 0, 0}
            borderColor(button, color)
        end
        button.dispellableDebuff = nil
    end
end

local function OnAuraDispelAdded(unit)
    local guid = UnitGUID(unit)
    if guid then
        dispelCache[guid] = nil
    end
    local button = FindUnitButton(unit)
    if button then
        UpdateButtonDispel(button)
    end
end

function Ether:UpdateRaidIsHelpful(unit)
    if not UnitExists(unit) then
        return
    end
    local guid = UnitGUID(unit)
    if not guid then
        return
    end
    local button = FindUnitButton(unit)
    if not button then return end
    local config = Ether.DB[1003]

    if not raidIcons[guid] then
        raidIcons[guid] = {}
    end
    if not foundSpells[guid] then
        foundSpells[guid] = {}
    end
    wipe(foundSpells[guid])
    local index = 1
    while true do
        local auraData = GetBuffDataByIndex(unit, index)
        if not auraData then break end
        if auraData.spellId and config[auraData.spellId] then
            local spellConfig = config[auraData.spellId]
            if not raidIcons[guid][auraData.spellId] then
                local texture = button.healthBar:CreateTexture(nil, "OVERLAY")
                texture:SetColorTexture(unpack(spellConfig.color))
                texture:SetSize(spellConfig.size, spellConfig.size)
                texture:SetPoint(spellConfig.position, spellConfig.offsetX, spellConfig.offsetY)
                raidIcons[guid][auraData.spellId] = texture
            end
            raidIcons[guid][auraData.spellId]:Show()
            foundSpells[guid][auraData.spellId] = true
        end
        index = index + 1
    end
    for spellId, texture in pairs(raidIcons[guid]) do
        if not foundSpells[guid][spellId] then
            texture:Hide()
        end
    end
end

local function raidAuraUpdate(unit, updateInfo)
    if not Ether:IsValidUnitForAuras(unit) then return end
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
            if aura.isHelpful and config[aura.spellId] and not config.isDebuff then
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
        OnAuraDispelAdded(unit)
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

local function CheckDispelType(self, dispelName)
    local colors = {
        ["Magic"] = {0.2, 0.6, 1.0},
        ["Disease"] = {0.6, 0.4, 0.0},
        ["Curse"] = {0.6, 0.2, 1.0},
        ["Poison"] = {0.2, 1.0, 0.2}
    }
    local dispel = colors[dispelName]
    if dispel then
        self:SetColorTexture(unpack(dispel))
        self:Show()
    else
        self:Hide()
    end
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

function Ether:AuraWipe()
    wipe(soloBuffs)
    wipe(soloDebuffs)
    wipe(raidAurasAdded)
    wipe(raidDispel)
    wipe(raidDebuffAdded)
    wipe(dispelCache)
end

function Ether:AuraEnable()
    Ether:AuraWipe()
    InitializeAuras()
end

function Ether:AuraDisable()
    Ether:AuraWipe()
    DisableAuras()
end

