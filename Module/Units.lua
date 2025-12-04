local _, C          = ...
local Units         = C.Units
local Update        = C.Update
local Setup         = C.Setup
local Aura          = C.Aura

local ipairs        = ipairs
local pairs         = pairs

Units.Data          = {
    Anchor = {
        Party = {},
        Split = {},
        RaidPet = {}
    },
    Header = {
        SplitHeader = {}
    },
    Buttons = {
        Player = {},
        Target = {},
        TargetTarget = {},
        PlayersPet = {},
        PlayersPetTarget = {},
        Party = {},
        Raid = {},
        RaidPets = {},
        Fake = {}
    },
    Update = {
        Single = {},
        Cache = {}
    },
    Events = {
        Registered = {}
    },
    FullUpdates = {},
    Frames = {},
    events = {},
    unitEvents = {},
    registeredEvents = {},
    OnUpdateRunning = false,
    unitFrames = {},
}

local __SECURE_INIT = [=[

	local header = self:GetParent()

	self:SetHeight(header:GetAttribute("style-height"))
	self:SetWidth(header:GetAttribute("style-width"))
	self:SetScale(header:GetAttribute("style-scale"))

	self:SetAttribute("*type1", "target")
	self:SetAttribute("*type2", "togglemenu")
	self:SetAttribute("type2", "togglemenu")

	self:SetAttribute("isHeaderDriven", true)

	header:CallMethod("initialConfigFunction", self:GetName())

]=]


local SORT = {
    CLASS = {
        order = 'DRUID,PRIEST,HUNTER,MAGE,PALADIN,ROGUE,SHAMAN,WARLOCK,WARRIOR',
        by = 'CLASS'
    },
    ASSIGNEDROLE = {
        order = 'TANK,HEALER,DAMAGER,NONE',
        by = 'ASSIGNEDROLE'
    },
    GROUP = {
        order = '1,2,3,4,5,6,7,8',
        by = 'GROUP'
    }
}

local TEMPLATE = {
    GROUP = 'SecureGroupHeaderTemplate',
    RAID = 'SecureRaidGroupHeaderTemplate',
    PARTY = 'SecurePartyHeaderTemplate',
    PET = 'SecureGroupPetHeaderTemplate'
}

local function OnEvent(self, event, unit, ...)
    if (not Units.Data.unitEvents[event] or self.unit == unit) then
        for handler, func in pairs(self.registeredEvents[event]) do
            handler[func](handler, self, event, unit, ...)
        end
    end
end
local function FullUpdate(self)
    for i = 1, #(self.fullUpdates), 2 do
        local handler = self.fullUpdates[i]
        handler[self.fullUpdates[i + 1]](handler, self)
    end
end



local function RegisterNormalEvent(self, event, handler, func, unitOverride)
    if (not handler[func]) then
        error(
            string.format("Invalid handler/function passed for %s on event %s, the function %s does not exist.",
                self:GetName() or tostring(self), tostring(event), tostring(func)), 3)
        return
    end

    if (Units.Data.unitEvents[event]) then
        self:BlizzRegisterUnitEvent(event, unitOverride or self.unitOwner, nil)
        if unitOverride then
            self.unitEventOverrides = self.unitEventOverrides or {}
            self.unitEventOverrides[event] = unitOverride
        end
    else
        self:RegisterEvent(event)
    end

    self.registeredEvents[event] = self.registeredEvents[event] or {}

    if (self.registeredEvents[event][handler]) then
        return
    end

    self.registeredEvents[event][handler] = func
end


local function RegisterUnitEvent(self, event, handler, func)
    Units.Data.unitEvents[event] = true
    self:RegisterNormalEvent(event, handler, func)
end
local function SetBarColor(self)
    if (self.healthBar) then return end

    local r, g, b = self:GetClassColors(self, self.UnitClassToken)
    self.healthBar:SetStatusBarColor(r, g, b, 1)
    self.healthBar.bg:SetVertexColor(r * 0.3, g * 0.3, b * 0.3, 1)
end

local function ClassToken(self)
    return (select(2, UnitClass(self.unit)))
end


function Units:CheckUnitStatus(frame)
    local guid = frame.unit and UnitGUID(frame.unit)
    if (guid ~= frame.unitGUID) then
        frame.unitGUID = guid
        if (guid) then
            Units:FullUpdate(frame)
        end
    end
end

function Units:FullUpdate(frame)
    Update:HealthBar(frame)
    Update:NameUpdate(frame)
    Update:PowerBar(frame)
