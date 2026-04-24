local D,F,_,C=unpack(select(2,...))
local C_Ticker,pairs=C_Timer.NewTicker,pairs
local UnitIsVisible,UnitPhaseReason=UnitIsVisible,UnitPhaseReason
local UnitInRange=UnitInRange
local IsSpellInRange=C_Spell.IsSpellInRange
local UnitCanAssist,UnitCanAttack=UnitCanAssist,UnitCanAttack
local petBtn,raidBtn,soloBtn=D.petBtn,D.raidBtn,D.soloBtn
local classFriendly={
    PRIEST=2061,-- Flash Heal
    SHAMAN=403,-- Lightning Bolt
    PALADIN=19750,-- Flash of Light
    DRUID=8936,-- Regrowth
    MAGE=1459,-- Arcane intellect
    WARLOCK=2970,-- Detect Invisibility
    HUNTER=75,-- Auto Shot
    ROGUE=36554,-- Shadowstep
}
local classHostile={
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
local friendly=classFriendly[C.ClassName] or 355
local hostile=classHostile[C.ClassName] or 589
local function IsInRange(unit)
    if not unit then return end
    local inRange
    if UnitCanAssist("player",unit) then
       inRange=IsSpellInRange(friendly,unit)
    elseif UnitCanAttack("player",unit) then
        inRange=IsSpellInRange(hostile,unit)
    else
        return
    end
    return inRange
end
local function IsUnitInRange(unit)
    if not unit then return end
    local inRange
    if UnitCanAssist("player",unit) then
        inRange=UnitInRange(unit)
    elseif UnitCanAttack("player",unit) then
        inRange=IsSpellInRange(hostile,unit)
    end
    return inRange
end

function F:UpdateAlpha(button)
    if not button then return end
    local unit=button.unit
    local inRange
    if not UnitIsVisible(unit) or UnitPhaseReason(unit) then
        button:SetAlpha(0.45)
        return
    end
    if IsInGroup() then
        inRange=IsUnitInRange(unit)
    else
        inRange=IsInRange(unit)
    end
    local value=inRange and 1.0 or 0.45
    button:SetAlpha(value)
end

function F:UpdateTargetAlpha()
    if soloBtn[2] and soloBtn[2]:IsVisible() then
        F:UpdateAlpha(soloBtn[2])
    end
    if soloBtn[6] and soloBtn[6]:IsVisible() then
        F:UpdateAlpha(soloBtn[6])
    end
end

local function UpdateRaidAlpha()
    for _,button in pairs(raidBtn) do
        if button and button:IsVisible() then
            F:UpdateAlpha(button)
        end
    end
    for _,button in pairs(petBtn) do
        if button and button:IsVisible() then
            F:UpdateAlpha(button)
        end
    end
end
local update
update=nil
function F:RangeEnable()
    if not update then
        update=C_Ticker(1,function()
            F:UpdateTargetAlpha()
            UpdateRaidAlpha()
        end)
    end
end
function F:RangeDisable()
    if update then
        update:Cancel()
        update=nil
    end
    for _,button in pairs(raidBtn) do
        if button then
            button:SetAlpha(1)
        end
    end
   for _,button in pairs(petBtn) do
        if button then
            button:SetAlpha(1)
        end
    end
    if soloBtn[2] and soloBtn[2]:IsVisible() then
        soloBtn[2]:SetAlpha(1)
    end
    if soloBtn[6] and soloBtn[6]:IsVisible() then
        soloBtn[6]:SetAlpha(1)
    end
end
