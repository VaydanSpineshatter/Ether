local _, Ether = ...
local UnitIsAFK = UnitIsAFK
local UnitIsDND = UnitIsDND
local UnitIsConnected = UnitIsConnected
local UnitHasIncomingResurrection = UnitHasIncomingResurrection
local GetReadyCheckStatus = GetReadyCheckStatus
local GetPartyAssignment = GetPartyAssignment
local Enum = Enum
local GetLoot = C_PartyInfo.GetLootMethod
local pairs, ipairs = pairs, ipairs
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsCharmed = UnitIsCharmed
local UnitIsDead = UnitIsDead
local UnitIsUnit = UnitIsUnit
local connectionIcon = "Interface\\CharacterFrame\\Disconnect-Icon"
local deadIcon = "Interface\\Icons\\Spell_Holy_GuardianSpirit"
local ReadyCheck_Ready = "Interface\\RaidFrame\\ReadyCheck-Ready"
local ReadyCheck_NotReady = "Interface\\RaidFrame\\ReadyCheck-NotReady"
local ReadyCheck_Waiting = "Interface\\RaidFrame\\ReadyCheck-Waiting"
local leaderIcon = "Interface\\GroupFrame\\UI-Group-LeaderIcon"
local targetIcon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons"
local mainTankIcon = "Interface\\GroupFrame\\UI-Group-MainTankIcon"
local mainAssistIcon = "Interface\\GroupFrame\\UI-Group-MainAssistIcon"
local rezIcon = "Interface\\RaidFrame\\Raid-Icon-Rez"
local masterlootIcon = "Interface\\GroupFrame\\UI-Group-MasterLooter"
local charmedIcon = "Interface\\Icons\\Spell_Shadow_Charm"
local AFK = [[|cE600CCFFAFK|r]]
local DND = [[|cffCC66FFDND|r]]
local Events = {}
local RegisterIndicatorEvent, UnregisterIndicatorEvent
do
    local frame
    local IsEventValid = C_EventUtils.IsEventValid
    function RegisterIndicatorEvent(castEvent, func)
        if not frame then
            frame = CreateFrame("Frame")
            frame:SetScript("OnEvent", function(self, event, unit)
                Events[event](self, event, unit)
            end)
        end
        if not Events[castEvent] then
            if not frame:IsEventRegistered(castEvent) then
                frame:RegisterEvent(castEvent)
            end
        end
        Events[castEvent] = func
    end
    function UnregisterIndicatorEvent(...)
        if frame then
            for i = select("#", ...), 1, -1 do
                local event = select(i, ...)
                if IsEventValid(event) then
                    if Events[event] then
                        frame:UnregisterEvent(event)
                    end
                end
                Events[event] = nil
            end
        end
    end
end

function Ether:HideIndicators(hide)
    for _, button in pairs(Ether.unitButtons.raid) do
        if button and button.Indicators and button.Indicators[hide] then
            button.Indicators[hide]:Hide()
        end
    end
end

function Ether.SaveIndicatorsPos(icon, number)
    for _, button in pairs(Ether.unitButtons.raid) do
        if button and button.Indicators and button.Indicators[icon] then
            button.Indicators[icon]:Hide()
            button.Indicators[icon]:ClearAllPoints()
            button.Indicators[icon]:SetPoint(Ether.DB[1002][number][2], button.healthBar, Ether.DB[1002][number][2], Ether.DB[1002][number][3], Ether.DB[1002][number][4])
            button.Indicators[icon]:SetSize(Ether.DB[1002][number][1], Ether.DB[1002][number][1])
            button.Indicators[icon]:Show()
        end
    end
    Ether:UpdateIndicatorsByIndex(number)
end

local IndicatorMap = {
    [1] = "ReadyCheck",
    [2] = "Connection",
    [3] = "RaidTarget",
    [4] = "Resurrection",
    [5] = "GroupLeader",
    [6] = "MasterLoot",
    [7] = "UnitFlags",
    [8] = "PlayerRoles",
    [9] = "PlayerFlags"
}

