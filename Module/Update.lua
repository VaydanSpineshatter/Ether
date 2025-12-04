local Ether                                  = select(2, ...)
local C                                      = Ether
local Update                                 = C.Update
local UnitIsPlayer                           = UnitIsPlayer
local UnitHealth, UnitHealthMax              = UnitHealth, UnitHealthMax
local UnitClass                              = UnitClass
local UnitName                               = UnitName
local UnitPowerType, UnitPower, UnitPowerMax = UnitPowerType, UnitPower, UnitPowerMax
local UnitGetIncomingHeals                   = UnitGetIncomingHeals
local UnitGetTotalHealAbsorbs                = UnitGetTotalHealAbsorbs
local Enum                                   = Enum

local nameCache                              = {}
local stringCache                            = {}
local PowerCache, ClassCache                 = {}, {}
local lastHealthData, lastPowerData          = {}, {}
local lastHealth, lastPower                  = {}, {}
local lastRaidPower                          = {}
Update.lastPowerData                         = lastPowerData
Update.lastPower                             = lastPower
Update.lastRaidPower                         = lastRaidPower


local CLASSCOLORS    = {
    ['HUNTER'] = { 0.67, 0.83, 0.45 },
    ['WARLOCK'] = { 0.58, 0.51, 0.79 },
    ['PRIEST'] = { 1.0, 1.0, 1.0 },
    ['PALADIN'] = { 0.96, 0.55, 0.73 },
    ['MAGE'] = { 0.41, 0.8, 0.94 },
    ['ROGUE'] = { 1.0, 0.96, 0.41 },
    ['DRUID'] = { 1.0, 0.49, 0.04 },
    ['SHAMAN'] = { 0.0, 0.44, 0.87 },
    ['WARRIOR'] = { 0.78, 0.61, 0.43 },
    ['UNKNOWN'] = { 0.80, 0.40, 1.00 }
}

local POWERCOLORS    = {
    [0] = { 0.00, 0.44, 0.87 },
    [1] = { 1.00, 0.00, 0.00 },
    [2] = { 1.00, 0.50, 0.25 },
    [3] = { 1.00, 1.00, 0.00 },
    [6] = { 0.00, 1.00, 1.00 },
    [99] = { 0.5, 0.5, 0.5 },
}

local GRADIENT_COLOR = {
    { 1, 0, 0 },
    { 1, 1, 0 },
    { 0, 1, 0 }
}

function Update:GetPowerColors(powerTypeID)
    if (not powerTypeID) then
        return 0.5, 0.5, 0.5
    end

    local cached = PowerCache[powerTypeID]
    if cached then
        return cached[1], cached[2], cached[3]
    end

    local COLOR = POWERCOLORS[powerTypeID]
    PowerCache[powerTypeID] = COLOR

    return COLOR[1], COLOR[2], COLOR[3]
end

function Update:GetClassColors(frame, classFile)
    if (not classFile) then classFile = 'UNKNOWN' end
    if (not UnitIsPlayer(frame.unit)) then
        classFile = 'UNKNOWN'
    end

    local cached = ClassCache[classFile]
    if cached then
        return cached[1], cached[2], cached[3]
    end

    local COLOR = CLASSCOLORS[classFile]
    ClassCache[classFile] = COLOR

    return COLOR[1], COLOR[2], COLOR[3]
end

local function utf8sub(str, start, numChars)
    local currentIndex = start
    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        if char >= 240 then
            currentIndex = currentIndex + 4
        elseif char >= 225 then
            currentIndex = currentIndex + 3
        elseif char >= 192 then
            currentIndex = currentIndex + 2
        else
            currentIndex = currentIndex + 1
        end
        numChars = numChars - 1
    end
    return str:sub(start, currentIndex - 1)
end

local function ShortenName(name, maxLength)
    if (not name or not maxLength) then return end
    if #name > maxLength then
        return name:sub(1, maxLength)
    else
        return name
    end
end

local function FormatNumber(value)
    if value >= 1e6 then
        return format("%.1fm", value / 1e6)
    elseif value >= 1e3 then
        return format("%.1fk", value / 1e3)
    else
        return tostring(value)
    end
end

local function GetGradientColor(pct)
    if pct < 0.3 then
        return GRADIENT_COLOR[1][1], GRADIENT_COLOR[1][2], GRADIENT_COLOR[1][3]
    elseif pct < 0.6 then
        return GRADIENT_COLOR[2][1], GRADIENT_COLOR[2][2], GRADIENT_COLOR[2][3]
    else
        return GRADIENT_COLOR[3][1], GRADIENT_COLOR[3][2], GRADIENT_COLOR[3][3]
    end
end

local function GetSmoothGradientColor(pct)
    local r, g
    if pct > 0.5 then
        r = (1 - pct) * 2
        g = 1
    else
        r = 1
        g = pct * 2
    end

    return r, g, 0
end

local function RGBToHex(r, g, b)
    return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

local function getCachedString(key)
    if stringCache[key] then
        return stringCache[key]
    else
        local result = key
        stringCache[key] = result
        return result
    end
end

