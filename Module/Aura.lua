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
local GetUnitAuraBySpellID = C_UnitAuras.GetUnitAuraBySpellID
local tinsert = table.insert
local colors = {
    ["Magic"] = {0.2, 0.6, 1.0, 1},
    ["Disease"] = {0.6, 0.4, 0.0, 1},
    ["Curse"] = {0.6, 0.2, 1.0, 1},
    ["Poison"] = {0.2, 1.0, 0.2, 1},
    [""] = {0, 0, 0, 0}
}

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
local raidAuraHelpful = {}
local raidAuraHarmful = {}
local raidAuraDispel = {}
local raidAuraIcons = {}
local raidBuffData = {}
local raidDebuffData = {}
local raidDispelData = {}
local raidIconData = {}
local getUnitBuffs = {}
local getUnitDebuffs = {}
local dispelCache = {}
local dataUnits = {}

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

function Ether:SaveAuraPos(spellId, debuff)
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
    local dispel = nil
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
                    dispelName = auraData.dispelName,
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

function Ether:UpdateRaidIsHelpful(button, guid)
    if not button or not guid then
        return
    end
    local config = Ether.DB[1003]
    local index = 1
    while true do
        local aura = GetBuffDataByIndex(button.unit, index)
        if not aura then break end
        if config[aura.spellId] and config[aura.spellId].enabled and not config[aura.spellId].isDebuff then
            local spellConfig = config[aura.spellId]
            raidBuffData[guid] = raidBuffData[guid] or {}
            if not raidBuffData[guid][aura.spellId] then
                raidBuffData[guid][aura.spellId] = button.healthBar:CreateTexture(nil, "OVERLAY")
                raidBuffData[guid][aura.spellId]:SetColorTexture(unpack(spellConfig.color))
                raidBuffData[guid][aura.spellId]:SetSize(spellConfig.size, spellConfig.size)
                raidBuffData[guid][aura.spellId]:SetPoint(spellConfig.position, spellConfig.offsetX, spellConfig.offsetY)
                raidBuffData[guid][aura.spellId]:Show()
            else
                raidBuffData[guid][aura.spellId]:Show()
            end
            raidBuffData[aura.auraInstanceID] = {
                spellId = aura.spellId,
                guid = guid
            }
            raidAuraHelpful[aura.auraInstanceID] = aura
        end
        index = index + 1
    end
end

function Ether:UpdateRaidIsHarmful(button, guid)
    if not button or not guid then
        return
    end
    local config = Ether.DB[1003]
    local index = 1
    while true do
        local aura = GetDebuffDataByIndex(button.unit, index)
        if not aura then break end
        if config[aura.spellId] and config[aura.spellId].enabled and config[aura.spellId].isDebuff then
            local spellConfig = config[aura.spellId]
            raidDebuffData[guid] = raidDebuffData[guid] or {}
            if not raidDebuffData[guid][aura.spellId] then
                raidDebuffData[guid][aura.spellId] = button.healthBar:CreateTexture(nil, "OVERLAY")
                raidDebuffData[guid][aura.spellId]:SetColorTexture(unpack(spellConfig.color))
                raidDebuffData[guid][aura.spellId]:SetSize(spellConfig.size, spellConfig.size)
                raidDebuffData[guid][aura.spellId]:SetPoint(spellConfig.position, spellConfig.offsetX, spellConfig.offsetY)
                raidDebuffData[guid][aura.spellId]:Show()
            else
                raidDebuffData[guid][aura.spellId]:Show()
            end
            raidDebuffData[aura.auraInstanceID] = {
                spellId = aura.spellId,
                guid = guid
            }
            raidAuraHarmful[aura.auraInstanceID] = aura
        end
        index = index + 1
    end
end

function Ether:updateDispelBorder(button, color)
    button.top:SetColorTexture(unpack(color))
    button.bottom:SetColorTexture(unpack(color))
    button.left:SetColorTexture(unpack(color))
    button.right:SetColorTexture(unpack(color))
