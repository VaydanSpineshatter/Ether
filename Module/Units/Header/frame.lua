local _, Ether = ...

local raidAnchor = CreateFrame("Frame", "EtherRaidGroupAnchor", UIParent, "SecureFrameTemplate")
Ether.Anchor.raid = raidAnchor

if InCombatLockdown() then
    if Ether.DebugOutput then
        Ether.DebugOutput("Users in combat lockdown – Reload interface outside of combat")
    else
        print("Users in combat lockdown – Reload interface outside of combat")
    end
    return
end

local initialConfigFunction = [[
    local header = self:GetParent()
    self:SetWidth(header:GetAttribute("ButtonWidth"))
    self:SetHeight(header:GetAttribute("ButtonHeight"))
    self:SetAttribute("*type1", "target")
    self:SetAttribute("*type2", "togglemenu")
    self:SetAttribute("isHeaderDriven", true)
    header:CallMethod("CreateChildren", self:GetName())
]]

local function OnEnter(self)
    self.unit = self:GetAttribute("unit")
    if GameTooltip then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetUnit(self.unit)
        GameTooltip:Show()
    end
end

local function OnLeave()
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
        Ether:CleanupAuras(oldGUID, oldUnit)
    end

    self.unit = unit
    self.unitGUID = newGUID

    if oldUnit and Ether.unitButtons.raid[oldUnit] == self then
        Ether.unitButtons.raid[oldUnit] = nil
    end
    Ether.unitButtons.raid[unit] = self
    if self.unit == unit and UnitExists(unit) then
        if Ether.DB and Ether.DB[1001] and Ether.DB[1001][3] == 1 then
            Ether:UpdateRaidIsHelpful(unit, true)
            Ether:UpdateRaidIsHarmful(unit, true)
        end
    end
    if Ether.DB and Ether.DB[401] and Ether.DB[401][6] == 1 then
        Ether:IndicatorsUnitUpdate(unit)
    end
    Update(self)
end

local function Show(self)
    self:RegisterEvent("UNIT_NAME_UPDATE")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    if self.TypePet then
        self:RegisterEvent("UNIT_PET")
    end
    Update(self)
end

local function Hide(self)
    self:UnregisterEvent("UNIT_NAME_UPDATE")
    self:UnregisterEvent("GROUP_ROSTER_UPDATE")
    if self.TypePet then
        self:UnregisterEvent("UNIT_PET")
    end
end

local function CreateChildren(headerName, buttonName)
    local button = _G[buttonName]
    Ether:AddBlackBorder(button, 1, 0, 0, 0, 1)
    local w = headerName:GetAttribute("ButtonWidth")
    local h = headerName:GetAttribute("ButtonHeight")
    Ether:SetupHealthBar(button, "VERTICAL", w, h)
    Ether:SetupPrediction(button)
    Ether:SetupName(button, -5)
    Ether:GetClassColor(button)
    button:SetBackdrop({
        bgFile = Ether.DB[811]["background"],
        edgeFile = Ether.DB[811]["border"],
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = -2, right = -2, top = -2, bottom = -2}
    })
    button:SetBackdropColor(0.1, 0.1, 0.1, .9)
    button:SetBackdropBorderColor(0.4, 0.4, 0.4)
    if headerName:GetAttribute("TypePet") then
        button.TypePet = true
    else
        Ether:SetupUpdateText(button, "health")
        Ether:SetupUpdateText(button, "power", true)
        Ether:DispelIconSetup(button)
        Mixin(button.healthBar, SmoothStatusBarMixin)
        button.Indicators = {}
        button.Smooth = true
        button.Indicators.PlayerFlags = button.healthBar:CreateFontString(nil, "OVERLAY")
        button.Indicators.PlayerFlags:SetFont(unpack(Ether.mediaPath.expressway), 10, "OUTLINE")
        button.Indicators.UnitFlags = button.healthBar:CreateTexture(nil, "OVERLAY")
        button.Indicators.ReadyCheck = button.healthBar:CreateTexture(nil, "OVERLAY")
        button.Indicators.Connection = button.healthBar:CreateTexture(nil, "OVERLAY")
        button.Indicators.Resurrection = button.healthBar:CreateTexture(nil, "OVERLAY")
        button.Indicators.RaidTarget = button.healthBar:CreateTexture(nil, "OVERLAY")
        button.Indicators.MasterLoot = button.healthBar:CreateTexture(nil, "OVERLAY")
        button.Indicators.GroupLeader = button.healthBar:CreateTexture(nil, "OVERLAY")
        button.Indicators.PlayerRoles = button.healthBar:CreateTexture(nil, "OVERLAY")
    end
    button:SetScript("OnShow", Show)
    button:SetScript("OnHide", Hide)
    button:SetScript("OnEnter", OnEnter)
    button:SetScript("OnLeave", OnLeave)
    button:HookScript("OnAttributeChanged", OnAttributeChanged)
    if not InCombatLockdown() then
        button:RegisterForClicks("AnyUp")
    end
    return button
