local _,Ether=...
local math_floor,math_ceil=math.floor,math.ceil
local tinsert=table.insert
local pairs,ipairs=pairs,ipairs
local GetBuffDataByIndex=C_UnitAuras.GetBuffDataByIndex
local GetDebuffDataByIndex=C_UnitAuras.GetDebuffDataByIndex
local GetAuraDataByIndex=C_UnitAuras.GetAuraDataByIndex
local UnitGUID=UnitGUID
local UnitExists=UnitExists
local GetAuraDataByAuraInstanceID=C_UnitAuras.GetAuraDataByAuraInstanceID
local unpack,GetTime=unpack,GetTime
local raidButtons=Ether.raidButtons
local soloButtons=Ether.soloButtons
local NewTicker=C_Timer.NewTicker
local dispelClass={
    ["MAGE"]={Curse=true},
    ["PRIEST"]={Magic=true,Disease=true},
    ["PALADIN"]={Magic=true,Disease=true,Poison=true},
    ["DRUID"]={Curse=true,Poison=true},
    ["SHAMAN"]={Disease=true,Poison=true}
}

local playerClass=select(2,UnitClass("player"))
local canDispel=dispelClass[playerClass] or {}
local DISPEL_PRIORITY={
    ["Magic"]=4,
    ["Disease"]=3,
    ["Curse"]=2,
    ["Poison"]=1
}

local dispelCache={}
local helpfulAuras={}
local harmfulAuras={}
local dataHelpful={}
local dataHarmful={}
local dataIcon={}
local function CheckRaidButtons(unit)
    local button=raidButtons[unit]
    if button and button.unit==unit then
        return button
    end
    return nil
end

local function updateAuraPos(tbl,spellId)
    local C=Ether.DB[1003][spellId]
    if C then
        for guid in pairs(tbl) do
            if tbl[guid] and tbl[guid][spellId] then
                tbl[guid][spellId].Shown=tbl[guid][spellId]:IsShown()
                tbl[guid][spellId]:Hide()
                tbl[guid][spellId]:ClearAllPoints()
                tbl[guid][spellId]:SetColorTexture(unpack(C[2]))
                tbl[guid][spellId]:SetSize(C[3],C[3])
                tbl[guid][spellId]:SetPoint(C[4],C[5],C[6])
                if tbl[guid][spellId].Shown then
                    tbl[guid][spellId]:Show()
                    tbl[guid][spellId].Shown=nil
                end
            end
        end
    end
end

local function ScanDispelAuras(unit)
    if not unit or not UnitExists(unit) then
        return nil,{}
    end
    local bestDispel=nil
    local bestPriority=0

    local index=1
    while true do
        local aura=GetAuraDataByIndex(unit,index,"HARMFUL")
        if not aura then break end
        if aura.dispelName and canDispel[aura.dispelName] then
            local priority=DISPEL_PRIORITY[aura.dispelName] or 0
            if priority>bestPriority then
                bestPriority=priority
                bestDispel={
                    name=aura.name,
                    icon=aura.icon,
                    dispelName=aura.dispelName,
                    spellId=aura.spellId,
                    index=index
                }
            end
        end
        index=index+1
    end

    return bestDispel
end

local function GetCachedDispel(unit,guid)
    if not guid then return nil end

    local cached=dispelCache[guid]
    if cached and (GetTime()-cached.timestamp)<3 then
        return cached.dispel
    end

    local dispel=ScanDispelAuras(unit)
    dispelCache[guid]={
        dispel=dispel,
        timestamp=GetTime()
    }

    return dispel
end

local function CheckDispelType(self,dispelName)
    local color=DebuffTypeColor[dispelName]
    if color then
        self.border:SetColorTexture(color.r,color.g,color.b)
        self.border:Show()
    else
        self.border:Hide()
    end
end

function Ether:HideButtonDispel(button)
    if not button or not button.unit or not button.Dispel then return end
    if button.Dispel.indicator then
        button.Dispel.indicator:Hide()
    end
    if button.Dispel.border then
        button.Dispel.border:Hide()
    end
    if button.Dispel.dispellableDebuff then
        button.Dispel.dispellableDebuff=nil
    end