end
OnAttributeChanged = function(self, name, unit)
    if (name ~= "unit" or not unit or unit == self.unitOwner) then return end

    -- Nullify the previous entry if it had on
    local configUnit = self.unitUnmapped or unit
    if (self.configUnit and Units.Data.unitFrames[self.configUnit] == self) then Units.Data.unitFrames[self.configUnit] = nil end

    -- Setup identification data
    self.unit = unit
    self.unitID = tonumber(string.match(unit, "([0-9]+)"))


    if not self.Indicators then
        self.Indicators = {}
    end

    if (self.unitRealType == self.unitType) then
        Units.Data.unitFrames[configUnit] = self
    end

    if( self.unitInitialized ) then

        self:FullUpdate()
        return
    end

    self.unitInitialized = true



    if( self.unit == "party" ) then
        Setup:CreateHealthBar(self,40, 'HORIZONTAL')
        Setup:PowerBar(self)
        self:RegisterUnitEvent("UNIT_POWER_UPDATE",  self, 'PowerBar')
        self:RegisterUnitEvent("UNIT_MAXPOWER", self, 'PowerBar')
        self:RegisterUnitEvent("UNIT_NAME_UPDATE",  self, 'NameUpdate')
        self:RegisterNormalEvent("GROUP_ROSTER_UPDATE", Units, " CheckUnitStatus")

    elseif( self.unit == "player" ) then

        Setup:CreateHealthBar(self,40, 'HORIZONTAL')
        Setup:CreatePowerBar(self)
        self:RegisterUnitEvent("UNIT_POWER_UPDATE",  self, 'PowerBar')
        self:RegisterUnitEvent("UNIT_MAXPOWER", self, 'PowerBar')
             elseif ( self.unit == "target" or self.unit == "targettarget"  ) then
        Setup:CreateHealthBar(self,40, 'HORIZONTAL')
        Setup:CreatePowerBar(self)
        self:RegisterUnitEvent("UNIT_POWER_UPDATE",  self, 'PowerBar')
        self:RegisterUnitEvent("UNIT_MAXPOWER", self, 'PowerBar')
        self:RegisterUnitEvent("UNIT_NAME_UPDATE",  self, 'NameUpdate')
        self:RegisterUnitEvent("UNIT_TARGETABLE_CHANGED", self, "FullUpdate")
        self:RegisterNormalEvent("PLAYER_TARGET_CHANGED", Units, "CheckUnitStatus")

    end


    Setup:CreateHealthBar(self, '55', 'VERTICAL')
    Setup:CreateBorder(self)
    Setup:CreateName(self, 10, 0)
    ClassToken(self)
    SetBarColor(self)
    Aura:RaidAuraSetup(self)
    Setup:HealPrediction(self)
    Setup:PowerText(self, true)

    Update:NameUpdate(self)


    Update:UpdateOffline(self)
    Units:CheckUnitStatus(self)
    Aura:UpdateRaidByUnitBuff(self)

    if not self.Indicators.offline then
        self.Indicators.offline = self.healthBar:CreateTexture(nil, 'OVERLAY')
        self.Indicators.offline:SetTexture("Interface\\CharacterFrame\\Disconnect-Icon")
        self.Indicators.offline:SetTexCoord(0, 1, 0, 1)
        self.Indicators.offline:SetPoint(0, 1)
        self.Indicators.offline:SetSize(24, 24)
        self.Indicators.offline:Hide()
    end
    if not self.Indicators.raidtarget then
        self.Indicators.raidtarget = self.healthBar:CreateTexture(nil, 'OVERLAY')
        self.Indicators.raidtarget:SetPoint('BOTTOM', -2, 1)
        self.Indicators.raidtarget:SetSize(12, 12)
        --   frame.Indicators.raidtarget:Hide()
    end
    if not self.Indicators.role then
        self.Indicators.role = self.healthBar:CreateTexture(nil, 'OVERLAY')
        self.Indicators.role:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
        self.Indicators.role:SetPoint('RIGHT', 0, 9)
        self.Indicators.role:SetSize(12, 12)
        self.Indicators.role:Hide()
    end
    Update:UpdateRaidTarget(self)
    Update:UpdateOffline(self)

-- role update
    self:RegisterUnitEvent("UNIT_HEALTH", self, "HealthBar")
    self:RegisterUnitEvent("UNIT_MAXHEALTH", self, "HealthBar")
    self:RegisterUnitEvent("UNIT_HEAL_PREDICTION", self, 'HealPrediction')
    self:RegisterUnitEvent('UNIT_ABSORB_AMOUNT_CHANGED', self, 'HealPrediction')
    self:RegisterNormalEvent('RAID_TARGET_UPDATE', self, 'UpdateRaidTarget')
    self:RegisterUnitEvent('UNIT_CONNECTION', self, 'UpdateOffline')
    self:RegisterNormalEvent('PLAYER_ROLES_ASSIGNED', self, 'UpdateRole')
end
Units.OnAttributeChanged = OnAttributeChanged


local function OnShow(self)
    if not self:GetScript("OnEvent") then
        self:SetScript("OnEvent", OnEvent)
    end
    Units:CheckUnitStatus(self)
end

local function OnHide(self)
    self:SetScript("OnEvent", nil)
    if (self.isUnitVolatile or self:IsShown()) then
        self.unitGUID = nil
    end
    -- git test
end

local function OnEnter(self)
    if (self.OnEnter) then
        self:OnEnter()
    end
end

local function OnLeave(self)
    if (self.OnLeave) then
        self:OnLeave()
    end
end


local function Ether_OnEnter(self)
    if not GameTooltip:IsForbidden() then
        UnitFrame_OnEnter(self)
    end
end

