local D,F,_,C=unpack(select(2,...))
local pairs,ipairs=pairs,ipairs
local GetBuffDataByIndex,GetDebuffDataByIndex=C_UnitAuras.GetBuffDataByIndex,C_UnitAuras.GetDebuffDataByIndex
local GetAuraDataByAuraInstanceID=C_UnitAuras.GetAuraDataByAuraInstanceID
local UnitExists,raidBtn,twipe,type=UnitExists,D.raidBtn,table.wipe,type
local helpfulAuras,harmfulAuras,dataHelpful,dataHarmful={},{},{},{}
local dispelClass={MAGE={Curse=true},PRIEST={Magic=true,Disease=true},PALADIN={Magic=true,Disease=true,Poison=true},DRUID={Curse=true,Poison=true},SHAMAN={Disease=true,Poison=true}}
local canDispel=dispelClass[C.ClassName]
local function UnitTable(unit)
    if not dataHelpful[unit] then
        dataHelpful[unit]={}
    end
    if not dataHarmful[unit] then
        dataHarmful[unit]={}
    end
end
local function GetRaidBtn(unit)
    UnitTable(unit)
    local b=raidBtn[unit]
    if b and b.unit==unit then
        return b
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
        dataHelpful[unit]=nil
    end
    if dataHarmful[unit] then
        for _,texture in pairs(dataHarmful[unit]) do
            if type(texture)~="table" then return end
            texture:Hide()
            texture:ClearAllPoints()
            texture:SetParent(nil)
        end
        dataHarmful[unit]=nil
    end
end
local function CleanupAuras()
    for unit in pairs(dataHelpful) do
        HideAuras(unit)
    end
    for unit in pairs(dataHarmful) do
        HideAuras(unit)
    end
end
F.CleanupAuras=CleanupAuras
local function CheckStacks(b,charges)
    if not b.stacks then return end
    if charges then
        b.stacks:SetText(charges)
        b.stacks:Show()
    else
        b.stacks:Hide()
    end
end
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
local function CheckDispelBorder(button,dispelName)
    if not button.top then return end
    if not button.topDispel and dispelName then
        local c=DebuffTypeColor[dispelName] or DebuffTypeColor["none"]
        UpdateBorder(button,c.r,c.g,c.b)
        button.topDispel=true
    else
        UpdateBorder(button,0,0,0)
        button.topDispel=false
    end
end
local function CheckClassDispel(b,icon,dispelName)
    if not b.dispel then return end
    if not b.classDispel and icon and dispelName then
        b.dispel:SetTexture(icon)
        b.dispel:Show()
        local c=DebuffTypeColor[dispelName] or DebuffTypeColor["none"]
        b.dispelBorder:SetColorTexture(c.r,c.g,c.b)
        b.dispelBorder:Show()
        b.classDispel=true
    else
        b.dispel:Hide()
        b.dispelBorder:Hide()
        b.classDispel=false
    end
end
local function CheckBlink(b,icon,duration)
    if not b.blink then return end
    b.blinkIcon:SetTexture(icon)
    F:StartBlink(b.blink,duration,0.3)
end
local function RemoveAuras(data,unit,spellId)
    if data[unit] and data[unit][spellId] then
        data[unit][spellId]:Hide()
        data[unit][spellId]:ClearAllPoints()
        data[unit][spellId]:SetParent(nil)
        data[unit][spellId]=nil
    end
end
local function UpdateAuras(aura,data,unit)
    if not data[unit] or not data[unit][aura.spellId] then return end
    if aura.duration and aura.duration>0 then
        CheckTime(data[unit][aura.spellId],aura.duration,aura.expirationTime)
    end
    if aura.applications and aura.applications>1 then
        CheckCount(data[unit][aura.spellId],aura.applications or 0)
    end
    if aura.charges and aura.charges>1 then
        CheckStacks(data[unit][aura.spellId],aura.charges or 0)
    end
end
local function AddHelpfulAuras(aura,b,unit,config)
    if config[aura.spellId] and not config[aura.spellId][10] then
        if not dataHelpful[unit][aura.spellId] then
            dataHelpful[unit][aura.spellId]=F:GetTexture(b,config[aura.spellId])
        else
            RemoveAuras(dataHelpful,unit,aura.spellId)
        end
        UpdateAuras(aura,dataHelpful,unit)
    end