end

local function UpdateButtonDispel(button,guid)
    if not button or not button.unit or not button.Dispel then return end
    local unit=button.unit
    local dispel=GetCachedDispel(unit,guid)
    if dispel then
        button.Dispel.indicator:SetTexture(dispel.icon)
        local color=DebuffTypeColor[dispel.dispelName] or DebuffTypeColor["none"]
        button.Dispel.border:SetColorTexture(color.r,color.g,color.b)
        button.Dispel.indicator:Show()
        button.Dispel.border:Show()
        button.Dispel.dispellableDebuff=dispel
    else
        button.Dispel.indicator:Hide()
        button.Dispel.border:Hide()
        button.Dispel.dispellableDebuff=nil
    end
end

local function TrackSpecificAura(unit,spellId)
    local auraData=C_UnitAuras.GetAuraDataBySpellName(unit,spellId)
    if not auraData then return end
    return auraData
end

local function CheckAuraGroup(unit,spellIds)
    local found={}
    for _,spellId in ipairs(spellIds) do
        local auraData=C_UnitAuras.GetAuraDataBySpellName(unit,spellId)
        if auraData then
            found[spellId]={
                name=auraData.name,
                icon=auraData.icon,
                count=auraData.applications,
                duration=auraData.duration,
                expirationTime=auraData.expirationTime
            }
        end
    end
    return found
end

function Ether:OnDispelAuraChanged(unit,guid)
    if guid then
        dispelCache[guid]=nil
    end
    local button=CheckRaidButtons(unit)
    if button then
        UpdateButtonDispel(button,guid)
    end
end

function Ether:CleanupCache()
    local currentTime=GetTime()
    for guid,data in pairs(dispelCache) do
        if (currentTime-data.timestamp)>10 then
            dispelCache[guid]=nil
        end
    end
end

function Ether:SaveAuraPosition(spellId)
    if not spellId then return end
    local debuff=Ether.DB[1003][spellId][8]
    if debuff then
        updateAuraPos(dataHarmful,spellId)
    else
        updateAuraPos(dataHelpful,spellId)
    end
end

function Ether:UpdatePrediction(button)
    if not button then return end
    if button.myPrediction then
        button.myPrediction:Hide()
    end
    if button.prediction then
        button.prediction:Hide()
    end
end

local function RemoveGUID(guid)
    if dataHelpful[guid] then
        dataHelpful[guid]=nil
    end
    if dataHarmful[guid] then
        dataHarmful[guid]=nil
    end
    if dataIcon[guid] then
        dataIcon[guid]=nil
    end
end

local function AddGUID(guid)
    if not dataHelpful[guid] then
        dataHelpful[guid]={}
    end
    if not dataHarmful[guid] then
        dataHarmful[guid]={}
    end
    if not dataIcon[guid] then
        dataIcon[guid]={}
    end
end

local guidData=Ether.guidData
Ether.CheckNewGUID=function(guid)
    if not guid then return end
    if not guidData[guid] then
        guidData[guid]=true
        Ether:EtherDebug("New GUID found: ",tostring(guid))
        AddGUID(guid)
        Ether:EtherDebug("GUID added: ",tostring(guid))
    end
end

Ether.CheckOldGUID=function(guid)
    if not guid then return end
    if guidData[guid] then
        guidData[guid]=nil
        Ether:EtherDebug("Old GUID found: ",tostring(guid))
        RemoveGUID(guid)
        Ether:EtherDebug("GUID cleared: ",tostring(guid))
    end
end