local function Ether_OnLeave(self)
    UnitFrame_OnLeave(self)
end

local function CheckGuid(self)
    local guid = self.unit and UnitGUID(self.unit)
    if (guid ~= self.unitGUID) then
        self.unitGUID = guid
        if (guid) then

        end
    end
end

local function RegisterUpdateFunc(self, handler, func)
    if (not handler[func]) then
        error(
            string.format(
                "Invalid handler/function passed to RegisterUpdateFunc for %s, the function %s does not exist.",
                self:GetName() or tostring(self), func), 3)
        return
    end

    for i = 1, #(self.fullUpdates), 2 do
        local data = self.fullUpdates[i]
        if (data == handler and self.fullUpdates[i + 1] == func) then
            return
        end
    end

    table.insert(self.fullUpdates, handler)
    table.insert(self.fullUpdates, func)
end

local function UnregisterUpdateFunc(self, handler, func)
    for i = #(self.fullUpdates), 1, -1 do
        if (self.fullUpdates[i] == handler and self.fullUpdates[i + 1] == func) then
            table.remove(self.fullUpdates, i + 1)
            table.remove(self.fullUpdates, i)
        end
    end
end


Units.OnEvent = OnEvent


local function initializeUnit(_, frameName)
    local frame = Units.Data.Buttons.Raid[frameName]
    frame = _G[frameName]

    Units:CreateChilds(frame)
    Units.Data.Buttons.Raid[frameName] = frame
end




function Units:CreateChilds(...)
    local frame = select("#", ...) > 1 and CreateFrame(...) or select(1, ...)


    frame.fullUpdates = {}
    frame.registeredEvents = {}

    frame.CreateHealthBar = C.Setup.CreateHealthBar
    frame.CreatePowerBar = C.Setup.CreatePowerBar
    frame.CreateName = C.Setup.CreateName

    frame.HealthBar = C.Update.HealthBar
    frame.HealPrediction = C.Update.HealPrediction
    frame.PowerBar = C.Update.PowerBar
    frame.NameUpdate = C.Update.NameUpdate
    frame.FullUpdate = FullUpdate
    frame.UpdateOffline = C.Update.UpdateOffline
    frame.UpdateRaidTarget = C.Update.UpdateRaidTarget
    frame.CheckUnitStatus = Units.CheckUnitStatus
    frame.UpdateRole = C.Update.UpdateRole
    frame.RegisterNormalEvent = RegisterNormalEvent
    frame.BlizzRegisterUnitEvent = frame.RegisterUnitEvent
    frame.UnitClassToken = ClassToken
    frame.RegisterUpdateFunc = RegisterUpdateFunc
    frame.UnregisterUpdateFunc = UnregisterUpdateFunc
    frame.RegisterUnitEvent = RegisterUnitEvent
    frame.SetBarColor = SetBarColor


    frame:HookScript("OnAttributeChanged", OnAttributeChanged)
    frame:SetScript("OnEvent", OnEvent)
    frame:HookScript("OnEnter", OnEnter)
    frame:HookScript("OnLeave", OnLeave)
    frame:SetScript("OnShow", OnShow)
    frame:SetScript("OnHide", OnHide)

    frame.OnEnter = Ether_OnEnter
    frame.OnLeave = Ether_OnLeave

    frame:RegisterForClicks("AnyUp")
    if (not InCombatLockdown() and not frame:GetAttribute("isHeaderDriven")) then
        frame:SetAttribute("*type1", "target")
        frame:SetAttribute("*type2", "togglemenu")
    end
    frame:SetAttribute("isHeaderDriven", true)

    return frame
end

