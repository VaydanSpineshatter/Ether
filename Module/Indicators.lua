local Ether                       = select(2, ...)
local C                           = Ether
local Indicators                  = C.Indicators
local Data                        = C.Data
local UnitIsGhost                 = UnitIsGhost
local UnitIsConnected             = UnitIsConnected
local UnitIsAFK                   = UnitIsAFK
local UnitHasIncomingResurrection = UnitHasIncomingResurrection
local GetReadyCheckStatus         = GetReadyCheckStatus
local GetPartyAssignment          = GetPartyAssignment
local UnitInRaid                  = UnitInRaid
local UnitGroupRolesAssigned      = UnitGroupRolesAssigned
local IsEventValid                = C_EventUtils.IsEventValid
local Enum                        = Enum
local UnitClass                   = UnitClass
local GetLoot                     = C_PartyInfo.GetLootMethod
local UnitIsUnit                  = UnitIsUnit
local UnitIsDND                   = UnitIsDND
local pairs                       = pairs

local Registered                  = {}
Indicators.Registered             = Registered

local function OnEvent(_, event, ...)
    for _, func in pairs(Registered[event]) do
        func(...)
    end
end

local eventUpdater
if not eventUpdater then
    eventUpdater = CreateFrame("Frame")
    if not eventUpdater:GetScript("OnEvent") then
        eventUpdater:SetScript("OnEvent", OnEvent)
    end
end

local function RegisterNormalEventUpdater(eventName, func, key)
    if not Registered[eventName] then
        Registered[eventName] = {}
        if not eventUpdater:IsEventRegistered(eventName) then
            if IsEventValid(eventName) then
                eventUpdater:RegisterEvent(eventName)
            end
        end
    end
    Registered[eventName][key] = func
end
C.Indicators.RegisterNormalEventUpdater = RegisterNormalEventUpdater

local function UnregisterEventUpdater(eventName, key)
    if Registered[eventName] then
        Registered[eventName][key] = nil

        if not next(Registered[eventName]) then
            Registered[eventName] = nil
            eventUpdater:UnregisterEvent(eventName)
        end
    end
end

local function GetKey(key)
    for _, info in pairs(Registered) do
        if info and info[key] then
            return true
        end
    end
    return false
end
Indicators.GetKey = GetKey

local function UpdateLeader()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if frame.Indicators.leader then
                if (UnitIsGroupLeader(frame.unit)) then
                    frame.Indicators.leader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
                    frame.Indicators.leader:SetTexCoord(0, 1, 0, 1)
                    frame.Indicators.leader:Show()
                else
                    frame.Indicators.leader:Hide()
                end
            end
        end
    end
end

local function EnableLeader()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if not frame.Indicators.leader then
                frame.Indicators.leader = frame.healthBar:CreateTexture(nil, 'OVERLAY')
                frame.Indicators.leader:SetPoint('RIGHT', 0, -2)
                frame.Indicators.leader:SetSize(12, 12)
                frame.Indicators.leader:Hide()
            end
        end
    end

    RegisterNormalEventUpdater('PARTY_LEADER_CHANGED', UpdateLeader, 'leaderKey')
end

local function DisableLeader()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators and frame.Indicators.leader then
            frame.Indicators.leader:Hide()
        end
    end
    UnregisterEventUpdater('PARTY_LEADER_CHANGED', 'leaderKey')
end
Indicators.EnableLeader = EnableLeader
Indicators.DisableLeader = DisableLeader

function Indicators:UpdateRaidTarget(frame)
    if not frame or frame.unit then return end

    local index = GetRaidTargetIndex(frame.unit)
    if (index) then
        frame.Indicators.raidtarget:Show()
        frame.Indicators.raidtarget:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
        SetRaidTargetIconTexture(frame.Indicators.raidtarget, index)
    else
        frame.Indicators.raidtarget:Hide()
    end
end

local function EnableRaidTarget()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if not frame.Indicators.raidtarget then
                frame.Indicators.raidtarget = frame.healthBar:CreateTexture(nil, 'OVERLAY')
                frame.Indicators.raidtarget:SetPoint('BOTTOM', -2, 1)
                frame.Indicators.raidtarget:SetSize(12, 12)
                frame.Indicators.raidtarget:Hide()
            end
        end
    end