local TexPool=Ether:CreateObjPool(Ether.TextureMethod)
Ether.TexPool=TexPool
function Ether:RaidAurasFullUpdate(button,guid)
    if not button or not guid then return end
    local C=Ether.DB[1003]
    Ether.CheckNewGUID(guid)
    if not guidData[guid] then return end
    local unit=button.unit
    local index=1
    while true do
        local aura=GetBuffDataByIndex(unit,index)
        if not aura then break end
        if C[aura.spellId] and C[aura.spellId][9] then
            if dataHelpful[guid][aura.spellId] then
                TexPool:Release(dataHelpful[guid][aura.spellId])
            end
            dataHelpful[guid][aura.spellId]=TexPool:Acquire(C[aura.spellId],button)
            helpfulAuras[aura.auraInstanceID]={
                spellId=aura.spellId,
                guid=guid
            }
        end
        index=index+1
    end
    index=1
    while true do
        local aura=GetDebuffDataByIndex(unit,index)
        if not aura then break end
        if aura.spellId then
            if C[aura.spellId] and C[aura.spellId][9] then
                if dataHarmful[guid][aura.spellId] then
                    TexPool:Release(dataHarmful[guid][aura.spellId])
                end
                dataHarmful[guid][aura.spellId]=TexPool:Acquire(C[aura.spellId],button)
            end
            if aura.dispelName then
                if dataIcon[guid][aura.spellId] then
                    Ether.StopBlink(dataIcon[guid][aura.spellId])
                end
                local color=DebuffTypeColor[aura.dispelName] or DebuffTypeColor["none"]
                button.dispelIcon:SetTexture(aura.icon)
                button.dispelBorder:SetColorTexture(color.r,color.g,color.b)
                dataIcon[guid][aura.spellId]=button.dispelFrame
                Ether.StartBlink(dataIcon[guid][aura.spellId],aura.duration,0.3)
            end
            harmfulAuras[aura.auraInstanceID]={
                spellId=aura.spellId,
                unit=unit,
                guid=guid
            }
        end
        index=index+1
    end
end

local raidUpdate=false
local function raidAuraUpdate(unit,updateInfo)
    if not raidUpdate then return end
    local button=CheckRaidButtons(unit)
    if not button or not UnitExists(unit) then return end
    local guid=UnitGUID(unit)
    if not guid then return end
    Ether.CheckNewGUID(guid)
    if not guidData[guid] then return end
    local isFullUpdate=not updateInfo or updateInfo.isFullUpdate
    local C=Ether.DB[1003]
    if isFullUpdate then
        local update=UnitGUID(button.unit)
        if update and update==guid then
            Ether:RaidAurasFullUpdate(button,update)
        end
    else
        if updateInfo.addedAuras then
            for _,aura in ipairs(updateInfo.addedAuras) do
                if aura.isHelpful then
                    if C[aura.spellId] and C[aura.spellId][9] then
                        if dataHelpful[guid][aura.spellId] then
                            TexPool:Release(dataHelpful[guid][aura.spellId])
                        end
                        dataHelpful[guid][aura.spellId]=TexPool:Acquire(C[aura.spellId],button)
                    end
                    helpfulAuras[aura.auraInstanceID]={
                        spellId=aura.spellId,
                        guid=guid
                    }
                end
                if aura.isHarmful then
                    if aura.spellId then
                        if C[aura.spellId] and C[aura.spellId][9] then
                            if dataHarmful[guid][aura.spellId] then
                                TexPool:Release(dataHarmful[guid][aura.spellId])
                            end
                            dataHarmful[guid][aura.spellId]=TexPool:Acquire(C[aura.spellId],button)
                        end
                        if aura.icon and aura.duration<120 then
                            Ether:OnDispelAuraChanged(unit,guid)
                            local color=DebuffTypeColor[aura.dispelName] or DebuffTypeColor["none"]
                            button.dispelIcon:SetTexture(aura.icon)
                            button.dispelBorder:SetColorTexture(color.r,color.g,color.b)
                            dataIcon[guid][aura.spellId]=button.dispelFrame
                            Ether.StartBlink(dataIcon[guid][aura.spellId],aura.duration,0.3)
                        end
                        harmfulAuras[aura.auraInstanceID]={
                            spellId=aura.spellId,
                            unit=unit,
                            guid=guid
                        }
                    end
                end
            end
        end
        if updateInfo.removedAuraInstanceIDs then
            for _,auraInstanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
                if harmfulAuras[auraInstanceID] then
                    local info=harmfulAuras[auraInstanceID]
                    if info.unit and info.guid then
                        Ether:OnDispelAuraChanged(info.unit,info.guid)
                    end
                    if dataHarmful[info.guid] and dataHarmful[info.guid][info.spellId] then
                        TexPool:Release(dataHarmful[info.guid][info.spellId])
                        dataHarmful[info.guid][info.spellId]=nil
                    end
                    if dataIcon[info.guid] and dataIcon[info.guid][info.spellId] then
                        Ether.StopBlink(dataIcon[info.guid][info.spellId])
                        dataIcon[info.guid][info.spellId]=nil
                    end
                    harmfulAuras[auraInstanceID]=nil
                end
                if helpfulAuras[auraInstanceID] then
                    local info=helpfulAuras[auraInstanceID]
                    if dataHelpful[info.guid] and dataHelpful[info.guid][info.spellId] then
                        TexPool:Release(dataHelpful[info.guid][info.spellId])
                        dataHelpful[info.guid][info.spellId]=nil
                    end
                    helpfulAuras[auraInstanceID]=nil
                end
            end
        end
    end
