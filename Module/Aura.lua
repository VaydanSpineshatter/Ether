local _,Ether=...
local math_floor=math.floor
local math_ceil=math.ceil
local pairs,ipairs=pairs,ipairs
local GetBuffDataByIndex=C_UnitAuras.GetBuffDataByIndex
local GetDebuffDataByIndex=C_UnitAuras.GetDebuffDataByIndex
local GetUnitAuras=C_UnitAuras.GetUnitAuras
local UnitGUID=UnitGUID
local UnitExists=UnitExists
local GetTime=GetTime
local unpack=unpack
local GetUnitAuraBySpellID=C_UnitAuras.GetUnitAuraBySpellID
local tinsert=table.insert
local colors={
    ["Magic"]={0.2,0.6,1.0,1},
    ["Disease"]={0.6,0.4,0.0,1},
    ["Curse"]={0.6,0.2,1.0,1},
    ["Poison"]={0.2,1.0,0.2,1},
    [""]={0,0,0,0}
}

local dispelClass={
    MAGE={["Curse"]=true},
    PRIEST={["Magic"]=true,["Disease"]=true},
    PALADIN={["Magic"]=true,["Disease"]=true,["Poison"]=true},
    DRUID={["Curse"]=true,["Poison"]=true},
    SHAMAN={["Disease"]=true,["Poison"]=true},
    WARRIOR=true,
    ROGUE=true,
    HUNTER=true,
    WARLOCK=true
}
local dispelPriority={
    Magic=4,
    Disease=3,
    Curse=2,
    Poison=1
}

local _,classFilename=UnitClass("player")
local dispelByPlayer={}
dispelByPlayer=dispelClass[classFilename]

local helpfulAuras={}
local dataHelpful={}
local raidAuraHarmful={}
local raidAuraDispel={}
local raidAuraIcons={}
local raidDebuffData={}
local raidDispelData={}
local raidIconData={}
local getUnitBuffs={}
local getUnitDebuffs={}
local dispelCache={}

function Ether:CleanupTimerCache()
    local currentTime=GetTime()
    for guid,data in pairs(dispelCache) do
        if (currentTime-data.timestamp)>5 then
            dispelCache[guid]=nil
        end
    end
end

local function updateAuraPos(tbl,spell,c)
    for guid in pairs(tbl) do
        if tbl[guid] and tbl[guid][spell] then
            tbl[guid][spell].IsActive=tbl[guid][spell]:IsShown()
            tbl[guid][spell]:Hide()
            tbl[guid][spell]:ClearAllPoints()
            tbl[guid][spell]:SetColorTexture(unpack(c.color))
            tbl[guid][spell]:SetSize(c.size,c.size)
            tbl[guid][spell]:SetPoint(c.position,c.offsetX,c.offsetY)
            if tbl and tbl[guid] and tbl[guid][spell] and tbl[guid][spell].IsActive then
                tbl[guid][spell]:Show()
                tbl[guid][spell].IsActive=nil
            end
        end
    end
end

function Ether:SaveAuraPosition(spellId)
    if not spellId or type(spellId)~="number" then
        return
    end
    local c=Ether.DB[1003][spellId]
    local debuff=c.isDebuff
    if debuff then
        updateAuraPos(raidDebuffData,spellId,c)
    else
        updateAuraPos(dataHelpful,spellId,c)
    end
end

local function ScanUnitAuras(unit)
    if not UnitExists(unit) then
        return nil,{}
    end
    local dispel=nil
    local priority=0
    local index=1
    while true do
        local auraData=GetDebuffDataByIndex(unit,index)
        if not auraData then
            break
        end
        if auraData.dispelName and dispelByPlayer[auraData.dispelName] then
            local order=dispelPriority[auraData.dispelName] or 0
            if order>priority then
                priority=order
                dispel={
                    name=auraData.name,
                    dispelName=auraData.dispelName,
                    spellId=auraData.spellId,
                    index=index
                }
            end
        end
        index=index+1
    end
    return dispel
end

