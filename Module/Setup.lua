local _, Ether = ...
local Setup = {}
Ether.Setup = Setup

Ether.Setup.CreatePowerText = function(button)
    local power = button.healthBar:CreateFontString(nil, "OVERLAY")
    button.power = power
    power:SetFont(unpack(Ether.mediaPath.Font), 9, "OUTLINE")
    power:SetPoint("BOTTOMRIGHT")
    power:SetTextColor(1, 1, 1)
    return button
end

Ether.Setup.CreateHealthText = function(button)
    local health = button.healthBar:CreateFontString(nil, "OVERLAY")
    button.health = health
    health:SetFont(unpack(Ether.mediaPath.Font), 9, "OUTLINE")
    health:SetPoint("BOTTOMRIGHT", 0, 10)
    health:SetTextColor(1, 1, 1)
    return button
end

Ether.Setup.CreateNameText = function(button, number, number2)
    local name = button.healthBar:CreateFontString(nil, 'ARTWORK', nil, -7)
    button.name = name
    name:SetFont(unpack(Ether.mediaPath.Font), number, 'OUTLINE')
    name:SetPoint("RIGHT", button.healthBar, "RIGHT", 0, number2)
    name:SetPoint("LEFT", button.healthBar, "LEFT", 0, number2)
    name:SetTextColor(1, 1, 1)
    return button
end

Ether.Setup.CreateBorder = function(button)
    if not button then
        return
    end
    local texture = button:CreateTexture(nil, "BORDER")
    button.texture = texture
    texture:SetPoint("TOPLEFT", -1, 1)
    texture:SetPoint("TOPRIGHT", 1, 1)
    texture:SetPoint("BOTTOMLEFT", -1, -1)
    texture:SetPoint("BOTTOMRIGHT", 1, -1)
    texture:SetColorTexture(0, 0, 0, 1)
    texture:SetSize(1, 1)
end

Ether.Setup.CreateHighlight = function(button)
    local highLight = button:CreateTexture(nil, "HIGHLIGHT")
    highLight:SetPoint("TOPLEFT", -1, 1)
    highLight:SetPoint("TOPRIGHT", 1, 1)
    highLight:SetPoint("BOTTOMLEFT", -1, -1)
    highLight:SetPoint("BOTTOMRIGHT", 1, -1)
    highLight:SetColorTexture(1, 0.65, 0, .2)
    highLight:SetSize(1, 1)
end

Ether.Setup.CreateHealthBar = function(button, orient)
    local healthBar = CreateFrame("StatusBar", nil, button)
    button.healthBar = healthBar
    healthBar:SetPoint("TOPLEFT")
    healthBar:SetSize(120, 40)
    healthBar:SetOrientation(orient)
    healthBar:SetStatusBarTexture(unpack(Ether.mediaPath.NewBar))
    healthBar:SetMinMaxValues(0, 100)
    healthBar:SetFrameLevel(button:GetFrameLevel() + 1)
    local healthDrop = button:CreateTexture(nil, "ARTWORK", nil, -7)
    button.healthDrop = healthDrop
    healthDrop:SetAllPoints(healthBar)
    healthBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -7)
    return button
end

Ether.Setup.CreatePowerBar = function(button)
    local powerBar = CreateFrame('StatusBar', nil, button)
    button.powerBar = powerBar
    powerBar:SetPoint("BOTTOMLEFT")
    powerBar:SetSize(120, 10)
    powerBar:SetStatusBarTexture(unpack(Ether.mediaPath.OldBar))
    powerBar:SetFrameLevel(button:GetFrameLevel() + 1)
    powerBar:SetMinMaxValues(0, 100)
    local powerDrop = button:CreateTexture(nil, "ARTWORK", nil, -7)
    button.powerDrop = powerDrop
    powerDrop:SetAllPoints()
    powerDrop:SetColorTexture(0.1, 0.1, 0.1, 0.4)
    powerBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -7)
    return button
end

Ether.Setup.CreatePrediction = function(button)
    local playerPrediction = CreateFrame('StatusBar', nil, button.healthBar:GetParent())
    button.playerPrediction = playerPrediction
    playerPrediction:SetAllPoints(button.healthBar)
    playerPrediction:SetFrameLevel(button:GetFrameLevel() + 0)
    playerPrediction:SetStatusBarTexture(unpack(Ether.mediaPath.NewBar))
    playerPrediction:SetStatusBarColor(0.70, 0.13, 0.13)
    playerPrediction:SetMinMaxValues(0, 1)
    playerPrediction:SetValue(1)
    playerPrediction:Hide()
    local otherPrediction = CreateFrame('StatusBar', nil, button.healthBar:GetParent())
    button.otherPrediction = otherPrediction
    otherPrediction:SetAllPoints(button.healthBar)
    otherPrediction:SetFrameLevel(button:GetFrameLevel() - 0)
    otherPrediction:SetStatusBarTexture(unpack(Ether.mediaPath.NewBar))
    otherPrediction:SetStatusBarColor(0.80, 0.40, 1.00)
    otherPrediction:SetMinMaxValues(0, 1)
    otherPrediction:SetValue(1)
    otherPrediction:Hide()
    return button
