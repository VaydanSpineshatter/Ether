local Ether = select(2, ...)
local Tooltip = {}
Ether.Tooltip = Tooltip
local L = Ether.L
local GetG_Info = GetGuildInfo
local RealmName = GetRealmName
local U_N = UnitName
local U_C = UnitClass
local U_L = UnitLevel
local U_GRA = UnitGroupRolesAssigned
local U_IP = UnitIsPlayer
local U_Reaction = UnitReaction
local U_PVP = UnitIsPVP
local U_PVP_A = UnitIsPVPFreeForAll
local IsResting = IsResting
local U_IU = UnitIsUnit
local U_FG = UnitFactionGroup
local U_AFK = UnitIsAFK
local U_DND = UnitIsDND
local GetTargetIndex = GetRaidTargetIndex
local string_format = string.format
local U_RACE = UnitRace
local U_CREATURE = UnitCreatureType
local U_EX = UnitExists
local afk = [[|cE600CCFFAFK|r]]
local dnd = [[|cffCC66FFDND|r]]
local tconcat, tinsert = table.concat, table.insert
local tankIcon = '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:0:19:22:41|t'
local healIcon = '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:20:39:1:20|t'
local damagerIcon = '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:20:39:22:41|t'
local fStr = " %s  |cff%02x%02x%02x%s|r"
local cStr = "|cffffd700%s - %s|r"
local aStr = " |cff%02x%02x%02x%s|r"
local bStr = "|cff%02x%02x%02x%s|r "
local TEMP_CAT = {}

local function GetF_UnitClass(unit)
    local color = RAID_CLASS_COLORS[select(2, U_C(unit))]
    if (color) then
        return string_format(aStr, color.r * 255, color.g * 255, color.b * 255, U_C(unit))
    end
end

local function GetFormattedUnitLevel(unit)
    local diff = GetQuestDifficultyColor(U_L(unit))
    if (U_L(unit) == -1) then
        return '|cffff0000??|r '
    elseif (U_L(unit) == 0) then
        return '? '
    else
        return string_format(bStr, diff.r * 255, diff.g * 255, diff.b * 255, U_L(unit))
    end
end

local function GetUnitRoleString(unit)
    local role = U_GRA(unit)
    local roleList = nil

    if (role == 'TANK') then
        roleList = ' ' .. tankIcon .. ''
    elseif (role == 'HEALER') then
        roleList = ' ' .. healIcon .. ''
    elseif (role == 'DAMAGER') then
        roleList = ' ' .. damagerIcon .. ''
    end
    return roleList
end

local function GetUnitPVPIcon(unit)
    local factionGroup = UnitFactionGroup(unit)

    if (UnitIsPVPFreeForAll(unit)) then
        if (db.showPVPIcons) then
            return '|TInterface\\AddOns\\MyCore\\Media\\UI-PVP-FFA:12|t'
        else
            return '|cffFF0000# |r'
        end
    elseif (factionGroup and UnitIsPVP(unit)) then
        if (db.showPVPIcons) then
            return '|TInterface\\AddOns\\MyCore\\Media\\UI-PVP-' .. factionGroup .. ':12|t'
        else
            return '|cff00FF00# |r'
        end
    else
        return ''
    end
end

