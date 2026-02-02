local _, Ether = ...
local math_floor = math.floor
local tinsert = table.insert
local string_format = string.format

function Ether:SetupUpdateText(button, tbl, p)
    if not button or not button.healthBar then return end
    local text = button.healthBar:CreateFontString(nil, "OVERLAY")
    button[tbl] = text
    text:SetFont(unpack(Ether.mediaPath.Font), 9, "OUTLINE")
    text:SetPoint("BOTTOMRIGHT", button.healthBar, "BOTTOMRIGHT", 0, p and 1 or 10)
    text:SetTextColor(1, 1, 1)
    return button
end

function Ether:SetupName(button, number, number2)
    if not button or not button.healthBar then return end
    local name = button.healthBar:CreateFontString(nil, "OVERLAY")
    button.name = name
    name:SetFont(unpack(Ether.mediaPath.Font), number, "OUTLINE")
    name:SetPoint("CENTER", button.healthBar, "CENTER", 0, number2)
    name:SetTextColor(1, 1, 1)
    return button
end

function Ether:SetupHealthBar(button, orient)
    if not button then return end
    local healthBar = CreateFrame("StatusBar", nil, button)
    button.healthBar = healthBar
    healthBar:SetPoint("TOPLEFT")
    healthBar:SetSize(120, 40)
    healthBar:SetOrientation(orient)
    healthBar:SetStatusBarTexture(unpack(Ether.mediaPath.soloBar))
    healthBar:SetMinMaxValues(0, 100)
    healthBar:SetFrameLevel(button:GetFrameLevel() + 1)
    local healthDrop = button:CreateTexture(nil, "ARTWORK", nil, -7)
    button.healthDrop = healthDrop
    healthDrop:SetAllPoints(healthBar)
    healthBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -7)
    return button
end

function Ether:SetupPowerBar(button)
    if not button then return end
    local powerBar = CreateFrame('StatusBar', nil, button)
    button.powerBar = powerBar
    powerBar:SetPoint("BOTTOMLEFT")
    powerBar:SetSize(120, 10)
    powerBar:SetStatusBarTexture(unpack(Ether.mediaPath.powerBar))
    powerBar:SetFrameLevel(button:GetFrameLevel() + 1)
    powerBar:SetMinMaxValues(0, 100)
    local powerDrop = button:CreateTexture(nil, "ARTWORK", nil, -7)
    button.powerDrop = powerDrop
    powerDrop:SetAllPoints()
    powerDrop:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    powerBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -7)
    return button
end

function Ether:SetupPrediction(button)
    if not button or not button.healthBar then return end
    local player = CreateFrame('StatusBar', nil, button.healthBar:GetParent())
    button.myPrediction = player
    player:SetAllPoints(button.healthBar)
    player:SetFrameLevel(button:GetFrameLevel() + 0)
    player:SetStatusBarTexture(unpack(Ether.mediaPath.predictionBar))
    player:SetStatusBarColor(0.70, 0.13, 0.13)
    player:SetMinMaxValues(0, 1)
    player:SetValue(1)
    player:Hide()
    local from = CreateFrame('StatusBar', nil, button.healthBar:GetParent())
    button.otherPrediction = from
    from:SetAllPoints(button.healthBar)
    from:SetFrameLevel(button:GetFrameLevel() - 0)
    from:SetStatusBarTexture(unpack(Ether.mediaPath.predictionBar))
    from:SetStatusBarColor(0.80, 0.40, 1.00)
    from:SetMinMaxValues(0, 1)
    from:SetValue(1)
    from:Hide()
    return button
end

