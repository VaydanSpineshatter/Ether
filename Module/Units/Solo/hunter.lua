local _,Ether=...

local petInfo={
    [1]={0.375,0.5625,0,0.359375},
    [2]={0.1875,0.375,0,0.359375},
    [3]={0,0.1875,0,0.359375}
}

local function PetStatus(self)
    local happiness=GetPetHappiness()
    if (happiness) then
        self.happy:SetTexCoord(unpack(petInfo[happiness]))
    end
end

local function Enter(self)
    if not UnitExists("pet") then
        return
    end
    local happiness,damagePercentage,loyaltyRate=GetPetHappiness()
    local petType=UnitCreatureFamily('pet')
    GameTooltip:SetOwner(self,'ANCHOR_RIGHT')
    GameTooltip:SetText('Condition:')
    GameTooltip:AddLine('Family: '..petType)
    GameTooltip:AddLine('Happiness: '..({'Unhappy','Content','Happy'})[happiness])
    GameTooltip:AddLine('Loyalty: '..(loyaltyRate or 'N/A'))
    GameTooltip:AddLine('Pet is doing '..damagePercentage..'% damage')
    GameTooltip:Show()
end

local function Leave()
    if not UnitExists("pet") then
        return
    end
    GameTooltip:Hide()
end

local function Event(self,event,unit)
    if unit and unit ~= "pet" then
        return
    end
    local petButton = Ether.unitButtons.solo["pet"]
    if not (petButton and petButton:IsVisible()) then
        return
    end
    if event == "UNIT_HAPPINESS" then
        PetStatus(self)
    elseif event == "UNIT_PET" or event == "PET_UI_UPDATE" then
        PetStatus(self)
    end
end

function Ether:PetCondition(button)
    if not button or not button.healthBar then
        return
    end
    local _,classFileName=UnitClass("player")
    if classFileName~="HUNTER" then
        return
    end
    local condition=CreateFrame("Frame",nil,button)
    condition:SetFrameLevel(button.healthBar:GetFrameLevel()+1)
    condition:SetSize(16,16)
    condition:SetPoint("BOTTOMRIGHT",button.healthBar,"BOTTOMRIGHT",0,0)
    local happy=condition:CreateTexture(nil,"OVERLAY")
    condition.happy=happy
    happy:SetTexture("Interface\\PetPaperDollFrame\\UI-PetHappiness")
    happy:SetAllPoints()
    condition:SetScript("OnEnter",Enter)
    condition:SetScript("OnLeave",Leave)
    condition:RegisterUnitEvent("UNIT_HAPPINESS","pet")
    condition:RegisterUnitEvent("UNIT_PET","player")
    condition:RegisterEvent("PET_UI_UPDATE")
    condition:SetScript("OnEvent",Event)
    C_Timer.After(1, function()
          PetStatus(condition)
    end)
end