end
local function DisableRaidTarget()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators and frame.Indicators.raidtarget then
            frame.Indicators.raidtarget:Hide()
        end
    end
end
Indicators.EnableRaidTarget = EnableRaidTarget
Indicators.DisableRaidTarget = DisableRaidTarget

local function UpdateRole()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if not frame.Indicators.role then return end
            local role = UnitGroupRolesAssigned(frame.unit)
            if (role) then
                if (role == "TANK") then
                    frame.Indicators.role:SetTexCoord(0, 19 / 64, 22 / 64, 41 / 64)
                    frame.Indicators.role:Show()
                elseif (role == "HEALER") then
                    frame.Indicators.role:SetTexCoord(20 / 64, 39 / 64, 1 / 64, 20 / 64)
                    frame.Indicators.role:Show()
                elseif (role == "DAMAGER") then
                    frame.Indicators.role:SetTexCoord(20 / 64, 39 / 64, 22 / 64, 41 / 64)
                    frame.Indicators.role:Show()
                else
                    frame.Indicators.role:Hide()
                end
            end
        end
    end
end

local function EnableRole()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if not frame.Indicators.role then
                frame.Indicators.role = frame.healthBar:CreateTexture(nil, 'OVERLAY')
                frame.Indicators.role:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
                frame.Indicators.role:SetPoint('RIGHT', 0, 9)
                frame.Indicators.role:SetSize(12, 12)
                frame.Indicators.role:Hide()
            end
        end
    end

    RegisterNormalEventUpdater('PLAYER_ROLES_ASSIGNED', UpdateRole, 'roleKey')
end
local function DisableRole()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators and frame.Indicators.role then
            frame.Indicators.role:Hide()
        end
    end
    UnregisterEventUpdater("PLAYER_ROLES_ASSIGNED", 'roleKey')
end
Indicators.EnableRole = EnableRole
Indicators.DisableRole = DisableRole

local function UpdateMainTank()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if not frame.Indicators.maintank then return end
            if not UnitInRaid('player') then
                frame.Indicators.maintank:Hide()
            elseif (GetPartyAssignment("MAINTANK", frame.unit)) then
                frame.Indicators.maintank:SetTexture("Interface\\GroupFrame\\UI-Group-MainTankIcon")
                frame.Indicators.maintank:Show()
            elseif (GetPartyAssignment("MAINASSIST", frame.unit)) then
                frame.Indicators.maintank:SetTexture("Interface\\GroupFrame\\UI-Group-MainAssistIcon")
                frame.Indicators.maintank:Show()
            else
                frame.Indicators.maintank:Hide()
            end
        end
    end
end

local function EnableMainTank()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if not frame.Indicators.maintank then
                frame.Indicators.maintank = frame.healthBar:CreateTexture(nil, 'OVERLAY')
                frame.Indicators.maintank:SetPoint('LEFT')
                frame.Indicators.maintank:SetSize(14, 14)
                frame.Indicators.maintank:Hide()
            end
        end
    end
    RegisterNormalEventUpdater('PLAYER_ROLES_ASSIGNED', UpdateMainTank, 'maintankKey')
end
local function DisableMainTank()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators and frame.Indicators.maintank then
            frame.Indicators.maintank:Hide()
        end
    end
    UnregisterEventUpdater("PLAYER_ROLES_ASSIGNED", 'maintankKey')
end
Indicators.EnableMainTank = EnableMainTank
Indicators.DisableMainTank = DisableMainTank

local function UpdateReadyCheck()
    for unit, frame in pairs(C.Units.Data.Update.Cache) do
        if unit and frame then
            if UnitIsAFK(unit) then
                frame.Indicators.ready:SetTexture(unpack(C.Forming.Tex.N))
                frame.Indicators.ready:Show()
                return
            end
            local status = GetReadyCheckStatus(unit)
            if (status) then
                if (status == "ready") then
                    frame.Indicators.ready:SetTexture(unpack(C.Forming.Tex.R))
                    frame.Indicators.ready:Show()
                elseif (status == "notready") then
                    frame.Indicators.ready:SetTexture(unpack(C.Forming.Tex.N))
                    frame.Indicators.ready:Show()
                elseif (status == "waiting") then
                    frame.Indicators.ready:SetTexture(unpack(C.Forming.Tex.W))
                    frame.Indicators.ready:Show()
                end
            end
        end
    end
