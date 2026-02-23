local _, Ether = ...
local UnitIsAFK = UnitIsAFK
local UnitIsDND = UnitIsDND
local UnitIsConnected = UnitIsConnected
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitHasIncomingResurrection = UnitHasIncomingResurrection
local GetReadyCheckStatus = GetReadyCheckStatus
local GetPartyAssignment = GetPartyAssignment
local IsEventValid = C_EventUtils.IsEventValid
local GetRaidTargetIndex = GetRaidTargetIndex
local UnitExists = UnitExists
local Enum = Enum
local tinsert, tremove = table.insert, table.remove
local GetLootMethod = C_PartyInfo.GetLootMethod
local pairs, ipairs = pairs, ipairs
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsCharmed = UnitIsCharmed
local UnitIsUnit = UnitIsUnit
local deadIcon = "Interface\\Icons\\Spell_Holy_GuardianSpirit"
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

Ether.Handler = {}
local Updates = {}
function Ether.Handler:FullUpdate()
    for i = 1, #(Updates) do
        Updates[i]()
    end
end

function Ether.Handler:RegisterUpdater(func)
    for i = 1, #(Updates) do
        if (Updates[i] and Updates[i + 1] == func) then
            return
        end
    end
    tinsert(Updates, func)
end

function Ether.Handler:UnregisterUpdater(func)
    for i = #(Updates), 1, -1 do
        if (Updates[i] and Updates[i + 1] == func) then
            tremove(Updates, i + 1)
        end
    end
end

local Register, Unregister, UnregisterAll
do
    local frame
    local Events = {}
    function Register(indicator, func)
        frame = CreateFrame("Frame")
        frame:SetScript("OnEvent", function(_, event)
            Events[event](_, event)
        end)
        if not Events[indicator] then
            if IsEventValid(indicator) and not frame:IsEventRegistered(indicator) then
                frame:RegisterEvent(indicator)
                Ether.Handler:RegisterUpdater(func)
            end
        end
        Events[indicator] = func
    end
    function Unregister(...)
        for i = select("#", ...), 1, -1 do
            local indicator = select(i, ...)
            if IsEventValid(indicator) then
                if Events[indicator] then
                    frame:UnregisterEvent(indicator)
                end
            end
            Events[indicator] = nil
        end
    end
    function UnregisterAll()
        frame:UnregisterAllEvents()
        wipe(Events)
    end
end

function Ether:HideIndicators(indicator)
    for _, button in pairs(Ether.unitButtons.raid) do
        if button and button.Indicators and button.Indicators[indicator] then
            button.Indicators[indicator]:Hide()
        end
    end
end

function Ether:IndictorsTexture(b, tbl)
    if not b then return end
    if not b.Indicators then b.Indicators = {} end
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetFrameLevel(b:GetFrameLevel() + 7)
    if not b.Indicators[tbl] then
        if tbl == "PlayerFlags" then
            b.Indicators[tbl] = frame:CreateFontString(nil, "OVERLAY")
            b.Indicators[tbl]:SetFont(unpack(Ether.mediaPath.expressway), 14, "OUTLINE")
            b.Indicators[tbl]:Hide()
        else
            b.Indicators[tbl] = frame:CreateTexture(nil, "OVERLAY")
            b.Indicators[tbl]:Hide()
        end
    end
end

function Ether:SaveIndicatorsPosition(indicator, number)
    for _, button in pairs(Ether.unitButtons.raid) do
        if not button or not button.Indicators then return end
        Ether:IndictorsTexture(button, indicator)
        if button.Indicators[indicator] then
            button.Indicators[indicator]:Hide()
            button.Indicators[indicator]:ClearAllPoints()
            button.Indicators[indicator]:SetPoint(Ether.DB[1002][number][2], button.healthBar, Ether.DB[1002][number][2], Ether.DB[1002][number][3], Ether.DB[1002][number][4])
            button.Indicators[indicator]:SetSize(Ether.DB[1002][number][1], Ether.DB[1002][number][1])
        end
    end

    Ether.Handler:FullUpdate()
end

function Ether:CheckIndicatorsPosition(button)

    for index, value in pairs({"ReadyCheck", "Connection", "RaidTarget", "Resurrection", "GroupLeader", "MasterLoot", "UnitFlags", "PlayerRoles", "PlayerFlags"}) do
        Ether:IndictorsTexture(button, value)
        if button.Indicators[value] then
            button.Indicators[value]:Hide()
            button.Indicators[value]:ClearAllPoints()
           button.Indicators[value]:SetPoint(Ether.DB[1002][index][2], button.healthBar, Ether.DB[1002][index][2], Ether.DB[1002][index][3], Ether.DB[1002][index][4])
            button.Indicators[value]:SetSize(Ether.DB[1002][index][1], Ether.DB[1002][index][1])
        end
    end
end