function Ether:InitialIndicatorsPos()
    if InCombatLockdown() then return end
    for _, button in pairs(Ether.unitButtons.raid) do
        if button and button.Indicators then
            for index, value in ipairs(IndicatorMap) do
                local icon = button.Indicators[value]
                local data = Ether.DB[1002][index]
                if icon and data then
                    icon:Hide()
                    icon:ClearAllPoints()
                    icon:SetPoint(data[2], button.healthBar, data[2], data[3], data[4])
                    icon:SetSize(data[1], data[1])
                    icon:Show()
                end
            end
        end
    end
end

local function UpdateReadyCheck(_, event)
    if event == "READY_CHECK" then
        for unit, button in pairs(Ether.unitButtons.raid) do
            if button and unit then
                local status = GetReadyCheckStatus(unit)
                if (status) then
                    if (status == "ready") then
                        button.Indicators.ReadyCheck:SetTexture(ReadyCheck_Ready)
                        button.Indicators.ReadyCheck:Show()
                    elseif (status == "notready") then
                        button.Indicators.ReadyCheck:SetTexture(ReadyCheck_NotReady)
                        button.Indicators.ReadyCheck:Show()
                    elseif (status == "waiting") then
                        button.Indicators.ReadyCheck:SetTexture(ReadyCheck_Waiting)
                        button.Indicators.ReadyCheck:Show()
                    end
                else
                    button.Indicators.ReadyCheck:Hide()
                end
            end
        end
    end
end

local function UpdateConfirm(_, event)
    if event == "READY_CHECK_CONFIRM" then
        for unit, button in pairs(Ether.unitButtons.raid) do
            if button and unit then
                local status = GetReadyCheckStatus(unit)
                if (status == "ready") then
                    button.Indicators.ReadyCheck:SetTexture(ReadyCheck_Ready)
                    button.Indicators.ReadyCheck:Show()
                elseif (status == "notready") then
                    button.Indicators.ReadyCheck:SetTexture(ReadyCheck_NotReady)
                    button.Indicators.ReadyCheck:Show()
                end
            end
        end
    end
end

local updater = nil
local function HideReadyCheckIcons()
    for _, button in pairs(Ether.unitButtons.raid) do
        if button and button.Indicators and button.Indicators.ReadyCheck then
            button.Indicators.ReadyCheck:Hide()
        end
    end
    if updater then
        updater:Cancel()
        updater = nil
    end
end

local function UpdateFinish(_, event)
    if event == "READY_CHECK_FINISHED" then
        if not updater then
            updater = C_Timer.After(5, HideReadyCheckIcons)
        end
    end
end

local function UpdateConnection(_, event, unit)
    if not unit then return end
    if event == "UNIT_CONNECTION" then
        local button = Ether.unitButtons.raid[unit]
        if not button or not button.Indicators or not button.Indicators.Connection then return end
        local isConnected = UnitIsConnected(unit)
        if not isConnected then
            button.healthBar:SetStatusBarColor(0.5, 0.5, 0.5)
            button.Indicators.Connection:SetTexture(connectionIcon)
            button.Indicators.Connection:Show()
        else
            button.Indicators.Connection:Hide()
        end
    end
end

local function UpdateRaidTarget(_, event)
    if event == "RAID_TARGET_UPDATE" then
        for unit, button in pairs(Ether.unitButtons.raid) do
            if button and button.Indicators and UnitExists(unit) then
                local index = GetRaidTargetIndex(unit)
                if index then
                    button.Indicators.RaidTarget:SetTexture(targetIcon)
                    SetRaidTargetIconTexture(button.Indicators.RaidTarget, index)
                    button.Indicators.RaidTarget:Show()
                else
                    button.Indicators.RaidTarget:Hide()
                end
            end
        end
        for unit, button in pairs(Ether.unitButtons.solo) do
            if button and button.RaidTarget and UnitExists(unit) then
                local index = GetRaidTargetIndex(unit)
                if index then
                    button.RaidTarget:SetTexture(targetIcon)
                    SetRaidTargetIconTexture(button.RaidTarget, index)
                    button.RaidTarget:Show()
                else
                    button.RaidTarget:Hide()
                end
            end
        end
    end
