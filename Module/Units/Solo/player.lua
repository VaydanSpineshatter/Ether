local _, Ether = ...

local function FullUpdate(self)
    C_Timer.After(0.1, function()
        Ether:InitialHealth(self)
        Ether:InitialPower(self)
    end)
    Ether:UpdateHealth(self)
    Ether:UpdateName(self)
    if Ether.DB[701][1] == 1 then
        Ether:UpdateHealthTextRounded(self)
    end
    Ether:UpdatePower(self)
    if Ether.DB[701][2] == 1 then
        Ether:UpdatePowerTextRounded(self)
    end
end

local function OnAttributeChanged(self)
    local guid = self.unit and UnitGUID(self.unit)
    if (guid ~= self.unitGUID) then
        self.unitGUID = guid
        if (guid) then
            FullUpdate(self)
        end
    end
end

local function Update(self, event, unit)
    if not unit then return end
    if not UnitExists(self.unit) then return end
    if event == "UNIT_HEAL_PREDICTION" then
        Ether:UpdatePrediction(self)
    elseif event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH" then
        Ether:UpdateHealth(self)
        if Ether.DB[701][1] == 1 then
            Ether:UpdateHealthTextRounded(self)
        end
    elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" then
        Ether:UpdatePower(self)
        if Ether.DB[701][2] == 1 then
            Ether:UpdatePowerTextRounded(self)
        end
    end
end

function Ether:CreateUnitButtons(token)
    if InCombatLockdown() then return end
    local button = CreateFrame("Button", "Ether_" .. token .. "_UnitButton", UIParent, "EtherUnitTemplate")
    button.unit = token
    button:SetSize(120, 50)
    button:SetAttribute("unit", button.unit)
    button:RegisterForClicks("AnyUp")
    button:SetAttribute("*type1", "target")
    button:SetAttribute("*type2", "togglemenu")
    Ether:SetupTooltip(button, button.unit)
    Ether:SetupHealthBar(button, "HORIZONTAL", 120, 40)
    Ether:SetupPowerBar(button)
    Ether:SetupPrediction(button)
    button:SetBackdrop({
        bgFile = Ether.DB[811]["background"],
        insets = {left = -2, right = -2, top = -2, bottom = -2}
    })
    Ether:SetupName(button, 0)
    Ether:GetClassColor(button)
    Ether:SetupUpdateText(button, "health")
    Ether:SetupUpdateText(button, "power", true)

    Mixin(button.healthBar, SmoothStatusBarMixin)
    Mixin(button.powerBar, SmoothStatusBarMixin)
    button.Smooth = true

    button.RaidTarget = button.healthBar:CreateTexture(nil, "OVERLAY")
    button.RaidTarget:SetSize(18, 18)
    button.RaidTarget:SetPoint("LEFT", button.healthBar, "LEFT", 5, 0)

    if button.unit ~= "player" then
        RegisterUnitWatch(button)
    end
    button:RegisterUnitEvent("UNIT_HEALTH", button.unit)
    button:RegisterUnitEvent("UNIT_MAXHEALTH", button.unit)
    button:RegisterUnitEvent("UNIT_POWER_UPDATE", button.unit)
    button:RegisterUnitEvent("UNIT_MAXPOWER", button.unit)
    button:RegisterUnitEvent("UNIT_DISPLAYPOWER", button.unit)
    button:RegisterUnitEvent("UNIT_HEAL_PREDICTION", button.unit)
    button:HookScript("OnAttributeChanged", OnAttributeChanged)
    button:HookScript("OnEvent", Update)
    button:RegisterForDrag("LeftButton")
    button:EnableMouse(true)
    button:SetMovable(true)

    local key = {
        [1] = 332,
        [2] = 333,
        [3] = 334,
        [4] = 335,
        [5] = 336,
        [6] = 337
    }
    for index, data in ipairs({"player", "target", "targettarget", "pet", "pettarget", "focus"}) do
        if button.unit == data then
            Ether:ApplyFramePosition(button, key[index])
            Ether:SetupDrag(button, key[index], 10)
            break
        end
    end
    OnAttributeChanged(button)
    Ether.unitButtons.solo[button.unit] = button
    return button

end

function Ether:DestroyUnitButtons(unit)
    if Ether.unitButtons.solo[unit] then
        local button = Ether.unitButtons.solo[unit]
        if unit == "player" then
            Ether:CastBarDisable("player")
        end
        if unit == "target" then
            Ether:CastBarDisable("target")
        end
        button:Hide()
        button:ClearAllPoints()
        button:SetAttribute("unit", nil)
        button:RegisterForClicks()
        if unit ~= "player" then
            UnregisterUnitWatch(button)
        end
        button:SetScript("OnAttributeChanged", nil)
        button:SetScript("OnEvent", nil)
        button:SetScript("OnDragStart", nil)
        button:SetScript("OnDragStop", nil)
        Ether.unitButtons.solo[unit] = nil
    end
end

