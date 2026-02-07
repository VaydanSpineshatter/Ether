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

local raidAurasHelpful = {}
local raidAurasHarmful = {}
local raidAurasDispel = {}
local raidBuffData = {}
local raidDebuffData = {}
local getUnitBuffs = {}
local getUnitDebuffs = {}
local dispelCache = {}


function Ether:CleanupTimerCache()
    local currentTime = GetTime()
    for guid, data in pairs(dispelCache) do
        if (currentTime - data.timestamp) > 5 then
            dispelCache[guid] = nil
        end
    end
end

local function updateAuraPos(tbl, spellId, spellConfig)
    for guid, _ in pairs(tbl) do
        if tbl[guid] and tbl[guid][spellId] then
            tbl[guid][spellId]:Hide()
            tbl[guid][spellId]:ClearAllPoints()
            tbl[guid][spellId]:SetColorTexture(unpack(spellConfig.color))
            tbl[guid][spellId]:SetSize(spellConfig.size, spellConfig.size)
            tbl[guid][spellId]:SetPoint(spellConfig.position, spellConfig.offsetX, spellConfig.offsetY)
        end
    end
end

function Ether.SaveAuraPos(spellId, debuff)
    local spellConfig = Ether.DB[1003][spellId]
    if not spellConfig then return end
    if debuff then
        updateAuraPos(raidDebuffData, spellId, spellConfig)
    else
        updateAuraPos(raidBuffData, spellId, spellConfig)
    end
end

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
        local auraData = GetDebuffDataByIndex(unit, index)
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
    if cached and (GetTime() - cached.timestamp) < 2 then
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
    if not raidBuffData[guid] then
        raidBuffData[guid] = {}
    end

    local index = 1
    while true do
        local auraData = GetBuffDataByIndex(unit, index)
        if not auraData then break end
        if auraData.spellId and config[auraData.spellId] then
            local spellConfig = config[auraData.spellId]
            if not raidBuffData[guid][auraData.spellId] then
                local texture = button.healthBar:CreateTexture(nil, "OVERLAY")
                texture:SetColorTexture(unpack(spellConfig.color))
                texture:SetSize(spellConfig.size, spellConfig.size)
                texture:SetPoint(spellConfig.position, spellConfig.offsetX, spellConfig.offsetY)
                raidBuffData[guid][auraData.spellId] = texture
            end
            raidBuffData[guid][auraData.spellId]:Show()
        end
        index = index + 1
    end
end

function Ether:UpdateRaidIsHarmful(unit)
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

    if not raidDebuffData[guid] then
        raidDebuffData[guid] = {}
    end

    local index = 1
    while true do
        local auraData = GetDebuffDataByIndex(unit, index)
        if not auraData then break end
        if auraData.spellId and config[auraData.spellId] then
            local spellConfig = config[auraData.spellId]
            if not raidDebuffData[guid][auraData.spellId] then
                local texture = button.healthBar:CreateTexture(nil, "OVERLAY")
                texture:SetColorTexture(unpack(spellConfig.color))
                texture:SetSize(spellConfig.size, spellConfig.size)
                texture:SetPoint(spellConfig.position, spellConfig.offsetX, spellConfig.offsetY)
                raidDebuffData[guid][auraData.spellId] = texture
            end
            raidDebuffData[guid][auraData.spellId]:Show()
        end
        index = index + 1
    end
end


function Ether:CleanupAuras(guid, unit)
    if raidBuffData[guid] then
        for _, texture in pairs(raidBuffData[guid]) do
            texture:Hide()
            texture:ClearAllPoints()
            texture:SetParent(nil)
        end
        raidBuffData[guid] = nil
    end

    if raidDebuffData[guid] then
        for _, texture in pairs(raidDebuffData[guid]) do
            texture:Hide()
            texture:ClearAllPoints()
            texture:SetParent(nil)
        end
        raidDebuffData[guid] = nil
    end

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
    for guid, _ in pairs(raidBuffData) do
        Ether:CleanupAuras(guid)
    end
    for guid, _ in pairs(raidDebuffData) do
        Ether:CleanupAuras(guid)
    end
    Ether:CleanupTimerCache()
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


local function UpdateAddedHelpfulAuras(unit)
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

    if not raidBuffData[guid] then
        raidBuffData[guid] = {}
    end

    for _, auraData in pairs(raidAurasHelpful) do
        if not auraData then break end
        if auraData.spellId and config[auraData.spellId] then
            local spellConfig = config[auraData.spellId]
            if not raidBuffData[guid][auraData.spellId] then
                local texture = button.healthBar:CreateTexture(nil, "OVERLAY")
                texture:SetColorTexture(unpack(spellConfig.color))
                texture:SetSize(spellConfig.size, spellConfig.size)
                texture:SetPoint(spellConfig.position, spellConfig.offsetX, spellConfig.offsetY)
                raidBuffData[guid][auraData.spellId] = texture
            end
            raidBuffData[guid][auraData.spellId]:Show()
        end
    end
