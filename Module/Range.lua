local _,Ether=...

local pairs=pairs
local C_Ticker=C_Timer.NewTicker
local UnitIsVisible=UnitIsVisible
--local UnitInAnyGroup = UnitInAnyGroup
local UnitPhaseReason=UnitPhaseReason
local UnitInRange=UnitInRange
local IsSpellInRange=C_Spell.IsSpellInRange
local UnitCanAssist=UnitCanAssist
local UnitCanAttack=UnitCanAttack

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
    PRIEST=585,-- Smite
    SHAMAN=403,-- Lightning Bolt
    DRUID=8921,-- Moonfire
    PALADIN=21084,-- seal-of-righteousness
    MAGE=133,-- Fireball
    WARLOCK=17793,-- Shadow Bolt
    HUNTER=75,-- Auto Shot
    ROGUE=6770,-- Sap
    WARRIOR=355 -- Taunt
}

local _,playerClass=UnitClass("player")
local friendly=classFriendly[playerClass] or 355
local hostile=classHostile[playerClass] or 772
local raidButtons=Ether.raidButtons
local soloButtons=Ether.soloButtons

function Ether:IsUnitInRange(unit)
    if not unit then
        return
    end

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

function Ether:UpdateAlpha(button)
    if not button or not button.unit then
        return
    end
    local inRange
    if not UnitIsVisible(button.unit) or UnitPhaseReason(button.unit) then
        button:SetAlpha(0.45)
        return
    end
    if IsInGroup() then
        inRange=UnitInRange(button.unit)
    else
        inRange=Ether:IsUnitInRange(button.unit)
    end
    local value=inRange and 1.0 or 0.45
    button:SetAlpha(value)
end

local function UpdateTargetAlpha()
    if soloButtons["target"] and soloButtons["target"]:IsVisible() then
        Ether:UpdateAlpha(soloButtons["target"])
    end
end

local function UpdateRaidAlpha()
    for _,button in pairs(raidButtons) do
        if button and button:IsVisible() then
            Ether:UpdateAlpha(button)
        end
    end
end

local rangeTicker=nil

function Ether:RangeEnable()
    if not rangeTicker then
        rangeTicker=C_Ticker(1.3,function()
            UpdateTargetAlpha()
            UpdateRaidAlpha()
        end)
    end
end

function Ether:RangeDisable()
    if rangeTicker then
        rangeTicker:Cancel()
        rangeTicker=nil
    end
    if soloButtons["target"] and soloButtons["target"]:IsVisible() then
       soloButtons["target"]:SetAlpha(1)
    end
    for _,button in pairs(raidButtons) do
        if button and button:IsVisible() then
            button:SetAlpha(1.0)
        end
    end
end