end

local function UpdateConfirm()
    for unit, frame in pairs(C.Units.Data.Update.Cache) do
        if unit and frame then
            local status = GetReadyCheckStatus(unit)
            if (status) then
                if (status == "ready") then
                    frame.Indicators.ready:SetTexture(unpack(C.Forming.Tex.R))
                    frame.Indicators.ready:Show()
                elseif (status == "notready") then
                    frame.Indicators.ready:SetTexture(unpack(C.Forming.Tex.N))
                    frame.Indicators.ready:Show()
                end
            end
        end
    end
end

local function UpdateFinish()
    for unit, frame in pairs(C.Units.Data.Update.Cache) do
        if unit and frame then
            if not frame.Indicators.ready.Timer then
                frame.Indicators.ready.Timer = C_Timer.After(5, function()
                    frame.Indicators.ready:Hide()
                    frame.Indicators.ready.Timer = nil
                end)
            end
        end
    end
end

local function EnableReady()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if not frame.Indicators.ready then
                frame.Indicators.ready = frame.healthBar:CreateTexture(nil, 'OVERLAY')
                frame.Indicators.ready:SetSize(14, 14)
                frame.Indicators.ready:SetPoint('BOTTOM', frame.Name, 'TOP', 0, 0)
                frame.Indicators.ready:Hide()
            end
        end
    end
    RegisterNormalEventUpdater('READY_CHECK', UpdateReadyCheck, 'readyKey')
    RegisterNormalEventUpdater('READY_CHECK_CONFIRM', UpdateConfirm, 'confirmKey')
    RegisterNormalEventUpdater('READY_CHECK_FINISHED', UpdateFinish, 'finishedKey')
end
local function DisableReady()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators and frame.Indicators.ready then
            frame.Indicators.ready:Hide()
        end
    end
    UnregisterEventUpdater('READY_CHECK', 'readyKey')
    UnregisterEventUpdater('READY_CHECK_CONFIRM', 'confirmKey')
    UnregisterEventUpdater('READY_CHECK_FINISHED', 'finishedKey')
end
Indicators.EnableReady = EnableReady
Indicators.DisableReady = DisableReady

local function UpdateOffline()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if (not frame.Indicators.offline) then return end
            local connection = UnitIsConnected(frame.unit)
            if (not connection) then
                frame.Indicators.offline:Show()
            else
                frame.Indicators.offline:Hide()
            end
        end
    end
end

local function EnableOffline()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if not frame.Indicators.offline then
                frame.Indicators.offline = frame.healthBar:CreateTexture(nil, 'OVERLAY')
                frame.Indicators.offline:SetTexture("Interface\\CharacterFrame\\Disconnect-Icon")
                frame.Indicators.offline:SetTexCoord(0, 1, 0, 1)
                frame.Indicators.offline:SetPoint('BOTTOM', frame.Name, 'TOP', 0, 1)
                frame.Indicators.offline:SetSize(24, 24)
                frame.Indicators.offline:Hide()
            end
        end
    end
    RegisterNormalEventUpdater('UNIT_CONNECTION', UpdateOffline, 'offlineKey')
end
local function DisableOffline()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators and frame.Indicators.offline then
            frame.Indicators.offline:Hide()
        end
    end
    UnregisterEventUpdater('UNIT_CONNECTION', 'offlineKey')
end
Indicators.EnableOffline = EnableOffline
Indicators.DisableOffline = DisableOffline

local function UpdateResurrection()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if (not frame.Indicators.resurrection) then return end
            local Resurrection = UnitHasIncomingResurrection(frame.unit)
            if (Resurrection) then
                frame.Indicators.resurrection:Show()
            else
                frame.Indicators.resurrection:Hide()
            end
        end
    end
end

local function EnableResurrection()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if not frame.Indicators.resurrection then
                frame.Indicators.resurrection = frame.healthBar:CreateTexture(nil, 'OVERLAY')
                frame.Indicators.resurrection:SetPoint('CENTER')
                frame.Indicators.resurrection:SetSize(21, 21)
                frame.Indicators.resurrection:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
                frame.Indicators.resurrection:Hide()
            end
        end
    end
    RegisterNormalEventUpdater('INCOMING_RESURRECT_CHANGED', UpdateResurrection, 'resurrectionKey')
