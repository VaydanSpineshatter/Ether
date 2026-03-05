local _,Ether=...
local soloButtons={}
Ether.soloButtons=soloButtons
local function FullUpdate(self)
    Ether:UpdateHealth(self)
    Ether:UpdatePower(self)
    Ether:UpdateName(self,10)
    if Ether.DB[701][1]==1 then
        Ether:UpdateHealthTextRounded(self)
    end
    if Ether.DB[701][2]==1 then
        Ether:UpdatePowerTextRounded(self)
    end
    Ether:InitialHealth(self)
    Ether:InitialPower(self)
end

local function OnAttributeChanged(self)
    self.unit=self:GetAttribute("unit")
    local guid=self.unit and UnitGUID(self.unit)
    if (guid~=self.unitGUID) then
        self.unitGUID=guid
        if (guid) then
            FullUpdate(self)
        end
    end
end

local function Event(self,event)
    if event=="UNIT_HEAL_PREDICTION" then
        Ether:UpdatePrediction(self)
    elseif event=="UNIT_MAXHEALTH" or event=="UNIT_HEALTH" then
        Ether:UpdateHealth(self)
        if Ether.DB[701][1]==1 then
            Ether:UpdateHealthTextRounded(self)
        end
    elseif event=="UNIT_POWER_UPDATE" or event=="UNIT_MAXPOWER" or event=="UNIT_DISPLAYPOWER" then
        Ether:UpdatePower(self)
        if Ether.DB[701][2]==1 then
            Ether:UpdatePowerTextRounded(self)
        end
    end
end

function Ether:CreateUnitButtons(token)
    if InCombatLockdown() then
        return
    end
    local button=CreateFrame("Button","Ether_"..token.."_UnitButton",UIParent,"EtherUnitTemplate")

    button:SetSize(120,40)
    button.unit=token
    button:SetAttribute("unit",button.unit)
    button:SetAttribute("*type1","target")
    button:SetAttribute("*type2","togglemenu")
    Ether:SetupTooltip(button,button.unit)
    Ether:SetupHealthBar(button,"HORIZONTAL")
    Ether:SetupPowerBar(button)
    Ether:SetupPrediction(button)
    Ether:SetupButtonLayout(button)
    Ether:SetupBorderLayout(button,2)
    Ether:SetupName(button,0)
    Ether:SetupUpdateText(button,"health")
    Ether:SetupUpdateText(button,"power",true)
    button.Smooth=true
    button.RaidTarget=button.healthBar:CreateTexture(nil,"OVERLAY")
    button.RaidTarget:SetSize(18,18)
    button.RaidTarget:SetPoint("LEFT",button.healthBar,"LEFT",5,0)
    if button.unit~="player" then
        RegisterUnitWatch(button)
    end
    button:RegisterUnitEvent("UNIT_HEALTH",button.unit)
    button:RegisterUnitEvent("UNIT_MAXHEALTH",button.unit)
    button:RegisterUnitEvent("UNIT_POWER_UPDATE",button.unit)
    button:RegisterUnitEvent("UNIT_MAXPOWER",button.unit)
    button:RegisterUnitEvent("UNIT_DISPLAYPOWER",button.unit)
    button:RegisterUnitEvent("UNIT_HEAL_PREDICTION",button.unit)
    button:HookScript("OnAttributeChanged",OnAttributeChanged)
    button:SetScript("OnEvent",Event)
    button:RegisterForDrag("LeftButton")
    button:EnableMouse(true)
    button:SetMovable(true)
    if not InCombatLockdown() then
        button:RegisterForClicks("AnyUp")
    end
    for index,data in ipairs({"player","target","targettarget","pet","pettarget","focus"}) do
        if button.unit==data then
            Ether:ApplyFramePosition(button,index+2)
            Ether:SetupDrag(button,index+2,10)
            break
        end
    end

    OnAttributeChanged(button)
    soloButtons[button.unit]=button
    return button
end

function Ether:DestroyUnitButtons(unit)
    if soloButtons[unit] then
        local button=soloButtons[unit]
        if unit=="player" then
            Ether:CastBarDisable("player")
        end
        if unit=="target" then
            Ether:CastBarDisable("target")
        end
        button:Hide()
        button:ClearAllPoints()
        button:SetAttribute("unit",nil)
        button:RegisterForClicks()
        if unit~="player" then
            UnregisterUnitWatch(button)
        end
        button:SetScript("OnAttributeChanged",nil)
        button:SetScript("OnEvent",nil)
        button:SetScript("OnDragStart",nil)
        button:SetScript("OnDragStop",nil)
        soloButtons[unit]=nil
    end
end