end

local function CheckCount(self,count)
    if count and count>1 then
        self.count:SetText(count)
        self.count:Show()
    else
        self.count:Hide()
    end
end

local function CheckDuration(self,duration,expirationTime)
    if duration and duration>0 and expirationTime and expirationTime>0 then
        local startTime=expirationTime-duration
        self.timer:SetCooldown(startTime,duration)
        self.timer:Show()
    else
        self.timer:Hide()
    end
end

local function CheckIcon(self,icon)
    if icon then
        self.icon:SetTexture(icon)
        self.icon:Show()
    else
        self.icon:Hide()
    end
end

local function AuraPosition(i)
    local row=math_floor((i-1)/8)
    local col=(i-1)%8
    local xOffset=col*(13+1)
    local yOffset=1+row*(13+1)
    return xOffset,yOffset
end

local function CheckCharges(self,charges)
    if charges and charges>1 then
        self.stacks:SetText(charges)
        self.stacks:Show()
    else
        self.stacks:Hide()
    end
end

local buffX,buffY={},{}
local debuffX,debuffY={},{}

for i=1,16 do
    local x,y=AuraPosition(i)

    buffX[i]=x-1
    buffY[i]=y+3

    debuffX[i]=x-1
    debuffY[i]=y+31
end

local function SortBuffs(button,buffs,LastBuffs)
    for i=1,15 do
        if not LastBuffs[i] then
            for j=i+1,16 do
                if LastBuffs[j] then
                    buffs[i].icon:SetTexture(buffs[j].icon:GetTexture())
                    buffs[i]:Show()
                    LastBuffs[i]=LastBuffs[j]
                    buffs[j]:Hide()
                    LastBuffs[j]=nil
                    local xOffset,yOffset=AuraPosition(i)
                    buffs[i]:ClearAllPoints()
                    buffs[i]:SetPoint("BOTTOMLEFT",button,"TOPLEFT",xOffset-1,yOffset+3)
                    break
                end
            end
        end
    end
end
local function SortDebuffs(button,debuffs,LastDebuffs,buffCount)
    for i=1,15 do
        if not LastDebuffs[i] then
            for j=i+1,16 do
                if LastDebuffs[j] then
                    debuffs[i].icon:SetTexture(debuffs[j].icon:GetTexture())
                    debuffs[i]:Show()
                    LastDebuffs[i]=LastDebuffs[j]
                    debuffs[j]:Hide()
                    LastDebuffs[j]=nil
                    local pos=i+buffCount
                    local xOffset,yOffset=AuraPosition(pos)
                    debuffs[i]:ClearAllPoints()
                    debuffs[i]:SetPoint("BOTTOMLEFT",button,"TOPLEFT",xOffset-1,yOffset+3)
                    break
                end
            end
        end
    end
end

