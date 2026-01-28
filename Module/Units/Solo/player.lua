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

function Ether:CreateUnitButtons(unit)
    if InCombatLockdown() then
        return
    end
    if not Ether.unitButtons.solo[unit] then
        local button = CreateFrame("Button", "Ether_" .. unit .. "_UnitButton", Ether.Anchor[unit], "EtherUnitTemplate")
        button:SetAllPoints(Ether.Anchor[unit])
        button.unit = unit
        button:SetAttribute("unit", button.unit)
        button:RegisterForClicks("AnyUp")
        button:SetAttribute("*type1", "target")
        button:SetAttribute("*type2", "togglemenu")
        button:SetAttribute("type2", "togglemenu")
        Ether:SetupTooltip(button, button.unit)
        Ether:SetupHealthBar(button, "HORIZONTAL")
        Ether:SetupPowerBar(button)
        Ether:SetupPrediction(button)
        Ether:AddBlackBorder(button)
        Ether:SetupName(button, 10, 0)
        Ether:GetClassColor(button)
        Ether:SetupPowerText(button)
        Ether:SetupHealthText(button)
        Mixin(button.healthBar, SmoothStatusBarMixin)
        Mixin(button.powerBar, SmoothStatusBarMixin)
        if button.unit ~= "player" then
            RegisterUnitWatch(button)
        end
        if button.unit == "targettarget" then
            button:SetScript("OnEvent", Update)
        end
        button:SetScript("OnAttributeChanged", AttributeChanged)
        button:SetScript("OnShow", Show)
        FullUpdate(button, true)
        Ether.unitButtons.solo[button.unit] = button
        return button
    end
end

function Ether:DestroyUnitButtons(unit)
    if Ether.unitButtons.solo[unit] then
        local button = Ether.unitButtons.solo[unit]
        button:Hide()
        button:ClearAllPoints()
        button:SetAttribute("unit", nil)
        button:RegisterForClicks()
        if unit ~= "player" then
            UnregisterUnitWatch(button)
        end
        if unit == "targettarget" then
            button:SetScript("OnEvent", nil)
        end
        button:SetScript("OnAttributeChanged", nil)
        button:SetScript("OnShow", nil)
        Ether.unitButtons.solo[unit] = nil
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
    if not UnitGUID(token) then
        Ether.DebugOutput("Target a group or raid member")
        enabled = false
        return
    end
    if not enabled and not custom then
        local success, msg = pcall(function()
            custom = CreateFrame("Button", "EtherCustomUnitButton", UIParent, "EtherUnitTemplate")
            custom:SetPoint("CENTER")
            custom:SetSize(120, 50)
            local name, unit = ParseGUID("target")
            if not name and not unit then
                return nil
            end
            custom.unit = unit
            custom:SetBackdrop({"Interface\\Tooltips\\UI-Tooltip-Background"})
            custom:SetBackdropColor(0, 0, 0, 1)
            custom:SetAttribute("unit", custom.unit)
            Ether:SetupTooltip(custom, custom.unit)
            Ether:SetupHealthBar(custom, "HORIZONTAL", 120, 40)
            Ether:SetupPowerBar(custom)
            Ether:SetupName(custom, 10)
            custom.name:SetText(name)
            Ether:SetupDrag(custom)
            custom.healthBar:SetStatusBarColor(0.18, 0.54, 0.34)
            custom.healthDrop:SetColorTexture(0.18 * 0.3, 0.54 * 0.3, 0.34 * 0.3, 0.8)
            local r, g, b = Ether:GetPowerColor(custom.unit)
            custom.powerBar:SetStatusBarColor(r, g, b)
            custom.powerDrop:SetColorTexture(r * 0.3, g * 0.3, b * 0.3, 0.4)
            custom.powerBar:SetStatusBarColor(r, g, b)
            custom:RegisterForClicks("AnyUp")
            custom:SetAttribute("*type1", "target")
            custom:SetAttribute("*type2", "togglemenu")
            custom:SetAttribute("type2", "togglemenu")
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

function Ether.registerToTEvents()
    if Ether.unitButtons.solo["targettarget"] then
        for _, key in ipairs({"UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_POWER_UPDATE", "UNIT_MAXPOWER", "UNIT_DISPLAYPOWER", "UNIT_HEAL_PREDICTION"}) do
            Ether.unitButtons.solo["targettarget"]:RegisterUnitEvent(key, "targettarget")
        end
    end
end
