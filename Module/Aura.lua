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
local foundHelpful = {}
local foundHarmful = {}
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
        if tbl and tbl[guid] and tbl[guid][spellId] then
            tbl[guid][spellId].IsActive = tbl[guid][spellId]:IsShown()
            tbl[guid][spellId]:Hide()
            tbl[guid][spellId]:ClearAllPoints()
            tbl[guid][spellId]:SetColorTexture(unpack(spellConfig.color))
            tbl[guid][spellId]:SetSize(spellConfig.size, spellConfig.size)
            tbl[guid][spellId]:SetPoint(spellConfig.position, spellConfig.offsetX, spellConfig.offsetY)
            if tbl and tbl[guid] and tbl[guid][spellId] and tbl[guid][spellId].IsActive then
                tbl[guid][spellId]:Show()
                tbl[guid][spellId].IsActive = nil
            end
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
function Ether:UpdateRaidIsHelpful(unit, force)
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
    if not foundHelpful[guid] then
        foundHelpful[guid] = {}
    end
    wipe(foundHelpful[guid])
    local index = 1
    while true do
        local auraData = GetBuffDataByIndex(unit, index)
        if not auraData then break end
        if auraData.spellId and config[auraData.spellId] and not config[auraData.spellId].isDebuff then
            local spellConfig = config[auraData.spellId]
            if not raidBuffData[guid][auraData.spellId] then
                local texture = button.healthBar:CreateTexture(nil, "OVERLAY")
                texture:SetColorTexture(unpack(spellConfig.color))
                texture:SetSize(spellConfig.size, spellConfig.size)
                texture:SetPoint(spellConfig.position, spellConfig.offsetX, spellConfig.offsetY)
                raidBuffData[guid][auraData.spellId] = texture
                if force then
                    raidAurasHelpful[auraData.auraInstanceID] = {
                        spellId = auraData.spellId,
                        guid = guid
                    }
                end
            end
            raidBuffData[guid][auraData.spellId]:Show()
            foundHelpful[guid][auraData.spellId] = true
        end
        index = index + 1
    end
    for spellId, texture in pairs(raidBuffData[guid]) do
        if not foundHelpful[guid][spellId] then
            texture:Hide()
        end
    end
end

function Ether:UpdateRaidIsHarmful(unit, force)
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
    if not foundHarmful[guid] then
        foundHarmful[guid] = {}
    end
    wipe(foundHarmful[guid])
    local index = 1
    while true do
        local auraData = GetDebuffDataByIndex(unit, index)
        if not auraData then break end
        if auraData.spellId and config[auraData.spellId] and config[auraData.spellId].isDebuff then
            local spellConfig = config[auraData.spellId]
            if not raidDebuffData[guid][auraData.spellId] then
                local texture = button.healthBar:CreateTexture(nil, "OVERLAY")
                texture:SetColorTexture(unpack(spellConfig.color))
                texture:SetSize(spellConfig.size, spellConfig.size)
                texture:SetPoint(spellConfig.position, spellConfig.offsetX, spellConfig.offsetY)
                raidDebuffData[guid][auraData.spellId] = texture
                if force then
                    raidAurasHarmful[auraData.auraInstanceID] = {
                        spellId = auraData.spellId,
                        guid = guid
                    }
                end
            end
            raidDebuffData[guid][auraData.spellId]:Show()
            foundHarmful[guid][auraData.spellId] = true
        end
        index = index + 1
    end
    for spellId, texture in pairs(raidDebuffData[guid]) do
        if not foundHarmful[guid][spellId] then
            texture:Hide()
        end
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
        foundHelpful[guid] = nil
    end

    if raidDebuffData[guid] then
        for _, texture in pairs(raidDebuffData[guid]) do
            texture:Hide()
            texture:ClearAllPoints()
            texture:SetParent(nil)
        end
        raidDebuffData[guid] = nil
        foundHarmful[guid] = nil
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

function Ether:CleanupRaidIcons()
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

local function raidAuraUpdate(unit, updateInfo)
    if Ether.DB[1001][3] ~= 1 then return end
    if not Ether.unitButtons.raid[unit] then
        return
    end

    local guid = UnitGUID(unit)
    if not guid then
        return
    end

    local config = Ether.DB[1003]
    local buffAdded, debuffAdded, dispelAdded = false, false, false

    if updateInfo.addedAuras then
        for _, aura in ipairs(updateInfo.addedAuras) do
            if aura.isHelpful and config[aura.spellId] and config[aura.spellId].enabled and not config[aura.spellId].isDebuff then
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
            if aura.isHarmful and config[aura.spellId] and config[aura.spellId].enabled and config[aura.spellId].isDebuff then
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
        Ether:UpdateRaidIsHelpful(unit)
    end

    if debuffAdded then
        Ether:UpdateRaidIsHarmful(unit)
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