end

Ether.Setup.CreateCastBar = function(button)
    local config = Ether.CastBar.Config
    local frame = CreateFrame("StatusBar", nil, button)
    button.castBar = frame
    frame:SetPoint("TOPLEFT", button.powerBar, "BOTTOMLEFT")
    frame:SetSize(220, 15)
    frame:SetStatusBarTexture(unpack(Ether.mediaPath.StatusBar))
    local drop = frame:CreateTexture(nil, "ARTWORK", nil, -7)
    frame.drop = drop
    drop:SetAllPoints()
    local r, g, b = GetClassColor("player")
    frame:SetStatusBarColor(r, g, b)
    drop:SetColorTexture(r * 0.3, g * 0.3, b * 0.3, 0.8)
    local text = frame:CreateFontString(nil, "OVERLAY")
    text:SetFont(unpack(Ether.mediaPath.Font), 12, 'OUTLINE')
    text:SetPoint("LEFT", 31, 0)

    local time = frame:CreateFontString(nil, "OVERLAY")
    time:SetFont(unpack(Ether.mediaPath.Font), 12, 'OUTLINE')
    time:SetPoint("RIGHT", frame, "RIGHT", -8, 0)

    local icon = frame:CreateTexture(nil, 'OVERLAY')
    icon:SetSize(15, 15)
    icon:SetPoint("LEFT")

    local safeZone = frame:CreateTexture(nil, "OVERLAY")
    safeZone:SetTexture(unpack(Ether.mediaPath.StatusBar))
    safeZone:SetVertexColor(0.70, 0.13, 0.13, 1)
    safeZone:SetBlendMode("ADD")

    frame:Hide()
    frame.text = config.showName and text or nil
    frame.time = config.showTime and time or nil
    frame.icon = config.showIcon and icon or nil
    frame.safeZone = config.showSafeZone and safeZone or nil
    frame.casting = nil
    frame.channeling = nil
    frame.duration = 0
    frame.max = 0
    frame.delay = 0
    frame.timeToHold = 0.1
end

Ether.Setup.CreateTooltip = function(button, unit)
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

function Ether.Setup:GetAttribute(button, unit)
    button:SetAttribute("unit", unit)
    button:SetAttribute("*type1", "target")
    button:SetAttribute("*type2", "togglemenu")
end

function Ether.Setup:CreateDrag(button)
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
function Ether.Setup:CreateGrid()
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
                table.insert(linePool, line)
            end
            if yBottom >= 0 then
                local line = frame:CreateLine()
                line:SetColorTexture(1, 0.5, 0.5, 0.5)
                line:SetThickness(2)
                line:SetStartPoint("TOPLEFT", UIParent, 0, -yBottom)
                line:SetEndPoint("TOPRIGHT", UIParent, screenWidth, -yBottom)
                table.insert(linePool, line)
            end
            local xRight = centerX + offset
            local xLeft = centerX - offset
            if xRight <= screenWidth then
                local line = frame:CreateLine()
                line:SetColorTexture(1, 0.5, 0.5, 0.5)
                line:SetThickness(2)
                line:SetStartPoint("TOPLEFT", UIParent, xRight, 0)
                line:SetEndPoint("BOTTOMLEFT", UIParent, xRight, -screenHeight)
                table.insert(linePool, line)
            end
            if xLeft >= 0 then
                local line = frame:CreateLine()
                line:SetColorTexture(1, 0.5, 0.5, 0.5)
                line:SetThickness(2)
                line:SetStartPoint("TOPLEFT", UIParent, xLeft, 0)
                line:SetEndPoint("BOTTOMLEFT", UIParent, xLeft, -screenHeight)
                table.insert(linePool, line)
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
                    table.insert(linePool, line)
                end
                if yBottom >= 0 then
                    local line = frame:CreateLine()
                    line:SetColorTexture(0.8, 0.8, 0.8, 0.2)
                    line:SetThickness(1)
                    line:SetStartPoint("TOPLEFT", UIParent, 0, -yBottom)
                    line:SetEndPoint("TOPRIGHT", UIParent, screenWidth, -yBottom)
                    table.insert(linePool, line)
                end
                local xRight = centerX + offset
                local xLeft = centerX - offset
                if xRight <= screenWidth then
                    local line = frame:CreateLine()
                    line:SetColorTexture(0.8, 0.8, 0.8, 0.2)
                    line:SetThickness(1)
                    line:SetStartPoint("TOPLEFT", UIParent, xRight, 0)
                    line:SetEndPoint("BOTTOMLEFT", UIParent, xRight, -screenHeight)
                    table.insert(linePool, line)
                end
                if xLeft >= 0 then
                    local line = frame:CreateLine()
                    line:SetColorTexture(0.8, 0.8, 0.8, 0.2)
                    line:SetThickness(1)
                    line:SetStartPoint("TOPLEFT", UIParent, xLeft, 0)
                    line:SetEndPoint("BOTTOMLEFT", UIParent, xLeft, -screenHeight)
                    table.insert(linePool, line)
                end
            end
        end
    end