function Units:CreateSplitHeader()
    if not self.SplitHeaderTemplate then
        self.SplitHeaderTemplate = CreateFrame('Frame', nil, UIParent, 'SecureFrameTemplate')
        self.__SPLITHEADER = C.ObjMetaPos:NEW(self.SplitHeaderTemplate, 'RAID')
        self.__SPLITHEADER:INITIAL()
        C.Callback.Register('RESET_RAIDUNIT_DATA', 'RaidUnitsReset', function(data)
            for groupID = 1, 8 do
                local header = C.Units.Data.Header.SplitHeader['Groups' .. groupID]
                for _, child in ipairs({ header:GetChildren() }) do
                    if child and child.Indicators and child.Indicators[data] then
                        if child.Indicators[data]:IsShown() then
                            child.Indicators[data]:Hide()
                        else
                            child.Indicators[data]:Show()
                        end
                    end
                end
            end
        end)
    end


    local groupsPerColumn = 1
    local currentColumn = 0
    local currentRow = 0

    local DB = C.DB['HEADER']['RAID']

    local GROUP_FILTER = DB['GroupsFilter']

    for groupID, enabled in pairs(GROUP_FILTER) do
        local frame = self.Data.Header.SplitHeader['Groups' .. groupID]
        if (enabled) then
            currentRow = currentRow + 1
            if currentRow > groupsPerColumn then
                currentRow = 1
                currentColumn = currentColumn + 1
            end
            local xOffset = currentColumn * 57
            local yOffset = (currentRow - 1) * -55
            if (not frame) then
                frame = CreateFrame('Frame', 'EtherRaidGroup' .. groupID .. 'Header', self.SplitHeaderTemplate,
                    TEMPLATE.GROUP)
                frame:SetPoint('TOPLEFT', self.SplitHeaderTemplate, 'TOPLEFT', xOffset, yOffset)
                frame:SetAttribute('template', 'Ether_ButtonTemplate')
                frame:SetAttribute('templateType', 'Button')
                frame:SetAttribute('groupFilter', groupID)
                frame:SetAttribute('initial-unitWatch', true)
                frame:SetAttribute('initialConfigFunction', __SECURE_INIT)
                frame.initialConfigFunction = initializeUnit
                frame:SetAttribute('indicators', true)
                frame:SetAttribute('style-height', DB.styleheight)
                frame:SetAttribute('style-width', DB.stylewidth)
                frame:SetAttribute('style-scale', DB.stylescale)
                frame:SetAttribute('showPlayer', false)
                frame:SetAttribute('showSolo', DB.showSolo)
                frame:SetAttribute('showParty', DB.showParty)
                frame:SetAttribute('showRaid', DB.showRaid)
                frame:SetAttribute('point', DB.point)
                frame:SetAttribute("xOffset", 0)
                frame:SetAttribute("yOffset", -2)
                frame:SetAttribute('columnAnchorPoint', DB.columnAnchorPoint)
                frame:SetAttribute('columnSpacing', DB.columnSpacing)
                frame:SetAttribute('unitsPerColumn', DB.unitsPerColumn)
                frame:SetAttribute('maxColumns', DB.maxColumns)
                frame:SetAttribute('groupBy', SORT.GROUP.by)
                frame:SetAttribute('groupingOrder', SORT.GROUP.order)
                frame:SetAttribute('sortMethod', DB.sortMethod)
                frame:SetAttribute('sortDir', DB.sortDir)
                frame:SetAttribute('startingIndex', 1)
                self.Data.Header.SplitHeader['Groups' .. groupID] = frame
                frame:ClearAllPoints()
                frame:SetPoint('TOPLEFT', self.SplitHeaderTemplate, 'TOPLEFT', xOffset, yOffset)
                frame:Show()
            else
                if (frame) then
                    frame:Hide()
                end
            end
        end
    end
end

function Units:CreatePetHeader()
    if not self.RaidPetTemplate then
        self.RaidPetTemplate = CreateFrame('Frame', nil, UIParent, 'SecureFrameTemplate')
        self.__RAIDPETHEADER = C.ObjMetaPos:NEW(self.RaidPetTemplate, 'RAIDPET')
        self.__RAIDPETHEADER:INITIAL()
    end

    local DB = C.DB['HEADER']['RAIDPET']

    local header = CreateFrame('Frame', 'EtherRaidPetGroupHeader', UIParent, TEMPLATE.PET)
    header:SetPoint('TOPLEFT', self.RaidPetTemplate, 'TOPLEFT')
    header:SetAttribute('template', 'Ether_ButtonTemplate')
    header:SetAttribute('templateType', 'Button')
    header:SetAttribute('initial-unitWatch', true)
    header:SetAttribute('initialConfigFunction', __SECURE_INIT)
    header.initialConfigFunction = initializeUnit
    header:SetAttribute('style-height', DB.styleheight)
    header:SetAttribute('style-width', DB.stylewidth)
    header:SetAttribute('style-scale', DB.stylescale)
    header:SetAttribute('showPlayer', DB.showPlayer)
    header:SetAttribute('showSolo', DB.showSolo)
    header:SetAttribute('showParty', DB.showParty)
    header:SetAttribute('showRaid', DB.showRaid)
    header:SetAttribute("point", "LEFT")
    header:SetAttribute("xOffset", 5)
    header:SetAttribute("yOffset", 0)
    header:SetAttribute('useOwnerUnit', DB.useOwnerUnit)
    header:SetAttribute('unitsPerColumn', 5)
    header:SetAttribute('maxColumns', 1)
    header:SetAttribute('filterOnPet', DB.filterOnPet)
    header:Show()
end

function Units:CreatePartyHeader()
    if not self.PartyTemplate then
        self.PartyTemplate = CreateFrame('Frame', nil, UIParent, 'SecureFrameTemplate')
        self.__PARTY = C.ObjMetaPos:NEW(self.PartyTemplate, 'PARTY')
        self.__PARTY:INITIAL()
    end

    local DB = C.DB['HEADER']['PARTY']

    local header = CreateFrame('Frame', 'EtherPartyHeader', UIParent, TEMPLATE.PARTY)
    header:SetPoint('TOPLEFT', self.PartyTemplate, 'TOPLEFT')
    header:SetAttribute('template', 'Ether_ButtonTemplate')
    header:SetAttribute('templateType', 'Button')
    header:SetAttribute('initial-unitWatch', true)
    header:SetAttribute('initialConfigFunction', __SECURE_INIT)
    header.initialConfigFunction = initializeUnit
    header:SetAttribute('style-height', DB.styleheight)
    header:SetAttribute('style-width', DB.stylewidth)
    header:SetAttribute('style-scale', DB.stylescale)
    header:SetAttribute('showPlayer', true)
    header:SetAttribute('showSolo', false)
    header:SetAttribute('showParty', true)
    header:SetAttribute('showRaid', false)
    header:SetAttribute("point", "LEFT")
    header:SetAttribute("xOffset", 5)
    header:SetAttribute("yOffset", 10)
    header:SetAttribute('point', DB.point)
    header:SetAttribute('columnAnchorPoint', DB.columnAnchorPoint)


    header:Show()
