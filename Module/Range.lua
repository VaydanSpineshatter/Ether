local _, Ether = ...
local Range = {}
Ether.Range = Range

local SpellRange = LibStub("SpellRange-1.0")
local U_GUID = UnitGUID
local U_EX = UnitExists
local U_CAS = UnitCanAssist
local U_CAT = UnitCanAttack
local U_I_Range = UnitInRange
local Check_D = CheckInteractDistance
local pairs = pairs
local C_Ticker = C_Timer.NewTicker


local classFriendly = {
        PRIEST = 2061, -- Flash Heal
        SHAMAN = 403, -- Lightning Bolt
        PALADIN = 19750, -- Flash of Light
        DRUID = 8936, -- Regrowth
        MAGE = 1459, -- Arcane intellect
        WARLOCK = 2970, -- Detect Invisibility
        ROUGE = 36554, -- Shadowstep
        WARRIOR = 6673, -- Battle Shout
    }

 local  classHostile = {
        PRIEST = 585, -- Smite
        MAGE = 133, -- Fireball
        WARLOCK = 17793, -- Shadow Bolt
        SHAMAN = 403, -- Lightning Bolt
        PALADIN = 21084, -- seal-of-righteousness
        DRUID = 8921, -- Moonfire
        HUNTER = 75, -- Auto Shot
        ROGUE = 6770, -- Sap
        WARRIOR = 355 -- Taunt
    }


local _, playerClass = UnitClass("player")
local friendly = classFriendly[playerClass] or 355
local hostile = classHostile[playerClass] or 772
local isMelee = (playerClass == "ROGUE" or playerClass == "WARRIOR")

local function IsUnitInRange(unit)

    if not U_EX(unit) then
        return false
    end

    local guid = U_GUID(unit)
    if not guid then
        return true
    end

    local inRange
    if U_CAS("player", unit) and not isMelee then
        inRange = SpellRange.IsSpellInRange(friendly, unit)
       -- if isMelee then
           -- return Check_D(unit, 3)
      --  end
    elseif U_CAT("player", unit) and isMelee then
        inRange = SpellRange.IsSpellInRange(hostile, unit)
       -- if isMelee then
           -- return Check_D(unit, 3)
      --  end
    else
        inRange = U_I_Range(unit)
    end

    if inRange == nil then
        inRange = Check_D(unit, 3) or Check_D(unit, 2) or U_I_Range(unit)
    end

    return inRange == 1
end

local function UpdateAlpha(button)
    if not button or not button.unit then
        return
    end
    local inRange = IsUnitInRange(button.unit)
    button:SetAlpha(inRange and 1.0 or 0.45)
    button.rangeInRange = inRange
end

local function UpdateAllButtons()
    for _, buttons in pairs({ Ether.Buttons.raid, Ether.Buttons.party }) do
        for _, button in pairs(buttons) do
            UpdateAlpha(button)
        end
    end
    if Ether.unitButtons["target"] then
        UpdateAlpha(Ether.unitButtons["target"])
    end
end

function Range:OnRosterOnTarget()
    UpdateAllButtons()
end

function Range:UpdateInRange(unit)
    local button = Ether.Buttons.raid[unit] or Ether.Buttons.party[unit] or Ether.unitButtons["target"] or nil
    if button then
        Range:UpdateAlpha(button)
    end
end

local rangeTicker = nil

function Range:CleanUp()
    for _, buttons in pairs({ Ether.Buttons.raid, Ether.Buttons.party }) do
        for _, button in pairs(buttons) do
            if button then
                button:SetAlpha(1.0)
            end
        end
    end
    if Ether.unitButtons["target"] then
        Ether.unitButtons["target"]:SetAlpha(1.0)
    end
end

function Range:Enable()
    if not rangeTicker then
        rangeTicker = C_Ticker(2.2, UpdateAllButtons)
    end
end

function Range:Disable()
    if rangeTicker then
        rangeTicker:Cancel()
        rangeTicker = nil
    end
   Range:CleanUp()
end




