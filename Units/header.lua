local D,F=unpack(select(2,...))
local raid=CreateFrame("Frame","EtherRaidGroupAnchor",UIParent,"SecureFrameTemplate")
local pet=CreateFrame("Frame","EtherPetGroupAnchor",UIParent,"SecureFrameTemplate")
D.A.raid,D.A.pet=raid,pet
D.A.raid.index,D.A.pet.index=10,11
local raidBtn=D.raidBtn
local UnitGUID,unpack=UnitGUID,unpack
local C_After,GameTooltip=C_Timer.After,GameTooltip
local initialConfigFunction=[[
    local header = self:GetParent()
    self:SetWidth(header:GetAttribute("ButtonWidth"))
    self:SetHeight(header:GetAttribute("ButtonHeight"))
    self:SetAttribute("*type1", "target")
    self:SetAttribute("*type2", "togglemenu")
    self:SetAttribute("isHeaderDriven", true)
    header:CallMethod("CreateChildren", self:GetName())
]]
local function UpdatePCT(self)
    if D.DB[5][3]==1 then
        F:UpdateHealthPct(self)
    end
    if D.DB[5][4]==1 then
        F:UpdatePowerPct(self)
    end
end
local function CheckStatus(self)
    local unit=self:GetAttribute("unit")
    self.unit=unit
    local guid=unit and UnitGUID(unit)
    if guid~=self.destGUID then
        self.destGUID=guid
        if guid then
            F:SetupBlinkIcon(self)
            F:SetupClassDispel(self)
            F:UpdateIndicatorsString(self)
            F:RaidAurasFullUpdate(self.unit)
            UpdatePCT(self)
            F:FullHealthUpdate(self)
            F:UpdateName(self,2)
            F:SaveBtnPosition(self)
        end
    end
end
local function OnAttributeChanged(self,name,unit)
    if name~="unit" then return end
    if unit then
        self.unit=nil
        raidBtn[unit]=self
    end
    CheckStatus(self)
end
local function OnShow(self)
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    if self.TypePet then
        self:RegisterEvent("UNIT_PET")
    end
end
local function OnHide(self)
    self:UnregisterEvent("GROUP_ROSTER_UPDATE")
    if self.TypePet then
        self:UnregisterEvent("UNIT_PET")
    end
end
local function OnEnter(self)
    if GameTooltip then
        GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
        GameTooltip:SetUnit(self.unit)
        GameTooltip:Show()
    end
end
local function OnLeave()
    if GameTooltip then
        GameTooltip:Hide()
    end
end
local function CreateChildren(h,n)
    local b=_G[n]
    b.Indicators={}
    local name=b:GetName()
    local healthBar=CreateFrame("StatusBar",name.."_HealthBar",b)
    b.healthBar=healthBar
    healthBar:SetOrientation("VERTICAL")
    healthBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
    healthBar:GetStatusBarTexture():SetDrawLayer("ARTWORK",-7)
    healthBar:SetMinMaxValues(0,100)
    healthBar:SetFrameLevel(b:GetFrameLevel()+3)
    healthBar:SetAllPoints(b)
    local healthDrop=b:CreateTexture(name.."_HealthDrop","ARTWORK",nil,-7)
    b.healthDrop=healthDrop
    healthDrop:SetAllPoints()
    healthDrop:SetTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
    b.healthBar:SetAllPoints(b)
    F:SetupButtonBackground(b)
    F:SetupButtonBorder(b)
    if h:GetAttribute("TypePet") then
        b.TypePet=true
    else
        F:SetupPowerText(b)
        F:SetupHealthText(b)
    end
    F:SetupPrediction(b)
    F:SetupName(b,-5)
    b:HookScript("OnAttributeChanged",OnAttributeChanged)
    b:SetScript("OnShow",OnShow)
    b:SetScript("OnHide",OnHide)
    b:SetScript("OnEnter",OnEnter)
    b:SetScript("OnLeave",OnLeave)
    if not InCombatLockdown() then
        b:RegisterForClicks("AnyUp")
    end
    return b
end
local function OrderMethod(index)
    if not index or type(index)~="number" then return end
    if index==1 then
        return "GROUP","1,2,3,4,5,6,7,8"
    elseif index==2 then
        return "CLASS","DRUID,PRIEST,HUNTER,MAGE,PALADIN,ROGUE,SHAMAN,WARLOCK,WARRIOR"
    elseif index==3 then
        return "ASSIGNEDROLE","TANK,HEALER,DAMAGER,NONE"
    end
