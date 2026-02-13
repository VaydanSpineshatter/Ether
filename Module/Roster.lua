local _, Ether = ...
local C_After = C_Timer.After
local UnitExists = UnitExists
local tinsert = table.insert
local IsEventValid = C_EventUtils.IsEventValid
local ipairs = ipairs
local UnitGUID = UnitGUID
local C_PlayerInfo = C_PlayerInfo.GUIDIsPlayer
local RegisterRosterEvent, UnregisterRosterEvent
do
    local frame
    local Events = {}
    function RegisterRosterEvent(rosterEvent, func)
        if not frame then
            frame = CreateFrame("Frame")
            frame:SetScript("OnEvent", function(self, event, unit)
                Events[event](self, event, unit)
            end)
        end
        if not Events[rosterEvent] then
            if IsEventValid(rosterEvent) and not frame:IsEventRegistered(rosterEvent) then
                frame:RegisterEvent(rosterEvent)
            end
        end
        Events[rosterEvent] = func
    end
    function UnregisterRosterEvent(...)
        if frame then
            for i = select("#", ...), 1, -1 do
                local rosterEvent = select(i, ...)
                if IsEventValid(rosterEvent) then
                    if Events[rosterEvent] then
                        frame:UnregisterEvent(rosterEvent)
                    end
                end
                Events[rosterEvent] = nil
            end
        end
    end
end

local function TargetChanged(_, event)
    if event == "PLAYER_TARGET_CHANGED" then
        if UnitExists("target") then
            local button = Ether.unitButtons.solo["target"]
            if not button then return end
            local index = GetRaidTargetIndex("target")
            if index then
                button.RaidTarget:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
                SetRaidTargetIconTexture(button.RaidTarget, index)
                button.RaidTarget:Show()
            else
                button.RaidTarget:Hide()
            end
            if Ether.DB[1001][2] == 1 and button.Aura then
                Ether:TargetAuraFullUpdate()
            end
        end
    end
end
local data = {}
local function GetUnits()
    wipe(data)
    if UnitInParty("player") and not UnitInRaid("player") then
        tinsert(data, "player")
        for i = 1, GetNumSubgroupMembers() do
            local unit = "party" .. i
            if UnitExists(unit) then
                tinsert(data, unit)
            end
        end
    elseif UnitInRaid("player") then
        for i = 1, GetNumGroupMembers() do
            local unit = "raid" .. i
            if UnitExists(unit) then
                tinsert(data, unit)
            end
        end
    else
        tinsert(data, "player")
    end
    return data
end

local status = false
local function refreshButtons()
    if not status then
        status = true
        if not UnitInAnyGroup("player") then
            if Ether.DB[401][6] == 1 then
                Ether:FullUpdateIndicators()
            end
            if Ether.DB[1001][3] == 1 then
                Ether:FullAuraReset()
            end
            status = false
            return
        end
        C_After(3, function()
            if Ether.DB[401][6] == 1 then
                Ether:FullUpdateIndicators()
            end
            if Ether.DB[1001][3] == 1 then
                Ether:CleanupTimerCache()
                for _, unit in ipairs(GetUnits()) do
                    if UnitExists(unit) then
                        local button = Ether.unitButtons.raid[unit]
                        if not button then return end
                        local guid = UnitGUID(unit)
                        if guid and C_PlayerInfo(guid) then
                            Ether:UpdateRaidIsHelpful(button, guid)
                            Ether:UpdateRaidIsHarmful(button, guid)
                        end
                    end
                end
            end
            status = false
        end)
    end
end

local function RosterChanged(_, event)
    if event == "GROUP_ROSTER_UPDATE" then
        refreshButtons()
    end
end

local function PlayerUnghost(_, event)
    if event == "PLAYER_UNGHOST" then
        refreshButtons()
    end
end

local function ZoneChanged(_, event)
    if event == "ZONE_CHANGED" then
        refreshButtons()
    end
end

local function NewAreaChanged(_, event)
    if event == "ZONE_CHANGED_NEW_AREA" then
        refreshButtons()
    end
end

function Ether:RosterEnable()
    Ether:AuraEnable()
    if Ether.DB[401][6] == 1 then
        Ether:InitialIndicatorsPos()
        Ether:IndicatorsEnable()
    end
    Ether:NameEnable()
    Ether:HealthEnable()
    Ether:PowerEnable()
    RegisterRosterEvent("PLAYER_TARGET_CHANGED", TargetChanged)
    RegisterRosterEvent("PLAYER_UNGHOST", PlayerUnghost)
    RegisterRosterEvent("GROUP_ROSTER_UPDATE", RosterChanged)
    RegisterRosterEvent("ZONE_CHANGED", ZoneChanged)
    RegisterRosterEvent("ZONE_CHANGED_NEW_AREA", NewAreaChanged)
    if Ether.DB[401][5] == 1 then
        C_After(0.1, function()
            Ether:RangeEnable()
        end)
    end
end

function Ether:RosterDisable()
    UnregisterRosterEvent("PLAYER_TARGET_CHANGED")
    UnregisterRosterEvent("GROUP_ROSTER_UPDATE")
    UnregisterRosterEvent("PLAYER_UNGHOST")
    UnregisterRosterEvent("ZONE_CHANGED", ZoneChanged)
    UnregisterRosterEvent("ZONE_CHANGED_NEW_AREA", NewAreaChanged)
    if Ether.DB[401][5] == 1 then
        C_After(0.1, function()
            Ether.Range:Disable()
        end)
    end
end