end

local function UpdateResurrection(_, event, unit)
    if not unit then return end
    if event == "INCOMING_RESURRECT_CHANGED" then
        local button = Ether.unitButtons.raid[unit]
        if not button or not button.Indicators or not button.Indicators.Resurrection then return end
        local Resurrection = UnitHasIncomingResurrection(unit)
        if (Resurrection) then
            button.Indicators.Resurrection:SetTexture(rezIcon)
            button.Indicators.Resurrection:Show()
        else
            button.Indicators.Resurrection:Hide()
        end
    end
end

local function UpdateGroupLeader(_, event)
    if event == "PARTY_LEADER_CHANGED" then
        for unit, button in pairs(Ether.unitButtons.raid) do
            if button and button.Indicators and unit then
                local IsLeader = UnitIsGroupLeader(unit)
                if (IsLeader) then
                    button.Indicators.GroupLeader:SetTexture(leaderIcon)
                    button.Indicators.GroupLeader:Show()
                else
                    button.Indicators.GroupLeader:Hide()
                end
            end
        end
    end
end

local function UpdateMasterLoot(_, event)
    if event == "PARTY_LOOT_METHOD_CHANGED" then
        for unit, button in pairs(Ether.unitButtons.raid) do
            if button and button.Indicators and unit then
                button.Indicators.MasterLoot:SetTexture(masterlootIcon)
                button.Indicators.MasterLoot:Hide()
                local lootType, partyID, raidID = GetLoot()
                if lootType == Enum.LootMethod.Masterlooter then
                    local masterLooterUnit = raidID and ((raidID == 0) and "player" or "raid" .. raidID) or partyID and ((partyID == 0) and "player" or "party" .. partyID)
                    if masterLooterUnit and UnitIsUnit(unit, masterLooterUnit) then
                        button.Indicators.MasterLoot:Show()
                    else
                        button.Indicators.MasterLoot:Hide()
                    end
                end
            end
        end
    end
end

local function unitIsDead(button)
    button.top:SetColorTexture(0, 0, 0, 1)
    button.right:SetColorTexture(0, 0, 0, 1)
    button.left:SetColorTexture(0, 0, 0, 1)
    button.bottom:SetColorTexture(0, 0, 0, 1)
end

local function UpdateUnitFlags(_, event, unit)
    if not unit then return end
    if event == "UNIT_FLAGS" then
        local button = Ether.unitButtons.raid[unit]
        if not button or not button.Indicators or not button.Indicators.UnitFlags then return end
        local dead = UnitIsDead(unit)
        local charmed = UnitIsCharmed(unit)
        if charmed then
            button.name:SetTextColor(1.00, 0.00, 0.00)
            button.Indicators.UnitFlags:SetTexture(charmedIcon)
            button.Indicators.UnitFlags:Show()
        elseif dead then
            button.Indicators.UnitFlags:SetTexture(deadIcon)
            button.healthBar:SetValue(0)
            button.Indicators.UnitFlags:Show()
            unitIsDead(button)
        else
            button.Indicators.UnitFlags:Hide()
            button.name:SetTextColor(1, 1, 1)
        end
    end
end

local function UpdatePlayerRoles(_, event)
    if event == "PLAYER_ROLES_ASSIGNED" then
        for unit, button in pairs(Ether.unitButtons.raid) do
            if button and button.Indicators and unit then
                if not IsInRaid() then
                    button.Indicators.PlayerRoles:Hide()
                else
                    if (GetPartyAssignment("MAINTANK", unit)) then
                        button.Indicators.PlayerRoles:SetTexture(mainTankIcon)
                        button.Indicators.PlayerRoles:Show()
                    elseif (GetPartyAssignment("MAINASSIST", unit)) then
                        button.Indicators.PlayerRoles:SetTexture(mainAssistIcon)
                        button.Indicators.PlayerRoles:Show()
                    else
                        button.Indicators.PlayerRoles:Hide()
                    end
                end
            end
        end
    end
