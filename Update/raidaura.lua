local D,F,_,C=unpack(select(2,...))
local pairs,ipairs,UnitGUID=pairs,ipairs,UnitGUID
local GetBuffDataByIndex,GetDebuffDataByIndex=C_UnitAuras.GetBuffDataByIndex,C_UnitAuras.GetDebuffDataByIndex
local GetAuraDataByIndex=C_UnitAuras.GetAuraDataByIndex
local GetAuraDataByAuraInstanceID=C_UnitAuras.GetAuraDataByAuraInstanceID
local GetAuraInstanceID,type=C_UnitAuras.GetUnitAuraBySpellID,type
local GetTime,UnitExists,raidBtn=GetTime,UnitExists,D.raidBtn
local twipe=table.wipe
local dispelCache,helpfulAuras,harmfulAuras={},{},{}
local dataHelpful,dataHarmful={},{}
local function GetRaidBtn(unit)
    local b=raidBtn[unit]
    if b and b.unit==unit then
        return b
    end
end
local dispelClass={
    MAGE={
        Curse=true,
    },
    PRIEST={
        Magic=true,
        Disease=true
    },
    PALADIN={
        Magic=true,
        Disease=true,
        Poison=true
    },
    DRUID={
        Curse=true,
        Poison=true
    },
    SHAMAN={
        Disease=true,
        Poison=true
    }
}
local canDispel=dispelClass[C.ClassName] or {}
local dispelPriority={
    Magic=4,
    Disease=3,
    Curse=2,
    Poison=1
}
local function CleanupAuras(unit)
    if dataHelpful[unit] then
        for _,texture in pairs(dataHelpful[unit]) do
            if type(texture)~="table" then return end
            texture:Hide()
            texture:ClearAllPoints()
            texture:SetParent(nil)
            dataHelpful[unit]=nil
        end
    end
    if dataHarmful[unit] then
        for _,texture in pairs(dataHarmful[unit]) do
            if type(texture)~="table" then return end
            texture:Hide()
            texture:ClearAllPoints()
            texture:SetParent(nil)
            dataHarmful[unit]=nil
        end
    end
end
local function HideAuras(unit)
    if dataHelpful[unit] then
        for _,texture in pairs(dataHelpful[unit]) do
            if type(texture)~="table" then return end
            texture:Hide()
            texture:ClearAllPoints()
            texture:SetParent(nil)
        end
    end
    if dataHarmful[unit] then
        for _,texture in pairs(dataHarmful[unit]) do
            if type(texture)~="table" then return end
            texture:Hide()
            texture:ClearAllPoints()
            texture:SetParent(nil)
        end
    end
end
local function CleanupRaidIcons()
    for unit in pairs(dataHelpful) do
        CleanupAuras(unit)
    end
    for unit in pairs(dataHarmful) do
        CleanupAuras(unit)
    end
end
local function GetTexture(button,data)
    local frame=CreateFrame("Frame",nil,button)
    frame:SetFrameStrata("HIGH")
    local tex=frame:CreateTexture(nil,"OVERLAY",nil,7)
    tex:SetColorTexture(data[2],data[3],data[4],data[5])
    tex:SetSize(data[9],data[9])
    tex:SetPoint(data[6],button.healthBar,data[6],data[7],data[8])
    local cooldown=CreateFrame("Cooldown",nil,frame,"CooldownFrameTemplate")
    cooldown:SetBlingTexture("Interface\\Cooldown\\star4_edge",1,1,1,1)
    cooldown:SetAllPoints(tex)
    cooldown:SetReverse(true)
    cooldown:SetHideCountdownNumbers(true)
    local count=frame:CreateFontString(nil,"OVERLAY")
    count:SetFontObject(C.EtherFont)
    count:SetPoint("LEFT",tex)
    count:Hide()
    local stacks=frame:CreateFontString(nil,"OVERLAY")
    stacks:SetFontObject(C.EtherFont)
    stacks:SetPoint("LEFT",tex)
    stacks:Hide()
    local durationText=frame:CreateFontString(nil,"OVERLAY")
    durationText:SetFontObject(C.EtherFont)
    durationText:SetPoint("CENTER",frame)
    durationText:Hide()
    frame.icon=tex
    frame.cooldown=cooldown
    frame.count=count
    frame.stacks=stacks
    frame.durationText=durationText
    return frame
