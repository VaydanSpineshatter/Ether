local _,Ether=...
local math_floor=math.floor
local math_ceil=math.ceil
local pairs,ipairs=pairs,ipairs
local GetBuffDataByIndex=C_UnitAuras.GetBuffDataByIndex
local GetDebuffDataByIndex=C_UnitAuras.GetDebuffDataByIndex
local UnitGUID=UnitGUID
local UnitExists=UnitExists
local GetAuraDataByAuraInstanceID=C_UnitAuras.GetAuraDataByAuraInstanceID
local unpack=unpack
local raidButtons=Ether.raidButtons
local soloButtons=Ether.soloButtons
local dispelColors={
    ["Magic"]={0.2,0.6,1.0,1},
    ["Disease"]={0.6,0.4,0.0,1},
    ["Curse"]={0.6,0.2,1.0,1},
    ["Poison"]={0.2,1.0,0.2,1},
    [""]={0,0,0,0}
}

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
local dispelAuras={}
local iconAuras={}
local dataHelpful={}
local dataHarmful={}
local dataDispel={}
local dataIcon={}

local function CheckRaidButtons(unit)
    for _,button in pairs(raidButtons) do
        if button and button.unit==unit then
            return button
        end
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

function Ether:UpdateDispelFrame(button,color)
    if not button or type(color)~="table" then return end
    if button.dispelLeft then
        button.dispelLeft:SetColorTexture(unpack(color))
    end
    if button.dispelRight then
        button.dispelRight:SetColorTexture(unpack(color))
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
    if not dataIcon[guid] then
        dataIcon[guid]={}
    end
    if not dataDispel[guid] then
        dataDispel[guid]={}
    end
end

local guidData = Ether.guidData
Ether.CheckNewGUID = function(guid)
    if not guid then return end
    if not guidData[guid] then
        guidData[guid]=true
        Ether:EtherDebug("New GUID found: ",tostring(guid))
        AddGUID(guid)
        Ether:EtherDebug("GUID added: ",tostring(guid))
    end
end

Ether.CheckOldGUID = function(guid)
    if not guid then return end
    if guidData[guid] then
        guidData[guid]=nil
        Ether:EtherDebug("Old GUID found: ",tostring(guid))
        RemoveGUID(guid)
        Ether:EtherDebug("GUID cleared: ",tostring(guid))
    end