function Ether:SetupCastBar(button)
    if not button then return end
    local frame = CreateFrame("StatusBar", nil, button)
    button.castBar = frame
    frame:SetPoint("TOPLEFT", button.powerBar, "BOTTOMLEFT")
    frame:SetSize(220, 15)
    frame:SetStatusBarTexture(unpack(Ether.mediaPath.predictionBar))
    local drop = frame:CreateTexture(nil, "ARTWORK", nil, -7)
    frame.drop = drop
    drop:SetAllPoints()
    local r, g, b = GetClassColor("player")
    frame:SetStatusBarColor(r, g, b)
    drop:SetColorTexture(r * 0.3, g * 0.3, b * 0.3, 0.8)
    local text = frame:CreateFontString(nil, "OVERLAY")
    frame.text = text
    text:SetFont(unpack(Ether.mediaPath.Font), 12, 'OUTLINE')
    text:SetPoint("LEFT", 31, 0)

    local time = frame:CreateFontString(nil, "OVERLAY")
    frame.time = time
    time:SetFont(unpack(Ether.mediaPath.Font), 12, 'OUTLINE')
    time:SetPoint("RIGHT", frame, "RIGHT", -8, 0)

    local icon = frame:CreateTexture(nil, "OVERLAY")
    frame.icon = icon
    icon:SetSize(15, 15)
    icon:SetPoint("LEFT")

    local safeZone = frame:CreateTexture(nil, "OVERLAY")
    frame.safeZone = safeZone
    safeZone:SetTexture(unpack(Ether.mediaPath.predictionBar))
    safeZone:SetVertexColor(0.70, 0.13, 0.13, 1)
    safeZone:SetBlendMode("ADD")

    frame:Hide()
    frame.casting = nil
    frame.channeling = nil
    frame.duration = 0
    frame.max = 0
    frame.delay = 0
    frame.timeToHold = 0.1
end

function Ether:SetupTooltip(button, unit)
    button:SetScript('OnEnter', function()
        GameTooltip:SetOwner(button, 'ANCHOR_RIGHT')
        GameTooltip:SetUnit(unit)
        GameTooltip:Show()
    end)
    button:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)
    return button
end

function Ether:SetupAttribute(button, unit)
    button:SetAttribute("unit", unit)
    button:SetAttribute("*type1", "target")
    button:SetAttribute("*type2", "togglemenu")
end

function Ether:SetupDrag(button)
    button:SetMovable(true)
    button:SetScript("OnMouseDown", function(self)
        if InCombatLockdown() or self.isMoving then
            return
        end
        if self:IsMovable() then
            self:StartMoving()
            self.isMoving = true
        end
    end)
    button:SetScript("OnMouseUp", function(self)
        if InCombatLockdown() or not self.isMoving then
            return
        end
        if self:IsMovable() then
            self:StopMovingOrSizing()
            self.isMoving = false
        end
    end)
end

