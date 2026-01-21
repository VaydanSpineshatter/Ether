local _, Ether = ...
local Range = {}
Ether.Range = Range

local pairs = pairs
local C_Ticker = C_Timer.NewTicker

local classFriendly = {
    PRIEST = 2061, -- Flash Heal
    SHAMAN = 403, -- Lightning Bolt
    PALADIN = 19750, -- Flash of Light
    DRUID = 8936, -- Regrowth
    MAGE = 1459, -- Arcane intellect
    WARLOCK = 2970, -- Detect Invisibility
    HUNTER = 75, -- Auto Shot
    ROUGE = 36554, -- Shadowstep
}

local classHostile = {
    PRIEST = 585, -- Smite
    SHAMAN = 403, -- Lightning Bolt
    DRUID = 8921, -- Moonfire
    PALADIN = 21084, -- seal-of-righteousness
    MAGE = 133, -- Fireball
    WARLOCK = 17793, -- Shadow Bolt
    HUNTER = 75, -- Auto Shot
    ROGUE = 6770, -- Sap
    WARRIOR = 355 -- Taunt
}

local _, playerClass = UnitClass("player")
local friendly = classFriendly[playerClass] or 355
local hostile = classHostile[playerClass] or 772
--local isMelee = (playerClass == "ROGUE" or playerClass == "WARRIOR")

function Range:IsUnitInRange(unit)
    if not unit then
        return
    end

    local inRange
    if UnitCanAssist("player", unit) then
        inRange = C_Spell.IsSpellInRange(friendly, unit)
    elseif UnitCanAttack("player", unit) then
        inRange = C_Spell.IsSpellInRange(hostile, unit)
    else
        return
    end

    return inRange
end

function Range:UpdateAlpha(button)
    if not button or not button.unit then
        return
    end
    local inRange
    if UnitPhaseReason(button.unit) then
        return
    end
    if IsInGroup() then
        inRange = UnitInRange(button.unit)
    else
        inRange = Range:IsUnitInRange(button.unit)
    end
    button:SetAlpha(inRange and 1.0 or 0.45)
end

function Range:UpdateTargetAlpha()
    if Ether.DB[201][2] == 1 then
        if Ether.unitButtons["target"] then
            Range:UpdateAlpha(Ether.unitButtons["target"])
        end
    end

    if Ether.DB[201][7] == 1 then
        for _, button in pairs(Ether.Buttons.party) do
            if button and button.unit and button:IsVisible() then
                Range:UpdateAlpha(button)
            end
        end
    end

    if Ether.DB[201][8] == 1 then
        for _, button in pairs(Ether.Buttons.raid) do
            if button and button.unit and button:IsVisible() then
                Range:UpdateAlpha(button)
            end
        end
    end

end

local function RemoveAlpha()
    if Ether.unitButtons["target"] then
        Ether.unitButtons["target"]:SetAlpha(1)
    end
    for _, button in pairs(Ether.Buttons.raid) do
        if button and button:IsVisible() then
            button:SetAlpha(1.0)
        end
    end
    for _, button in pairs(Ether.Buttons.party) do
        if button and button:IsVisible() then
            button:SetAlpha(1.0)
        end
    end
end

local rangeTicker = nil

function Range:Enable()
    if not rangeTicker then
        rangeTicker = C_Ticker(1.7, function()
            Range:UpdateTargetAlpha()
        end)
    end
end

function Range:Disable()
    if rangeTicker then
        rangeTicker:Cancel()
        rangeTicker = nil
    end
    RemoveAlpha()
end
