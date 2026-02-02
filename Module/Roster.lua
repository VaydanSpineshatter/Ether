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

local ValidUnits = {
    player = false,
    party = false,
    partypet = false,
    raid = true,
    raidpet = false,
}

function Ether:IsValidUnitForAuras(unit)
    if not unit then
        return false
    end
    local baseType, index = unit:match("^(%a+)(%d*)$")
    if not baseType then
        return false
    end
    if not ValidUnits[baseType] then
        return false
    end
    if index ~= "" then
        local num = tonumber(index)
        if baseType == "raid" then
            if not num or num < 1 or num > 40 then
                return false
            end
        elseif baseType == "party" then
            if not num or num < 1 or num > 4 then
                return false
            end
        end
    end
    return UnitExists(unit)
end

local function TargetChanged(_, event)
    if event == "PLAYER_TARGET_CHANGED" then
        if Ether.DB[1001][3] == 1 then
            if UnitExists("target") then
                Ether:SingleAuraUpdateBuff(Ether.unitButtons.solo["target"])
                Ether:SingleAuraUpdateDebuff(Ether.unitButtons.solo["target"])
            end
        end
    end
end

local function WorldEnter(_, event)
    if event == "PLAYER_ENTERING_WORLD" then
        C_After(1, function()
            if not UnitInAnyGroup("player") then
                ValidUnits.player = true
                ValidUnits.raid = false
                ValidUnits.party = false
            elseif UnitInRaid("player") then
                ValidUnits.player = false
                ValidUnits.party = false
                ValidUnits.raid = true
            elseif UnitInParty("player") then
                ValidUnits.player = true
                ValidUnits.party = true
                ValidUnits.raid = false
            end
        end)
    end
end

local status = false
local function ifValidUnits()
    if not status then
        status = true
        C_After(4, function()
            if not UnitInAnyGroup("player") then
                ValidUnits.player = true
                ValidUnits.raid = false
                ValidUnits.party = false
            elseif UnitInRaid("player") then
                ValidUnits.player = false
                ValidUnits.party = false
                ValidUnits.raid = true
            elseif UnitInParty("player") then
                ValidUnits.player = true
                ValidUnits.party = true
                ValidUnits.raid = false
            end
            status = false
        end)
    end
end
local function RosterChanged(_, event)
    if event == "GROUP_ROSTER_UPDATE" then
        ifValidUnits()
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
    Ether:FullUpdateIndicators()
    Ether:NameEnable()
    Ether:HealthEnable()
    Ether:PowerEnable()
    RegisterRosterEvent("PLAYER_ENTERING_WORLD", WorldEnter)
    RegisterRosterEvent("PLAYER_TARGET_CHANGED", TargetChanged)
    RegisterRosterEvent("GROUP_ROSTER_UPDATE", RosterChanged)
    if Ether.DB[801][6] == 1 then
        C_After(0.1, function()
            Ether:RangeEnable()
        end)
    end
end

function Ether:RosterDisable()
    UnregisterRosterEvent("PLAYER_TARGET_CHANGED")
    UnregisterRosterEvent("PLAYER_ENTERING_WORLD")
    UnregisterRosterEvent("GROUP_ROSTER_UPDATE")
    if Ether.DB[801][6] == 1 then
        C_After(0.1, function()
            Ether.Range:Disable()
        end)
    end
end

