local D,F,S=unpack(select(2,...))
local UnitHealth,UnitHealthMax,UnitGetIncomingHeals,UnitIsDeadOrGhost=UnitHealth,UnitHealthMax,UnitGetIncomingHeals,UnitIsDeadOrGhost
local sformat,mfloor,pairs,UnitExists,mmax,mmin=string.format,math.floor,pairs,UnitExists,math.max,math.min
local event,raidBtn,soloBtn,f2m,UnitIsConnected=S.EventFrame,D.raidBtn,D.soloBtn,"%s%d|r",UnitIsConnected
local function ReturnHealth(self)
    if not self or not self.unit then return end
    return UnitHealth(self.unit)
end
local function ReturnMaxHealth(self)
    if not self or not self.unit then return end
    return UnitHealthMax(self.unit)
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
local function InitialHealth(b)
    if not b or not b.healthBar then return end
    if b.smooth then
        b.healthBar:SetMinMaxSmoothedValue(0,ReturnMaxHealth(b))
        b.healthBar:SetSmoothedValue(ReturnHealth(b))
    else
        b.healthBar:SetValue(ReturnHealth(b))
        b.healthBar:SetMinMaxValues(0,ReturnMaxHealth(b))
    end
end
F.InitialHealth=InitialHealth
local function UpdateClassColor(b)
    if not b then return end
    local unit=b.unit
    local r,g,be=0.4,0.4,0.4
    local Connected=UnitIsConnected(b.unit)
    if Connected then
        r,g,be=F:GetClassColor(unit)
    else
        r,g,be=0.4,0.4,0.4
    end
    b.healthBar:SetStatusBarColor(r,g,be)
    b.healthDrop:SetColorTexture(r*0.3,g*0.3,be*0.4,.3)
end
F.UpdateClassColor=UpdateClassColor
local function Health(b)
    if not b or not b.healthBar then return end
    local unit=b.unit
    local h=UnitHealth(unit)
    if not h then return end
    if b.smooth then
        b.healthBar:SetSmoothedValue(h)
    else
        b.healthBar:SetValue(h)
        F:UpdateDeadUnit(b)
    end
end
function F:UpdateDeadUnit(b)
    if not b or not b.Indicators or not b.Indicators.UnitFlags then return end
    if not UnitIsDeadOrGhost(b.unit) and b.Indicators.UnitFlags:IsShown() then
        b.Indicators.UnitFlags:Hide()
        b.healthBar:SetValue(ReturnHealth(b))
        b.healthBar:SetMinMaxValues(0,ReturnMaxHealth(b))
    end
end
local function MaxHealth(b)
    if not b or not b.healthBar then return end
    local unit=b.unit
    local mh=UnitHealthMax(unit)
    if not mh then return end
    if b.smooth then
        b.healthBar:SetMinMaxSmoothedValue(0,mh)
    else
        b.healthBar:SetMinMaxValues(0,mh)
    end
end
function F:FullHealthUpdate(self)
    InitialHealth(self)
    UpdateClassColor(self)
    Health(self)
    MaxHealth(self)
end
local lastHealth={}
function F:UpdateHealthPct(b)
    if not b or not b.unit or not b.health then return end
    local unit=b.unit
    local h,maxH=UnitHealth(unit),UnitHealthMax(unit)
    if not h then return end
    local pct=maxH>0 and h/maxH or 0
    if not pct then return end
    local rPct=mfloor(pct*100+0.5)
    if lastHealth[unit]==rPct then
        return
    end
    lastHealth[unit]=rPct
    b.health:SetText(sformat(f2m,D.HealGradient[rPct],rPct))
end
local function ResetHealthPct(index)
    if index~=3 then return end
    if D.DB[5][index]==0 then
        for _,b in pairs(raidBtn) do
            if b and b.health then
                b.health:Hide()
            end
        end
        table.wipe(lastHealth)
    elseif D.DB[5][index]==1 then
        for _,b in pairs(raidBtn) do
            if b and b.health then
                b.health:Show()
                F:UpdateHealthPct(b)
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
function F:HidePrediction(b)
    if not b or UnitGetIncomingHeals("target") then return end
    if b.myPrediction then
        b.myPrediction:Hide()
    end
    if b.prediction then
        b.prediction:Hide()
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