local D,F,_,C=unpack(select(2,...))
local pairs,ipairs=pairs,ipairs
local GetBuffDataByIndex,GetDebuffDataByIndex=C_UnitAuras.GetBuffDataByIndex,C_UnitAuras.GetDebuffDataByIndex
local GetAuraDataByAuraInstanceID=C_UnitAuras.GetAuraDataByAuraInstanceID
local UnitExists,raidBtn,twipe=UnitExists,D.raidBtn,table.wipe
local helpfulAuras,harmfulAuras,dispelAuras={},{},{}
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
local function UpdateStatusIcons(status,b)
    if status[14]==1 then
        if b.blink then
            F:StopBlink(b.blink)
        end
    end
    if status[15]==1 then
        if b.dispel and b.dispel:IsShown() then
            b.dispel:Hide()
        end
    end
    if status[16]==1 then
        UpdateBorder(b,0,0,0)
    end
end
F.UpdateStatusIcons=UpdateStatusIcons
function F:UpdateRaidAuras(b)
    if not b or not b.unit or not b.RaidAuras then return end
    for spellId in pairs(b.RaidAuras) do
        F:Release(b.RaidAuras[spellId])
    end
    local unit=b.unit
    local c=D.DB["CUSTOM"]
    local status=D.DB["CONFIG"]
    UpdateStatusIcons(status,b)
    local i=1
    while true do
        local aura=GetBuffDataByIndex(unit,i)
        if not aura then break end
        if c[aura.spellId] then
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
        if c[aura.spellId] then
            b.RaidAuras[aura.spellId]=F:Acquire(b,c[aura.spellId])
            UpdateAuras(b.RaidAuras,aura)
            harmfulAuras[aura.auraInstanceID]=aura
        end
        if aura.icon then
            if status[14]==1 then
                if aura.duration<=60 then
                    b.blink:SetTexture(aura.icon)
                    F:StartBlink(b.blink,aura.duration,0.3)
                end
            end
            if aura.dispelName then
                if status[16]==1 then
                    local color=DebuffTypeColor[aura.dispelName]
                    if color then
                        UpdateBorder(b,color.r,color.g,color.b)
                    end
                end
                if status[15]==1 then
                    if canDispel[aura.dispelName] then
                        b.dispel:SetTexture(aura.icon)
                        b.dispel:Show()
                    end
                end
            end
            dispelAuras[aura.auraInstanceID]=aura
        end
        i=i+1
    end
end
local update=false
function F:AuraUpdate(b,updateInfo)
    if not update then return end
    if not b then return end
    local unit=b.unit
    local c=D.DB["CUSTOM"]
    local status=D.DB["CONFIG"]
    if updateInfo.isFullUpdate then
        F:UpdateRaidAuras(b)
        return
    end
    if updateInfo.addedAuras then
        for _,aura in ipairs(updateInfo.addedAuras) do
            if aura.isHelpful then
                if c[aura.spellId] then
                    b.RaidAuras[aura.spellId]=F:Acquire(b,c[aura.spellId])
                    UpdateAuras(b.RaidAuras,aura)
                    helpfulAuras[aura.auraInstanceID]=aura
                end
            end
            if aura.isHarmful then
                if c[aura.spellId] then
                    b.RaidAuras[aura.spellId]=F:Acquire(b,c[aura.spellId])
                    UpdateAuras(b.RaidAuras,aura)
                    harmfulAuras[aura.auraInstanceID]=aura
                end
                if aura.icon then
                    if status[14]==1 then
                        if aura.duration<=60 then
                            if status[14]==1 then
                                b.blink:SetTexture(aura.icon)
                                F:StartBlink(b.blink,aura.duration,0.3)
                            end
                        end
                    end
                    if aura.dispelName then
                        if status[16]==1 then
                            local color=DebuffTypeColor[aura.dispelName]
                            if color then
                                UpdateBorder(b,color.r,color.g,color.b)
                            end
                        end
                        if status[15]==1 then
                            if canDispel[aura.dispelName] then
                                b.dispel:SetTexture(aura.icon)
                                b.dispel:Show()
                            end
                        end
                    end
                    dispelAuras[aura.auraInstanceID]=aura
                end
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
            if helpfulAuras[auraInstanceID] then
                for spellId in pairs(b.RaidAuras) do
                    if spellId==helpfulAuras[auraInstanceID].spellId then
                        F:Release(b.RaidAuras[spellId])
                    end
                end
                helpfulAuras[auraInstanceID]=nil
            end
            if harmfulAuras[auraInstanceID] then
                if harmfulAuras[auraInstanceID].spellId then
                    for spellId in pairs(b.RaidAuras) do
                        if spellId==harmfulAuras[auraInstanceID].spellId then
                            F:Release(b.RaidAuras[spellId])
                        end
                    end
                end
                harmfulAuras[auraInstanceID]=nil
            end
            if dispelAuras[auraInstanceID] then
                UpdateStatusIcons(status,b)
                dispelAuras[auraInstanceID]=nil
            end
        end
    end
end
function F:HideClassDispel()
    for _,b in pairs(raidBtn) do
        if b.dispel then
            b.dispel:Hide()
        end
    end
end
function F:HideBorderDispel()
    for _,b in pairs(raidBtn) do
        UpdateBorder(b,0,0,0)
    end
end
function F:EnableRaidAura()
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
    twipe(helpfulAuras)
    twipe(harmfulAuras)
    twipe(dispelAuras)
    F:WipePoolData()
end