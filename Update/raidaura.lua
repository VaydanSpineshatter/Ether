local D,F,_,C=unpack(select(2,...))
local pairs,ipairs=pairs,ipairs
local GetBuffDataByIndex,GetDebuffDataByIndex=C_UnitAuras.GetBuffDataByIndex,C_UnitAuras.GetDebuffDataByIndex
local GetAuraDataByAuraInstanceID=C_UnitAuras.GetAuraDataByAuraInstanceID
local UnitExists,raidBtn,twipe=UnitExists,D.raidBtn,table.wipe
local helpfulAuras,harmfulAuras={},{}
local dispelClass={MAGE={Curse=true},PRIEST={Magic=true,Disease=true},PALADIN={Magic=true,Disease=true,Poison=true},DRUID={Curse=true,Poison=true},SHAMAN={Disease=true,Poison=true}}
local canDispel=dispelClass[C.ClassName]
local function CheckCount(b,applications)
    if not b.count then return end
    if applications then
        b.count:SetText(applications)
        b.count:Show()
    else
        b.count:Hide()
    end
end
local function CheckTime(b,duration,expirationTime)
    if not b.cooldown then return end
    if duration and expirationTime and duration>0 then
        local start=expirationTime-duration
        b.cooldown:SetCooldown(start,duration)
    else
        b.cooldown:Clear()
    end
end
local function UpdateBorder(self,r,g,b)
    self.top:SetColorTexture(r,g,b)
    self.bottom:SetColorTexture(r,g,b)
    self.right:SetColorTexture(r,g,b)
    self.left:SetColorTexture(r,g,b)
end
F.UpdateBorder=UpdateBorder
local function CheckDispelBorder(button,dispelName)
    if not button.top then return end
    if dispelName then
        local c=DebuffTypeColor[dispelName] or DebuffTypeColor["none"]
        UpdateBorder(button,c.r,c.g,c.b)
    else
        UpdateBorder(button,0,0,0)
    end
end
local function CheckClassDispel(b,icon,dispelName)
    if not b.dispel then return end
    if icon and dispelName then
        b.dispel:SetTexture(icon)
        b.dispel:Show()
        local c=DebuffTypeColor[dispelName] or DebuffTypeColor["none"]
        b.dispelBorder:SetColorTexture(c.r,c.g,c.b)
        b.dispelBorder:Show()
    else
        b.dispel:Hide()
        b.dispelBorder:Hide()
    end
end
local function CheckBlink(b,icon,duration)
    if not b.blink then return end
    b.blink:SetTexture(icon)
    F:StartBlink(b.blink,duration,0.3)
end
local function UpdateAuras(auras,aura)
    if aura.duration and aura.duration>0 then
        if auras[aura.spellId] then
            CheckTime(auras[aura.spellId],aura.duration,aura.expirationTime)
        end
    end
    if aura.applications and aura.applications>1 then
        if auras[aura.spellId] then
            CheckCount(auras[aura.spellId],aura.applications or 0)
        end
    end
end
local function CheckAuras(b,aura)
    local status=D.DB["CONFIG"]
    if status[14]==1 then
        if aura.icon and aura.duration<=70 then
            CheckBlink(b,aura.icon,aura.duration)
        end
    end
    if status[15]==1 then
        if canDispel[aura.dispelName] then
            CheckClassDispel(b,aura.icon,aura.dispelName)
        end
    end
    if status[16]==1 then
        if aura.dispelName then
            CheckDispelBorder(b,aura.dispelName)
        end
    end
end
local function UpdateStatusIcons(b)
    local status=D.DB["CONFIG"]
    if status[14]==1 then
        if b.blink then
            F:StopBlink(b.blink)
        end
    end
    if status[15]==1 then
        if b.dispel then
            CheckClassDispel(b)
        end
    end
    if status[16]==1 then
        if b.top then
            CheckDispelBorder(b)
        end
    end