end

function Ether:CleanupAuras(guid)
    if raidBuffData[guid] then
        for _, texture in pairs(raidBuffData[guid]) do
            if type(texture) ~= "table" then return end
            texture:Hide()
            texture:ClearAllPoints()
            texture:SetParent(nil)
        end
        raidBuffData[guid] = nil
    end
    if raidIconData[guid] then
        for _, icon in pairs(raidIconData[guid]) do
            Ether.StopBlink(icon)
        end
        raidIconData[guid] = nil
    end
    if raidDebuffData[guid] then
        for _, texture in pairs(raidDebuffData[guid]) do
            if type(texture) ~= "table" then return end
            texture:Hide()
            texture:ClearAllPoints()
            texture:SetParent(nil)
        end
        raidDebuffData[guid] = nil
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

function Ether:UpdateBlink(unit, guid, spellId)
    local aura = GetUnitAuraBySpellID(unit, spellId, "HELPFUL")
    if not aura then return end
    local button = Ether.unitButtons.raid[unit]
    if not button then return end
    if not raidIconData[guid] then
        raidIconData[guid] = {}
    end
    if not raidIconData[guid][aura.spellId] then
        local color = colors[aura.dispelName] or {0, 0, 0, 1}
        button.dispelIcon:SetTexture(aura.icon)
        button.dispelBorder:SetColorTexture(unpack(color))
        raidIconData[guid][aura.spellId] = button.iconFrame
    end
    Ether.StartBlink(raidIconData[guid][aura.spellId], aura.duration, 0.3)
end
function Ether:UpdateDispel(unit, guid, spellId)
    local aura = GetUnitAuraBySpellID(unit, spellId, "HELPFUL")
    if not aura then return end
    local button = Ether.unitButtons.raid[unit]
    if not button then return end
    local dispel = nil
    local priority = 0
    if not raidDispelData[guid] then
        raidDispelData[guid] = {}
    end
    if not raidDispelData[guid][spellId] then
        local order = dispelPriority[aura.dispelName] or 0
        if order > priority then
            priority = order
            dispel = aura.dispelName
            local color = colors[dispel] or {0, 0, 0, 0}
            raidDispelData[guid][spellId] = button
            Ether:updateDispelBorder(raidDispelData[guid][spellId], color)
        end
    else
        raidDispelData[guid][spellId]:Show()
    end
end

