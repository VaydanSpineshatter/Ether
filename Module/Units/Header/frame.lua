local _,Ether=...
local raid=CreateFrame("Frame","EtherRaidGroupAnchor",UIParent,"SecureFrameTemplate")
Ether.Anchor.raid=raid
local pet=CreateFrame("Frame","EtherPetGroupAnchor",UIParent,"SecureFrameTemplate")
Ether.Anchor.pet=pet
local UnitExists=UnitExists
local UnitGUID=UnitGUID
local GameTooltip=GameTooltip
local raidButtons={}
Ether.raidButtons=raidButtons
local guidData={}
Ether.guidData=guidData
local C_After=C_Timer.After

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
    Ether:UpdateName(self,3)
    Ether:InitialHealth(self)
    Ether:UpdateClassColor(self)
    Ether:InitialIndicatorsPosition()
    Ether:IndicatorsFullUpdate()
end

local function CheckStatus(self)
    self.unit=self:GetAttribute("unit")
    local guid=self.unit and UnitGUID(self.unit)
    if (guid~=self.destGUID) then
        self.destGUID=guid
        if guid then
            Update(self)
            if UnitExists(self.unit) then
                C_After(2,function()
                    Ether:RaidAurasFullUpdate(self,guid)
                    Ether:SavePosition(self)
                end)
            end
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
    if self.destGUID then
        if UnitExists(self.unit) then
            Ether.Fire("UNIT_IS_DEAD",self.unit)
        end
        C_After(0.3,function()
            Ether.CheckOldGUID(self.destGUID)
        end)
    end
end

local function OnAttributeChanged(self,name,unit)
    if not unit or name~="unit" then
        return
    end
    local oldUnit=self.unit
    local newUnit=unit or self:GetAttribute("unit")
    if oldUnit and oldUnit~=newUnit then
        raidButtons[oldUnit]=nil
    end
    if newUnit then
        raidButtons[newUnit]=self
    end
    CheckStatus(self)
end

local function CreateChildren(header,button)
    local b=_G[button]
    b.Indicators={}
    b.Dispel={}
    Ether:SetupButtonLayout(b)
    Ether:SetupHealthBar(b,"VERTICAL")
    if header:GetAttribute("TypePet") then
        b.TypePet=true
    end
    Ether:SetupPrediction(b)
    Ether:SetupName(b,-5)
    Ether:DispelIconSetup(b)
    Ether.SetupDispelAuraButton(b)
    b:HookScript("OnAttributeChanged",OnAttributeChanged)
    b:SetScript("OnShow",Show)
    b:SetScript("OnHide",Hide)
    b:SetScript("OnEnter",Enter)
    b:SetScript("OnLeave",Leave)
    if Ether.SavePosition then
        Ether:SavePosition(b)
    end
    if not InCombatLockdown() then
        b:RegisterForClicks("AnyUp")
    end
    return b
end

local Sort={"GROUP","CLASS","ASSIGNEDROLE"}
local group={"1,2,3,4,5,6,7,8"}
local class={"DRUID,PRIEST,HUNTER,MAGE,PALADIN,ROGUE,SHAMAN,WARLOCK,WARRIOR"}
local assigned = {"TANK,HEALER,DAMAGER,NONE"}
local function OrderMethod(string)
    if not string or type(string)~="string" then return end
    local sort,data
    if string=="GROUP" then
        sort,data="GROUP",group
    elseif string=="CLASS" then
        sort,data="CLASS",class
    elseif string=="ASSIGNEDROLE" then
        sort,data="ASSIGNEDROLE",assigned
    end
    return sort,data
end

