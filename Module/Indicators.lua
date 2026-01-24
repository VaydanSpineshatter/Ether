local _, Ether = ...

local U_Dead, U_Ghost = UnitIsDead, UnitIsGhost
local U_AFK = UnitIsAFK
local U_DND = UnitIsDND
local UnitHasIncomingResurrection = UnitHasIncomingResurrection
local GetReadyCheckStatus = GetReadyCheckStatus
local GetPartyAssignment = GetPartyAssignment
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local Enum = Enum
local GetLoot = C_PartyInfo.GetLootMethod
local pairs = pairs
local GroupLeader = UnitIsGroupLeader

local C_After = C_Timer.After
local U_ICN = UnitIsConnected
local U_ISC = UnitIsCharmed
local U_IU = UnitIsUnit
local rdyTex = "Interface\\RaidFrame\\ReadyCheck-Ready"
local notRdyTex = "Interface\\RaidFrame\\ReadyCheck-NotReady"
local waitingTex = "Interface\\RaidFrame\\ReadyCheck-Waiting"
local deadIcon = "Interface\\Icons\\Spell_Holy_SenseUndead"
local ghostIcon = "Interface\\Icons\\Spell_Holy_GuardianSpirit"
local leader = "Interface\\GroupFrame\\UI-Group-LeaderIcon"
local target = "Interface\\TargetingFrame\\UI-RaidTargetingIcons"
local mainTankIcon = "Interface\\GroupFrame\\UI-Group-MainTankIcon"
local mainAssistIcon = "Interface\\GroupFrame\\UI-Group-MainAssistIcon"
local connectionIcon = "Interface\\CharacterFrame\\Disconnect-Icon"
local rezIcon = "Interface\\RaidFrame\\Raid-Icon-Rez"
local charmedIcon = "Interface\\Icons\\Spell_Shadow_Charm"
local masterlootIcon = "Interface\\GroupFrame\\UI-Group-MasterLooter"
local roleIcon = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES"
local afkStr = "|cffff0000AFK|r"
local dndStr = "|cffCC66FFDND|r"
local rdyStr = "ready"
local notRdyStr = "notready"
local waitingStr = "waiting"

local RegisterStatus = {
    [1] = "Ready check ",
    [2] = "Unit connection ",
    [3] = "Raid target update ",
    [4] = "Incoming Resurrect ",
    [5] = "Party leader change ",
    [6] = "Party loot method ",
    [7] = "Unit Flags ",
    [8] = "Player roles assigned ",
    [9] = "Player flags ",
}

local EnabledStatus = {
    [1] = "Charmed ",
    [2] = "Dead ",
    [3] = "Ghost ",
    [4] = "Role ",
    [5] = "maintank ",
    [6] = "AFK ",
    [7] = "DND ",
}

local Events = {}
local RegisterIndicatorEvent, UnregisterIndicatorEvent, GetIndicatorRegisterStatus, GetIndicatorEnabledStatus
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
    function GetIndicatorRegisterStatus(numb)
        if type(numb) ~= "number" and numb > 9 then
            return
        end
        local int = Ether.DB[501][numb]
        local status
        if int == 1 then
            status = "Enabled"
        elseif int == 0 then
            status = "Disabled"
        end
        Ether.DebugOutput(RegisterStatus[numb], status)
    end
    function GetIndicatorEnabledStatus(numb)
        if type(numb) ~= "number" and numb > 7 then
            return
        end
        local int = Ether.DB[601][numb]
        local status
        if int == 1 then
            status = "Enabled"
        elseif int == 0 then
            status = "Disabled"
        end
        Ether.DebugOutput(EnabledStatus[numb], status)
    end
end

Ether.GetIndicatorRegisterStatus = GetIndicatorRegisterStatus
Ether.GetIndicatorEnabledStatus = GetIndicatorEnabledStatus

