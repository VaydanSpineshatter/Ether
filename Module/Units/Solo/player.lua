local _, Ether = ...
local C_Ticker = C_Timer.NewTicker

local function FullUpdate(self)
    C_Timer.After(0.1, function()
        Ether:InitialHealth(self)
        Ether:InitialPower(self)
    end)
    Ether:UpdateHealth(self)
    Ether:UpdateName(self)
    if Ether.DB[701][1] == 1 then
        Ether:UpdateHealthText(self)
    end
    Ether:UpdatePower(self)
    if Ether.DB[701][2] == 1 then
        Ether:UpdatePowerText(self)
    end
end

local function AttributeChanged(self)
    local guid = self.unit and UnitGUID(self.unit)
    if (guid ~= self.unitGUID) then
        self.unitGUID = guid
        if (guid) then
            FullUpdate(self)
        end
    end
end

local function Show(self)
    FullUpdate(self)
end

local function Update(_, event, unit)
    if not unit or not UnitExists("targettarget") then return end
    if not Ether.DB[901]["targettarget"] then return end
    if event == "UNIT_HEAL_PREDICTION" then
        Ether:UpdatePrediction(Ether.unitButtons.solo["targettarget"])
    elseif event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH" then
        Ether:UpdateHealth(Ether.unitButtons.solo["targettarget"])
        if Ether.DB[701][1] == 1 then
            Ether:UpdateHealthText(Ether.unitButtons.solo["targettarget"])
        end
    elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" then
        Ether:UpdatePower(Ether.unitButtons.solo["targettarget"])
        if Ether.DB[701][2] == 1 then
            Ether:UpdatePowerText(Ether.unitButtons.solo["targettarget"])
        end
    end
end

local units = {
    [1] = "player",
    [2] = "target",
    [3] = "targettarget",
    [4] = "pet",
    [5] = "pettarget",
    [6] = "focus"
}

local function OnDrag(self)
    if not Ether.IsMovable then return end
    if self:IsMovable() then
        self:StartMoving()
    end
end

local function SnapToGrid(x, y, gridSize)
    local snappedX = math.floor((x + gridSize/2) / gridSize) * gridSize
    local snappedY = math.floor((y + gridSize/2) / gridSize) * gridSize
    return snappedX, snappedY
end

local function StopDrag(self)
    if not Ether.IsMovable then return end
    if self:IsMovable() then
        self:StopMovingOrSizing()
    end

    local point, relTo, relPoint, x, y = self:GetPoint(1)
    local relToName = "UIParent"

    if relTo then
        if relTo == UIParent then
            relToName = "UIParent"
        elseif relTo.GetName and relTo:GetName() then
            relToName = relTo:GetName()
        end
    end
     local snappedX, snappedY = SnapToGrid(x, y, 20)

    local frameID
    for key, value in ipairs({332, 333, 334, 335, 336, 337}) do
        if self.unit == units[key] then
            frameID = value
            break
        end
    end

    if frameID and Ether.DB[5111] and Ether.DB[5111][frameID] then
        local DB = Ether.DB[5111][frameID]
        DB[1] = point
        DB[2] = relToName
        DB[3] = relPoint
        DB[4] = snappedX
        DB[5] = snappedY

        local anchorRelTo = (relToName == "UIParent") and UIParent or _G[relToName]
        if anchorRelTo then
            self:ClearAllPoints()
            self:SetPoint(point, anchorRelTo, relPoint, snappedX, snappedY)
        end
    end
end

function Ether:CreateUnitButtons(index)
    if InCombatLockdown() or type(index) ~= "number" then
        return
    end
    if not Ether.unitButtons.solo[units[index]] then
        local button = CreateFrame("Button", "Ether_" .. units[index] .. "_UnitButton", UIParent, "EtherUnitTemplate")
        button.unit = units[index]
        button:SetSize(120, 50)
        button:SetAttribute("unit", button.unit)
        button:RegisterForClicks("AnyUp")
        button:SetAttribute("*type1", "target")
        button:SetAttribute("*type2", "togglemenu")
        Ether:SetupTooltip(button, button.unit)
        Ether:SetupHealthBar(button, "HORIZONTAL", 120, 40)
        Ether:SetupPowerBar(button)
        Ether:SetupPrediction(button)
        local background = button:CreateTexture(nil, "BACKGROUND")
        background:SetColorTexture(0, 0, 0, .6)
        background:SetPoint("TOPLEFT", button, "TOPLEFT", -2, 2)
        background:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
        Ether:SetupName(button, 0)
        Ether:GetClassColor(button)
        Ether:SetupUpdateText(button, "health")
        Ether:SetupUpdateText(button, "power", true)
        Mixin(button.healthBar, SmoothStatusBarMixin)
        Mixin(button.powerBar, SmoothStatusBarMixin)
        button.Smooth = true
        if button.unit ~= "targettarget" then
            button.RaidTarget = button.healthBar:CreateTexture(nil, "OVERLAY")
            button.RaidTarget:SetSize(18, 18)
            button.RaidTarget:SetPoint("LEFT", button.healthBar, "LEFT", 5, 0)
        end
        if button.unit ~= "player" then
            RegisterUnitWatch(button)
        end
        if button.unit == "targettarget" then
            for _, key in ipairs({"UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_POWER_UPDATE", "UNIT_MAXPOWER", "UNIT_DISPLAYPOWER", "UNIT_HEAL_PREDICTION"}) do
                button:RegisterUnitEvent(key, "targettarget")
            end
            button:SetScript("OnEvent", Update)
        end
        button:SetScript("OnAttributeChanged", AttributeChanged)
        button:SetScript("OnShow", Show)
        button:RegisterForDrag("LeftButton")
        button:EnableMouse(true)
        button:SetMovable(true)
        button:SetScript("OnDragStart", OnDrag)
        button:SetScript("OnDragStop", StopDrag)
        FullUpdate(button, true)
        Ether.unitButtons.solo[button.unit] = button
        if button.unit == "player" then
            if Ether.DB[801][1] == 1 then
                Ether:CastBarEnable("player")
            end
        end
        if button.unit == "target" then
            if Ether.DB[801][2] == 1 then
                Ether:CastBarEnable("target")
            end
        end
        if button.unit == "pet" then
            Ether:PetCondition(button)
        end
        for key, value in ipairs({332, 333, 334, 335, 336, 337}) do
            if Ether.DB[201][key] == 1 then
                Ether:ApplyFramePosition(value)
            end
        end
        return button
    end
