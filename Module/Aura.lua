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

local trackedBuffAuras = {
    [10938] = 1, --Power Word: Fortitude, Prayer of Fortitude
    [21564] = 1,
    [27841] = 2, --Divine Spirit, Prayer of Spirit
    [27681] = 2,
    [10958] = 3, --Shadow Protection, Prayer of Shadow Protection
    [27683] = 3,
    [10157] = 4, --Arcane Intellect, Arcane Brilliance
    [23028] = 4,
    [9885] = 5, --Mark of the Wild, Gift of the Wild
    [21850] = 5,
    [25315] = 6, --Renew: Rank 10
    [10901] = 7, --Power Word Shield: Rank 3
    [6346] = 8, --Fear Ward
}

local trackedDebuffAuras = {
    [6788] = 1   -- Weakened Soul
}

local AuraColors = {
    [10938] = { 0.80, 0.40, 1.00 },
    [21564] = { 0.80, 0.40, 1.00 },
    [27841] = { 0, 1, 1 },
    [27681] = { 0, 1, 1 },
    [10958] = { 0, 0, 0 },
    [27683] = { 0, 0, 0 },
    [10157] = { 0.00, 0.80, 1.00 },
    [23028] = { 0.00, 0.80, 1.00 },
    [9885] = { 1, 0.65, 0 },
    [21850] = { 1, 0.65, 0 },
    [25315] = { 0.00, 1.00, 0.00 },
    [10901] = { 1, 1, 1 },
    [6346] = { 1.00, 0.84, 0.00 }
}

local TextureCoordinate = {
    [10938] = { "BOTTOMLEFT", 0, 0 },
    [21564] = { "BOTTOMLEFT", 0, 0 },
    [27841] = { "BOTTOMLEFT", 0, 6 },
    [27681] = { "BOTTOMLEFT", 0, 6 },
    [10958] = { "BOTTOMLEFT", 0, 12 },
    [27683] = { "BOTTOMLEFT", 0, 12 },
    [10157] = { "BOTTOMLEFT", 6, 0 },
    [23028] = { "BOTTOMLEFT", 6, 0 },
    [9885] = { "BOTTOMLEFT", 12, 0 },
    [21850] = { "BOTTOMLEFT", 12, 0 },
    [25315] = { "TOPRIGHT", 0, 0 },
    [10901] = { "TOP", 0, 0 },
    [6346] = { "TOP", 0, -12 }
}

local raidBuffs = {}
local raidDebuffs = {}
local raidDispel = {}
Ether.raidBuffs = raidBuffs
Ether.raidDebuffs = raidDebuffs
Ether.raidDispel = raidDispel

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

    if button.Buffs then
        for i = 1, 8 do
            if button.Buffs[i] then
                button.Buffs[i]:Hide()
                button.Buffs[i]:SetParent(nil)
                button.Buffs[i] = nil
            end
        end
    end

    if button.Debuffs[1] then
        if Ether and Ether.StopBlink then
            Ether.StopBlink(button.Debuffs[1])
        end
        button.Debuffs[1]:Hide()
        button.Debuffs[1]:SetParent(nil)
        button.Debuffs[1] = nil
    end

    if button.top and button.right then
        button.top:SetColorTexture(0, 0, 0, 1)
        button.right:SetColorTexture(0, 0, 0, 1)
        button.left:SetColorTexture(0, 0, 0, 1)
        button.bottom:SetColorTexture(0, 0, 0, 1)
    end
end

local function CreateBuffTexture(button, spellId)
    if not button then
        return
    end
    local id = trackedBuffAuras[spellId]
    if not button.Buffs[id] then
        local color = AuraColors[spellId]
        local coordinate = TextureCoordinate[spellId]
        button.Buffs[id] = button.healthBar:CreateTexture(nil, "OVERLAY")
        button.Buffs[id]:SetSize(6, 6)
        button.Buffs[id]:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        button.Buffs[id]:SetColorTexture(unpack(color))
        button.Buffs[id]:SetPoint(unpack(coordinate))
    end

    button.Buffs[id]:Show()