end
F.UpdateStatusIcons=UpdateStatusIcons
function F:UpdateRaidAuras(b)
    if not b or not b.unit or not b.RaidAuras then return end
    for spellId in pairs(b.RaidAuras) do
        F:Release(b.RaidAuras[spellId])
    end
    F:StopAllBlinks()
    UpdateBorder(b,0,0,0)
    twipe(b.RaidAuras)
    local unit=b.unit
    local c=D.DB["CUSTOM"]
    local i=1
    while true do
        local aura=GetBuffDataByIndex(unit,i)
        if not aura then break end
        if c[aura.spellId] and not c[aura.spellId][10] then
            b.RaidAuras[aura.spellId]=F:Acquire(b,c[aura.spellId])
            UpdateAuras(b.RaidAuras,aura)
            helpfulAuras[aura.auraInstanceID]=aura
        end
        i=i+1
    end
    i=1
    while true do
        local aura=GetDebuffDataByIndex(unit,i)
        if not aura then break end
        if c[aura.spellId] and c[aura.spellId][10] then
            b.RaidAuras[aura.spellId]=F:Acquire(b,c[aura.spellId])
            UpdateAuras(b.RaidAuras,aura)
        end
        CheckAuras(b,aura)
        harmfulAuras[aura.auraInstanceID]=aura
        i=i+1
    end
end
local update=false
function F:AuraUpdate(b,updateInfo)
    if not update then return end
    if not b then return end
    local unit=b.unit
    local c=D.DB["CUSTOM"]
    if updateInfo.isFullUpdate then
        F:UpdateRaidAuras(b)
        return
    end
    if updateInfo.addedAuras then
        for _,aura in ipairs(updateInfo.addedAuras) do
            if aura.isHelpful then
                if c[aura.spellId] and not c[aura.spellId][10] then
                    b.RaidAuras[aura.spellId]=F:Acquire(b,c[aura.spellId])
                    UpdateAuras(b.RaidAuras,aura)
                    helpfulAuras[aura.auraInstanceID]=aura
                end
            else
                if c[aura.spellId] and c[aura.spellId][10] then
                    b.RaidAuras[aura.spellId]=F:Acquire(b,c[aura.spellId])
                    UpdateAuras(b.RaidAuras,aura)
                end
                CheckAuras(b,aura)
                harmfulAuras[aura.auraInstanceID]=aura
            end
        end
    end
    if updateInfo.updatedAuraInstanceIDs then
        for _,auraInstanceID in ipairs(updateInfo.updatedAuraInstanceIDs) do
            local aura=GetAuraDataByAuraInstanceID(unit,auraInstanceID)
            if aura then
                if aura.isHelpful then
                    UpdateAuras(b.RaidAuras,aura)
                else
                    UpdateAuras(b.RaidAuras,aura)
                end
            end
        end
    end
    if updateInfo.removedAuraInstanceIDs then
        for _,auraInstanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
            if helpfulAuras[auraInstanceID] and helpfulAuras[auraInstanceID].spellId then
                for spellId in pairs(b.RaidAuras) do
                    if spellId==helpfulAuras[auraInstanceID].spellId then
                        F:Release(b.RaidAuras[spellId])
                    end
                end
                helpfulAuras[auraInstanceID]=nil
            end
            if harmfulAuras[auraInstanceID] then
                UpdateStatusIcons(b)
                if harmfulAuras[auraInstanceID].spellId then
                    for spellId in pairs(b.RaidAuras) do
                        if spellId==harmfulAuras[auraInstanceID].spellId then
                            F:Release(b.RaidAuras[spellId])
                        end
                    end
                end
                harmfulAuras[auraInstanceID]=nil
            end
        end
    end
end
function F:HideClassDispel()
    for _,b in pairs(raidBtn) do
        if b.dispel then
            CheckClassDispel(b)
        end
    end
end
F.CheckClassDispel=CheckClassDispel
function F:HideBorderDispel()
    for _,b in pairs(raidBtn) do
        if b.top then
            CheckDispelBorder(b)
        end
    end
end
F.CheckDispelBorder=CheckDispelBorder
function F:EnableRaidAura()
    twipe(helpfulAuras)
    twipe(harmfulAuras)
    update=true
    for _,b in pairs(raidBtn) do
        if UnitExists(b.unit) then
            F:UpdateRaidAuras(b)
        end
    end
end
function F:DisableRaidAura()
    update=false
    F:StopAllBlinks()
    F:ReleaseAll()
    for _,b in pairs(raidBtn) do
        if b then
            UpdateStatusIcons(b)
        end
    end
    twipe(helpfulAuras)
    twipe(harmfulAuras)
    F:WipePoolData()
end