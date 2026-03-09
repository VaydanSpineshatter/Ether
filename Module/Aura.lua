local _,Ether=...
local math_floor=math.floor
local math_ceil=math.ceil
local pairs,ipairs=pairs,ipairs
local GetBuffDataByIndex=C_UnitAuras.GetBuffDataByIndex
local GetDebuffDataByIndex=C_UnitAuras.GetDebuffDataByIndex
local GetUnitAuras=C_UnitAuras.GetUnitAuras
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
local dispelCache={}

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

local function CreateAuraTexture(button,tbl,spellId,guid)
    if true then return end
    if not tbl[guid] then
        tbl[guid]={}
    end
    local C=Ether.DB[1003][spellId]
    if not tbl[guid][spellId] then
        tbl[guid][spellId]=button.healthBar:CreateTexture(nil,"OVERLAY")
        tbl[guid][spellId]:SetColorTexture(unpack(C[2]))
        tbl[guid][spellId]:SetSize(C[3],C[3])
        tbl[guid][spellId]:SetPoint(C[4],C[5],C[6])
        tbl[guid][spellId]:Show()
    end
end

function Ether:UpdateRaidIsHelpful(button,guid)
    if not button then return end
    local unit=button.unit
    local C=Ether.DB[1003]
    local index=1
    while true do
        local aura=GetBuffDataByIndex(unit,index)
        if not aura then break end
        if not C[aura.spellId] or not C[aura.spellId][9] then return end
        CreateAuraTexture(button,dataHelpful,aura.spellId,guid)
        helpfulAuras[aura.auraInstanceID]=aura
        index=index+1
    end
end

function Ether:UpdateRaidIsHarmful(button,guid)
    if not button then return end
    local unit=button.unit
    local C=Ether.DB[1003]
    local index=1
    while true do
        local aura=GetDebuffDataByIndex(unit,index)
        if not aura then break end
        if not C[aura.spellId] or not C[aura.spellId][9] then return end
        CreateAuraTexture(button,dataHarmful,aura.spellId,guid)
        harmfulAuras[aura.auraInstanceID]=aura
        index=index+1
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

local function CheckGUID(guid)
    if dataHelpful[guid] then
        dataHelpful[guid]=nil
        Ether:EtherDebug("GUID cleared: ",tostring(guid))
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

function Ether:CleanupGUID()
    for guid in pairs(dataHelpful) do
        CheckGUID(guid)
    end
    for guid in pairs(dataHarmful) do
        CheckGUID(guid)
    end
    for guid in pairs(dataDispel) do
        CheckGUID(guid)
    end
    for guid in pairs(dataIcon) do
        CheckGUID(guid)
    end
end

function Ether:GuidStatus(guid)
    local found=false
    if guid and type(guid)~="nil" then
        if Ether.guidData[guid] then
            found=true
        end
    end
    if found then
        Ether:EtherDebug("GUID found: ",tostring(guid))
        CheckGUID(guid)
        Ether.guidData[guid]=nil
    end
end

local TexPool=Ether:CreateObjPool(Ether.TextureMethod)
local function raidAuraUpdate(unit,updateInfo)
    local button=CheckRaidButtons(unit)
    if not button then return end
    local guid=UnitGUID(unit)
    if not guid then return end
    if not Ether.guidData[guid] then
        Ether.guidData[guid]=true
    end
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
    local C=Ether.DB[1003]
    if updateInfo.isFullUpdate then
        --Ether:UpdateRaidIsHarmful(button)
        --Ether:UpdateRaidIsHelpful(button)
    end
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
            if aura.isHelpful then
                if not C[aura.spellId] or not C[aura.spellId][9] then return end
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
                if not C[aura.spellId] or not C[aura.spellId][9] then return end
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
                        if not next(dataHarmful[targetGuid]) then
                            dataHarmful[targetGuid]=nil
                        end
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
                        if not next(dataHelpful[targetGuid]) then
                            dataHelpful[targetGuid]=nil
                        end
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
local function SoloAuraIsHelpful(unit)
    local button=soloButtons[unit]
    if not button or not button.Aura then
        return
    end
    local visibleBuffCount=0
    local allAuras=GetUnitAuras(unit,"HELPFUL")
    if not allAuras then
        return
    end
    for index,auraData in ipairs(allAuras) do
        if index>16 then
            break
        end
        local now=button.Aura.Buffs[index]
        if now then
            local last=button.Aura.LastBuffs[index] or {}
            if last.auraInstanceID~=auraData.auraInstanceID or last.name~=auraData.name or last.icon~=auraData.icon then
                now.icon:SetTexture(auraData.icon)
                now.icon:Show()
                last.auraInstanceID=auraData.auraInstanceID
                last.name=auraData.name
                last.icon=auraData.icon
                button.Aura.LastBuffs[index]=last
            end
            if CheckCount then
                CheckCount(now,auraData.applications or 0)
            end
            if CheckDuration then
                CheckDuration(now,auraData.duration or 0,auraData.expirationTime or 0)
            end
            local xOffset,yOffset=AuraPosition(index)
            now:ClearAllPoints()
            now:SetPoint("BOTTOMLEFT",button,"TOPLEFT",xOffset-1,yOffset+3)
            now:Show()
            visibleBuffCount=visibleBuffCount+1
        end
    end
    for i=visibleBuffCount+1,16 do
        local now=button.Aura.Buffs[i]
        if now then
            now:Hide()
        end
        button.Aura.LastBuffs[i]=nil
    end
    button.Aura.visibleBuffCount=visibleBuffCount
