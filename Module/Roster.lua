local _,Ether=...
local C_After=C_Timer.After
local UnitExists=UnitExists
local tinsert=table.insert
local IsEventValid=C_EventUtils.IsEventValid
local ipairs=ipairs
local UnitGUID=UnitGUID
local data={}
local function GetUnits()
    wipe(data)
    if UnitInParty("player") and not UnitInRaid("player") then
        for i=1,GetNumSubgroupMembers() do
            tinsert(data,"player")
            local unit="party"..i
            if UnitExists(unit) then
                tinsert(data,unit)
            end
        end
    elseif UnitInRaid("player") and not UnitInParty("player") then
        for i=1,GetNumGroupMembers() do
            local unit="raid"..i
            if UnitExists(unit) then
                tinsert(data,unit)
            end
        end
    elseif not UnitInAnyGroup("player") then
        tinsert(data,"player")
    end
    return data
end

local unitCache={
    player=true,
}

local cacheSolo={
    player=true,
    pet=true,
    pettarget=true,
    target=true,
    targettarget=true,
    focus=true
}

local cacheSoloAura={
    player=true,
    pet=true,
    target=true,
}

for i=1,40 do
    unitCache["raid"..i]=true
end

for i=1,40 do
    unitCache["raidpet"..i]=true
end

for i=1,4 do
    unitCache["party"..i]=true
end

for i=1,4 do
    unitCache["partypet"..i]=true
end

function Ether:IsValidSolo(unit)
    return cacheSolo[unit]
end

function Ether:IsValidSoloAura(unit)
    return cacheSoloAura[unit]
end

function Ether:IsValidUnit(unit)
    return unitCache[unit]
end

local status=false
local function refreshButtons()
    if not status then
        status=true
        C_After(3,function()
            if not UnitInAnyGroup("player") then
                for _,button in pairs(Ether.unitButtons.raid) do
                    if button then
                        Ether:UpdateDispelFrame(button,{0,0,0,0})
                        Ether:UpdatePrediction(button)
                    end
                end
                if Ether.DB[1001][1]==1 then
                    Ether:FullAuraReset()
                end
                if Ether.DB[401][6]==1 then
                    Ether.Handler:FullUpdate()
                end
            else
                if Ether.DB[1001][3]==1 then
                    for _,button in pairs(Ether.unitButtons.raid) do
                        if button then
                            local guid=UnitGUID(button.unit)
                            if guid then
                                Ether:CheckRaidAuras(button,guid)
                            end
                        end
                    end
                end
                if Ether.DB[401][6]==1 then
                    Ether.Handler:FullUpdate()
                end
                if UnitInBattleground("player") then
                    for index = 1, GetNumGroupMembers() do
                        local unit = "raid" .. index
                        if UnitExists(unit) then
                            local button = Ether.unitButtons.raid[unit]
                            if button then
                                Ether:InitialHealth(button)
                            end
                        end
                    end
                end
            end
            status=false
        end)
    end
end

local number = 0
local IsPVP = {}
function Ether:CheckPvpStatus()
    number = 0
    wipe(IsPVP)
    table.insert(IsPVP, "|cffcc66ffPvP Mismatch found:|r")
    for unit,button in pairs(Ether.unitButtons.raid) do
            if button then
                if UnitExists(unit) then
                local name = UnitName(unit)
                local pvp=UnitIsPVPFreeForAll(unit)
                if pvp and name then
                    table.insert(IsPVP, name)
                    number = number + 1
                end
            end
        end
    end
    table.insert(IsPVP, "|cffcc66ffMismatch total:|r " ..  tostring(number))
    local concat = table.concat(IsPVP, "\n")
    Ether:EtherInfo(concat)
end

local function Roster(_,event)
    if event=="PLAYER_UNGHOST" then
        refreshButtons()
    elseif event=="GROUP_ROSTER_UPDATE" then
        refreshButtons()
    elseif event=="PLAYER_TARGET_CHANGED" then
        if Ether.DB[401][6]==1 then
            Ether:UpdateSoloIndicator("target")
            Ether:UpdateSoloIndicator("targettarget")
        end
        if Ether.DB[1001][2]==1 then
            Ether:TargetAuraFullUpdate()
        end
    end
end

local frame
if not frame then
    frame=CreateFrame("Frame")
end

function Ether:RosterEnable()
    if not frame:GetScript("OnEvent") then
        for _,events in ipairs({"PLAYER_TARGET_CHANGED","PLAYER_UNGHOST","GROUP_ROSTER_UPDATE"}) do
            if not frame:IsEventRegistered(events) and IsEventValid(events) then
                frame:RegisterEvent(events)
                frame:SetScript("OnEvent",Roster)
            end
        end
    end
    if Ether.DB[401][6]==1 then
        Ether:IndicatorsEnable()
    end
    Ether:HealthEnable()
    Ether:PowerEnable()
    Ether:AuraEnable()
    if Ether.DB[401][5]==1 then
        C_After(0.1,function()
            Ether:RangeEnable()
        end)
    end
    C_Timer.After(0.8,function()
        for _,button in pairs(Ether.unitButtons.raid) do
            if Ether.DB[701][3]==1 then
                Ether:UpdateHealthTextRounded(button)
            end
            if Ether.DB[701][4]==1 then
                Ether:UpdatePowerTextRounded(button)
            end
        end
    end)
end

function Ether:RosterDisable()
    if frame:GetScript("OnEvent") then
        frame:UnregisterAllEvents()
        frame:SetScript("OnEvent",nil)
    end
    Ether:AuraDisable()
    Ether:IndicatorsDisable()
    Ether:HealthDisable()
    Ether:PowerDisable()
    Ether:RangeDisable()
end