local function HideIndicators(tex)
    for _, button in pairs(Ether.unitButtons.raid) do
        if (button and button.Indicators and button.Indicators[tex]) then
            button.Indicators[tex]:Hide()
        end
    end
end
Ether.HideIndicators = HideIndicators

local function CreatePlayerFlagsString(self)
    if not self.Indicators.PlayerFlagsString then
        self.Indicators.PlayerFlagsString = self.healthBar:CreateFontString(nil, "OVERLAY")
        self.Indicators.PlayerFlagsString:SetFont(unpack(Ether.mediaPath.Font), 9, "OUTLINE")
        self.Indicators.PlayerFlagsString:SetPoint("TOPLEFT", 1, -1)
        self.Indicators.PlayerFlagsString:Hide()
    end
    return self.Indicators.PlayerFlagsString
end

local function CreateIndicatorsTexture(self, icon, size, posi, x, y)
    if (not self.Indicators[icon]) then
        self.Indicators[icon] = self.healthBar:CreateTexture(nil, "OVERLAY")
        self.Indicators[icon]:SetSize(size, size)
        self.Indicators[icon]:SetPoint(posi, self.healthBar, posi, 0, 0)
        self.Indicators[icon]:Hide()
    end
end

local function UpdateUnitFlagsIcon()
    for _, button in pairs(Ether.unitButtons.raid and Ether.unitButtons.party) do
        if button then
            CreateIndicatorsTexture(button, "UnitFlagsIcon", 12, "TOP")
            local unit = button:GetAttribute("unit")
            if unit then
                local IsCharmed = U_ISC(unit)
                local IsDead = U_Dead(unit)
                local IsGhost = U_Ghost(unit)
                if (IsCharmed and Ether.DB[601][1] == 1 and Ether.DB[501][7] == 1) then
                    button.Indicators.UnitFlagsIcon:SetTexture(charmedIcon)
                    button.name:SetTextColor(1.00, 0.00, 0.00)
                    button.Indicators.UnitFlagsIcon:Show()
                elseif (IsGhost and Ether.DB[601][3] == 1 and Ether.DB[501][7] == 1) then
                    button.Indicators.UnitFlagsIcon:SetTexture(ghostIcon)
                    button.Indicators.UnitFlagsIcon:Show()
                    if button.top then
                        button.top:SetColorTexture(0, 0, 0, 1)
                        button.right:SetColorTexture(0, 0, 0, 1)
                        button.left:SetColorTexture(0, 0, 0, 1)
                        button.bottom:SetColorTexture(0, 0, 0, 1)
                    end
                elseif (IsDead and Ether.DB[601][2] == 1 and Ether.DB[501][7] == 1) then
                    button.Indicators.UnitFlagsIcon:SetTexture(deadIcon)
                    button.Indicators.UnitFlagsIcon:Show()
                    if button.top then
                        button.top:SetColorTexture(0, 0, 0, 1)
                        button.right:SetColorTexture(0, 0, 0, 1)
                        button.left:SetColorTexture(0, 0, 0, 1)
                        button.bottom:SetColorTexture(0, 0, 0, 1)
                    end
                else
                    button.name:SetTextColor(1, 1, 1)
                    button.Indicators.UnitFlagsIcon:Hide()
                end
            end
        end
    end
end
local IndicatorsRdy = {}

local function UpdateReadyCheckIcon()
    for _, button in pairs(Ether.unitButtons.raid and Ether.unitButtons.party) do
        if button then
            CreateIndicatorsTexture(button, "ReadyCheckIcon", 18, "TOP")
            local unit = button:GetAttribute("unit")
            if unit then
                local status = GetReadyCheckStatus(unit)
                if (status) then
                    if (status == rdyStr) then
                        button.Indicators.ReadyCheckIcon:SetTexture(rdyTex)
                        button.Indicators.ReadyCheckIcon:Show()
                    elseif (status == notRdyStr) then
                        button.Indicators.ReadyCheckIcon:SetTexture(notRdyTex)
                        button.Indicators.ReadyCheckIcon:Show()
                    elseif (status == waitingStr) then
                        button.Indicators.ReadyCheckIcon:SetTexture(waitingTex)
                        button.Indicators.ReadyCheckIcon:Show()
                    end
                else
                    button.Indicators.ReadyCheckIcon:Hide()
                end
            end
        end
    end