end

local P = { 0, 0, 0, 0, 0 }
local T = { 0, 0, 0, 0, 0 }

local function OnAuraEvent(self, event, unit, info)
    self.unit = Units.Data.Buttons.Target:GetAttribute('unit')
    if (event == 'PLAYER_TARGET_CHANGED' and self.unit == 'target') then

        Aura:SingleAuraUpdateBuff(Units.Data.Buttons.Target, 'target')
        Aura:SingleAuraUpdateDebuff(Units.Data.Buttons.Target, 'target')
        return
    end



    if (event ~= "UNIT_AURA") then return end
    if not info or not (info.addedAuras or info.removedAuraInstanceIDs) then return end
    if unit and unit == 'player' then
        P[1], P[2], P[3], P[4], P[5] = 0, 0, 0, 0, 0
        if P[1] ~= 1 then
            C_Timer.After(0.1, function()
                P[1] = 1
                if info.addedAuras then
                    for _, data in ipairs(info.addedAuras) do
                        if data and data.isHelpful then
                            P[2] = 1
                        elseif data and data.isHarmful then
                            P[3] = 1
                        end
                    end
                end
                if P[2] == 1 then
                    -- Ether.Console:Output('Added aura harmful ' .. unitName)
                    Aura:SingleAuraUpdateBuff(Units.Data.Buttons.Player, 'player')
                end
                if P[3] == 1 then
                    --Ether.Console:Output('Added aura harmful ' .. unitName)
                    Aura:SingleAuraUpdateDebuff(Units.Data.Buttons.Player, 'player')
                end
                if info.removedAuraInstanceIDs then
                    P[4], P[5] = 1, 1
                end

                if P[4] == 1 then
                    --  Ether.Console:Output('Removed aura helpful ' .. unitName)
                    Aura:SingleAuraUpdateBuff(Units.Data.Buttons.Player, 'player')
                end
                if P[5] == 1 then
                    --  Ether.Console:Output('Removed aura harmful ' .. unitName)
                    Aura:SingleAuraUpdateDebuff(Units.Data.Buttons.Player, 'player')
                end
            end)
        end
    elseif unit and unit == 'target' then
        T[1], T[2], T[3], T[4], T[5] = 0, 0, 0, 0, 0
        if T[1] ~= 1 then
            C_Timer.After(0.1, function()
                T[1] = 1
                if info.addedAuras then
                    for _, data in ipairs(info.addedAuras) do
                        if data and data.isHelpful then
                            T[2] = 1
                        elseif data and data.isHarmful then
                            T[3] = 1
                        end
                    end
                end
                if T[2] == 1 then
                    Aura:SingleAuraUpdateBuff(Units.Data.Buttons.Target, 'target')
                end
                if T[3] == 1 then
                    Aura:SingleAuraUpdateDebuff(Units.Data.Buttons.Target, 'target')
                end
                if info.removedAuraInstanceIDs then
                    T[4], T[5] = 1, 1
                end

                if T[4] == 1 then
                    Aura:SingleAuraUpdateBuff(Units.Data.Buttons.Target, 'target')
                end
                if T[5] == 1 then
                    Aura:SingleAuraUpdateDebuff(Units.Data.Buttons.Target, 'target')
                end
            end)
        end
    end
end

