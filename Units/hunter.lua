local D,F,S,C=unpack(select(2,...))
local UnitCreatureFamily,UnitExists=UnitCreatureFamily,UnitExists
local GetPetHappiness,GameTooltip=GetPetHappiness,GameTooltip
local event=S.EventFrame
local petBtn=D.soloBtn
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
    if UnitExists("pet") then
        local happiness,damagePercentage,loyaltyRate=GetPetHappiness()
        local petType=UnitCreatureFamily("pet")
        GameTooltip:SetOwner(self,'ANCHOR_RIGHT')
        GameTooltip:SetText('Condition:',0,0.8,1)
        GameTooltip:AddLine('Family: '..petType)
        GameTooltip:AddLine('Happiness: '..({'Unhappy','Content','Happy'})[happiness])
        GameTooltip:AddLine('Loyalty: '..(loyaltyRate or 'N/A'))
        GameTooltip:AddLine('Pet is doing '..damagePercentage..'% damage')
        GameTooltip:Show()
    end
end
local function Leave()
    if UnitExists("pet") then
        GameTooltip:Hide()
    end
end
function event:UNIT_HAPPINESS()
    if petBtn[4]:IsVisible() then
        PetStatus(C.condition)
    end
end
function event:UNIT_PET()
    if petBtn[4]:IsVisible() then
        PetStatus(C.condition)
    end
end
function event:PET_UI_UPDATE()
    if petBtn[4]:IsVisible() then
        PetStatus(C.condition)
    end
end
function F:PetCondition()
    if C.ClassName~="HUNTER" then return end
    local condition=CreateFrame("Frame",nil,petBtn[4])
    C.condition=condition
    condition:SetFrameLevel(petBtn[4].healthBar:GetFrameLevel()+1)
    condition:SetSize(16,16)
    condition:SetPoint("BOTTOMRIGHT",petBtn[4].healthBar,"BOTTOMRIGHT",0,0)
    local happy=condition:CreateTexture(nil,"OVERLAY")
    condition.happy=happy
    happy:SetTexture("Interface\\PetPaperDollFrame\\UI-PetHappiness")
    happy:SetAllPoints()
    event:RegisterUnitEvent("UNIT_HAPPINESS","pet")
    event:RegisterUnitEvent("UNIT_PET","player")
    event:RegisterEvent("PET_UI_UPDATE")
    condition:SetScript("OnEnter",Enter)
    condition:SetScript("OnLeave",Leave)
    C_Timer.After(1,function()
        PetStatus(condition)
    end)
end