local _, Ether = ...

local C_After = C_Timer.After
local C_Ticker = C_Timer.NewTicker

local function FullUpdate(self)
    C_After(0.1, function()
        Ether.InitialHealth(self)
        Ether.InitialPower(self)
    end)
    Ether.UpdateHealthAndMax(self)
    Ether.UpdateName(self)
    if Ether.DB[701][1] == 1 then
        Ether.UpdateHealthText(self)
    end
    Ether.UpdatePowerAndMax(self)
    if Ether.DB[701][2] == 1 then
        Ether.UpdatePowerText(self)
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
    C_After(0.05, function()
        FullUpdate(self)
    end)
end

local function Update(self, event, unit)
    if self.unit ~= unit then return end
    if not Ether.DB[901]["targettarget"] or self.unit ~= "targettarget" then
        return
    end
    local button = Ether.unitButtons["targettarget"]

    if event == "UNIT_HEAL_PREDICTION" then
        Ether.UpdatePrediction(button)
    elseif event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH" then
        Ether.UpdateHealthAndMax(button)
        if Ether.DB[701][1] == 1 then
            Ether.UpdateHealthText(button)
        end
    elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" then
        Ether.UpdatePowerAndMax(button)
        if Ether.DB[701][2] == 1 then
            Ether.UpdatePowerText(button)
        end
    end
end

function Ether:CreateUnitButtons(unit)
    if InCombatLockdown() then
        return
    end
    if not Ether.unitButtons[unit] then
        local button = CreateFrame("Button", "Ether_" .. unit .. "_UnitButton", Ether.Anchor[unit], "EtherUnitTemplate")
        button:SetAllPoints(Ether.Anchor[unit])
        button.unit = unit
        button:SetAttribute("unit", button.unit)
        button:RegisterForClicks("AnyUp")
        button:SetAttribute("*type1", "target")
        button:SetAttribute("*type2", "togglemenu")
        button:SetAttribute("type2", "togglemenu")
        button.Indicators = {}
        Ether.Setup.CreateTooltip(button, button.unit)
        Ether.Setup.CreateHealthBar(button, "HORIZONTAL")
        Ether.Setup.CreatePowerBar(button)
        Ether.Setup.CreatePrediction(button)
        Ether.AddBlackBorder(button)
        Ether.Setup.CreateNameText(button, 10, 0)
        Ether.GetClassColor(button)
        Ether.Setup.CreatePowerText(button)
        Ether.Setup.CreateHealthText(button)
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
        Ether.InitialHealth(button)
        Ether.InitialPower(button)

        FullUpdate(button)

        Ether.unitButtons[button.unit] = button

        return button
    end
end

function Ether:DestroyUnitButtons(unit)
    if Ether.unitButtons[unit] then
        local button = Ether.unitButtons[unit]
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
        Ether.unitButtons[unit] = nil
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
            custom:SetAttribute("unit", custom.unit)
            Ether.Setup.CreateTooltip(custom, custom.unit)
            Ether.Setup.CreateHealthBar(custom, "HORIZONTAL")
            Ether.Setup.CreatePowerBar(custom)
            Ether.Setup.CreateNameText(custom, 10)

            custom.name:SetText(name)
            Ether.Setup:CreateDrag(custom)
            custom.healthBar:SetStatusBarColor(0.18, 0.54, 0.34)
            custom.healthDrop:SetColorTexture(0.18 * 0.3, 0.54 * 0.3, 0.34 * 0.3, 0.8)
            local r, g, b = Ether.GetPowerColor(custom.unit)
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
