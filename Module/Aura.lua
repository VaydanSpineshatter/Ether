local _,Ether=...
local math_floor=math.floor
local math_ceil=math.ceil
local pairs,ipairs=pairs,ipairs
local GetBuffDataByIndex=C_UnitAuras.GetBuffDataByIndex
local GetDebuffDataByIndex=C_UnitAuras.GetDebuffDataByIndex
--local GetDataByIndex=C_UnitAuras.GetAuraDataByIndex
local UnitGUID=UnitGUID
local UnitExists=UnitExists
local GetAuraDataByAuraInstanceID=C_UnitAuras.GetAuraDataByAuraInstanceID
local unpack=unpack
local raidButtons=Ether.raidButtons
local soloButtons=Ether.soloButtons

local dispelClass={
    ["MAGE"]={Curse=true},
    ["PRIEST"]={Magic=true,Disease=true},
    ["PALADIN"]={Magic=true,Disease=true,Poison=true},
    ["DRUID"]={Curse=true,Poison=true},
    ["SHAMAN"]={Disease=true,Poison=true}
}

local dispelByPlayer={}
local _,classFilename=UnitClass("player")
dispelByPlayer=dispelClass[classFilename] or {}

local helpfulAuras={}
local harmfulAuras={}
local dataHelpful={}
local dataHarmful={}
local dataDispel={}
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
    if dataDispel[guid] then
        dataDispel[guid]=nil
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
    if not dataDispel[guid] then
        dataDispel[guid]={}
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
local function CheckDispelType(self,dispelName)
   local color = DebuffTypeColor[dispelName] or DebuffTypeColor["none"]
    if color then
        self.border:SetColorTexture(color.r,color.g,color.b)
        self.border:Show()
    else
        self.border:Hide()
    end