function Units:LoadUnit(unit)
    if (self.Data.unitFrames[unit]) then
        RegisterUnitWatch(self.Data.unitFrames[unit], self.Data.unitFrames[unit].hasStateWatch)
        return
    end

    local frame = self:CreateChilds("Button", "UnitFramesUnit" .. unit, UIParent, "Ether_ButtonTemplate")
    frame:SetAttribute("unit", unit)


    if unit == 'player' then
        self.Data.Buttons.Player = frame


        if C.DB['CREATE']['PLAYERAURA'] then
            self.Data.Buttons.Player.SingleAura = {
                Buffs = {},
                Debuffs = {},
                LastBuffs = {},
                LastDebuffs = {}
            }

            Aura:SingleAuraSetup(self.Data.Buttons.Player, 'player')
            Aura:SingleAuraUpdateBuff(self.Data.Buttons.Player, 'player')
            Aura:SingleAuraUpdateDebuff(self.Data.Buttons.Player, 'player')
            if not self.AuraUpdater:GetScript('OnEvent') then
                self.AuraUpdater:SetScript('OnEvent', OnAuraEvent)
            end
        end
        if C.DB['CREATE']['PLAYERBAR'] and C.DB['CREATE']['PLAYER'] then
            self.PlayerCastbar = C.Castbar:CreateCastbar('player')
            self.__PLAYERSBAR = C.ObjMetaPos:NEW(self.PlayerCastbar, 'PLAYERCASTBAR')
            self.__PLAYERSBAR:INITIAL()
        end


        self.__PLAYER = C.ObjMetaPos:NEW(self.Data.Buttons.Player, 'PLAYER')
        self.__PLAYER:INITIAL()
    end

    if unit == 'target' then
        self.Data.Buttons.Target = frame

        if C.DB['CREATE']['TARGETAURA'] then
            self.Data.Buttons.Target.SingleAura = {
                Buffs = {},
                Debuffs = {},
                LastBuffs = {},
                LastDebuffs = {}
            }
            Aura:SingleAuraSetup(self.Data.Buttons.Target, 'target')
            Aura:SingleAuraUpdateBuff(self.Data.Buttons.Target, 'target')
            Aura:SingleAuraUpdateDebuff(self.Data.Buttons.Target, 'target')
            self.AuraUpdater:RegisterUnitEvent('UNIT_AURA', 'player', 'target')
            self.AuraUpdater:RegisterEvent('PLAYER_TARGET_CHANGED')
            if not self.AuraUpdater:GetScript('OnEvent') then
                self.AuraUpdater:SetScript('OnEvent', OnAuraEvent)
            end
        end
        if C.DB['CREATE']['TARGETBAR'] and C.DB['CREATE']['TARGET'] then
            self.TargetCastbar = C.Castbar:CreateCastbar('target')
            self.__TARGETSBAR = C.ObjMetaPos:NEW(self.TargetCastbar, 'TARGETCASTBAR')
            self.__TARGETSBAR:INITIAL()
        end

        self.__TARGET = C.ObjMetaPos:NEW(self.Data.Buttons.Target, 'TARGET')
        self.__TARGET:INITIAL()
    end
    if unit == 'targettarget' then
        self.Data.Buttons.TargetTarget = frame
        self.__TARGETTARGET = C.ObjMetaPos:NEW(self.Data.Buttons.TargetTarget, 'TARGETTARGET')
        self.__TARGETTARGET:INITIAL()

    end



    RegisterUnitWatch(frame, frame.hasStateWatch)
end