function Ether:InitialIndicatorsPosition()
    for index, value in ipairs({"ReadyCheck", "Connection", "RaidTarget", "Resurrection", "GroupLeader", "MasterLoot", "UnitFlags", "PlayerRoles", "PlayerFlags"}) do
        Ether:SaveIndicatorsPosition(value, index)
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

local function UpdateConnection()
    for _, button in pairs(Ether.unitButtons.raid) do
        if not button or not button.Indicators then return end
        Ether:IndictorsTexture(button, "Connection")
        local isConnected = UnitIsConnected(button.unit)
        if not isConnected then
            button.healthBar:SetStatusBarColor(0.5, 0.5, 0.5)
            button.Indicators.Connection:SetTexture(connectionIcon)
            button.Indicators.Connection:Show()
        else
            button.Indicators.Connection:Hide()
        end
    end
end

local function UpdateResurrection()
    for _, button in pairs(Ether.unitButtons.raid) do
        if not button or not button.Indicators then return end
        Ether:IndictorsTexture(button, "Resurrection")
        local Resurrection = UnitHasIncomingResurrection(button.unit)
        if (Resurrection) then
            button.Indicators.Resurrection:SetTexture(rezIcon)
            button.Indicators.Resurrection:Show()
        else
            button.Indicators.Resurrection:Hide()
        end
    end

end

local function UpdateReady()
    for _, button in pairs(Ether.unitButtons.raid) do
        Ether:IndictorsTexture(button, "ReadyCheck")
        local unit = button.unit
        if UnitExists(unit) then
            local status = GetReadyCheckStatus(button.unit)
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

local function UpdateConfirm()
    for _, button in pairs(Ether.unitButtons.raid) do
        Ether:IndictorsTexture(button, "ReadyCheck")
        local status = GetReadyCheckStatus(button.unit)
        if (status == "ready") then
            button.Indicators.ReadyCheck:SetTexture(ReadyCheck_Ready)
            button.Indicators.ReadyCheck:Show()
        elseif (status == "notready") then
            button.Indicators.ReadyCheck:SetTexture(ReadyCheck_NotReady)
            button.Indicators.ReadyCheck:Show()

        end
    end
end

local function UpdateFinished()
    if not updater then
        updater = C_Timer.After(5, HideReadyCheckIcons)
    end
end

local function UpdateUnitFlags()
    for _, button in pairs(Ether.unitButtons.raid) do

        Ether:IndictorsTexture(button, "UnitFlags")
        local charmed = UnitIsCharmed(button.unit)
        local dead = UnitIsDeadOrGhost(button.unit)
        if charmed then
            button.name:SetTextColor(1.00, 0.00, 0.00)
            button.Indicators.UnitFlags:SetTexture(charmedIcon)
            button.Indicators.UnitFlags:Show()
        elseif dead then
            button.Indicators.UnitFlags:SetTexture(deadIcon)
            if button.healthBar then
                button.healthBar:SetValue(0)
                button.healthBar:SetMinMaxValues(0, 0)
                Ether:updateDispelBorder(button, {0, 0, 0, 0})
            end
            button.Indicators.UnitFlags:Show()
        else
            button.Indicators.UnitFlags:Hide()
            button.name:SetTextColor(1, 1, 1)
        end

    end
end

local function UpdatePlayerFlags()
    for _, button in pairs(Ether.unitButtons.raid) do

        Ether:IndictorsTexture(button, "PlayerFlags")
        local away = UnitIsAFK(button.unit)
        local dnd = UnitIsDND(button.unit)
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
            if not Ether.unitIsAway then
                Ether:AFK()
            end
        else
            if Ether.unitIsAway then
                Ether:NotAFK()
            end
        end

    end
end

local function UpdateGroupLeader()
    for _, button in pairs(Ether.unitButtons.raid) do
        if not button or not button.Indicators then return end
        Ether:IndictorsTexture(button, "GroupLeader")
        if not UnitInAnyGroup("player") then
            button.Indicators.GroupLeader:Hide()
        end
        local IsLeader = UnitIsGroupLeader(button.unit)
        if (IsLeader) then
            button.Indicators.GroupLeader:SetTexture(leaderIcon)
            button.Indicators.GroupLeader:Show()
        else
            button.Indicators.GroupLeader:Hide()
        end


    end
end

local function UpdatePlayerRoles()
    for _, button in pairs(Ether.unitButtons.raid) do

        Ether:IndictorsTexture(button, "PlayerRoles")
        if not IsInRaid() then
            button.Indicators.PlayerRoles:Hide()
        else
            if (GetPartyAssignment("MAINTANK", button.unit)) then
                button.Indicators.PlayerRoles:SetTexture(mainTankIcon)
                button.Indicators.PlayerRoles:Show()
            elseif (GetPartyAssignment("MAINASSIST", button.unit)) then
                button.Indicators.PlayerRoles:SetTexture(mainAssistIcon)
                button.Indicators.PlayerRoles:Show()
            else
                button.Indicators.PlayerRoles:Hide()
            end
        end
    end

end