local function GetAuras(unit)
    if not unit then return end
    local button=soloButtons[Ether:UnitNumber(unit)]
    if not button or not button.Aura then return end
    button.Aura.LastBuffs=button.Aura.LastBuffs or {}
    button.Aura.LastDebuffs=button.Aura.LastDebuffs or {}
    local buffCount,debuffCount=0,0
    local index=1
    while true do
        local aura=GetBuffDataByIndex(unit,index)
        if not aura then break end
        local now=button.Aura.Buffs[index]
        if now then
            if not button.Aura.LastBuffs[index] then
                button.Aura.LastBuffs[index]={}
            end
            local last=button.Aura.LastBuffs[index]
            if last.auraInstanceID~=aura.auraInstanceID then
                if aura.icon then
                    CheckIcon(now,aura.icon)
                    last.icon=now.icon
                end
                last.auraInstanceID=aura.auraInstanceID
            end
            if aura.applications then
                CheckCount(now,aura.applications or 0)
            end
            if aura.duration then
                CheckDuration(now,aura.duration or 0,aura.expirationTime or 0)
            end
            if aura.charges then
                CheckCharges(now,aura.charges)
            end
            local xOffset,yOffset=AuraPosition(index)
            now:ClearAllPoints()
            now:SetPoint("BOTTOMLEFT",button,"TOPLEFT",xOffset-1,yOffset+3)
            now:Show()
            buffCount=buffCount+1
        end
        index=index+1
    end
    index=1
    while true do
        local aura=GetDebuffDataByIndex(unit,index)
        if not aura then break end
        local buffRows=math_ceil(buffCount/8)
        local startY=buffRows*(14+1)+2
        local now=button.Aura.Debuffs[index]
        if now then
            local row=math_floor((index-1)/8)
            local col=(index-1)%8
            local yOffset=startY+row*(14+1)
            now:ClearAllPoints()
            now:SetPoint("BOTTOMLEFT",button,"TOPLEFT",col*(14+1)-1,yOffset+2)
            if not button.Aura.LastDebuffs[index] then
                button.Aura.LastDebuffs[index]={}
            end
            local last=button.Aura.LastDebuffs[index]
            if last.auraInstanceID~=aura.auraInstanceID then
                if aura.icon then
                    CheckIcon(now,aura.icon)
                    last.icon=now.icon
                end
                if aura.dispelName then
                    CheckDispelType(now,aura.dispelName)
                    last.dispelName=now.dispelName
                end
                last.auraInstanceID=aura.auraInstanceID
            end
            if aura.applications then
                CheckCount(now,aura.applications or 0)
            end
            if aura.duration then
                CheckDuration(now,aura.duration or 0,aura.expirationTime or 0)
            end
            if aura.charges then
                CheckCharges(now,aura.charges)
            end
            now:Show()
            debuffCount=debuffCount+1
        end
        index=index+1
    end
    for i=buffCount+1,16 do
        local now=button.Aura.Buffs[i]
        if now then now:Hide() end
        if button.Aura.LastBuffs[i] then
            button.Aura.LastBuffs[i].auraInstanceID=nil
        end
    end
    for i=debuffCount+1,16 do
        local now=button.Aura.Debuffs[i]
        if now then now:Hide() end
        if button.Aura.LastDebuffs[i] then
            button.Aura.LastDebuffs[i].auraInstanceID=nil
        end
    end
end

