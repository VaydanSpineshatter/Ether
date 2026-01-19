local _, Ether = ...
local Aura = {}
Ether.Aura = Aura
local U_EX = UnitExists
local U_GUID = UnitGUID
local math_floor = math.floor
local math_ceil = math.ceil
--local G_Time = GetTime
local pairs, ipairs = pairs, ipairs
--local C_Ticker = C_Timer.NewTicker
--local C_After = C_Timer.After
local GetBuffDataByIndex = C_UnitAuras.GetBuffDataByIndex
local GetDebuffDataByIndex = C_UnitAuras.GetDebuffDataByIndex
--local GetAuraDataBySpellID = C_UnitAuras.GetUnitAuraBySpellID
--local GetAuraDataBySpellName = C_UnitAuras.GetAuraDataBySpellName

local dispelClass = {
    MAGE = { ["Curse"] = true },
    PRIEST = { ["Magic"] = true, ["Disease"] = true },
    PALADIN = { ["Magic"] = true, ["Disease"] = true, ["Poison"] = true },
    DRUID = { ["Curse"] = true, ["Poison"] = true },
    SHAMAN = { ["Disease"] = true, ["Poison"] = true }
}

local dispelPriority = {
    Magic = 4,
    Disease = 3,
    Curse = 2,
    Poison = 1
}

local dispelColors = {
    ["Magic"] = { 0.2, 0.6, 1.0, 0.85 },
    ["Curse"] = { 0.6, 0.2, 1.0, 0.85 },
    ["Disease"] = { 0.6, 0.4, 0.0, 0.85 },
    ["Poison"] = { 0.1, 0.9, 0.1, 0.85 },
    [""] = { 0, 0, 0, 1 }
}

local _, classFilename = UnitClass("player")
local dispelByPlayer = {}
dispelByPlayer = dispelClass[classFilename]

local raidBuffs = {}
local raidDebuffs = {}
local raidDispel = {}

Aura.RaidIconCleanUp = function(button)
    if not button then
        return
    end

    local guid = button.unitGUID

    if guid then
        for k, v in pairs(raidBuffs) do
            if v.unit then
                local targetGuid = U_GUID(v.unit)
                if targetGuid == guid then
                    raidBuffs[k] = nil
                end
            end
        end
        for k, v in pairs(raidDebuffs) do
            if v.unit then
                local targetGuid = U_GUID(v.unit)
                if targetGuid == guid then
                    raidDebuffs[k] = nil
                end
            end
        end
        for k, v in pairs(raidDispel) do
            if v.unit then
                local targetGuid = U_GUID(v.unit)
                if targetGuid == guid then
                    raidDispel[k] = nil
                end
            end
        end
    end
    for k in pairs(button.RaidAura) do
        button.RaidAura[k]:Hide()
        button.RaidAura[k]:SetParent(nil)
        button.RaidAura[k] = nil
    end
    if button.top and button.right then
        button.top:SetColorTexture(0, 0, 0, 1)
        button.right:SetColorTexture(0, 0, 0, 1)
        button.left:SetColorTexture(0, 0, 0, 1)
        button.bottom:SetColorTexture(0, 0, 0, 1)
    end
end

local function GetAuraTexture(button, spellId)
    if not button or not button.RaidAura then
        return
    end

    local config = Ether.DB[1001][1003][spellId]
    if not config then
        return
    end
    if not button.RaidAura[spellId] then
        button.RaidAura[spellId] = button.healthBar:CreateTexture(nil, "OVERLAY")
        button.RaidAura[spellId]:SetSize(config.size, config.size)
        button.RaidAura[spellId]:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        button.RaidAura[spellId]:SetColorTexture(unpack(config.color))
        button.RaidAura[spellId]:SetPoint(config.position, config.offsetX, config.offsetY)
        button.RaidAura[spellId]:Hide()
    end
    return button.RaidAura[spellId]
end

local function CreateAuraTexture(button, spellId, bool)
    if not button.unit then
        return
    end
    local customAura = Ether.DB[1001][1003]
    if customAura then
        if not button.RaidAura[spellId] then
            GetAuraTexture(button, spellId)
        end
        button.RaidAura[spellId]:Show()
    end
end

--  if Ether.StartBlink then
--    Ether.StartBlink(button.Debuffs[id], 15, 0.3)
--  end
--  Ether.StopBlink(button.Debuffs[id])

local function RemoveAuraTexture(button, spellId)
    if not button.unit then
        return
    end
    local customAura = Ether.DB[1001][1003]
    if customAura then
        button.RaidAura[spellId]:Hide()
    end
end

