local _, Ether = ...

local anchor = CreateFrame("Frame", "EtherRaidGroupAnchor", UIParent, "SecureFrameTemplate")
Ether.Anchor.raid = anchor
if InCombatLockdown() then
    print("User in combat lockdown - Reload interface")
    return
end
local header = CreateFrame("Frame", "EtherRaidGroupHeader", anchor, "SecureGroupHeaderTemplate")
Ether.Header.raid = header

--local secureHandler = CreateFrame("Frame", nil, nil, "SecureHandlerBaseTemplate")
--secureHandler:WrapScript(header, "OnAttributeChanged", [[
--]])


local function OnEnter(self)
    self.unit = self:GetAttribute("unit")
    if GameTooltip then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetUnit(self.unit)
        GameTooltip:Show()
    end
end

local function OnLeave(self)
    self.unit = self:GetAttribute("unit")
    if GameTooltip then
        GameTooltip:Hide()
    end
end

local function Update(self)
    self.unit = self:GetAttribute("unit")
    Ether:UpdateHealth(self)
    Ether:UpdateName(self, true)
    C_Timer.After(0.1, function()
        Ether:InitialHealth(self)
    end)
end


local function OnAttributeChanged(self, name, unit)
    if name ~= "unit" or not unit then
        return
    end

    local oldUnit = self.unit
    local oldGUID = self.unitGUID
    local newGUID = UnitGUID(unit)


    if oldGUID and newGUID and oldGUID ~= newGUID then
        self.top:SetColorTexture(0, 0, 0, .6)
        self.right:SetColorTexture(0, 0, 0, .6)
        self.left:SetColorTexture(0, 0, 0, .6)
        self.bottom:SetColorTexture(0, 0, 0, .6)
        Ether:CleanupIconsForGUID(oldGUID)
    end

    self.unit = unit
    self.unitGUID = newGUID

    if oldUnit and Ether.unitButtons.raid[oldUnit] == self then
        Ether.unitButtons.raid[oldUnit] = nil
    end
    Ether.unitButtons.raid[unit] = self

    C_Timer.After(0.1, function()
        if self.unit == unit then
            Ether:UpdateRaidIsHelpful(unit)
            Ether:DispelAuraScan(unit)
        end
    end)
    Update(self)
end

local function Show(self)
    self:RegisterEvent("UNIT_NAME_UPDATE")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    Update(self)
end

local function Hide(self)
    self:UnregisterEvent("UNIT_NAME_UPDATE")
    self:UnregisterEvent("GROUP_ROSTER_UPDATE")
end

function header:CreateChildren(buttonName)
    local button = _G[buttonName]
    button.Indicators = {}
    button.raidAuras = {}
    button.raidIcons = {}
    Ether:AddBlackBorder(button)
    local healthBar = CreateFrame("StatusBar", nil, button)
    button.healthBar = healthBar
    healthBar:SetPoint("TOPLEFT")
    healthBar:SetAllPoints(button)
    healthBar:SetOrientation("VERTICAL")
    healthBar:SetStatusBarTexture(unpack(Ether.mediaPath.statusBar))
    healthBar:SetMinMaxValues(0, 100)
    healthBar:SetFrameLevel(button:GetFrameLevel() + 1)
    Mixin(healthBar, SmoothStatusBarMixin)
    local healthDrop = button:CreateTexture(nil, "ARTWORK", nil, -7)
    button.healthDrop = healthDrop
    healthDrop:SetAllPoints(healthBar)
    healthBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -7)
    Ether:SetupPrediction(button)
    Ether:SetupName(button, 10, -5)
    Ether:GetClassColor(button)
    Ether:SetupPowerText(button)
    Ether:SetupHealthText(button)
    button:SetScript("OnShow", Show)
    button:SetScript("OnHide", Hide)
    button:SetScript("OnEnter", OnEnter)
    button:SetScript("OnLeave", OnLeave)
    button:HookScript("OnAttributeChanged", OnAttributeChanged)
    button:RegisterForClicks("AnyUp")
    return button
end

