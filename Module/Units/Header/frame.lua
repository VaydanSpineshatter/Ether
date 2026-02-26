local _,Ether=...
local anchor=CreateFrame("Frame","EtherRaidGroupAnchor",UIParent,"SecureFrameTemplate")
Ether.Anchor.raid=anchor
local UnitExists=UnitExists
local UnitGUID=UnitGUID
local C_After=C_Timer.After
local GameTooltip=GameTooltip
local initialConfigFunction=[[
    local header = self:GetParent()
    self:SetWidth(header:GetAttribute("ButtonWidth"))
    self:SetHeight(header:GetAttribute("ButtonHeight"))
    self:SetAttribute("*type1", "target")
    self:SetAttribute("*type2", "togglemenu")
    self:SetAttribute("isHeaderDriven", true)
    header:CallMethod("CreateChildren", self:GetName())
]]

local function Enter(self)
    if not GameTooltip then
        return
    end
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:SetUnit(self.unit)
    GameTooltip:Show()
end

local function Leave()
    if not GameTooltip then
        return
    end
    GameTooltip:Hide()

end

local function Update(self)
    Ether:UpdateHealth(self)
    Ether:UpdateName(self,true)
    C_After(0.1,function()
        Ether:InitialHealth(self)
    end)
    Ether.Handler:FullUpdate()
end

local function CheckStatus(button)
    button.unit=button:GetAttribute("unit")
    local guid=button.unit and UnitGUID(button.unit)
    if (guid~=button.unitGUID) then
        button.unitGUID=guid
        if guid then
            Update(button)
        end
    end
end

local function Show(self)
    self:RegisterEvent("UNIT_NAME_UPDATE")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    if self.TypePet then
        self:RegisterEvent("UNIT_PET")
    end
    CheckStatus(self)
end

local function Hide(self)
    self:UnregisterEvent("UNIT_NAME_UPDATE")
    self:UnregisterEvent("GROUP_ROSTER_UPDATE")
    if self.TypePet then
        self:UnregisterEvent("UNIT_PET")
    end
    Ether:UpdateDispelBorder(self,{0,0,0,0})
    Ether:UpdatePrediction(self)
end

local function Event(self,event)
    if event=="UNIT_NAME_UPDATE" or event=="UNIT_PET" then
        self.unit=self:GetAttribute("unit")
        if UnitExists(self.unit) then
            Ether:UpdateName(self,true)
        end
    end
end
local function OnAttributeChanged(self,name,unit)
    if not unit or name~="unit" then
        return
    end
    local oldUnit=self.unit
    local newUnit=unit or self:GetAttribute("unit")
    local GUID=UnitGUID(unit)
    if self.unitGUID~=GUID then
        Ether:CleanupAuras(self.unitGUID)
        self.unitGUID=nil
    end
    if oldUnit and oldUnit~=newUnit then
        Ether.unitButtons.raid[oldUnit]=nil
    end
    Ether.unitButtons.raid[newUnit]=self
    if newUnit and UnitExists(newUnit) then
        if Ether.DB[1001][3]==1 then
            C_After(0.3,function()
                if GUID then
                    Ether:UpdateRaidIsHelpful(self,GUID)
                    Ether:UpdateRaidIsHarmful(self,GUID)
                    Ether:UpdateNotActive(self,GUID)
                end
            end)
        end
    end
    self.unit=newUnit
    CheckStatus(self)
end

local function CreateChildren(header,button)
    local b=_G[button]
    b.Indicators={}
    Ether:SetupHealthBar(b,"VERTICAL")
    Ether:SetupPrediction(b)
    Ether:SetupName(b,-5)
    Ether:DispelIconSetup(b)
    Ether:CheckIndicatorsPosition(b)
    Ether:SetupButtonLayout(b)
    if header:GetAttribute("TypePet") then
        b.TypePet=true
    else
        Ether:SetupUpdateText(b,"health")
        Ether:SetupUpdateText(b,"power",true)
        Mixin(b.healthBar,SmoothStatusBarMixin)
        b.Smooth=true
    end
    b:HookScript("OnAttributeChanged",OnAttributeChanged)
    b:SetScript("OnShow",Show)
    b:SetScript("OnHide",Hide)
    b:HookScript("OnEvent",Event)
    b:SetScript("OnEnter",Enter)
    b:SetScript("OnLeave",Leave)
    if not InCombatLockdown() then
        b:RegisterForClicks("AnyUp")
    end
    return b
end