local function raidAuraUpdate(unit, updateInfo)
    if Ether.DB[1001][3] ~= 1 then return end
    if not UnitExists(unit) then return end
    local button = Ether.unitButtons.raid[unit]
    if not button then return end
    local guid = UnitGUID(unit)
    if not guid then return end
    local config = Ether.DB[1003]
    if updateInfo.addedAuras then
        for _, aura in ipairs(updateInfo.addedAuras) do
            if aura.isHelpful and config[aura.spellId] and config[aura.spellId].enabled and not config[aura.spellId].isDebuff then
                local spellConfig = config[aura.spellId]
                raidBuffData[guid] = raidBuffData[guid] or {}
                if not raidBuffData[guid][aura.spellId] then
                    raidBuffData[guid][aura.spellId] = button.healthBar:CreateTexture(nil, "OVERLAY")
                    raidBuffData[guid][aura.spellId]:SetColorTexture(unpack(spellConfig.color))
                    raidBuffData[guid][aura.spellId]:SetSize(spellConfig.size, spellConfig.size)
                    raidBuffData[guid][aura.spellId]:SetPoint(spellConfig.position, spellConfig.offsetX, spellConfig.offsetY)
                    raidBuffData[guid][aura.spellId]:Show()
                else
                    raidBuffData[guid][aura.spellId]:Show()
                end
                raidBuffData[aura.auraInstanceID] = {
                    spellId = aura.spellId,
                    guid = guid
                }
                raidAuraHelpful[aura.auraInstanceID] = aura
            end
            if aura.isHarmful and dispelByPlayer[aura.dispelName] then
                raidDispelData[guid] = raidDispelData[guid] or {}
                raidIconData[guid] = raidIconData[guid] or {}
                raidDispelData[aura.auraInstanceID] = {
                    spellId = aura.spellId,
                    guid = guid
                }
                raidIconData[aura.auraInstanceID] = {
                    spellId = aura.spellId,
                    guid = guid
                }
                local color = colors[aura.dispelName] or {0, 0, 0, 0}
                raidDispelData[guid][aura.spellId] = button
                Ether:updateDispelBorder(raidDispelData[guid][aura.spellId], color)
                button.dispelIcon:SetTexture(aura.icon)
                button.dispelBorder:SetColorTexture(unpack(color))
                raidIconData[guid][aura.spellId] = button.iconFrame
                Ether.StartBlink(raidIconData[guid][aura.spellId], aura.duration, 0.28)
                raidAuraDispel[aura.auraInstanceID] = aura
            end
            if aura.isHarmful and config[aura.spellId] and config[aura.spellId].enabled and config[aura.spellId].isDebuff then
                local spellConfig = config[aura.spellId]
                raidDebuffData[guid] = raidDebuffData[guid] or {}
                if not raidDebuffData[guid][aura.spellId] then
                    raidDebuffData[guid][aura.spellId] = button.healthBar:CreateTexture(nil, "OVERLAY")
                    raidDebuffData[guid][aura.spellId]:SetColorTexture(unpack(spellConfig.color))
                    raidDebuffData[guid][aura.spellId]:SetSize(spellConfig.size, spellConfig.size)
                    raidDebuffData[guid][aura.spellId]:SetPoint(spellConfig.position, spellConfig.offsetX, spellConfig.offsetY)
                    raidDebuffData[guid][aura.spellId]:Show()
                else
                    raidDebuffData[guid][aura.spellId]:Show()
                end
                raidDebuffData[aura.auraInstanceID] = {
                    spellId = aura.spellId,
                    guid = guid
                }
                raidAuraHarmful[aura.auraInstanceID] = aura
            end
        end
    end
    if updateInfo.removedAuraInstanceIDs then
        for _, auraInstanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
            if raidAuraDispel[auraInstanceID] then
                local auraData = raidDispelData[auraInstanceID]
                local auraGuid = auraData.guid
                local spellId = auraData.spellId
                if raidDispelData[auraGuid] and raidDispelData[auraGuid][spellId] then
                    Ether:updateDispelBorder(raidDispelData[auraGuid][spellId], {0, 0, 0, 0})
                end
                if raidIconData[auraGuid] and raidIconData[auraGuid][spellId] then
                    Ether.StopBlink(raidIconData[auraGuid][spellId])
                end
                raidAuraDispel[auraInstanceID] = nil
            end
            if raidAuraHarmful[auraInstanceID] then
                local auraData = raidDebuffData[auraInstanceID]
                if not auraData then return end
                local auraGuid = auraData.guid
                local spellId = auraData.spellId
                if raidDebuffData[auraGuid] and raidDebuffData[auraGuid][spellId] then
                    raidDebuffData[auraGuid][spellId]:Hide()
                end
                raidAuraHarmful[auraInstanceID] = nil
            end
            if raidAuraHelpful[auraInstanceID] then
                local auraData = raidBuffData[auraInstanceID]
                if not auraData then return end
                local auraGuid = auraData.guid
                local spellId = auraData.spellId
                if raidBuffData[guid] and raidBuffData[auraGuid][spellId] then
                    raidBuffData[auraGuid][spellId]:Hide()
                end
                raidAuraHelpful[auraInstanceID] = nil
            end
        end
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
    wipe(raidAuraHelpful)
    wipe(raidAuraHarmful)
    wipe(raidAuraDispel)
    wipe(raidAuraIcons)
    wipe(raidDispelData)
    wipe(raidIconData)
    wipe(raidBuffData)
    wipe(raidDebuffData)
    wipe(dispelCache)
    wipe(getUnitBuffs)
    wipe(getUnitDebuffs)
