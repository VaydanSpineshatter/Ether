local D,F,_,C=unpack(select(2,...))
local pairs,ipairs,UnitGUID=pairs,ipairs,UnitGUID
local GetBuffDataByIndex,GetDebuffDataByIndex=C_UnitAuras.GetBuffDataByIndex,C_UnitAuras.GetDebuffDataByIndex
local GetAuraDataByIndex=C_UnitAuras.GetAuraDataByIndex
local GetAuraDataByAuraInstanceID=C_UnitAuras.GetAuraDataByAuraInstanceID
local GetAuraInstanceID,type=C_UnitAuras.GetUnitAuraBySpellID,type
local GetTime,UnitExists,raidBtn=GetTime,UnitExists,D.raidBtn
local twipe=table.wipe
local dispelCache,helpfulAuras,harmfulAuras,dataHelpful,dataHarmful={},{},{},{},{}
local dispelClass={MAGE={Curse=true},PRIEST={Magic=true,Disease=true},PALADIN={Magic=true,Disease=true,Poison=true},DRUID={Curse=true,Poison=true},SHAMAN={Disease=true,Poison=true}}
local canDispel=dispelClass[C.ClassName] or {}
local dispelPriority={Magic=4,Disease=3,Curse=2,Poison=1}
local function GetRaidBtn(unit)
    local b=raidBtn[unit]
    if b and b.unit==unit then
        return b
    end
end
local function UnitTable(unit)
    if not dataHelpful[unit] then
        dataHelpful[unit]={}
    end
    if dataHarmful[unit] then return end
    dataHarmful[unit]={}
end
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
local function CleanupRaidIcons()
    for _,b in pairs(raidBtn) do
        if b then
            F:UnitUpdateTable(b)
        end
    end
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
    if cached and (GetTime()-cached.timestamp)<=3 then
        return cached.dispel
    end
    local dispel=ScanDispelAuras(unit)
    dispelCache[guid]={
        dispel=dispel,
        timestamp=GetTime()
    }
    return dispel
end
local function CleanupCache()
    local currentTime=GetTime()
    for guid,data in pairs(dispelCache) do
        if (currentTime-data.timestamp)>=4 then
            dispelCache[guid]=nil
        end
    end
end
function F:CacheStatus()
    CleanupCache()
end
local function UpdateButtonDispel(b,guid)
    if not b or not b.unit then return end
    local unit=b.unit
    local dispel=GetCachedDispel(unit,guid)
    if dispel then
        b.indicator:SetTexture(dispel.icon)
        local c=DebuffTypeColor[dispel.dispelName] or DebuffTypeColor["none"]
        b.indicatorborder:SetColorTexture(c.r,c.g,c.b)
        b.indicator:Show()
        b.indicatorborder:Show()
        b.dispellable=dispel
    else
        b.indicator:Hide()
        b.indicatorborder:Hide()
        b.dispellable=nil
    end
end
local function CheckStacks(b,charges)
    if not b then return end
    if charges and charges>1 then
        b.stacks:SetText(charges)
        b.stacks:Show()
    else
        b.stacks:Hide()
    end
end
local function CheckCount(b,applications)
    if applications and applications>1 then
        b.count:SetText(applications)
        b.count:Show()
    else
        b.count:Hide()
    end
end
local function CheckTime(b,duration,expirationTime)
    if duration and expirationTime and duration>0 then
        local start=expirationTime-duration
        b.cooldown:SetCooldown(start,duration)
    else
        b.cooldown:Clear()
    end
end
local function CheckBorder(button,dispelName,instance)
    if not button or not button.top then return end
    local c=DebuffTypeColor[dispelName]
    if not c then return end
    button.top:SetColorTexture(c.r,c.g,c.b)
    button.bottom:SetColorTexture(c.r,c.g,c.b)
    button.right:SetColorTexture(c.r,c.g,c.b)
    button.left:SetColorTexture(c.r,c.g,c.b)
    button.top.instance=instance
end
local function CheckBorderInstance(button,instance)
    if not button then return end
    if button.top.instance and button.top.instance==instance then
        button.top:SetColorTexture(0,0,0)
        button.bottom:SetColorTexture(0,0,0)
        button.right:SetColorTexture(0,0,0)
        button.left:SetColorTexture(0,0,0)
        button.top.instance=nil
    end