local UpdateSolo=false
local function UnitAuraUpdate(unit,updateInfo)
    if not UpdateSolo then return end
    local button=soloButtons[Ether:UnitNumber(unit)]
    if not button or not button.Aura then return end
    local buffs=button.Aura.Buffs
    local debuffs=button.Aura.Debuffs
    local LastBuffs=button.Aura.LastBuffs
    local LastDebuffs=button.Aura.LastDebuffs
    local helpfulRemoved,harmfulRemoved=false,false
    local buffCount,debuffCount=0,0
    local isFullUpdate=not updateInfo or updateInfo.isFullUpdate
    if isFullUpdate then
        GetAuras(unit)
    else
        if updateInfo.addedAuras then
            for _,aura in ipairs(updateInfo.addedAuras) do
                if aura.isHelpful and aura.icon then
                    for index=1,16 do
                        local now=buffs[index]
                        if now and not now:IsShown() then
                            if not LastBuffs[index] then
                                LastBuffs[index]={}
                            end
                            local last=LastBuffs[index]
                            if aura.icon then
                                CheckIcon(now,aura.icon)
                                last.icon=now.icon
                            end
                            last.auraInstanceID=aura.auraInstanceID
                            LastBuffs[index]=last
                            if aura.applications and aura.applications>1 then
                                now.count:SetText(aura.applications)
                                now.count:Show()
                            else
                                now.count:Hide()
                            end
                            if aura.duration and aura.duration>0 and aura.expirationTime and aura.expirationTime>0 then
                                local startTime=aura.expirationTime-aura.duration
                                now.timer:SetCooldown(startTime,aura.duration)
                                now.timer:Show()
                            else
                                now.timer:Hide()
                            end
                            if aura.charges then
                                CheckCharges(now,aura.charges)
                            end
                            local xOffset,yOffset=AuraPosition(index)
                            now:ClearAllPoints()
                            now:SetPoint("BOTTOMLEFT",button,"TOPLEFT",xOffset-1,yOffset+3)
                            now:Show()
                            buffCount=buffCount+1
                            break
                        end
                    end
                end
                if aura.isHarmful and aura.icon then
                    for index=1,16 do
                        local now=debuffs[index]
                        if now and not now:IsShown() then
                            if not LastDebuffs[index] then
                                LastDebuffs[index]={}
                            end
                            local last=LastDebuffs[index]
                            if aura.icon then
                                CheckIcon(now,aura.icon)
                                last.icon=now.icon
                            end
                            last.auraInstanceID=aura.auraInstanceID
                            LastDebuffs[index]=last
                            if aura.dispelName then
                                CheckDispelType(now,aura.dispelName)
                                last.dispelName=now.dispelName
                            end
                            if aura.applications and aura.applications>1 then
                                now.count:SetText(aura.applications)
                                now.count:Show()
                            else
                                now.count:Hide()
                            end
                            if aura.duration and aura.duration>0 and aura.expirationTime and aura.expirationTime>0 then
                                local startTime=aura.expirationTime-aura.duration
                                now.timer:SetCooldown(startTime,aura.duration)
                                now.timer:Show()
                            else
                                now.timer:Hide()
                            end
                            if aura.charges then
                                CheckCharges(now,aura.charges)
                            end
                            local buffRows=math_ceil(buffCount/8)
                            local startY=buffRows*(14+1)+2
                            local row=math_floor((index-1)/8)
                            local col=(index-1)%8
                            local yOffset=startY+row*(14+1)
                            now:ClearAllPoints()
                            now:SetPoint("BOTTOMLEFT",button,"TOPLEFT",col*(14+1)-1,yOffset+2)
                            now:Show()
                            debuffCount=debuffCount+1
                            break
                        end
                    end
                end
            end
        end
        if updateInfo.updatedAuraInstanceIDs then
            for _,auraInstanceID in ipairs(updateInfo.updatedAuraInstanceIDs) do
                local aura=GetAuraDataByAuraInstanceID(unit,auraInstanceID)
                if not aura then break end
                if aura.isHelpful then
                    if aura.applications then
                        for i=1,16 do
                            local last=LastBuffs[i]
                            if last and last.auraInstanceID==auraInstanceID then
                                local now=buffs[i]
                                if aura.applications and aura.applications>1 then
                                    now.count:SetText(aura.applications)
                                    now.count:Show()
                                else
                                    now.count:Hide()
                                end
                                break
                            end
                        end
                    end
                    if aura.duration then
                        for i=1,16 do
                            local last=LastBuffs[i]
                            if last and last.auraInstanceID==auraInstanceID then
                                local now=buffs[i]
                                if aura.duration and aura.duration>0 and aura.expirationTime and aura.expirationTime>0 then
                                    local startTime=aura.expirationTime-aura.duration
                                    now.timer:SetCooldown(startTime,aura.duration)
                                    now.timer:Show()
                                else
                                    now.timer:Hide()
                                end
                                break
                            end
                        end
                    end
                    if aura.charges then
                        for i=1,16 do
                            local last=LastBuffs[i]
                            if last and last.auraInstanceID==auraInstanceID then
                                local now=buffs[i]
                                CheckCharges(now,aura.charges)
                                break
                            end
                        end
                    end
                end
                if aura.isHarmful then
                    if aura.applications then
                        for i=1,16 do
                            local last=LastDebuffs[i]
                            if last and last.auraInstanceID==auraInstanceID then
                                local now=debuffs[i]
                                if aura.applications and aura.applications>1 then
                                    now.count:SetText(aura.applications)
                                    now.count:Show()
                                else
                                    now.count:Hide()
                                end
                                break
                            end
                        end
                    end
                    if aura.duration then
                        for i=1,16 do
                            local last=LastBuffs[i]
                            if last and last.auraInstanceID==auraInstanceID then
                                local now=debuffs[i]
                                if aura.duration and aura.duration>0 and aura.expirationTime and aura.expirationTime>0 then
                                    local startTime=aura.expirationTime-aura.duration
                                    now.timer:SetCooldown(startTime,aura.duration)
                                    now.timer:Show()
                                else
                                    now.timer:Hide()
                                end
                                break
                            end
                        end
                    end
                    if aura.charges then
                        for i=1,16 do
                            local last=LastBuffs[i]
                            if last and last.auraInstanceID==auraInstanceID then
                                local now=debuffs[i]
                                CheckCharges(now,aura.charges)
                                break
                            end
                        end
                    end
                end
            end
        end
        if updateInfo.removedAuraInstanceIDs then
            for _,auraInstanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
                for i=1,16 do
                    local last=LastBuffs[i]
                    if last and last.auraInstanceID==auraInstanceID then
                        if buffs[i] then buffs[i]:Hide() end
                        LastBuffs[i]=nil
                        helpfulRemoved=true
                        break
                    end
                end
                for i=1,16 do
                    local last=LastDebuffs[i]
                    if last and last.auraInstanceID==auraInstanceID then
                        if debuffs[i] then debuffs[i]:Hide() end
                        LastDebuffs[i]=nil
                        harmfulRemoved=true
                        break
                    end
                end
            end
        end
        if helpfulRemoved then
            SortBuffs(button,buffs,LastBuffs)
        end
        if harmfulRemoved then
            SortDebuffs(button,debuffs,LastDebuffs,buffCount)
        end
    end