end
local TexPool=Ether:CreateObjPool(Ether.TextureMethod)
function Ether:RaidAurasFullUpdate(button, guid)
    if not button then return end
    Ether.CheckNewGUID(guid)
    if not guid or not guidData[guid] then return end
    local C=Ether.DB[1003]
    local index=1
    while true do
        local aura=GetBuffDataByIndex(button.unit,index)
        if not aura then break end
        if not C[aura.spellId] or not C[aura.spellId][9] then return end
        if guidData[guid] then
            if dataHelpful[guid][aura.spellId] then
                TexPool:Release(dataHelpful[guid][aura.spellId])
            end
            dataHelpful[guid][aura.spellId]=TexPool:Acquire(C[aura.spellId],button.unit)
            helpfulAuras[aura.auraInstanceID]={
                spellId=aura.spellId,
                guid=guid
            }
        end
        index=index+1
    end
    index=1
    while true do
        local aura=GetDebuffDataByIndex(button.unit,index)
        if not aura then break end
        if not C[aura.spellId] or not C[aura.spellId][9] then return end
        if guidData[guid] then
            if dataHarmful[guid][aura.spellId] then
                TexPool:Release(dataHarmful[guid][aura.spellId])
            end
            dataHarmful[guid][aura.spellId]=TexPool:Acquire(C[aura.spellId],button.unit)
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
    local isFullUpdate = not updateInfo or updateInfo.isFullUpdate
    local C=Ether.DB[1003]
    if isFullUpdate then
         Ether:RaidAurasFullUpdate(button, unit)
    else
        if updateInfo.addedAuras then
            for _,aura in ipairs(updateInfo.addedAuras) do
                if aura.isHarmful then
                    if aura.dispelName and dispelByPlayer[aura.dispelName] then
                        local color=dispelColors[aura.dispelName] or {0,0,0,0}
                        dataDispel[guid][aura.spellId]=button
                        Ether:UpdateDispelFrame(dataDispel[guid][aura.spellId],color)
                        dispelAuras[aura.auraInstanceID]={
                            spellId=aura.spellId,
                            guid=guid
                        }
                    end
                    if aura.dispelName then
                        local color=dispelColors[aura.dispelName] or {0,0,0,0}
                        button.dispelIcon:SetTexture(aura.icon)
                        button.dispelBorder:SetColorTexture(unpack(color))
                        dataIcon[guid][aura.spellId]=button.dispelFrame
                        Ether.StartBlink(dataIcon[guid][aura.spellId],aura.duration,0.3)
                        iconAuras[aura.auraInstanceID]={
                            spellId=aura.spellId,
                            guid=guid
                        }
                    end
                end
                if not C[aura.spellId] or not C[aura.spellId][9] then return end
                if aura.isHelpful then
                    if dataHelpful[guid][aura.spellId] then
                        TexPool:Release(dataHelpful[guid][aura.spellId])
                    end
                    dataHelpful[guid][aura.spellId]=TexPool:Acquire(C[aura.spellId],unit)
                    helpfulAuras[aura.auraInstanceID]={
                        spellId=aura.spellId,
                        guid=guid
                    }
                end
                if aura.isHarmful then
                    if dataHarmful[guid][aura.spellId] then
                        TexPool:Release(dataHarmful[guid][aura.spellId])
                    end
                    dataHarmful[guid][aura.spellId]=TexPool:Acquire(C[aura.spellId],unit)
                    harmfulAuras[aura.auraInstanceID]={
                        spellId=aura.spellId,
                        guid=guid
                    }
                end
            end
        end
        if updateInfo.removedAuraInstanceIDs then
            for _,auraInstanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
                if dispelAuras[auraInstanceID] then
                    local tracked=dispelAuras[auraInstanceID]
                    if tracked then
                        local spellId=tracked.spellId
                        local targetGuid=tracked.guid
                        if dataDispel[targetGuid] and dataDispel[targetGuid][spellId] then
                            Ether:UpdateDispelFrame(dataDispel[targetGuid][spellId],{0,0,0,0})
                        end
                    end
                    dispelAuras[auraInstanceID]=nil
                end
                if iconAuras[auraInstanceID] then
                    local tracked=iconAuras[auraInstanceID]
                    if tracked then
                        local spellId=tracked.spellId
                        local targetGuid=tracked.guid
                        if dataIcon[targetGuid] and dataIcon[targetGuid][spellId] then
                            Ether.StopBlink(dataIcon[guid][spellId])
                        end
                    end
                    iconAuras[auraInstanceID]=nil
                end
                if harmfulAuras[auraInstanceID] then
                    local tracked=harmfulAuras[auraInstanceID]
                    if tracked then
                        local spellId=tracked.spellId
                        local targetGuid=tracked.guid
                        if dataHarmful[targetGuid] and dataHarmful[targetGuid][spellId] then
                            TexPool:Release(dataHarmful[targetGuid][spellId])
                            dataHarmful[targetGuid][spellId]=nil
                        end
                        harmfulAuras[auraInstanceID]=nil
                    end
                end
                if helpfulAuras[auraInstanceID] then
                    local tracked=helpfulAuras[auraInstanceID]
                    if tracked then
                        local spellId=tracked.spellId
                        local targetGuid=tracked.guid
                        if dataHelpful[targetGuid] and dataHelpful[targetGuid][spellId] then
                            TexPool:Release(dataHelpful[targetGuid][spellId])
                            dataHelpful[targetGuid][spellId]=nil
                        end
                        helpfulAuras[auraInstanceID]=nil
                    end
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

local function AuraPosition(i)
    local row=math_floor((i-1)/8)
    local col=(i-1)%8
    local xOffset=col*(14+1)
    local yOffset=1+row*(14+1)
    return xOffset,yOffset
end

local function CheckDispelType(self,dispelName)
    local dispel=dispelColors[dispelName]
    if dispel then
        self:SetColorTexture(unpack(dispel))
        self:Show()
    else
        self:Hide()
    end
end

--local auraIndexBuff={}
--local auraIndexDebuff={}

