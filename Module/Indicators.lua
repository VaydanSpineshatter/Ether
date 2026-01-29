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

local function StringMethod()
    local method = CreateFrame("Frame", nil, UIParent)
    method.string = method:CreateFontString(nil, "OVERLAY")
    method.string:SetFont(unpack(Ether.mediaPath.Font), 10, "OUTLINE")
    function method:Setup(parent, position, offsetX, offsetY)
        self.string:SetParent(parent)
        self.string:SetPoint(position, parent, position, offsetX, offsetY)
        self.string:Show()
    end
    function method:Reset()
        self.string:Hide()
        self.string:ClearAllPoints()
        self.string:SetParent(nil)
    end
    return method
end

local function TextureMethod()
    local method = CreateFrame("Frame", nil, UIParent)
    method.texture = method:CreateTexture(nil, "OVERLAY")
    function method:Setup(parent, size, position, offsetX, offsetY)
        self.texture:SetParent(parent)
        self.texture:SetSize(size, size)
        self.texture:SetTexCoord(0, 1, 0, 1)
        self.texture:SetPoint(position, parent, position, offsetX, offsetY)
        self.texture:Show()
    end
    function method:Reset()
        self.texture:Hide()
        self.texture:ClearAllPoints()
        self.texture:SetParent(nil)
    end
    return method
end

local getTextureMethod = Ether:CreateObjPool(TextureMethod)
local getStringMethod = Ether:CreateObjPool(StringMethod)

function Ether:HideIndicators(hide, method)
    for _, button in pairs(Ether.unitButtons.raid) do
        if (button and button.Indicators and button.Indicators[hide]) then
            if method ~= "string" then
                getTextureMethod:Release(button.Indicators[hide])
                button.Indicators[hide] = nil
            else
                getStringMethod:Release(button.Indicators[hide])
                button.Indicators[hide] = nil
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

local function UpdateUnitFlagsIcon()
    for unit, button in pairs(Ether.unitButtons.raid) do
        if button and unit then
            if not button.Indicators.UnitFlagsIcon then
                button.Indicators.UnitFlagsIcon = getTextureMethod:Acquire(button.healthBar, 12, "TOP")
            end
            local IsCharmed = UnitIsCharmed(unit)
            local IsDead = UnitIsDead(unit)
            local IsGhost = UnitIsGhost(unit)

            if (IsCharmed) then
                button.name:SetTextColor(1.00, 0.00, 0.00)
            elseif (IsGhost) then
                button.Indicators.UnitFlagsIcon.texture:SetTexture(ghostIcon)
                button.Indicators.UnitFlagsIcon.texture:Show()
                unitIsDead(button)
            elseif (IsDead) then
                button.Indicators.UnitFlagsIcon.texture:SetTexture(deadIcon)
                button.Indicators.UnitFlagsIcon.texture:Show()
                unitIsDead(button)
            else
                button.name:SetTextColor(1, 1, 1)
                if button.Indicators.UnitFlagsIcon then
                   button.Indicators.UnitFlagsIcon.texture:Hide()
                end
            end
        end
    end
end

local IndicatorsRdy = {}

local function UpdateReadyCheckIcon()
    for unit, button in pairs(Ether.unitButtons.raid) do
        if button and unit then
            if not button.Indicators.ReadyCheckIcon then
                button.Indicators.ReadyCheckIcon = getTextureMethod:Acquire(button.healthBar, 18, "TOP")
            end
            local status = GetReadyCheckStatus(unit)
            if (status) then
                if (status == "ready") then
                    button.Indicators.ReadyCheckIcon.texture:SetTexture(ReadyCheck_Ready)
                    button.Indicators.ReadyCheckIcon.texture:Show()
                elseif (status == "notready") then
                    button.Indicators.ReadyCheckIcon.texture:SetTexture(ReadyCheck_NotReady)
                    button.Indicators.ReadyCheckIcon.texture:Show()
                elseif (status == "waiting") then
                    button.Indicators.ReadyCheckIcon.texture:SetTexture(ReadyCheck_Waiting)
                    button.Indicators.ReadyCheckIcon.texture:Show()
                end
            else
                if button.Indicators.ReadyCheckIcon then
                    button.Indicators.ReadyCheckIcon.texture:Hide()
                end
            end
        end
    end
end

local function UpdateConfirmIcon()
    for unit, button in pairs(Ether.unitButtons.raid) do
        if button and unit then
            if not button.Indicators.ReadyCheckIcon or not button.Indicators.ReadyCheckIcon.texture then return end
            local status = GetReadyCheckStatus(unit)
            if (status == "ready") then
                button.Indicators.ReadyCheckIcon.texture:SetTexture(ReadyCheck_Ready)
                button.Indicators.ReadyCheckIcon.texture:Show()
            elseif (status == "notready") then
                button.Indicators.ReadyCheckIcon.texture:SetTexture(ReadyCheck_NotReady)
                button.Indicators.ReadyCheckIcon.texture:Show()
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
                button.Indicators.GroupLeaderIcon = getTextureMethod:Acquire(button.healthBar, 12, "RIGHT")
            end
            local IsLeader = UnitIsGroupLeader(unit)
            if (IsLeader) then
                button.Indicators.GroupLeaderIcon.texture:SetTexture(leader)
            else
                button.Indicators.GroupLeaderIcon.texture:Hide()
            end
        end
    end
end