end
local function CreateDebuffTexture(button, spellId)
    if not button then
        return
    end
    local id = trackedDebuffAuras[spellId]

    if not button.Debuffs[id] then
        button.Debuffs[id] = button.healthBar:CreateTexture(nil, "OVERLAY")
        button.Debuffs[id]:SetSize(6, 6)
        button.Debuffs[id]:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        button.Debuffs[id]:SetPoint("TOP", 0, -6)
        button.Debuffs[id]:SetColorTexture(1, 0, 0, 1)
        button.Debuffs[id]:Show()
    end

    if Ether and Ether.StartBlink then
        Ether.StartBlink(button.Debuffs[id], 15, 0.3)
    end
end

local function UpdateRemovedRaidBuffs(button, spellId)
    if not button then
        return
    end
    local id = trackedBuffAuras[spellId]
    if id and button.Buffs and button.Buffs[id] then
        button.Buffs[id]:Hide()
    end
end

local function UpdateRemovedRaidDebuffs(button, spellId)
    if not button then
        return
    end
    local id = trackedDebuffAuras[spellId]
    if id and button.Debuffs and button.Debuffs[id] then
        if Ether and Ether.StopBlink then
            Ether.StopBlink(button.Debuffs[id])
        end
        button.Debuffs[id]:Hide()
    end
end

Aura.FullAuraScan = function(button)
    if not button or not button.unit or not U_EX(button.unit) then
        return
    end

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

        local spellId = aura.spellId
        if Ether.DB[1001][1101][spellId] then
            CreateBuffTexture(button, spellId)
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

        local spellId = aura.spellId
        if Ether.DB[1001][1202][spellId] then
            CreateDebuffTexture(button, spellId)
            raidDebuffs[aura.auraInstanceID] = aura
        end
        index = index + 1
    end
end

local function raidAuraUpdate(unit, info)

    local validBuff = Ether.DB[1001][1101]
    local validDebuff = Ether.DB[1001][1202]

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
            if aura.isHelpful and validBuff[aura.spellId] then
                CreateBuffTexture(button, aura.spellId)
                raidBuffs[aura.auraInstanceID] = aura
            end
            if aura.isHarmful and validDebuff[aura.spellId] then
                CreateDebuffTexture(button, aura.spellId)
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
                UpdateRemovedRaidBuffs(button, raidBuffs[auraInstanceID].spellId)
                raidBuffs[auraInstanceID] = nil
            end
            if raidDebuffs[auraInstanceID] then
                UpdateRemovedRaidDebuffs(button, raidDebuffs[auraInstanceID].spellId)
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

local function AuraPosition(i)
    local row = math_floor((i - 1) / 8)
    local col = (i - 1) % 8
    local xOffset = col * (14 + 1)
    local yOffset = 1 + row * (14 + 1)

    return xOffset, yOffset
end

Aura.SingleAuraUpdateBuff = function(button)
    if (not button or not button.unit or not button.Aura) then
        return
    end

    local visibleBuffCount = 0
    for index = 1, 16 do
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

    for index = 1, 16 do
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

