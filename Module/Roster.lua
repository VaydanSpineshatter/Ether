local _,Ether=...
local C_After=C_Timer.After
local UnitExists=UnitExists
local tinsert,tconcat=table.insert,table.concat
local IsEventValid=C_EventUtils.IsEventValid
local pairs,ipairs=pairs,ipairs
--local UnitGUID=UnitGUID
local soloButtons=Ether.soloButtons
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

local raidButtons=Ether.raidButtons
local function CheckRaidButtons(unit)
    for _,button in pairs(raidButtons) do
        if button and button.unit==unit then
            return button
        end
    end
    return nil
end

function Ether:UpdateRaidButtons()
    for index=1,GetNumGroupMembers() do
        local unit="raid"..index
        if UnitExists(unit) then
            local button=CheckRaidButtons(unit)
            if button then
                Ether:IndicatorsFullUpdateByUnit(button)
            end
        end
    end
end

local status=false
local function refreshButtons()
    if not status then
        status=true
        C_After(3,function()
            if not UnitInAnyGroup("player") then
                for _,button in pairs(raidButtons) do
                    if button then
                        Ether:UpdateDispelFrame(button,{0,0,0,0})
                        Ether:UpdatePrediction(button)
                    end
                end
                if Ether.DB[6][1]==1 then
                    Ether:AuraDisable()
                    Ether:AuraEnable()
                end
                if Ether.DB[1][6]==1 then
                    local btn=raidButtons["player"]
                    if btn then
                        Ether:IndicatorsFullUpdateByeUnit(btn)
                    end
                end
            else
                if Ether.DB[6][3]==1 then
                    for _,button in pairs(raidButtons) do
                        if button and button:IsVisible() then
                            Ether:UpdateClassColor(button)
                        end
                    end
                end
                if Ether.DB[1][6]==1 then
                    Ether:UpdateRaidButtons()
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
    for unit,button in pairs(raidButtons) do
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
            for unit,button in pairs(raidButtons) do
                if button then
                    if UnitExists(unit) then
                        Ether:InitialHealth(button)
                        Ether:IndicatorsFullUpdateUnit(button)
                    end
                end
            end
            initial=false
        end)
    end
end

function Ether:UpdateColors()
    for _,info in ipairs({"target","targettarget","pettarget"}) do
        Ether:UpdateClassColor(soloButtons[info])
        Ether:UpdatePowerColor(soloButtons[info])
    end
end

local sendChannel
local updatedChannel=false
local function UpdateSendChannel()
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        sendChannel="INSTANCE_CHAT"
    elseif IsInRaid() then
        sendChannel="RAID"
    else
        sendChannel="PARTY"
    end
end
local function Roster(_,event)
    if event=="PLAYER_UNGHOST" then
        if not UnitInBattleground("player") then return end
        initialButtons()
    elseif event=="GROUP_ROSTER_UPDATE" then
        refreshButtons()
        if IsInGroup() then
            if not updatedChannel then
                updatedChannel=true
                UpdateSendChannel()
                C_ChatInfo.SendAddonMessage(Ether.metaData[1],Ether.metaData[3],sendChannel)
            end
        else
            updatedChannel=false
        end
    elseif event=="PLAYER_TARGET_CHANGED" then
        if Ether.DB[1][6]==1 then
            Ether:UpdateSoloIndicator("target")
            Ether:UpdateSoloIndicator("targettarget")
        end
        Ether:UpdateColors()
        if Ether.DB[6][2]==1 then
            Ether:TargetAuraFullUpdate("target")
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
    if Ether.DB[6][1]==1 then
        Ether:AuraEnable()
    end
    if Ether.DB[1][6]==1 then
        Ether:IndicatorsEnable()
    end
    Ether:HealthEnable()
    Ether:PowerEnable()
    if Ether.DB[1][5]==1 then
        C_After(0.1,function()
            Ether:RangeEnable()
        end)
    end
    C_Timer.After(0.8,function()
        for _,button in pairs(raidButtons) do
            if Ether.DB[4][3]==1 then
                Ether:UpdateHealthTextRounded(button)
            end
            if Ether.DB[4][4]==1 then
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