end

local function GetUnits()
    wipe(dataUnits)
    if UnitInParty("player") and not UnitInRaid("player") then
        tinsert(dataUnits, "player")
        for i = 1, GetNumSubgroupMembers() do
            local unit = "party" .. i
            if UnitExists(unit) then
                tinsert(dataUnits, unit)
            end
        end
    elseif UnitInRaid("player") then
        for i = 1, GetNumGroupMembers() do
            local unit = "raid" .. i
            if UnitExists(unit) then
                tinsert(dataUnits, unit)
            end
        end
    else
        tinsert(dataUnits, "player")
    end
    return dataUnits
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
    wipe(button.Aura.Buffs)
    wipe(button.Aura.Debuffs)
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

function Ether:EnableSoloUnitAura(info)
    for index, unit in ipairs({"player", "target", "pet"}) do
        if index == info then
            Ether:SoloAuraFullInitial(unit)
            break
        end
    end
end

function Ether:DisableSoloUnitAura(info)
    for index, unit in ipairs({"player", "target", "pet"}) do
        if index == info then
            auraTblReset(unit)
            break
        end
    end
end

function Ether:DisableHeaderAuras()
    Ether:CleanupRaidIcons()
    Ether:AuraWipe()
end

function Ether:EnableHeaderAuras()
    C_Timer.After(0.3, function()
        Ether:CleanupTimerCache()
        for _, unit in ipairs(GetUnits()) do
            if UnitExists(unit) then
                local button = Ether.unitButtons.raid[unit]
                if not button then return end
                local guid = UnitGUID(unit)
                if guid and C_PlayerInfo.GUIDIsPlayer(guid) then
                    Ether:UpdateRaidIsHelpful(button, guid)
                    Ether:UpdateRaidIsHarmful(button, guid)
                end
            end
        end
    end)
end

function Ether:FullAuraReset()
    Ether.StopAllBlinks()
    Ether:CleanupRaidIcons()
    Ether:CleanupTimerCache()
    Ether:DisableHeaderAuras()
    Ether:DisableSoloAuras()
    Ether:AuraWipe()
    Ether:EnableHeaderAuras()
    Ether:EnableSoloAuras()
end

function Ether:AuraEnable()
    if not update:GetScript("OnEvent") then
        update:RegisterEvent("UNIT_AURA")
        update:SetScript("OnEvent", Aura)
    end
    Ether:CleanupRaidIcons()
    Ether:AuraWipe()
    if Ether.DB[1001][3] == 1 then
        C_Timer.After(3, function()
            if Ether.DB[1001][3] == 1 then
                Ether:CleanupTimerCache()
                for _, unit in ipairs(GetUnits()) do
                    if UnitExists(unit) then
                        local button = Ether.unitButtons.raid[unit]
                        if not button then return end
                        local guid = UnitGUID(unit)
                        if guid and C_PlayerInfo.GUIDIsPlayer(guid) then
                            Ether:UpdateRaidIsHelpful(button, guid)
                            Ether:UpdateRaidIsHarmful(button, guid)
                        end
                    end
                end
            end
        end)
    end
    if Ether.DB[1001][2] == 1 then
        Ether:EnableSoloAuras()
    end
end

function Ether:AuraDisable()
    Ether.StopAllBlinks()
    Ether:CleanupRaidIcons()
    Ether:DisableSoloAuras()
    if update:GetScript("OnEvent") then
        update:UnregisterAllEvents()
        update:SetScript("OnEvent", nil)
    end
    Ether:AuraWipe()
end
