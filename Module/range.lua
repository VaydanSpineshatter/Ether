local D,F=unpack(select(2,...))
local C_Ticker,pairs,GetTime=C_Timer.NewTicker,pairs,GetTime
local UnitInRange,UnitIsConnected,IsInGroup=UnitInRange,UnitIsConnected,IsInGroup
local UnitCanAssist,UnitCanAttack,IsSpellInRange,UnitIsVisible,UnitPhaseReason=UnitCanAssist,UnitCanAttack,C_Spell.IsSpellInRange,UnitIsVisible,UnitPhaseReason
local raidBtn,soloBtn,UnitExists,IsFlying=D.raidBtn,D.soloBtn,UnitExists,IsFlying
local fTbl,hTbl={6673,19750,75,36554,2061,0,403,1459,2970,0,8936},{355,21084,75,6770,589,0,403,133,17793,0,8921}
local f,h=fTbl[select(3,UnitClass("player"))],hTbl[select(3,UnitClass("player"))]
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
local is,none=5,4
local cache={}
local function CleanupCache()
    local currentTime=GetTime()
    for unit,data in pairs(cache) do
        if (currentTime-data.timestamp)>=is then
            cache[unit]=nil
        end
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
local function ticker()
    if not update then
        update=C_Ticker(1,function()
            i=i+1
            if i>=5 then
                i=0
                CleanupCache()
            end
            UpdateAlpha()
        end)
    end
end
local function clear()
    if update then
        update:Cancel()
        update=nil
    end
end
local function ScanUnits(b,unit)
    if IsFlying("player") then
        b:SetAlpha(.7)
        is,none=8,7
        return true
    end
    if not UnitIsConnected(unit) then
        b:SetAlpha(1)
        is,none=5,4
        return true
    end
    if UnitPhaseReason(unit) then
        b:SetAlpha(.45)
        is,none=6,5
        return true
    end
    if not UnitIsVisible(unit) then
        b:SetAlpha(.45)
        is,none=5,4
        return true
    end
    if is~=5 then
        is,none=5,4
    end
    return false
end
local function GetCachedStatus(b)
    local unit=b.unit
    local status=cache[unit]
    if status and (GetTime()-status.timestamp)<=4 then
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
function F:RangeEnable()
    ticker()
end
function F:RangeDisable()
    clear()
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
    is,none,i=5,4,0
end
F:RegisterCallbackByIndex(F.RangeEnable,5)
F:RegisterCallbackByIndex(F.RangeDisable,5+30)
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