local function GetCachedDispel(unit)
    local guid=UnitGUID(unit)
    if not guid then
        return nil
    end

    local cached=dispelCache[guid]
    if cached and (GetTime()-cached.timestamp)<2 then
        return cached.dispel
    end
    local dispel=ScanUnitAuras(unit)
    dispelCache[guid]={
        dispel=dispel,
        timestamp=GetTime()
    }
    return dispel
end

local function CreateAuraTexture(button,tbl,guid,spellId)
    if not tbl[guid] then
        tbl[guid]={}
    end
    local sc=Ether.DB[1003][spellId]
    if not tbl[guid][spellId] then
        tbl[guid][spellId]=button.healthBar:CreateTexture(nil,"OVERLAY")
        tbl[guid][spellId]:SetColorTexture(unpack(sc.color))
        tbl[guid][spellId]:SetSize(sc.size,sc.size)
        tbl[guid][spellId]:SetPoint(sc.position,sc.offsetX,sc.offsetY)
        tbl[guid][spellId]:Hide()
    end
end

function Ether:UpdateRaidIsHelpful(button,guid)
    if not button or not guid then
        return
    end
    local c=Ether.DB[1003]
    local index=1
    while true do
        local aura=GetBuffDataByIndex(button.unit,index)
        if not aura then
            break
        end
        if c[aura.spellId] and not c[aura.spellId].isDebuff and c[aura.spellId].isActive then
            CreateAuraTexture(button,dataHelpful,guid,aura.spellId)
            dataHelpful[guid][aura.spellId]:Show()
            dataHelpful[aura.auraInstanceID]={
                spellId=aura.spellId,
                guid=guid
            }
            helpfulAuras[aura.auraInstanceID]=aura
        end
        index=index+1
    end
end

local function UpdateNotActive(button,guid,spellId,auraConfig)
    if auraConfig.isDebuff then
        return
    end
    local aura=GetUnitAuraBySpellID(button.unit,spellId,"HELPFUL")
    CreateAuraTexture(button,dataHelpful,guid,spellId)
    if not aura and not auraConfig.isActive then
        dataHelpful[guid][spellId]:Show()
    elseif not aura and auraConfig.isActive then
        dataHelpful[guid][spellId]:Hide()
    end
end

local function UpdateAuraActive(button,guid)
    if not button or not guid then
        return
    end
    local config=Ether.DB[1003]
    if not next(config) then
        return
    end
    for spellId,auraConfig in pairs(config) do
        if auraConfig.enabled then
            UpdateNotActive(button,guid,spellId,auraConfig)
        end
    end
end
function Ether:UpdateNotActive(button,guid)
    if not button or not guid then
        return
    end
    local config=Ether.DB[1003]
    for spellId,auraConfig in pairs(config) do
        if auraConfig.enabled then
            UpdateNotActive(button,guid,spellId,auraConfig)
        end
    end
end
function Ether:UpdateRaidIsHarmful(button,guid)
    if not button or not guid then
        return
    end
    local c=Ether.DB[1003]
    local index=1
    while true do
        local aura=GetDebuffDataByIndex(button.unit,index)
        if not aura then
            break
        end
        if c[aura.spellId] and c[aura.spellId].enabled and c[aura.spellId].isDebuff and c[aura.spellId].isActive then
            CreateAuraTexture(button,raidDebuffData,guid,aura.spellId)
            raidDebuffData[guid][aura.spellId]:Show()
            raidDebuffData[aura.auraInstanceID]={
                spellId=aura.spellId,
                guid=guid
            }
            raidAuraHarmful[aura.auraInstanceID]=aura
        end
        index=index+1
    end
end

function Ether:UpdateDispelBorder(button,color)
    if not button.top then
        return
    end
    local c=unpack(color)
    --  button.top:SetColorTexture(c)
    --  button.bottom:SetColorTexture(c)
    -- button.left:SetColorTexture(c)
    -- button.right:SetColorTexture(c)
end

function Ether:UpdatePrediction(button)
    if not button.myPrediction or not button.otherPrediction then
        return
    end
    button.myPrediction:Hide()
    button.otherPrediction:Hide()
end