header:SetAllPoints(anchor)
header:SetAttribute("template", "EtherUnitTemplate")
header:SetAttribute("initial-unitWatch", true)
header:SetAttribute("groupingFilter", "1,2,3,4,5,6,7,8")
header:SetAttribute("initialConfigFunction", [[
    local header = self:GetParent()
    self:SetWidth(header:GetAttribute("ButtonWidth"))
    self:SetHeight(header:GetAttribute("ButtonHeight"))
    self:SetAttribute("*type1", "target")
    self:SetAttribute("*type2", "togglemenu")
    self:SetAttribute("isHeaderDriven", true)
    header:CallMethod("CreateChildren", self:GetName())
   ]])

header:SetAttribute("ButtonWidth", 55)
header:SetAttribute("ButtonHeight", 55)
header:SetAttribute("columnAnchorPoint", "LEFT")
header:SetAttribute("point", "TOP")
header:SetAttribute("groupBy", "GROUP")
header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
header:SetAttribute("xOffset", 1)
header:SetAttribute("yOffset", -3)
header:SetAttribute("columnSpacing", 3)
header:SetAttribute("unitsPerColumn", 5)
header:SetAttribute("maxColumns", 8)
header:SetAttribute("showRaid", true)
header:SetAttribute("showParty", false)
header:SetAttribute("showPlayer", false)
header:SetAttribute("showSolo", true)
header:Show()


--[[
order = 'DRUID,PRIEST,HUNTER,MAGE,PALADIN,ROGUE,SHAMAN,WARLOCK,WARRIOR',
by = 'CLASS'
order = 'TANK,HEALER,DAMAGER,NONE',
by = 'ASSIGNEDROLE'
order = '1,2,3,4,5,6,7,8',
by = "GROUP"
Header: SecureGroupHeaderTemplate, SecureGroupPetHeaderTemplate
useOwnerUnit = [BOOLEAN]
filterOnPet = [BOOLEAN]
showRaid = [BOOLEAN] -- true if the header should be shown while in a raid
showParty = [BOOLEAN] -- true if the header should be shown while in a party and not in a raid
showPlayer = [BOOLEAN] -- true if the header should show the player when not in a raid
showSolo = [BOOLEAN] -- true if the header should be shown while not in a group (implies showPlayer)
nameList = [STRING] -- a comma separated list of player names (not used if 'groupFilter' is set)
groupFilter = [1-8, STRING] -- a comma separated list of raid group numbers and/or uppercase class names and/or uppercase roles
roleFilter = [STRING] -- a comma separated list of MT/MA/Tank/Healer/DPS role strings
strictFiltering = [BOOLEAN]
-- if true, then
---- if only groupFilter is specified then characters must match both a group and a class from the groupFilter list
---- if only roleFilter is specified then characters must match at least one of the specified roles
---- if both groupFilter and roleFilters are specified then characters must match a group and a class from the groupFilter list and a role from the roleFilter list
point = [STRING] -- a valid XML anchoring point (Default: "TOP")
xOffset = [NUMBER] -- the x-Offset to use when anchoring the unit buttons (Default: 0)
yOffset = [NUMBER] -- the y-Offset to use when anchoring the unit buttons (Default: 0)
sortMethod = ["INDEX", "NAME", "NAMELIST"] -- defines how the group is sorted (Default: "INDEX")
sortDir = ["ASC", "DESC"] -- defines the sort order (Default: "ASC")
template = [STRING] -- the XML template to use for the unit buttons
templateType = [STRING] - specifies the frame type of the managed subframes (Default: "Button")
groupBy = [nil, "GROUP", "CLASS", "ROLE", "ASSIGNEDROLE"] - specifies a "grouping" type to apply before regular sorting (Default: nil)
groupingOrder = [STRING] - specifies the order of the groupings (ie. "1,2,3,4,5,6,7,8")
maxColumns = [NUMBER] - maximum number of columns the header will create (Default: 1)
unitsPerColumn = [NUMBER or nil] - maximum units that will be displayed in a singe column, nil is infinite (Default: nil)
startingIndex = [NUMBER] - the index in the final sorted unit list at which to start displaying units (Default: 1)
columnSpacing = [NUMBER] - the amount of space between the rows/columns (Default: 0)
columnAnchorPoint = [STRING] - the anchor point of each new column (ie. use LEFT for the columns to grow to the right)
]]