function Update:Health(frame)
    if (not frame.unit or not frame.Health) then return end

    local health, maxHealth = UnitHealth(frame.unit), UnitHealthMax(frame.unit)
    if maxHealth <= 0 then return end

    local pct = health / maxHealth
    local roundedPct = math.floor(pct * 100 + 0.5)

    if lastHealthData[frame.unit] == roundedPct then
        return
    end

    lastHealthData[frame.unit] = roundedPct

    local r, g, b = GetSmoothGradientColor(pct)
    frame.Health:SetText(RGBToHex(r, g, b) .. roundedPct .. '%|r')
end

function Update:Power(frame)
    if (not frame.unit or not frame.Power) then return end
    local power, maxPower
    local Display = C.DB['POWER']['SHORT']['DISPLAY']

    if Display == 'Power' then
        power, maxPower = UnitPower(frame.unit), UnitPowerMax(frame.unit)
    else
        power, maxPower = UnitPower(frame.unit, Enum.PowerType[Display]),
            UnitPowerMax(frame.unit, Enum.PowerType[Display])
    end
    if maxPower <= 0 then return end

    local pct = power / maxPower
    local roundedPct = math.floor(pct * 100 + 0.5)

    if lastPowerData[frame.unit] == roundedPct then
        return
    end

    lastPowerData[frame.unit] = roundedPct

    local r, g, b = GetSmoothGradientColor(pct)
    frame.Power:SetText(RGBToHex(r, g, b) .. roundedPct .. '%|r')
end

function Update:HealthText(frame)
    if (not frame.unit or not frame.Health) then return end
    local health, maxHealth = UnitHealth(frame.unit), UnitHealthMax(frame.unit)
    if maxHealth <= 0 then return end
    local hM = health / maxHealth
    if (not health) then return end
    if lastHealth[frame.unit] == hM then
        return
    end
    lastHealth[frame.unit] = hM

    frame.Health:SetText(getCachedString(string.format("%.1fk", health / 1000)))
end

function Update:PowerText(frame)
    if (not frame or not frame.unit or not frame.Power) then return end
    local power, maxPower
    local Display = Ether.DB.POWER.DISPLAY
    if Display == 'Power' then
        power, maxPower = UnitPower(frame.unit), UnitPowerMax(frame.unit)
    else
        power, maxPower = UnitPower(frame.unit, Enum.PowerType[Display]),
            UnitPowerMax(frame.unit, Enum.PowerType[Display])
    end
    if maxPower <= 0 then return end
    local pM = power / maxPower

    if lastPower[frame.unit] == pM then
        return
    end
    lastPower[frame.unit] = pM
    frame.Power:SetText(getCachedString(string.format("%.1fk", power / 1000)))
end

function Update:HealthBar(frame)
    if (not frame or not frame.unit or not frame.healthBar) then return end
    local health, maxHealth = UnitHealth(frame.unit), UnitHealthMax(frame.unit)
    local _, classFileName = UnitClass(frame.unit)

    frame.healthBar:SetMinMaxValues(0, maxHealth)
    frame.healthBar:SetValue(health)

    local r, g, b = Update:GetClassColors(frame, classFileName)
    frame.healthBar:SetStatusBarColor(r, g, b, 1)
    frame.healthBar.bg:SetVertexColor(r * 0.3, g * 0.3, b * 0.3, 1)
end


function Update:UpdateRole(frame)
    if not frame.Indicators.role then
        frame.Indicators.role = frame.healthBar:CreateTexture(nil, 'OVERLAY')
        frame.Indicators.role:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
        frame.Indicators.role:SetPoint('RIGHT', 0, 9)
        frame.Indicators.role:SetSize(12, 12)
        frame.Indicators.role:Hide()
    end
    local role = UnitGroupRolesAssigned(frame.unit)
    if (role) then
        if (role == "TANK") then
            frame.Indicators.role:SetTexCoord(0, 19 / 64, 22 / 64, 41 / 64)
            frame.Indicators.role:Show()
        elseif (role == "HEALER") then
            frame.Indicators.role:SetTexCoord(20 / 64, 39 / 64, 1 / 64, 20 / 64)
            frame.Indicators.role:Show()
        elseif (role == "DAMAGER") then
            frame.Indicators.role:SetTexCoord(20 / 64, 39 / 64, 22 / 64, 41 / 64)
            frame.Indicators.role:Show()
        else
            frame.Indicators.role:Hide()
        end
    end
end

function Update:UpdateRaidTarget(frame)
    local index = GetRaidTargetIndex(frame.unit)
    if (index) then
        frame.Indicators.raidtarget:Show()
        frame.Indicators.raidtarget:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
        SetRaidTargetIconTexture(frame.Indicators.raidtarget, index)
    else
        frame.Indicators.raidtarget:Hide()
    end
end