Aura.FullAuraScan = function(button)
    if not button or not button.unit then
        return
    end
    local customAura = Ether.DB[1001][1003]
    local unit = button.unit
    local guid = U_GUID(unit)

    if guid then
        for k, v in pairs(raidBuffs) do
            if v.unit then
                local targetGuid = U_GUID(v.unit)
                if targetGuid == guid then
                    raidBuffs[k] = nil
                end
            end
        end
        for k, v in pairs(raidDebuffs) do
            if v.unit then
                local targetGuid = U_GUID(v.unit)
                if targetGuid == guid then
                    raidDebuffs[k] = nil
                end
            end
        end
    end

    local index = 1
    while true do
        local aura = GetBuffDataByIndex(unit, index)
        if not aura then
            break
        end
        if aura.isHelpful and customAura[aura.spellId]then
            CreateAuraTexture(button, aura.spellId, true)
            raidBuffs[aura.auraInstanceID] = aura
        end
        index = index + 1
    end

    index = 1
    while true do
        local aura = GetDebuffDataByIndex(unit, index)
        if not aura then
            break
        end
        if aura.isHarmful and customAura[aura.spellId] then
            CreateAuraTexture(button, aura.spellId)
            raidDebuffs[aura.auraInstanceID] = aura
        end
        index = index + 1
    end
end


--[[
local auraCache = {}
local function UpdateAuraCache(guid, spellID, data)
    if not auraCache[guid] then
        auraCache[guid] = {}
    end
    auraCache[guid][spellID] = data
end
return C_UnitAuras.GetAuraDataBySpellName(unit, GetSpellInfo(spellID), "HARMFUL")
AuraUtil.ForEachAura(unit, "HARMFUL", nil, function(auraData)
AuraUtil.ForEachAura("player", "HELPFUL", nil, foo)
]]


local function raidAuraUpdate(unit, info)
    if not unit:match("^raid") then
        return
    end

    local customAura = Ether.DB[1001][1003]
    local button = Ether.Buttons.raid[unit]
    if not button then
        return
    end
    local dispel
    local priority = 0

    if info.isFullUpdate then
        Ether.Aura.RaidIconCleanUp(button)
        Aura.FullAuraScan(button)
        return
    end

    if info.addedAuras then
        for _, aura in ipairs(info.addedAuras) do
            if aura.isHelpful and customAura[aura.spellId]then
                CreateAuraTexture(button, aura.spellId, true)
                raidBuffs[aura.auraInstanceID] = aura
            end
            if aura.isHarmful and customAura[aura.spellId] then
                CreateAuraTexture(button, aura.spellId)
                raidDebuffs[aura.auraInstanceID] = aura
            end
            if aura.isHarmful and dispelByPlayer and dispelByPlayer[aura.dispelName] then
                local sort = dispelPriority and dispelPriority[aura.dispelName] or 0
                if sort > priority then
                    priority = sort
                    dispel = aura.dispelName
                end
                if dispelColors and dispelColors[aura.dispelName] then
                    local c = dispelColors[aura.dispelName]
                    button.top:SetColorTexture(unpack(c))
                    button.right:SetColorTexture(unpack(c))
                    button.left:SetColorTexture(unpack(c))
                    button.bottom:SetColorTexture(unpack(c))
                end
                raidDispel[aura.auraInstanceID] = aura
            end
        end
    end

    if info.removedAuraInstanceIDs then
        for _, auraInstanceID in ipairs(info.removedAuraInstanceIDs) do
            if raidBuffs[auraInstanceID] then
                RemoveAuraTexture(button, raidBuffs[auraInstanceID].spellId)
                raidBuffs[auraInstanceID] = nil
            end
            if raidDebuffs[auraInstanceID] then
                RemoveAuraTexture(button, raidDebuffs[auraInstanceID].spellId)
                raidDebuffs[auraInstanceID] = nil
            end
            if raidDispel[auraInstanceID] then
                if button.top then
                    button.top:SetColorTexture(0, 0, 0, 1)
                    button.right:SetColorTexture(0, 0, 0, 1)
                    button.left:SetColorTexture(0, 0, 0, 1)
                    button.bottom:SetColorTexture(0, 0, 0, 1)
                end
                raidDispel[auraInstanceID] = nil
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
    if unit ~= "player" then
        return
    end
    local button = Ether.unitButtons[unit]
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
    if unit ~= "target" then
        return
    end
    local button = Ether.unitButtons[unit]
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
            frame:SetScript("OnEvent", function(_, event, unit, info)
                if event ~= "UNIT_AURA" then
                    return
                end
                if not unit then
                    return
                end
                if Ether.DB[1001][1002][3] == 1 then
                    raidAuraUpdate(unit, info)
                end
                if Ether.DB[1001][1002][1] == 1 and unit == "player" then
                    auraUpdatePlayer(unit, info)
                end
                if Ether.DB[1001][1002][2] == 1 and unit == "target" then
                    auraUpdateTarget(unit, info)
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
    wipe(raidBuffs)
    wipe(raidDebuffs)
    wipe(raidDispel)
end

function Aura:Enable()
    InitializeAuras()
end

function Aura:Disable()
    DisableAuras()
    AuraWipe()
end

