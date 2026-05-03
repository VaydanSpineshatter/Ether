local D,F,S=unpack(select(2,...))
local UnitPower,UnitPowerMax,UnitExists=UnitPower,UnitPowerMax,UnitExists
local sformat,mfloor,pairs=string.format,math.floor,pairs
local event,raidBtn,soloBtn,f2m=S.EventFrame,D.raidBtn,D.soloBtn,"%s%d|r"
local function ReturnPower(self)
    if not self or not self.unit then return end
    return UnitPower(self.unit)
end
local function ReturnMaxPower(self)
    if not self or not self.unit then return end
    return UnitPowerMax(self.unit)
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
local function InitialPower(b)
    if not b or not b.powerBar then return end
    if b.smooth then
        b.powerBar:SetMinMaxSmoothedValue(0,ReturnMaxPower(b))
        b.powerBar:SetSmoothedValue(ReturnPower(b))
    else
        b.powerBar:SetValue(ReturnPower(b))
        b.powerBar:SetMinMaxValues(0,ReturnMaxPower(b))
    end
end
F.InitialPower=InitialPower
local function DisplayPower(b)
    if not b or not b.unit or not b.powerBar then return end
    local unit=b.unit
    local r,g,be=F:GetPowerColor(unit)
    b.powerBar:SetStatusBarColor(r,g,be,.6)
    b.powerDrop:SetColorTexture(r*0.3,g*0.3,be*0.3)
end
F.DisplayPower=DisplayPower
local function Power(b)
    if not b or not b.unit or not b.powerBar then return end
    local unit=b.unit
    local p=UnitPower(unit)
    if not p then return end
    if b.smooth then
        b.powerBar:SetSmoothedValue(p)
    else
        b.powerBar:SetValue(p)
    end
end
local function MaxPower(b)
    if not b or not b.unit or not b.powerBar then return end
    local unit=b.unit
    local mp=UnitPowerMax(unit)
    if not mp then return end
    if b.smooth then
        b.powerBar:SetMinMaxSmoothedValue(0,mp)
    else
        b.powerBar:SetMinMaxValues(0,mp)
    end
end
local lastPower={}
function F:UpdatePowerPct(b)
    if not b or not b.unit or not b.power then return end
    local unit=b.unit
    local pw,maxPw=UnitPower(unit),UnitPowerMax(unit)
    if not pw then return end
    local pct=maxPw>0 and pw/maxPw or 0
    if not pct then return end
    local rPct=mfloor(pct*100+0.5)
    if not rPct then return end
    if lastPower[unit]==rPct then return end
    lastPower[unit]=rPct
    b.power:SetText(sformat(f2m,D.PowerGradient[rPct],rPct))
end
function F:ResetPowerPct(index)
    if index~=4 then return end
    if D.DB[5][index]==0 then
        for _,b in pairs(raidBtn) do
            if b and b.power then
                b.power:Hide()
            end
        end
        table.wipe(lastPower)
    elseif D.DB[5][index]==1 then
        for _,b in pairs(raidBtn) do
            if b and b.power then
                b.power:Show()
                F:UpdatePowerPct(b)
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
F:RegisterCallbackByIndex(F.PowerEnable,11)
F:RegisterCallbackByIndex(F.PowerDisable,11+30)