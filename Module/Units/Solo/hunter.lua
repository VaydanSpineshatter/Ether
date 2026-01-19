local _, Ether = ...


function Ether:PetCondition(button)
    if (InCombatLockdown()) then
        return
    end
    local _, classFileName = UnitClass("player")
    if classFileName ~= "HUNTER" then
        return
    end
    if (not button.healthBar) then
        return
    end
    local condition = CreateFrame("Frame", "nil", button)

    condition:SetSize(16, 16)
    condition:SetPoint("BOTTOMRIGHT", button.healthBar, "BOTTOMRIGHT", 0, 0)

    condition.happy = condition:CreateTexture(nil, "OVERLAY")
    condition.happy:SetTexture("Interface\\PetPaperDollFrame\\UI-PetHappiness")
    condition.happy:SetAllPoints(condition)

    condition.happy:SetScript("OnEnter", function()
        if not UnitExists("pet") then
            return
        end
        local happiness, damagePercentage, loyaltyRate = GetPetHappiness()
        local petType = UnitCreatureFamily("pet")
        GameTooltip:SetOwner(condition, "ANCHOR_RIGHT")
        GameTooltip:SetText("Condition:")
        GameTooltip:AddLine("Family: " .. petType)
        GameTooltip:AddLine("Happiness: " .. ({ "Unhappy", "Content", "Happy" })[happiness])
        GameTooltip:AddLine("Loyalty: " .. (loyaltyRate or "N/A"))
        GameTooltip:AddLine("Pet is doing " .. damagePercentage .. "% damage")
        GameTooltip:Show()
    end)
    condition.happy:SetScript("OnLeave", GameTooltip_Hide)

    local PET_CORDS = {
        [1] = { 0.375, 0.5625, 0, 0.359375 },
        [2] = { 0.1875, 0.375, 0, 0.359375 },
        [3] = { 0, 0.1875, 0, 0.359375 },
    }

    local function PetStatus()
        local happiness = GetPetHappiness()
        if (happiness) then
            condition.happy:SetTexCoord(unpack(PET_CORDS[happiness]))
        end
    end

    local function OnPetEvent(_, event, unit)
        if event == "UNIT_POWER_UPDATE" and unit == "pet" then
            local happiness = UnitPower("pet", Enum.PowerType.Happiness)
            if happiness then
                PetStatus()
            end

        elseif (event == "UNIT_PET") then
            Ether.UpdateName(button)
        end
    end
    local petEvent = CreateFrame('Frame')
    PetStatus()
    petEvent:RegisterUnitEvent("UNIT_POWER_UPDATE", "pet")
    petEvent:RegisterUnitEvent("UNIT_PET", "player")
    petEvent:SetScript("OnEvent", OnPetEvent)
end