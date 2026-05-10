local D,F=unpack(select(2,...))
local C_Ticker,pairs,CheckInteractDistance=C_Timer.NewTicker,pairs,CheckInteractDistance
local UnitCanAssist,UnitCanAttack,IsSpellInRange=UnitCanAssist,UnitCanAttack,C_Spell.IsSpellInRange
local petBtn,raidBtn,soloBtn,UnitIsInteractable=D.petBtn,D.raidBtn,D.soloBtn,UnitIsInteractable
local fTbl,hTbl={6673,19750,75,36554,2061,0,403,1459,2970,0,8936},{355,21084,75,6770,589,0,403,133,17793,0,8921}
local f,h=fTbl[select(3,UnitClass("player"))],hTbl[select(3,UnitClass("player"))]
local function IsInRange(unit)
    if not unit then return end
    local range
    local assist=CheckInteractDistance(unit,4) and not InCombatLockdown()
    local attack=CheckInteractDistance(unit,1) and not InCombatLockdown()
    local interact=CheckInteractDistance(unit,3) and not InCombatLockdown()
    if UnitCanAssist("player",unit) then
        range=assist or IsSpellInRange(f,unit)
    elseif UnitCanAttack("player",unit) then
        range=attack or IsSpellInRange(h,unit)
    elseif UnitIsInteractable("target") then
        range=interact or false
    end
    return range and 1 or .45
end
local function UpdateAlpha(b)
    if not b or not b.unit then return end
    local unit=b.unit
    b:SetAlpha(IsInRange(unit))
end
local function UpdateUnits()
    for _,b in pairs(raidBtn) do
        if b:IsVisible() then
            UpdateAlpha(b)
        end
    end
    for _,b in pairs(petBtn) do
        if b:IsVisible() then
            UpdateAlpha(b)
        end
    end
    if soloBtn[4]:IsVisible() then
        UpdateAlpha(soloBtn[4])
    end
    if soloBtn[6]:IsVisible() then
        UpdateAlpha(soloBtn[6])
    end
    F:UpdateTargetAlpha()
end
function F:UpdateTargetAlpha()
    if soloBtn[2]:IsVisible() then
        UpdateAlpha(soloBtn[2])
    end
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
--[[
local C_Ticker,pairs,event=C_Timer.NewTicker,pairs,S.EventFrame
local UnitInRange,IsInGroup,CheckInteractDistance=UnitInRange,IsInGroup,CheckInteractDistance
local UnitCanAssist,UnitCanAttack,IsSpellInRange,UnitInParty=UnitCanAssist,UnitCanAttack,C_Spell.IsSpellInRange,UnitInParty
local petBtn,raidBtn,soloBtn,UnitExists=D.petBtn,D.raidBtn,D.soloBtn,UnitExists  --IsFlying
  for _,b in pairs(raidBtn) do
        b:SetAlpha(1)
    end
    for _,b in pairs(petBtn) do
        b:SetAlpha(1)
    end
    soloBtn[2]:SetAlpha(1)
    soloBtn[4]:SetAlpha(1)
    soloBtn[6]:SetAlpha(1)
local function UpdateAlpha(b)
    if not b or not b.unit  then return end
    local unit=b.unit
    if IsInGroup() then
        if unit~="player" then
            local r=UnitInRange(unit) and 1 or .45
            b:SetAlpha(r)
        end
    else
        b:SetAlpha(IsInRange(unit))
    end
end
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