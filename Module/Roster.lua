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
        if Ether.DB[1001][3] == 1 then
            if UnitExists("target") then
                local button = Ether.unitButtons.solo["target"]
                if not button then return end
                Ether:SingleAuraUpdateBuff(button)
                Ether:SingleAuraUpdateDebuff(button)
                local index = GetRaidTargetIndex("target")
                if index then
                    button.RaidTarget:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
                    SetRaidTargetIconTexture(button.RaidTarget, index)
                    button.RaidTarget:Show()
                else
                    button.RaidTarget:Hide()
                end
            end
        end
    end
end

local status = false
local function ifValidUnits()
    if not status then
        status = true
        C_After(5, function()
            Ether:FullUpdateIndicators()
            Ether:HeaderBackground()
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
        if Ether.DB[1001][4] == 1 then
            clearTimerCache()
        end
    end
end
local function PlayerUnghost(_, event)
    if event == "PLAYER_UNGHOST" then
        C_After(0.2, function()
            Ether:FullUpdateIndicators()
        end)
    end
end
--[[
  for i = 1, GetNumGroupMembers() do
            local unit = "raid" .. i
                if UnitExists(unit) then
                    Ether:IndicatorsUpdateUnit(unit)
                end
            end
]]
function Ether:RosterEnable()
    Ether:AuraEnable()
    Ether:IndicatorsEnable()
    Ether:InitialIndicatorsPos()
    Ether:NameEnable()
    Ether:HealthEnable()
    Ether:PowerEnable()
    RegisterRosterEvent("PLAYER_ENTERING_WORLD", WorldEnter)
    RegisterRosterEvent("PLAYER_TARGET_CHANGED", TargetChanged)
    RegisterRosterEvent("PLAYER_UNGHOST", PlayerUnghost)
    RegisterRosterEvent("GROUP_ROSTER_UPDATE", RosterChanged)
    if Ether.DB[801][6] == 1 then
        C_After(0.1, function()
            Ether:RangeEnable()
        end)
    end
    Ether:FullUpdateIndicators()
end

function Ether:RosterDisable()
    UnregisterRosterEvent("PLAYER_TARGET_CHANGED")
    UnregisterRosterEvent("PLAYER_ENTERING_WORLD")
    UnregisterRosterEvent("GROUP_ROSTER_UPDATE")
    UnregisterRosterEvent("PLAYER_UNGHOST")
    if Ether.DB[801][6] == 1 then
        C_After(0.1, function()
            Ether.Range:Disable()
        end)
    end
end