local initialGrid = false
function Ether:SetupGridFrame()
    if not initialGrid then
        initialGrid = true
        local frame = CreateFrame("Frame", nil, UIParent)
        Ether.gridFrame = frame
        frame:SetAllPoints(UIParent)
        frame:SetFrameStrata("TOOLTIP")
        frame:SetFrameLevel(1)
        frame:SetAlpha(0.4)
        frame:Hide()
        local screenWidth, screenHeight = GetScreenWidth(), GetScreenHeight()
        local centerX, centerY = screenWidth / 2, screenHeight / 2
        local linePool = {}
        local centerH = frame:CreateLine()
        centerH:SetColorTexture(0, 1, 0, 0.8)
        centerH:SetThickness(4)
        centerH:SetStartPoint("TOPLEFT", UIParent, 0, -centerY)
        centerH:SetEndPoint("TOPRIGHT", UIParent, screenWidth, -centerY)
        local centerV = frame:CreateLine()
        centerV:SetColorTexture(0, 1, 0, 0.8)
        centerV:SetThickness(4)
        centerV:SetStartPoint("TOPLEFT", UIParent, centerX, 0)
        centerV:SetEndPoint("BOTTOMLEFT", UIParent, centerX, -screenHeight)
        for offset = 100, math.max(centerX, centerY), 100 do
            local yTop = centerY + offset
            local yBottom = centerY - offset
            if yTop <= screenHeight then
                local line = frame:CreateLine()
                line:SetColorTexture(1, 0.5, 0.5, 0.5)
                line:SetThickness(2)
                line:SetStartPoint("TOPLEFT", UIParent, 0, -yTop)
                line:SetEndPoint("TOPRIGHT", UIParent, screenWidth, -yTop)
                tinsert(linePool, line)
            end
            if yBottom >= 0 then
                local line = frame:CreateLine()
                line:SetColorTexture(1, 0.5, 0.5, 0.5)
                line:SetThickness(2)
                line:SetStartPoint("TOPLEFT", UIParent, 0, -yBottom)
                line:SetEndPoint("TOPRIGHT", UIParent, screenWidth, -yBottom)
                tinsert(linePool, line)
            end
            local xRight = centerX + offset
            local xLeft = centerX - offset
            if xRight <= screenWidth then
                local line = frame:CreateLine()
                line:SetColorTexture(1, 0.5, 0.5, 0.5)
                line:SetThickness(2)
                line:SetStartPoint("TOPLEFT", UIParent, xRight, 0)
                line:SetEndPoint("BOTTOMLEFT", UIParent, xRight, -screenHeight)
                tinsert(linePool, line)
            end
            if xLeft >= 0 then
                local line = frame:CreateLine()
                line:SetColorTexture(1, 0.5, 0.5, 0.5)
                line:SetThickness(2)
                line:SetStartPoint("TOPLEFT", UIParent, xLeft, 0)
                line:SetEndPoint("BOTTOMLEFT", UIParent, xLeft, -screenHeight)
                tinsert(linePool, line)
            end
        end
        for offset = 20, math.max(centerX, centerY), 20 do
            if offset % 100 ~= 0 then
                local yTop = centerY + offset
                local yBottom = centerY - offset
                if yTop <= screenHeight then
                    local line = frame:CreateLine()
                    line:SetColorTexture(0.8, 0.8, 0.8, 0.2)
                    line:SetThickness(1)
                    line:SetStartPoint("TOPLEFT", UIParent, 0, -yTop)
                    line:SetEndPoint("TOPRIGHT", UIParent, screenWidth, -yTop)
                    tinsert(linePool, line)
                end
                if yBottom >= 0 then
                    local line = frame:CreateLine()
                    line:SetColorTexture(0.8, 0.8, 0.8, 0.2)
                    line:SetThickness(1)
                    line:SetStartPoint("TOPLEFT", UIParent, 0, -yBottom)
                    line:SetEndPoint("TOPRIGHT", UIParent, screenWidth, -yBottom)
                    tinsert(linePool, line)
                end
                local xRight = centerX + offset
                local xLeft = centerX - offset
                if xRight <= screenWidth then
                    local line = frame:CreateLine()
                    line:SetColorTexture(0.8, 0.8, 0.8, 0.2)
                    line:SetThickness(1)
                    line:SetStartPoint("TOPLEFT", UIParent, xRight, 0)
                    line:SetEndPoint("BOTTOMLEFT", UIParent, xRight, -screenHeight)
                    tinsert(linePool, line)
                end
                if xLeft >= 0 then
                    local line = frame:CreateLine()
                    line:SetColorTexture(0.8, 0.8, 0.8, 0.2)
                    line:SetThickness(1)
                    line:SetStartPoint("TOPLEFT", UIParent, xLeft, 0)
                    line:SetEndPoint("BOTTOMLEFT", UIParent, xLeft, -screenHeight)
                    tinsert(linePool, line)
                end
            end
        end
    end
end

local function OnDrag(self)
    if self:IsMovable() then
        self:StartMoving()
    end
end

local function StopDrag(self)
    if self:IsMovable() then
        self:StopMovingOrSizing()
    end

    local point, relTo, relPoint, x, y = self:GetPoint(1)
    local relToName = "UIParent"

    if relTo then
        if relTo.GetName and relTo:GetName() then
            relToName = relTo:GetName()
        elseif relTo == UIParent then
            relToName = "UIParent"
        else
            relToName = "UIParent"
        end
    end

    Ether.DB[5111][339][1] = point
    Ether.DB[5111][339][2] = relToName
    Ether.DB[5111][339][3] = relPoint
    Ether.DB[5111][339][4] = x
    Ether.DB[5111][339][5] = y

    local anchorRelTo = _G[relToName] or UIParent
    self:ClearAllPoints()
    self:SetPoint(
            Ether.DB[5111][339][1],
            anchorRelTo,
            Ether.DB[5111][339][3],
            Ether.DB[5111][339][4],
            Ether.DB[5111][339][5]
    )
end

