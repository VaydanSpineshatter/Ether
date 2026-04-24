local D,F,_,C,L=unpack(select(2,...))
local frame=C.ToolFrame
local UnitName,UnitClass,GetRealmName=UnitName,UnitClass,GetRealmName
local UnitExists,UnitLevel,UnitRace=UnitExists,UnitLevel,UnitRace
local UnitIsPVP,UnitFactionGroup=UnitIsPVP,UnitFactionGroup
local UnitIsPVPFreeForAll=UnitIsPVPFreeForAll
local UnitRealmRelationship=UnitRealmRelationship
local IsResting,select,UnitReaction=IsResting,select,UnitReaction
local UnitIsUnit,UnitIsPlayer=UnitIsUnit,UnitIsPlayer
local UnitIsAFK,UnitIsDND,GetRaidTargetIndex=UnitIsAFK,UnitIsDND,GetRaidTargetIndex
local UnitGroupRolesAssigned=UnitGroupRolesAssigned
local UnitCreatureType,GetGuildInfo=UnitCreatureType,GetGuildInfo
local tconcat,sformat=table.concat,string.format
local GameTooltip=GameTooltip
local AFK=[[|cffff00ffAFK|r]]
local DND=[[|cffCC66FFDND|r]]
local TANK="|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:0:19:22:41|t"
local HEAL="|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:20:39:1:20|t"
local DAMAGER="|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:20:39:22:41|t"
local tankStr="TANK"
local healStr="HEALER"
local damagerStr="DAMAGER"
local fStr=" %s  |cff%02x%02x%02x%s|r"
local cStr="|cffffd700%s - %s|r"
local aStr=" |cff%02x%02x%02x%s|r"
local bStr="|cff%02x%02x%02x%s|r "
local name=frame:CreateFontString(nil,"OVERLAY")
frame.name=name
name:SetFontObject(C.EtherFont)
name:SetPoint("TOPLEFT",5,-5)
name:SetJustifyH("LEFT")
name:SetTextColor(1,0.9,0.5)
local guild=frame:CreateTexture(nil,"OVERLAY")
guild:SetSize(12,12)
guild:SetTexture(135026)
guild:SetPoint("TOPLEFT",name,"BOTTOMLEFT",0,-8)
local label=frame:CreateFontString(nil,"OVERLAY")
frame.label=label
label:SetFontObject(C.EtherFont)
label:SetPoint("LEFT",guild,"RIGHT",4,0)
label:SetTextColor(0.7,0.7,1,1)
local info=frame:CreateFontString(nil,"OVERLAY")
frame.info=info
info:SetFontObject(C.EtherFont)
info:SetPoint("TOPLEFT",guild,"BOTTOMLEFT",0,-8)
info:SetTextColor(0.8,0.8,0.8,1)
local skull=frame:CreateTexture(nil,"OVERLAY")
skull:SetSize(14,14)
skull:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
skull:SetPoint("TOPLEFT",info,"BOTTOMLEFT",0,-5)
local target=frame:CreateFontString(nil,"OVERLAY")
frame.target=target
target:SetFontObject(C.EtherFont)
target:SetPoint("LEFT",skull,"RIGHT",4,0)
target:SetJustifyH("LEFT")
target:SetTextColor(1,0.5,0.5,1)
local flags=frame:CreateFontString(nil,"OVERLAY")
frame.flags=flags
flags:SetFontObject(C.EtherFont)
flags:SetPoint("BOTTOMRIGHT",frame,-10,10)
flags:SetJustifyH("RIGHT")
flags:SetTextColor(0.6,0.6,0.6,1)
local pvp=frame:CreateTexture(nil,"OVERLAY")
frame.pvp=pvp
pvp:SetSize(18,18)
pvp:SetPoint("TOPRIGHT",-5,-5)
local resting=frame:CreateTexture(nil,"OVERLAY")
frame.resting=resting
resting:SetSize(18,18)
resting:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
resting:SetTexCoord(0.0625,0.45,0.0625,0.45)
resting:SetPoint("TOPRIGHT",pvp,"TOPLEFT")
frame:Hide()
local bg=frame:CreateTexture(nil,"BACKGROUND")
bg:SetColorTexture(0,0,0,.5)
bg:SetAllPoints()
local function GetClassColor(unit)
    local className,classFileName=UnitClass(unit)
    local color=RAID_CLASS_COLORS[classFileName]
    if color then
        return sformat(aStr,color.r*255,color.g*255,color.b*255,className)
    end
    return ""
