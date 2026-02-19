local _, Ether = ...
local C_After = C_Timer.After
local UnitExists = UnitExists
local tinsert = table.insert
local IsEventValid = C_EventUtils.IsEventValid
local ipairs = ipairs
local UnitGUID = UnitGUID
local C_PlayerInfo = C_PlayerInfo.GUIDIsPlayer
local GetRaidTargetIndex = GetRaidTargetIndex
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
        C_After(3, function()
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

local function Roster(_, event)
    if event == "ZONE_CHANGED" then
        refreshButtons()
    elseif event == "PLAYER_UNGHOST" then
        refreshButtons()
    elseif event == "GROUP_ROSTER_UPDATE" then
        refreshButtons()

    elseif event == "PLAYER_TARGET_CHANGED" then
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

local frame
if not frame then
    frame = CreateFrame("Frame")
end

function Ether:RosterEnable()
    if not frame:GetScript("OnEvent") then
        for _, events in ipairs({"PLAYER_TARGET_CHANGED", "PLAYER_UNGHOST", "GROUP_ROSTER_UPDATE", "ZONE_CHANGED"}) do
            if not frame:IsEventRegistered(events) and IsEventValid(events) then
                frame:RegisterEvent(events)
                frame:SetScript("OnEvent", Roster)
            end
        end
    end
    Ether:AuraEnable()
    if Ether.DB[401][6] == 1 then
        Ether:InitialIndicatorsPos()
        Ether:IndicatorsEnable()
    end
    Ether:NameEnable()
    Ether:HealthEnable()
    Ether:PowerEnable()
    if Ether.DB[401][5] == 1 then
        C_After(0.1, function()
            Ether:RangeEnable()
        end)
    end
    C_Timer.After(0.8, function()
        for _, button in pairs(Ether.unitButtons.raid) do
            if Ether.DB[701][3] == 1 then
                Ether:UpdateHealthTextRounded(button)
            end
            if Ether.DB[701][4] == 1 then
                Ether:UpdatePowerTextRounded(button)
            end
        end
    end)
end

function Ether:RosterDisable()
    if frame:GetScript("OnEvent") then
        frame:UnregisterAllEvents()
        frame:SetScript("OnEvent", nil)
    end
    Ether:AuraDisable()
    Ether:IndicatorsDisable()
    Ether:NameDisable()
    Ether:HealthDisable()
    Ether:PowerDisable()
    Ether:RangeDisable()
end

