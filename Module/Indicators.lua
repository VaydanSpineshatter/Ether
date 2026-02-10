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
local UnitIsUnit = UnitIsUnit
local connectionIcon = "Interface\\CharacterFrame\\Disconnect-Icon"
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
        end
    end
    Ether:FullUpdateIndicators()
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

local function FindUnitButton(unit)
    local button = Ether.unitButtons.raid[unit]
    if button and button.Indicators and button.unit == unit then
        return button
    end
    return nil
end

local function Indicator(_, event)
    if event == "READY_CHECK" then
        for unit, button in pairs(Ether.unitButtons.raid) do
            if button and button.Indicators and unit then
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
    elseif event == "READY_CHECK_CONFIRM" then
        for unit, button in pairs(Ether.unitButtons.raid) do
            if button and button.Indicators and unit then
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
    elseif event == "READY_CHECK_FINISHED" then
        if not updater then
            updater = C_Timer.After(5, HideReadyCheckIcons)
        end
    elseif event == "RAID_TARGET_UPDATE" then
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
    elseif event == "PARTY_LEADER_CHANGED" then
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
    elseif event == "PARTY_LOOT_METHOD_CHANGED" then
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
    elseif event == "PLAYER_ROLES_ASSIGNED" then
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

local indicatorEvent = {"READY_CHECK", "READY_CHECK_CONFIRM", "READY_CHECK_FINISHED", "RAID_TARGET_UPDATE", "PARTY_LEADER_CHANGED", "PARTY_LOOT_METHOD_CHANGED", "PLAYER_ROLES_ASSIGNED"}
local indicatorEventUnit = {"UNIT_CONNECTION", "INCOMING_RESURRECT_CHANGED", "UNIT_FLAGS", "PLAYER_FLAGS_CHANGED"}

local frame, frameUnit
if not frame and not frameUnit then
    frame, frameUnit = CreateFrame("Frame"), CreateFrame("Frame")
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
    for _, events in ipairs(indicatorEvent) do
        if frame:IsEventRegistered(events) then
            frame:UnregisterEvent(events)
        end
    end
    for _, events in ipairs({"UNIT_CONNECTION", "INCOMING_RESURRECT_CHANGED", "UNIT_FLAGS"}) do
        if frameUnit:IsEventRegistered(events) then
            frameUnit:UnregisterEvent(events)
        end
    end
    if Ether.DB[1001][1] == 1 then
        Ether:AuraDisable()
    end
    if Ether.DB[401][5] == 1 then
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
    for _, events in ipairs(indicatorEvent) do
        if not frame:IsEventRegistered(events) then
            frame:RegisterEvent(events)
        end
    end
    for _, events in ipairs({"UNIT_CONNECTION", "INCOMING_RESURRECT_CHANGED", "UNIT_FLAGS"}) do
        if not frameUnit:IsEventRegistered(events) then
            frameUnit:RegisterEvent(events)
        end
    end
    if Ether.DB[1001][1] == 1 then
        C_Timer.After(0.3, function()
            Ether:AuraEnable()
        end)
    end
    if Ether.DB[401][5] == 1 then
        C_Timer.After(0.1, function()
            Ether:RangeEnable()
        end)
    end
end

local function IndicatorUnit(self, event, unit)
    if not unit then return end
    if event == "UNIT_CONNECTION" then
        local button = FindUnitButton(unit)
        if not button then return end
        if not button.Indicators.Connection then return end
        local isConnected = UnitIsConnected(unit)
        if not isConnected then
            button.healthBar:SetStatusBarColor(0.5, 0.5, 0.5)
            button.Indicators.Connection:SetTexture(connectionIcon)
            button.Indicators.Connection:Show()
        else
            button.Indicators.Connection:Hide()
        end
    elseif event == "INCOMING_RESURRECT_CHANGED" then
        local button = FindUnitButton(unit)
        if not button then return end
        if not button.Indicators.Resurrection then return end
        local Resurrection = UnitHasIncomingResurrection(unit)
        if (Resurrection) then
            button.Indicators.Resurrection:SetTexture(rezIcon)
            button.Indicators.Resurrection:Show()
        else
            button.Indicators.Resurrection:Hide()
        end
    elseif event == "UNIT_FLAGS" then
        local button = FindUnitButton(unit)
        if not button then return end
        if not button.Indicators.UnitFlags then return end
        if button.unit == unit and UnitExists(unit) then
            local charmed = UnitIsCharmed(unit)
            if charmed then
                button.name:SetTextColor(1.00, 0.00, 0.00)
                button.Indicators.UnitFlags:SetTexture(charmedIcon)
                button.Indicators.UnitFlags:Show()
            else
                button.Indicators.UnitFlags:Hide()
                button.name:SetTextColor(1, 1, 1)
            end
        end
    elseif event == "PLAYER_FLAGS_CHANGED" then
        local button = FindUnitButton(unit)
        if not button then return end
        if not button.Indicators.PlayerFlags then return end
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
        if Ether.DB[401][4] ~= 1 then return end
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

function Ether:FullUpdateIndicators()
    Indicator(frame, "READY_CHECK")
    Indicator(frame, "RAID_TARGET_UPDATE")
    Indicator(frame, "PARTY_LEADER_CHANGED")
    Indicator(frame, "PARTY_LOOT_METHOD_CHANGED")
    Indicator(frame, "PLAYER_ROLES_ASSIGNED")

    for unit, button in pairs(Ether.unitButtons.raid) do
        if button and button.Indicators and UnitExists(unit) then
            IndicatorUnit(frameUnit, "UNIT_CONNECTION", unit)
            IndicatorUnit(frameUnit, "INCOMING_RESURRECT_CHANGED", unit)
            IndicatorUnit(frameUnit, "UNIT_FLAGS", unit)
            IndicatorUnit(frameUnit, "PLAYER_FLAGS_CHANGED", unit)
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

    for index, handlers in ipairs(IndicatorMap) do
        for _, button in pairs(Ether.unitButtons.raid) do
            if button and button.Indicators then
                if Ether.DB[501][index] == 0 then
                    if button.Indicators[handlers] then
                        button.Indicators[handlers]:Hide()
                    end
                end
            end
        end
    end
end

function Ether:IndicatorsEnable()
    if not frame:GetScript("OnEvent") and not frameUnit:GetScript("OnEvent") then
        for _, events in ipairs(indicatorEvent) do
            if not frame:IsEventRegistered(events) then
                frame:RegisterEvent(events)
            end
        end
        for _, events in ipairs(indicatorEventUnit) do
            if not frameUnit:IsEventRegistered(events) then
                frameUnit:RegisterEvent(events)
            end
        end
        frame:SetScript("OnEvent", Indicator)
        frameUnit:SetScript("OnEvent", IndicatorUnit)
    end
end

function Ether:IndicatorsDisable()
    if frame:GetScript("OnEvent") and frameUnit:GetScript("OnEvent") then
        frame:UnregisterAllEvents();
        frameUnit:UnregisterAllEvents()
        frame:SetScript("OnEvent", nil);
        frameUnit:SetScript("OnEvent", nil)
    end
end