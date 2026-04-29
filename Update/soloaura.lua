local D,F,S,C=unpack(select(2,...))
local pairs,ipairs,mfloor,sformat=pairs,ipairs,math.floor,string.format
local GetBuffDataByIndex,GetDebuffDataByIndex=C_UnitAuras.GetBuffDataByIndex,C_UnitAuras.GetDebuffDataByIndex
local UnitExists,GetTime,twipe=UnitExists,GetTime,table.wipe
local GetAuraDataByAuraInstanceID=C_UnitAuras.GetAuraDataByAuraInstanceID
local event,raidBtn,soloBtn=S.EventFrame,D.raidBtn,D.soloBtn
local ActiveAuras={}
local function GetSoloButton(unit)
    return soloBtn[D:PosUnit(unit)]
end
local function CheckStacks(button,charges)
    if charges and charges>1 then
        button.stacks:SetText(charges)
        button.stacks:Show()
    else
        button.stacks:Hide()
    end
end
local function CheckCount(button,applications)
    if applications and applications>1 then
        button.count:SetText(applications)
        button.count:Show()
    else
        button.count:Hide()
    end
end
local function CheckIcon(button,icon)
    if icon then
        button.icon:SetTexture(icon)
        button.icon:Show()
    else
        button.icon:Hide()
    end
end
local function UpdateDispel(self,dispelName)
    local color=DebuffTypeColor[dispelName]
    if color then
        self.border:SetColorTexture(color.r,color.g,color.b)
        self.border:Show()
    else
        self.border:Hide()
    end
end
local function SetAuraTimer(icon,duration,expirationTime)
    if duration and expirationTime and duration>0 then
        icon.expirationTime=expirationTime
        icon.durationText:Show()
        ActiveAuras[icon]=true
    else
        icon.durationText:Hide()
        ActiveAuras[icon]=nil
    end
end
local AuraTimerFrame=CreateFrame("Frame")
local UPDATE_RATE=0.1
local acc=0
local function FormatTime(t)
    if t>=60 then
        return sformat("%dm",mfloor(t/60))
    elseif t>=10 then
        return mfloor(t)
    else
        return sformat("%.1f",t)
    end