local function SoloAuraIsHelpful(unit)
    local button = Ether.unitButtons.solo[unit]
    if not button or not button.Aura then return end
    local visibleBuffCount = 0
    local allAuras = GetUnitAuras(unit, "HELPFUL")
    if not allAuras then return end
    for index, auraData in ipairs(allAuras) do
        if index > 16 then
            break
        end
        local now = button.Aura.Buffs[index]
        if now then
            local last = button.Aura.LastBuffs[index] or {}
            if last.auraInstanceID ~= auraData.auraInstanceID or last.name ~= auraData.name or last.icon ~= auraData.icon then
                now.icon:SetTexture(auraData.icon)
                now.icon:Show()
                last.auraInstanceID = auraData.auraInstanceID
                last.name = auraData.name
                last.icon = auraData.icon
                button.Aura.LastBuffs[index] = last
            end
            if CheckCount then
                CheckCount(now, auraData.applications or 0)
            end
            if CheckDuration then
                CheckDuration(now, auraData.duration or 0, auraData.expirationTime or 0)
            end
            local xOffset, yOffset = AuraPosition(index)
            now:ClearAllPoints()
            now:SetPoint("BOTTOMLEFT", button, "TOPLEFT", xOffset - 1, yOffset + 3)
            now:Show()
            visibleBuffCount = visibleBuffCount + 1
        end
    end
    for i = visibleBuffCount + 1, 16 do
        local now = button.Aura.Buffs[i]
        if now then
            now:Hide()
        end
        button.Aura.LastBuffs[i] = nil
    end
    button.Aura.visibleBuffCount = visibleBuffCount
end

local function SoloAuraIsHarmful(unit)
    local button = Ether.unitButtons.solo[unit]
    if not button or not button.Aura then return end
    local visibleBuffCount = button.Aura.visibleBuffCount or 0
    local visibleDebuffCount = 0
    local buffRows = math_ceil(visibleBuffCount / 8)
    local startY = buffRows * (14 + 1) + 2
    local allAuras = GetUnitAuras(unit, "HARMFUL")
    if not allAuras then return end
    for index, auraData in ipairs(allAuras) do
        if index > 16 then
            break
        end

        local now = button.Aura.Debuffs[index]
        if now then
            local row = math_floor((index - 1) / 8)
            local col = (index - 1) % 8
            local yOffset = startY + row * (14 + 1)

            now:ClearAllPoints()
            now:SetPoint("BOTTOMLEFT", button, "TOPLEFT", col * (14 + 1) - 1, yOffset + 2)

            local last = button.Aura.LastDebuffs[index] or {}

            if last.auraInstanceID ~= auraData.auraInstanceID then
                now.icon:SetTexture(auraData.icon)
                now.icon:Show()

                if CheckDispelType and now.border then
                    CheckDispelType(now.border, auraData.dispelName)
                elseif now.border then
                    now.border:Show()
                end

                last.auraInstanceID = auraData.auraInstanceID
                last.name = auraData.name
                last.icon = auraData.icon
                last.dispelName = auraData.dispelName
                button.Aura.LastDebuffs[index] = last
            end

            if CheckCount then
                CheckCount(now, auraData.applications or 0)
            end
            if CheckDuration then
                CheckDuration(now, auraData.duration or 0, auraData.expirationTime or 0)
            end

            now:Show()
            visibleDebuffCount = visibleDebuffCount + 1
        end
    end
    for i = visibleDebuffCount + 1, 16 do
        local now = button.Aura.Debuffs[i]
        if now then
            now:Hide()
        end
        button.Aura.LastDebuffs[i] = nil
    end
end

function Ether:SoloAuraFullInitial(unit)
    local button = Ether.unitButtons.solo[unit]
    if not button then return end
    Ether:SoloAuraSetup(button)
    SoloAuraIsHelpful(button.unit)
    SoloAuraIsHarmful(button.unit)
    for i = 1, 16 do
        if button.Aura.Buffs and button.Aura.Buffs[i] then
            button.Aura.Buffs[i]:SetShown(true)
        end
        if button.Aura.Debuffs and button.Aura.Debuffs[i] then
            button.Aura.Debuffs[i]:SetShown(true)
        end
    end
end

function Ether:TargetAuraFullUpdate()
    if Ether.DB[1001][2] ~= 1 then return end
    local button = Ether.unitButtons.solo["target"]
    if not button then return end
    SoloAuraIsHelpful("target")
    SoloAuraIsHarmful("target")
end