end

local function UpdateAddedHarmfulAuras(unit)
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

    if not raidDebuffData[guid] then
        raidDebuffData[guid] = {}
    end

    for _, auraData in pairs(raidAurasHarmful) do
        if not auraData then break end
        if auraData.spellId and config[auraData.spellId] then
            local spellConfig = config[auraData.spellId]
            if not raidDebuffData[guid][auraData.spellId] then
                local texture = button.healthBar:CreateTexture(nil, "OVERLAY")
                texture:SetColorTexture(unpack(spellConfig.color))
                texture:SetSize(spellConfig.size, spellConfig.size)
                texture:SetPoint(spellConfig.position, spellConfig.offsetX, spellConfig.offsetY)
                raidDebuffData[guid][auraData.spellId] = texture
            end
            raidDebuffData[guid][auraData.spellId]:Show()
        end
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
    local buffAdded, debuffAdded, dispelAdded = false, false

    if updateInfo.addedAuras then
        for _, aura in ipairs(updateInfo.addedAuras) do
            if aura.isHelpful and config[aura.spellId] and not config[aura.spellId].isDebuff then
                buffAdded = true
                raidAurasHelpful[aura.auraInstanceID] = {
                    spellId = aura.spellId,
                    guid = guid
                }
            end
            if aura.isHarmful and dispelByPlayer[aura.dispelName] then
                dispelAdded = true
                raidAurasDispel[aura.auraInstanceID] = aura
            end
            if aura.isHarmful and config[aura.spellId] and config[aura.spellId].isDebuff then
                debuffAdded = true
                raidAurasHarmful[aura.auraInstanceID] = {
                    spellId = aura.spellId,
                    guid = guid
                }
            end
        end
    end

    if updateInfo.removedAuraInstanceIDs then
        for _, auraInstanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
            if raidAurasDispel[auraInstanceID] then
                dispelAdded = true
                raidAurasDispel[auraInstanceID] = nil
            end
            if raidAurasHarmful[auraInstanceID] then
                local auraData = raidAurasHarmful[auraInstanceID]
                local auraGuid = auraData.guid
                local spellId = auraData.spellId
                if raidDebuffData[auraGuid] and raidDebuffData[auraGuid][spellId] then
                    raidDebuffData[auraGuid][spellId]:Hide()
                end
                raidAurasHarmful[auraInstanceID] = nil
            end
            if raidAurasHelpful[auraInstanceID] then
                local auraData = raidAurasHelpful[auraInstanceID]
                local auraGuid = auraData.guid
                local spellId = auraData.spellId
                if raidBuffData[auraGuid] and raidBuffData[auraGuid][spellId] then
                    raidBuffData[auraGuid][spellId]:Hide()
                end
                raidAurasHelpful[auraInstanceID] = nil
            end
        end
    end

    if buffAdded then
        UpdateAddedHelpfulAuras(unit)
    end

    if debuffAdded then
        UpdateAddedHarmfulAuras(unit)
    end

    if dispelAdded then
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

                if last.auraInstanceID ~= aura.auraInstanceID or last.name ~= aura.name or last.icon ~= aura.icon then
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
                now:SetPoint("BOTTOMLEFT", button, "TOPLEFT", xOffset - 1, yOffset + 3)

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

local function Aura(_, event, arg1, ...)
    if event == "UNIT_AURA" then
        if not UnitExists(arg1) then return end
        local updateInfo = ...
        if updateInfo then
            raidAuraUpdate(arg1, updateInfo)
            soloAuraUpdate(arg1, updateInfo)
        end
    end
end

local update
if not update then
    update = CreateFrame("Frame")
end

function Ether:AuraWipe()
    wipe(getUnitBuffs)
    wipe(getUnitDebuffs)
    wipe(raidAurasHelpful)
    wipe(raidAurasHarmful)
    wipe(raidAurasDispel)
    wipe(raidBuffData)
    wipe(raidDebuffData)
    wipe(dispelCache)
end

function Ether:AuraEnable()
    if not update:GetScript("OnEvent") then
        update:RegisterEvent("UNIT_AURA")
        update:SetScript("OnEvent", Aura)
    end
    if Ether.DB[1001][4] == 1 then
        C_Timer.After(0.1, function()
            for unit in pairs(Ether.unitButtons.raid) do
                if UnitExists(unit) then
                    Ether:UpdateRaidIsHelpful(unit)
                    Ether:UpdateRaidIsHarmful(unit)
                end
            end
        end)
    end
end

function Ether:AuraDisable()
    Ether:CleanupAllRaidIcons()
    if update:GetScript("OnEvent") then
        update:UnregisterAllEvents()
        update:SetScript("OnEvent", nil)
    end
    Ether:AuraWipe()
end