local function GetAuras(unit)
    if not unit then return end
    local button=soloButtons[unit]
    if not button or not button.Aura then return end
    button.Aura.LastBuffs=button.Aura.LastBuffs or {}
    button.Aura.LastDebuffs=button.Aura.LastDebuffs or {}
    local visibleBuffCount=0
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
            if last.auraInstanceID~=aura.auraInstanceID or last.name~=aura.name or last.icon~=aura.icon then
                now.icon:SetTexture(aura.icon)
                now.icon:Show()
                last.auraInstanceID=aura.auraInstanceID
                last.name=aura.name
                last.icon=aura.icon
            end
            if aura.applications then
                CheckCount(now,aura.applications or 0)
            end
            if aura.duration then
                CheckDuration(now,aura.duration or 0,aura.expirationTime or 0)
            end
            local xOffset,yOffset=AuraPosition(index)
            now:ClearAllPoints()
            now:SetPoint("BOTTOMLEFT",button,"TOPLEFT",xOffset-1,yOffset+3)
            now:Show()
            visibleBuffCount=visibleBuffCount+1
        end
        index=index+1
    end

    local visibleDebuffCount=0
    index=1
    while true do
        local aura=GetDebuffDataByIndex(unit,index)
        if not aura then break end
        local buffRows=math_ceil(visibleBuffCount/8)
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
                now.icon:SetTexture(aura.icon)
                now.icon:Show()
                if CheckDispelType and now.border then
                    CheckDispelType(now.border,aura.dispelName)
                elseif now.border then
                    now.border:Show()
                end
                last.auraInstanceID=aura.auraInstanceID
                last.name=aura.name
                last.icon=aura.icon
                last.dispelName=aura.dispelName
            end
            if aura.applications then
                CheckCount(now,aura.applications or 0)
            end
            if aura.duration then
                CheckDuration(now,aura.duration or 0,aura.expirationTime or 0)
            end
            now:Show()
            visibleDebuffCount=visibleDebuffCount+1
        end
        index=index+1
    end
    for i=visibleBuffCount+1,16 do
        local now=button.Aura.Buffs[i]
        if now then now:Hide() end
        if button.Aura.LastBuffs[i] then
            button.Aura.LastBuffs[i].auraInstanceID=nil
        end
    end
    for i=visibleDebuffCount+1,16 do
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
                            now.icon:SetTexture(aura.icon)
                            now.icon:Show()
                            last.auraInstanceID=aura.auraInstanceID
                            last.name=aura.name
                            last.icon=aura.icon
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
                            now.icon:SetTexture(aura.icon)
                            now.icon:Show()
                            last.auraInstanceID=aura.auraInstanceID
                            last.name=aura.name
                            last.icon=aura.icon
                            last.dispelName=aura.dispelName
                            LastDebuffs[index]=last
                            if aura.dispelName then
                                CheckDispelType(now.border,aura.dispelName)
                                if now.border then
                                    now.border:Show()
                                end
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
            for _,instanceID in ipairs(updateInfo.updatedAuraInstanceIDs) do
                local aura=GetAuraDataByAuraInstanceID(unit,instanceID)
                if not aura then return end
                    if aura.isHelpful then
                    for i=1,16 do
                        local last=LastBuffs[i]
                        if last and last.auraInstanceID==instanceID then
                            local now=buffs[i]
                            if aura.applications then
                                 now.count:SetText(aura.applications)
                            end
                            if aura.duration and aura.duration ~= aura.expirationTime then
                                local startTime=aura.expirationTime-aura.duration
                                now.timer:SetCooldown(startTime,aura.duration)
                            end
                        end
                        break
                    end
                    if aura.isHarmful then
                    for i=1,16 do
                        local last=button.Aura.LastDebuffs[i]
                        if last and last.auraInstanceID==instanceID then
                            local now=debuffs[i]
                            if aura.applications then
                                 now.count:SetText(aura.applications)
                            end
                            if aura.duration and aura.duration ~= aura.expirationTime then
                                local startTime=aura.expirationTime-aura.duration
                                now.timer:SetCooldown(startTime,aura.duration)
                            end
                        end
                        break
                        end
                    end
                end
            end
        end
        if updateInfo.removedAuraInstanceIDs then
            for _,instanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
                for i=1,16 do
                    local last=LastBuffs[i]
                    if last and last.auraInstanceID==instanceID then
                        if buffs[i] then buffs[i]:Hide() end
                        LastBuffs[i]=nil
                        break
                    end
                end
                for i=1,16 do
                    local last=LastDebuffs[i]
                    if last and last.auraInstanceID==instanceID then
                        if debuffs[i] then debuffs[i]:Hide() end
                        LastDebuffs[i]=nil
                        break
                    end
                end
            end
        end
    end
end

function Ether:SoloAuraFullInitial(unit)
    local button=soloButtons[unit]
    Ether:SoloAuraSetup(Ether.soloButtons[unit])
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

function Ether:TargetAuraFullUpdate(unit)
    if UnitExists("target") then
        GetAuras(unit)
    end
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
    for _,unit in ipairs(soloTbl) do
        Ether:SoloAuraFullInitial(unit)
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

function Ether:FullAuraReset()
    Ether.StopAllBlinks()
    TexPool:ReleaseAll()
    Ether:CleanupGUID()
    Ether:DisableSoloAuras()
    Ether:EnableSoloAuras()
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
        Ether.StopAllBlinks()
        Ether:CleanupGUID()
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
end

function Ether:AuraWipe()
    wipe(helpfulAuras)
    wipe(harmfulAuras)
    wipe(dispelAuras)
    wipe(iconAuras)
    wipe(dataHelpful)
    wipe(dataHarmful)
    wipe(dataIcon)
    wipe(dataDispel)
    wipe(Ether.guidData)
end

function Ether:AuraDisable()
    TexPool:ReleaseAll()
    Ether.StopAllBlinks()
    Ether:DisableSoloAuras()
    update:UnregisterAllEvents()
    update:SetScript("OnEvent",nil)
    Ether:AuraWipe()
end