function Ether:SetupDebugFrame()
    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    Ether.DebugFrame = frame
    frame:SetPoint("CENTER")
    frame:SetSize(320, 200)
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    frame:SetBackdropColor(0.1, 0.1, 0.1, .9)
    frame:SetBackdropBorderColor(0.4, 0.4, 0.4)
    frame:SetSize(320, 200)
    frame:SetFrameStrata("DIALOG")
    local sF = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    sF:SetPoint("TOPLEFT", 10, -30)
    sF:SetPoint("BOTTOMRIGHT", -30, 10)
    local cF = CreateFrame("Frame", nil, sF)
    cF:SetSize(390, 111)
    sF:SetScrollChild(cF)
    local txt = cF:CreateFontString(nil, "OVERLAY")
    Ether.DebugText = txt
    txt:SetFont(unpack(Ether.mediaPath.Font), 12, 'OUTLINE')
    txt:SetPoint("TOPLEFT")
    txt:SetWidth(290)
    txt:SetJustifyH("LEFT")
    local top = frame:CreateFontString(nil, "OVERLAY")
    top:SetFont(unpack(Ether.mediaPath.Font), 12, "OUTLINE")
    top:SetPoint("TOP", 0, -10)
    top:SetText("|cE600CCFFEther|r")
    frame:Hide()
    Ether:FramePosition(339)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", OnDrag)
    frame:SetScript("OnDragStop", StopDrag)
end

local function AuraPosition(i)
    local row = math_floor((i - 1) / 8)
    local col = (i - 1) % 8
    local xOffset = col * (14 + 1)
    local yOffset = 1 + row * (14 + 1)

    return xOffset, yOffset
end

local function SetupAuraIcon(button)
    local icon = button:CreateTexture(nil, "OVERLAY")
    icon:SetAllPoints()
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    return icon
end

local function SetupAuraTimer(button, icon)
    local timer = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    timer:SetAllPoints(icon)
    timer:SetHideCountdownNumbers(true)
    timer:SetReverse(true)
    timer:SetBlingTexture("Interface\\Cooldown\\star4_edge", 1, 1, 1, 1)
    return timer
end

local function SetupAuraCount(button)
    local count = button:CreateFontString(nil, "OVERLAY")
    count:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    count:SetPoint('LEFT')
    count:Hide()
    return count
end

function Ether:SingleAuraSetup(button)
    if not button or not button.unit then return end
    if Ether.DB[1001][1] ~= 1 and Ether.DB[1001][2] ~= 1 and Ether.DB[1001][3] ~= 1 then return end
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

        frame.icon = SetupAuraIcon(frame)
        frame.count = SetupAuraCount(frame)
        frame.timer = SetupAuraTimer(frame, frame.icon)

        frame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetUnitAura(button.unit, i, "HELPFUL")
            GameTooltip:Show()
        end)
        frame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        button.Aura.Buffs[i] = frame
    end

    for i = 1, 16 do
        local frame = CreateFrame("Frame", nil, button)
        frame:SetSize(14, 14)

        local xOffset, yOffset = AuraPosition(i)

        frame:SetPoint("BOTTOMLEFT", button, "TOPLEFT", xOffset - 1, yOffset + 2)

        frame:SetShown(false)

        frame.icon = SetupAuraIcon(frame)
        frame.count = SetupAuraCount(frame)
        frame.timer = SetupAuraTimer(frame, frame.icon)
        local border = frame:CreateTexture(nil, "BORDER")
        border:SetColorTexture(1, 0, 0, 1)
        border:SetPoint("TOPLEFT", -1, 1)
        border:SetPoint("BOTTOMRIGHT", 1, -1)
        border:Hide()
        frame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetUnitAura(button.unit, i, "HARMFUL")
            GameTooltip:Show()
        end)
        frame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        frame.border = border

        button.Aura.Debuffs[i] = frame
    end
end

function Ether:AddBlackBorder(button, scale, r, g, b, a)
    if not button then return end
    local top = button:CreateTexture(nil, "BORDER")
    top:SetColorTexture(r, g, b, a)
    top:SetPoint("TOPLEFT", button, "TOPLEFT", -scale, scale)
    top:SetPoint("TOPRIGHT", button, "TOPRIGHT", scale, scale)
    local bottom = button:CreateTexture(nil, "BORDER")
    bottom:SetColorTexture(r, g, b, a)
    bottom:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", -scale, -scale)
    bottom:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", scale, -scale)
    local left = button:CreateTexture(nil, "BORDER")
    left:SetColorTexture(r, g, b, a)
    left:SetPoint("TOPLEFT", button, "TOPLEFT", -scale, scale)
    left:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", -scale, -scale)
    local right = button:CreateTexture(nil, "BORDER")
    right:SetColorTexture(r, g, b, a)
    right:SetPoint("TOPRIGHT", button, "TOPRIGHT", scale, scale)
    right:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", scale, -scale)
    button.top = top
    button.left = left
    button.right = right
    button.bottom = bottom
    return button