end
local function AnchorMethod(index)
    if not index or type(index)~="number" then return end
    if index==4 then
        return "LEFT","TOP"
    elseif index==5 then
        return "TOP","LEFT"
    end
end
function F:CreateGroupHeader()
    local data=D.DB[21][10]
    local by,order=OrderMethod(D.DB["CONFIG"][11])
    local column,point=AnchorMethod(D.DB["CONFIG"][12])
    local header=CreateFrame("Frame","EtherRaidGroupHeader",raid,"SecureGroupHeaderTemplate")
    D.H.raid=header
    header:SetPoint("BOTTOMLEFT",raid,"TOPLEFT")
    header:SetAttribute("template","EtherUnitTemplate")
    header:SetAttribute("initial-unitWatch",true)
    header:SetAttribute("initialConfigFunction",initialConfigFunction)
    header.CreateChildren=CreateChildren
    header:SetAttribute("ButtonWidth",data[6] or 55)
    header:SetAttribute("ButtonHeight",data[7] or 55)
    header:SetAttribute("columnAnchorPoint",column or "LEFT")
    header:SetAttribute("point",point or "TOP")
    header:SetAttribute("groupBy",by or "GROUP")
    header:SetAttribute("groupingOrder",order or "1,2,3,4,5,6,7,8")
    header:SetAttribute("xOffset",2)
    header:SetAttribute("yOffset",-2)
    header:SetAttribute("columnSpacing",1)
    header:SetAttribute("unitsPerColumn",5)
    header:SetAttribute("maxColumns",8)
    header:SetAttribute("showRaid",true)
    header:SetAttribute("showParty",true)
    header:SetAttribute("showPlayer",true)
    header:SetAttribute("showSolo",true)
    header:Show()
end
function F:CreatePetHeader()
    local DB=D.DB
    local data=DB[21][11]
    local header=CreateFrame("Frame","EtherPetGroupHeader",pet,"SecureGroupPetHeaderTemplate")
    D.H.pet=header
    header:SetPoint("BOTTOMLEFT",pet,"TOPLEFT")
    header:SetAttribute("template","EtherUnitTemplate")
    header:SetAttribute("initialConfigFunction",initialConfigFunction)
    header.CreateChildren=CreateChildren
    header:SetAttribute("TypePet",true)
    header:SetAttribute("ButtonHeight",data[6] or 50)
    header:SetAttribute("ButtonWidth",data[7] or 50)
    header:SetAttribute("xOffset",-2)
    header:SetAttribute("yOffset",2)
    header:SetAttribute("showRaid",true)
    header:SetAttribute("showParty",false)
    header:SetAttribute("showPlayer",true)
    header:SetAttribute("showSolo",true)
    header:SetAttribute("columnAnchorPoint","LEFT")
    header:SetAttribute("point","RIGHT")
    header:SetAttribute("useOwnerUnit",false)
    header:SetAttribute("filterOnPet",true)
    header:SetAttribute("unitsPerColumn",6)
    header:SetAttribute("maxColumns",2)
    header:Hide()
    RegisterAttributeDriver(header,"state-visibility",
            "[@pet,exists] show;[@raid1,exists] show;[@party1,exists] show;[group:party] show;hide")
end
local function UpdateHeader()
    if InCombatLockdown() then return end
    local header=D.H.raid
    local by,order=OrderMethod(D.DB["CONFIG"][11])
    local column,point=AnchorMethod(D.DB["CONFIG"][12])
    header:SetAttribute("groupBy",by or "GROUP")
    header:SetAttribute("groupingOrder",order or "1,2,3,4,5,6,7,8")
    header:SetAttribute("columnAnchorPoint",column or "LEFT")
    header:SetAttribute("point",point or "TOP")
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
        F:AuraDisable()
    end
    C_After(1.5,function()
        header:Show()
        F:AuraEnable()
    end)
end
F:RegisterCallbackByIndex(UpdateHeader,22)
--[[
order = 'DRUID,PRIEST,HUNTER,MAGE,PALADIN,ROGUE,SHAMAN,WARLOCK,WARRIOR',
by = 'CLASS'
order = 'TANK,HEALER,DAMAGER,NONE',
by = 'ASSIGNEDROLE'
order = '1,2,3,4,5,6,7,8',
by = 'GROUP'
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