end
local function UpdateConfirmIcon()
    for _, button in pairs(Ether.unitButtons.raid and Ether.unitButtons.party) do
        if button then
            local unit = button:GetAttribute("unit")
            if unit then
                local status = GetReadyCheckStatus(unit)
                if (status == rdyStr) then
                    button.Indicators.ReadyCheckIcon:SetTexture(rdyTex)
                    button.Indicators.ReadyCheckIcon:Show()
                elseif (status == waitingStr) then
                    button.Indicators.ReadyCheckIcon:SetTexture(notRdyTex)
                    button.Indicators.ReadyCheckIcon:Show()
                end
            end
        end
    end
end
local function HideReadyCheckIcons()
    for _, button in pairs(Ether.unitButtons.raid) do
        if button.Indicators.ReadyCheckIcon then
            button.Indicators.ReadyCheckIcon:Hide()
        end
    end
    IndicatorsRdy.ReadyCheckTimer = nil
end
local function UpdateFinish()
    if IndicatorsRdy.ReadyCheckTimer then
        IndicatorsRdy.ReadyCheckTimer:Cancel()
    end
    IndicatorsRdy.ReadyCheckTimer = C_After(10, HideReadyCheckIcons)
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
    if IndicatorsRdy.ReadyCheckTimer then
        IndicatorsRdy.ReadyCheckTimer:Cancel()
        IndicatorsRdy.ReadyCheckTimer = nil
    end
    HideReadyCheckIcons()
end
local function UpdateMainTankIcon(self, unit)
    CreateIndicatorsTexture(self, "MainTankIcon", 12, "LEFT")
    if not IsInRaid() then
        self.Indicators.MainTankIcon:Hide()
    elseif (GetPartyAssignment("MAINTANK", unit)) then
        self.Indicators.MainTankIcon:SetTexture(mainTankIcon)
        self.Indicators.MainTankIcon:Show()
    elseif (GetPartyAssignment("MAINASSIST", unit)) then
        self.Indicators.MainTankIcon:SetTexture(mainAssistIcon)
        self.Indicators.MainTankIcon:Show()
    else
        self.Indicators.MainTankIcon:Hide()
    end
end

local function UpdateGroupRoleIcon(self, role)
    CreateIndicatorsTexture(self, "GroupRoleIcon", 12, "RIGHT")
    if (role == "TANK") then
        self.Indicators.GroupRoleIcon:SetTexCoord(0, 19 / 64, 22 / 64, 41 / 64)
        self.Indicators.GroupRoleIcon:Show()
    elseif (role == "HEALER") then
        self.Indicators.GroupRoleIcon:SetTexCoord(20 / 64, 39 / 64, 1 / 64, 20 / 64)
        self.Indicators.GroupRoleIcon:Show()
    elseif (role == "DAMAGER") then
        self.Indicators.GroupRoleIcon:SetTexCoord(20 / 64, 39 / 64, 22 / 64, 41 / 64)
        self.Indicators.GroupRoleIcon:Show()
    else
        self.Indicators.GroupRoleIcon:Hide()
    end
end

local function UpdateGroupLeaderIcon()
    for _, button in pairs(Ether.unitButtons.raid) do
        CreateIndicatorsTexture(button, "GroupLeaderIcon", 12, "RIGHT")
        if button then
            local unit = button:GetAttribute("unit")
            if unit then
                local IsLeader = GroupLeader(unit)
                if (IsLeader) then
                    button.Indicators.GroupLeaderIcon:SetTexture(leader)
                    button.Indicators.GroupLeaderIcon:SetTexCoord(0, 1, 0, 1)
                    button.Indicators.GroupLeaderIcon:Show()
                else
                    button.Indicators.GroupLeaderIcon:Hide()
                end
            end
        end
    end