end

local function SoloAuraIsHarmful(unit)
    local button=soloButtons[unit]
    if not button or not button.Aura then
        return
    end
    local visibleBuffCount=button.Aura.visibleBuffCount or 0
    local visibleDebuffCount=0
    local buffRows=math_ceil(visibleBuffCount/8)
    local startY=buffRows*(14+1)+2
    local allAuras=GetUnitAuras(unit,"HARMFUL")
    if not allAuras then
        return
    end
    for index,auraData in ipairs(allAuras) do
        if index>16 then
            break
        end
        local now=button.Aura.Debuffs[index]
        if now then
            local row=math_floor((index-1)/8)
            local col=(index-1)%8
            local yOffset=startY+row*(14+1)

            now:ClearAllPoints()
            now:SetPoint("BOTTOMLEFT",button,"TOPLEFT",col*(14+1)-1,yOffset+2)

            local last=button.Aura.LastDebuffs[index] or {}

            if last.auraInstanceID~=auraData.auraInstanceID then
                now.icon:SetTexture(auraData.icon)
                now.icon:Show()
                if CheckDispelType and now.border then
                    CheckDispelType(now.border,auraData.dispelName)
                elseif now.border then
                    now.border:Show()
                end

                last.auraInstanceID=auraData.auraInstanceID
                last.name=auraData.name
                last.icon=auraData.icon
                last.dispelName=auraData.dispelName
                button.Aura.LastDebuffs[index]=last
            end

            if CheckCount then
                CheckCount(now,auraData.applications or 0)
            end
            if CheckDuration then
                CheckDuration(now,auraData.duration or 0,auraData.expirationTime or 0)
            end

            now:Show()
            visibleDebuffCount=visibleDebuffCount+1
        end
    end
    for i=visibleDebuffCount+1,16 do
        local now=button.Aura.Debuffs[i]
        if now then
            now:Hide()
        end
        button.Aura.LastDebuffs[i]=nil
    end
end

local function CheckDispel(icon,dispelName)
    if icon.currentDispel==dispelName then return end
    local color=dispelColors[dispelName or ""]
    if color then
        icon.border:SetColorTexture(unpack(color))
        icon.border:Show()
    else
        icon.border:Hide()
    end
    icon.currentDispel=dispelName
end

local function CheckSoloButtons(unit)
    local button=soloButtons[unit]
    if button and UnitExists(unit) then
        return button
    end
    return nil
end

local helpfulSolo={}
local harmfulSolo={}
local function UpdateInstanceId(auraInstance,unit)
    local button=CheckSoloButtons(unit)
    for _,aura in ipairs(auraInstance) do
        if aura.isHelpful then
            local icon=button.Aura.Buffs
            if aura and aura.applications then
                print(aura.applications..unit)
                CheckCount(button,aura.applications or 0)
            end
            if aura and aura.duration then
                if aura and aura.duration then
                    print(aura.duration..unit)
                    CheckDuration(icon,aura.duration,aura.expirationTime)
                end
            end
        end
        if aura.isHarmful then
            local icon=button.Aura.Debuffs
            if aura and aura.applications then
                print(aura.applications.." "..unit)
                CheckCount(button,aura.applications or 0)
            end
            if aura and aura.duration then
                print(aura.duration.." "..unit)
                CheckDuration(button,aura.duration or 0,aura.expirationTime or 0)
            end
        end
    end
end

