local _,Ether=...
local math_floor=math.floor
local math_ceil=math.ceil
local pairs,ipairs=pairs,ipairs
local GetUnitAuras=C_UnitAuras.GetUnitAuras
local UnitGUID=UnitGUID
local UnitExists=UnitExists
local UnitIsConnected=UnitIsConnected
local unpack,type,wipe=unpack,type,wipe
local tinsert,tremove=table.insert,table.remove
--local GetTime=GetTime
--local GetUnitAuraBySpellID=C_UnitAuras.GetUnitAuraBySpellID
--local GetDataByIndex=C_UnitAuras.GetAuraDataByIndex
--local GetBuffDataByIndex=C_UnitAuras.GetBuffDataByIndex
-- local GetDebuffDataByIndex=C_UnitAuras.GetDebuffDataByIndex
--   if updateInfo.isFullUpdate then
--   end
--   if info.updatedAuraInstanceIDs then
--   end

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
dispelByPlayer=dispelClass[classFilename]

local function CheckRaidButtons(arg1)
    for unit,button in pairs(Ether.unitButtons.raid) do
        if button and unit and unit==arg1 then
            return button,button.unit,button.destGUID
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
                tbl[guid][spellId]:SetColorTexture(unpack(C.color))
                tbl[guid][spellId]:SetSize(C.size,C.size)
                tbl[guid][spellId]:SetPoint(C.position,C.offsetX,C.offsetY)
                if tbl[guid][spellId].Shown then
                    tbl[guid][spellId]:Show()
                    tbl[guid][spellId].Shown=nil
                end
            end
        end
    end
end

function Ether:SaveAuraPosition(spellId)
    if type(spellId)~="number" then return end
    updateAuraPos(Ether.dataSpell,spellId)
end

function Ether:UpdateDispelFrame(button,color)
    if not button or type(color)~="table" then return end
    if button.dispelLeft then
        button.dispelLeft:SetColorTexture(unpack(color))
        button.dispelRight:SetColorTexture(unpack(color))
    end
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

Ether.CheckGUID=function(unit,guid)
    local found=false
    local oldGUID=UnitGUID(unit)
    if oldGUID and oldGUID==guid then
        found=true
    end
    if found then
        for info in pairs(Ether.dataSpell) do
            if info and info==guid then
                info=nil
                break
            end
        end
        for info in pairs(Ether.dataDispel) do
            if info and info==guid then
                info=nil
                break
            end
        end
    end
end

local function raidAuraUpdate(arg1,updateInfo)
    local button,unit,guid=CheckRaidButtons(arg1)
    if not button then return end

    if not UnitIsConnected(unit) then
        Ether.CheckGUID(unit,guid)
    end
    local C=Ether.DB[1003]
    local spell=false

    if updateInfo.addedAuras then
        for _,aura in ipairs(updateInfo.addedAuras) do
            if aura.isHarmful and aura.dispelName then
                local color=dispelColors[aura.dispelName] or {0,0,0,0}
                if dispelByPlayer[aura.dispelName] then
                    Ether.dataDispel[guid][aura.dispelName] = button
                    Ether:UpdateDispelFrame(Ether.dataDispel[guid][aura.dispelName],color)
                end
                button.dispelIcon:SetTexture(aura.icon)
                button.dispelBorder:SetColorTexture(unpack(color))
                Ether.dataDispel[guid][aura.icon]=button.dispelFrame
                Ether.StartBlink(Ether.dataDispel[guid][aura.icon],aura.duration,0.26)
                Ether.dispelInstance[aura.auraInstanceID]=aura
            end
            if not C[aura.spellId] or not C[aura.spellId].isEnabled then return end
            spell=true
            tinsert(Ether.spellAdded,aura)
            Ether.spellInstance[aura.auraInstanceID]=aura
        end
    end

    if updateInfo.removedAuraInstanceIDs then
        for _,auraInstanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
            if Ether.spellInstance[auraInstanceID] then
                local data=Ether.spellInstance[auraInstanceID].spellId
                if Ether.dataSpell[guid] and Ether.dataSpell[guid][data] then
                    Ether:Release(Ether.dataSpell[guid][data])
                end
                Ether.spellInstance[auraInstanceID]=nil
            end
            if Ether.dispelInstance[auraInstanceID] then
                if not Ether.dataDispel[guid] then return end
                local auraData=Ether.dispelInstance[auraInstanceID]
                local icon=auraData.icon
                local name=auraData.dispelName
                if Ether.dataDispel[guid][name] then
                     Ether:UpdateDispelFrame(Ether.dataDispel[guid][name],{0,0,0,0})
                end
                if Ether.dataDispel[guid][icon] then
                    Ether.StopBlink(Ether.dataDispel[guid][icon])
                end
                Ether.dispelInstance[auraInstanceID]=nil
            end
        end
    end

    if spell then
        for _,info in ipairs(Ether.spellAdded) do
            if info and info.spellId then
                Ether.dataSpell[guid][info.spellId]=Ether:Acquire(C[info.spellId],unit)
            end
        end
        wipe(Ether.spellAdded)
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

local buttons=Ether.unitButtons.raid

local function getDB()
    return Ether.DB and Ether.DB[1001][3]
end

local function Aura(_,event,arg1,...)
    if event~="UNIT_AURA" then return end
    if not arg1 or not UnitExists(arg1) then return end
    local updateInfo=...
    if not updateInfo then return end
    if Ether.DB[1001][3]==1 then
        if buttons[arg1] then
            raidAuraUpdate(arg1,updateInfo)
        end
    end
    if Ether.DB[1001][2]==1 then
        if Ether:IsValidAura(arg1) then
            soloAuraUpdate(arg1,updateInfo)
        end
    end
end

local update
if not update then
    update=CreateFrame("Frame")
end

function Ether:AuraEnable()
    if Ether.DB[1001][1]~=1 then return end
    if not update:GetScript("OnEvent") then
        update:RegisterEvent("UNIT_AURA")
        update:RegisterUnitEvent("UNIT_AURA","targettarget")
        update:SetScript("OnEvent",Aura)
    end
    if Ether.DB[1001][2]==1 then
        Ether:EnableSoloAuras()
    end
end

function Ether:AuraDisable()
    if update:GetScript("OnEvent") then
        Ether:DisableSoloAuras()
        update:UnregisterAllEvents()
        update:SetScript("OnEvent",nil)
        Ether.StopAllBlinks()
        Ether:ReleaseAll()
        Ether:DisableSoloAuras()
        Ether:RaidAuraWipe()
    end
end
