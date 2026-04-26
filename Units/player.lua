local D,F=unpack(select(2,...))
local UnitGUID=UnitGUID
local soloBtn=D.soloBtn
local function OnAttributeChanged(self)
    self.unit=self:GetAttribute("unit")
    local guid=self.unit and UnitGUID(self.unit)
    if (guid~=self.unitGUID) then
        self.unitGUID=guid
        if (guid) then
            F:FullHealthUpdate(self)
            F:FullPowerUpdate(self)
            F:UpdateName(self,6)
        end
    end
end
function F:CreateUnitButtons(index)
    local unit=D:PosUnit(index)
    local b=CreateFrame("Button","Ether_"..unit.."_UnitButton",UIParent,"EtherUnitTemplate")
    b.unit=unit
    b.index=index
    local name=b:GetName()
    local healthBar=CreateFrame("StatusBar",name.."_HealthBar",b)
    b.healthBar=healthBar
    healthBar:SetOrientation("HORIZONTAL")
    healthBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
    healthBar:GetStatusBarTexture():SetDrawLayer("ARTWORK",-7)
    healthBar:SetMinMaxValues(0,100)
    healthBar:SetFrameLevel(b:GetFrameLevel()+3)
    local powerBar=CreateFrame("StatusBar",name.."_PowerBar",b)
    b.powerBar=powerBar
    powerBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
    powerBar:GetStatusBarTexture():SetDrawLayer("ARTWORK",-7)
    powerBar:SetFrameLevel(b:GetFrameLevel()+3)
    powerBar:SetMinMaxValues(0,100)
    local healthDrop=b:CreateTexture(name.."_HealthDrop","ARTWORK",nil,-7)
    b.healthDrop=healthDrop
    healthDrop:SetAllPoints()
    local powerDrop=b:CreateTexture(name.."_PowerDrop","ARTWORK",nil,-7)
    b.powerDrop=powerDrop
    powerDrop:SetAllPoints(powerBar)
    powerBar:SetPoint("BOTTOMLEFT")
    powerBar:SetPoint("BOTTOMRIGHT")
    healthBar:SetPoint("TOPLEFT")
    healthBar:SetPoint("TOPRIGHT")
    healthBar:SetPoint("BOTTOM",powerBar,"TOP",0,1)
    b.RaidTarget=b.healthBar:CreateTexture(nil,"OVERLAY")
    b.RaidTarget:SetSize(12,12)
    b.RaidTarget:SetPoint("TOPRIGHT",b.healthBar,"TOPRIGHT")
    b.UnitConnection=b.healthBar:CreateTexture(nil,"OVERLAY")
    b.UnitConnection:SetSize(24,24)
    b.UnitConnection:SetPoint("TOPLEFT",b.healthBar,"TOPLEFT")
    b:SetScript("OnSizeChanged",function(_,_,height)
        local pH=height*0.15
        powerBar:SetHeight(pH)
    end)
    if b.unit=="player" or b.unit=="target" or b.unit=="targettarget" then
        Mixin(healthBar,SmoothStatusBarMixin)
        Mixin(powerBar,SmoothStatusBarMixin)
        b.smooth=true
    end
    F:SetupTooltip(b,b.unit)
    F:SetupPrediction(b)
    F:SetupButtonBackground(b)
    F:SetupButtonBorder(b)
    F:SetupName(b,0)
    F.UpdateClassColor(b)
    F.DisplayPower(b)
    if not InCombatLockdown() then
        b:SetAttribute("unit",b.unit)
        b:SetAttribute("*type1","target")
        b:SetAttribute("*type2","togglemenu")
        b:RegisterForClicks("AnyUp")
        b:RegisterForDrag("LeftButton")
    end
    if b.unit~="player" then
        RegisterUnitWatch(b)
    end
    b:HookScript("OnAttributeChanged",OnAttributeChanged)
    OnAttributeChanged(b)
    soloBtn[b.index]=b
    D:ApplyFramePosition(b)
    F:SetupDrag(b)
end
function F:ActivateUnitButton(index)
    local b=soloBtn[index]
    if not b then return end
    local unit=D:PosUnit(index)
    b.unit=unit
    if not InCombatLockdown() then
        b:SetAttribute("unit",b.unit)
        b:SetAttribute("*type1","target")
        b:SetAttribute("*type2","togglemenu")
        b:RegisterForClicks("AnyUp")
        b:RegisterForDrag("LeftButton")
        b.unit=nil
        b.unitGUID=nil
    end
    if unit~="player" then
        RegisterUnitWatch(b)
    end
    b:EnableMouse(true)
    b:SetMovable(true)
    D:ApplyFramePosition(b)
    F:SetupDrag(b)
    OnAttributeChanged(b)
    b:Show()
end
function F:DeactivateUnitButton(index)
    if soloBtn[index] then
        local b=soloBtn[index]
        b:Hide()
        b:ClearAllPoints()
        if not InCombatLockdown() then
            b:SetAttribute("unit",nil)
            b:SetAttribute("*type1",nil)
            b:SetAttribute("*type2",nil)
            b:RegisterForClicks()
            b:RegisterForDrag()
        end
        b:EnableMouse(false)
        b:SetMovable(false)
        if b.unit~="player" then
            UnregisterUnitWatch(b)
        end
        b:SetScript("OnDragStart",nil)
        b:SetScript("OnDragStop",nil)
    end
end