local auraInstance={}
--[[
local function soloAuraUpdate(unit,updateInfo)
    if not UnitExists(unit) then return end
    local button=soloButtons[unit]
    local visibleBuffCount=0
    if updateInfo.isFullUpdate then
        print("Full Update "..unit)
        SoloAuraIsHelpful(unit)
        SoloAuraIsHarmful(unit)
    else
        if updateInfo.addedAuras then
            for index,aura in ipairs(updateInfo.addedAuras) do
                if aura.isHelpful then
                    if index>16 then
                        break
                    end
                    SortAuraIcons(button,true)
                    local now=button.Aura.Buffs[index]
                    if now then
                        local last=button.Aura.LastBuffs[index] or {}
                        if last.auraInstanceID~=aura.auraInstanceID or last.name~=aura.name or last.icon~=aura.icon then
                            now.icon:SetTexture(aura.icon)
                            now.icon:Show()
                            last.auraInstanceID=aura.auraInstanceID
                            last.name=aura.name
                            last.icon=aura.icon
                            button.Aura.LastBuffs[index]=last
                        end
                        local xOffset,yOffset=AuraPosition(index)
                        now:ClearAllPoints()
                        now:SetPoint("BOTTOMLEFT",button,"TOPLEFT",xOffset-1,yOffset+3)
                        now:Show()
                        visibleBuffCount=visibleBuffCount+1
                    end
                end
                if aura.isHarmful then
                    if index>16 then
                        break
                    end
                    local now=button.Aura.Debuffs[index]
                    if now then
                        local visibleDebuffCount=0
                        local buffRows=math_ceil(visibleBuffCount/8)
                        local startY=buffRows*(14+1)+2
                        local row=math_floor((index-1)/8)
                        local col=(index-1)%8
                        local yOffset=startY+row*(14+1)
                        now:ClearAllPoints()
                        now:SetPoint("BOTTOMLEFT",button,"TOPLEFT",col*(14+1)-1,yOffset+2)
                        local last=button.Aura.LastDebuffs[index] or {}
                        if last.auraInstanceID~=aura.auraInstanceID then
                            now.icon:SetTexture(aura.icon)
                            now.icon:Show()
                            if aura.dispelName and now.border then
                                CheckDispelType(now.border,aura.dispelName)
                            elseif now.border then
                                now.border:Show()
                            end
                            last.auraInstanceID=aura.auraInstanceID
                            last.name=aura.name
                            last.icon=aura.icon
                            last.dispelName=aura.dispelName
                            button.Aura.LastDebuffs[index]=last
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
                end
            end
        end

        -- Warning:	GetAuraDataByAuraInstanceID will not work on removed aura InstanceIDs, so it might be a good idea to cache the information.

        if updateInfo.updatedAuraInstanceIDs then
            wipe(auraInstance)
            for _,instanceID in ipairs(updateInfo.updatedAuraInstanceIDs) do
                local data=GetAuraDataByAuraInstanceID(unit,instanceID)
                table.insert(auraInstance,data)
                UpdateInstanceId(auraInstance,unit)
            end
        end
        if updateInfo.removedAuraInstanceIDs then
            for _,instanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
                for i=1,16 do
                    local aura=button.Aura.Buffs[i]
                    aura:Hide()
                    aura.auraInstanceID=nil
                end
                for i=1,16 do
                    local aura=button.Aura.Debuffs[i]
                    if aura.auraInstanceID==instanceID then
                        aura:Hide()
                        aura.auraInstanceID=nil
                        break

                    end

                end

            end
        end
    end
end

]]
local function SortAuraIcons(button,isBuffs)
    local targetTable=isBuffs and button.Aura.Buffs or button.Aura.Debuffs
    local activeCount=0
    for i=1,16 do
        local icon=targetTable[i]
        if icon.auraInstanceID then
            activeCount=activeCount+1
            local x,y=AuraPosition(activeCount)
            icon:ClearAllPoints()
            icon:SetPoint("BOTTOMLEFT",button,"TOPLEFT",x-1,y+3)
            icon:Show()
        else
            icon:Hide()
        end
    end
end

local function UpdateSingleIcon(icon,data)
    if not icon or not data then return end
    icon.icon:SetTexture(data.icon)
    CheckCount(icon,data.applications or 0)
    CheckDuration(icon,data.duration or 0,data.expirationTime or 0)
    if icon.border and data.dispelName then
        CheckDispelType(icon.border,data.dispelName)
    end
    icon:Show()
end