function Ether:CleanupAuras(guid)
    if dataHelpful[guid] then
        for _,texture in pairs(dataHelpful[guid]) do
            if type(texture)~="table" then
                return
            end
            texture:Hide()
            texture:ClearAllPoints()
            texture:SetParent(nil)
        end
        dataHelpful[guid]=nil
    end
    if raidIconData[guid] then
        for _,icon in pairs(raidIconData[guid]) do
            Ether.StopBlink(icon)
        end
        raidIconData[guid]=nil
    end
    if raidDebuffData[guid] then
        for _,texture in pairs(raidDebuffData[guid]) do
            if type(texture)~="table" then
                return
            end
            texture:Hide()
            texture:ClearAllPoints()
            texture:SetParent(nil)
        end
        raidDebuffData[guid]=nil
    end
end

function Ether:CleanupRaidIcons()
    for guid,_ in pairs(dataHelpful) do
        Ether:CleanupAuras(guid)
    end
    for guid,_ in pairs(raidDebuffData) do
        Ether:CleanupAuras(guid)
    end
    Ether:CleanupTimerCache()
end

function Ether:UpdateBlink(unit,guid,spellId)
    local aura=GetUnitAuraBySpellID(unit,spellId,"HELPFUL")
    if not aura then
        return
    end
    local button=Ether.unitButtons.raid[unit]
    if not button then
        return
    end
    if not raidIconData[guid] then
        raidIconData[guid]={}
    end
    if not raidIconData[guid][aura.spellId] then
        local color=colors[aura.dispelName] or {0,0,0,1}
        button.dispelIcon:SetTexture(aura.icon)
        button.dispelBorder:SetColorTexture(unpack(color))
        raidIconData[guid][aura.spellId]=button.iconFrame
    end
    Ether.StartBlink(raidIconData[guid][aura.spellId],aura.duration,0.3)
end

function Ether:UpdateDispel(unit,guid,spellId)
    local aura=GetUnitAuraBySpellID(unit,spellId,"HELPFUL")
    if not aura then
        return
    end
    local button=Ether.unitButtons.raid[unit]
    if not button then
        return
    end
    local dispel=nil
    local priority=0
    if not raidDispelData[guid] then
        raidDispelData[guid]={}
    end
    if not raidDispelData[guid][spellId] then
        local order=dispelPriority[aura.dispelName] or 0
        if order>priority then
            priority=order
            dispel=aura.dispelName
            local color=colors[dispel] or {0,0,0,0}
            raidDispelData[guid][spellId]=button
            Ether:updateDispelBorder(raidDispelData[guid][spellId],color)
        end
    else
        raidDispelData[guid][spellId]:Show()
    end
end