end

Ether.Setup.CreateReadyCheckTexture = function(self)
    if (not self.Indicators.ReadyCheckIcon) then
        self.Indicators.ReadyCheckIcon = self.healthBar:CreateTexture(nil, "OVERLAY")
        self.Indicators.ReadyCheckIcon:SetSize(18, 18)
        self.Indicators.ReadyCheckIcon:SetPoint("TOP", self.healthBar, "TOP", 0, 0)
        self.Indicators.ReadyCheckIcon:Hide()
    end
end

Ether.Setup.CreateUnitFlagsTexture = function(self)
    if (not self.Indicators.UnitFlagsIcon) then
        self.Indicators.UnitFlagsIcon = self.healthBar:CreateTexture(nil, "OVERLAY")
        self.Indicators.UnitFlagsIcon:SetSize(12, 12)
        self.Indicators.UnitFlagsIcon:SetPoint("TOP")
    end
    return self.Indicators.UnitFlagsIcon
end

Ether.Setup.CreateGroupRoleTexture = function(self)
    if (not self.Indicators.GroupRoleIcon) then
        self.Indicators.GroupRoleIcon = self.healthBar:CreateTexture(nil, 'OVERLAY')
        self.Indicators.GroupRoleIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
        self.Indicators.GroupRoleIcon:SetPoint('RIGHT', 0, 9)
        self.Indicators.GroupRoleIcon:SetSize(12, 12)
        self.Indicators.GroupRoleIcon:Hide()
    end
    return self.Indicators.GroupRoleIcon
end

Ether.Setup.CreateMainTankTexture = function(self)
    if (not self.Indicators.MainTankIcon) then
        self.Indicators.MainTankIcon = self.healthBar:CreateTexture(nil, 'OVERLAY')
        self.Indicators.MainTankIcon:SetPoint("LEFT")
        self.Indicators.MainTankIcon:SetSize(14, 14)
        self.Indicators.MainTankIcon:Show()
    end
    return self.Indicators.MainTankIcon
end

Ether.Setup.CreateConnectionTexture = function(self)
    if (not self.Indicators.ConnectionIcon) then
        self.Indicators.ConnectionIcon = self.healthBar:CreateTexture(nil, "OVERLAY")
        self.Indicators.ConnectionIcon:SetTexture("Interface\\CharacterFrame\\Disconnect-Icon")
        self.Indicators.ConnectionIcon:SetTexCoord(0, 1, 0, 1)
        self.Indicators.ConnectionIcon:SetPoint("TOPLEFT", 2, -2)
        self.Indicators.ConnectionIcon:SetSize(24, 24)
        self.Indicators.ConnectionIcon:Hide()
    end
    return self.Indicators.ConnectionIcon
end

Ether.Setup.CreateRaidTargetTexture = function(self)
    if (not self.Indicators.RaidTargetIcon) then
        self.Indicators.RaidTargetIcon = self.healthBar:CreateTexture(nil, "OVERLAY")
        self.Indicators.RaidTargetIcon:SetPoint("BOTTOM", -2, 1)
        self.Indicators.RaidTargetIcon:SetSize(11, 11)
        self.Indicators.RaidTargetIcon:Hide()
    end
    return self.Indicators.RaidTargetIcon
end

Ether.Setup.CreateResurrectionTexture = function(self)
    if (not self.Indicators.ResurrectionIcon) then
        self.Indicators.ResurrectionIcon = self.healthBar:CreateTexture(nil, "OVERLAY")
        self.Indicators.ResurrectionIcon:SetPoint("CENTER")
        self.Indicators.ResurrectionIcon:SetSize(21, 21)
        self.Indicators.ResurrectionIcon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
        self.Indicators.ResurrectionIcon:Hide()
    end
    return self.Indicators.ResurrectionIcon
end