function Update:UpdateOffline(frame)
    if not frame.unit then return end
    if not frame.Indicators.offline then
        frame.Indicators.offline = frame.healthBar:CreateTexture(nil, 'OVERLAY')
        frame.Indicators.offline:SetTexture("Interface\\CharacterFrame\\Disconnect-Icon")
        frame.Indicators.offline:SetTexCoord(0, 1, 0, 1)
        frame.Indicators.offline:SetPoint('CENTER', 0, 5)
        frame.Indicators.offline:SetSize(24, 24)
        frame.Indicators.offline:Hide()
    end
    local connection = UnitIsConnected(frame.unit)
    if (not connection) then
        frame.Indicators.offline:Show()
    else
        frame.Indicators.offline:Hide()
    end
end

local function EnableOffline()
    if not button.Indicators.offline then
        button.Indicators.offline = button.healthBar:CreateTexture(nil, 'OVERLAY')
        button.Indicators.offline:SetTexture("Interface\\CharacterFrame\\Disconnect-Icon")
        button.Indicators.offline:SetTexCoord(0, 1, 0, 1)
        button.Indicators.offline:SetPoint('BOTTOM', button.Name, 'TOP', 0, 1)
        button.Indicators.offline:SetSize(24, 24)
        button.Indicators.offline:Hide()
    end
end


function Update:RaidTargets(frame)
    if not frame.Indicators.raidtarget then
        frame.Indicators.raidtarget = frame.healthBar:CreateTexture(nil, 'OVERLAY')
        frame.Indicators.raidtarget:SetPoint('BOTTOM', -2, 1)
        frame.Indicators.raidtarget:SetSize(12, 12)
        frame.Indicators.raidtarget:Hide()
    end

    frame:RegisterUpdateFunc(self, "UpdateRaidTarget")
end

function Update:HealPrediction(frame)
    if (not frame or not frame.unit or not frame.healthBar) then return end

    local myIncomingHeal = UnitGetIncomingHeals(frame.unit, 'player') or 0
    local allIncomingHeal = UnitGetIncomingHeals(frame.unit) or 0
    local healAbsorb = UnitGetTotalHealAbsorbs(frame.unit) or 0

    local otherIncomingHeal = 0

    if healAbsorb > allIncomingHeal then
        allIncomingHeal = 0
        myIncomingHeal = 0
    else
        otherIncomingHeal = math.max(0, allIncomingHeal - myIncomingHeal)
        myIncomingHeal = math.min(myIncomingHeal, allIncomingHeal)
    end

    if frame.playerBar then
        if myIncomingHeal > 0 then
            frame.playerBar:Show()
        else
            frame.playerBar:Hide()
        end
    end

    if frame.enemyBar then
        if otherIncomingHeal > 0 then
            frame.enemyBar:Show()
        else
            frame.enemyBar:Hide()
        end
    end
end

function Update:PowerBar(frame)
    if (not frame or not frame.unit or not frame.powerBar) then return end
    local powerType       = UnitPowerType(frame.unit)
    local power, powerMax = UnitPower(frame.unit), UnitPowerMax(frame.unit)
    frame.powerBar:SetMinMaxValues(0, powerMax)
    frame.powerBar:SetValue(power)
    local r, g, b = Update:GetPowerColors(powerType)
    frame.powerBar:SetStatusBarColor(r, g, b)
    frame.powerBar.bg:SetVertexColor(r * 0.3, g * 0.3, b * 0.3, 0.5)
end

function Update:NameUpdate(frame)
    if (not frame.unit) then return end
    if UnitIsUnit(frame.unit, 'player') then
        frame.Name:SetText('Me')
        frame.Name:SetTextColor(0.9, 0.3, 1.00)
    else
        local unitName = UnitName(frame.unit)
        if (unitName) then
            local substring
            for length = #unitName, 1, -1 do
                substring = utf8sub(unitName, 1, length)
                frame.Name:SetText(substring)
                if frame.Name:GetStringWidth() <= 55 then
                    return
                end
            end
            frame.Name:SetTextColor(1, 1, 1)
        end
    end
end

function Update:RaidName(frame)
    if (not frame.unit) then return end

    if UnitIsUnit(frame.unit, 'player') then
        frame.Name:SetText('Me')
        frame.Name:SetTextColor(0.9, 0.3, 1.00)
    else
        local unitName = UnitName(frame.unit)
        if not nameCache[unitName] then
            nameCache[unitName] = utf8sub(unitName, 1, 3)
        end

        frame.Name:SetText(nameCache[unitName])
        frame.Name:SetTextColor(00.00, 0.80, 1.00)
    end
end

function Update:GetRelativeAnchor(point)
    if (point == 'TOP') then
        return 'BOTTOM', 0, -1
    elseif (point == 'BOTTOM') then
        return 'TOP', 0, 1
    elseif (point == 'LEFT') then
        return 'RIGHT', 1, 0
    elseif (point == 'RIGHT') then
        return 'LEFT', -1, 0
    elseif (point == 'TOPLEFT') then
        return 'BOTTOMRIGHT', 1, -1
    elseif (point == 'TOPRIGHT') then
        return 'BOTTOMLEFT', -1, -1
    elseif (point == 'BOTTOMLEFT') then
        return 'TOPRIGHT', 1, 1
    elseif (point == 'BOTTOMRIGHT') then
        return 'TOPLEFT', -1, 1
    else
        return 'CENTER', 0, 0
    end
end