end

local function WipeSoloAuras(button)
    wipe(button.Aura.Buffs)
    wipe(button.Aura.Debuffs)
    wipe(button.Aura.LastBuffs)
    wipe(button.Aura.LastDebuffs)
end

local function auraTblRefresh(button,state)
    if not button or not button.Aura then return end
    for i=1,16 do
        if button.Aura.Buffs and button.Aura.Buffs[i] then
            button.Aura.Buffs[i]:SetShown(state)
        end
        if button.Aura.Debuffs and button.Aura.Debuffs[i] then
            button.Aura.Debuffs[i]:SetShown(state)
        end
    end
    if not state then
        WipeSoloAuras(button)
    end
end

function Ether:SoloAuraFullInitial(button)
    for i=1,16 do
        if button.Aura.Buffs and button.Aura.Buffs[i] then
            button.Aura.Buffs[i]:SetShown(true)
        end
        if button.Aura.Debuffs and button.Aura.Debuffs[i] then
            button.Aura.Debuffs[i]:SetShown(true)
        end
    end
    GetAuras(button.unit)
end

function Ether:AuraWipe()
    wipe(helpfulAuras)
    wipe(harmfulAuras)
    wipe(dataHelpful)
    wipe(dataHarmful)
    wipe(dataIcon)
    wipe(Ether.guidData)
    wipe(dispelCache)