end
AuraTimerFrame:SetScript("OnUpdate",function(_,elapsed)
    acc=acc+elapsed
    if acc<UPDATE_RATE then return end
    acc=0
    local now=GetTime()
    for icon in pairs(ActiveAuras) do
        local remain=icon.expirationTime-now
        if remain<=0 then
            icon.durationText:Hide()
            icon.durationText:SetText("")
            ActiveAuras[icon]=nil
        else
            icon.durationText:SetText(FormatTime(remain))
            icon.durationText:Show()
        end
    end
end)
local function ApplyAura(now,aura)
    CheckIcon(now,aura.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    CheckCount(now,aura.applications or 0)
    if aura.duration and aura.duration>0 then
        SetAuraTimer(now,aura.duration,aura.expirationTime)
    else
        now.durationText:Hide()
        ActiveAuras[now]=nil
    end
    if aura.isHarmful and aura.dispelName then
        UpdateDispel(now,aura.dispelName)
    end
    CheckStacks(now,aura.charges or 0)
end
local ICON_SIZE=15
local SPACING=1
local PER_ROW=8
local BUFF_Y=3
local DEBUFF_Y=35
local function AuraPosition(i,offsetY)
    local row=mfloor((i-1)/PER_ROW)
    local col=(i-1)%PER_ROW
    local step=ICON_SIZE+SPACING
    local x=col*step
    local y=row*step+offsetY
    return x,y
end
local bX,bY={},{}
local dX,dY={},{}
for i=1,16 do
    bX[i],bY[i]=AuraPosition(i,BUFF_Y)
    dX[i],dY[i]=AuraPosition(i,DEBUFF_Y)
end
local function SetAuraPos(b,i,x,y)
    b:ClearAllPoints()
    b:SetPoint("BOTTOMLEFT",i,"TOPLEFT",x,y)
end
local function AuraRefreshPos(tbl,button,unit,func)
    if not tbl then return end
    for _,v in ipairs(tbl) do
        v:Hide()
        v.instance=nil
    end
    for i,v in ipairs(tbl) do
        local aura=func(unit,i)
        if not aura then break end
        button.aura.bmap[aura.auraInstanceID]=i
        v.instance=aura.auraInstanceID
        ApplyAura(v,aura)
        v:Show()
    end
end
local function AddBuff(button,aura)
    if not button.aura.buffs then return end
    for i,v in ipairs(button.aura.buffs) do
        if not v:IsShown() then
            button.aura.bmap[aura.auraInstanceID]=i
            v.instance=aura.auraInstanceID
            ApplyAura(v,aura)
            v:Show()
            break
        end
    end
end
local function AddDebuff(button,aura)
    if not button.aura.debuffs then return end
    for i,v in ipairs(button.aura.debuffs) do
        if not v:IsShown() then
            button.aura.dmap[aura.auraInstanceID]=i
            v.instance=aura.auraInstanceID
            ApplyAura(v,aura)
            v:Show()
            break
        end
    end
end
local function UpdateBuff(button,aura)
    local slot=button.aura.bmap[aura.auraInstanceID]
    if slot then
        ApplyAura(button.aura.buffs[slot],aura)
    end
end
local function UpdateDebuff(button,aura)
    local slot=button.aura.dmap[aura.auraInstanceID]
    if slot then
        ApplyAura(button.aura.debuffs[slot],aura)
    end
end
local function RemoveBuff(button,id)
    local slot=button.aura.bmap[id]
    if slot then
        local now=button.aura.buffs[slot]
        if now then
            now:Hide()
            now.instance=nil
            ActiveAuras[now]=nil
        end
    end
end
local function RemoveDebuff(button,id)
    local slot=button.aura.dmap[id]
    if slot then
        local now=button.aura.debuffs[slot]
        if now then
            now:Hide()
            now.instance=nil
            ActiveAuras[now]=nil
        end
    end
end
local function GetAuras(update,button,unit)
    if not update or not button then return end
    AuraRefreshPos(button.aura.buffs,button,unit,GetBuffDataByIndex)
    AuraRefreshPos(button.aura.debuffs,button,unit,GetDebuffDataByIndex)
end
local update=false
local function UnitAuraUpdate(unit,updateInfo)
    if not update then return end
    local button=GetSoloButton(unit)
    if not button or not button.aura then return end
    local isFullUpdate=not updateInfo or updateInfo.isFullUpdate
    if isFullUpdate then
        GetAuras(update,button,unit)
        return
    end
    if updateInfo.addedAuras then
        for _,aura in ipairs(updateInfo.addedAuras) do
            if aura.isHelpful then
                AddBuff(button,aura)
            end
            if aura.isHarmful then
                AddDebuff(button,aura)
            end
        end
    end
    if updateInfo.updatedAuraInstanceIDs then
        for _,id in ipairs(updateInfo.updatedAuraInstanceIDs) do
            local aura=GetAuraDataByAuraInstanceID(unit,id)
            if aura then
                if aura.isHelpful then
                    UpdateBuff(button,aura)
                else
                    UpdateDebuff(button,aura)
                end
            end
        end
    end
    if updateInfo.removedAuraInstanceIDs then
        for _,id in ipairs(updateInfo.removedAuraInstanceIDs) do
            RemoveBuff(button,id)
            RemoveDebuff(button,id)
        end
    end
end
local function auraTbl(button,status)
    if type(button.aura.buffs)=="nil" or type(button.aura.debuffs)=="nil" then return end
    for i=1,16 do
        if button.aura.buffs[i] and button.aura.debuffs[i] then
            button.aura.buffs[i]:SetShown(status)
            button.aura.debuffs[i]:SetShown(status)
        end
    end
    if not status then
        twipe(button.aura.bmap)
        twipe(button.aura.dmap)
        twipe(button.aura.buffs)
        twipe(button.aura.debuffs)
    end
end
function F:SoloAuraFullUpdate(button,unit)
    if not button or not button.aura then return end
    if UnitExists(unit) then
        GetAuras(update,button,unit)
    end
end
local function SetupAuraIcon(button)
    local icon=button:CreateTexture(nil,"OVERLAY")
    icon:SetAllPoints()
    icon:SetTexCoord(0.07,0.93,0.07,0.93)
    return icon
end
local function SetupAuraDuration(button,icon)
    local text=button:CreateFontString(nil,"OVERLAY")
    text:SetFontObject(C.EtherFont)
    text:SetPoint("CENTER",icon)
    text:Hide()
    icon.durationText=text
    return text
end
local function SetupAuraCount(button)
    local count=button:CreateFontString(nil,"OVERLAY")
    count:SetFontObject(C.EtherFont)
    count:SetPoint("LEFT")
    count:Hide()
    return count
end
local function SetupAuraStacks(button)
    local stacks=button:CreateFontString(nil,"OVERLAY")
    stacks:SetFontObject(C.EtherFont)
    stacks:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT")
    stacks:Hide()
    return stacks
end
local function SetupAuraBorder(button)
    local border=button:CreateTexture(nil,"BORDER")
    border:SetColorTexture(1,0,0,1)
    border:SetPoint("TOPLEFT",-1,1)
    border:SetPoint("BOTTOMRIGHT",1,-1)
    border:Hide()
    return border
end
local function Aura_OnEnter(self)
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:SetUnitAura(self.unit,self.id,self.filter)
    GameTooltip:Show()
end
local function Aura_OnLeave()
    GameTooltip:Hide()
end
local function InitialAuraTbl(button)
    if button.aura then return end
    button.aura={
        buffs={},
        debuffs={},
        bmap={},
        dmap={}
    }
end
local function AuraSetup(button)
    if not button then return end
    InitialAuraTbl(button)
    local unit=button.unit
    for i=1,16 do
        if not button.aura.buffs[i] then
            local aura=CreateFrame("Frame",nil,button)
            aura.unit=unit
            aura.filter="HELPFUL"
            aura:SetSize(15,15)
            aura.icon=SetupAuraIcon(aura)
            aura.count=SetupAuraCount(aura)
            aura.durationText=SetupAuraDuration(aura,aura.icon)
            aura.stacks=SetupAuraStacks(aura)
            aura.id=i
            aura:SetScript("OnEnter",Aura_OnEnter)
            aura:SetScript("OnLeave",Aura_OnLeave)
            button.aura.buffs[i]=aura
        end
        SetAuraPos(button.aura.buffs[i],button,bX[i],bY[i])
    end
    for i=1,16 do
        if not button.aura.debuffs[i] then
            local aura=CreateFrame("Frame",nil,button)
            aura.unit=unit
            aura.filter="HARMFUL"
            aura:SetSize(15,15)
            aura.icon=SetupAuraIcon(aura)
            aura.count=SetupAuraCount(aura)
            aura.durationText=SetupAuraDuration(aura,aura.icon)
            aura.stacks=SetupAuraStacks(aura)
            aura.border=SetupAuraBorder(aura)
            aura.id=i
            aura:SetScript("OnEnter",Aura_OnEnter)
            aura:SetScript("OnLeave",Aura_OnLeave)
            button.aura.debuffs[i]=aura
        end
        SetAuraPos(button.aura.debuffs[i],button,bX[i],bY[i])
    end
end
function F:EnableSoloAura()
    update=true
    AuraSetup(soloBtn[1])
    auraTbl(soloBtn[1],true)
    AuraSetup(soloBtn[2])
    auraTbl(soloBtn[2],true)
    AuraSetup(soloBtn[4])
    auraTbl(soloBtn[4],true)
    C_Timer.After(0.4,function()
        F:SoloAuraFullUpdate(soloBtn[1],"player")
        F:SoloAuraFullUpdate(soloBtn[2],"target")
    end)
end
function F:DisableSoloAura()
    update=false
    auraTbl(soloBtn[1],false)
    auraTbl(soloBtn[2],false)
    auraTbl(soloBtn[4],false)
end
function F:SoloAuraReset()
    F:EnableSoloAura()
    F:DisableSoloAura()
end
local validUnit={
    player=true,
    pet=true,
    target=true
}
function event:UNIT_AURA(arg1,...)
    if not arg1 or not UnitExists(arg1) then return end
    local info=...
    if validUnit[arg1] then
        UnitAuraUpdate(arg1,info)
    end
    if raidBtn[arg1] then
        F:raidAuraUpdate(arg1,info)
    end
end
function F:AuraEnable()
    if not event:IsEventRegistered("UNIT_AURA") then
        event:RegisterEvent("UNIT_AURA")
    end
    F:EnableRaidAura()
    F:EnableSoloAura()
end
function F:AuraDisable()
    if event:IsEventRegistered("UNIT_AURA") then
        event:UnregisterEvent("UNIT_AURA")
    end
    table.wipe(ActiveAuras)
    F:DisableRaidAura()
    F:DisableSoloAura()
end