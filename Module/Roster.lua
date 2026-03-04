local _,Ether=...
local C_After=C_Timer.After
local UnitExists=UnitExists
local tinsert,tconcat=table.insert,table.concat
local IsEventValid=C_EventUtils.IsEventValid
local pairs,ipairs=pairs,ipairs
--local UnitGUID=UnitGUID

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

function Ether:IsValidSolo(unit)
    return cacheSolo[unit]
end

function Ether:IsValidAura(unit)
    return cacheSoloAura[unit]
end
--[[
local function CheckRaidButtons(arg1)
    for unit,button in pairs(Ether.unitButtons.raid) do
        if button and unit and unit==arg1 then
            return button,button.unit,button.destGUID
        end
    end
    return nil
end
     for index = 1, GetNumGroupMembers() do
                    local unit = "raid" .. index
                    if UnitExists(unit) then
                        local button, _, guid =CheckRaidButtons(unit)
                        if not button then return end
                        UpdateAuraByIndex(unit, guid)
                    end
                end

local function UpdateAuraByIndex(unit,guid)
    local C=Ether.DB[1003]
     if not Ether.dataSpell[guid] then
        Ether.dataSpell[guid]={}
     end
    local index=1
    while true do
        local aura=C_UnitAuras.GetBuffDataByIndex(unit,index)
        if not aura then
            break
        end
        if not C[aura.spellId] or not C[aura.spellId].isEnabled then return end
        Ether.dataSpell[guid][aura.spellId] = Ether.texPool:Acquire(C[aura.spellId],unit)
        Ether.spellInstance[aura.auraInstanceID]=aura
        index=index+1
    end
end
]]
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
                    Ether:AuraDisable()
                    Ether:AuraEnable()
                end
            else
                if Ether.DB[1001][3]==1 then
                   -- Ether:ReleaseAll()
                end
                if Ether.DB[401][6]==1 then
                    Ether.Handler:FullUpdate()
                end
            end
            status=false
        end)
    end
end

local number=0
local IsPVP={}
function Ether:CheckPvpStatus()
    number=0
    wipe(IsPVP)
    tinsert(IsPVP,"|cffcc66ffPvP Mismatch found:|r")
    for unit,button in pairs(Ether.unitButtons.raid) do
        if button then
            if UnitExists(unit) then
                local name=UnitName(unit)
                local pvp=UnitIsPVPFreeForAll(unit)
                if pvp and name then
                    tinsert(IsPVP,name)
                    number=number+1
                end
            end
        end
    end
    tinsert(IsPVP,"|cffcc66ffMismatch total:|r "..tostring(number))
    local concat=tconcat(IsPVP,"\n")
    Ether:EtherInfo(concat)
end

local initial=false
local function initialButtons()
    if not initial then
        initial=true
        C_After(1.5,function()
            for unit,button in pairs(Ether.unitButtons.raid) do
                if button and button:IsVisible() then
                    if UnitExists(unit) then
                        Ether:InitialHealth(button)
                    end
                end
            end
            initial=false
        end)
    end
end

local function Roster(_,event)
    if event=="PLAYER_UNGHOST" then
        if not UnitInBattleground("player") then return end
        initialButtons()
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
    if Ether.DB[1001][1]==1 then
        Ether:AuraEnable()
    end
    if Ether.DB[401][6]==1 then
        Ether:IndicatorsEnable()
    end
    Ether:HealthEnable()
    Ether:PowerEnable()
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