end
local function DisableResurrection()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators and frame.Indicators.resurrection then
            frame.Indicators.resurrection:Hide()
        end
    end
    UnregisterEventUpdater('INCOMING_RESURRECT_CHANGED', 'resurrectionKey')
end
Indicators.EnableResurrection = EnableResurrection
Indicators.DisableResurrection = DisableResurrection

local function UpdateGhost()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if (not frame.Indicators.ghost) then return end
            local ghost = UnitIsGhost(frame.unit)
            if (ghost) then
                frame.Indicators.ghost:Show()
            else
                frame.Indicators.ghost:Hide()
            end
        end
    end
end

local function EnableGhost()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if not frame.Indicators.ghost then
                frame.Indicators.ghost = frame.healthBar:CreateTexture(nil, 'OVERLAY')
                frame.Indicators.ghost:SetPoint('CENTER')
                frame.Indicators.ghost:SetSize(21, 21)
                frame.Indicators.ghost:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
                frame.Indicators.ghost:Hide()
            end
        end
    end
    RegisterNormalEventUpdater('PLAYER_FLAGS_CHANGED', UpdateGhost, 'ghostKey')
end

local function DisableGhost()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators and frame.Indicators.ghost then
            frame.Indicators.ghost:Hide()
        end
    end
    UnregisterEventUpdater('PLAYER_FLAGS_CHANGED', 'ghostKey')
end

Indicators.EnableGhost = EnableGhost
Indicators.DisableGhost = DisableGhost

local function UpdateDnd()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if (not frame.Indicators.dnd) then return end
            local dnd = UnitIsDND(frame.unit)
            if (dnd) then
                frame.Indicators.dnd:Show()
            else
                frame.Indicators.dnd:Hide()
            end
        end
    end
end

local function EnableDnd()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if not frame.Indicators.dnd then
                frame.Indicators.dnd = frame.healthBar:CreateFontString(nil, 'OVERLAY')
                frame.Indicators.dnd:SetFont(unpack(Ether.Data.Forming.Font), 10, 'OUTLINE')
                frame.Indicators.dnd:SetPoint('BOTTOM', frame.Name, 'TOP', 0, 1)
                frame.Indicators.dnd:SetText('|cffCC66FF[DND]|r')
                frame.Indicators.dnd:Hide()
            end
        end
    end
    RegisterNormalEventUpdater('PLAYER_FLAGS_CHANGED', UpdateDnd, 'dndKey')
end

local function DisableDnd()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators and frame.Indicators.dnd then
            frame.Indicators.dnd:Hide()
        end
    end
    UnregisterEventUpdater('PLAYER_FLAGS_CHANGED', 'dndKey')
end

Indicators.EnableDnd = EnableDnd
Indicators.DisableDnd = DisableDnd

local function UpdateAway()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if (not frame.Indicators.away) then return end
            local away = UnitIsAFK(frame.unit)
            if (away) then
                frame.Indicators.away:Show()
            else
                frame.Indicators.away:Hide()
            end
        end
    end
end

local function EnableAway()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if not frame.Indicators.away then
                frame.Indicators.away = frame.healthBar:CreateFontString(nil, 'OVERLAY')
                frame.Indicators.away:SetFont(unpack(Ether.Data.Forming.Font), 10, 'OUTLINE')
                frame.Indicators.away:SetPoint('BOTTOM', frame.Name, 'TOP', 0, 1)
                frame.Indicators.away:SetText('|cffff0000[AFK]|r')
                frame.Indicators.away:Hide()
            end
        end
    end
    RegisterNormalEventUpdater('PLAYER_FLAGS_CHANGED', UpdateAway, 'awayKey')
end

local function DisableAway()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators and frame.Indicators.away then
            frame.Indicators.away:Hide()
        end
    end
    UnregisterEventUpdater('PLAYER_FLAGS_CHANGED', 'awayKey')
end

Indicators.EnableAway = EnableAway
Indicators.DisableAway = DisableAway