Aura.SingleAuraSetup = function(button)
    if (not button or not button.unit) then
        return
    end
    if not button.Aura then
        button.Aura = {
            Buffs = {},
            Debuffs = {},
            LastBuffs = {},
            LastDebuffs = {}
        }
    end

    for i = 1, 16 do
        local frame = CreateFrame("Frame", nil, button)
        frame:SetSize(14, 14)

        local xOffset, yOffset = AuraPosition(i)

        frame:SetPoint("BOTTOMLEFT", button, "TOPLEFT", xOffset - 1, yOffset + 2)
        frame:SetShown(false)

        frame.icon = Ether.Setup.SingleAuraIcon(frame)
        frame.count = Ether.Setup.SingleAuraCount(frame)
        frame.timer = Ether.Setup.SingleAuraTimer(frame, frame.icon)

        button.Aura.Buffs[i] = frame
    end

    for i = 1, 16 do
        local frame = CreateFrame("Frame", nil, button)
        frame:SetSize(14, 14)

        local xOffset, yOffset = AuraPosition(i)

        frame:SetPoint("BOTTOMLEFT", button, "TOPLEFT", xOffset - 1, yOffset + 2)

        frame:SetShown(false)

        frame.icon = Ether.Setup.SingleAuraIcon(frame)
        frame.count = Ether.Setup.SingleAuraCount(frame)
        frame.timer = Ether.Setup.SingleAuraTimer(frame, frame.icon)

        local border = frame:CreateTexture(nil, "BORDER")
        border:SetColorTexture(1, 0, 0, 1)
        border:SetPoint("TOPLEFT", -1, 1)
        border:SetPoint("BOTTOMRIGHT", 1, -1)
        border:Hide()

        frame.border = border

        button.Aura.Debuffs[i] = frame
    end
end

Aura.SingleAuraFullInitial = function(self)
    Ether.Aura.SingleAuraSetup(self)
    Ether.Aura.SingleAuraUpdateBuff(self)
    Ether.Aura.SingleAuraUpdateDebuff(self)
end

local soloPlayerB = {}
local soloPlayerD = {}

local function auraUpdatePlayer(unit, info)
    local button = Ether.unitButtons[unit]
    if info.addedAuras then
        for _, aura in ipairs(info.addedAuras) do
            if aura.isHelpful then
                Aura.SingleAuraUpdateBuff(button)
                soloPlayerB[aura.auraInstanceID] = aura
            end
            if aura.isHarmful then
                Aura.SingleAuraUpdateDebuff(button)
                soloPlayerD[aura.auraInstanceID] = aura
            end
        end
    end
    if info.removedAuraInstanceIDs then
        for _, auraInstanceID in ipairs(info.removedAuraInstanceIDs) do
            if soloPlayerB[auraInstanceID] then
                Aura.SingleAuraUpdateBuff(button)
                soloPlayerB[auraInstanceID] = nil
            end
            if soloPlayerD[auraInstanceID] then
                Aura.SingleAuraUpdateDebuff(button)
                soloPlayerD[auraInstanceID] = nil
            end
        end
    end
end

local soloTargetB = {}
local soloTargetD = {}

local function auraUpdateTarget(unit, info)
    local button = Ether.unitButtons[unit]
    if info.addedAuras then
        for _, aura in ipairs(info.addedAuras) do
            if aura.isHelpful then
                Aura.SingleAuraUpdateBuff(button)
                soloTargetB[aura.auraInstanceID] = aura
            end
            if aura.isHarmful then
                Aura.SingleAuraUpdateDebuff(button)
                soloTargetD[aura.auraInstanceID] = aura
            end
        end
    end
    if info.removedAuraInstanceIDs then
        for _, auraInstanceID in ipairs(info.removedAuraInstanceIDs) do
            if soloTargetB[auraInstanceID] then
                Aura.SingleAuraUpdateBuff(button)
                soloTargetB[auraInstanceID] = nil
            end
            if soloTargetD[auraInstanceID] then
                Aura.SingleAuraUpdateDebuff(button)
                soloTargetD[auraInstanceID] = nil
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
                if not unit or not U_EX(unit) then
                    return
                end
                if Ether.DB[1001][1002][1] == 1 and unit == "player" then
                    auraUpdatePlayer(unit, info)
                end
                if Ether.DB[1001][1002][2] == 1 and unit == "target" then
                    auraUpdateTarget(unit, info)
                end
                if Ether.DB[1001][1002][3] == 1 then
                    raidAuraUpdate(unit, info)
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
    wipe(soloPlayerB)
    wipe(soloPlayerD)
    wipe(soloTargetB)
    wipe(soloTargetD)
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