function Ether:CreateGroupHeader()
    local DB=Ether.DB
    local data=DB[21][10]
    local by,order = OrderMethod(Sort[DB[100][9]])
    local header=CreateFrame("Frame","EtherGroupHeader",raid,"SecureGroupHeaderTemplate")
    Ether.Header.raid=header
    header:SetPoint("BOTTOM",raid,"TOP")
    header:SetAttribute("template","EtherUnitTemplate")
    header:SetAttribute("initial-unitWatch",true)
    header:SetAttribute("initialConfigFunction",initialConfigFunction)
    header.CreateChildren=CreateChildren
    header:SetAttribute("ButtonWidth",data[6] or 55)
    header:SetAttribute("ButtonHeight",data[7] or 55)
    header:SetAttribute("columnAnchorPoint","LEFT")
    header:SetAttribute("point","TOP")
    header:SetAttribute("groupBy",by or "GROUP")
    header:SetAttribute("groupingOrder",unpack(order) or "1,2,3,4,5,6,7,8")
    header:SetAttribute("xOffset",0)
    header:SetAttribute("yOffset",0)
    header:SetAttribute("unitsPerColumn",5)
    header:SetAttribute("maxColumns",8)
    header:SetAttribute("showRaid",true)
    header:SetAttribute("showParty",false)
    header:SetAttribute("showPlayer",false)
    header:SetAttribute("showSolo",true)
    header:Show()
    Ether:SetupBorderLayout(header,3)
end

function Ether:CreatePetHeader()
    local data=Ether.DB[21][11]
    local header=CreateFrame("Frame","EtherPetGroupHeader",pet,"SecureGroupPetHeaderTemplate")
    Ether.Header.pet=header
    header:SetPoint("BOTTOMLEFT",pet,"TOPLEFT",0,10)
    header:SetAttribute("template","EtherUnitTemplate")
    header:SetAttribute("initialConfigFunction",initialConfigFunction)
    header.CreateChildren=CreateChildren
    header:SetAttribute("TypePet",true)
    header:SetAttribute("ButtonHeight",data[6] or 50)
    header:SetAttribute("ButtonWidth",data[7] or 50)
    header:SetAttribute("xOffset",0)
    header:SetAttribute("yOffset",0)
    header:SetAttribute("showRaid",true)
    header:SetAttribute("showParty",false)
    header:SetAttribute("showPlayer",true)
    header:SetAttribute("showSolo",true)
    header:SetAttribute("columnAnchorPoint","LEFT")
    header:SetAttribute("point","RIGHT")
    header:SetAttribute("useOwnerUnit",false)
    header:SetAttribute("filterOnPet",true)
    header:SetAttribute("unitsPerColumn",10)
    header:SetAttribute("maxColumns",1)
    header:Hide()
    Ether:SetupBorderLayout(header,3)
    RegisterAttributeDriver(header,"state-visibility","[@pet,exists] show;[@raid1,exists] show;[@party1,exists] show;[group:party] show;hide")
end

function Ether:ChangeDirectionHeader(horizontal)
    if InCombatLockdown() then return end
    if horizontal then
        Ether.Header.raid:SetAttribute("point","LEFT")
        Ether.Header.raid:SetAttribute("columnAnchorPoint","TOP")
    else
        Ether.Header.raid:SetAttribute("columnAnchorPoint","LEFT")
        Ether.Header.raid:SetAttribute("point","TOP")
    end

    local name=Ether.Header.raid:GetName().."UnitButton"
    local index=1
    local child=_G[name..index]
    while (child) do
        child:ClearAllPoints()
        index=index+1
        child=_G[name..index]
    end
    if Ether.Header.raid:IsShown() then
        Ether.Header.raid:Hide()
        Ether.Header.raid:Show()
    end
    if Ether.DB[6][1]==1 then
        Ether:AuraDisable()
        Ether:AuraEnable()
    end
end

function Ether:ChangeSortMethod(data)
    if InCombatLockdown() or not data then return end
    local by,order = OrderMethod(data)
    Ether.Header.raid:SetAttribute("groupBy",by or "GROUP")
    Ether.Header.raid:SetAttribute("groupingOrder",unpack(order) or "1,2,3,4,5,6,7,8")
    local name=Ether.Header.raid:GetName().."UnitButton"
    local index=1
    local child=_G[name..index]
    while (child) do
        child:ClearAllPoints()
        index=index+1
        child=_G[name..index]
    end
    if Ether.Header.raid:IsShown() then
        Ether.Header.raid:Hide()
        Ether.Header.raid:Show()
    end
    if Ether.DB[6][1]==1 then
        Ether:AuraDisable()
        Ether:AuraEnable()
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