end

local groupHeaders = {}
local function CreateGroupHeader(group)
    local headerName = "EtherRaidGroupHeader" .. group
    local header = CreateFrame("Frame", headerName, raidAnchor, "SecureGroupHeaderTemplate")
    groupHeaders[group] = header
    Ether.Header.raid = header
    header:SetAllPoints(raidAnchor)
    header:SetAttribute("template", "EtherUnitTemplate")
    header:SetAttribute("initial-unitWatch", true)
    header:SetAttribute("groupFilter", group)
    header:SetAttribute("initialConfigFunction", initialConfigFunction)
    header.CreateChildren = CreateChildren
    header:SetAttribute("ButtonWidth", 55)
    header:SetAttribute("ButtonHeight", 55)
    header:SetAttribute("columnAnchorPoint", "LEFT")
    header:SetAttribute("point", "TOP")
    header:SetAttribute("groupBy", "GROUP")
    header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
    header:SetAttribute("xOffset", 0)
    header:SetAttribute("yOffset", -3)
    header:SetAttribute("columnSpacing", 3)
    header:SetAttribute("unitsPerColumn", 5)
    header:SetAttribute("maxColumns", 1)
    header:SetAttribute("raidHeader", true)
    header:SetAttribute("showRaid", true)
    header:SetAttribute("showParty", true)
    header:SetAttribute("showPlayer", true)
    header:SetAttribute("showSolo", true)
    header:Show()
end

function Ether:CreateSplitGroupHeader(number)
    if InCombatLockdown() then return end
    if type(number) ~= "number" then return end
    for i = 1, number do
        CreateGroupHeader(i)
    end
end

function Ether:InitializePetHeader()
    if _G["EtherRaidGroupHeader1"] and not InCombatLockdown() then
        local raidpet = CreateFrame("Frame", "EtherPetGroupHeader", raidAnchor, "SecureGroupPetHeaderTemplate")
        Ether.Header.raidpet = raidpet
        raidpet:SetPoint("BOTTOMLEFT", groupHeaders[1], "TOPLEFT", 0, 10)
        raidpet:SetAttribute("template", "EtherUnitTemplate")
        raidpet:SetAttribute("initialConfigFunction", initialConfigFunction)
        raidpet.CreateChildren = CreateChildren
        raidpet:SetAttribute("TypePet", true)
        raidpet:SetAttribute("ButtonHeight", 50)
        raidpet:SetAttribute("ButtonWidth", 50)
        raidpet:SetAttribute("xOffset", -2)
        raidpet:SetAttribute("showRaid", true)
        raidpet:SetAttribute("showParty", true)
        raidpet:SetAttribute("showPlayer", true)
        raidpet:SetAttribute("showSolo", true)
        raidpet:SetAttribute("columnAnchorPoint", "LEFT")
        raidpet:SetAttribute("point", "RIGHT")
        raidpet:SetAttribute("useOwnerUnit", false)
        raidpet:SetAttribute("filterOnPet", true)
        raidpet:SetAttribute("unitsPerColumn", 10)
        raidpet:SetAttribute("maxColumns", 1)
        raidpet:Show()
    end
end

function Ether:RepositionHeaders()
    if InCombatLockdown() then return end
    local spacing = Ether.Header.raid:GetAttribute("columnSpacing")
    local lastHeader = nil
    for i = 1, 8 do
        if not lastHeader then
            groupHeaders[i]:ClearAllPoints()
            groupHeaders[i]:SetPoint("TOPLEFT", Ether.Anchor.raid, "TOPLEFT")
        else
            groupHeaders[i]:ClearAllPoints()
            groupHeaders[i]:SetPoint("TOPLEFT", lastHeader, "TOPRIGHT", spacing, 0)
        end
        lastHeader = groupHeaders[i]
    end
end

local function ResetChildren()
    if InCombatLockdown() then return end
    for i = 1, 8 do
        local name = groupHeaders[i]:GetName() .. "UnitButton"
        local index = 1
        local child = _G[name .. index]
        while (child) do
            child:ClearAllPoints()
            index = index + 1
            child = _G[name .. index]
        end
        if groupHeaders[i]:IsShown() then
            groupHeaders[i]:Hide()
            groupHeaders[i]:Show()
        end
    end
end

Ether.RegisterCallback("RESET_CHILDREN", "ResetChildren", ResetChildren)

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