local function soloAuraUpdate(unit, updateInfo)
    local button = Ether.unitButtons.solo[unit]
    if not button or not button.Aura then return end
    local helpful, harmful = false, false
    if updateInfo.addedAuras then
        for _, aura in ipairs(updateInfo.addedAuras) do
            if aura.isHelpful then
                helpful = true
            end
            if aura.isHarmful then
                harmful = true
            end
        end
    end
    if updateInfo.removedAuraInstanceIDs then
        helpful = true
        harmful = true
    end
    if helpful then
        SoloAuraIsHelpful(button.unit)
    end
    if harmful then
        SoloAuraIsHarmful(button.unit)
    end
end

local function Aura(_, event, arg1, ...)
    if event == "UNIT_AURA" then
        if not UnitExists(arg1) then return end
        local updateInfo = ...
        if updateInfo then
            if Ether.DB[1001][3] == 1 then
                raidAuraUpdate(arg1, updateInfo)
            end
            if Ether.DB[1001][2] == 1 then
                soloAuraUpdate(arg1, updateInfo)
            end
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
    wipe(foundHelpful)
    wipe(foundHarmful)
    wipe(dispelCache)
end

Ether.GetUnits = function()
    local data = {}
    if UnitInParty("player") and not UnitInRaid("player") then
        table.insert(data, "player")
        for i = 1, GetNumSubgroupMembers() do
            local unit = "party" .. i
            if UnitExists(unit) then
                table.insert(data, unit)
            end
        end
    elseif UnitInRaid("player") or UnitInBattleground("player") then
        for i = 1, GetNumGroupMembers() do
            local unit = "raid" .. i
            if UnitExists(unit) then
                table.insert(data, unit)
            end
        end
    else
        table.insert(data, "player")
    end
    return data
end

local function auraTblReset(unit)
    local button = Ether.unitButtons.solo[unit]
    if not button or not button.Aura then return end
    for i = 1, 16 do
        if button.Aura.Buffs and button.Aura.Buffs[i] then
            button.Aura.Buffs[i]:SetShown(false)
        end
        if button.Aura.Debuffs and button.Aura.Debuffs[i] then
            button.Aura.Debuffs[i]:SetShown(false)
        end
    end
    wipe(button.Aura.LastBuffs)
    wipe(button.Aura.LastDebuffs)
end

function Ether:EnableSoloAuras()
    for _, unit in ipairs({"player", "target", "pet"}) do
        Ether:SoloAuraFullInitial(unit)
    end
end

function Ether:DisableSoloAuras()
    for _, unit in ipairs({"player", "target", "pet"}) do
        auraTblReset(unit)
    end
end

function Ether:EnableHeaderAuras()
    C_Timer.After(0.3, function()
        local getUnits = Ether.GetUnits()
        for _, unit in ipairs(getUnits) do
            if UnitExists(unit) then
                Ether:UpdateRaidIsHelpful(unit, true)
                Ether:UpdateRaidIsHarmful(unit, true)
            end
        end
    end)
end

function Ether:AuraEnable()
    if not update:GetScript("OnEvent") then
        update:RegisterEvent("UNIT_AURA")
        update:SetScript("OnEvent", Aura)
    end
    if Ether.DB[1001][3] == 1 then
        Ether:EnableHeaderAuras()
    end
    if Ether.DB[1001][2] == 1 then
        Ether:EnableSoloAuras()
    end
end

function Ether:DisableHeaderAuras()
    Ether:CleanupRaidIcons()
    wipe(raidAurasHelpful)
    wipe(raidAurasHarmful)
    wipe(raidAurasDispel)
    wipe(raidBuffData)
    wipe(raidDebuffData)
    wipe(foundHelpful)
    wipe(foundHarmful)
    wipe(dispelCache)
end

function Ether:AuraDisable()
    Ether:CleanupRaidIcons()
    Ether:DisableSoloAuras()
    if update:GetScript("OnEvent") then
        update:UnregisterAllEvents()
        update:SetScript("OnEvent", nil)
    end
    Ether:AuraWipe()
end

--[[

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
    if not foundHelpful[guid] then
        foundHelpful[guid] = {}
    end
    wipe(foundHelpful[guid])
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
            foundHelpful[guid][auraData.spellId] = true
        end
    end
    for spellId, texture in pairs(raidBuffData[guid]) do
        if not foundHelpful[guid][spellId] then
            texture:Hide()
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
    if not foundHarmful[guid] then
        foundHarmful[guid] = {}
    end
    wipe(foundHarmful[guid])
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
    for spellId, texture in pairs(raidDebuffData[guid]) do
        if not foundHarmful[guid][spellId] then
            texture:Hide()
        end
    end
end
]]