function Units:Initialize()
    local DB               = C.DB
    if not self.AuraUpdater then
        self.AuraUpdater = CreateFrame('frame')
    end
    if DB['CREATE']['PLAYER'] then
        self:LoadUnit('player')
    end
    if DB['CREATE']['TARGET'] then
        self:LoadUnit('target')
    end
    if DB['CREATE']['TARGETTARGET'] then
        self:LoadUnit('targettarget')
    end
    --[[

    local function CreateUnits(name)
    local frame = CreateFrame('Button', 'Ether' .. name .. 'UnitButton', UIParent, 'Ether_ButtonTemplate')

    Setup:CreateBorder(frame, 1, 1)
    local unit = string.lower(name)
    frame.unit = unit
    frame:SetAttribute('unit', frame.unit)

    Setup:Healthbar(frame, 40, 'HORIZONTAL')
    Setup:Powerbar(frame)
    Setup:Name(frame, 10, 0)
    Setup:HealPrediction(frame)
    Setup:PowerText(frame)
    frame:RegisterUnitEvent('UNIT_MAXPOWER', frame.unit)
    frame:RegisterUnitEvent('UNIT_POWER_UPDATE', frame.unit)
    frame:RegisterUnitEvent('UNIT_HEALTH', frame.unit)
    frame:RegisterUnitEvent('UNIT_MAXHEALTH', frame.unit)
    frame:SetScript('OnEvent', function(self, event)
        if (event == 'UNIT_MAXPOWER' or event == 'UNIT_POWER_UPDATE') then
            Update:Powerbar(self)
        elseif (event == 'UNIT_HEALTH' or event == 'UNIT_MAXHEALTH') then
            Update:Healthbar(self)
        end
    end)
    Setup:PowerText(frame)
    frame:SetScript('OnAttributeChanged', CheckSingleGuid)
    frame:SetScript('OnEnter', function()
        GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
        GameTooltip:SetUnit(frame.unit)
        GameTooltip:Show()
    end)
    frame:SetScript('OnLeave', GameTooltip_Hide)

    frame:RegisterForClicks("AnyUp")
    if (not InCombatLockdown()) then
        frame:SetAttribute("*type1", "target")
        frame:SetAttribute("*type2", "togglemenu")
    end

    return frame
end
    if DB['CREATE']['PLAYER'] then
        self.Data.Buttons.Player = self:LoadUnit('player')
        self.__PLAYER = C.ObjMetaPos:NEW(self.Data.Buttons.Player, 'PLAYER')
        self.__PLAYER:INITIAL()
        if DB['CREATE']['PLAYERAURA'] then
            self.Data.Buttons.Player.SingleAura = {
                Buffs = {},
                Debuffs = {},
                LastBuffs = {},
                LastDebuffs = {}
            }
            Aura:SingleAuraSetup(self.Data.Buttons.Player, 'player')
            Aura:SingleAuraUpdateBuff(self.Data.Buttons.Player, 'player')
            Aura:SingleAuraUpdateDebuff(self.Data.Buttons.Player, 'player')
            self.AuraUpdater:RegisterUnitEvent('UNIT_AURA', 'player', 'target')

            if not self.AuraUpdater:GetScript('OnEvent') then
                self.AuraUpdater:SetScript('OnEvent', OnAuraEvent)
            end
        end
        table.insert(self.Data.Update.Single, self.Data.Buttons.Player)
    end

    if DB['CREATE']['TARGET'] then
        self.Data.Buttons.Target = CreateUnits('Target')
        RegisterUnitWatch(self.Data.Buttons.Target)
        self.__TARGET = C.ObjMetaPos:NEW(self.Data.Buttons.Target, 'TARGET')
        self.__TARGET:INITIAL()
        if DB['CREATE']['TARGETAURA'] then
            self.Data.Buttons.Target.SingleAura = {
                Buffs = {},
                Debuffs = {},
                LastBuffs = {},
                LastDebuffs = {}
            }
            Aura:SingleAuraSetup(self.Data.Buttons.Target, 'target')
            Aura:SingleAuraUpdateBuff(self.Data.Buttons.Target, 'target')
            Aura:SingleAuraUpdateDebuff(self.Data.Buttons.Target, 'target')
            self.AuraUpdater:RegisterEvent('PLAYER_TARGET_CHANGED')
            if not self.AuraUpdater:GetScript('OnEvent') then
                self.AuraUpdater:SetScript('OnEvent', OnAuraEvent)
            end
        end
        table.insert(self.Data.Update.Single, self.Data.Buttons.Target)
    end

    if DB['CREATE']['TARGETTARGET'] then
        self.Data.Buttons.TargetTarget = CreateUnits('TargetTarget')
        RegisterUnitWatch(self.Data.Buttons.TargetTarget)
        self.__TARGETTARGET = C.ObjMetaPos:NEW(self.Data.Buttons.TargetTarget, 'TARGETTARGET')
        self.__TARGETTARGET:INITIAL()
        table.insert(self.Data.Update.Single, self.Data.Buttons.TargetTarget)
    end
    if DB['CREATE']['PLAYERSPET'] then
        self.Data.Buttons.PlayersPet = CreateUnits('pet')
        RegisterUnitWatch(self.Data.Buttons.PlayersPet)
        self.__PLAYERSPET = C.ObjMetaPos:NEW(self.Data.Buttons.PlayersPet, 'PLAYERSPET')
        self.__PLAYERSPET:INITIAL()
        if classFileName == 'HUNTER' then
            Setup:PetCondition(Data.Buttons.PlayersPet)
        end
        table.insert(self.Data.Update.Single, self.Data.Buttons.PlayersPet)
    end
    if DB['CREATE']['PLAYERSPETTARGET'] then
        self.Data.Buttons.PlayersPetTarget = CreateUnits('pettarget')
        RegisterUnitWatch(self.Data.Buttons.PlayersPetTarget)
        self.__PLAYERSPETTARGET = C.ObjMetaPos:NEW(self.Data.Buttons.PlayersPetTarget, 'PLAYERSPETTARGET')
        self.__PLAYERSPETTARGET:INITIAL()
        table.insert(self.Data.Update.Single, self.Data.Buttons.PlayersPetTarget)
    end
    if DB['CREATE']['PARTY'] then
        if not self.PartyTemplate then
            self.PartyTemplate = CreateFrame('Frame', nil, UIParent, 'SecureFrameTemplate')
            self.__PARTY = C.ObjMetaPos:NEW(self.PartyTemplate, 'PARTY')
            self.__PARTY:INITIAL()
        end
        for i = 1, 4 do
            local unit = 'party' .. i
            self.Data.Buttons.Party[i] = CreateUnits(unit)
            self.Data.Buttons.Party[i]:SetSize(120, 50)
            self.Data.Buttons.Party[i]:SetParent(self.PartyTemplate)
            RegisterUnitWatch(self.Data.Buttons.Party[i])
            if i == 1 then
                self.Data.Buttons.Party[i]:SetPoint('TOPLEFT', self.PartyTemplate, 'TOPLEFT')
            else
                self.Data.Buttons.Party[i]:SetPoint('TOPLEFT', self.Data.Buttons.Party[i - 1], 'BOTTOMLEFT', 0, -5)
            end
        end
    end
    if DB['CREATE']['PLAYERBAR'] and DB['CREATE']['PLAYER'] then
        self.PlayerCastbar = Castbar:CreateCastbar('player')
        self.__PLAYERSBAR = C.ObjMetaPos:NEW(self.PlayerCastbar, 'PLAYERCASTBAR')
        self.__PLAYERSBAR:INITIAL()
    end
    if DB['CREATE']['TARGETBAR'] and DB['CREATE']['TARGET'] then
        self.TargetCastbar = Castbar:CreateCastbar('target')
        self.__TARGETSBAR = C.ObjMetaPos:NEW(self.TargetCastbar, 'TARGETCASTBAR')
        self.__TARGETSBAR:INITIAL()
    end
    ]]