end
local function AddHarmfulAuras(aura,b,unit,config)
    if config[aura.spellId] and config[aura.spellId][10] then
        if not dataHarmful[unit][aura.spellId] then
            dataHarmful[unit][aura.spellId]=F:GetTexture(b,config[aura.spellId])
        else
            RemoveAuras(dataHarmful,unit,aura.spellId)
        end
        UpdateAuras(aura,dataHarmful,unit)
    end
    if D.DB["CONFIG"][14]==1 then
        if aura.icon and aura.duration<=70 then
            CheckBlink(b,aura.icon,aura.duration)
        end
    end
    if D.DB["CONFIG"][15]==1 then
        if canDispel[aura.dispelName] then
            CheckClassDispel(b,aura.icon,aura.dispelName)
        end
    end
    if D.DB["CONFIG"][16]==1 then
        if aura.dispelName then
            CheckDispelBorder(b,aura.dispelName)
        end
    end
end
local function UpdateStatusIcons(b)
    if b.blink then
        F:StopBlink(b.blink)
    end
    if b.dispel then
        CheckClassDispel(b)
    end
    if b.top then
        CheckDispelBorder(b)
    end
end
F.UpdateStatusIcons=UpdateStatusIcons
function F:RaidAurasFullUpdate(unit)
    if not unit or not UnitExists(unit) then return end
    local b=GetRaidBtn(unit)
    if not b then return end
    UpdateStatusIcons(b)
    local c=D.DB["CUSTOM"]
    local i=1
    while true do
        local aura=GetBuffDataByIndex(unit,i)
        if not aura then break end
        AddHelpfulAuras(aura,b,unit,c)
        helpfulAuras[aura.auraInstanceID]=aura
        i=i+1
    end
    i=1
    while true do
        local aura=GetDebuffDataByIndex(unit,i)
        if not aura then break end
        AddHarmfulAuras(aura,b,unit,c)
        harmfulAuras[aura.auraInstanceID]=aura
        i=i+1
    end
end
local update=false
function F:raidAuraUpdate(unit,updateInfo)
    if not update then return end
    local b=GetRaidBtn(unit)
    if not b then return end
    local c=D.DB["CUSTOM"]
    if updateInfo.isFullUpdate then
        F:RaidAurasFullUpdate(unit)
        return
    end
    if updateInfo.addedAuras then
        for _,aura in ipairs(updateInfo.addedAuras) do
            if aura.isHelpful then
                AddHelpfulAuras(aura,b,unit,c)
                helpfulAuras[aura.auraInstanceID]=aura
            end
            if aura.isHarmful then
                AddHarmfulAuras(aura,b,unit,c)
                harmfulAuras[aura.auraInstanceID]=aura
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
                    UpdateAuras(aura,dataHelpful,unit)
                end
                if aura.isHarmful then
                    local info=harmfulAuras[auraInstanceID]
                    if not info then return end
                    UpdateAuras(aura,dataHarmful,unit)
                end
            end
        end
    end
    if updateInfo.removedAuraInstanceIDs then
        for _,auraInstanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
            if helpfulAuras[auraInstanceID] then
                local aura=helpfulAuras[auraInstanceID]
                if not aura then return end
                RemoveAuras(dataHelpful,unit,aura.spellId)
                helpfulAuras[auraInstanceID]=nil
            end
            if harmfulAuras[auraInstanceID] then
                local aura=harmfulAuras[auraInstanceID]
                if not aura then return end
                RemoveAuras(dataHarmful,unit,aura.spellId)
                UpdateStatusIcons(b)
                harmfulAuras[auraInstanceID]=nil
            end
        end
    end
end
function F:HideClassDispel()
    for _,b in pairs(raidBtn) do
        if b.dispel and b.classDispel then
            CheckClassDispel(b)
        end
    end
end
function F:HideBorderDispel()
    for _,b in pairs(raidBtn) do
        if b.top and b.topDispel then
            CheckDispelBorder(b)
        end
    end
end
function F:AuraWipe()
    twipe(helpfulAuras)
    twipe(harmfulAuras)
    twipe(dataHelpful)
    twipe(dataHarmful)
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
    for _,b in pairs(raidBtn) do
        if b then
            UpdateStatusIcons(b)
        end
    end
    CleanupAuras()
    F:AuraWipe()
end