local function UpdateMasterLoot()
    for _, button in pairs(Ether.unitButtons.raid) do

        Ether:IndictorsTexture(button, "MasterLoot")
        if not UnitInAnyGroup("player") then
            button.Indicators.MasterLoot:Hide()
        end
        local lootType, partyID, raidID = GetLootMethod()
        if lootType == Enum.LootMethod.Masterlooter then
            local masterLooterUnit = raidID and ((raidID == 0) and "player" or "raid" .. raidID) or partyID and ((partyID == 0) and "player" or "party" .. partyID)
            if masterLooterUnit and UnitIsUnit(button.unit, masterLooterUnit) then
                button.Indicators.MasterLoot:SetTexture(masterlootIcon)
                button.Indicators.MasterLoot:Show()
            else
                button.Indicators.MasterLoot:Hide()
            end
        end

    end

end

local function UpdateRaidTarget()
    for _, button in pairs(Ether.unitButtons.raid) do
        Ether:IndictorsTexture(button, "RaidTarget")
        local index = GetRaidTargetIndex(button.unit)
        if index then
            button.Indicators.RaidTarget:SetTexture(targetIcon)
            SetRaidTargetIconTexture(button.Indicators.RaidTarget, index)
            button.Indicators.RaidTarget:Show()
        else
            button.Indicators.RaidTarget:Hide()
        end
    end
    for _, info in ipairs({"player", "target", "targettarget"}) do
        Ether:UpdateSoloIndicator(info)
    end

end

function Ether:UpdateSoloIndicator(unit)
    local button = Ether.unitButtons.solo[unit]
    if not button or not button.RaidTarget then return end
    if UnitExists(unit) then
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

local map = {"ReadyCheck", "Connection", "RaidTarget", "Resurrection", "GroupLeader", "MasterLoot", "UnitFlags", "PlayerRoles", "PlayerFlags"}
local events = {"UNIT_CONNECTION", "INCOMING_RESURRECT_CHANGED", "READY_CHECK", "READY_CHECK_CONFIRM", "READY_CHECK_FINISHED", "RAID_TARGET_UPDATE", "PARTY_LEADER_CHANGED", "PARTY_LOOT_METHOD_CHANGED", "PLAYER_ROLES_ASSIGNED", "PLAYER_FLAGS_CHANGED", "UNIT_FLAGS"}
local handler = {UpdateConnection, UpdateResurrection, UpdateReady, UpdateConfirm, UpdateFinished, UpdateRaidTarget, UpdateGroupLeader, UpdateMasterLoot, UpdatePlayerRoles, UpdatePlayerFlags, UpdateUnitFlags}

function Ether:IndicatorsRegisterByIndex(index)

end

function Ether:IndicatorsRegister()
    for index, info in ipairs(events) do
        Register(info, handler[index])

    end
    --[[
    Register("UNIT_CONNECTION", UpdateConnection)
    Register("INCOMING_RESURRECT_CHANGED", UpdateResurrection)
    Register("READY_CHECK", UpdateReady)
    Register("READY_CHECK_CONFIRM", UpdateConfirm)
    Register("READY_CHECK_FINISHED", UpdateFinished)
    Register("RAID_TARGET_UPDATE", UpdateRaidTarget)
    Register("PARTY_LEADER_CHANGED", UpdateGroupLeader)
    Register("PARTY_LOOT_METHOD_CHANGED", UpdateMasterLoot)
    Register("PLAYER_ROLES_ASSIGNED", UpdatePlayerRoles)
    Register("PLAYER_FLAGS_CHANGED", UpdatePlayerFlags)
    Register("UNIT_FLAGS", UpdateUnitFlags)
    ]]
end

Ether.unitIsAway = false
function Ether:AFK()
    Ether.unitIsAway = true
    if Ether.DB[1201][1] == 1 then
        Ether:CastBarDisable("player")
    end
    if Ether.DB[1201][2] == 1 then
        Ether:CastBarDisable("target")
    end
    Ether:HealthDisable()
    Ether:PowerDisable()

    if Ether.DB[1001][1] == 1 then
        Ether:AuraDisable()
    end
    if Ether.DB[401][5] == 1 then
        C_Timer.After(0.1, function()
            Ether:RangeDisable()
        end)
    end
    for i = 1, 9 do
        Ether:HideIndicators(map[i])
    end
end

function Ether:NotAFK()
    Ether.unitIsAway = false
    if Ether.DB[1201][1] == 1 then
        Ether:CastBarEnable("player")
    end
    if Ether.DB[1201][2] == 1 then
        Ether:CastBarEnable("target")
    end
    Ether:HealthEnable()
    Ether:PowerEnable()
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
    Ether.Handler:FullUpdate()
end

function Ether:IndicatorsEnable()
   -- Ether:InitialIndicatorsPosition()
    Ether:IndicatorsRegister()
    Ether:UpdateSoloIndicator("player")
    Ether.Handler:FullUpdate()

end

function Ether:IndicatorsDisable()

    for i = 1, 9 do
        Ether:HideIndicators(map[i])
    end
end
