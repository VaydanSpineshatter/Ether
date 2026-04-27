local D,F=unpack(select(2,...))
local C_Ticker,pairs,GetTime=C_Timer.NewTicker,pairs,GetTime
local UnitInRange,UnitIsConnected,IsInGroup=UnitInRange,UnitIsConnected,IsInGroup
local UnitCanAssist,UnitCanAttack,IsSpellInRange,UnitIsVisible,UnitPhaseReason=UnitCanAssist,UnitCanAttack,C_Spell.IsSpellInRange,UnitIsVisible,UnitPhaseReason
local raidBtn,soloBtn,UnitExists=D.raidBtn,D.soloBtn,UnitExists
local fTbl={6673,19750,75,36554,2061,0,403,1459,2970,0,8936}
local hTbl={355,21084,75,6770,589,0,403,133,17793,0,8921}
local f=fTbl[select(3,UnitClass("player"))]
local h=hTbl[select(3,UnitClass("player"))]
local function IsInRange(unit)
    if not unit then return end
    local r
    if UnitCanAssist("player",unit) then
        r=IsSpellInRange(f,unit)
    elseif UnitCanAttack("player",unit) then
        r=IsSpellInRange(h,unit)
    end
    return r and 1 or .45
end
local function ScanUnits(b,unit)
    if not UnitIsConnected(unit) then
        F:HideButtonDispellable(b)
        F:HidePrediction(b)
        b:SetAlpha(1)
        return true
    end
    if UnitPhaseReason(unit) then
        F:HideButtonDispellable(b)
        F:HidePrediction(b)
        b:SetAlpha(.45)
        return true
    end
    if not UnitIsVisible(unit) then
        F:HideButtonDispellable(b)
        F:HidePrediction(b)
        b:SetAlpha(.45)
        return true
    end
    return false
end
local cache={}
local function CleanupCache()
    local currentTime=GetTime()
    for unit,data in pairs(cache) do
        if (currentTime-data.timestamp)>=5 then
            cache[unit]=nil
        end
    end
end
local function GetCachedStatus(b)
    local unit=b.unit
    local status=cache[unit]
    if status and (GetTime()-status.timestamp)<=5 then
        return status.callback
    end
    local callback=ScanUnits(b,unit)
    cache[unit]={timestamp=GetTime(),callback=callback}
    return callback
end
function F:UpdateAlpha(b)
    if not b or not b.unit or not UnitExists(b.unit) then return end
    local unit=b.unit
    local status=GetCachedStatus(b)
    if not status then
        if IsInGroup() then
            local range=UnitInRange(unit)
            b:SetAlpha(range and 1 or .45)
        else
            b:SetAlpha(IsInRange(unit))
        end
    end
end
function F:UpdateTargetAlpha()
    if soloBtn[2] and soloBtn[2]:IsVisible() then
        F:UpdateAlpha(soloBtn[2])
    end
    if soloBtn[6] and soloBtn[6]:IsVisible() then
        F:UpdateAlpha(soloBtn[6])
    end
end
local function UpdateAlpha()
    for _,button in pairs(raidBtn) do
        if button and button:IsVisible() then
            F:UpdateAlpha(button)
        end
    end
    F:UpdateTargetAlpha()
end
local update,i=nil,0
function F:RangeEnable()
    if not update then
        update=C_Ticker(1,function()
            i=i+1
            if i>=6 then
                i=0
                CleanupCache()
            end
            UpdateAlpha()
        end)
    end
end
function F:RangeDisable()
    if update then
        update:Cancel()
        update=nil
    end
    for _,b in pairs(raidBtn) do
        b:SetAlpha(1)
    end
    if soloBtn[2] and soloBtn[2]:IsVisible() then
        soloBtn[2]:SetAlpha(1)
    end
    if soloBtn[6] and soloBtn[6]:IsVisible() then
        soloBtn[6]:SetAlpha(1)
    end
    table.wipe(cache)
    i=0
end
--[[
local fTbl={
    PRIEST=2061,-- Flash Heal
    SHAMAN=403,-- Lightning Bolt
    PALADIN=19750,-- Flash of Light
    DRUID=8936,-- Regrowth
    MAGE=1459,-- Arcane intellect
    WARLOCK=2970,-- Detect Invisibility
    HUNTER=75,-- Auto Shot
    ROGUE=36554-- Shadowstep
    WARRIOR=6673 --battle-shout
}
local hTbl={
    PRIEST=589,-- spell=589/shadow-word-pain
    SHAMAN=403,-- Lightning Bolt
    DRUID=8921,-- Moonfire
    PALADIN=21084,-- seal-of-righteousness
    MAGE=133,-- Fireball
    WARLOCK=17793,-- Shadow Bolt
    HUNTER=75,-- Auto Shot
    ROGUE=6770,-- Sap
    WARRIOR=355    -- Taunt
}
]]