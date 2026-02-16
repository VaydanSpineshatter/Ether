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
            Ether:UpdateHealthTextRounded(Ether.unitButtons.solo["targettarget"])
        end
    elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" then
        Ether:UpdatePower(Ether.unitButtons.solo["targettarget"])
        if Ether.DB[701][2] == 1 then
            Ether:UpdatePowerTextRounded(Ether.unitButtons.solo["targettarget"])
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
        Ether:SetupHealthBar(button, "HORIZONTAL", 120, 40, button.unit)
        Ether:SetupPowerBar(button, button.unit)
        Ether:SetupPrediction(button)
        button:SetBackdrop({
            bgFile = Ether.DB[811]["background"],
            insets = {left = -2, right = -2, top = -2, bottom = -2}
        })
        Ether:SetupName(button, 0)
        Ether:GetClassColor(button)
        Ether:SetupUpdateText(button, "health")
        Ether:SetupUpdateText(button, "power", true)
        for key, value in ipairs({332, 333, 334, 335, 336, 337}) do
            if button.unit == units[key] then
                Ether:ApplyFramePosition(button, value)
                Ether:SetupDrag(button, value, 20)
                break
            end
        end
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
        FullUpdate(button, true)
        Ether.unitButtons.solo[button.unit] = button
        if button.unit == "player" then
            if Ether.DB[1201][1] == 1 then
                Ether:CastBarEnable("player")
            end
        end
        if button.unit == "target" then
            if Ether.DB[1201][2] == 1 then
                Ether:CastBarEnable("target")
            end
        end
        if button.unit == "pet" then
            Ether:PetCondition(button)
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

