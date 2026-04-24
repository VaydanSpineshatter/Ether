local D,F,S,_,_=unpack(select(2,...))
local UnitHealth,UnitHealthMax,UnitGetIncomingHeals=UnitHealth,UnitHealthMax,UnitGetIncomingHeals
local sformat,mfloor,pairs,UnitExists,mmax,mmin=string.format,math.floor,pairs,UnitExists,math.max,math.min
local event,raidBtn,petBtn,soloBtn,f2m=S.EventFrame,D.raidBtn,D.petBtn,D.soloBtn,"%s%d|r"
local function ReturnHealth(self)
    return UnitHealth(self)
end
local function ReturnMaxHealth(self)
    return UnitHealthMax(self)
end
local function GetSoloBtn(unit)
    return soloBtn[D:PosUnit(unit)]
end
local function GetRaidBtn(unit)
    local b=raidBtn[unit]
    if b and b.unit==unit then
        return b
    end
end
local function GetPetBtn(unit)
    local b=petBtn[unit]
    if b and b.unit==unit then
        return b
    end
end
local function InitialHealth(button)
    if not button or not button.healthBar then return end
    local unit=button.unit
    button.healthBar:SetValue(ReturnHealth(unit))
    button.healthBar:SetMinMaxValues(0,ReturnMaxHealth(button.unit))
end
F.InitialHealth=InitialHealth
local function UpdateClassColor(button)
    if not button then return end
    local unit=button.unit
    local r,g,b=F:GetClassColor(unit)
    button.healthBar:SetStatusBarColor(r,g,b)
    button.healthDrop:SetColorTexture(r*0.3,g*0.3,b*0.4,.3)
end
F.UpdateClassColor=UpdateClassColor
local function Health(button)
    if not button or not button.healthBar then return end
    local unit=button.unit
    local h=UnitHealth(unit)
    if not h then return end
    if button.smooth then
        button.healthBar:SetSmoothedValue(h)
    else
        button.healthBar:SetValue(h)
    end
end
local function MaxHealth(button)
    if not button or not button.healthBar then return end
    local unit=button.unit
    local mh=UnitHealthMax(unit)
    if not mh then return end
    if button.smooth then
        button.healthBar:SetMinMaxSmoothedValue(0,mh)
    else
        button.healthBar:SetMinMaxValues(0,mh)
    end
end
function F:FullHealthUpdate(self)
    InitialHealth(self)
    UpdateClassColor(self)
    Health(self)
    MaxHealth(self)
end
local lastHealth=F.GetTbl()
function F:UpdateHealthPct(button)
    if not button or not button.health then return end
    local unit=button.unit
    local h,maxH=UnitHealth(unit),UnitHealthMax(unit)
    if not h then return end
    local pct=maxH>0 and h/maxH or 0
    if not pct then return end
    local roundedPct=mfloor(pct*100+0.5)
    if lastHealth[unit]==roundedPct then
        return
    end
    lastHealth[unit]=roundedPct
    button.health:SetText(sformat(f2m,D.HealGradient[roundedPct],roundedPct))
end
local function ResetHealthPct(index)
    if index~=3 then return end
    if D.DB[5][index]==0 then
        for _,button in pairs(raidBtn) do
            if button and button.health then
                button.health:Hide()
            end
        end
        F.RelTbl(lastHealth)
    elseif D.DB[5][index]==1 then
        for _,button in pairs(raidBtn) do
            if button and button.health then
                button.health:Show()
                F:UpdateHealthPct(button)
            end
        end
    end
end
function F:UpdateText(index)
    if index==3 then
        ResetHealthPct(index)
    elseif index==4 then
        F:ResetPowerPct(index)
    end
end
function F:HidePrediction(button)
    if not button then return end
    if button.myPrediction then
        button.myPrediction:Hide()
    end
    if button.prediction then
        button.prediction:Hide()
    end
end
local function UpdatePrediction(button)
    if not button or not button.myPrediction then return end
    local unit=button.unit
    local myHeal=UnitGetIncomingHeals(unit,"player") or 0
    local otherHeal=UnitGetIncomingHeals(unit) or 0
    local other=0
    if otherHeal>0 then
        other=mmax(0,otherHeal-myHeal)
        myHeal=mmin(myHeal,otherHeal)
    end
    if myHeal>1 then
        button.myPrediction:Show()
    else
        button.myPrediction:Hide()
    end
    if not button.prediction then return end
    if other>1 then
        button.prediction:Show()
    else
        button.prediction:Hide()
    end
end
function event:UNIT_HEAL_PREDICTION(unit)
    local b=GetRaidBtn(unit)
    if b then
        UpdatePrediction(b)
    end
    local p=GetPetBtn(unit)
    if p then
        UpdatePrediction(p)
    end
    local s=GetSoloBtn(unit)
    if s then
        UpdatePrediction(s)
    end
    if soloBtn[3]:IsVisible() then
        if UnitExists("targettarget") then
            UpdatePrediction(soloBtn[3])
        end
    end
end
function event:UNIT_HEALTH(unit)
    local b=GetRaidBtn(unit)
    if b then
        Health(b)
        if D.DB[5][3]==1 then
            F:UpdateHealthPct(b)
        end
    end
    local p=GetPetBtn(unit)
    if p then
        Health(p)
    end
    local s=GetSoloBtn(unit)
    if s then
        Health(s)
    end
    if soloBtn[3]:IsVisible() then
        if UnitExists("targettarget") then
            Health(soloBtn[3])
        end
    end
end
function event:UNIT_MAXHEALTH(unit)
    local b=GetRaidBtn(unit)
    if b then
        MaxHealth(b)
        if D.DB[5][3]==1 then
            F:UpdateHealthPct(b)
        end
    end
    local p=GetPetBtn(unit)
    if p then
        MaxHealth(p)
    end
    local s=GetSoloBtn(unit)
    if s then
        MaxHealth(s)
    end
    if soloBtn[3]:IsVisible() then
        if UnitExists("targettarget") then
            MaxHealth(soloBtn[3])
        end
    end
end
function F:HealthEnable()
    for _,v in ipairs({"UNIT_MAXHEALTH","UNIT_HEALTH","UNIT_HEAL_PREDICTION"}) do
        if not event:IsEventRegistered(v) then
            event:RegisterEvent(v)
        end
    end
end
function F:HealthDisable()
    for _,v in ipairs({"UNIT_MAXHEALTH","UNIT_HEALTH","UNIT_HEAL_PREDICTION"}) do
        event:UnregisterEvent(v)
    end
end