end

function Ether:DestroyUnitButtons(index)
    if Ether.unitButtons.solo[units[index]] then
        local button = Ether.unitButtons.solo[units[index]]
        button.unit = units[index]
        if button.unit == "player" then
            Ether:CastBarDisable("player")
        end
        if button.unit == "target" then
            Ether:CastBarDisable("target")
        end
        button:Hide()
        button:ClearAllPoints()
        button:SetAttribute("unit", nil)
        button:RegisterForClicks()
        if button.unit ~= "player" then
            UnregisterUnitWatch(button)
        end
        if button.unit == "targettarget" then
            button:UnregisterAllEvents()
            button:SetScript("OnEvent", nil)
        end
        button:SetScript("OnAttributeChanged", nil)
        button:SetScript("OnShow", nil)
        button:SetScript("OnDragStart", nil)
        button:SetScript("OnDragStop", nil)
        Ether.unitButtons.solo[button.unit] = nil
    end
end

local custom = nil
local updateTicker = nil
local enabled = false

local function updateCustom(self, token)
    local health, healthMax = UnitHealth(token), UnitHealthMax(token)
    if self.healthBar and healthMax > 0 then
        self.healthBar:SetMinMaxValues(0, healthMax)
        self.healthBar:SetValue(health)
    end
    local power, powerMax = UnitPower(token), UnitPowerMax(token)
    if self.powerBar and powerMax > 0 then
        self.powerBar:SetMinMaxValues(0, powerMax)
        self.powerBar:SetValue(power)
    end
end

local function updateFunc(self, token)
    if not updateTicker and not enabled then
        enabled = true
        updateTicker = C_Ticker(0.1, function()
            updateCustom(self, token)
        end)
    end
end

function Ether.stopUpdateFunc()
    if updateTicker and custom then
        updateTicker:Cancel()
        custom:RegisterForClicks()
        custom:RegisterForDrag()
        custom:Hide()
        custom:ClearAllPoints()
        custom:SetScript("OnDragStart", nil)
        custom:SetScript("OnDragStop", nil)
        custom:SetScript("OnEnter", nil)
        custom:SetScript("OnLeave", nil)
        custom = nil
        updateTicker = nil
        enabled = false
    end
end

local function ParseGUID(unit)
    local guid = UnitGUID(unit)
    local name = UnitName(unit)
    local tokenGuid = UnitTokenFromGUID(guid)
    if guid and tokenGuid then
        return name, tokenGuid
    end
end

function Ether.CreateCustomUnit()
    if InCombatLockdown() then
        return
    end
    local token = "target"
    if not UnitGUID(token) or not UnitInAnyGroup("player") then
        Ether.DebugOutput("Target a group or raid member")
        enabled = false
        return
    end
    if not enabled and not custom then
        local success, msg = pcall(function()
            custom = CreateFrame("Button", "EtherCustomUnitButton", UIParent, "EtherUnitTemplate")
            custom:SetPoint("TOPLEFT", 20, -200)
            custom:SetSize(120, 50)
            local name, unit = ParseGUID("target")
            if not name and not unit then
                return nil
            end
            custom.unit = unit
            Ether:SetupAttribute(custom, custom.unit)
            Ether:SetupTooltip(custom, custom.unit)
            Ether:SetupHealthBar(custom, "HORIZONTAL", 120, 40)
            local background = custom:CreateTexture(nil, "BACKGROUND")
            background:SetColorTexture(0, 0, 0, .6)
            background:SetPoint("TOPLEFT", custom, "TOPLEFT", -2, 2)
            background:SetPoint("BOTTOMRIGHT", custom, "BOTTOMRIGHT", 2, -2)
            local r, g, b = Ether:GetClassColors(custom.unit)
            custom.healthBar:SetStatusBarColor(r, g, b, .8)
            custom.healthDrop:SetColorTexture(r * 0.3, g * 0.3, b * 0.4)
            Ether:SetupPowerBar(custom)
            Ether:SetupName(custom, 0)
            custom.name:SetText(name)
            local re, ge, be = Ether:GetPowerColor(custom.unit)
            custom.powerBar:SetStatusBarColor(re, ge, be, .6)
        end)
        if not success then
            Ether.DebugOutput("Custom unit creation failed - ", msg)
            Ether.stopUpdateFunc()
        else
            if not updateTicker then
                updateFunc(custom, custom.unit)
                enabled = true
            end
        end
    end
end
