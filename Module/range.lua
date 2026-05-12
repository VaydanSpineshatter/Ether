local D,F,_,C=unpack(select(2,...))
local C_Ticker,pairs,CheckInteractDistance=C_Timer.NewTicker,pairs,CheckInteractDistance
local UnitCanAssist,UnitCanAttack,IsSpellInRange=UnitCanAssist,UnitCanAttack,C_Spell.IsSpellInRange
local petBtn,raidBtn,soloBtn,UnitIsInteractable=D.petBtn,D.raidBtn,D.soloBtn,UnitIsInteractable
local fTbl,hTbl={6673,19750,75,36554,2061,0,403,1459,2970,0,8936},{355,21084,75,6770,589,0,403,133,17793,0,8921}
local f,h=fTbl[select(3,UnitClass("player"))],hTbl[select(3,UnitClass("player"))]
local function IsInRange(unit)
    if not unit then return end
    local range
    if UnitCanAssist("player",unit) then
        range=IsSpellInRange(f,unit)
    elseif UnitCanAttack("player",unit) then
        range=IsSpellInRange(h,unit)
    elseif UnitIsInteractable("target") then
        range=UnitCanAssist("player",unit) and true or false
    end
    return range and 1 or .45
end
local function IsInDistance(unit)
    if not unit then return end
    local range
    if UnitCanAssist("player",unit) then
        range=CheckInteractDistance(unit,4)
    elseif UnitCanAttack("player",unit) then
        range=CheckInteractDistance(unit,1)
    elseif UnitIsInteractable("target") then
        range=CheckInteractDistance(unit,3)
    end
    return range and 1 or .45
end
local function UpdateAlpha(b)
    if not b or not b.unit then return end
    local unit=b.unit
    if b:IsVisible() then
        if InCombatLockdown() then
            b:SetAlpha(IsInRange(unit))
        else
            b:SetAlpha(IsInDistance(unit))
        end
    end
end
local function UpdateUnits()
    for _,b in pairs(raidBtn) do
        UpdateAlpha(b)
    end
    for _,b in pairs(petBtn) do
        UpdateAlpha(b)
    end
    UpdateAlpha(soloBtn[4])
    UpdateAlpha(soloBtn[6])
    F:UpdateTargetAlpha()
end
function F:UpdateTargetAlpha()
    UpdateAlpha(soloBtn[2])
end
local updater
updater=nil
function F:RangeEnable()
    UpdateUnits()
    if not updater then
        updater=C_Ticker(.8,function()
            UpdateUnits()
        end)
    end
end
function F:RangeDisable()
    if updater then
        updater:Cancel()
        if updater:IsCancelled() then
            updater=nil
        end
    end
    UpdateUnits()
end
F:RegisterCallbackByIndex(F.RangeEnable,5)
F:RegisterCallbackByIndex(F.RangeDisable,5+30)
--[[Assist
PRIEST=2061,-- Flash Heal
SHAMAN=403,-- Lightning Bolt
PALADIN=19750,-- Flash of Light
DRUID=8936,-- Regrowth
MAGE=1459,-- Arcane intellect
WARLOCK=2970,-- Detect Invisibility
HUNTER=75,-- Auto Shot
ROGUE=36554-- Shadowstep
WARRIOR=6673 --battle-shout
}Attack
PRIEST=589,-- spell=589/shadow-word-pain
SHAMAN=403,-- Lightning Bolt
DRUID=8921,-- Moonfire
PALADIN=21084,-- seal-of-righteousness
MAGE=133,-- Fireball
WARLOCK=17793,-- Shadow Bolt
HUNTER=75,-- Auto Shot
ROGUE=6770,-- Sap
WARRIOR=355    -- Taunt
]]
