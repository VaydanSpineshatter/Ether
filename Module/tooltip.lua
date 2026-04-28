local D,F,_,C,L=unpack(select(2,...))
local UnitName,UnitClass,GetRealmName=UnitName,UnitClass,GetRealmName
local UnitExists,UnitLevel,UnitRace=UnitExists,UnitLevel,UnitRace
local UnitIsPVP,UnitFactionGroup,tostring=UnitIsPVP,UnitFactionGroup,tostring
local UnitIsPVPFreeForAll,UnitGroupRolesAssigned=UnitIsPVPFreeForAll,UnitGroupRolesAssigned
local IsResting,select,UnitReaction=IsResting,select,UnitReaction
local UnitIsUnit,UnitIsPlayer=UnitIsUnit,UnitIsPlayer
local UnitIsAFK,UnitIsDND,GetRaidTargetIndex=UnitIsAFK,UnitIsDND,GetRaidTargetIndex
local UnitCreatureType,GetGuildInfo,GameTooltip=UnitCreatureType,GetGuildInfo,GameTooltip
local tconcat,sformat,AFK,DND=table.concat,string.format,"|cffff00ffAFK|r","|cffCC66FFDND|r"
local fStr,aStr,bStr=" %s  |cff%02x%02x%02x%s|r"," |cff%02x%02x%02x%s|r","|cff%02x%02x%02x%s|r "
if not C.ToolFrame then return end
local frame=C.ToolFrame
local info=frame:CreateFontString(nil,"OVERLAY")
info:SetFontObject(C.EtherFont)
info:SetPoint("TOPLEFT",5,-5)
info:SetJustifyH("LEFT")
info:SetTextColor(1,0.9,0.5)
local second=frame:CreateFontString(nil,"OVERLAY")
second:SetFontObject(C.EtherFont)
second:SetPoint("TOPLEFT",info,"BOTTOMLEFT",0,-8)
second:SetTextColor(0.8,0.8,0.8,1)
local skull=frame:CreateTexture(nil,"OVERLAY")
skull:SetSize(14,14)
skull:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
skull:SetPoint("TOPLEFT",second,"BOTTOMLEFT",0,-5)
local target=frame:CreateFontString(nil,"OVERLAY")
frame.target=target
target:SetFontObject(C.EtherFont)
target:SetPoint("LEFT",skull,"RIGHT",4,0)
target:SetJustifyH("LEFT")
target:SetTextColor(1,0.5,0.5,1)
local pvp=frame:CreateTexture(nil,"OVERLAY")
frame.pvp=pvp
pvp:SetSize(18,18)
pvp:SetPoint("TOPRIGHT",-5,-5)
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
local roleStr={"TANK","HEALER","DAMAGER"}
local roleIcon={"|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:18:18:0:0:64:64:0:19:22:41|t",
                "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:18:18:0:0:64:64:20:39:1:20|t",
                "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:18:18:0:0:64:64:20:39:22:41|t"}
local function GetUnitRoleString(unit)
    local role=UnitGroupRolesAssigned(unit)
    if role=="NONE" then return end
    for i,v in ipairs(roleStr) do
        if v==role then
            return roleIcon[i]
        end
    end
end
local data,parts={},{}
local function UpdateTooltip(unit,DB,status)
    frame:SetShown(status)
    local isPlayer=UnitIsPlayer(unit)
    local _,classFileName=UnitClass(unit)
    local name=UnitName(unit)
    local tName=UnitName(unit.."target")
    if tName then
        local you=UnitIsUnit(unit.."target","player")
        local color=RAID_CLASS_COLORS[select(2,UnitClass(unit.."target"))] or RAID_CLASS_COLORS["UNKNOWN"]
        target:SetText(you and L.TT_AIMING_YOU or
                sformat(fStr,L.TT_AIMING,color.r*255,color.g*255,color.b*255,tName))
        target:Show()
    else
        target:Hide()
    end
    if DB[1]==1 then
        if UnitIsAFK(unit) then
            parts[#parts+1]=AFK
        end
    end
    if DB[2]==1 then
        if UnitIsDND(unit) then
            parts[#parts+1]=DND
        end
    end
    if DB[3]==1 then
        if UnitIsPVPFreeForAll(unit) then
            pvp:SetTexture("Interface\\AddOns\\Ether\\Media\\UI-PVP-FFA")
            pvp:Show()
        elseif UnitFactionGroup(unit) and UnitIsPVP(unit) then
            pvp:SetTexture("Interface\\AddOns\\Ether\\Media\\UI-PVP-"..UnitFactionGroup(unit))
            pvp:Show()
        else
            pvp:Hide()
        end
    else
        pvp:Hide()
    end
    if DB[6]==1 then
        parts[#parts+1]=tostring(GetLevelColor(UnitLevel(unit)))
    end
    if DB[7]==1 then
        if isPlayer then
            parts[#parts+1]=tostring(GetClassColor(unit))
        end
    end
    if DB[9]==1 then
        parts[#parts+1]=GetUnitRoleString(unit)
    end
    if DB[10]==1 then
        if UnitCreatureType(unit) then
            parts[#parts+1]=UnitCreatureType(unit)
        end
    end
    if DB[11]==1 then
        if UnitRace(unit) then
            parts[#parts+1]=UnitRace(unit)
        end
    end
    if DB[12]==1 then
        local index=GetRaidTargetIndex(unit)
        if index then
            parts[#parts+1]=ICON_LIST[index].."11|t"
        end
    end
    local r,g,b=1,.9,.5
    local c=RAID_CLASS_COLORS[classFileName]
    if c then
        r,g,b=c.r,c.g,c.b
    end
    if DB[13]==1 then
        local reaction=UnitReaction(unit,"player")
        if reaction then
            local f=FACTION_BAR_COLORS[reaction]
            if f then
                r,g,b=f.r,f.g,f.b
            end
        end
    end
    if DB[5]==1 then
        data[#data+1]=F.RGBToHex(r,g,b,name.." - "..GetRealmName())
    else
        data[#data+1]=F.RGBToHex(r,g,b,name)
    end
    if DB[4]==1 then
        if UnitIsUnit(unit,"player") and IsResting() then
            data[#data+1]=C.RestingIcon
        end
    end
    if DB[8]==1 then
        if isPlayer then
            local guildName,guildRankName=GetGuildInfo(unit)
            if guildName then
                data[#data+1]="\n\n"..C.GuildIcon.." "..guildName.." - "..guildRankName or L.TT_UNKNOWN
            end
        end
    end
    info:SetText(tconcat(data,'  '))
    second:SetText(tconcat(parts,' , '))
    table.wipe(data)
    table.wipe(parts)
end
function F:ToolTipInitialize()
    if not frame then return end
    GameTooltip:HookScript("OnTooltipSetUnit",function(self)
        local _,unit=self:GetUnit()
        if not unit then return end
        UpdateTooltip(unit,D.DB[4],UnitExists(unit))
    end)
    GameTooltip:HookScript("OnTooltipCleared",function()
        if D.DB[1][9]~=1 then return end
        frame:SetShown(false)
    end)
end