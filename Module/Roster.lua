local _, Ether = ...

local C_After = C_Timer.After

local RegisterRosterEvent, UnregisterRosterEvent
do
    local IsEventValid = C_EventUtils.IsEventValid
    local frame
    local Events = {}
    function RegisterRosterEvent(castEvent, func)
        if not frame then
            frame = CreateFrame("Frame")
            frame:SetScript("OnEvent", function(self, event, unit, ...)
                Events[event](self, event, unit, ...)
            end)
        end
        if not Events[castEvent] then
            if IsEventValid(castEvent) and not frame:IsEventRegistered(castEvent) then
                frame:RegisterEvent(castEvent)
            end
        end
        Events[castEvent] = func
    end
    function UnregisterRosterEvent(...)
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

local function GetUnits()
    local data = {}
    if UnitInParty("player") and not UnitInRaid("player") then
        table.insert(data, "player")
        for i = 1, GetNumSubgroupMembers() do
            local unit = "party" .. i
            if UnitExists(unit) then
                table.insert(data, unit)
            end
        end
    elseif UnitInRaid("player") or UnitInBattleground("player") then
        for i = 1, GetNumGroupMembers() do
            local unit = "raid" .. i
            if UnitExists(unit) then
                table.insert(data, unit)
            end
        end
    else
        table.insert(data, "player")
    end
    return data
end

local status = false
local function ifValidUnits()
    if not status then
        status = true
        C_After(4, function()
            if Ether.DB[1001][3] == 1 then
                if not UnitInAnyGroup("player") then
                    Ether:DisableHeaderAuras()
                    Ether:EnableHeaderAuras()
                else
                    local getUnits = Ether.GetUnits()
                    for _, unit in ipairs(getUnits) do
                        if UnitExists(unit) then
                            Ether:UpdateRaidIsHelpful(unit, true)
                            Ether:UpdateRaidIsHarmful(unit, true)
                        end
                    end
                end
            end
            if Ether.DB[401][6] == 1 then
                for _, unit in ipairs(GetUnits()) do
                    if UnitExists(unit) then
                        Ether:IndicatorsUnitUpdate(unit)
                    end
                end
            end
            status = false
        end)
    end
end

local timer = false
local function clearTimerCache()
    if not timer then
        timer = true
        C_After(10, function()
            Ether:CleanupTimerCache()
            timer = false
        end)
    end
end

local function WorldEnter(_, event)
    if event == "PLAYER_ENTERING_WORLD" then
        ifValidUnits()
    end
end

local function RosterChanged(_, event)
    if event == "GROUP_ROSTER_UPDATE" then
        ifValidUnits()
        if Ether.DB[1001][3] == 1 then
            clearTimerCache()
        end
    end
end

local function PlayerUnghost(_, event)
    if event == "PLAYER_UNGHOST" then
        if Ether.DB[401][6] == 1 then
            C_After(0.3, function()
                for _, unit in ipairs(GetUnits()) do
                    if UnitExists(unit) then
                        Ether:IndicatorsUnitUpdate(unit)
                    end
                end
            end)
        end
    end
end

local function ZoneChanged(_, event)
    if event == "ZONE_CHANGED" then
        if Ether.DB[401][6] == 1 then
            C_After(0.3, function()
                for _, unit in ipairs(GetUnits()) do
                    if UnitExists(unit) then
                        Ether:IndicatorsUnitUpdate(unit)
                    end
                end
            end)
        end
    end
end

local function NewAreaChanged(_, event)
    if event == "ZONE_CHANGED_NEW_AREA" then
        if Ether.DB[401][6] == 1 then
            C_After(0.3, function()
                for _, unit in ipairs(GetUnits()) do
                    if UnitExists(unit) then
                        Ether:IndicatorsUnitUpdate(unit)
                    end
                end
            end)
        end
    end
end

function Ether:RosterEnable()
    Ether:AuraEnable()
    if Ether.DB[401][6] == 1 then
        Ether:IndicatorsEnable()
        Ether:InitialIndicatorsPos()
        C_After(0.3, function()
            for _, unit in ipairs(GetUnits()) do
                if UnitExists(unit) then
                    Ether:IndicatorsUnitUpdate(unit)
                end
            end
        end)
    end
    Ether:NameEnable()
    Ether:HealthEnable()
    Ether:PowerEnable()
    RegisterRosterEvent("PLAYER_ENTERING_WORLD", WorldEnter)
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
    UnregisterRosterEvent("PLAYER_ENTERING_WORLD")
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