end
local function ScanDispelAuras(unit)
    if not unit then return end
    local dispel
    dispel=nil
    local prio=0
    local index=1
    while true do
        local aura=GetAuraDataByIndex(unit,index,"HARMFUL")
        if not aura then break end
        if aura.dispelName and canDispel[aura.dispelName] then
            local status=dispelPriority[aura.dispelName] or 0
            if status>prio then
                prio=status
                dispel={
                    icon=aura.icon,
                    dispelName=aura.dispelName,
                    index=index
                }
            end
        end
        index=index+1
    end
    return dispel
end
local function GetCachedDispel(unit,guid)
    if not unit or not guid then return end
    local cached=dispelCache[guid]
    if cached and (GetTime()-cached.timestamp)<6 then
        return cached.dispel
    end
    local dispel=ScanDispelAuras(unit)
    dispelCache[guid]={
        dispel=dispel,
        timestamp=GetTime()
    }
    return dispel
end
local function UpdateButtonDispel(button,guid)
    if not button or not button.unit then return end
    local unit=button.unit
    local dispel=GetCachedDispel(unit,guid)
    if dispel then
        button.indicator:SetTexture(dispel.icon)
        local color=DebuffTypeColor[dispel.dispelName] or DebuffTypeColor["none"]
        button.indicatorborder:SetColorTexture(color.r,color.g,color.b)
        button.indicator:Show()
        button.indicatorborder:Show()
        button.dispellable=dispel
    else
        button.indicator:Hide()
        button.indicatorborder:Hide()
        button.dispellable=nil
    end
end
function F:HideButtonDispellable(b)
    if not b or not b.dispellable then return end
    b.indicator:Hide()
    b.indicatorborder:Hide()
    b.dispellable=nil
end
local function OnDispelAuraChanged(button,unit)
    if not button or not unit then return end
    local guid=UnitGUID(unit)
    if guid then
        dispelCache[guid]=nil
    end
    UpdateButtonDispel(button,guid)
end
local function CheckStacks(button,charges)
    if not button then return end
    if charges and charges>1 then
        button.stacks:SetText(charges)
        button.stacks:Show()
    else
        button.stacks:Hide()
    end
end
local function CheckCount(button,applications)
    if not button then return end
    if applications and applications>1 then
        button.count:SetText(applications)
        button.count:Show()
    else
        button.count:Hide()
    end
end
local function SetAuraRaidTimer(self,duration,expirationTime)
    if duration and expirationTime and duration>0 then
        local start=expirationTime-duration
        self.cooldown:SetCooldown(start,duration)
    else
        self.cooldown:Clear()
    end
end
local function UnitTable(unit)
    if not dataHelpful[unit] then
        dataHelpful[unit]={}
    end
    if not dataHarmful[unit] then
        dataHarmful[unit]={}
    end
end
function F:UnitUpdateTable(b)
    if not b or not b.unit then return end
    if b.dispel then
        F:StopBlink(b.dispel)
    end
    if b.dispellable then
        F:HideButtonDispellable(b)
    end
    HideAuras(b.unit)
end
function F:UpdateRaidAura(unit)
    if not unit or not UnitExists(unit) then return end
    local DB=D.DB
    local config=DB["CUSTOM"]
    local b=GetRaidBtn(unit)
    if not b then return end
    UnitTable(unit)
    for i in pairs(config) do
        local aura=C_UnitAuras.GetUnitAuraBySpellID(unit,i)
        if not aura then return end
        if i and config[i] then
            if not config[i][10] then
                if not dataHelpful[unit][i] then
                    dataHelpful[unit][i]=GetTexture(b,config)
                    if aura.duration then
                        SetAuraRaidTimer(dataHelpful[unit],aura.duration,aura.expirationTime)
                    end
                    CheckCount(dataHelpful[unit][i],aura.applications or 0)
                    CheckStacks(dataHelpful[unit][i],aura.charges or 0)
                    helpfulAuras[aura.auraInstanceID]={
                        spellId=i,
                        unit=unit
                    }
                end
            end
            if config[aura.spellId][10] then
                if not dataHarmful[unit][C.Spell] then
                    dataHarmful[unit][C.Spell]=GetTexture(b,config)
                    if aura.duration then
                        SetAuraRaidTimer(dataHelpful[unit][C.Spell],aura.duration,aura.expirationTime)
                    end
                    CheckCount(dataHarmful[unit][C.Spell],aura.applications or 0)
                    CheckStacks(dataHarmful[unit][C.Spell],aura.charges or 0)
                    harmfulAuras[aura.auraInstanceID]={
                        spellId=C.Spell,
                        unit=unit
                    }
                end
            end
        end
    end