end

local function UpdateMasterLootIcon()
    for _, button in pairs(Ether.unitButtons.raid) do
        local unit = button:GetAttribute("unit")
        if unit then
            CreateIndicatorsTexture(button, "MasterLootIcon", 12, "BOTTOMRIGHT", 0, 12)
            button.Indicators.MasterLootIcon:SetTexture(masterlootIcon)
            button.Indicators.MasterLootIcon:Hide()
            local lootType, partyID, raidID = GetLoot()
            if lootType == Enum.LootMethod.Masterlooter then
                local masterLooterUnit = raidID and ((raidID == 0) and "player" or "raid" .. raidID) or partyID and ((partyID == 0) and "player" or "party" .. partyID)
                if masterLooterUnit and U_IU(unit, masterLooterUnit) then
                    button.Indicators.MasterLootIcon:Show()
                end
            end
        end
    end
end
local function UpdatePlayerRolesIcon()
    for _, button in pairs(Ether.unitButtons.raid) do
        local unit = button:GetAttribute("unit")
        if unit then
            local role = UnitGroupRolesAssigned(unit)
            if (Ether.DB[601][4] == 1 and role) then
                UpdateGroupRoleIcon(button, role)
            end
            if (Ether.DB[601][5] == 1) then
                UpdateMainTankIcon(button, unit, role)
            end
        end
    end
end
local function UpdateConnectionIcon()
    for _, button in pairs(Ether.unitButtons.raid) do
        CreateIndicatorsTexture(button, "ConnectionIcon", 24, "TOPLEFT")
        local unit = button:GetAttribute("unit")
        if unit and unit == button.unit then
            local isConnected = U_ICN(button.unit)
            if (not isConnected) then
                button.Indicators.ConnectionIcon:Show()
                button.Indicators.ConnectionIcon:SetTexture(connectionIcon)
                button.healthBar:SetStatusBarColor(0.5, 0.5, 0.5)
            else
                button.Indicators.ConnectionIcon:Hide()
            end
        end
    end
end

local function UpdateRaidTargetIcon()
    for _, button in pairs(Ether.unitButtons.raid) do
        if button then
            CreateIndicatorsTexture(button, "RaidTargetIcon", 12, "BOTTOM")
            local unit = button:GetAttribute("unit")
            if not UnitExists(unit) then
                return
            end
            if unit then
                local index = GetRaidTargetIndex(unit)
                if (index) then
                    button.Indicators.RaidTargetIcon:SetTexture(target)
                    SetRaidTargetIconTexture(button.Indicators.RaidTargetIcon, index)
                    button.Indicators.RaidTargetIcon:Show()
                else
                    button.Indicators.RaidTargetIcon:Hide()
                end
            end
        end
    end
end
local function UpdateResurrectionIcon()
    for _, button in pairs(Ether.unitButtons.raid) do
        if button then
            CreateIndicatorsTexture(button, "ResurrectionIcon", 24, "CENTER")
            local unit = button:GetAttribute("unit")
            if unit then
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
end
local function UpdatePlayerFlagsString()
    for _, button in pairs(Ether.unitButtons.raid) do
        if button then
            CreatePlayerFlagsString(button)
            local unit = button:GetAttribute("unit")
            if unit then
                local away = U_AFK(unit)
                local dnd = U_DND(unit)
                if (away and Ether.DB[601][6] == 1 and Ether.DB[501][7] == 1) then
                    button.Indicators.PlayerFlagsString:SetText(afkStr)
                    button.Indicators.PlayerFlagsString:Show()
                elseif (dnd and Ether.DB[601][7] == 1 and Ether.DB[501][7] == 1) then
                    button.Indicators.PlayerFlagsString:SetText(dndStr)
                    button.Indicators.PlayerFlagsString:Show()
                else
                    button.Indicators.PlayerFlagsString:Hide()
                end
            end
        end
    end
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
    HideIndicators("ConnectionIcon")
