local _,Ether=...
local math_floor=math.floor
local math_ceil=math.ceil
local pairs,ipairs=pairs,ipairs
local GetBuffDataByIndex=C_UnitAuras.GetBuffDataByIndex
local GetDebuffDataByIndex=C_UnitAuras.GetDebuffDataByIndex
local GetUnitAuras=C_UnitAuras.GetUnitAuras
local UnitGUID=UnitGUID
local UnitExists=UnitExists
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

local raidAuraHelpful={}
local raidAuraHarmful={}
local raidAuraDispel={}
local dataHelpful={}
local dataHarmful={}
local dataDispel={}
local getUnitBuffs={}
local getUnitDebuffs={}

local function CheckRaidButtons(unit)
    for _,button in pairs(Ether.unitButtons.raid) do
        if button and button.unit==unit then
            return button
        end
    end
    return nil
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
    local CFG=Ether.DB[1003][spellId]
    if CFG.isDebuff then
        updateAuraPos(dataHarmful,spellId,CFG)
    else
        updateAuraPos(dataHelpful,spellId,CFG)
    end
end

local function CreateAuraTexture(button,tbl,guid,spellId)
    if not tbl[guid] then
        tbl[guid]={}
    end
    local CFG=Ether.DB[1003][spellId]
    if not tbl[guid][spellId] then
        tbl[guid][spellId]=button.healthBar:CreateTexture(nil,"OVERLAY")
        tbl[guid][spellId]:SetColorTexture(unpack(CFG.color))
        tbl[guid][spellId]:SetSize(CFG.size,CFG.size)
        tbl[guid][spellId]:SetPoint(CFG.position,CFG.offsetX,CFG.offsetY)
        tbl[guid][spellId]:Hide()
    end
end

function Ether:UpdateDispelFrame(button,color)
    if type(color)~="table" then return end
    if not button or not button.left or not button.right then return end
    button.left:SetColorTexture(unpack(color))
    button.right:SetColorTexture(unpack(color))
end

function Ether:UpdatePrediction(button)
    if not button then return end
    if button.myPrediction then
        button.myPrediction:Hide()
    end
    if button.otherPrediction then
        button.otherPrediction:Hide()
    end
end

local function CheckDispelOrder(data)
    if not data then return nil end
    local dispel=nil
    local priority=0
    local order=dispelPriority[data] or 0
    if order>priority then
        priority=order
        dispel=order
    end
    return dispel
end

local function UpdateDispelButton(button,guid)
    if not button or not guid then return end
    local dispelName=dataDispel[guid].dispel
    local order=CheckDispelOrder(dispelName)
    local color=colors[order] or {0,0,0,0}
    Ether:UpdateDispelFrame(button,color)
    if not button.iconFrame then return end
    local icon=dataDispel[guid].icon
    local duration=dataDispel[guid].duration
    local spellId=dataDispel[guid].spellId
    button.dispelIcon:SetTexture(icon)
    button.dispelBorder:SetColorTexture(unpack(color))
    dataDispel[guid][spellId]=button.iconFrame
    Ether.StartBlink(dataDispel[guid][spellId],duration,0.28)
end

local function CheckActiveStatus(tbl,config,guid,spellId)
    if not tbl or type(tbl)~="table" then return end
    if config[spellId].isActive then
        tbl[guid][spellId]:Show()
    else
        tbl[guid][spellId]:Hide()
    end
end