end

local function OnAfk(self)
    self.isActive = true
    if Ether.DB[801][1] == 1 then
        Ether:CastBarDisable("player")
    end
    if Ether.DB[801][2] == 1 then
        Ether:CastBarDisable("target")
    end
    Ether:NameDisable()
    Ether:HealthDisable()
    Ether:PowerDisable()
    Ether:AuraDisable()
    Ether:IndicatorsDisable()
    Ether:CleanupAllRaidIcons()
    if Ether.DB[801][6] == 1 then
        C_Timer.After(0.1, function()
            Ether:RangeDisable()
        end)
    end
end

local function NotAfk(self)
    self.isActive = false
    if Ether.DB[801][1] == 1 then
        Ether:CastBarEnable("player")
    end
    if Ether.DB[801][2] == 1 then
        Ether:CastBarEnable("target")
    end
    Ether:NameEnable()
    Ether:HealthEnable()
    Ether:PowerEnable()
    Ether:AuraEnable()
    Ether:IndicatorsEnable()
    Ether:FullUpdateIndicators()
    if Ether.DB[1001][4] == 1 then
        for unit in pairs(Ether.unitButtons.raid) do
            if UnitExists(unit) then
                Ether:UpdateRaidIsHelpful(unit)
            end
        end
    end
    if Ether.DB[801][6] == 1 then
        C_Timer.After(0.1, function()
            Ether:RangeEnable()
        end)
    end
end

local function UpdatePlayerFlags(self, event, unit)
    if not unit then return end
    if event == "PLAYER_FLAGS_CHANGED" then
        local button = Ether.unitButtons.raid[unit]
        if not button or not button.Indicators or not button.Indicators.PlayerFlags then return end
        local away = UnitIsAFK(unit)
        local dnd = UnitIsDND(unit)
        if away then
            button.Indicators.PlayerFlags:SetText(AFK)
            button.Indicators.PlayerFlags:Show()
        elseif dnd then
            button.Indicators.PlayerFlags:SetText(DND)
            button.Indicators.PlayerFlags:Show()
        else
            button.Indicators.PlayerFlags:Hide()
        end
    end
    if Ether.DB[401][4] == 1 then
        if UnitIsAFK("player") then
            if not self.isActive then
                OnAfk(self)
            end
        else
            if self.isActive then
                NotAfk(self)
            end
        end
    end
end

local function EnableReadyCheck()
    RegisterIndicatorEvent("READY_CHECK", UpdateReadyCheck)
    RegisterIndicatorEvent("READY_CHECK_CONFIRM", UpdateConfirm)
    RegisterIndicatorEvent("READY_CHECK_FINISHED", UpdateFinish)
end
local function DisableReadyCheck()
    UnregisterIndicatorEvent("READY_CHECK")
    UnregisterIndicatorEvent("READY_CHECK_CONFIRM")
    UnregisterIndicatorEvent("READY_CHECK_FINISHED")
    HideReadyCheckIcons()
end

local function EnableConnection()
    RegisterIndicatorEvent("UNIT_CONNECTION", UpdateConnection)
end

local function EnableRaidTarget()
    RegisterIndicatorEvent("RAID_TARGET_UPDATE", UpdateRaidTarget)
end

local function EnableResurrection()
    RegisterIndicatorEvent("INCOMING_RESURRECT_CHANGED", UpdateResurrection)
end

local function EnableGroupLeader()
    RegisterIndicatorEvent("PARTY_LEADER_CHANGED", UpdateGroupLeader)
end

local function EnableMasterLoot()
    RegisterIndicatorEvent("PARTY_LOOT_METHOD_CHANGED", UpdateMasterLoot)