end
function F:UpdateButtonBorder(button,r,g,b)
    if not button or not button.top then return end
    button.top:SetColorTexture(r,g,b)
    button.bottom:SetColorTexture(r,g,b)
    button.right:SetColorTexture(r,g,b)
    button.left:SetColorTexture(r,g,b)
end
function F:HideButtonDispellable(b)
    if not b or not b.dispellable then return end
    b.indicator:Hide()
    b.indicatorborder:Hide()
    b.dispellable=nil
end
local function CheckBlink(b,icon,duration)
    if not b or not b.dispel then return end
    b.dispelicon:SetTexture(icon)
    F:StartBlink(b.dispel,duration,0.3)
end
local function CheckDispel(unit)
    if not unit then return end
    local guid=UnitGUID(unit)
    if guid then
        dispelCache[guid]=nil
    end
    local b=GetRaidBtn(unit)
    if not b then return end
    UpdateButtonDispel(b,guid)
end
local function AddAuras(data,unit,b,config,spellId)
    if not data[unit][spellId] then
        data[unit][spellId]=GetTexture(b,config[spellId])
    end
end
local function RemoveAuras(data,unit,spellId)
    if data[unit] and data[unit][spellId] then
        data[unit][spellId]:Hide()
        data[unit][spellId]:ClearAllPoints()
        data[unit][spellId]:SetParent(nil)
        data[unit][spellId]=nil
    end