local function raidAuraUpdate(unit,updateInfo)
    if not UnitExists(unit) then
        return
    end
    local button=Ether.unitButtons.raid[unit]
    if not button then
        return
    end
    local guid=UnitGUID(unit)
    if not guid then
        return
    end
    local c=Ether.DB[1003]
    if updateInfo.isFullUpdate then
        Ether:UpdateRaidIsHarmful(button,guid)
        Ether:UpdateRaidIsHelpful(button,guid)
    end
    if updateInfo.addedAuras then
        for _,aura in ipairs(updateInfo.addedAuras) do
            if aura.isHelpful and c[aura.spellId] and not c[aura.spellId].isDebuff then
                CreateAuraTexture(button,dataHelpful,guid,aura.spellId)
                if c[aura.spellId].isActive then
                    dataHelpful[guid][aura.spellId]:Show()
                else
                    dataHelpful[guid][aura.spellId]:Hide()
                end
                dataHelpful[aura.auraInstanceID]={
                    spellId=aura.spellId,
                    guid=guid
                }
                helpfulAuras[aura.auraInstanceID]=aura
            end

            if aura.isHarmful and dispelByPlayer[aura.dispelName] then
                raidDispelData[guid]=raidDispelData[guid] or {}
                raidIconData[guid]=raidIconData[guid] or {}
                raidDispelData[aura.auraInstanceID]={
                    spellId=aura.spellId,
                    guid=guid
                }
                raidIconData[aura.auraInstanceID]={
                    spellId=aura.spellId,
                    guid=guid
                }
                local color=colors[aura.dispelName] or {0,0,0,0}
                raidDispelData[guid][aura.spellId]=button
                Ether:UpdateDispelBorder(raidDispelData[guid][aura.spellId],color)
                button.dispelIcon:SetTexture(aura.icon)
                button.dispelBorder:SetColorTexture(unpack(color))
                raidIconData[guid][aura.spellId]=button.iconFrame
                Ether.StartBlink(raidIconData[guid][aura.spellId],aura.duration,0.28)
                raidAuraDispel[aura.auraInstanceID]=aura
            end
            if aura.isHarmful and c[aura.spellId] and c[aura.spellId].enabled and c[aura.spellId].isDebuff and c[aura.spellId].isActive then
                CreateAuraTexture(button,raidDebuffData,guid,aura.spellId)
                raidDebuffData[guid][aura.spellId]:Show()
                raidDebuffData[aura.auraInstanceID]={
                    spellId=aura.spellId,
                    guid=guid
                }
                raidAuraHarmful[aura.auraInstanceID]=aura
            end
        end
    end
    if updateInfo.removedAuraInstanceIDs then
        for _,auraInstanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
            if raidAuraDispel[auraInstanceID] then
                local auraData=raidDispelData[auraInstanceID]
                local auraGuid=auraData.guid
                local spellId=auraData.spellId
                if raidDispelData[auraGuid] and raidDispelData[auraGuid][spellId] then
                    Ether:UpdateDispelBorder(raidDispelData[auraGuid][spellId],{0,0,0,1})
                end
                if raidIconData[auraGuid] and raidIconData[auraGuid][spellId] then
                    Ether.StopBlink(raidIconData[auraGuid][spellId])
                end
                raidAuraDispel[auraInstanceID]=nil
            end
            if raidAuraHarmful[auraInstanceID] then
                local auraData=raidDebuffData[auraInstanceID]
                if not auraData then
                    return
                end
                local auraGuid=auraData.guid
                local spellId=auraData.spellId
                if raidDebuffData[auraGuid] and raidDebuffData[auraGuid][spellId] then
                    raidDebuffData[auraGuid][spellId]:Hide()
                end
                raidAuraHarmful[auraInstanceID]=nil
            end
            if helpfulAuras[auraInstanceID] then
                local auraData=dataHelpful[auraInstanceID]
                if not auraData then
                    return
                end
                local auraGuid=auraData.guid
                local spellId=auraData.spellId
                if dataHelpful[guid] and dataHelpful[auraGuid][spellId] then
                    if c[spellId].isActive then
                        dataHelpful[auraGuid][spellId]:Hide()
                    else
                        dataHelpful[auraGuid][spellId]:Show()
                    end
                end
                helpfulAuras[auraInstanceID]=nil
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
    local dispel=colors[dispelName]
    if dispel then
        self:SetColorTexture(unpack(dispel))
        self:Show()
    else
        self:Hide()
    end
end

local function SoloAuraIsHelpful(unit)
    local button=Ether.unitButtons.solo[unit]
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
    local button=Ether.unitButtons.solo[unit]
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

local function soloAuraUpdate(unit,updateInfo)
    if not UnitExists(unit) then
        return
    end
    local button=Ether.unitButtons.solo[unit]
    if not button or not button.Aura then
        return
    end
    local helpful,harmful=false,false
    if updateInfo.addedAuras then
        for _,aura in ipairs(updateInfo.addedAuras) do
            if aura.isHelpful then
                helpful=true
            end
            if aura.isHarmful then
                harmful=true
            end
        end
    end
    if updateInfo.removedAuraInstanceIDs then
        helpful=true
        harmful=true
    end
    if helpful then
        SoloAuraIsHelpful(unit)
    end
    if harmful then
        SoloAuraIsHarmful(unit)
    end
end