Ether.Setup.CreateGroupLeaderTexture = function(self)
    if (not self.Indicators.GroupLeaderIcon) then
        self.Indicators.GroupLeaderIcon = self.healthBar:CreateTexture(nil, "OVERLAY")
        self.Indicators.GroupLeaderIcon:SetPoint("RIGHT", 0, -2)
        self.Indicators.GroupLeaderIcon:SetSize(12, 12)
        self.Indicators.GroupLeaderIcon:Hide()
    end
    return self.Indicators.GroupLeaderIcon
end

Ether.Setup.CreateMasterLootTexture = function(self)
    if not self.Indicators.MasterLootIcon then
        self.Indicators.MasterLootIcon = self.healthBar:CreateTexture(nil, "OVERLAY")
        self.Indicators.MasterLootIcon:SetTexture("Interface\\GroupFrame\\UI-Group-MasterLooter")
        self.Indicators.MasterLootIcon:SetPoint("BOTTOMRIGHT", -2, 11)
        self.Indicators.MasterLootIcon:SetSize(10, 10)
        self.Indicators.MasterLootIcon:Hide()
    end
    return self.Indicators.MasterLootIcon
end

Ether.Setup.CreatePlayerFlagsString = function(self)
    if not self.Indicators.PlayerFlagsString then
        self.Indicators.PlayerFlagsString = self.healthBar:CreateFontString(nil, "OVERLAY")
        self.Indicators.PlayerFlagsString:SetFont(unpack(Ether.mediaPath.Font), 9, "OUTLINE")
        self.Indicators.PlayerFlagsString:SetPoint("TOPLEFT", 1, -1)
        self.Indicators.PlayerFlagsString:Hide()
    end
    return self.Indicators.PlayerFlagsString
end

Ether.Setup.SingleAuraIcon = function(button)
    local icon = button:CreateTexture(nil, "OVERLAY")
    icon:SetAllPoints()
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    return icon
end

Ether.Setup.SingleAuraTimer = function(button, icon)
    local timer = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    timer:SetAllPoints(icon)
    timer:SetHideCountdownNumbers(true)
    timer:SetReverse(true)
    timer:SetBlingTexture("Interface\\Cooldown\\star4_edge", 1, 1, 1, 1)
    return timer
end

Ether.Setup.SingleAuraCount = function(button)
    local count = button:CreateFontString(nil, "OVERLAY")
    count:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    count:SetPoint('LEFT')
    count:Hide()
    return count
end

Ether.Setup.CreateDebugFrame = function()
    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    Ether.DebugFrame = frame
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
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
end


--[[

Ether.Setup.PixelPerfect = function(frame)
    local scale = frame:GetEffectiveScale()

    local pixelWidth = frame:GetWidth() / scale
    local pixelHeight = frame:GetHeight() / scale

    local newPixelWidth = math.floor(pixelWidth + 0.5)
    local newPixelHeight = math.floor(pixelHeight + 0.5)

    frame:SetSize(newPixelWidth * scale, newPixelHeight * scale)

    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
    if point then
        local newX = math.floor(xOfs / scale + 0.5) * scale
        local newY = math.floor(yOfs / scale + 0.5) * scale
        frame:ClearAllPoints()
        frame:SetPoint(point, relativeTo, relativePoint, newX, newY)
    end
    return frame
end

local ClassCoordinate           = {
	["WARRIOR"] = { 0, 0.25, 0, 0.25 },
	["MAGE"]    = { 0.25, 0.49609375, 0, 0.25 },
	["ROGUE"]   = { 0.49609375, 0.7421875, 0, 0.25 },
	["DRUID"]   = { 0.7421875, 0.98828125, 0, 0.25 },
	["HUNTER"]  = { 0, 0.25, 0.25, 0.5 },
	["SHAMAN"]  = { 0.25, 0.49609375, 0.25, 0.5 },
	["PRIEST"]  = { 0.49609375, 0.7421875, 0.25, 0.5 },
	["WARLOCK"] = { 0.7421875, 0.98828125, 0.25, 0.5 },
	["PALADIN"] = { 0, 0.25, 0.5, 0.75 }
}
]]

--[[
local function FramesOverlap(frameA, frameB)
	local sA, sB = frameA:GetEffectiveScale(), frameB:GetEffectiveScale();
	return ((frameA:GetLeft()*sA) < (frameB:GetRight()*sB))
		and ((frameB:GetLeft()*sB) < (frameA:GetRight()*sA))
		and ((frameA:GetBottom()*sA) < (frameB:GetTop()*sB))
		and ((frameB:GetBottom()*sB) < (frameA:GetTop()*sA))
end

local function MouseIsOver(frame)
	local x, y = GetCursorPosition();
	local s = frame:GetEffectiveScale();
	x, y = x/s, y/s;
	return ((x >= frame:GetLeft()) and (x <= frame:GetRight())
		and (y >= frame:GetBottom()) and (y <= frame:GetTop()))
end
]]