local function UpdateTooltip(self, unit)
    if not unit or not U_EX(unit) then
        return
    end

    local DB = Ether.DB[301]
    local name = U_N(unit)
    local isPlayer = U_IP(unit)
    local _, classFileName = U_C(unit)
    local RC = Ether.RAID_COLORS
    local FC = Ether.FACTION_COLORS
    local r, g, b = 1, 1, 1

    local targetName = U_N(unit .. 'target')
    if targetName then
        local you = U_IU(unit .. "target", "player")
        local color = RC[select(2, U_C(unit .. 'target'))] or RC["UNKNOWN"]
        self.target:SetText(you and L.TT_AIMING_YOU or string_format(fStr, L.TT_AIMING, color.r * 255, color.g * 255, color.b * 255, targetName))
        self.target:Show()
    else
        self.target:Hide()
    end

    if (DB[2] == 1 and U_AFK(unit)) then
        self.flags:SetText(afk)
        self.flags:Show()
    elseif (DB[3] == 1 and U_DND(unit)) then
        self.flags:SetText(dnd)
        self.flags:Show()
    else
        self.flags:Hide()
    end

	if DB[4] == 1 and U_PVP_A(unit) then
		self.pvp:SetTexture("Interface\\AddOns\\Ether\\Media\\Graphic\\UI-PVP-FFA")
		self.pvp:Show()
	elseif DB[4] == 1 and U_FG(unit) and U_PVP(unit) then
		self.pvp:SetTexture("Interface\\AddOns\\Ether\\Media\\Graphic\\UI-PVP-" .. U_FG(unit))
		self.pvp:Show()
	else
		self.pvp:Hide()
	end


    if DB[5] == 1 then
        if (U_IU(unit, "player") and IsResting()) then
            self.resting:Show()
        else
            self.resting:Hide()
        end
    end

    if DB[6] == 1 and DB[7] ~= 1 then
        self.name:SetText(string_format("%s - %s", name, RealmName()))
        self.name:SetTextColor(r, g, b)
    elseif DB[7] == 1 and DB[6] ~= 1 then
        self.name:SetText(name)
        self.name:SetTextColor(r, g, b)
    else
        self.name:SetText(name)
    end

    wipe(TEMP_CAT)

    if DB[8] == 1 then
        tinsert(TEMP_CAT, GetFormattedUnitLevel(unit))
    end

    if DB[9] == 1 and U_IP(unit) then
        tinsert(TEMP_CAT, GetF_UnitClass(unit) .. '|r')
    end

    if DB[10] == 1 and isPlayer then
        local guildName, guildRankName = GetG_Info(unit)
        if guildName then
            self.guild:SetText(string_format(cStr, guildName, guildRankName or L.TT_UNKNOWN))
            self.guild:Show()
        else
            self.guild:Hide()

        end
    end

    if DB[11] == 1 then
        tinsert(TEMP_CAT, GetUnitRoleString(unit))
    end

    if (DB[12] == 1 and U_CREATURE(unit)) then
        tinsert(TEMP_CAT, " " .. U_CREATURE(unit))
    end

    if (DB[13] == 1 and U_RACE(unit)) then
        tinsert(TEMP_CAT, " " .. U_RACE(unit))
    end

    if DB[14] == 1 then
        local index = GetTargetIndex(unit)
        if (index) then
            tinsert(TEMP_CAT, ICON_LIST[index] .. "11|t")
        end
    end

    if #TEMP_CAT > 0 then
        local concat = tconcat(TEMP_CAT, ",")
        self.info:SetText(concat)
        self.info:Show()
    else
        self.info:Hide()
    end

    if DB[15] == 1 then
        local reaction = U_Reaction(unit, "player")
        if isPlayer and RC[classFileName] then
            r, g, b = RC[classFileName].r,
            RC[classFileName].g,
            RC[classFileName].b
        elseif reaction then
            r, g, b = FC[reaction].r,
            FC[reaction].g,
            FC[reaction].b
        end
    end
end

local function SetupToolFrame(parent)

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetAllPoints(parent)
    frame:Hide()

    local name = frame:CreateFontString(nil, "OVERLAY")
    frame.name = name
    name:SetFont(unpack(Ether.mediaPath.Font), 13, "OUTLINE")
    name:SetPoint("TOPLEFT", 10, -10)
    name:SetJustifyH("LEFT")

    local guild = frame:CreateFontString(nil, "OVERLAY")
    frame.guild = guild
    guild:SetFont(unpack(Ether.mediaPath.Font), 13, "OUTLINE")
    guild:SetTextColor(1, 1, 1)
    guild:SetShadowColor(0, 0, 0, 0.8)
    guild:SetShadowOffset(1, -1)
    guild:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -5)

    local info = frame:CreateFontString(nil, "OVERLAY")
    frame.info = info
    info:SetFont(unpack(Ether.mediaPath.Font), 13, "OUTLINE")
    info:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -30)

    local flags = frame:CreateFontString(nil, "OVERLAY")
    frame.flags = flags
    flags:SetFont(unpack(Ether.mediaPath.Font), 13, "OUTLINE")
    flags:SetTextColor(1, 1, 1)
    flags:SetShadowColor(0, 0, 0, 0.8)
    flags:SetShadowOffset(1, -1)
    flags:SetPoint("BOTTOMLEFT", name, "TOPLEFT", 0, 5)
    flags:SetJustifyH("RIGHT")

    local pvp = frame:CreateTexture(nil, "ARTWORK")
    frame.pvp = pvp
    pvp:SetSize(18, 18)
    pvp:SetPoint("RIGHT", name, "LEFT", -5, 0)

    local resting = frame:CreateTexture(nil, "ARTWORK")
    frame.resting = resting
    resting:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
    resting:SetTexCoord(0.0625, 0.45, 0.0625, 0.45)
    resting:SetSize(18, 18)
    resting:SetPoint("RIGHT", name, "LEFT", -5, 20)

    local target = frame:CreateFontString(nil, "OVERLAY")
    frame.target = target
    target:SetFont(unpack(Ether.mediaPath.Font), 13, "OUTLINE")
    target:SetPoint("LEFT", name, "RIGHT", 0, 0)
    target:SetJustifyH("CENTER")

    return frame
end

local function SetupHooks()
    local anchor = Ether.Anchor.tooltip
    if anchor then
        anchor = SetupToolFrame(anchor)
    else
        return
    end

    GameTooltip:HookScript("OnTooltipSetUnit", function(self)
        local _, unit = self:GetUnit()
        if unit then
            if not anchor:IsShown() then
                anchor:Show()
            end
            UpdateTooltip(anchor, unit)
        end
    end)

    GameTooltip:HookScript("OnTooltipCleared", function()
        if anchor:IsShown() then
            anchor:Hide()
        end
    end)

end

function Tooltip:Initialize()
    SetupHooks()
end