function Ether:CreateGroupHeader()
    local group=CreateFrame("Frame","EtherGroupHeader",anchor,"SecureGroupHeaderTemplate")
    Ether.Header.raid=group
    group:SetPoint("BOTTOM",anchor,"TOP")
    group:SetAttribute("template","EtherUnitTemplate")
    group:SetAttribute("initial-unitWatch",true)
    group:SetAttribute("initialConfigFunction",initialConfigFunction)
    group.CreateChildren=CreateChildren
    group:SetAttribute("ButtonWidth",55)
    group:SetAttribute("ButtonHeight",55)
    group:SetAttribute("columnAnchorPoint","LEFT")
    group:SetAttribute("point","TOP")
    group:SetAttribute("groupBy","GROUP")
    group:SetAttribute("groupingOrder","1,2,3,4,5,6,7,8")
    group:SetAttribute("xOffset",1)
    group:SetAttribute("yOffset",-1)
    group:SetAttribute("columnSpacing",1)
    group:SetAttribute("unitsPerColumn",5)
    group:SetAttribute("maxColumns",8)
    group:SetAttribute("showRaid",true)
    group:SetAttribute("showParty",false)
    group:SetAttribute("showPlayer",false)
    group:SetAttribute("showSolo",true)
    group:Show()

    Ether:SetupBorderLayout(group)
end

function Ether:CreatePetHeader()
    local pet=CreateFrame("Frame","EtherPetGroupHeader",anchor,"SecureGroupPetHeaderTemplate")
    Ether.Header.pet=pet
    pet:SetPoint("BOTTOMLEFT",Ether.Header.raid,"TOPLEFT",0,10)
    pet:SetAttribute("template","EtherUnitTemplate")
    pet:SetAttribute("initialConfigFunction",initialConfigFunction)
    pet.CreateChildren=CreateChildren
    pet:SetAttribute("TypePet",true)
    pet:SetAttribute("ButtonHeight",50)
    pet:SetAttribute("ButtonWidth",50)
    pet:SetAttribute("xOffset",-2)
    pet:SetAttribute("showRaid",true)
    pet:SetAttribute("showParty",false)
    pet:SetAttribute("showPlayer",true)
    pet:SetAttribute("showSolo",true)
    pet:SetAttribute("columnAnchorPoint","LEFT")
    pet:SetAttribute("point","RIGHT")
    pet:SetAttribute("useOwnerUnit",false)
    pet:SetAttribute("filterOnPet",true)
    pet:SetAttribute("unitsPerColumn",10)
    pet:SetAttribute("maxColumns",1)
    pet:Show()
end

function Ether:ChangeDirectionHeader(horizontal)
    if InCombatLockdown() then
        return
    end
    local header=Ether.Header.raid
    if horizontal then
        header:SetAttribute("point","LEFT")
        header:SetAttribute("columnAnchorPoint","TOP")
        header:SetAttribute("xOffset",1)
        header:SetAttribute("yOffset",-1)
        header:SetAttribute("columnSpacing",1)
    else
        header:SetAttribute("columnAnchorPoint","LEFT")
        header:SetAttribute("point","TOP")
        header:SetAttribute("xOffset",1)
        header:SetAttribute("yOffset",-1)
        header:SetAttribute("columnSpacing",1)
    end

    local name=header:GetName().."UnitButton"
    local index=1
    local child=_G[name..index]
    while (child) do
        child:ClearAllPoints()
        index=index+1
        child=_G[name..index]
    end
    if header:IsShown() then
        header:Hide()
        header:Show()
    end
    if Ether.DB[1001][3]==1 then
        Ether:AuraDisable()
        Ether:AuraEnable()
    end
end

function Ether:ResetGroupHeader()
    if InCombatLockdown() then
        return
    end
    local header=Ether.Header.raid
    local name=header:GetName().."UnitButton"
    local index=1
    local child=_G[name..index]
    while (child) do
        child:ClearAllPoints()
        index=index+1
        child=_G[name..index]
    end
    if header:IsShown() then
        header:Hide()
        header:Show()
    end
end

function Ether:ResetPetHeader()
    if InCombatLockdown() then
        return
    end
    local header=Ether.Header.pet
    local name=header:GetName().."UnitButton"
    local index=1
    local child=_G[name..index]
    while (child) do
        child:ClearAllPoints()
        index=index+1
        child=_G[name..index]
    end
    if header:IsShown() then
        header:Hide()
        header:Show()
    end
end


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