end
local levelColorCache={}
local function GetLevelColor(level)
    if not levelColorCache[level] then
        if level==-1 then
            levelColorCache[level]='|cffff0000??|r '
        elseif level==0 then
            levelColorCache[level]='? '
        else
            local diff=GetQuestDifficultyColor(level)
            levelColorCache[level]=sformat(bStr,diff.r*255,diff.g*255,diff.b*255,level)
        end
    end
    return levelColorCache[level]
end
local function GetUnitRoleString(unit)
    local role=UnitGroupRolesAssigned(unit)
    local roleList
    if (role==tankStr) then
        roleList=' '..TANK..''
    elseif (role==healStr) then
        roleList=' '..HEAL..''
    elseif (role==damagerStr) then
        roleList=' '..DAMAGER..''
    end
    return roleList
end
local function UpdateTooltip(self,unit,DB)
    local name=UnitName(unit)
    local isPlayer=UnitIsPlayer(unit)
    local _,classFileName=UnitClass(unit)
    local parts=F.GetTbl()
    local target=UnitName(unit.."target")
    if target then
        local you=UnitIsUnit(unit.."target","player")
        local color=RAID_CLASS_COLORS[select(2,UnitClass(unit.."target"))] or RAID_CLASS_COLORS["UNKNOWN"]
        self.target:SetText(you and L.TT_AIMING_YOU or
                sformat(fStr,L.TT_AIMING,color.r*255,color.g*255,color.b*255,target))
        self.target:Show()
    else
        self.target:Hide()
    end
    local R,G,B=1,0.9,0.5
    if isPlayer and RAID_CLASS_COLORS[classFileName] then
        R,G,B=RAID_CLASS_COLORS[classFileName].r,RAID_CLASS_COLORS[classFileName].g,
        RAID_CLASS_COLORS[classFileName].b
    elseif DB[13]==1 then
        local reaction=UnitReaction(unit,"player")
        if reaction and FACTION_BAR_COLORS[reaction] then
            R,G,B=FACTION_BAR_COLORS[reaction].r,FACTION_BAR_COLORS[reaction].g,FACTION_BAR_COLORS[reaction].b
        end
    end
    self.name:SetTextColor(R,G,B)
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
            self.pvp:SetTexture("Interface\\AddOns\\Ether\\Media\\UI-PVP-FFA")
            self.pvp:Show()
        elseif UnitFactionGroup(unit) and UnitIsPVP(unit) then
            self.pvp:SetTexture("Interface\\AddOns\\Ether\\Media\\UI-PVP-"..UnitFactionGroup(unit))
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
            self.name:SetText(sformat("%s - %s",name,GetRealmName()))
        else
            self.name:SetText(name)
        end
    else
        self.name:SetText(name)
    end
    if DB[6]==1 then
        parts[#parts+1]=" "..GetLevelColor(UnitLevel(unit))
    end
    if DB[7]==1 then
        if isPlayer then
            parts[#parts+1]=" "..GetClassColor(unit)
        end
    end
    if DB[8]==1 then
        if isPlayer then
            local guildName,guildRankName=GetGuildInfo(unit)
            if guildName then
                self.label:SetText(sformat(cStr,guildName,guildRankName or L.TT_UNKNOWN))
                self.label:Show()
            else
                self.label:Hide()
            end
        else
            self.label:Hide()
        end
    end
    if DB[9]==1 then
        parts[#parts+1]=GetUnitRoleString(unit)
    end
    if DB[10]==1 then
        if UnitCreatureType(unit) then
            parts[#parts+1]=" "..UnitCreatureType(unit)
        end
    end
    if DB[11]==1 then
        if UnitRace(unit) then
            parts[#parts+1]=" "..UnitRace(unit)
        end
    end
    if DB[12]==1 then
        local index=GetRaidTargetIndex(unit)
        if index then
            parts[#parts+1]=ICON_LIST[index].."11|t"
        end
    end
    self.info:SetText(tconcat(parts,','))
    F.RelTbl(parts)
end
function F:ToolTipInitialize()
    if not frame then return end
    GameTooltip:HookScript("OnTooltipSetUnit",function(self)
        local _,unit=self:GetUnit()
        if not unit or not UnitExists(unit) then return end
        if not frame:IsShown() then
            frame:Show()
        end
        UpdateTooltip(frame,unit,D.DB[4])
    end)
    GameTooltip:HookScript("OnTooltipCleared",function()
        if D.DB[1][9]~=1 then return end
        if frame:IsShown() then
            if not C.StatusTooltip then
                frame:Hide()
            end
        end
    end)
end