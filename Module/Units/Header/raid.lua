local _, Ether = ...

local anchor = CreateFrame("Frame", "EtherRaidGroupAnchor", UIParent, "SecureFrameTemplate")
Ether.Anchor.raid = anchor
local header = CreateFrame("Frame", "EtherRaidGroupHeader", anchor, "SecureGroupHeaderTemplate")
Ether.Header.raid = header

local __SECURE_INITIALIZE = [[
    RegisterUnitWatch(self)
    local header = self:GetParent()
    self:SetAttribute("*type1", "target")
	self:SetAttribute("*type2", "togglemenu")
    self:SetWidth(header:GetAttribute("ButtonWidth"))
	self:SetHeight(header:GetAttribute("ButtonHeight"))
	header:CallMethod("initialConfigFunction", self:GetName())
	local unit = self:GetAttribute("unit")
   ]]

local function OnEnter(self)
    if not GameTooltip then
        return
    end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetUnit(self.unit)
    GameTooltip:Show()
end
Ether.OnEnter = OnEnter

local function OnLeave()
    if not GameTooltip then
        return
    end
    GameTooltip:Hide()
end
Ether.OnLeave = OnLeave

local function InitialUpdate(self)
    Ether.InitialHealth(self)
    Ether.UpdateHealthAndMax(self)
    if Ether.DB[701][5] == 1 then
        Ether.UpdateHealthText(self)
    end
    if Ether.DB[701][6] == 1 then
        Ether.UpdatePowerText(self)
    end
    Ether.UpdateName(self, true)

end

local function Show(self)
    self.unit = self:GetAttribute("unit")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("UNIT_NAME_UPDATE")
    InitialUpdate(self)
    Ether.Aura.UpdateUnitAuras(self)
end

local function Hide(self)
    self:UnregisterEvent("GROUP_ROSTER_UPDATE")
    self:UnregisterEvent("UNIT_NAME_UPDATE")
end

local function OnAttributeChanged(self, name, unit)
    if (name ~= "unit" or not unit) then
        return
    end

    local oldUnit = self.unit
    local newUnit = unit or self:GetAttribute("unit")
    local newGuid = newUnit and UnitGUID(newUnit)

    if newGuid ~= self.unitGUID then
        if oldUnit then
            Ether.unitButtons.raid[oldUnit] = nil
        end

        self.unit = newUnit
        self.unitGUID = newGuid

        if newUnit then
            Ether.unitButtons.raid[newUnit] = self
        end

        if newUnit and UnitExists(newUnit) then
            InitialUpdate(self)
            Ether:UpdateIndicators()
            if Ether.DB[1002][3] == 1 then
                C_Timer.After(0.1, function()
                    Ether.Aura.UpdateUnitAuras(self)
                end)
            end
        end
    end
end

local function Event(self, event, unit)
    self.unit = self:GetAttribute("unit")
    if self.unit ~= unit then
        return
    end
    if event == "GROUP_ROSTER_UPDATE" then
        local currentUnit = self:GetAttribute("unit")
        if currentUnit ~= unit then
            OnAttributeChanged(self, "unit", currentUnit)
        end
    elseif event == "UNIT_NAME_UPDATE" then
        Ether.UpdateName(self, true)
    end
end

local function initialConfigFunction(headerName, buttonName)
    local b = _G[buttonName]
    b.Indicators = {}
    b.raidAuras = {}
    b.raidIcons = {}
    b:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground"})
    b:SetBackdropColor(0, 0, 0, 1)
    Ether.AddBlackBorder(b)
    local healthBar = CreateFrame("StatusBar", nil, b)
    b.healthBar = healthBar
    healthBar:SetPoint("TOPLEFT")
    healthBar:SetAllPoints(b)
    healthBar:SetOrientation("VERTICAL")
    healthBar:SetStatusBarTexture(unpack(Ether.mediaPath.StatusBar))
    healthBar:SetMinMaxValues(0, 100)
    healthBar:SetFrameLevel(b:GetFrameLevel() + 1)
    Mixin(healthBar, SmoothStatusBarMixin)
    local healthDrop = b:CreateTexture(nil, "ARTWORK", nil, -7)
    b.healthDrop = healthDrop
    healthDrop:SetAllPoints(healthBar)
    healthBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -7)
    Ether.Setup.CreatePrediction(b)
    Ether.Setup.CreateNameText(b, 10, -5)
    Ether.GetClassColor(b)
    Ether.Setup.CreatePowerText(b)
    Ether.Setup.CreateHealthText(b)
    local highlight = b:CreateTexture(nil, "HIGHLIGHT")
    b.highlight = highlight
    highlight:SetAllPoints()
    highlight:SetColorTexture(0.80, 0.40, 1.00, .2)
    local background = b:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0, 0, 0, 1)
    b:RegisterForClicks("AnyUp")
    b:SetScript("OnShow", Show)
    b:SetScript("OnHide", Hide)
    b:SetScript("OnEnter", OnEnter)
    b:SetScript("OnLeave", OnLeave)
    b:SetScript("OnEvent", Event)
    b:HookScript("OnAttributeChanged", OnAttributeChanged)
    Ether.unitButtons.raid[buttonName] = b
    return b
end

local function CreateHeader()
    header:SetPoint("TOPLEFT")
    header:SetParent(anchor)
    header:SetAttribute("template", "EtherUnitTemplate")
    header:SetAttribute("initialConfigFunction", __SECURE_INITIALIZE)
    header.initialConfigFunction = initialConfigFunction
    header:SetAttribute("ButtonWidth", 55)
    header:SetAttribute("ButtonHeight", 55)
    header:SetAttribute("columnAnchorPoint", "LEFT")
    header:SetAttribute("point", "TOP")
    header:SetAttribute("groupBy", "GROUP")
    header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
    header:SetAttribute("xOffset", 1)
    header:SetAttribute("yOffset", -1)
    header:SetAttribute("columnSpacing", 1)
    header:SetAttribute("unitsPerColumn", 5)
    header:SetAttribute("maxColumns", 8)
    header:SetAttribute("showRaid", true)
    header:SetAttribute("showParty", false)
    header:SetAttribute("showPlayer", false)
    header:SetAttribute("showSolo", false)
    RegisterAttributeDriver(header, "state-visibility", "[@raid1,exists] show; hide")
end

local state = false
function Ether:CreateRaidHeader()
    if InCombatLockdown() then
        return
    end
    if not state then
        state = true
        CreateHeader()
    end
end


--[[

--> -->
order = 'DRUID,PRIEST,HUNTER,MAGE,PALADIN,ROGUE,SHAMAN,WARLOCK,WARRIOR',
by = 'CLASS'
order = 'TANK,HEALER,DAMAGER,NONE',
by = 'ASSIGNEDROLE'
order = '1,2,3,4,5,6,7,8',
by = "GROUP"
<-- <--

--> -->
Header: SecureGroupHeaderTemplate, SecureGroupPetHeaderTemplate
<-- <--

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