local _,Ether=...
local Tooltip={}
Ether.Tooltip=Tooltip
local L=Ether.L
local GetG_Info=GetGuildInfo
local RealmName=GetRealmName
local UnitName=UnitName
local UnitClass=UnitClass
local UnitIsPlayer=UnitIsPlayer
local UnitReaction=UnitReaction
local UnitExists=UnitExists
local UnitIsPVP=UnitIsPVP
local UnitIsPVPFreeForAll=UnitIsPVPFreeForAll
local IsResting=IsResting
local UnitIsUnit=UnitIsUnit
local UnitFactionGroup=UnitFactionGroup
local UnitIsAFK=UnitIsAFK
local UnitIsDND=UnitIsDND
local GetTargetIndex=GetRaidTargetIndex
local UnitGroupRolesAssigned=UnitGroupRolesAssigned
local U_RACE=UnitRace
local U_CREATURE=UnitCreatureType
local AFK=[[|cffff00ffAFK|r]]
local DND=[[|cffCC66FFDND|r]]
local TANK='|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:0:19:22:41|t'
local HEAL='|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:20:39:1:20|t'
local DAMAGER='|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:20:39:22:41|t'
local tankStr="TANK"
local healStr="HEALER"
local damagerStr="DAMAGER"
local fStr=" %s  |cff%02x%02x%02x%s|r"
local cStr="|cffffd700%s - %s|r"
local aStr=" |cff%02x%02x%02x%s|r"
local bStr="|cff%02x%02x%02x%s|r "
local string_format=string.format
local tconcat=table.concat
Tooltip.StringBuffer=(function()
    local bufferPool={}
    local poolCount=0
    return {
        Get=function()
            local buffer
            if poolCount>0 then
                buffer=bufferPool[poolCount]
                bufferPool[poolCount]=nil
                poolCount=poolCount-1
            else
                buffer={}
            end
            return buffer
        end,
        Add=function(buffer,str)
            buffer[#buffer+1]=str
        end,
        AddFormat=function(buffer,fmt,...)
            buffer[#buffer+1]=string_format(fmt,...)
        end,
        Concat=function(buffer,sep)
            return tconcat(buffer,sep or "",1,#buffer)
        end,
        Release=function(buffer)
            for i=#buffer,1,-1 do
                buffer[i]=nil
            end
            if poolCount<100 then
                poolCount=poolCount+1
                bufferPool[poolCount]=buffer
            end
        end
    }
end)()

local function GetF_UnitClass(unit)
    local className,classFileName=UnitClass(unit)
    local color=RAID_CLASS_COLORS[classFileName]
    if color then
        return string_format(aStr,color.r*255,color.g*255,color.b*255,className)
    end
    return ""
end

local levelColorCache={}
local function GetCachedLevelColor(level)
    if not levelColorCache[level] then
        if level==-1 then
            levelColorCache[level]='|cffff0000??|r '
        elseif level==0 then
            levelColorCache[level]='? '
        else
            local diff=GetQuestDifficultyColor(level)
            levelColorCache[level]=string_format(bStr,diff.r*255,diff.g*255,diff.b*255,level)
        end
    end
    return levelColorCache[level]
end

local function GetUnitRoleString(unit)
    local role=UnitGroupRolesAssigned(unit)
    local roleList=nil

    if (role==tankStr) then
        roleList=' '..TANK..''
    elseif (role==healStr) then
        roleList=' '..HEAL..''
    elseif (role==damagerStr) then
        roleList=' '..DAMAGER..''
    end
    return roleList
end

local function UpdateTooltip(self,unit)
    if not unit or not UnitExists(unit) then
        return
    end

    local DB=Ether.DB[301]
    local name=UnitName(unit)
    local isPlayer=UnitIsPlayer(unit)
    local _,classFileName=UnitClass(unit)
    local raidColors=Ether.RAID_COLORS
    local factionColors=Ether.FACTION_COLORS

    local buffer=Tooltip.StringBuffer.Get()

    local targetName=UnitName(unit.."target")
    if targetName then
        local you=UnitIsUnit(unit.."target","player")
        local color=raidColors[select(2,UnitClass(unit..'target'))] or raidColors["UNKNOWN"]
        self.target:SetText(you and L.TT_AIMING_YOU or
                string_format(fStr,L.TT_AIMING,color.r*255,color.g*255,color.b*255,targetName))
        self.target:Show()
    else
        self.target:Hide()
    end

    local nameColorR,nameColorG,nameColorB=1,0.9,0.5

    if isPlayer and raidColors[classFileName] then
        nameColorR,nameColorG,nameColorB=raidColors[classFileName].r,raidColors[classFileName].g,raidColors[classFileName].b
    elseif DB[13]==1 then
        local reaction=UnitReaction(unit,"player")
        if reaction and factionColors[reaction] then
            nameColorR,nameColorG,nameColorB=factionColors[reaction].r,factionColors[reaction].g,factionColors[reaction].b
        end
    end

    self.name:SetTextColor(nameColorR,nameColorG,nameColorB)

    if DB[1]==1 and UnitIsAFK(unit) then
        self.flags:SetText(AFK)
        self.flags:Show()
    elseif DB[2]==1 and UnitIsDND(unit) then
        self.flags:SetText(DND)
        self.flags:Show()
    else
        self.flags:Hide()
    end

    if DB[3]==1 then
        if UnitIsPVPFreeForAll(unit) then
            self.pvp:SetTexture("Interface\\AddOns\\Ether\\Media\\Texture\\UI-PVP-FFA")
            self.pvp:Show()
        elseif UnitFactionGroup(unit) and UnitIsPVP(unit) then
            self.pvp:SetTexture("Interface\\AddOns\\Ether\\Media\\Texture\\UI-PVP-"..UnitFactionGroup(unit))
            self.pvp:Show()
        else
            self.pvp:Hide()
        end
    else
        self.pvp:Hide()
    end

    if DB[4]==1 and (UnitIsUnit(unit,"player") and IsResting()) then
        self.resting:Show()
    else
        self.resting:Hide()
    end

    if DB[5]==1 then
        local realmRelation=UnitRealmRelationship(unit)
        local isDifferentRealm=(realmRelation and realmRelation~=LE_REALM_RELATION_SAME)
        if isDifferentRealm then
            self.name:SetText(string_format("%s - %s",name,RealmName()))
        else
            self.name:SetText(name)
        end
    else
        self.name:SetText(name)
    end

    if DB[6]==1 then
        Tooltip.StringBuffer.Add(buffer,GetCachedLevelColor(UnitLevel(unit)))
    end

    if DB[7]==1 and isPlayer then
        Tooltip.StringBuffer.Add(buffer,GetF_UnitClass(unit))
    end

    if DB[8]==1 and isPlayer then
        local guildName,guildRankName=GetG_Info(unit)
        if guildName then
            self.guild:SetText(string_format(cStr,guildName,guildRankName or L.TT_UNKNOWN))
            self.guild:Show()
        else
            self.guild:Hide()
        end
    else
        self.guild:Hide()
    end

    if DB[9]==1 then
        Tooltip.StringBuffer.Add(buffer,GetUnitRoleString(unit))
    end

    if DB[10]==1 and U_CREATURE(unit) then
        Tooltip.StringBuffer.Add(buffer," "..U_CREATURE(unit))
    end

    if DB[11]==1 and U_RACE(unit) then
        Tooltip.StringBuffer.Add(buffer," "..U_RACE(unit))
    end

    if DB[12]==1 then
        local index=GetTargetIndex(unit)
        if index then
            Tooltip.StringBuffer.Add(buffer,ICON_LIST[index].."11|t")
        end
    end

    if #buffer>0 then
        self.info:SetText(Tooltip.StringBuffer.Concat(buffer,","))
        self.info:Show()
    else
        self.info:Hide()
    end
    Tooltip.StringBuffer.Release(buffer)
end

function Ether:ToolTipInitialize()
    if not Ether.toolFrame then return end
    local frame=Ether.toolFrame
    GameTooltip:HookScript("OnTooltipSetUnit",function(self)
        if Ether.DB[401][3]~=1 then
            return
        end
        local _,unit=self:GetUnit()
        if unit and frame then
            if not frame:IsShown() then
                frame:Show()
            end
            UpdateTooltip(frame,unit)
        end
    end)
    GameTooltip:HookScript("OnTooltipCleared",function()
        if Ether.DB[401][3]~=1 then
            return
        end
        if frame and frame:IsShown() then
            frame:Hide()
        end
    end)
end