function Ether:CheckRaidAuras(button,guid)
    if not button or not button.unit or not guid then
        return
    end
    local CFG=Ether.DB[1003]
    if not dataHelpful[guid] then dataHelpful[guid] = {} end
    if not dataHarmful[guid] then dataHarmful[guid] = {} end
    local index=1
    while true do
        local aura=GetBuffDataByIndex(button.unit,index)
        if not aura then break end
        if CFG[aura.spellId] then
            local data=CFG[aura.spellId]
            if not data.isDebuff then
                CreateAuraTexture(button, dataHelpful, guid, aura.spellId)
                CheckActiveStatus(dataHelpful, CFG, guid, aura.spellId)
                raidAuraHelpful[aura.auraInstanceID] = aura
            end
        end
        index=index+1
    end

    index=1
    while true do
        local aura=GetDebuffDataByIndex(button.unit,index)
        if not aura then break end
        if CFG[aura.spellId] then
            local data=CFG[aura.spellId]
            if data.isDebuff then
                CreateAuraTexture(button, dataHarmful, guid, aura.spellId)
                CheckActiveStatus(dataHarmful, CFG, guid, aura.spellId)
                raidAuraHarmful[aura.auraInstanceID] = aura
            end
        end
        index=index+1
    end
end

local function raidAuraUpdate(unit,updateInfo)
    local button=CheckRaidButtons(unit)
    if not button then return end
    local guid=UnitGUID(unit)
    if not guid then return end
    local CFG=Ether.DB[1003]

    if updateInfo.addedAuras then
        for _,aura in ipairs(updateInfo.addedAuras) do
            if aura.isHarmful and dispelByPlayer[aura.dispelName] then
               if not dataDispel[guid] then dataDispel[guid]={} end
                dataDispel[guid] = {
                   spellId= aura.spellId,
                    icon=aura.icon,
                    dispel=aura.dispelName,
                    duration=aura.duration
                }
               UpdateDispelButton(button,guid)
                raidAuraDispel[aura.auraInstanceID]=aura
            end
            if CFG[aura.spellId] then
                local data=CFG[aura.spellId]
                if aura.isHelpful and not data.isDebuff then
                    CreateAuraTexture(button, dataHelpful, guid, aura.spellId)
                    CheckActiveStatus(dataHelpful, CFG, guid, aura.spellId)
                    raidAuraHelpful[aura.auraInstanceID]=aura
                end
                if aura.isHarmful and data.isDebuff then
                    CreateAuraTexture(button, dataHarmful, guid, aura.spellId)
                    CheckActiveStatus(dataHarmful, CFG, guid, aura.spellId)
                    raidAuraHarmful[aura.auraInstanceID]=aura
                end
            end
        end
    end

    if updateInfo.removedAuraInstanceIDs then
        for _,auraInstanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
            if raidAuraDispel[auraInstanceID] then
                local auraData = raidAuraDispel[auraInstanceID]
                if auraData and auraData.spellId then
                    Ether:UpdateDispelFrame(button, {0,0,0,0})
                    if dataDispel[guid] and dataDispel[guid][auraData.spellId] then
                        Ether.StopBlink(dataDispel[guid][auraData.spellId])
                    end
                end
                raidAuraDispel[auraInstanceID]=nil
            end

            if raidAuraHarmful[auraInstanceID] then
                local auraData = raidAuraHarmful[auraInstanceID]
                if auraData and auraData.spellId and dataHarmful[guid] then
                    if dataHarmful[guid][auraData.spellId] then
                        dataHarmful[guid][auraData.spellId]:Hide()
                    end
                end
                raidAuraHarmful[auraInstanceID]=nil
            end

            if raidAuraHelpful[auraInstanceID] then
                local auraData = raidAuraHelpful[auraInstanceID]
                if auraData and auraData.spellId and dataHelpful[guid] then
                    if dataHelpful[guid][auraData.spellId] then
                        dataHelpful[guid][auraData.spellId]:Hide()
                    end
                end
                raidAuraHelpful[auraInstanceID]=nil
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

function Ether:AuraWipe()
    wipe(raidAuraHelpful)
    wipe(raidAuraHarmful)
    wipe(raidAuraDispel)
    wipe(dataHelpful)
    wipe(dataHarmful)
    wipe(dataDispel)
    wipe(getUnitBuffs)
    wipe(getUnitDebuffs)
end

