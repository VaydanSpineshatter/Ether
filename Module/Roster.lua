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

local VALID_UNIT_TYPES = {
    player = true,
    target = true,
    targettarget = true,
    pet = true,
    pettarget = true,
    focus = true,
    party = true,
    partypet = false,
    raid = true,
    raidpet = false,
}

function Ether.IsValidUnitForAuras(unit)
    if not unit then
        return false
    end
    local baseType, index = unit:match("^(%a+)(%d*)$")
    if not baseType then
        return false
    end
    if not VALID_UNIT_TYPES[baseType] then
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

local roster = {
    units = {}, -- [unit] = {guid, name, button, class, isPlayer, isPet}
    guids = {}, -- [guid] = unit
    buttons = {}, -- [unit] = button
    names = {}, -- [unit] = name
    classes = {}, -- [unit] = class
}


--[[
 for _, child in ipairs(Ether.Header.raid) do
            if child and child:GetAttribute("unit") then
                local unit = child:GetAttribute("unit")
                Ether.unitButtons.raid[unit] = child
            end
        end
        ]]

function Ether:RosterRegisterUnit(button, unit)
    if not unit or not UnitExists(unit) then
        return
    end
    local guid = UnitGUID(unit)
    if not guid then
        return
    end

    local oldUnit = roster.guids[guid]
    if oldUnit and oldUnit ~= unit then
        Ether:RosterUnregisterUnit(oldUnit)
    end

    local oldButtonUnit = button.unit
    if oldButtonUnit and oldButtonUnit ~= unit then
        if roster.buttons[oldButtonUnit] == button then
            roster.buttons[oldButtonUnit] = nil
            roster.units[oldButtonUnit] = nil
        end
    end

    local name = UnitName(unit)
    local class = select(2, UnitClass(unit))

    roster.units[unit] = {
        guid = guid,
        name = name,
        button = button,
        class = class,
    }

    roster.guids[guid] = unit
    roster.buttons[unit] = button
    roster.names[unit] = name
    roster.classes[unit] = class

    button.unit = unit
    button.unitGUID = guid

    Ether.unitButtons.raid[unit] = button

    return true
end

function Ether:RosterUnregisterUnit(unit)
    if not unit then
        return
    end

    local data = roster.units[unit]
    if data then
        local guid = data.guid

        roster.units[unit] = nil
        roster.buttons[unit] = nil
        roster.names[unit] = nil
        roster.classes[unit] = nil
        if roster.guids[guid] == unit then
            roster.guids[guid] = nil
        end
        Ether.unitButtons.raid[unit] = nil
    end
end

local function TargetChanged(_, event)
    if event == "PLAYER_TARGET_CHANGED" then
        if Ether.DB[1001][2] == 1 then
            C_After(0.05, function()
                if UnitExists("target") then
                    Ether:SingleAuraUpdateBuff(Ether.unitButtons.solo["target"])
                    Ether:SingleAuraUpdateDebuff(Ether.unitButtons.solo["target"])
                end
            end)
        end
    end
end

local function RosterChanged(_, event)
    if event == "GROUP_ROSTER_UPDATE" then
        C_After(0.1, function()
            Ether:UpdateIndicators()
        end)
        C_After(0.1, function()
            for i = 1, GetNumGroupMembers() do
                local unit = "raid" .. i
                if UnitExists(unit) then
                    Ether:UpdateUnitAuras(unit)
                    Ether:DispelAuraScan(unit)
                end
            end
        end)
    end
end

local function WorldEnter(_, event)
    if event == "PLAYER_JOINING_WORLD" then
        C_After(0.1, function()
            Ether:UpdateIndicators()
        end)
        if Ether.DB[1001][3] == 1 then
            C_After(0.1, function()
                for i = 1, GetNumGroupMembers() do
                    local unit = "raid" .. i
                    if UnitExists(unit) then
                        Ether:UpdateUnitAuras(unit)
                        Ether:DispelAuraScan(unit)
                    end
                end
            end)
        end
    end
end

local function WorldLeaved(_, event)
    if event == "PLAYER_LEAVING_WORLD" then
        C_After(0.1, function()
            Ether:UpdateIndicators()
        end)

        wipe(Ether.rangeCache)
    end
end
local function Unghost(_, event)
    if event == "PLAYER_UNGHOST" then
        Ether:UpdateIndicators()
    end
end
local function OnAfk(self)
    self.isActive = true
    Ether.CastBar.DisableCastEvents()
    Ether:NameDisable()
    Ether:HealthDisable()
    Ether:PowerDisable()
    Ether:AuraDisable()
    if Ether.DB[801][6] == 1 then
        C_After(0.1, function()
            Ether:RangeDisable()
        end)
    end
end

local function NotAfk(self)
    self.isActive = false
    Ether.CastBar.EnableCastEvents()
    Ether:NameEnable()
    Ether:HealthEnable()
    Ether:PowerEnable()
    Ether:AuraEnable()
    if Ether.DB[801][6] == 1 then
        C_After(0.1, function()
            Ether:RangeEnable()
        end)
    end
end

local function PlayerFlags(self, event, unit)
    if event == "PLAYER_FLAGS_CHANGED" and unit == "player" then
        if UnitIsAFK(unit) then
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

function Ether:RosterEnable()
    Ether:AuraEnable()
    Ether:IndicatorsToggle()
    Ether:UpdateIndicators()
    Ether:NameEnable()
    Ether:HealthEnable()
    Ether:PowerEnable()
    RegisterRosterEvent("GROUP_ROSTER_UPDATE", RosterChanged)
    RegisterRosterEvent("PLAYER_TARGET_CHANGED", TargetChanged)
    RegisterRosterEvent("PLAYER_UNGHOST", Unghost)
    RegisterRosterEvent("PLAYER_FLAGS_CHANGED", PlayerFlags)
    RegisterRosterEvent("PLAYER_JOINING_WORLD", WorldEnter)
    RegisterRosterEvent("PLAYER_LEAVING_WORLD", WorldLeaved)
    if Ether.DB[801][6] == 1 then
        C_After(0.1, function()
            Ether:RangeEnable()
        end)
    end
end

function Ether:RosterDisable()
    UnregisterRosterEvent("PLAYER_TARGET_CHANGED")
    UnregisterRosterEvent("GROUP_ROSTER_UPDATE")
    UnregisterRosterEvent("PLAYER_UNGHOST")
    UnregisterRosterEvent("PLAYER_JOINING_WORLD")
    UnregisterRosterEvent("PLAYER_LEAVING_WORLD")
    if Ether.DB[801][6] == 1 then
        C_After(0.1, function()
            Ether.Range:Disable()
        end)
    end
end