end

function Ether:DispelIconSetup(button)
    local iconFrame = CreateFrame("Frame", nil, button)
    button.iconFrame = iconFrame
    iconFrame:SetSize(12, 12)
    iconFrame:SetPoint("CENTER", 0, 10)
    iconFrame:Hide()
    local dispelIcon = iconFrame:CreateTexture(nil, "OVERLAY")
    button.dispelIcon = dispelIcon
    dispelIcon:SetAllPoints()
    dispelIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    local dispelBorder = iconFrame:CreateTexture(nil, "BORDER")
    button.dispelBorder = dispelBorder
    dispelBorder:SetColorTexture(0, 0, 0, 1)
    dispelBorder:SetPoint("TOPLEFT", -1, 1)
    dispelBorder:SetPoint("BOTTOMRIGHT", 1, -1)
    return button
end

--[[
local function HexToRGB(hex)
    hex = hex:gsub('#', '')
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    return r, g, b
end

local function LeapColor(r1, g1, b1, r2, g2, b2, t)
    return r1 + (r2 - r1) * t, g1 + (g2 - g1) * t, b1 + (b2 - b1) * t
end

local cFF = "|cff%02x%02x%02x"
function Ether:BuildGradientTable(colorDef)
    local steps = {}
    for i = 0, 100 do
        local pct = i / 100
        local prev, nextC
        for idx = 1, #colorDef - 1 do
            if pct >= colorDef[idx][1] and pct <= colorDef[idx + 1][1] then
                prev = colorDef[idx]
                nextC = colorDef[idx + 1]
                break
            end
        end
        if not prev then
            prev, nextC = colorDef[#colorDef - 1], colorDef[#colorDef]
        end
        local pr, pg, pb = HexToRGB(prev[2])
        local nr, ng, nb = HexToRGB(nextC[2])
        local range = (nextC[1] - prev[1])
        local t = range > 0 and (pct - prev[1]) / range or 0

        local r, g, b = LeapColor(pr, pg, pb, nr, ng, nb, t)
        steps[i] = string_format(cFF, r * 255, g * 255, b * 255)
    end
    return steps
end

local ObjPool = {}
function Ether:CreateObjPool(creatorFunc)
    local obj = {
        create = creatorFunc,
        active = {},
        inactive = {},
        temp = {},
        activeCount = 0,
    }
    setmetatable(obj, {__index = ObjPool})
    return obj
end
function ObjPool:Acquire(...)
    if self.activeCount >= 220 then
        return nil
    end
    local obj = table.remove(self.inactive)
    if not obj then
        obj = self.create()
    end
    self.activeCount = self.activeCount + 1
    self.active[self.activeCount] = obj
    obj._poolIndex = self.activeCount
    if obj.Setup then
        obj:Setup(...)
    end
    return obj
end
function ObjPool:Release(obj)
    if not obj or not obj._poolIndex then
        return
    end
    local index = obj._poolIndex
    if index <= 0 or index > self.activeCount then
        return
    end
    local last = self.active[self.activeCount]
    self.active[index] = last
    self.active[self.activeCount] = nil
    if last and last ~= obj then
        last._poolIndex = index
    end
    obj._poolIndex = -1
    self.activeCount = self.activeCount - 1
    if obj.Reset then
        obj:Reset()
    end
    if #self.inactive < 150 then
        self.inactive[#self.inactive + 1] = obj
    end
end
function ObjPool:ReleaseAll()
    for i = 1, self.activeCount do
        self.temp[i] = self.active[i]
    end

    for i = 1, #self.temp do
        self:Release(self.temp[i])
    end

    for i = 1, #self.temp do
        self.temp[i] = nil
    end
end
]]