local dataUnits={}
local function GetUnits()
    wipe(dataUnits)
    if UnitInParty("player") and not UnitInRaid("player") then
        for i=1,GetNumSubgroupMembers() do
            tinsert(dataUnits,"player")
            local unit="party"..i
            if UnitExists(unit) then
                tinsert(dataUnits,unit)
            end
        end
    elseif UnitInRaid("player") and not UnitInParty("player") then
        for i=1,GetNumGroupMembers() do
            local unit="raid"..i
            if UnitExists(unit) then
                tinsert(dataUnits,unit)
            end
        end
    else
        tinsert(dataUnits,"player")
    end
    return dataUnits
end

function Ether:EnableHeaderAuras()
    for _,unit in ipairs(GetUnits()) do
        local button=CheckRaidButtons(unit)
        if not button then return end
        local guid=UnitGUID(unit)
        if not guid then return end
        Ether:CheckRaidAuras(button,guid)
    end
end

function Ether:FullAuraReset()
    Ether:DisableSoloAuras()
    Ether:CleanupRaidIcons()
    Ether:AuraWipe()
    Ether:EnableHeaderAuras()
    Ether:EnableSoloAuras()
end

function Ether:CleanupAuras(guid)
    if dataHelpful[guid] then
        for spellId, texture in pairs(dataHelpful[guid]) do
            if type(texture) == "table" or type(texture) == "userdata" then
                texture:Hide()
                texture:ClearAllPoints()
                texture:SetParent(nil)
            end
        end
        dataHelpful[guid]=nil
    end
    if dataHarmful[guid] then
        for spellId, texture in pairs(dataHarmful[guid]) do
            if type(texture) == "table" or type(texture) == "userdata" then
                texture:Hide()
                texture:ClearAllPoints()
                texture:SetParent(nil)
            end
        end
        dataHarmful[guid]=nil
    end

    if dataDispel[guid] then
        for spellId, data in pairs(dataDispel[guid]) do
            if data and type(data) == "table" then
                if Ether.StopBlink then
                    Ether.StopBlink(data)
                end
            end
        end
        dataDispel[guid]=nil
    end
end

function Ether:CleanupRaidIcons()
    for guid,_ in pairs(dataHelpful) do
        Ether:CleanupAuras(guid)
    end
    for guid,_ in pairs(dataHarmful) do
        Ether:CleanupAuras(guid)
    end
    for guid,_ in pairs(dataDispel) do
        Ether:CleanupAuras(guid)
    end
    Ether.StopAllBlinks()
end

local function Aura(_,event,arg1,...)
    if event~="UNIT_AURA" then return end
    if not arg1 or not UnitExists(arg1) then return end
    local updateInfo=...
    if not updateInfo then return end
    if Ether.DB[1001][3]==1 then
        if Ether.unitButtons.raid[arg1] then
            raidAuraUpdate(arg1,updateInfo)
        end
    end
    if Ether.DB[1001][2]==1 then
        if Ether:IsValidSoloAura(arg1) then
            soloAuraUpdate(arg1,updateInfo)
        end
    end
end

local update
if not update then
    update=CreateFrame("Frame")
end

local state=false
function Ether:AuraEnable()
    if Ether.DB[1001][1]~=1 then return end
    if not update:GetScript("OnEvent") then
        update:RegisterEvent("UNIT_AURA")
        update:SetScript("OnEvent",Aura)
    end
    if not state then
        state=true
        C_Timer.After(1.4,function()
            if Ether.DB[1001][3]==1 then
                Ether:EnableHeaderAuras()
            end
            if Ether.DB[1001][2]==1 then
                Ether:EnableSoloAuras()
            end
            state=false
        end)
    end
end

function Ether:AuraDisable()
    if update:GetScript("OnEvent") then
        update:UnregisterAllEvents()
        update:SetScript("OnEvent",nil)
        Ether:CleanupRaidIcons()
        Ether:DisableSoloAuras()
        Ether:AuraWipe()
    end
end