end

function Ether:TargetAuraFullUpdate()
    if UnitExists("target") then
        GetAuras("target")
    end
end

function Ether:EnableSoloAuras()
    if Ether.DB[4][1]==1 and not UpdateSolo then
        UpdateSolo=true
        if Ether.DB[6][1]==1 then
            Ether:SoloAuraSetup(soloButtons[Ether:UnitNumber("player")])
            auraTblRefresh(soloButtons[1],true)
            GetAuras("player")
        end
        if Ether.DB[6][2]==1 then
            Ether:SoloAuraSetup(soloButtons[Ether:UnitNumber("target")])
            auraTblRefresh(soloButtons[2],true)
            GetAuras("target")
        end
        if Ether.DB[6][4]==1 then
            Ether:SoloAuraSetup(soloButtons[Ether:UnitNumber("pet")])
            auraTblRefresh(soloButtons[4],true)
            GetAuras("pet")
        end
    end
end

function Ether:DisableSoloAuras()
    if UpdateSolo then
        UpdateSolo=false
        auraTblRefresh(soloButtons[1],false)
        auraTblRefresh(soloButtons[2],false)
        auraTblRefresh(soloButtons[4],false)
    end
end

function Ether:EnableSoloUnitAura(unit)
    Ether:SoloAuraSetup(soloButtons[Ether:UnitNumber(unit)])
    auraTblRefresh(soloButtons[Ether:UnitNumber(unit)],true)
    GetAuras(Ether:UnitNumber(unit))
end

function Ether:DisableSoloUnitAura(unit)
    auraTblRefresh(soloButtons[Ether:UnitNumber(unit)],false)
end

function Ether:AuraReset()
    Ether:AuraDisable()
    Ether:AuraEnable()
end
function Ether:SoloAuraReset()
    if UnitName("player")==Ether.metaData[2] then
        Ether:DisableSoloAuras()
        Ether:EnableSoloAuras()
    end
end
local cleanupTicker
cleanupTicker=nil
function Ether:ToggleHeaderAuras()
    if Ether.DB[6][10]==1 and not raidUpdate then
        raidUpdate=true
        C_Timer.After(1,function()
            for _,button in pairs(raidButtons) do
                if button and UnitExists(button.unit) then
                    Ether:RaidAurasFullUpdate(button,button.destGUID)
                end
            end
        end)
        if not cleanupTicker then
            cleanupTicker=NewTicker(20,function()
                Ether:CleanupCache()
            end)
        end
    else
        raidUpdate=false
        TexPool:ReleaseAll()
        Ether.StopAllBlinks()
        Ether:AuraWipe()
        if cleanupTicker then
            cleanupTicker:Cancel()
            if cleanupTicker:IsCancelled() then
                cleanupTicker=nil
            else
                Ether:EtherInfo("Aura Ticker is not cancelled. Reload UI")
                error("Aura Ticker is not cancelled. Reload UI")
            end
        end
    end
end

local update
if not update then
    update=CreateFrame("Frame")
    update:SetScript("OnEvent",function(_,event,arg1,...)
        if event~="UNIT_AURA" then return end
        if not arg1 or not UnitExists(arg1) then return end
        local updateInfo=...
        if raidButtons[arg1] then
            raidAuraUpdate(arg1,updateInfo)
        end
        if Ether:IsValidAura(arg1) then
            UnitAuraUpdate(arg1,updateInfo)
        end
    end)
end

function Ether:AuraEnable()
    if Ether.DB[1][7]~=1 then return end
    update:RegisterEvent("UNIT_AURA")
    C_Timer.After(1,function()
        Ether:EnableSoloAuras()
    end)
    Ether:ToggleHeaderAuras()
end

function Ether:AuraDisable()
    TexPool:ReleaseAll()
    Ether.StopAllBlinks()
    Ether:DisableSoloAuras()
    Ether:ToggleHeaderAuras()
    update:UnregisterAllEvents()
    Ether:AuraWipe()
end