end
function F:UnitUpdateTable(b)
    if not b then return end
    if b.dispel then
        F:StopBlink(b.dispel)
    end
    if b.dispellable then
        F:HideButtonDispellable(b)
    end
    if b.top then
        F:UpdateButtonBorder(b,0,0,0)
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
                if aura.duration and aura.duration>0 then
                    CheckTime(dataHelpful[unit][C.Spell],aura.duration,aura.expirationTime)
                end
                CheckCount(dataHelpful[unit][C.Spell],aura.applications or 0)
                CheckStacks(dataHelpful[unit][C.Spell],aura.charges or 0)
                helpfulAuras[aura.auraInstanceID]={spellId=C.Spell,unit=unit}
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
                if aura.duration and aura.duration>0 then
                    CheckTime(dataHarmful[unit][C.Spell],aura.duration,aura.expirationTime)
                end
                CheckCount(dataHarmful[unit][C.Spell],aura.applications or 0)
                CheckStacks(dataHarmful[unit][C.Spell],aura.charges or 0)
                harmfulAuras[aura.auraInstanceID]={spellId=C.Spell,unit=unit}
            end
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
        if config[aura.spellId] and not config[aura.spellId][10] then
            RemoveAuras(dataHelpful,unit,aura.spellId)
            AddAuras(dataHelpful,unit,b,config,aura.spellId)
            if aura.duration and aura.duration>0 then
                CheckTime(dataHelpful[unit][aura.spellId],aura.duration,aura.expirationTime)
            end
            CheckCount(dataHelpful[unit][aura.spellId],aura.applications or 0)
            CheckStacks(dataHelpful[unit][aura.spellId],aura.charges or 0)
            helpfulAuras[aura.auraInstanceID]={spellId=aura.spellId,unit=unit}
        end
        index=index+1
    end
    index=1
    while true do
        local aura=GetDebuffDataByIndex(unit,index)
        if not aura then break end
        if config[aura.spellId] and config[aura.spellId][10] then
            RemoveAuras(dataHarmful,unit,aura.spellId)
            AddAuras(dataHarmful,unit,b,config,aura.spellId)
            if aura.duration and aura.duration>0 then
                CheckTime(dataHarmful[unit][aura.spellId],aura.duration,aura.expirationTime)
            end
            CheckCount(dataHarmful[unit][aura.spellId],aura.applications or 0)
            CheckStacks(dataHarmful[unit][aura.spellId],aura.charges or 0)
        end
        if canDispel[aura.dispelName] then
            if b.dispellable then
                F:HideButtonDispellable(b)
            end
            CheckDispel(unit)
        end
        if aura.dispelName then
            CheckBorderInstance(b,aura.auraInstanceID)
            CheckBorder(b,aura.dispelName,aura.auraInstanceID)
        end
        if aura.icon and aura.duration<=70 then
            if b.dispel then
                F:StopBlink(b.dispel)
            end
            CheckBlink(b,aura.icon,aura.duration)
        end
        harmfulAuras[aura.auraInstanceID]={spellId=aura.spellId,unit=unit}
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
                if config[aura.spellId] and not config[aura.spellId][10] then
                    RemoveAuras(dataHelpful,unit,aura.spellId)
                    AddAuras(dataHelpful,unit,b,config,aura.spellId)
                    if aura.duration and aura.duration>0 then
                        CheckTime(dataHelpful[unit][aura.spellId],aura.duration,aura.expirationTime)
                    end
                    CheckCount(dataHelpful[unit][aura.spellId],aura.applications or 0)
                    CheckStacks(dataHelpful[unit][aura.spellId],aura.charges or 0)
                    helpfulAuras[aura.auraInstanceID]={spellId=aura.spellId,unit=unit}
                end
            end
            if aura.isHarmful then
                if config[aura.spellId] and config[aura.spellId][10] then
                    RemoveAuras(dataHarmful,unit,aura.spellId)
                    AddAuras(dataHarmful,unit,b,config,aura.spellId)
                    if aura.duration and aura.duration>0 then
                        CheckTime(dataHarmful[unit][aura.spellId],aura.duration,aura.expirationTime)
                    end
                    CheckCount(dataHarmful[unit][aura.spellId],aura.applications or 0)
                    CheckStacks(dataHarmful[unit][aura.spellId],aura.charges or 0)
                end
                if canDispel[aura.dispelName] then
                    if b.dispellable then
                        F:HideButtonDispellable(b)
                    end
                    CheckDispel(unit)
                end
                if aura.dispelName then
                    CheckBorderInstance(b,aura.auraInstanceID)
                    CheckBorder(b,aura.dispelName,aura.auraInstanceID)
                end
                if aura.icon and aura.duration<=70 then
                    if b.dispel then
                        F:StopBlink(b.dispel)
                    end
                    CheckBlink(b,aura.icon,aura.duration)
                end
                harmfulAuras[aura.auraInstanceID]={spellId=aura.spellId,unit=unit}
            end
        end
    end
    if updateInfo.updatedAuraInstanceIDs then
        for _,auraInstanceID in ipairs(updateInfo.updatedAuraInstanceIDs) do
            local aura=GetAuraDataByAuraInstanceID(unit,auraInstanceID)
            if aura then
                if helpfulAuras[auraInstanceID] then
                    local info=helpfulAuras[auraInstanceID]
                    if dataHelpful[info.unit] and dataHelpful[info.unit][info.spellId] then
                        if aura.duration and aura.duration>0 then
                            CheckTime(dataHelpful[info.unit][info.spellId],aura.duration,aura.expirationTime)
                        end
                    end
                    if dataHelpful[info.unit] and dataHelpful[info.unit][info.spellId] then
                        CheckCount(dataHelpful[info.unit][info.spellId],aura.applications or 0)
                    end
                    if dataHelpful[info.unit] and dataHelpful[info.unit][info.spellId] then
                        CheckStacks(dataHelpful[info.unit][info.spellId],aura.charges or 0)
                    end
                end
                if harmfulAuras[auraInstanceID] then
                    local info=harmfulAuras[auraInstanceID]
                    if dataHarmful[info.unit] and dataHarmful[info.unit][info.spellId] then
                        if aura.duration and aura.duration>0 then
                            CheckTime(dataHarmful[info.unit][info.spellId],aura.duration,aura.expirationTime)
                        end
                    end
                    if dataHarmful[info.unit] and dataHarmful[info.unit][info.spellId] then
                        CheckCount(dataHarmful[info.unit][info.spellId],aura.applications or 0)
                    end
                    if dataHarmful[info.unit] and dataHarmful[info.unit][info.spellId] then
                        CheckStacks(dataHarmful[info.unit][info.spellId],aura.charges or 0)
                    end
                end
            end
        end
    end
    if updateInfo.removedAuraInstanceIDs then
        for _,auraInstanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
            if helpfulAuras[auraInstanceID] then
                local aura=helpfulAuras[auraInstanceID]
                RemoveAuras(dataHelpful,aura.unit,aura.spellId)
                helpfulAuras[auraInstanceID]=nil
            end
            if harmfulAuras[auraInstanceID] then
                local aura=harmfulAuras[auraInstanceID]
                if b.dispel then
                    F:StopBlink(b.dispel)
                end
                if b.dispellable then
                    F:HideButtonDispellable(b)
                end
                CheckBorderInstance(b,auraInstanceID)
                RemoveAuras(dataHarmful,aura.unit,aura.spellId)
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
