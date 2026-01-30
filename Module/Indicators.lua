local _, Ether = ...
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
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
local ReadyCheck_Ready = "Interface\\RaidFrame\\ReadyCheck-Ready"
local ReadyCheck_NotReady = "Interface\\RaidFrame\\ReadyCheck-NotReady"
local ReadyCheck_Waiting = "Interface\\RaidFrame\\ReadyCheck-Waiting"
local deadIcon = "Interface\\Icons\\Spell_Holy_TurnUndead"
local ghostIcon = "Interface\\Icons\\Spell_Holy_GuardianSpirit"
local leader = "Interface\\GroupFrame\\UI-Group-LeaderIcon"
local target = "Interface\\TargetingFrame\\UI-RaidTargetingIcons"
local mainTankIcon = "Interface\\GroupFrame\\UI-Group-MainTankIcon"
local mainAssistIcon = "Interface\\GroupFrame\\UI-Group-MainAssistIcon"
local connectionIcon = "Interface\\CharacterFrame\\Disconnect-Icon"
local rezIcon = "Interface\\RaidFrame\\Raid-Icon-Rez"
local masterlootIcon = "Interface\\GroupFrame\\UI-Group-MasterLooter"
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
            frame:SetScript("OnEvent", function(self, event)
                Events[event](self, event)
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

local function StringMethod(button, position, offsetX, offsetY)
    local string = button.healthBar:CreateFontString(nil, "OVERLAY")
    string:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    string:SetPoint(position, button.healthBar, position, offsetX, offsetY)
    string:Show()
    return string
end

local function TextureMethod(button, size, position, offsetX, offsetY)
    local texture = button.healthBar:CreateTexture(nil, "OVERLAY")
    texture:SetSize(size, size)
    texture:SetTexCoord(0, 1, 0, 1)
    texture:SetPoint(position, button.healthBar, position, offsetX, offsetY)
    texture:Show()
    return texture
end

function Ether:HideIndicators(hide)
    for _, button in pairs(Ether.unitButtons.raid) do
        if (button and button.Indicators and button.Indicators[hide]) then
            button.Indicators[hide]:Hide()
        end
    end
end

local function unitIsDead(button)
    button.top:SetColorTexture(0, 0, 0, 1)
    button.right:SetColorTexture(0, 0, 0, 1)
    button.left:SetColorTexture(0, 0, 0, 1)
    button.bottom:SetColorTexture(0, 0, 0, 1)
end

local function UpdateUnitFlagsIcon()
    for unit, button in pairs(Ether.unitButtons.raid) do
        if button and unit then
            if not button.Indicators.UnitFlagsIcon then
                button.Indicators.UnitFlagsIcon = TextureMethod(button, 12, "TOP")
            end
            local IsCharmed = UnitIsCharmed(unit)
            local IsDead = UnitIsDead(unit)
            local IsGhost = UnitIsGhost(unit)
            if (IsCharmed) then
                button.name:SetTextColor(1.00, 0.00, 0.00)
            elseif (IsGhost) then
                button.Indicators.UnitFlagsIcon:SetTexture(ghostIcon)
                button.Indicators.UnitFlagsIcon:Show()
                unitIsDead(button)
            elseif (IsDead) then
                button.Indicators.UnitFlagsIcon:SetTexture(deadIcon)
                button.Indicators.UnitFlagsIcon:Show()
                unitIsDead(button)
            else
                button.name:SetTextColor(1, 1, 1)
                button.Indicators.UnitFlagsIcon:Hide()
            end
        end
    end
end

local IndicatorsRdy = {}

local function UpdateReadyCheckIcon()
    for unit, button in pairs(Ether.unitButtons.raid) do
        if button and unit then
            if not button.Indicators.ReadyCheckIcon then
                button.Indicators.ReadyCheckIcon = TextureMethod(button, 18, "TOP")
            end
            local status = GetReadyCheckStatus(unit)
            if (status) then
                if (status == "ready") then
                    button.Indicators.ReadyCheckIcon:SetTexture(ReadyCheck_Ready)
                    button.Indicators.ReadyCheckIcon:Show()
                elseif (status == "notready") then
                    button.Indicators.ReadyCheckIcon:SetTexture(ReadyCheck_NotReady)
                    button.Indicators.ReadyCheckIcon:Show()
                elseif (status == "waiting") then
                    button.Indicators.ReadyCheckIcon:SetTexture(ReadyCheck_Waiting)
                    button.Indicators.ReadyCheckIcon:Show()
                end
            else
                if button.Indicators.ReadyCheckIcon then
                    button.Indicators.ReadyCheckIcon:Hide()
                end
            end
        end
    end
end

local function UpdateConfirmIcon()
    for unit, button in pairs(Ether.unitButtons.raid) do
        if button and unit then
            if not button.Indicators.ReadyCheckIcon then return end
            local status = GetReadyCheckStatus(unit)
            if (status == "ready") then
                button.Indicators.ReadyCheckIcon:SetTexture(ReadyCheck_Ready)
                button.Indicators.ReadyCheckIcon:Show()
            elseif (status == "notready") then
                button.Indicators.ReadyCheckIcon:SetTexture(ReadyCheck_NotReady)
                button.Indicators.ReadyCheckIcon:Show()
            end
        end
    end
end

local function HideReadyCheckIcons()
    Ether:HideIndicators("ReadyCheckIcon")
    if IndicatorsRdy.ReadyCheckTimer then
        IndicatorsRdy.ReadyCheckTimer:Cancel()
        IndicatorsRdy.ReadyCheckTimer = nil
    end
end

local function UpdateFinish()
    IndicatorsRdy.ReadyCheckTimer = C_Timer.After(10, HideReadyCheckIcons)
end

local function UpdateGroupLeaderIcon()
    for unit, button in pairs(Ether.unitButtons.raid) do
        if button and unit then
            if not button.Indicators.GroupLeaderIcon then
                button.Indicators.GroupLeaderIcon = TextureMethod(button, 12, "RIGHT")
            end
            local IsLeader = UnitIsGroupLeader(unit)
            if (IsLeader) then
                button.Indicators.GroupLeaderIcon:SetTexture(leader)
            else
                button.Indicators.GroupLeaderIcon:Hide()
            end
        end
    end
end

local function UpdateMasterLootIcon()
    for unit, button in pairs(Ether.unitButtons.raid) do
        if button and unit then
            if not button.Indicators.MasterLootIcon then
                button.Indicators.MasterLootIcon = TextureMethod(button, 12, "BOTTOMRIGHT", 0, 12)
            end
            button.Indicators.MasterLootIcon:SetTexture(masterlootIcon)
            button.Indicators.MasterLootIcon:Hide()
            local lootType, partyID, raidID = GetLoot()
            if lootType == Enum.LootMethod.Masterlooter then
                local masterLooterUnit = raidID and ((raidID == 0) and "player" or "raid" .. raidID) or partyID and ((partyID == 0) and "player" or "party" .. partyID)
                if masterLooterUnit and UnitIsUnit(unit, masterLooterUnit) then
                    button.Indicators.MasterLootIcon:Show()
                else
                    button.Indicators.MasterLootIcon:Hide()
                end
            end
        end
    end
end
local function UpdatePlayerRolesIcon()
    for unit, button in pairs(Ether.unitButtons.raid) do
        if button and unit then
            if not button.Indicators.MainTankIcon then
                button.Indicators.MainTankIcon = TextureMethod(button, 12, "LEFT")
            end
            if not IsInRaid() and button.Indicators.MainTankIcon then
                button.Indicators.MainTankIcon:Hide()
            else
                if (GetPartyAssignment("MAINTANK", unit)) then
                    button.Indicators.MainTankIcon:SetTexture(mainTankIcon)
                    button.Indicators.MainTankIcon:Show()
                elseif (GetPartyAssignment("MAINASSIST", unit)) then
                    button.Indicators.MainTankIcon:SetTexture(mainAssistIcon)
                    button.Indicators.MainTankIcon:Show()
                else
                    button.Indicators.MainTankIcon:Hide()
                end
            end
        end
    end
end

local function UpdateConnectionIcon()
    for unit, button in pairs(Ether.unitButtons.raid) do
        if button and unit then
            if not button.Indicators.ConnectionIcon then
                button.Indicators.ConnectionIcon = TextureMethod(button, 24, "TOPLEFT")
            end
            local isConnected = UnitIsConnected(unit)
            if (not isConnected) then
                button.Indicators.ConnectionIcon:SetTexture(connectionIcon)
                button.Indicators.ConnectionIcon:Show()
                button.healthBar:SetStatusBarColor(0.5, 0.5, 0.5)
            else
                button.Indicators.ConnectionIcon:Hide()
            end
        end
    end
end

local function UpdateRaidTargetIcon()
    for unit, button in pairs(Ether.unitButtons.raid) do
        if button and UnitExists(unit) then
            if not button.Indicators.RaidTargetIcon then
                button.Indicators.RaidTargetIcon = TextureMethod(button, 12, "BOTTOM")
            end
            local index = GetRaidTargetIndex(unit)
            if index then
                button.Indicators.RaidTargetIcon:SetTexture(target)
                button.Indicators.RaidTargetIcon:Show()
                SetRaidTargetIconTexture(button.Indicators.RaidTargetIcon, index)
            else
                button.Indicators.RaidTargetIcon:Hide()
            end
        end
    end
end

local function UpdateResurrectionIcon()
    for unit, button in pairs(Ether.unitButtons.raid) do
        if button and unit then
            if not button.Indicators.ResurrectionIcon then
                button.Indicators.ResurrectionIcon = TextureMethod(button, 24, "CENTER")
            end
            local Resurrection = UnitHasIncomingResurrection(unit)
            if (Resurrection) then
                button.Indicators.ResurrectionIcon:SetTexture(rezIcon)
                button.Indicators.ResurrectionIcon:Show()
            else
                button.Indicators.ResurrectionIcon:Hide()
            end
        end
    end
end

local function UpdatePlayerFlagsString()
    for unit, button in pairs(Ether.unitButtons.raid) do
        if button and unit then
            if not button.Indicators.PlayerFlagsString then
                button.Indicators.PlayerFlagsString = StringMethod(button, "TOPLEFT")
            end
            local away = UnitIsAFK(unit)
            local dnd = UnitIsDND(unit)
            if away then
                button.Indicators.PlayerFlagsString:SetText(AFK)
                button.Indicators.PlayerFlagsString:Show()
            elseif dnd then
                button.Indicators.PlayerFlagsString:SetText(DND)
                button.Indicators.PlayerFlagsString:Show()
            else
                button.Indicators.PlayerFlagsString:Hide()
            end
        end
    end
end

local function EnableReadyCheck()
    RegisterIndicatorEvent("READY_CHECK", UpdateReadyCheckIcon)
    RegisterIndicatorEvent("READY_CHECK_CONFIRM", UpdateConfirmIcon)
    RegisterIndicatorEvent("READY_CHECK_FINISHED", UpdateFinish)
end
local function DisableReadyCheck()
    UnregisterIndicatorEvent("READY_CHECK")
    UnregisterIndicatorEvent("READY_CHECK_CONFIRM")
    UnregisterIndicatorEvent("READY_CHECK_FINISHED")
    HideReadyCheckIcons()
end

local function EnableConnection()
    RegisterIndicatorEvent("UNIT_CONNECTION", UpdateConnectionIcon)
end

local function EnableRaidTarget()
    RegisterIndicatorEvent("RAID_TARGET_UPDATE", UpdateRaidTargetIcon)
end

local function EnableResurrection()
    RegisterIndicatorEvent("INCOMING_RESURRECT_CHANGED", UpdateResurrectionIcon)
end

local function EnableGroupLeader()
    RegisterIndicatorEvent("PARTY_LEADER_CHANGED", UpdateGroupLeaderIcon)
end

local function EnableMasterLoot()
    RegisterIndicatorEvent("PARTY_LOOT_METHOD_CHANGED", UpdateMasterLootIcon)
end

local function EnableUnitFlags()
    RegisterIndicatorEvent("UNIT_FLAGS", UpdateUnitFlagsIcon)
end

local function EnablePlayerRoles()
    RegisterIndicatorEvent("PLAYER_ROLES_ASSIGNED", UpdatePlayerRolesIcon)
end

local function EnablePlayerFlags()
    RegisterIndicatorEvent("PLAYER_FLAGS_CHANGED", UpdatePlayerFlagsString)
end

local function DisableConnection()
    UnregisterIndicatorEvent("UNIT_CONNECTION")
    Ether:HideIndicators("ConnectionIcon")
end

local function DisableRaidTarget()
    UnregisterIndicatorEvent("RAID_TARGET_UPDATE")
    Ether:HideIndicators("RaidTargetIcon")
end

local function DisableResurrection()
    UnregisterIndicatorEvent("INCOMING_RESURRECT_CHANGED")
    Ether:HideIndicators("ResurrectionIcon")
end

local function DisableGroupLeader()
    UnregisterIndicatorEvent("PARTY_LEADER_CHANGED")
    Ether:HideIndicators("GroupLeaderIcon")
end

local function DisableMasterLoot()
    UnregisterIndicatorEvent("PARTY_LOOT_METHOD_CHANGED")
    Ether:HideIndicators("MasterLootIcon")
end

local function DisableUnitFlags()
    UnregisterIndicatorEvent("UNIT_FLAGS")
    Ether:HideIndicators("UnitFlagsIcon")
end

local function DisablePlayerRoles()
    UnregisterIndicatorEvent("PLAYER_ROLES_ASSIGNED")
    Ether:HideIndicators("MainTankIcon")
end

local function DisablePlayerFlags()
    UnregisterIndicatorEvent("PLAYER_FLAGS_CHANGED")
    Ether:HideIndicators("PlayerFlagsString", "string")
end

local indicatorsHandlers = {
    [1] = {EnableReadyCheck, DisableReadyCheck},
    [2] = {EnableConnection, DisableConnection, UpdateConnectionIcon},
    [3] = {EnableRaidTarget, DisableRaidTarget, UpdateRaidTargetIcon},
    [4] = {EnableResurrection, DisableResurrection},
    [5] = {EnableGroupLeader, DisableGroupLeader, UpdateGroupLeaderIcon},
    [6] = {EnableMasterLoot, DisableMasterLoot, UpdateMasterLootIcon},
    [7] = {EnableUnitFlags, DisableUnitFlags, UpdateUnitFlagsIcon},
    [8] = {EnablePlayerRoles, DisablePlayerRoles, UpdatePlayerRolesIcon},
    [9] = {EnablePlayerFlags, DisablePlayerFlags, UpdatePlayerFlagsString},
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
        if index ~= 9 then
            handlers[2]()
        end
    end
end

function Ether:IndicatorsUpdate()
    local I = Ether.DB[501]
    for index, handlers in ipairs(indicatorsHandlers) do
        if I[index] == 1 and handlers[3] then
            handlers[3]()
        end
    end
end
