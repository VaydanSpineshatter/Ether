local D,F,S,_,_=unpack(select(2,...))
local UnitPower,UnitPowerMax,UnitExists=UnitPower,UnitPowerMax,UnitExists
local sformat,mfloor,pairs=string.format,math.floor,pairs
local event,raidBtn,soloBtn,f2m=S.EventFrame,D.raidBtn,D.soloBtn,"%s%d|r"
local function ReturnPower(self)
    return UnitPower(self)
end
local function ReturnMaxPower(self)
    return UnitPowerMax(self)
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
local function InitialPower(button)
    if not button or not button.powerBar then return end
    local unit=button.unit
    button.powerBar:SetValue(ReturnPower(unit))
    button.powerBar:SetMinMaxValues(0,ReturnMaxPower(unit))
end
local function DisplayPower(button)
    if not button or not button.powerBar then return end
    local unit=button.unit
    local r,g,b=F:GetPowerColor(unit)
    button.powerBar:SetStatusBarColor(r,g,b,.6)
    button.powerDrop:SetColorTexture(r*0.3,g*0.3,b*0.3)
end
F.DisplayPower=DisplayPower
local function Power(button)
    if not button or not button.powerBar then return end
    local unit=button.unit
    local p=UnitPower(unit)
    if not p then return end
    if button.smooth then
        button.powerBar:SetSmoothedValue(p)
    else
        button.powerBar:SetValue(p)
    end
end
local function MaxPower(button)
    if not button or not button.powerBar then return end
    local unit=button.unit
    local mp=UnitPowerMax(unit)
    if not mp then return end
    if button.smooth then
        button.powerBar:SetMinMaxSmoothedValue(0,mp)
    else
        button.powerBar:SetMinMaxValues(0,mp)
    end
end
local lastPower=F.GetTbl()
function F:UpdatePowerPct(button)
    if not button or not button.power then return end
    local unit=button.unit
    local pw,maxPw=UnitPower(unit),UnitPowerMax(unit)
    if not pw then return end
    local pct=maxPw>0 and pw/maxPw or 0
    if not pct then return end
    local rPct=mfloor(pct*100+0.5)
    if lastPower[unit]==rPct then return end
    lastPower[unit]=rPct
    button.power:SetText(sformat(f2m,D.PowerGradient[rPct],rPct))
end
function F:ResetPowerPct(index)
    if index~=4 then return end
    if D.DB[5][index]==0 then
        for _,button in pairs(raidBtn) do
            if button and button.health then
                button.power:Hide()
            end
        end
        F.RelTbl(lastPower)
    elseif D.DB[5][index]==1 then
        for _,button in pairs(raidBtn) do
            if button and button.health then
                button.power:Show()
                F:UpdatePowerPct(button)
            end
        end
    end
end
function F:FullPowerUpdate(self)
    InitialPower(self)
    Power(self)
    MaxPower(self)
    DisplayPower(self)
end
function event:UNIT_POWER_UPDATE(unit)
    local s=GetSoloBtn(unit)
    if s then
        Power(s)
    end
    if soloBtn[3]:IsVisible() then
        if UnitExists("targettarget") then
            Power(soloBtn[3])
        end
    end
    if D.DB[5][4]==1 then
        local b=GetRaidBtn(unit)
        if b then
            F:UpdatePowerPct(b)
        end
    end
end
function event:UNIT_MAXPOWER(unit)
    local s=GetSoloBtn(unit)
    if s then
        MaxPower(s)
    end
    if soloBtn[3]:IsVisible() then
        if UnitExists("targettarget") then
            MaxPower(soloBtn[3])
        end
    end
    if D.DB[5][4]==1 then
        local b=GetRaidBtn(unit)
        if b then
            F:UpdatePowerPct(b)
        end
    end
end
function event:UNIT_DISPLAYPOWER(unit)
    local b=GetSoloBtn(unit)
    if b then
        DisplayPower(b)
    end
    if soloBtn[3]:IsVisible() then
        if UnitExists("targettarget") then
            DisplayPower(soloBtn[3])
        end
    end
end
function F:PowerEnable()
    for _,v in ipairs({"UNIT_POWER_UPDATE","UNIT_MAXPOWER","UNIT_DISPLAYPOWER"}) do
        if not event:IsEventRegistered(v) then
            event:RegisterEvent(v)
        end
    end
end
function F:PowerDisable()
    for _,v in ipairs({"UNIT_POWER_UPDATE","UNIT_MAXPOWER","UNIT_DISPLAYPOWER"}) do
        event:UnregisterEvent(v)
    end
end