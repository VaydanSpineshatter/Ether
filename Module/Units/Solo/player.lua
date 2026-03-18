local _,Ether=...
local ipairs=ipairs
local UnitGUID=UnitGUID
local soloButtons={}
local customButtons={}
local castBar={}
Ether.soloButtons=soloButtons
Ether.customButtons=customButtons
Ether.castBar=castBar
local function FullUpdate(self)
    Ether:UpdateHealth(self)
    Ether:UpdatePower(self)
    Ether:UpdateName(self,10)
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
            if self.unit~="player" then
                Ether:UpdateClassColor(self)
                Ether:UpdatePowerColor(self)
            end
        end
    end
end

local function Event(self,event)
    if self:IsVisible() then
        if event=="UNIT_HEAL_PREDICTION" then
            Ether:UpdatePrediction(self)
        elseif event=="UNIT_MAXHEALTH" or event=="UNIT_HEALTH" then
            Ether:UpdateHealth(self)
        elseif event=="UNIT_POWER_UPDATE" or event=="UNIT_MAXPOWER" or event=="UNIT_DISPLAYPOWER" then
            Ether:UpdatePower(self)
        end
    end
end

local unitEvents={"UNIT_HEALTH","UNIT_MAXHEALTH","UNIT_POWER_UPDATE","UNIT_MAXPOWER","UNIT_DISPLAYPOWER","UNIT_HEAL_PREDICTION"}
function Ether:CreateUnitButtons(index)
    local DB=Ether.DB[21][index]
    local unit=Ether:UnitNumber(index)
    local button=CreateFrame("Button","Ether_"..unit.."_UnitButton",UIParent,"EtherUnitTemplate")
    button:SetSize(DB[6] or 110,DB[7] or 35)
    button:SetScale(DB[8] or 1)
    button:SetAlpha(DB[9] or 1)
    button.unit=unit
    if not InCombatLockdown() then
        button:SetAttribute("unit",button.unit)
        button:SetAttribute("*type1","target")
        button:SetAttribute("*type2","togglemenu")
        button:RegisterForClicks("AnyUp")
        button:RegisterForDrag("LeftButton")
    end
    Ether:SetupTooltip(button,button.unit)
    Ether:SetupHealthBar(button,"HORIZONTAL")
    Ether:SetupPowerBar(button)
    Ether:SetupPrediction(button)
    Ether:SetupButtonLayout(button)
    Ether:SetupBorderLayout(button,2)
    Ether:SetupName(button,0)
    Ether:SetupUpdateText(button,"health")
    Ether:SetupUpdateText(button,"power",true)
    button.RaidTarget=button.healthBar:CreateTexture(nil,"OVERLAY")
    button.RaidTarget:SetSize(18,18)
    button.RaidTarget:SetPoint("LEFT",button.healthBar,"LEFT",5,0)
    for _,v in ipairs(unitEvents) do
        button:RegisterUnitEvent(v,button.unit)
    end
    button:EnableMouse(true)
    button:SetMovable(true)
    Ether:UpdateClassColor(button)
    Ether:UpdatePowerColor(button)

    if button.unit~="player" then
        RegisterUnitWatch(button)
    end
    button:HookScript("OnAttributeChanged",OnAttributeChanged)
    button:SetScript("OnEvent",Event)
    OnAttributeChanged(button)
    if button.unit=="player" and button.unit=="target" and button.unit=="pet" then
        if not button.Aura then
            button.Aura={
                Buffs={},
                Debuffs={},
                LastBuffs={},
                LastDebuffs={}
            }
        end
    end
    soloButtons[index]=button
    Ether:ApplyFramePosition(index)
    Ether:SetupDrag(index)
end

function Ether:ActivateUnitButton(index)
    local button=soloButtons[index]
    if not button then return end
    local unit=Ether:UnitNumber(index)
    button.unit=unit
    if not InCombatLockdown() then
        button:SetAttribute("unit",button.unit)
        button:SetAttribute("*type1","target")
        button:SetAttribute("*type2","togglemenu")
        button:RegisterForClicks("AnyUp")
        button:RegisterForDrag("LeftButton")
        button.unit=nil
        button.unitGUID=nil
    end
    for _,v in ipairs(unitEvents) do
        button:RegisterUnitEvent(v,button.unit)
    end
    if unit~="player" then
        RegisterUnitWatch(button)
    end
    button:EnableMouse(true)
    button:SetMovable(true)
    Ether:ApplyFramePosition(index)
    Ether:SetupDrag(index)
    button:SetScript("OnEvent",Event)
    OnAttributeChanged(button)
    button:Show()
end