local function UpdateMasterLoot()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if (not frame.Indicators.masterloot) then return end
            frame.Indicators.masterloot:Hide()

            if not frame.unit or C.DB['INDICATORS']['MASTERLOOT'] ~= 1 then
                return
            end

            local lootType, partyID, raidID = GetLoot()
            if lootType == Enum.LootMethod.Masterlooter then
                local masterLooterUnit = raidID and ((raidID == 0) and "player" or "raid" .. raidID) or
                    partyID and ((partyID == 0) and "player" or "party" .. partyID)

                if masterLooterUnit and UnitIsUnit(frame.unit, masterLooterUnit) then
                    frame.Indicators.masterloot:Show()
                end
            end
        end
    end
end

local function EnableMasterLoot()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if not frame.Indicators.masterloot then
                frame.Indicators.masterloot = frame.healthBar:CreateTexture(nil, 'OVERLAY')
                frame.Indicators.masterloot:SetTexture("Interface\\GroupFrame\\UI-Group-MasterLooter")
                frame.Indicators.masterloot:SetPoint('BOTTOMRIGHT', -2, 11)
                frame.Indicators.masterloot:SetSize(10, 10)
                frame.Indicators.masterloot:Hide()
            end
        end
    end
    RegisterNormalEventUpdater('PARTY_LOOT_METHOD_CHANGED', UpdateMasterLoot, 'masterlootKey')
end

local function DisableMasterLoot()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators and frame.Indicators.masterloot then
            frame.Indicators.masterloot:Hide()
        end
    end
    UnregisterEventUpdater('PARTY_LOOT_METHOD_CHANGED', 'masterlootKey')
end

Indicators.EnableMasterLoot = EnableMasterLoot
Indicators.DisableMasterLoot = DisableMasterLoot

local function GetClassCoordinate(classFilename)
    local Coordinate = Data.ClassCoordinate[classFilename]
    if not Coordinate then
        return 0, 1, 0, 1
    end
    local crop = 0.015
    return Coordinate[1] + crop, Coordinate[2] - crop, Coordinate[3] + crop, Coordinate[4] - crop
end

local function UpdateClassIcon()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if (not frame.Indicators.class) then return end
            local _, classFilename = UnitClass(frame.unit)
            if (classFilename) then
                frame.Indicators.class:SetTexture('Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES')
                frame.Indicators.class:SetTexCoord(GetClassCoordinate(classFilename))
                frame.Indicators.class:Show()
            end
        end
    end
end

local function EnableClassIcon()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators then
            if not frame.Indicators.class then
                frame.Indicators.class = frame.healthBar:CreateTexture(nil, 'OVERLAY')
                frame.Indicators.class:SetSize(14, 14)
                frame.Indicators.class:SetPoint('TOPLEFT', 1, -1)
                frame.Indicators.class:Hide()
            end
        end
    end
    RegisterNormalEventUpdater('GROUP_ROSTER_UPDATE', UpdateClassIcon, 'classKey')
end

local function DisableClassIcon()
    for _, frame in pairs(C.Units.Data.Update.Cache) do
        if frame and frame.Indicators and frame.Indicators.class then
            frame.Indicators.class:Hide()
        end
    end
    UnregisterEventUpdater('GROUP_ROSTER_UPDATE', 'classKey')
end

Indicators.EnableClassIcon = EnableClassIcon
Indicators.DisableClassIcon = DisableClassIcon


---@type IndicatorsID

local function Enable()
    if C.DB['INDICATORS'][1] == 1 then
        EnableReady()
    end
    if C.DB['INDICATORS'][2] == 1 then
        EnableRole()
    end
    if C.DB['INDICATORS'][3] == 1 then
        EnableMainTank()
    end
    if C.DB['INDICATORS'][4] == 1 then
        EnableClassIcon()
    end
    if C.DB['INDICATORS'][5] == 1 then
        EnableOffline()
    end
    if C.DB['INDICATORS'][6] == 1 then
        --  EnableRaidTarget()
    end
    if C.DB['INDICATORS'][7] == 1 then
        EnableResurrection()
    end
    if C.DB['INDICATORS'][8] == 1 then
        EnableLeader()
    end
    if C.DB['INDICATORS'][9] == 1 then
        EnableMasterLoot()
    end
    if C.DB['INDICATORS'][10] == 1 then
        EnableGhost()
    end
    if C.DB['INDICATORS'][11] == 1 then
        EnableAway()
    end
    if C.DB['INDICATORS'][12] == 1 then
        EnableDnd()
    end
end
Indicators.Enable = Enable
