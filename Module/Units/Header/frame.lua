local _, Ether = ...

local raidAnchor = CreateFrame("Frame", "EtherRaidGroupAnchor", UIParent, "SecureFrameTemplate")
Ether.Anchor.raid = raidAnchor
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local C_After = C_Timer.After
local GameTooltip = GameTooltip
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
    C_After(0.1, function()
        Ether:InitialHealth(self)
    end)
end

local function OnAttributeChanged(self, name, unit)
    if name ~= "unit" or not unit then
        return
    end

    local oldUnit = self.unit
    local oldGUID = self.unitGUID
    local newUnit = unit or self:GetAttribute("unit")
    local newGUID = UnitGUID(unit)
    if newGUID and oldGUID ~= newGUID then
        oldGUID = newGUID
        Ether:CleanupAuras(oldGUID)
    end
    if oldUnit and oldUnit ~= newUnit then
        Ether.unitButtons.raid[oldUnit] = nil
    end
    Ether.unitButtons.raid[newUnit] = self
    if newUnit and UnitExists(newUnit) then
        if Ether.DB[1001][3] == 1 then
            C_After(0.3, function()
                if newGUID then
                    Ether:UpdateRaidIsHelpful(self, newGUID)
                    Ether:UpdateRaidIsHarmful(self, newGUID)
                end
            end)
        end
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
    local width = headerName:GetAttribute("ButtonWidth")
    local height = headerName:GetAttribute("ButtonHeight")
    button.Indicators = {}
    Ether:SetupHealthBar(button, "VERTICAL", width, height)
    Ether:SetupPrediction(button)
    Ether:SetupName(button, -5)
    Ether:GetClassColor(button)
    Ether:DispelIconSetup(button)
    Ether:DispelNameSetup(button, 0, 0, 0, 0)
    button:SetBackdrop({
        bgFile = Ether.DB[811]["background"],
        insets = {left = -2, right = -2, top = -2, bottom = -2}
    })
    button.Indicators.PlayerFlags = button.healthBar:CreateFontString(nil, "OVERLAY")
    button.Indicators.PlayerFlags:SetFont(unpack(Ether.mediaPath.expressway), 14, "OUTLINE")
    button.Indicators.UnitFlags = button.healthBar:CreateTexture(nil, "OVERLAY")
    button.Indicators.ReadyCheck = button.healthBar:CreateTexture(nil, "OVERLAY")
    button.Indicators.Connection = button.healthBar:CreateTexture(nil, "OVERLAY")
    button.Indicators.Resurrection = button.healthBar:CreateTexture(nil, "OVERLAY")
    button.Indicators.RaidTarget = button.healthBar:CreateTexture(nil, "OVERLAY")
    button.Indicators.MasterLoot = button.healthBar:CreateTexture(nil, "OVERLAY")
    button.Indicators.GroupLeader = button.healthBar:CreateTexture(nil, "OVERLAY")
    button.Indicators.PlayerRoles = button.healthBar:CreateTexture(nil, "OVERLAY")
    if headerName:GetAttribute("TypePet") then
        button.TypePet = true
    else
        Ether:SetupUpdateText(button, "health")
        Ether:SetupUpdateText(button, "power", true)
        Mixin(button.healthBar, SmoothStatusBarMixin)
        button.Smooth = true
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
--[[

local function CreateHeaders(type)
end
local function AttributeHeaders(type, Attribute)
end
local function PositionHeaders(type, Position)
end
]]
local function CreateGroupHeader()
    local header = CreateFrame("Frame", "EtherRaidGroupHeader", raidAnchor, "SecureGroupHeaderTemplate")
    Ether.Header.raid = header
    header:SetPoint("RIGHT", raidAnchor, "RIGHT")
    header:SetAttribute("template", "EtherUnitTemplate")
    header:SetAttribute("initial-unitWatch", true)
    header:SetAttribute("initialConfigFunction", initialConfigFunction)
    header.CreateChildren = CreateChildren
    header:SetAttribute("ButtonWidth", 55)
    header:SetAttribute("ButtonHeight", 55)
    header:SetAttribute("columnAnchorPoint", "LEFT")
    header:SetAttribute("point", "BOTTOM")
    header:SetAttribute("groupBy", "GROUP")
    header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
    header:SetAttribute("xOffset", 5)
    header:SetAttribute("yOffset", 4)
    header:SetAttribute("columnSpacing", 4)
    header:SetAttribute("unitsPerColumn", 5)
    header:SetAttribute("maxColumns", 8)
    header:SetAttribute("raidHeader", true)
    header:SetAttribute("showRaid", true)
    header:SetAttribute("showParty", true)
    header:SetAttribute("showPlayer", true)
    header:SetAttribute("showSolo", true)
    header:Show()
end

function Ether:CreateSplitGroupHeader()
    if InCombatLockdown() then return end
    CreateGroupHeader()
end

function Ether:InitializePetHeader()
    if _G["EtherRaidGroupHeader"] and not InCombatLockdown() then
        local pet = CreateFrame("Frame", "EtherPetGroupHeader", raidAnchor, "SecureGroupPetHeaderTemplate")
        Ether.Header.pet = pet
        pet:SetPoint("BOTTOMLEFT", Ether.Header.raid, "TOPLEFT", 0, 10)
        pet:SetAttribute("template", "EtherUnitTemplate")
        pet:SetAttribute("initialConfigFunction", initialConfigFunction)
        pet.CreateChildren = CreateChildren
        pet:SetAttribute("TypePet", true)
        pet:SetAttribute("ButtonHeight", 50)
        pet:SetAttribute("ButtonWidth", 50)
        pet:SetAttribute("xOffset", -2)
        pet:SetAttribute("showRaid", true)
        pet:SetAttribute("showParty", true)
        pet:SetAttribute("showPlayer", true)
        pet:SetAttribute("showSolo", true)
        pet:SetAttribute("columnAnchorPoint", "LEFT")
        pet:SetAttribute("point", "RIGHT")
        pet:SetAttribute("useOwnerUnit", false)
        pet:SetAttribute("filterOnPet", true)
        pet:SetAttribute("unitsPerColumn", 10)
        pet:SetAttribute("maxColumns", 1)
        pet:Show()
    end
end

function Ether:RepositionHeaders()
    if true then return end
end

local function ResetChildren()
    if InCombatLockdown() then return end
    local name = Ether.Header.raid:GetName() .. "UnitButton"
    local index = 1
    local child = _G[name .. index]
    while (child) do
        child:ClearAllPoints()
        index = index + 1
        child = _G[name .. index]
    end
    if Ether.Header.raid:IsShown() then
        Ether.Header.raid:Hide()
        Ether.Header.raid:Show()
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