local function soloAuraUpdate(unit,updateInfo)
    local button=soloButtons[unit]
    if not button or not button.Aura then return end
    if updateInfo.isFullUpdate then
        print("Full Update "..unit)
        SoloAuraIsHelpful(unit)
        SoloAuraIsHarmful(unit)
    else
        if updateInfo.addedAuras then
            for _,aura in ipairs(updateInfo.addedAuras) do
                if aura.isHelpful then
                    local data=button.Aura.Buffs
                    for i=1,16 do
                        local icon=data[i]
                        if not icon:IsShown() or icon.auraInstanceID==aura.auraInstanceID then
                            icon.auraInstanceID=aura.auraInstanceID
                            UpdateSingleIcon(icon,aura)
                            break
                        end
                    end
                end
                if aura.isHarmful then
                    local data=button.Aura.Debuffs
                    for i=1,16 do
                        local icon=data[i]
                        if not icon:IsShown() or icon.auraInstanceID==aura.auraInstanceID then
                            icon.auraInstanceID=aura.auraInstanceID
                            UpdateSingleIcon(icon,aura)
                            break
                        end
                    end
                end
            end
        end
        if updateInfo.updatedAuraInstanceIDs then
            for _,instanceID in ipairs(updateInfo.updatedAuraInstanceIDs) do
                for i=1,16 do
                    local icon=button.Aura.Buffs[i]
                    if icon.auraInstanceID==instanceID then
                        local data=C_UnitAuras.GetAuraDataByAuraInstanceID(unit,instanceID)
                        UpdateSingleIcon(icon,data)
                        break
                    end

                end
            end
        end
        if updateInfo.removedAuraInstanceIDs then
            for _,instanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
                for i=1,16 do
                    local icon=button.Aura.Buffs[i]
                    if icon.auraInstanceID==instanceID then
                        icon:Hide()
                        icon.auraInstanceID=nil
                        break
                    end
                    local data=button.Aura.Buffs[i]
                    if data.auraInstanceID==instanceID then
                        data:Hide()
                        data.auraInstanceID=nil
                        break
                    end
                end
            end
            SortAuraIcons(button,true)
            SortAuraIcons(button,false)
        end
    end
end

function Ether:SoloAuraFullInitial(unit)
    local button=soloButtons[unit]
    if not button then return end
    Ether:SoloAuraSetup(button)
    for i=1,16 do
        if button.Aura.Buffs and button.Aura.Buffs[i] then
            button.Aura.Buffs[i]:SetShown(true)
        end
        if button.Aura.Debuffs and button.Aura.Debuffs[i] then
            button.Aura.Debuffs[i]:SetShown(true)
        end
    end
    SoloAuraIsHelpful(button.unit)
    SoloAuraIsHarmful(button.unit)
end

function Ether:TargetAuraFullUpdate()
    local button=soloButtons["target"]
    if button then
        SoloAuraIsHelpful("target")
        SoloAuraIsHarmful("target")
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
end

function Ether:DisableSoloAuras()
    for _,unit in ipairs(soloTbl) do
        auraTblReset(unit)
    end
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

function Ether:DisableHeaderAuras()
    Ether:CleanupRaidIcons()
    Ether:AuraWipe()
end

function Ether:EnableHeaderAuras()
    if true then return end
    for unit,button in pairs(raidButtons) do
        if button and UnitExists(unit) then
            local guid=UnitGUID(unit)
            if guid then
                Ether:UpdateRaidIsHelpful(button,guid)
                Ether:UpdateRaidIsHarmful(button,guid)
            end
        end
    end
end

function Ether:FullAuraReset()
    Ether.StopAllBlinks()
    TexPool:ReleaseAll()
    Ether:CleanupGUID()
    Ether:DisableHeaderAuras()
    Ether:DisableSoloAuras()
    Ether:EnableHeaderAuras()
    Ether:EnableSoloAuras()
end

local function Aura(_,event,arg1,...)
    if event~="UNIT_AURA" then return end
    if not arg1 then return end
    local updateInfo=...
    if updateInfo then
        if raidButtons[arg1] then
            raidAuraUpdate(arg1,updateInfo)
        end
        if Ether:IsValidAura(arg1) then
            soloAuraUpdate(arg1,updateInfo)
        end
    end
end

--Ether.DB[1001][2]==1
--Ether.DB[1001][3]==1
local update
if not update then
    update=CreateFrame("Frame")
end

function Ether:AuraEnable()
    if not update:GetScript("OnEvent") then
        update:RegisterEvent("UNIT_AURA")
        update:SetScript("OnEvent",Aura)
    end
    if Ether.DB[6][3]==1 then
        C_Timer.After(1,function()
            Ether:EnableHeaderAuras()
        end)
    end
    if Ether.DB[6][2]==1 then
        Ether:EnableSoloAuras()
    end

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
    wipe(dispelCache)
end

function Ether:AuraDisable()
    TexPool:ReleaseAll()
    Ether.StopAllBlinks()
    Ether:CleanupGUID()
    Ether:DisableSoloAuras()
    update:UnregisterAllEvents()
    update:SetScript("OnEvent",nil)
    Ether:AuraWipe()
end