end
local TexPool=Ether:CreateObjPool(Ether.TextureMethod)
local DispelMethod=Ether:CreateObjPool(Ether.DispelMethod)
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
                if dataDispel[guid][aura.spellId] then
                    DispelMethod:Release(dataDispel[guid][aura.spellId])
                end
                local color = DebuffTypeColor[aura.dispelName] or DebuffTypeColor["none"]
                button.dispelIcon:SetTexture(aura.icon)
                button.dispelBorder:SetColorTexture(color.r,color.g,color.b)
                dataIcon[guid][aura.spellId]=button.dispelFrame
                Ether.StartBlink(dataIcon[guid][aura.spellId],aura.duration,0.3)
                if dispelByPlayer[aura.spellId] then
                    dataDispel[guid][aura.spellId]=DispelMethod:Acquire(button,aura.dispelName)
                end
            end
            harmfulAuras[aura.auraInstanceID]={
                spellId=aura.spellId,
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
    if not button then return end
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
                        if aura.dispelName then
                            if dataIcon[guid][aura.spellId] then
                                Ether.StopBlink(dataIcon[guid][aura.spellId])
                            end
                            if dataDispel[guid][aura.spellId] then
                                DispelMethod:Release(dataDispel[guid][aura.spellId])
                            end
                            local color = DebuffTypeColor[aura.dispelName] or DebuffTypeColor["none"]
                            button.dispelIcon:SetTexture(aura.icon)
                            button.dispelBorder:SetColorTexture(color.r,color.g,color.b)
                            dataIcon[guid][aura.spellId]=button.dispelFrame
                            Ether.StartBlink(dataIcon[guid][aura.spellId],aura.duration,0.3)
                            if dispelByPlayer[aura.spellId] then
                                dataDispel[guid][aura.spellId]=DispelMethod:Acquire(button,aura.dispelName)
                            end
                        end
                        harmfulAuras[aura.auraInstanceID]={
                            spellId=aura.spellId,
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
                    if dataHarmful[info.guid] and dataHarmful[info.guid][info.spellId] then
                        TexPool:Release(dataHarmful[info.guid][info.spellId])
                        dataHarmful[info.guid][info.spellId]=nil
                    end
                    if dataIcon[info.guid] and dataIcon[info.guid][info.spellId] then
                        Ether.StopBlink(dataIcon[info.guid][info.spellId])
                        dataIcon[info.guid][info.spellId]=nil
                    end
                    if dataDispel[info.guid] and dataDispel[info.guid][info.spellId] then
                        DispelMethod:Release(dataDispel[info.guid][info.spellId])
                        dataDispel[info.guid][info.spellId]=nil
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
    for i = 1, 15 do
        if not LastBuffs[i] then
            for j = i + 1, 16 do
                if LastBuffs[j] then
                    buffs[i].icon:SetTexture(buffs[j].icon:GetTexture())
                    buffs[i]:Show()
                    LastBuffs[i] = LastBuffs[j]
                    buffs[j]:Hide()
                    LastBuffs[j] = nil
                    local xOffset,yOffset = AuraPosition(i)
                    buffs[i]:ClearAllPoints()
                    buffs[i]:SetPoint("BOTTOMLEFT",button,"TOPLEFT",xOffset-1,yOffset+3)
                    break
                end
            end
        end
    end
end
local function SortDebuffs(button,debuffs,LastDebuffs,buffCount)
    for i = 1, 15 do
        if not LastDebuffs[i] then
            for j = i + 1, 16 do
                if LastDebuffs[j] then
                    debuffs[i].icon:SetTexture(debuffs[j].icon:GetTexture())
                    debuffs[i]:Show()
                    LastDebuffs[i] = LastDebuffs[j]
                    debuffs[j]:Hide()
                    LastDebuffs[j] = nil
                    local pos = i + buffCount
                    local xOffset,yOffset = AuraPosition(pos)
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
    local button=soloButtons[unit]
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
    local button=soloButtons[unit]
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

function Ether:SoloAuraFullInitial(unit)
    local button=soloButtons[unit]
    if not button then return end
    for i=1,16 do
        if button.Aura.Buffs and button.Aura.Buffs[i] then
            button.Aura.Buffs[i]:SetShown(true)
        end
        if button.Aura.Debuffs and button.Aura.Debuffs[i] then
            button.Aura.Debuffs[i]:SetShown(true)
        end
    end
    GetAuras(unit)
end

function Ether:TargetAuraFullUpdate()

    GetAuras("target")

end

local function auraTblReset(unit)
    local button=soloButtons[unit]
    if not button or not button.Aura then
        return
    end

    for i=1,16 do
        if button.Aura.Buffs and button.Aura.Buffs[i] then
            button.Aura.Buffs[i]:SetShown(false)
        end
        if button.Aura.Debuffs and button.Aura.Debuffs[i] then
            button.Aura.Debuffs[i]:SetShown(false)
        end
    end
    wipe(button.Aura.Buffs)
    wipe(button.Aura.Debuffs)
    wipe(button.Aura.LastBuffs)
    wipe(button.Aura.LastDebuffs)
end

local soloTbl={"player","target","pet"}
function Ether:EnableSoloAuras()
    for _,v in ipairs(soloTbl) do
        Ether:SoloAuraSetup(soloButtons[v])
        Ether:SoloAuraFullInitial(v)
    end
    UpdateSolo=true
end

function Ether:DisableSoloAuras()
    for _,unit in ipairs(soloTbl) do
        auraTblReset(unit)
    end
    UpdateSolo=false
end

function Ether:EnableSoloUnitAura(info)
    for index,unit in ipairs(soloTbl) do
        if index==info then
            Ether:SoloAuraFullInitial(unit)
            break
        end
    end
end

function Ether:DisableSoloUnitAura(info)
    for index,unit in ipairs(soloTbl) do
        if index==info then
            auraTblReset(unit)
            break
        end
    end
end

local function Aura(_,event,arg1,...)
    if event~="UNIT_AURA" then return end
    if not arg1 or not UnitExists(arg1) then return end
    local updateInfo=...
    if raidButtons[arg1] then
        raidAuraUpdate(arg1,updateInfo)
    end
    if Ether:IsValidAura(arg1) then
        UnitAuraUpdate(arg1,updateInfo)
    end
end

function Ether:ToggleHeaderAuras()
    if Ether.DB[6][3]==1 then
        raidUpdate=true
    else
        raidUpdate=false
        TexPool:ReleaseAll()
        DispelMethod:ReleaseAll()
        Ether.StopAllBlinks()
        Ether:AuraWipe()
    end
end

local update
if not update then
    update=CreateFrame("Frame")
end

function Ether:AuraEnable()
    if not update:GetScript("OnEvent") then
        update:RegisterEvent("UNIT_AURA")
        update:SetScript("OnEvent",Aura)
    end
    if Ether.DB[6][2]==1 then
        Ether:EnableSoloAuras()
    end
    Ether:ToggleHeaderAuras()
    C_Timer.After(1,function()
        for _,button in pairs(raidButtons) do
            if button and UnitExists(button.unit) then
                Ether:RaidAurasFullUpdate(button,button.destGUID)
            end
        end
    end)
end

function Ether:AuraWipe()
    wipe(helpfulAuras)
    wipe(harmfulAuras)
    wipe(dataHelpful)
    wipe(dataHarmful)
    wipe(dataDispel)
    wipe(dataIcon)
    wipe(Ether.guidData)
end
function Ether:AuraReleaseAll()
    TexPool:ReleaseAll()
    DispelMethod:ReleaseAll()
end
function Ether:AuraReset()
    Ether:AuraDisable()
    Ether:AuraEnable()
end
function Ether:AuraDisable()
    TexPool:ReleaseAll()
    DispelMethod:ReleaseAll()
    Ether.StopAllBlinks()
    Ether:DisableSoloAuras()
    update:UnregisterAllEvents()
    update:SetScript("OnEvent",nil)
    Ether:AuraWipe()
end