local function UpdateMasterLootIcon()
    for unit, button in pairs(Ether.unitButtons.raid) do
        if button and unit then
            if not button.Indicators.MasterLootIcon then
                button.Indicators.MasterLootIcon = getTextureMethod:Acquire(button.healthBar, 12, "BOTTOMRIGHT", 0, 12)
            end
            button.Indicators.MasterLootIcon.texture:SetTexture(masterlootIcon)
            button.Indicators.MasterLootIcon.texture:Hide()
            local lootType, partyID, raidID = GetLoot()
            if lootType == Enum.LootMethod.Masterlooter then
                local masterLooterUnit = raidID and ((raidID == 0) and "player" or "raid" .. raidID) or partyID and ((partyID == 0) and "player" or "party" .. partyID)
                if masterLooterUnit and UnitIsUnit(unit, masterLooterUnit) then
                    button.Indicators.MasterLootIcon.texture:Show()
                else
                    button.Indicators.MasterLootIcon.texture:Hide()
                end
            end
        end
    end
end
local function UpdatePlayerRolesIcon()
    for unit, button in pairs(Ether.unitButtons.raid) do
        if button and unit then
            if not button.Indicators.MainTankIcon then
                button.Indicators.MainTankIcon = getTextureMethod:Acquire(button.healthBar, 12, "LEFT")
            end
            if not IsInRaid() and button.Indicators.MainTankIcon then
                button.Indicators.MainTankIcon.texture:Hide()
            else
                if (GetPartyAssignment("MAINTANK", unit)) then
                    button.Indicators.MainTankIcon.texture:SetTexture(mainTankIcon)
                    button.Indicators.MainTankIcon.texture:Show()
                elseif (GetPartyAssignment("MAINASSIST", unit)) then
                    button.Indicators.MainTankIcon.texture:SetTexture(mainAssistIcon)
                    button.Indicators.MainTankIcon.texture:Show()
                else
                    button.Indicators.MainTankIcon.texture:Hide()
                end
            end
        end
    end
end

local function UpdateConnectionIcon()
    for unit, button in pairs(Ether.unitButtons.raid) do
        if button and unit then
            if not button.Indicators.ConnectionIcon then
                button.Indicators.ConnectionIcon = getTextureMethod:Acquire(button.healthBar, 24, "TOPLEFT")
            end
            local isConnected = UnitIsConnected(unit)
            if (not isConnected) then
                button.Indicators.ConnectionIcon.texture:SetTexture(connectionIcon)
                button.Indicators.ConnectionIcon.texture:Show()
                button.healthBar:SetStatusBarColor(0.5, 0.5, 0.5)
            else
                button.Indicators.ConnectionIcon.texture:Hide()
            end
        end
    end
end

local function UpdateRaidTargetIcon()
    for unit, button in pairs(Ether.unitButtons.raid) do
        if button and UnitExists(unit) then
            if not button.Indicators.RaidTargetIcon then
                button.Indicators.RaidTargetIcon = getTextureMethod:Acquire(button.healthBar, 12, "BOTTOM")
            end
            local index = GetRaidTargetIndex(unit)
            if index then
                button.Indicators.RaidTargetIcon.texture:SetTexture(target)
                button.Indicators.RaidTargetIcon.texture:Show()
                SetRaidTargetIconTexture(button.Indicators.RaidTargetIcon.texture, index)
            else
                button.Indicators.RaidTargetIcon.texture:Hide()
            end
        end
    end
end

local function UpdateResurrectionIcon()
    for unit, button in pairs(Ether.unitButtons.raid) do
        if button and unit then
            if not button.Indicators.ResurrectionIcon then
                button.Indicators.ResurrectionIcon = getTextureMethod:Acquire(button.healthBar, 24, "CENTER")
            end
            local Resurrection = UnitHasIncomingResurrection(unit)
            if (Resurrection) then
                button.Indicators.ResurrectionIcon.texture:SetTexture(rezIcon)
                button.Indicators.ResurrectionIcon.texture:Show()
            else
                button.Indicators.ResurrectionIcon.texture:Hide()
            end
        end
    end
end

local function UpdatePlayerFlagsString()
    for unit, button in pairs(Ether.unitButtons.raid) do
        if button and unit then
            if not button.Indicators.PlayerFlagsString then
                button.Indicators.PlayerFlagsString = getStringMethod:Acquire(button.healthBar, "TOPLEFT")
            end
            local away = UnitIsAFK(unit)
            local dnd = UnitIsDND(unit)
            if away then
                button.Indicators.PlayerFlagsString.string:SetText(AFK)
                button.Indicators.PlayerFlagsString.string:Show()
            elseif dnd then
                button.Indicators.PlayerFlagsString.string:SetText(DND)
                button.Indicators.PlayerFlagsString.string:Show()
            else
                button.Indicators.PlayerFlagsString.string:Hide()
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

local IndicatorsHandlers = {
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
Ether.IndicatorHandlers = IndicatorsHandlers

function Ether:IndicatorsToggle()
    local I = Ether.DB[501]
    for index, handlers in ipairs(IndicatorsHandlers) do
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
    for index, handlers in ipairs(IndicatorsHandlers) do
        if I[index] == 1 then
            handlers[1]()
        end
    end
end

function Ether:IndicatorsDisable()
    for index, handlers in ipairs(IndicatorsHandlers) do
        if index ~= 9 then
            handlers[2]()
        end
    end
end

function Ether:IndicatorsUpdate()
    local I = Ether.DB[501]
    for index, handlers in ipairs(IndicatorsHandlers) do
        if I[index] == 1 and handlers[3] then
            handlers[3]()
        end
    end
end