end

local function EnableUnitFlags()
    RegisterIndicatorEvent("UNIT_FLAGS", UpdateUnitFlags)
end

local function EnablePlayerRoles()
    RegisterIndicatorEvent("PLAYER_ROLES_ASSIGNED", UpdatePlayerRoles)
end

local function EnablePlayerFlags()
    RegisterIndicatorEvent("PLAYER_FLAGS_CHANGED", UpdatePlayerFlags)
end

local function DisableConnection()
    UnregisterIndicatorEvent("UNIT_CONNECTION")
    Ether:HideIndicators("Connection")
end

local function DisableRaidTarget()
    UnregisterIndicatorEvent("RAID_TARGET_UPDATE")
    Ether:HideIndicators("RaidTarget")
end

local function DisableResurrection()
    UnregisterIndicatorEvent("INCOMING_RESURRECT_CHANGED")
    Ether:HideIndicators("Resurrection")
end

local function DisableGroupLeader()
    UnregisterIndicatorEvent("PARTY_LEADER_CHANGED")
    Ether:HideIndicators("GroupLeader")
end

local function DisableMasterLoot()
    UnregisterIndicatorEvent("PARTY_LOOT_METHOD_CHANGED")
    Ether:HideIndicators("MasterLoot")
end

local function DisableUnitFlags()
    UnregisterIndicatorEvent("UNIT_FLAGS")
    Ether:HideIndicators("UnitFlags")
end

local function DisablePlayerRoles()
    UnregisterIndicatorEvent("PLAYER_ROLES_ASSIGNED")
    Ether:HideIndicators("PlayerRoles")
end

local function DisablePlayerFlags()
    UnregisterIndicatorEvent("PLAYER_FLAGS_CHANGED")
    Ether:HideIndicators("PlayerFlags")
end

local indicatorsHandlers = {
    [1] = {EnableReadyCheck, DisableReadyCheck},
    [2] = {EnableConnection, DisableConnection, UpdateConnection},
    [3] = {EnableRaidTarget, DisableRaidTarget, UpdateRaidTarget},
    [4] = {EnableResurrection, DisableResurrection},
    [5] = {EnableGroupLeader, DisableGroupLeader, UpdateGroupLeader},
    [6] = {EnableMasterLoot, DisableMasterLoot, UpdateMasterLoot},
    [7] = {EnableUnitFlags, DisableUnitFlags, UpdateUnitFlags},
    [8] = {EnablePlayerRoles, DisablePlayerRoles, UpdatePlayerRoles},
    [9] = {EnablePlayerFlags, DisablePlayerFlags, UpdatePlayerFlags},
}

function Ether:IndicatorsToggle()
    local I = Ether.DB[501]
    for index, handlers in ipairs(indicatorsHandlers) do
        if I[index] == 1 then
            handlers[1]()
        end
        if I[index] == 0 then
            handlers[2]()
        end
    end
end

function Ether:IndicatorsEnable()
    local I = Ether.DB[501]
    for index, handlers in ipairs(indicatorsHandlers) do
        if I[index] == 1 then
            handlers[1]()
        end
    end
end

function Ether:IndicatorsDisable()
    for index, handlers in ipairs(indicatorsHandlers) do
        if handlers[2] and index ~= 9 then
            handlers[2]()
        end
    end
end

function Ether:UpdateIndicatorsByIndex(index)
    local I = Ether.DB[501]
    for _, handlers in ipairs(indicatorsHandlers) do
        if I[index] == 1 and handlers[3] then
            for data in pairs(Events) do
                handlers[3](_, data)
            end
        end
    end
end

function Ether:FullUpdateIndicators()
    local I = Ether.DB[501]
    for index, handlers in ipairs(indicatorsHandlers) do
        if I[index] == 1 and handlers[3] then
            for data in pairs(Events) do
                handlers[3](_, data)
            end
        end
    end
end