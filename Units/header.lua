local D,F,_,C=unpack(select(2,...))
local raid,pet=CreateFrame("Frame","EtherRaidGroupAnchor",UIParent,"SecureFrameTemplate"),CreateFrame("Frame","EtherPetGroupAnchor",UIParent,"SecureFrameTemplate")
local raidGroup,raidPet=CreateFrame("Frame","EtherRaidGroupHeader",raid,"SecureGroupHeaderTemplate"),CreateFrame("Frame","EtherPetGroupHeader",pet,"SecureGroupPetHeaderTemplate")
local raidBtn,petBtn,UnitGUID,C_After,GameTooltip,UnitExists=D.raidBtn,D.petBtn,UnitGUID,C_Timer.After,GameTooltip,UnitExists
D.A.raid,D.A.pet,D.H.raid,D.H.pet=raid,pet,raidGroup,raidPet
local initialConfig=[[
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
local function CheckGUID(self)
    self.unit=self:GetAttribute("unit")
    local guid=self.unit and UnitGUID(self.unit)
    if guid and guid~=self.guid then
        self.guid=guid
        F:FullHealthUpdate(self)
        F:UpdateName(self,2)
        UpdatePCT(self)
        F:UpdateIndicatorsUnit(self)
        F:UpdateRaidAuras(self)
    end
end
local function OnAttributeChanged(self,name,unit)
    if not unit or name~="unit" then return end
    if unit~=self.unit then
        self.unit=unit
        raidBtn[self.unit]=self
    end
    CheckGUID(self)
end
local function OnEnter(self)
    if not UnitExists(self.unit) then return end
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:SetUnit(self.unit)
    GameTooltip:Show()
end
local function OnLeave()
    GameTooltip:Hide()
end
local function UpdatePetUnit(self)
    self.unit=self:GetAttribute("unit")
    petBtn[self.unit]=self
    F:FullHealthUpdate(self)
    F:UpdateName(self,3)
    F:UpdateIndicatorsPetUnit(self)
end
local function OnEvent(self,event)
    if event=="UNIT_PET" then
        UpdatePetUnit(self)
    elseif event=="GROUP_ROSTER_UPDATE" then
        UpdatePetUnit(self)
    end
end
local function OnShow(self)
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("UNIT_PET")
end
local function OnHide(self)
    self:UnregisterEvent("UNIT_PET")
    self:UnregisterEvent("GROUP_ROSTER_UPDATE")
end
local function CreateChildren(h,n)
    local b=_G[n]
    local name=b:GetName()
    b.Indicators={}
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
    if h:GetAttribute("TypePet") then
        b.TypePet=true
        local r,g,be=0.18,0.54,0.34
        b.healthBar:SetStatusBarColor(r,g,be)
        b.healthDrop:SetColorTexture(r*0.3,g*0.3,be*0.4,.3)
    else
        b.RaidAuras={}
        local frame=CreateFrame("Frame",nil,UIParent)
        frame:SetFrameStrata("HIGH")
        frame:SetFrameLevel(b:GetFrameLevel()+3)
        local dispel=frame:CreateTexture(nil,"ARTWORK",nil,-7)
        dispel:Hide()
        dispel:SetSize(14,14)
        dispel:SetPoint("TOPRIGHT",b,"TOPRIGHT",-2,-2)
        local border=frame:CreateTexture(nil,"BORDER")
        border:Hide()
        border:SetColorTexture(1,0,0,1)
        border:SetPoint("TOPLEFT",dispel,"TOPLEFT",-1,1)
        border:SetPoint("BOTTOMRIGHT",dispel,"BOTTOMRIGHT",1,-1)
        b.dispel=dispel
        b.dispelBorder=border
        local blink=frame:CreateTexture(nil,"ARTWORK",nil,-7)
        blink:SetSize(10,10)
        blink:SetPoint("CENTER",b,"CENTER",0,10)
        blink:SetTexCoord(0.07,0.93,0.07,0.93)
        b.blink=blink
        F:SetupPowerText(b)
        F:SetupHealthText(b)
    end
    F:SetupButtonBackground(b)
    F:SetupButtonBorder(b)
    F:SetupPrediction(b)
    F:SetupName(b,-5)
    b:SetScript("OnEnter",OnEnter)
    b:SetScript("OnLeave",OnLeave)
    if h:GetAttribute("TypePet") then
        F:SavePetBtnPosition(b)
        b:SetScript("OnShow",OnShow)
        b:SetScript("OnHide",OnHide)
        b:SetScript("OnEvent",OnEvent)
    else
        F:SaveRaidBtnPosition(b)
        b:HookScript("OnAttributeChanged",OnAttributeChanged)
    end
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
local _,s=GetPhysicalScreenSize()
local p=1/(768/s)
function F:CreateGroupHeader(call)
    local by,order=OrderMethod(D.DB["CONFIG"][11])
    local column,point=AnchorMethod(D.DB["CONFIG"][12])
    if call=="GROUP" then
        raidGroup:SetPoint("BOTTOMLEFT",raid,"TOPLEFT")
        raidGroup:SetAttribute("template","EtherUnitTemplate")
        raidGroup:SetAttribute("initialConfigFunction",initialConfig)
        raidGroup:SetAttribute("ButtonWidth",D.DB[21][10][6] or 55)
        raidGroup:SetAttribute("ButtonHeight",D.DB[21][10][7] or 55)
        raidGroup:SetAttribute("columnAnchorPoint",column or "LEFT")
        raidGroup:SetAttribute("point",point or "TOP")
        raidGroup:SetAttribute("groupBy",by or "GROUP")
        raidGroup:SetAttribute("groupingOrder",order or "1,2,3,4,5,6,7,8")
        raidGroup:SetAttribute("xOffset",p)
        raidGroup:SetAttribute("yOffset",-p)
        raidGroup:SetAttribute("columnSpacing",p)
        raidGroup:SetAttribute("unitsPerColumn",5)
        raidGroup:SetAttribute("maxColumns",8)
        raidGroup:SetAttribute("showRaid",true)
        raidGroup:SetAttribute("showParty",true)
        raidGroup:SetAttribute("showPlayer",true)
        raidGroup:SetAttribute("showSolo",true)
        raidGroup.CreateChildren=CreateChildren
        raidGroup:Show()
    elseif call=="PET" then
        raidPet:SetPoint("BOTTOMLEFT",pet,"TOPLEFT")
        raidPet:SetAttribute("template","EtherUnitTemplate")
        raidPet:SetAttribute("initialConfigFunction",initialConfig)
        raidPet:SetAttribute("TypePet",true)
        raidPet:SetAttribute("ButtonHeight",D.DB[21][11][6] or 45)
        raidPet:SetAttribute("ButtonWidth",D.DB[21][11][7] or 45)
        raidPet:SetAttribute("xOffset",p)
        raidPet:SetAttribute("yOffset",-p)
        raidPet:SetAttribute("columnSpacing",p)
        raidPet:SetAttribute("showRaid",true)
        raidPet:SetAttribute("showParty",true)
        raidPet:SetAttribute("showPlayer",true)
        raidPet:SetAttribute("showSolo",true)
        raidPet:SetAttribute("columnAnchorPoint","TOP")
        raidPet:SetAttribute("point","LEFT")
        raidPet:SetAttribute("useOwnerUnit",false)
        raidPet:SetAttribute("filterOnPet",true)
        raidPet:SetAttribute("unitsPerColumn",6)
        raidPet:SetAttribute("maxColumns",2)
        raidPet.CreateChildren=CreateChildren
        RegisterAttributeDriver(raidPet,"state-visibility","[@pet,exists] show;[@raid1,exists] show;[@party1,exists] show;[group:party] show;hide")
    end
    F:SetupHeaderBackground(raid,10)
    F:SetupHeaderBackground(pet,11)
end
local function UpdateHeader()
    if InCombatLockdown() then return end
    C.ProfileRefresh=true
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
        C.ProfileRefresh=false
    end)
end
F:RegisterCallbackByIndex(UpdateHeader,22)
--[[
local _,screenHeight=GetPhysicalScreenSize()
local pixelScale=1/(768/screenHeight)
    local handler = CreateFrame("Frame",nil,nil,"SecureHandlerShowHideTemplate")
    handler:SetFrameRef("EtherHeader",header)
    handler:Execute([-[
	header = self:GetFrameRef("EtherHeader")
]-])
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