end
function F:UpdateAuraPos()
    if type(C.Spell)=="nil" then return end
    local DB=D.DB
    local config=DB["CUSTOM"][C.Spell]
    local debuff=config[10]
    if not debuff then
        for unit in pairs(dataHelpful) do
            if dataHelpful[unit][C.Spell] then
                dataHelpful[unit][C.Spell]:Hide()
                dataHelpful[unit][C.Spell]:ClearAllPoints()
                dataHelpful[unit][C.Spell]:SetParent(nil)
                dataHelpful[unit][C.Spell]=GetTexture(raidBtn[unit],config)
                local aura=GetAuraInstanceID(raidBtn[unit].unit,C.Spell)
                if not aura then break end
                if aura.duration then
                    SetAuraRaidTimer(dataHelpful[unit][C.Spell],aura.duration,aura.expirationTime)
                end
                CheckCount(dataHelpful[unit][C.Spell],aura.applications or 0)
                CheckStacks(dataHelpful[unit][C.Spell],aura.charges or 0)
                helpfulAuras[aura.auraInstanceID]={
                    spellId=C.Spell,
                    unit=unit
                }
            end
        end
    else
        for unit in pairs(dataHarmful) do
            if dataHarmful[unit][C.Spell] then
                dataHarmful[unit][C.Spell]:Hide()
                dataHarmful[unit][C.Spell]:ClearAllPoints()
                dataHarmful[unit][C.Spell]:SetParent(nil)
                dataHarmful[unit][C.Spell]=GetTexture(raidBtn[unit],config)
                local aura=GetAuraInstanceID(raidBtn[unit].unit,C.Spell)
                if not aura then break end
                if aura.duration then
                    SetAuraRaidTimer(dataHelpful[unit][C.Spell],aura.duration,aura.expirationTime)
                end
                CheckCount(dataHarmful[unit][C.Spell],aura.applications or 0)
                CheckStacks(dataHarmful[unit][C.Spell],aura.charges or 0)
                harmfulAuras[aura.auraInstanceID]={
                    spellId=C.Spell,
                    unit=unit,
                }
            end
        end
    end
end
local function CleanupCache()
    local currentTime=GetTime()
    for guid,data in pairs(dispelCache) do
        if (currentTime-data.timestamp)>8 then
            dispelCache[guid]=nil
        end
    end