local function Aura(_,event,arg1,...)
    if event=="UNIT_AURA" then
        if not UnitExists(arg1) then
            return
        end
        local updateInfo=...
        if updateInfo then
            if Ether.DB[1001][3]==1 then
                raidAuraUpdate(arg1,updateInfo)
            end
            if Ether:IsValidSoloAura(arg1) and Ether.DB[1001][2]==1 then
                soloAuraUpdate(arg1,updateInfo)
            end
        end
    end
end

local update
if not update then
    update=CreateFrame("Frame")
end

function Ether:AuraWipe()
    wipe(raidAuraHarmful)
    wipe(raidAuraDispel)
    wipe(raidAuraIcons)
    wipe(raidDispelData)
    wipe(raidIconData)
    wipe(helpfulAuras)
    wipe(dataHelpful)
    wipe(raidDebuffData)
    wipe(dispelCache)
    wipe(getUnitBuffs)
    wipe(getUnitDebuffs)
end
local data={}
local function GetUnits()
    wipe(data)
    if UnitInParty("player") then
        for i=1,GetNumSubgroupMembers() do
            tinsert(data,"player")
            local unit="party"..i
            if UnitExists(unit) then
                tinsert(data,unit)
            end
        end
    elseif UnitInRaid("player") then
        for i=1,GetNumGroupMembers() do
            local unit="raid"..i
            if UnitExists(unit) then
                tinsert(data,unit)
            end
        end
    else
        tinsert(data,"player")
    end
    return data
end

function Ether:SoloAuraFullInitial(unit)
    local button=Ether.unitButtons.solo[unit]
    if not button then
        return
    end
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
    local button=Ether.unitButtons.solo["target"]
    if button then
        SoloAuraIsHelpful("target")
        SoloAuraIsHarmful("target")
    end
end

function Ether:ForceHelpfulNotActive()
    for _,unit in ipairs(GetUnits()) do
        if UnitExists(unit) then
            local button=Ether.unitButtons.raid[unit]
            if not button then
                return
            end
            local guid=UnitGUID(unit)
            if guid then
                UpdateAuraActive(button,guid)
            end
        end
    end
end

local function auraTblReset(unit)
    local button=Ether.unitButtons.solo[unit]
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
    C_Timer.After(0.3,function()
        for _,unit in ipairs(GetUnits()) do
            if UnitExists(unit) then
                local button=Ether.unitButtons.raid[unit]
                if not button then
                    return
                end
                local guid=UnitGUID(unit)
                if guid then
                    Ether:UpdateRaidIsHelpful(button,guid)
                    Ether:UpdateRaidIsHarmful(button,guid)
                    UpdateAuraActive(button,guid)
                end
            end
        end
    end)
end

function Ether:FullAuraReset()
    Ether.StopAllBlinks()
    Ether:CleanupRaidIcons()
    Ether:DisableHeaderAuras()
    Ether:DisableSoloAuras()
    Ether:EnableHeaderAuras()
    Ether:EnableSoloAuras()
end

function Ether:AuraEnable()
    if not update:GetScript("OnEvent") then
        update:RegisterEvent("UNIT_AURA")
        update:RegisterUnitEvent("UNIT_AURA","targettarget")
        update:SetScript("OnEvent",Aura)
    end
    if Ether.DB[1001][3]==1 then
        C_Timer.After(3,function()
            if Ether.DB[1001][3]==1 then
                for _,unit in ipairs(GetUnits()) do
                    if UnitExists(unit) then
                        local button=Ether.unitButtons.raid[unit]
                        if not button then
                            return
                        end
                        local guid=UnitGUID(unit)
                        if guid then
                            Ether:UpdateRaidIsHelpful(button,guid)
                            Ether:UpdateRaidIsHarmful(button,guid)
                        end
                    end
                end
            end
        end)
    end
    if Ether.DB[1001][2]==1 then
        Ether:EnableSoloAuras()
    end

end

function Ether:AuraDisable()
    if update:GetScript("OnEvent") then
        Ether.StopAllBlinks()
        Ether:CleanupRaidIcons()
        Ether:DisableSoloAuras()
        update:UnregisterAllEvents()
        update:SetScript("OnEvent",nil)
        Ether:AuraWipe()
    end
end
