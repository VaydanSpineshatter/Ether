local _, Ether = ...

local anchor = CreateFrame("Frame", "EtherMaintankAnchor", UIParent, "SecureFrameTemplate")
Ether.Anchor.maintank = anchor
local header = CreateFrame("Frame", "EtherMaintankHeader", anchor, "SecureGroupHeaderTemplate")

local U_GUID = UnitGUID
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
    local guid = self.unit and U_GUID(self.unit)
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
    if (InCombatLockdown()) then
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
    local guid = U_GUID(unit)
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
    if not U_GUID(token) then
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

local function MTInitial(self)
    C_After(0.1, function()
        Ether.InitialHealth(self)
        Ether.UpdateHealthAndMax(self)
        Ether.UpdateName(self)
    end)
end

local function MTAttributeChanged(self)
    self.unit = self:GetAttribute("unit")
    local guid = self.unit and U_GUID(self.unit)
    if (guid ~= self.unitGUID) then
        self.unitGUID = guid
        if (guid) then
            MTInitial(self)
        end
    end
end

local function MTShow(self)
    self.unit = self:GetAttribute("unit")
    MTInitial(self)
end

function Ether:CreateMainTankHeader()
    if (InCombatLockdown()) then
        return
    end
    header:SetPoint("TOPLEFT", anchor, "TOPLEFT")
    header:SetAttribute("template", "EtherUnitTemplate")
    header:SetAttribute("point", "LEFT")
    header:SetAttribute("columnAnchorPoint", "LEFT")
    header:SetAttribute("roleFilter", "MAINTANK")
    header:SetAttribute("showRaid", true)
    header:SetAttribute("strictFiltering", true)
    header:SetAttribute("ButtonHeight", 35)
    header:SetAttribute("ButtonWidth", 95)
    header:SetAttribute("xOffset", 1)
    header:SetAttribute("yOffset", -1)
    header:SetAttribute("columnSpacing", 2)
    header:SetAttribute("initialConfigFunction", [[
    RegisterUnitWatch(self)
    local header = self:GetParent()
    self:SetWidth(header:GetAttribute("ButtonWidth"))
    self:SetHeight(header:GetAttribute("ButtonHeight"))
    self:SetAttribute("*type1", "target")
    self:SetAttribute("*type2", "togglemenu")
   	local unit = self:GetAttribute("unit")
]])

    header:SetAttribute("unitsPerColumn", 4)
    header:SetAttribute("maxColumns", 1)
    header:SetAttribute("startingIndex", -3)
    header:Show()
    header:SetAttribute("startingIndex", 1)

    for i, b in ipairs(header) do
        local unit = "raid" .. i
        b.unit = unit
        b:SetAttribute("unit", b.unit)
        local healthBar = CreateFrame("StatusBar", nil, b)
        b.healthBar = healthBar
        healthBar:SetPoint("TOPLEFT")
        healthBar:SetSize(95, 35)
        healthBar:SetOrientation("HORIZONTAL")
        healthBar:SetStatusBarTexture(unpack(Ether.mediaPath.NewBar))
        healthBar:SetMinMaxValues(0, 100)
        healthBar:SetFrameLevel(b:GetFrameLevel() + 1)
        local healthDrop = b:CreateTexture(nil, "ARTWORK", nil, -7)
        b.healthDrop = healthDrop
        healthDrop:SetAllPoints(healthBar)
        healthBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -7)
        Ether.Setup.CreatePrediction(b)
        Ether.Setup.CreateBorder(b)
        Ether.Setup.CreateNameText(b, 10, 0)
        Ether.GetClassColor(b)
        b:SetAttribute("unit", b.unit)
        b:RegisterForClicks("AnyUp")
        b:SetScript("OnShow", MTShow)
        b:HookScript("OnAttributeChanged", MTAttributeChanged)
        b:SetScript("OnEnter", Ether.OnEnter)
        b:SetScript("OnLeave", Ether.OnLeave)
        Ether.Buttons.maintank[b.unit] = b
    end
end