end
function F:RaidAurasFullUpdate(unit)
    if not unit or not UnitExists(unit) then return end
    local b=GetRaidBtn(unit)
    if not b then return end
    CleanupCache()
    UnitTable(unit)
    local config=D.DB["CUSTOM"]
    local index=1
    while true do
        local aura=GetBuffDataByIndex(unit,index)
        if not aura then break end
        if aura.spellId and config[aura.spellId] and not config[aura.spellId][10] then
            if dataHelpful[unit] and dataHelpful[unit][aura.spellId] then
                dataHelpful[unit][aura.spellId]:Hide()
                dataHelpful[unit][aura.spellId]:ClearAllPoints()
                dataHelpful[unit][aura.spellId]:SetParent(nil)
                dataHelpful[unit][aura.spellId]=nil
            end
            if not dataHelpful[unit][aura.spellId] then
                dataHelpful[unit][aura.spellId]=GetTexture(b,config[aura.spellId])
                if aura.duration then
                    SetAuraRaidTimer(dataHelpful[unit][aura.spellId],aura.duration,aura.expirationTime)
                end
                CheckCount(dataHelpful[unit][aura.spellId],aura.applications or 0)
                CheckStacks(dataHelpful[unit][aura.spellId],aura.charges or 0)
                helpfulAuras[aura.auraInstanceID]={
                    spellId=aura.spellId,
                    unit=unit
                }
            end
        end
        index=index+1
    end
    index=1
    while true do
        local aura=GetDebuffDataByIndex(unit,index)
        if not aura then break end
        if aura.spellId and config[aura.spellId] and config[aura.spellId][10] then
            if dataHarmful[unit] and dataHarmful[unit][aura.spellId] then
                dataHarmful[unit][aura.spellId]:Hide()
                dataHarmful[unit][aura.spellId]:ClearAllPoints()
                dataHarmful[unit][aura.spellId]:SetParent(nil)
                dataHarmful[unit][aura.spellId]=nil
            end
            if not dataHarmful[unit][aura.spellId] then
                dataHarmful[unit][aura.spellId]=GetTexture(b,config[aura.spellId])
                if aura.duration and aura.duration>0 then
                    SetAuraRaidTimer(dataHarmful[unit][aura.spellId],aura.duration,aura.expirationTime)
                end
            end
        end
        if aura.dispelName and canDispel[aura.dispelName] then
            OnDispelAuraChanged(unit)
        end
        CheckCount(dataHarmful[unit][aura.spellId],aura.applications or 0)
        CheckStacks(dataHarmful[unit][aura.spellId],aura.charges or 0)
        if aura.icon and aura.duration<=90 then
            local color=DebuffTypeColor[aura.dispelName] or DebuffTypeColor["none"]
            b.dispelicon:SetTexture(aura.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
            b.dispelborder:SetColorTexture(color.r,color.g,color.b)
            F:StartBlink(b.dispel,aura.duration,0.3)
        end
        harmfulAuras[aura.auraInstanceID]={
            spellId=aura.spellId,
            dispelName=aura.dispelName,
            unit=unit
        }
        index=index+1
    end
end
local update=false
function F:raidAuraUpdate(unit,updateInfo)
    if not update then return end
    local b=GetRaidBtn(unit)
    if not b then return end
    UnitTable(unit)
    local DB=D.DB
    local config=DB["CUSTOM"]
    if updateInfo.isFullUpdate then
        F:RaidAurasFullUpdate(unit)
        return
    end
    if updateInfo.addedAuras then
        for _,aura in ipairs(updateInfo.addedAuras) do
            if aura.isHelpful then
                if aura.spellId and config[aura.spellId] and not config[aura.spellId][10] then
                    if dataHelpful[unit] and dataHelpful[unit][aura.spellId] then
                        dataHelpful[unit][aura.spellId]:Hide()
                        dataHelpful[unit][aura.spellId]:ClearAllPoints()
                        dataHelpful[unit][aura.spellId]:SetParent(nil)
                        dataHelpful[unit][aura.spellId]=nil
                    end
                    if not dataHelpful[unit][aura.spellId] then
                        dataHelpful[unit][aura.spellId]=GetTexture(b,config[aura.spellId])
                        if aura.duration and aura.duration>0 then
                            SetAuraRaidTimer(dataHelpful[unit][aura.spellId],aura.duration,aura.expirationTime)
                        end
                        CheckCount(dataHelpful[unit][aura.spellId],aura.applications or 0)
                        CheckStacks(dataHelpful[unit][aura.spellId],aura.charges or 0)
                        helpfulAuras[aura.auraInstanceID]={
                            spellId=aura.spellId,
                            unit=unit
                        }
                    end
                end
            end
            if aura.isHarmful then
                if aura.spellId and config[aura.spellId] and config[aura.spellId][10] then
                    if dataHarmful[unit] and dataHarmful[unit][aura.spellId] then
                        dataHarmful[unit][aura.spellId]:Hide()
                        dataHarmful[unit][aura.spellId]:ClearAllPoints()
                        dataHarmful[unit][aura.spellId]:SetParent(nil)
                        dataHarmful[unit][aura.spellId]=nil
                    end
                    if not dataHarmful[unit][aura.spellId] then
                        dataHarmful[unit][aura.spellId]=GetTexture(b,config[aura.spellId])
                        if aura.duration and aura.duration>0 then
                            SetAuraRaidTimer(dataHarmful[unit][aura.spellId],aura.duration,aura.expirationTime)
                        end
                        CheckCount(dataHarmful[unit][aura.spellId],aura.applications or 0)
                        CheckStacks(dataHarmful[unit][aura.spellId],aura.charges or 0)
                    end
                end
                if aura.icon and aura.duration<=90 then
                    local color=DebuffTypeColor[aura.dispelName] or DebuffTypeColor["none"]
                    b.dispelicon:SetTexture(aura.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
                    b.dispelborder:SetColorTexture(color.r,color.g,color.b)
                    F:StartBlink(b.dispel,aura.duration,0.3)
                end
                if aura.dispelName and canDispel[aura.dispelName] then
                    OnDispelAuraChanged(b,unit)
                end
                harmfulAuras[aura.auraInstanceID]={
                    spellId=aura.spellId,
                    dispelName=aura.dispelName,
                    unit=unit
                }
            end
        end
    end
    if updateInfo.updatedAuraInstanceIDs then
        for _,auraInstanceID in ipairs(updateInfo.updatedAuraInstanceIDs) do
            local aura=GetAuraDataByAuraInstanceID(unit,auraInstanceID)
            if aura then
                if aura.isHelpful then
                    local info=helpfulAuras[auraInstanceID]
                    if not info then return end
                    if aura.duration and aura.duration>0 then
                        if dataHelpful[info.unit] and dataHelpful[info.unit][info.spellId] then
                            SetAuraRaidTimer(dataHelpful[info.unit][info.spellId],aura.duration,aura.expirationTime)
                        end
                    end
                    CheckCount(dataHelpful[info.unit][aura.spellId],aura.applications or 0)
                    CheckStacks(dataHelpful[info.unit][aura.spellId],aura.charges or 0)
                end
                if aura.isHarmful then
                    local info=harmfulAuras[auraInstanceID]
                    if not info then return end
                    if aura.duration and aura.duration>0 then
                        if dataHarmful[aura.unit] and dataHarmful[info.unit][info.spellId] then
                            SetAuraRaidTimer(dataHarmful[info.unit][info.spellId],aura.duration,aura.expirationTime)
                        end
                    end
                    CheckCount(dataHarmful[info.unit][aura.spellId],aura.applications or 0)
                    CheckStacks(dataHarmful[info.unit][aura.spellId],aura.charges or 0)
                end
            end
        end
    end
    if updateInfo.removedAuraInstanceIDs then
        for _,auraInstanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
            if helpfulAuras[auraInstanceID] then
                local aura=helpfulAuras[auraInstanceID]
                if dataHelpful[aura.unit] and dataHelpful[aura.unit][aura.spellId] then
                    dataHelpful[aura.unit][aura.spellId]:Hide()
                    dataHelpful[aura.unit][aura.spellId]:ClearAllPoints()
                    dataHelpful[aura.unit][aura.spellId]:SetParent(nil)
                    dataHelpful[aura.unit][aura.spellId]=nil
                end
                helpfulAuras[auraInstanceID]=nil
            end
            if harmfulAuras[auraInstanceID] then
                local aura=harmfulAuras[auraInstanceID]
                if b then
                    F:HideButtonDispellable(b)
                end
                if dataHarmful[aura.unit] and dataHarmful[aura.unit][aura.spellId] then
                    dataHarmful[aura.unit][aura.spellId]:Hide()
                    dataHarmful[aura.unit][aura.spellId]:ClearAllPoints()
                    dataHarmful[aura.unit][aura.spellId]:SetParent(nil)
                    dataHarmful[aura.unit][aura.spellId]=nil
                end
                if b and b.dispel then
                    F:StopBlink(b.dispel)
                end
                harmfulAuras[auraInstanceID]=nil
            end
        end
    end
end

function F:AuraWipe()
    twipe(helpfulAuras)
    twipe(harmfulAuras)
    twipe(dataHelpful)
    twipe(dataHarmful)
    twipe(dispelCache)
end
function F:ClearRaidIcons()
    F:StopAllBlinks()
    CleanupRaidIcons()
end
function F:EnableRaidAura()
    update=true
    for _,b in pairs(raidBtn) do
        if b and UnitExists(b.unit) then
            F:RaidAurasFullUpdate(b.unit)
        end
    end
end
function F:DisableRaidAura()
    update=false
    F:StopAllBlinks()
    CleanupRaidIcons()
    F:AuraWipe()
end