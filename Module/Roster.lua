local _, Ether = ...

local Roster = {}
Ether.Roster = Roster
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
        if Ether.DB[1002][2] == 1 then
            if UnitExists("target") then
                Ether.Aura.SingleAuraUpdateBuff(Ether.unitButtons.solo["target"])
                Ether.Aura.SingleAuraUpdateDebuff(Ether.unitButtons.solo["target"])
            end
        end
    end
end
local function onEnterEvent()
    for i = 1, GetNumGroupMembers() do
        local unit = "raid" .. i
        if unit then
            Ether.Aura.UpdateUnitAuras(unit)
        end
    end
end

local function RosterChanged(_, event)
    if event == "GROUP_ROSTER_UPDATE" then
        Ether:UpdateIndicators()

    end
end
local function RosterEnter(_, event)
    if event == "PLAYER_JOINING_WORLD" then
        if Ether.DB[1002][3] == 1 then
            C_After(0.2, function()
                Ether.AuraTexture:ReleaseAll()
            end)
        end
    end
end
local function RosterLeaved(_, event)
    if event == "PLAYER_LEAVING_WORLD" then
        if Ether.DB[1002][3] == 1 then
            C_After(1, function()
                Ether.AuraTexture:ReleaseAll()
            end)
        end
        if Ether.DB[801][1] == 1 then
            C_After(0.3, function()
                Ether.Range:UpdateTargetAlpha()
            end)
        end
    end
end

-- local snapCreate = {}
-- snapCreate = Ether.DataSnapShot(Ether.DB[201])
-- Ether.DataDisableAll(Ether.DB[201])
-- Ether.DataRestore(Ether.DB[201], snapCreate)
local function OnAfk(self)
    self.isActive = true
    Ether.CastBar.DisableCastEvents()
    Ether.hStatus:Disable()
    Ether.nStatus:Disable()
    Ether.pStatus:Disable()
    Ether.Aura:Disable()
    if Ether.DB[801][1] == 1 then
        C_After(0.1, function()
            Ether.Range:Disable()
        end)
    end
end

local function NotAfk(self)
    self.isActive = false
    Ether.CastBar.EnableCastEvents()
    Ether.hStatus:Enable()
    Ether.nStatus:Enable()
    Ether.pStatus:Enable()
    Ether.Aura:Enable()
    if Ether.DB[801][1] == 1 then
        C_After(0.1, function()
            Ether.Range:Enable()
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

function Roster:Enable()
    RegisterRosterEvent("GROUP_ROSTER_UPDATE", RosterChanged)
    RegisterRosterEvent("PLAYER_TARGET_CHANGED", TargetChanged)
    RegisterRosterEvent("PLAYER_FLAGS_CHANGED", PlayerFlags)
    RegisterRosterEvent("PLAYER_JOINING_WORLD", RosterEnter)
    RegisterRosterEvent("PLAYER_LEAVING_WORLD", RosterLeaved)
    if Ether.DB[801][1] == 1 then
        C_After(0.1, function()
            Ether.Range:Enable()
        end)
    end
end

function Roster:Disable()
    UnregisterRosterEvent("PLAYER_TARGET_CHANGED")
    UnregisterRosterEvent("GROUP_ROSTER_UPDATE")
    UnregisterRosterEvent("PLAYER_JOINING_WORLD")
    UnregisterRosterEvent("PLAYER_LEAVING_WORLD")
    if Ether.DB[801][1] == 0 then
        C_After(0.1, function()
            Ether.Range:Disable()
        end)
    end
end