function Ether:DeactivateUnitButton(index)
    if soloButtons[index] then
        local button=soloButtons[index]
        button:Hide()
        button:ClearAllPoints()
        if not InCombatLockdown() then
            button:SetAttribute("unit",nil)
            button:SetAttribute("*type1",nil)
            button:SetAttribute("*type2",nil)
            button:RegisterForClicks()
            button:RegisterForDrag()
        end
        button:EnableMouse(false)
        button:SetMovable(false)
        button:UnregisterAllEvents()
        if button.unit~="player" then
            UnregisterUnitWatch(button)
        end
        button:SetScript("OnEvent",nil)
        button:SetScript("OnDragStart",nil)
        button:SetScript("OnDragStop",nil)
    end
end

local updateTicker
updateTicker=nil
local C_Ticker=C_Timer.NewTicker
local function updateHealth(button)
    if not button then
        return
    end
    local health,healthMax=UnitHealth(button.unit),UnitHealthMax(button.unit)
    if button.healthBar and healthMax>0 then
        button.healthBar:SetMinMaxValues(0,healthMax)
        button.healthBar:SetValue(health)
    end
end

local function updatePower(button)
    if not button then
        return
    end
    local power,powerMax=UnitPower(button.unit),UnitPowerMax(button.unit)
    if button.powerBar and powerMax>0 then
        button.powerBar:SetMinMaxValues(0,powerMax)
        button.powerBar:SetValue(power)
    end
end

local function updateCustom()
    for i=1,3 do
        updateHealth(customButtons[i])
        updatePower(customButtons[i])
    end
end

local function updateFunc()
    if not updateTicker then
        updateTicker=C_Ticker(0.1,updateCustom)
    end
end

local function DestroyCustom(numb)
    if not customButtons[numb] then
        return
    end
    local button=customButtons[numb]
    button:Hide()
    button:ClearAllPoints()
    button:RegisterForClicks()
    button:RegisterForDrag()
    button:SetAttribute("unit",nil)
    button:SetScript("OnDragStart",nil)
    button:SetScript("OnDragStop",nil)
    button:SetScript("OnEnter",nil)
    button:SetScript("OnLeave",nil)
    button=nil
    customButtons[numb]=nil
end

function Ether:CleanUpCustom(numb)
    if not customButtons[numb] then
        return
    end
    DestroyCustom(numb)
    if not next(customButtons) and updateTicker then
        updateTicker:Cancel()
        if updateTicker:IsCancelled() then
            updateTicker=nil
        else
            Ether:EtherInfo("Custom Updater is not cancelled. Reload UI")
            error("Custom Updater is not cancelled. Reload UI")
        end
    end
end

local function ParseGUID(unit)
    local guid=UnitGUID(unit)
    local name=UnitName(unit)
    local tokenGuid=UnitTokenFromGUID(guid)
    if guid and tokenGuid then
        return name,tokenGuid
    end
end

function Ether:CreateCustomUnit(numb)
    if InCombatLockdown() then return end
    if not UnitGUID("target") or not UnitInAnyGroup("player") then
        Ether:EtherInfo("Target a group or raid member")
        return
    end
    if customButtons[numb] then
        return
    end
    local custom=CreateFrame("Button","EtherCustomUnitButton",UIParent,"EtherUnitTemplate")
    local pos=Ether.DB[21][numb+6]
    custom:SetPoint(pos[1],UIParent,pos[3],pos[4],pos[5])
    custom:SetSize(pos[6] or 110,pos[7] or 40)
    custom:SetScale(pos[8] or 1)
    custom:SetAlpha(pos[9] or 1)
    local name,unit=ParseGUID("target")
    if not name or not unit then
        return nil
    end
    custom.unit=unit
    Ether:SetupAttribute(custom,custom.unit)
    Ether:SetupTooltip(custom,custom.unit)
    Ether:SetupHealthBar(custom,"HORIZONTAL",13)
    local background=custom:CreateTexture(nil,"BACKGROUND")
    background:SetColorTexture(0,0,0,.6)
    background:SetPoint("TOPLEFT",custom,"TOPLEFT",-2,2)
    background:SetPoint("BOTTOMRIGHT",custom,"BOTTOMRIGHT",2,-2)
    local r,g,b=Ether:GetClassColors(custom.unit)
    custom.healthBar:SetStatusBarColor(r,g,b,.8)
    custom.healthDrop:SetColorTexture(r*0.3,g*0.3,b*0.4)
    Ether:SetupPowerBar(custom)
    Ether:SetupName(custom,0)
    custom.name:SetText(name)
    local re,ge,be=Ether:GetPowerColor(custom.unit)
    custom.powerBar:SetStatusBarColor(re,ge,be,.6)
    customButtons[numb]=custom
    updateFunc()
end