end

local function DisableRaidTarget()
    UnregisterIndicatorEvent("RAID_TARGET_UPDATE")
    HideIndicators("RaidTargetIcon")
end

local function DisableResurrection()
    UnregisterIndicatorEvent("INCOMING_RESURRECT_CHANGED")
    HideIndicators("ResurrectionIcon")
end

local function DisableGroupLeader()
    UnregisterIndicatorEvent("PARTY_LEADER_CHANGED")
    HideIndicators("GroupLeaderIcon")
end

local function DisableMasterLoot()
    UnregisterIndicatorEvent("PARTY_LOOT_METHOD_CHANGED")
    HideIndicators("MasterLootIcon")
end

local function DisableUnitFlags()
    UnregisterIndicatorEvent("UNIT_FLAGS")
    HideIndicators("UnitFlagsIcon")
end

local function DisablePlayerRoles()
    UnregisterIndicatorEvent("PLAYER_ROLES_ASSIGNED")
    HideIndicators("GroupRoleIcon")
    HideIndicators("MainTankIcon")
end

local function DisablePlayerFlags()
    UnregisterIndicatorEvent("PLAYER_FLAGS_CHANGED")
    HideIndicators("PlayerFlags")
end

local IndicatorHandlers = {
    [1] = {EnableReadyCheck, DisableReadyCheck},
    [2] = {EnableConnection, DisableConnection},
    [3] = {EnableRaidTarget, DisableRaidTarget},
    [4] = {EnableResurrection, DisableResurrection},
    [5] = {EnableGroupLeader, DisableGroupLeader},
    [6] = {EnableMasterLoot, DisableMasterLoot},
    [7] = {EnableUnitFlags, DisableUnitFlags},
    [8] = {EnablePlayerRoles, DisablePlayerRoles},
    [9] = {EnablePlayerFlags, DisablePlayerFlags},
}
Ether.IndicatorHandlers = IndicatorHandlers

function Ether:IndicatorsToggle()
    local I = Ether.DB[501]
    for index, handlers in pairs(IndicatorHandlers) do
        if I[index] == 1 then
            handlers[1]()
        end
        if I[index] == 0 then
            handlers[2]()
        end
    end
end

local tremove = table.remove
local isUpdating = false
local creationDelay = 0.05
local creationQueue = {}

local function processFunc()
    if #creationQueue == 0 then
        isUpdating = false
        return
    end
    tremove(creationQueue, 1)()
    C_After(creationDelay, function()
        processFunc()
    end)
end

function Ether:UpdateIndicators()
    local I = Ether.DB[501]

    if I[2] == 1 then
        creationQueue[#creationQueue + 1] = function()
            UpdateConnectionIcon()
        end
    end

    if I[3] == 1 then
        creationQueue[#creationQueue + 1] = function()
            UpdateRaidTargetIcon()
        end
    end

    if I[5] == 1 then
        creationQueue[#creationQueue + 1] = function()
            UpdateGroupLeaderIcon()
        end
    end

    if I[6] == 1 then
        creationQueue[#creationQueue + 1] = function()
            UpdateMasterLootIcon()
        end
    end

    if I[7] == 1 then
        creationQueue[#creationQueue + 1] = function()
            UpdateUnitFlagsIcon()
        end
    end

    if I[8] == 1 then
        creationQueue[#creationQueue + 1] = function()
            UpdatePlayerRolesIcon()
        end
    end

    if I[9] == 1 then
        creationQueue[#creationQueue + 1] = function()
            UpdatePlayerFlagsString()
        end
    end

    if not isUpdating then
        isUpdating = true;
        processFunc()
    end
end