end

--[[

frame:SetAttribute('useOwnerUnit', true)
frame:SetAttribute('filterOnPet', true)

for _, child in ipairs(Data.Raid:GetChildren()) do

Interface\FrameXML\SecureGroupHeaders.lua
List of the various configuration attributes
======================================================
showRaid = [BOOLEAN] -- true if the header should be shown while in a raid
showParty = [BOOLEAN] -- true if the header should be shown while in a party and not in a raid
showPlayer = [BOOLEAN] -- true if the header should show the player when not in a raid
showSolo = [BOOLEAN] -- true if the header should be shown while not in a group (implies showPlayer)
nameList = [STRING] -- a comma separated list of player names (not used if 'groupFilter' is set)
groupFilter = [1-8, STRING] -- a comma seperated list of raid group numbers and/or uppercase class names and/or uppercase roles
roleFilter = [STRING] -- a comma seperated list of MT/MA/Tank/Healer/DPS role strings
strictFiltering = [BOOLEAN]

point = [STRING] -- a valid XML anchoring point (Default: 'TOP')
xOffset = [NUMBER] -- the x-Offset to use when anchoring the unit buttons (Default: 0)
yOffset = [NUMBER] -- the y-Offset to use when anchoring the unit buttons (Default: 0)
sortMethod = ['INDEX', 'NAME', 'NAMELIST'] -- defines how the group is sorted (Default: 'INDEX')
sortDir = ['ASC', 'DESC'] -- defines the sort order (Default: 'ASC')
template = [STRING] -- the XML template to use for the unit buttons
templateType = [STRING] - specifies the frame type of the managed subframes (Default: 'Button')
groupBy = [nil, 'GROUP', 'CLASS', 'ROLE', 'ASSIGNEDROLE'] - specifies a 'grouping' type to apply before regular sorting (Default: nil)
groupingOrder = [STRING] - specifies the order of the groupings (ie. '1,2,3,4,5,6,7,8')
maxColumns = [NUMBER] - maximum number of columns the header will create (Default: 1)
unitsPerColumn = [NUMBER or nil] - maximum units that will be displayed in a singe column, nil is infinite (Default: nil)
startingIndex = [NUMBER] - the index in the final sorted unit list at which to start displaying units (Default: 1)
columnSpacing = [NUMBER] - the amount of space between the rows/columns (Default: 0)
columnAnchorPoint = [STRING] - the anchor point of each new column (ie. use LEFT for the columns to grow to the right)

]]


function Units:CreateFakeUnit()
    local button = CreateFrame('Button', 'EtherFakeUnitButton', UIParent, 'Ether_ButtonTemplate')
    button:SetPoint('CENTER', 0, 200)
    button:SetSize(120, 50)
    button:SetScale(1)
    button:SetAlpha(1)
    C.Setup:CreateBorder(button, 1, 1)
    C.Setup:HealthBar(button, 40, 'HORIZONTAL')
    C.Setup:PowerBar(button)
    C.Setup:Name(button, 10, 0)

    local token
    local guid = UnitGUID('target')
    if guid then
        token = UnitTokenFromGUID(guid)
    end
    if token then
        button.unit = token
        button:SetAttribute('unit', button.unit)
    end

    button:RegisterForClicks('AnyUp')
    button:RegisterForDrag('LeftButton')
    button:SetMovable(true)
    button:SetScript('OnDragStart', function(self)
        if not InCombatLockdown() then self:StartMoving() end
    end)

    button:SetScript('OnDragStop', function(self)
        if not InCombatLockdown() then self:StopMovingOrSizing() end
    end)
    if button.token then
        button:SetScript('OnEnter', function()
            GameTooltip:SetOwner(button, 'ANCHOR_RIGHT')
            GameTooltip:SetUnit(button.token)
            GameTooltip:Show()
        end)

        button:SetScript('OnLeave', GameTooltip_Hide)
    end
    local name = UnitName('target')
    button.Name:SetText(name or "UNKNOWN")
    button:SetAttribute("*type1", "target")
    button:SetAttribute("*type2", "togglemenu")


    if not self.FakeUpdater and button.Name:GetText() ~= "UNKNOWN" then
        self.FakeUpdater = C_Timer.NewTicker(0.9, function()
            local health, healthMax = UnitHealth(button.unit), UnitHealthMax(button.unit)
            if button.healthBar and healthMax > 0 then
                button.healthBar:SetMinMaxValues(0, healthMax)
                button.healthBar:SetValue(health)
            end

            local power, powerMax = UnitPower(button.unit), UnitPowerMax(button.unit)
            if button.powerBar and powerMax > 0 then
                button.powerBar:SetMinMaxValues(0, powerMax)
                button.powerBar:SetValue(power)
            end
        end)
    end

C.Update:HealthBar(button)
C.Update:PowerBar(button)
C.Update:NameUpdate(button, 10, 0)

    if name and guid then
        table.insert(C.Units.Data.Buttons.Fake, {
            name = name,
            guid = guid
        })
    end

    return button
end
